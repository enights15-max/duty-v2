<?php

namespace App\Services;

use App\Models\Customer;
use App\Models\Reservation\ReservationPayment;
use App\Models\Reservation\TicketReservation;
use App\Services\Payments\PaymentGatewayRegistry;
use Exception;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\DB;

class AdminReservationRefundService
{
    public const HIGH_VALUE_REFUND_THRESHOLD = 5000.00;
    private const MIN_ADMIN_NOTE_LENGTH = 12;
    private const COMPLEX_CASE_NOTE_LENGTH = 24;

    public const REASON_EVENT_REPROGRAMMED = 'event_reprogrammed';
    public const REASON_EVENT_CANCELLED = 'event_cancelled';
    public const REASON_OPERATIONAL_INCIDENT = 'operational_incident';
    public const REASON_GOODWILL_EXCEPTION = 'goodwill_exception';
    public const REASON_DISPUTE_RESOLUTION = 'dispute_resolution';

    public const RISK_TREASURY_IMPACT = 'treasury_impact';
    public const RISK_HIGH_VALUE = 'high_value';
    public const RISK_GATEWAY_REFUND = 'gateway_refund';
    public const RISK_CUSTOMER_ESCALATION = 'customer_escalation';
    public const RISK_MANUAL_EXCEPTION = 'manual_exception';

    public function __construct(
        private WalletService $walletService,
        private BonusWalletService $bonusWalletService,
        private PaymentGatewayRegistry $paymentGatewayRegistry,
        private EventTreasuryService $eventTreasuryService
    ) {
    }

    public function refundReasonOptions(): array
    {
        return [
            self::REASON_EVENT_REPROGRAMMED => 'Event reprogrammed',
            self::REASON_EVENT_CANCELLED => 'Event cancelled',
            self::REASON_OPERATIONAL_INCIDENT => 'Operational incident',
            self::REASON_GOODWILL_EXCEPTION => 'Goodwill exception',
            self::REASON_DISPUTE_RESOLUTION => 'Dispute resolution',
        ];
    }

    public function refundRiskFlagOptions(): array
    {
        return [
            self::RISK_TREASURY_IMPACT => 'Treasury impact',
            self::RISK_HIGH_VALUE => 'High value refund',
            self::RISK_GATEWAY_REFUND => 'Gateway/card refund',
            self::RISK_CUSTOMER_ESCALATION => 'Customer escalation',
            self::RISK_MANUAL_EXCEPTION => 'Manual exception',
        ];
    }

    public function refundGovernanceRules(): array
    {
        return [
            'high_value_threshold' => self::HIGH_VALUE_REFUND_THRESHOLD,
            'min_admin_note_length' => self::MIN_ADMIN_NOTE_LENGTH,
            'complex_admin_note_length' => self::COMPLEX_CASE_NOTE_LENGTH,
            'rules' => [
                [
                    'key' => 'gateway_refund_requires_flag',
                    'label' => 'Card or gateway refunds must include the Gateway/card refund risk flag.',
                ],
                [
                    'key' => 'high_value_requires_flag',
                    'label' => 'Refunds at or above RD$ ' . number_format(self::HIGH_VALUE_REFUND_THRESHOLD, 2) . ' must include the High value refund flag.',
                ],
                [
                    'key' => 'goodwill_requires_manual_exception',
                    'label' => 'Goodwill exceptions must include the Manual exception risk flag and a detailed note.',
                ],
                [
                    'key' => 'dispute_requires_escalation_and_manual_exception',
                    'label' => 'Dispute resolution refunds must include both Customer escalation and Manual exception flags.',
                ],
                [
                    'key' => 'complex_cases_require_longer_note',
                    'label' => 'Goodwill and dispute cases require a more detailed admin note for audit purposes.',
                ],
            ],
        ];
    }

    public function refund(TicketReservation $reservation, array $requested = [], array $decision = []): array
    {
        $reservation->loadMissing('customer', 'payments');

        if (!in_array($reservation->status, ['cancelled', 'defaulted'], true)) {
            throw new Exception('Refunds are available only for cancelled or defaulted reservations.');
        }

        $customer = $reservation->customer;
        if (!$customer instanceof Customer) {
            throw new Exception('Reservation customer not found.');
        }

        $refundables = $this->resolveRefundables($reservation->payments);
        if ($refundables->isEmpty()) {
            throw new Exception('No refundable balance remains on this reservation.');
        }

        $refundPlan = $this->resolveRequestedRefunds($refundables, $requested);
        if ($refundPlan->isEmpty()) {
            throw new Exception('No refundable amount was selected.');
        }

        $decision = $this->normalizeDecisionContext($decision);
        $decision = $this->enforceDecisionGovernance($decision, $refundPlan);

        $reservation->loadMissing('event');

        $refundedRows = DB::transaction(function () use ($reservation, $customer, $refundPlan) {
            $createdRows = collect();

            foreach ($refundPlan as $entry) {
                /** @var ReservationPayment $payment */
                $payment = $entry['payment'];
                $refundBase = $entry['amount'];
                $refundFee = $entry['fee_amount'];
                $refundGross = $entry['total_amount'];

                if ($refundGross <= 0) {
                    continue;
                }

                $refundSourceType = $payment->source_type . '_refund';
                $refundGroup = 'refund_for_' . $payment->id;

                switch ($payment->source_type) {
                    case 'wallet':
                        $walletTransaction = $this->walletService->credit(
                            $customer,
                            $refundBase,
                            'reservation_wallet_admin_refund',
                            (string) $payment->id,
                            'reservation_wallet_admin_refund_' . $payment->id
                        );

                        $createdRows->push(ReservationPayment::create([
                            'reservation_id' => $reservation->id,
                            'payment_group' => $refundGroup,
                            'source_type' => $refundSourceType,
                            'amount' => -$refundBase,
                            'fee_amount' => 0,
                            'total_amount' => -$refundBase,
                            'reference_type' => 'wallet_transaction',
                            'reference_id' => (string) $walletTransaction->id,
                            'status' => 'reversed',
                            'paid_at' => now(),
                        ]));
                        break;

                    case 'bonus_wallet':
                        $bonusTransaction = $this->bonusWalletService->credit(
                            $customer,
                            $refundBase,
                            'reservation_bonus_admin_refund',
                            (string) $payment->id,
                            'reservation_bonus_admin_refund_' . $payment->id,
                            'reversal'
                        );

                        $createdRows->push(ReservationPayment::create([
                            'reservation_id' => $reservation->id,
                            'payment_group' => $refundGroup,
                            'source_type' => $refundSourceType,
                            'amount' => -$refundBase,
                            'fee_amount' => 0,
                            'total_amount' => -$refundBase,
                            'reference_type' => 'bonus_transaction',
                            'reference_id' => (string) $bonusTransaction->id,
                            'status' => 'reversed',
                            'paid_at' => now(),
                        ]));
                        break;

                    case 'card':
                        if (empty($payment->reference_id)) {
                            throw new Exception('Stripe payment intent missing for one of the card payment rows.');
                        }

                        $stripeRefund = $this->paymentGatewayRegistry->refund(
                            $payment->source_type,
                            (string) $payment->reference_id,
                            $refundGross,
                            [
                                'reservation_id' => (string) $reservation->id,
                                'reservation_code' => (string) $reservation->reservation_code,
                                'reservation_payment_id' => (string) $payment->id,
                            ]
                        );

                        $createdRows->push(ReservationPayment::create([
                            'reservation_id' => $reservation->id,
                            'payment_group' => $refundGroup,
                            'source_type' => $refundSourceType,
                            'amount' => -$refundBase,
                            'fee_amount' => -$refundFee,
                            'total_amount' => -$refundGross,
                            'reference_type' => 'stripe_refund',
                            'reference_id' => (string) ($stripeRefund->id ?? ''),
                            'status' => 'reversed',
                            'paid_at' => now(),
                        ]));
                        break;

                    default:
                        throw new Exception('Unsupported payment source for refund: ' . $payment->source_type);
                }
            }

            return $createdRows;
        });

        $eventId = (int) $reservation->event_id;
        if ($eventId > 0) {
            $this->eventTreasuryService->syncReservationRefunds(
                $reservation->fresh(['event', 'payments']),
                $refundedRows
            );

            $refundReferenceIds = $refundedRows
                ->pluck('id')
                ->filter()
                ->map(fn ($id) => (string) $id)
                ->values()
                ->all();

            $this->eventTreasuryService->markSettlementHold(
                $reservation->event ?? $eventId,
                'reservation_refund_processed',
                null,
                [
                    'reservation_id' => $reservation->id,
                    'reservation_code' => $reservation->reservation_code,
                    'refund_sources' => $refundedRows->pluck('source_type')->values()->all(),
                    'refund_payment_ids' => $refundReferenceIds,
                    'refund_reason_code' => $decision['reason_code'],
                    'refund_reason_label' => $decision['reason_label'],
                    'refund_admin_note' => $decision['admin_note'],
                    'refund_risk_flags' => $decision['risk_flags'],
                    'refund_risk_flag_labels' => $decision['risk_flag_labels'],
                    'processed_by_admin_id' => $decision['processed_by_admin_id'],
                ],
                'reservation_refund_hold_' . $reservation->id . '_' . md5(implode('|', $refundReferenceIds))
            );
        }

        return [
            'rows' => $refundedRows,
            'sources' => $refundedRows->pluck('source_type')->values()->all(),
            'base_amount' => round((float) abs($refundedRows->sum('amount')), 2),
            'fee_amount' => round((float) abs($refundedRows->sum('fee_amount')), 2),
            'gross_amount' => round((float) abs($refundedRows->sum('total_amount')), 2),
            'decision' => $decision,
        ];
    }

    public function summarize(TicketReservation $reservation): array
    {
        $reservation->loadMissing('payments');

        $payments = $reservation->payments;
        $collectionSummary = $this->groupPayments($payments->whereIn('source_type', ['bonus_wallet', 'wallet', 'card']));
        $refundSummary = $this->groupPayments($payments->filter(function (ReservationPayment $payment) {
            return str_ends_with($payment->source_type, '_refund');
        }));

        $basePaid = round((float) $payments->whereIn('source_type', ['bonus_wallet', 'wallet', 'card'])->sum('amount'), 2);
        $feesPaid = round((float) $payments->whereIn('source_type', ['bonus_wallet', 'wallet', 'card'])->sum('fee_amount'), 2);
        $grossPaid = round((float) $payments->whereIn('source_type', ['bonus_wallet', 'wallet', 'card'])->sum('total_amount'), 2);

        $refundedBase = round((float) abs($payments->filter(fn (ReservationPayment $payment) => str_ends_with($payment->source_type, '_refund'))->sum('amount')), 2);
        $refundedFees = round((float) abs($payments->filter(fn (ReservationPayment $payment) => str_ends_with($payment->source_type, '_refund'))->sum('fee_amount')), 2);
        $refundedGross = round((float) abs($payments->filter(fn (ReservationPayment $payment) => str_ends_with($payment->source_type, '_refund'))->sum('total_amount')), 2);

        return [
            'collection_summary' => $collectionSummary,
            'refund_summary' => $refundSummary,
            'financials' => [
                'base_paid' => $basePaid,
                'fees_paid' => $feesPaid,
                'gross_paid' => $grossPaid,
                'remaining_balance' => round((float) $reservation->remaining_balance, 2),
                'refunded_base' => $refundedBase,
                'refunded_fees' => $refundedFees,
                'refunded_gross' => $refundedGross,
                'net_collected' => round($grossPaid - $refundedGross, 2),
            ],
            'refundable_summary' => [
                'by_source' => $this->resolveRefundables($payments)
                    ->groupBy(fn (array $entry) => (string) $entry['payment']->source_type)
                    ->map(function (Collection $rows) {
                        return [
                            'amount' => round((float) $rows->sum('amount'), 2),
                            'fee_amount' => round((float) $rows->sum('fee_amount'), 2),
                            'total_amount' => round((float) $rows->sum('total_amount'), 2),
                            'count' => $rows->count(),
                        ];
                    }),
                'gross_amount' => round((float) $this->resolveRefundables($payments)->sum('total_amount'), 2),
            ],
        ];
    }

    private function resolveRefundables(Collection $payments): Collection
    {
        return $payments
            ->whereIn('source_type', ['bonus_wallet', 'wallet', 'card'])
            ->where('status', 'completed')
            ->filter(function (ReservationPayment $payment) {
                return (float) $payment->total_amount > 0;
            })
            ->map(function (ReservationPayment $payment) use ($payments) {
                $refundRows = $payments
                    ->where('payment_group', 'refund_for_' . $payment->id)
                    ->filter(function (ReservationPayment $candidate) use ($payment) {
                        return $candidate->source_type === $payment->source_type . '_refund';
                    });

                $refundedAmount = abs((float) $refundRows->sum('amount'));
                $refundedFees = abs((float) $refundRows->sum('fee_amount'));
                $refundedGross = abs((float) $refundRows->sum('total_amount'));

                return [
                    'payment' => $payment,
                    'amount' => round(max(0, (float) $payment->amount - $refundedAmount), 2),
                    'fee_amount' => round(max(0, (float) $payment->fee_amount - $refundedFees), 2),
                    'total_amount' => round(max(0, (float) $payment->total_amount - $refundedGross), 2),
                ];
            })
            ->filter(function (array $entry) {
                return (float) $entry['total_amount'] > 0;
            })
            ->values();
    }

    private function resolveRequestedRefunds(Collection $refundables, array $requested): Collection
    {
        $requestedBySource = $this->normalizeRequestedAmounts($requested);
        if ($requestedBySource === []) {
            return $refundables->values();
        }

        $refundablesBySource = $refundables
            ->groupBy(fn (array $entry) => (string) $entry['payment']->source_type);

        $plannedRows = collect();

        foreach ($requestedBySource as $sourceType => $requestedGross) {
            /** @var Collection<int, array> $sourceRows */
            $sourceRows = $refundablesBySource->get($sourceType, collect());
            $sourceAvailable = round((float) $sourceRows->sum('total_amount'), 2);

            if ($sourceAvailable <= 0) {
                throw new Exception('No refundable balance remains for ' . str_replace('_', ' ', $sourceType) . '.');
            }

            if ($requestedGross > $sourceAvailable + 0.009) {
                $formattedAvailable = number_format($sourceAvailable, 2);
                throw new Exception('Requested refund for ' . str_replace('_', ' ', $sourceType) . " exceeds the refundable balance ({$formattedAvailable}).");
            }

            $remainingGrossCents = $this->toCents($requestedGross);

            foreach ($sourceRows as $entry) {
                if ($remainingGrossCents <= 0) {
                    break;
                }

                $rowGrossCents = $this->toCents((float) $entry['total_amount']);
                $allocationGrossCents = min($remainingGrossCents, $rowGrossCents);

                if ($allocationGrossCents <= 0) {
                    continue;
                }

                $allocation = $this->allocateRefundEntry($entry, $allocationGrossCents);
                $plannedRows->push($allocation);
                $remainingGrossCents -= $allocationGrossCents;
            }
        }

        return $plannedRows->filter(function (array $entry) {
            return (float) $entry['total_amount'] > 0;
        })->values();
    }

    private function normalizeRequestedAmounts(array $requested): array
    {
        $normalized = [];

        foreach (['bonus_wallet', 'wallet', 'card'] as $sourceType) {
            $value = $requested[$sourceType] ?? null;

            if ($value === null || $value === '') {
                continue;
            }

            $amount = round((float) $value, 2);
            if ($amount <= 0) {
                continue;
            }

            $normalized[$sourceType] = $amount;
        }

        return $normalized;
    }

    private function normalizeDecisionContext(array $decision): array
    {
        $reasonCode = trim((string) ($decision['reason_code'] ?? ''));
        $adminNote = trim((string) ($decision['admin_note'] ?? ''));
        $riskFlags = collect((array) ($decision['risk_flags'] ?? []))
            ->map(fn ($flag) => trim((string) $flag))
            ->filter()
            ->unique()
            ->values();

        $reasonOptions = $this->refundReasonOptions();
        $riskFlagOptions = $this->refundRiskFlagOptions();

        if ($reasonCode === '' || !array_key_exists($reasonCode, $reasonOptions)) {
            throw new Exception('A valid refund reason is required.');
        }

        if ($adminNote === '') {
            throw new Exception('An admin refund note is required.');
        }

        if (mb_strlen($adminNote) < self::MIN_ADMIN_NOTE_LENGTH) {
            throw new Exception('The admin refund note must be at least ' . self::MIN_ADMIN_NOTE_LENGTH . ' characters.');
        }

        $invalidRiskFlags = $riskFlags->filter(fn ($flag) => !array_key_exists($flag, $riskFlagOptions));
        if ($invalidRiskFlags->isNotEmpty()) {
            throw new Exception('Unsupported refund risk flag detected.');
        }

        return [
            'reason_code' => $reasonCode,
            'reason_label' => $reasonOptions[$reasonCode],
            'admin_note' => $adminNote,
            'risk_flags' => $riskFlags->all(),
            'risk_flag_labels' => $riskFlags->map(fn ($flag) => $riskFlagOptions[$flag])->values()->all(),
            'processed_by_admin_id' => isset($decision['processed_by_admin_id']) ? (int) $decision['processed_by_admin_id'] : null,
        ];
    }

    private function enforceDecisionGovernance(array $decision, Collection $refundPlan): array
    {
        $refundSources = $refundPlan
            ->map(fn (array $entry) => (string) data_get($entry, 'payment.source_type'))
            ->filter()
            ->unique()
            ->values();

        $grossAmount = round((float) $refundPlan->sum('total_amount'), 2);
        $riskFlags = collect((array) ($decision['risk_flags'] ?? []));
        $reasonCode = (string) ($decision['reason_code'] ?? '');
        $adminNote = (string) ($decision['admin_note'] ?? '');

        if ($refundSources->contains('card') && !$riskFlags->contains(self::RISK_GATEWAY_REFUND)) {
            throw new Exception('Card or gateway refunds must include the Gateway/card refund risk flag.');
        }

        if ($grossAmount >= self::HIGH_VALUE_REFUND_THRESHOLD && !$riskFlags->contains(self::RISK_HIGH_VALUE)) {
            throw new Exception('Refunds at or above RD$ ' . number_format(self::HIGH_VALUE_REFUND_THRESHOLD, 2) . ' must include the High value refund risk flag.');
        }

        if ($reasonCode === self::REASON_GOODWILL_EXCEPTION && !$riskFlags->contains(self::RISK_MANUAL_EXCEPTION)) {
            throw new Exception('Goodwill exception refunds must include the Manual exception risk flag.');
        }

        if ($reasonCode === self::REASON_DISPUTE_RESOLUTION) {
            if (!$riskFlags->contains(self::RISK_MANUAL_EXCEPTION)) {
                throw new Exception('Dispute resolution refunds must include the Manual exception risk flag.');
            }

            if (!$riskFlags->contains(self::RISK_CUSTOMER_ESCALATION)) {
                throw new Exception('Dispute resolution refunds must include the Customer escalation risk flag.');
            }
        }

        if (in_array($reasonCode, [self::REASON_GOODWILL_EXCEPTION, self::REASON_DISPUTE_RESOLUTION], true)
            && mb_strlen($adminNote) < self::COMPLEX_CASE_NOTE_LENGTH
        ) {
            throw new Exception('Goodwill and dispute refunds require an admin note of at least ' . self::COMPLEX_CASE_NOTE_LENGTH . ' characters.');
        }

        return $decision;
    }

    private function allocateRefundEntry(array $entry, int $allocationGrossCents): array
    {
        /** @var ReservationPayment $payment */
        $payment = $entry['payment'];
        $rowBaseCents = $this->toCents((float) $entry['amount']);
        $rowFeeCents = $this->toCents((float) $entry['fee_amount']);
        $rowGrossCents = $this->toCents((float) $entry['total_amount']);

        if ($allocationGrossCents >= $rowGrossCents) {
            return $entry;
        }

        if ($payment->source_type !== 'card' || $rowFeeCents <= 0) {
            return [
                'payment' => $payment,
                'amount' => $this->fromCents($allocationGrossCents),
                'fee_amount' => 0.0,
                'total_amount' => $this->fromCents($allocationGrossCents),
            ];
        }

        $allocationBaseCents = (int) round(($rowBaseCents * $allocationGrossCents) / max(1, $rowGrossCents));
        $allocationFeeCents = $allocationGrossCents - $allocationBaseCents;

        if ($allocationBaseCents > $rowBaseCents) {
            $allocationBaseCents = $rowBaseCents;
            $allocationFeeCents = $allocationGrossCents - $allocationBaseCents;
        }

        if ($allocationFeeCents > $rowFeeCents) {
            $allocationFeeCents = $rowFeeCents;
            $allocationBaseCents = $allocationGrossCents - $allocationFeeCents;
        }

        return [
            'payment' => $payment,
            'amount' => $this->fromCents($allocationBaseCents),
            'fee_amount' => $this->fromCents($allocationFeeCents),
            'total_amount' => $this->fromCents($allocationGrossCents),
        ];
    }

    private function toCents(float $amount): int
    {
        return (int) round($amount * 100);
    }

    private function fromCents(int $amount): float
    {
        return round($amount / 100, 2);
    }

    private function groupPayments(Collection $payments): Collection
    {
        return $payments
            ->groupBy(function (ReservationPayment $payment) {
                return str_replace('_refund', '', $payment->source_type);
            })
            ->map(function (Collection $rows) {
                return [
                    'amount' => round((float) abs($rows->sum('amount')), 2),
                    'fee_amount' => round((float) abs($rows->sum('fee_amount')), 2),
                    'total_amount' => round((float) abs($rows->sum('total_amount')), 2),
                    'count' => $rows->count(),
                ];
            });
    }
}
