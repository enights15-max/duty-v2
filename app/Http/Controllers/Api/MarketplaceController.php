<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Event\Booking;
use App\Models\Customer;
use App\Models\TicketTransfer;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\Validator;

use App\Services\NotificationService;
use App\Services\EventWaitlistService;
use App\Services\FeeEngine;
use App\Services\PlatformRevenueService;
use App\Services\TicketJourneyService;
use App\Services\Payments\PaymentGatewayRegistry;

class MarketplaceController extends Controller
{
    protected $notificationService;
    protected $eventWaitlistService;
    protected $ticketJourneyService;
    protected $feeEngine;
    protected $platformRevenueService;

    public function __construct(
        NotificationService $notificationService,
        EventWaitlistService $eventWaitlistService,
        TicketJourneyService $ticketJourneyService,
        FeeEngine $feeEngine,
        PlatformRevenueService $platformRevenueService
    )
    {
        $this->notificationService = $notificationService;
        $this->eventWaitlistService = $eventWaitlistService;
        $this->ticketJourneyService = $ticketJourneyService;
        $this->feeEngine = $feeEngine;
        $this->platformRevenueService = $platformRevenueService;
    }

    private function resolveRecipientFromRequest(Request $request): ?Customer
    {
        $recipientId = $request->input('recipient_id');
        if ($recipientId !== null && $recipientId !== '') {
            return Customer::find($recipientId);
        }

        $recipientStr = trim((string) $request->input('recipient', ''));
        if ($recipientStr === '') {
            return null;
        }

        return Customer::where('email', $recipientStr)
            ->orWhere('username', $recipientStr)
            ->first();
    }

    private function validateTransferableBooking(Booking $booking): ?string
    {
        if (!$booking->is_transferable) {
            return 'This ticket is not transferable.';
        }

        if ($booking->is_listed) {
            return 'Please remove the ticket from the Blackmarket before transferring.';
        }

        $hasPendingTransfer = TicketTransfer::where('booking_id', $booking->id)
            ->where('status', 'pending')
            ->lockForUpdate()
            ->exists();

        if ($booking->transfer_status === 'transfer_pending' || $hasPendingTransfer) {
            return 'This ticket already has a pending transfer request.';
        }

        $event = \App\Models\Event::find($booking->event_id);
        if ($event && $event->end_date_time && now()->greaterThan($event->end_date_time)) {
            return 'Cannot transfer tickets for past events.';
        }

        return null;
    }

    private function validateBookingResaleEligibility(Booking $booking): ?string
    {
        if (!$booking->is_transferable) {
            return 'This ticket is not transferable.';
        }

        if (Schema::hasColumn($booking->getTable(), 'is_resellable') && !$booking->is_resellable) {
            return match ((string) ($booking->resale_restriction_reason ?? '')) {
                'promotional_restriction' => 'This promotional ticket cannot be resold on the Blackmarket.',
                default => 'This ticket cannot be resold on the Blackmarket.',
            };
        }

        return null;
    }

    private function buildTransferQrToken(Booking $booking, Customer $owner): string
    {
        return Crypt::encryptString(json_encode([
            'booking_id' => (int) $booking->id,
            'owner_customer_id' => (int) $owner->id,
            'issued_at' => now()->toISOString(),
        ]));
    }

    private function decodeTransferQrToken(string $token): ?array
    {
        try {
            $decoded = json_decode(Crypt::decryptString($token), true);
            return is_array($decoded) ? $decoded : null;
        } catch (\Throwable $e) {
            return null;
        }
    }

    private function resolveAcceptedOwner(TicketTransfer $transfer): ?Customer
    {
        $newOwnerId = $transfer->flow === 'receiver_request'
            ? $transfer->from_customer_id
            : $transfer->to_customer_id;

        return Customer::find($newOwnerId);
    }

    private function resolveEventTitleFromBooking(?Booking $booking): string
    {
        if (!$booking) {
            return 'Unknown Event';
        }

        $eventModel = $booking->relationLoaded('evnt') ? $booking->getRelation('evnt') : $booking->evnt;
        if ($eventModel && !empty($eventModel->title)) {
            return $eventModel->title;
        }

        try {
            $content = $booking->relationLoaded('event') ? $booking->getRelation('event') : $booking->event;
            if ($content && !empty($content->title)) {
                return $content->title;
            }
        } catch (\Throwable $e) {
            // Tests and some lightweight environments do not materialize event_contents.
        }

        return 'Unknown Event';
    }

    private function paymentMethodBelongsToCustomer(Customer $customer, ?string $paymentMethodId): bool
    {
        if (empty($paymentMethodId)) {
            return false;
        }

        return \App\Models\PaymentMethod::forActor($customer)
            ->where('stripe_payment_method_id', $paymentMethodId)
            ->exists();
    }

    private function resolveMarketplaceFundingPreview(
        Customer $buyer,
        Booking $booking,
        bool $applyWalletBalance,
        ?string $stripePaymentMethodId = null
    ): array {
        $walletService = app(\App\Services\WalletService::class);
        $fundingAllocator = app(\App\Services\CheckoutFundingAllocatorService::class);

        $price = round((float) $booking->listing_price, 2);
        $walletBalance = (float) ($walletService->getOrCreateWallet($buyer)->balance ?? 0);
        $requestedGateway = $this->resolveGatewayDescriptor($applyWalletBalance ? 'mixed' : 'stripe');
        $fundingPlan = $fundingAllocator->allocate($price, [
            'gateway' => (string) ($requestedGateway['gateway'] ?? ($applyWalletBalance ? 'mixed' : 'stripe')),
            'wallet_balance' => $walletBalance,
            'bonus_balance' => 0,
            'apply_wallet_balance' => $applyWalletBalance,
            'apply_bonus_balance' => false,
        ]);

        $processingQuote = [
            'fee_amount' => 0.0,
            'net_amount' => round((float) ($fundingPlan['card_amount'] ?? 0), 2),
            'total_charge_amount' => round((float) ($fundingPlan['card_amount'] ?? 0), 2),
        ];

        if (((float) ($fundingPlan['card_amount'] ?? 0)) > 0) {
            $processingQuote = $this->feeEngine->quoteBuyerChargeForNet(
                FeeEngine::OP_MARKETPLACE_CARD_PROCESSING,
                (float) $fundingPlan['card_amount'],
                ['currency' => 'DOP']
            );
        }

        $fundingPlan['processing_fee'] = round((float) ($processingQuote['fee_amount'] ?? 0), 2);
        $fundingPlan['card_processing_fee'] = round((float) ($processingQuote['fee_amount'] ?? 0), 2);
        $fundingPlan['card_total_charge'] = round((float) ($processingQuote['total_charge_amount'] ?? ($fundingPlan['card_amount'] ?? 0)), 2);
        $fundingPlan['total_to_charge'] = round(
            (float) ($fundingPlan['wallet_amount'] ?? 0) + (float) ($fundingPlan['card_total_charge'] ?? 0),
            2
        );
        $fundingPlan['available_wallet_balance'] = round($walletBalance, 2);
        $fundingPlan['has_selected_card'] = !empty($stripePaymentMethodId);
        $fundingPlan['can_purchase'] = !((bool) ($fundingPlan['requires_card'] ?? false)) || !empty($stripePaymentMethodId);

        $effectiveGateway = $this->resolveGatewayDescriptor((string) ($fundingPlan['payment_method'] ?? ($requestedGateway['gateway'] ?? 'stripe')));
        $fundingPlan['requested_gateway'] = $requestedGateway['gateway'] ?? null;
        $fundingPlan['gateway'] = $effectiveGateway['gateway'] ?? null;
        $fundingPlan['gateway_family'] = $effectiveGateway['gateway_family'] ?? null;
        $fundingPlan['verification_strategy'] = $effectiveGateway['verification_strategy'] ?? null;

        return [$fundingPlan, $processingQuote];
    }

    private function resolveVisibleMarketplaceBooking(int|string $id, bool $lockForUpdate = false): ?Booking
    {
        $query = Booking::query()
            ->visibleMarketplaceListings()
            ->whereKey($id);

        if ($lockForUpdate) {
            $query->lockForUpdate();
        }

        return $query->first();
    }

    /**
     * @return array{supported:bool,gateway:string,gateway_family:?string,verification_strategy:?string}
     */
    private function resolveGatewayDescriptor(string $gateway): array
    {
        return app(\App\Services\EventPaymentVerificationService::class)->describeGateway($gateway);
    }

    /**
     * @return array<string, mixed>
     */
    private function buildMarketplaceGatewayMetadata(array $fundingPlan, ?string $sourceGateway = null): array
    {
        $metadata = [
            'requested_gateway' => $fundingPlan['requested_gateway'] ?? null,
            'gateway' => $fundingPlan['gateway'] ?? null,
            'gateway_family' => $fundingPlan['gateway_family'] ?? null,
            'verification_strategy' => $fundingPlan['verification_strategy'] ?? null,
            'wallet_amount' => isset($fundingPlan['wallet_amount']) ? round((float) $fundingPlan['wallet_amount'], 2) : null,
            'card_amount' => isset($fundingPlan['card_amount']) ? round((float) $fundingPlan['card_amount'], 2) : null,
            'card_total_charge' => isset($fundingPlan['card_total_charge']) ? round((float) $fundingPlan['card_total_charge'], 2) : null,
        ];

        if ($sourceGateway !== null) {
            $sourceDescriptor = $this->resolveGatewayDescriptor($sourceGateway);
            $metadata['source_gateway'] = $sourceDescriptor['gateway'] ?? null;
            $metadata['source_gateway_family'] = $sourceDescriptor['gateway_family'] ?? null;
            $metadata['source_verification_strategy'] = $sourceDescriptor['verification_strategy'] ?? null;
        }

        return array_filter($metadata, static fn ($value) => $value !== null);
    }

    private function serializeTransfer(TicketTransfer $transfer, Customer $viewer): array
    {
        $booking = $transfer->booking;
        $eventTitle = $this->resolveEventTitleFromBooking($booking);
        $eventDate = $booking?->event_date ?? null;
        $eventThumbnail = optional($booking?->evnt)->thumbnail ?? null;
        $sender = $transfer->sender;
        $receiver = $transfer->receiver;
        $flow = $transfer->flow ?? 'owner_offer';
        $isIncoming = (int) $transfer->to_customer_id === (int) $viewer->id;
        $isActionOwner = $transfer->status === 'pending' && $isIncoming;
        $senderDisplay = $sender->fname ?? $sender->username ?? 'Someone';
        $receiverDisplay = $receiver->fname ?? $receiver->username ?? 'Someone';

        if ($isIncoming) {
            $messageTitle = $flow === 'receiver_request'
                ? 'Ticket request'
                : 'Incoming transfer';

            $messageBody = $flow === 'receiver_request'
                ? ($senderDisplay . ' wants your ticket for ' . $eventTitle . '.')
                : ($senderDisplay . ' wants to send you a ticket for ' . $eventTitle . '.');
        } else {
            $messageTitle = $flow === 'receiver_request'
                ? 'Request sent'
                : 'Transfer pending';

            if ($transfer->status === 'accepted') {
                $messageBody = $flow === 'receiver_request'
                    ? 'Your request for ' . $eventTitle . ' was approved.'
                    : $receiverDisplay . ' accepted your ticket for ' . $eventTitle . '.';
            } elseif ($transfer->status === 'rejected') {
                $messageBody = $flow === 'receiver_request'
                    ? 'Your request for ' . $eventTitle . ' was declined.'
                    : $receiverDisplay . ' declined your ticket for ' . $eventTitle . '.';
            } elseif ($transfer->status === 'cancelled') {
                $messageBody = $flow === 'receiver_request'
                    ? 'You cancelled your request for ' . $eventTitle . '.'
                    : 'This transfer for ' . $eventTitle . ' was cancelled.';
            } else {
                $messageBody = $flow === 'receiver_request'
                    ? 'Waiting for the owner to approve your request for ' . $eventTitle . '.'
                    : 'Waiting for ' . $receiverDisplay . ' to accept your ticket for ' . $eventTitle . '.';
            }
        }

        return [
            'id' => $transfer->id,
            'booking_id' => $transfer->booking_id,
            'flow' => $flow,
            'status' => $transfer->status,
            'direction' => $isIncoming ? 'incoming' : 'outgoing',
            'requires_action' => $transfer->status === 'pending' && $isActionOwner,
            'can_accept' => $transfer->status === 'pending' && $isActionOwner,
            'can_reject' => $transfer->status === 'pending' && $isActionOwner,
            'can_cancel' => $transfer->status === 'pending' && (int) $transfer->from_customer_id === (int) $viewer->id,
            'message_title' => $messageTitle,
            'message_body' => $messageBody,
            'event' => [
                'title' => $eventTitle,
                'date' => $eventDate,
                'thumbnail' => $eventThumbnail,
            ],
            'sender' => [
                'id' => $sender->id ?? null,
                'name' => trim(($sender->fname ?? '') . ' ' . ($sender->lname ?? '')),
                'username' => $sender->username ?? null,
                'photo' => $sender->photo ?? null,
            ],
            'receiver' => [
                'id' => $receiver->id ?? null,
                'name' => trim(($receiver->fname ?? '') . ' ' . ($receiver->lname ?? '')),
                'username' => $receiver->username ?? null,
                'photo' => $receiver->photo ?? null,
            ],
            'created_at' => optional($transfer->created_at)->toISOString(),
            'notes' => $transfer->notes,
        ];
    }

    /**
     * Transfer a ticket to another user.
     */
    public function transfer(Request $request, $id)
    {
        $customer = Auth::guard('sanctum')->user();
        $booking = Booking::where('id', $id)->where('customer_id', $customer->id)->first();

        if (!$booking) {
            return response()->json(['success' => false, 'message' => 'Ticket not found or not owned by you.'], 404);
        }

        if (!$booking->is_transferable) {
            return response()->json(['success' => false, 'message' => 'This ticket is not transferable.'], 403);
        }

        $validator = Validator::make($request->all(), [
            'recipient' => 'required', // Email or username
        ]);

        if ($validator->fails()) {
            return response()->json(['success' => false, 'errors' => $validator->errors()], 422);
        }

        // Find recipient
        $recipientStr = $request->recipient;
        $recipient = Customer::where('email', $recipientStr)
            ->orWhere('username', $recipientStr)
            ->first();

        if (!$recipient) {
            return response()->json(['success' => false, 'message' => 'Recipient user not found.'], 404);
        }

        if ($recipient->id === $customer->id) {
            return response()->json(['success' => false, 'message' => 'You cannot transfer a ticket to yourself.'], 400);
        }

        try {
            $result = DB::transaction(function () use ($booking, $customer, $recipient) {
                $lockedBooking = Booking::query()
                    ->whereKey($booking->id)
                    ->lockForUpdate()
                    ->first();

                if (!$lockedBooking || (int) $lockedBooking->customer_id !== (int) $customer->id) {
                    return [
                        'response' => response()->json([
                            'success' => false,
                            'message' => 'Ticket not found or not owned by you.',
                        ], 404),
                    ];
                }

                if (!$lockedBooking->is_transferable) {
                    return [
                        'response' => response()->json(['success' => false, 'message' => 'This ticket is not transferable.'], 403),
                    ];
                }

                $hasPendingTransfer = TicketTransfer::where('booking_id', $lockedBooking->id)
                    ->where('status', 'pending')
                    ->lockForUpdate()
                    ->exists();

                if ($lockedBooking->transfer_status === 'transfer_pending' || $hasPendingTransfer) {
                    return [
                        'response' => response()->json(['success' => false, 'message' => 'This ticket already has a pending transfer request.'], 409),
                    ];
                }

                $event = \App\Models\Event::find($lockedBooking->event_id);
                if ($event && $event->end_date_time && now()->greaterThan($event->end_date_time)) {
                    return [
                        'response' => response()->json(['success' => false, 'message' => 'Cannot transfer tickets for past events.'], 403),
                    ];
                }

                $transfer = TicketTransfer::create([
                    'booking_id' => $lockedBooking->id,
                    'from_customer_id' => $customer->id,
                    'to_customer_id' => $recipient->id,
                    'notes' => 'Direct transfer via Mobile App',
                    'status' => 'accepted',
                    'flow' => 'direct_owner_transfer',
                ]);

                $lockedBooking->customer_id = $recipient->id;
                $lockedBooking->email = $recipient->email;
                $lockedBooking->phone = $recipient->phone;
                $lockedBooking->transfer_status = null;
                $lockedBooking->is_listed = false;
                $lockedBooking->listing_price = 0;
                $lockedBooking->save();

                $this->ticketJourneyService->record($lockedBooking->fresh(), 'gift_transfer_completed', [
                    'actor_customer_id' => (int) $customer->id,
                    'target_customer_id' => (int) $recipient->id,
                    'transfer_id' => (int) $transfer->id,
                    'metadata' => [
                        'flow' => 'direct_owner_transfer',
                        'notes' => 'Direct transfer via Mobile App',
                    ],
                ]);

                return [
                    'transfer' => $transfer,
                    'booking' => $lockedBooking->fresh(),
                ];
            });

            if (isset($result['response'])) {
                return $result['response'];
            }

            $transfer = $result['transfer'];
            $booking = $result['booking'];

            try {
                $eventTitle = optional($booking->evnt)->title ?? 'an event';
                $this->notificationService->notifyUser(
                    $recipient,
                    'Ticket Transferred',
                    ($customer->fname ?? $customer->username) . ' sent you a ticket for ' . $eventTitle . '.',
                    [
                        'type' => 'ticket_transferred',
                        'transfer_id' => $transfer->id,
                        'flow' => 'direct_owner_transfer',
                        'booking_id' => $booking->id,
                        'event_id' => $booking->event_id,
                    ]
                );
            } catch (\Throwable $notifyError) {
                report($notifyError);
            }
            return response()->json([
                'success' => true,
                'message' => 'Ticket transferred successfully to ' . ($recipient->fname ?? $recipient->username) . '.',
                'data' => [
                    'transfer_id' => $transfer->id,
                    'status' => 'accepted',
                ]
            ]);
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => 'Transfer request failed: ' . $e->getMessage()], 500);
        }
    }

    public function transferQr($id)
    {
        $customer = Auth::guard('sanctum')->user();

        $booking = Booking::where('id', $id)
            ->where('customer_id', $customer->id)
            ->lockForUpdate()
            ->first();

        if (!$booking) {
            return response()->json(['success' => false, 'message' => 'Ticket not found or not owned by you.'], 404);
        }

        $transferError = $this->validateTransferableBooking($booking);
        if ($transferError !== null) {
            $status = str_contains($transferError, 'past events') || str_contains($transferError, 'not transferable')
                ? 403
                : 409;

            return response()->json(['success' => false, 'message' => $transferError], $status);
        }

        $token = $this->buildTransferQrToken($booking, $customer);

        return response()->json([
            'success' => true,
            'data' => [
                'booking_id' => $booking->id,
                'event_title' => $this->resolveEventTitleFromBooking($booking),
                'qr_value' => 'duty://transfer-ticket?token=' . urlencode($token),
                'transfer_token' => $token,
                'expires_at' => now()->addDay()->toISOString(),
            ],
        ]);
    }

    public function requestFromTicketScan(Request $request)
    {
        $customer = Auth::guard('sanctum')->user();

        $validator = Validator::make($request->all(), [
            'transfer_token' => 'required|string',
        ]);

        if ($validator->fails()) {
            return response()->json(['success' => false, 'errors' => $validator->errors()], 422);
        }

        $payload = $this->decodeTransferQrToken((string) $request->input('transfer_token'));
        if (!$payload) {
            return response()->json(['success' => false, 'message' => 'This transfer QR is invalid or has expired.'], 422);
        }

        $bookingId = (int) ($payload['booking_id'] ?? 0);
        $ownerId = (int) ($payload['owner_customer_id'] ?? 0);
        $issuedAt = null;
        if (isset($payload['issued_at'])) {
            try {
                $issuedAt = \Illuminate\Support\Carbon::parse($payload['issued_at']);
            } catch (\Throwable $e) {
                $issuedAt = null;
            }
        }

        if ($bookingId <= 0 || $ownerId <= 0 || !$issuedAt || $issuedAt->lt(now()->subDay())) {
            return response()->json(['success' => false, 'message' => 'This transfer QR is invalid or has expired.'], 422);
        }

        if ($customer->id === $ownerId) {
            return response()->json(['success' => false, 'message' => 'You cannot request your own ticket.'], 400);
        }

        $owner = Customer::find($ownerId);
        if (!$owner) {
            return response()->json(['success' => false, 'message' => 'The ticket owner could not be found.'], 404);
        }

        try {
            $result = DB::transaction(function () use ($bookingId, $ownerId, $customer) {
                $booking = Booking::where('id', $bookingId)
                    ->where('customer_id', $ownerId)
                    ->lockForUpdate()
                    ->first();

                if (!$booking) {
                    return [
                        'response' => response()->json(['success' => false, 'message' => 'This ticket is no longer available for transfer.'], 404),
                    ];
                }

                $transferError = $this->validateTransferableBooking($booking);
                if ($transferError !== null) {
                    $status = str_contains($transferError, 'past events') || str_contains($transferError, 'not transferable')
                        ? 403
                        : 409;

                    return [
                        'response' => response()->json(['success' => false, 'message' => $transferError], $status),
                    ];
                }

                $transfer = TicketTransfer::create([
                    'booking_id' => $booking->id,
                    'from_customer_id' => $customer->id,
                    'to_customer_id' => $ownerId,
                    'notes' => 'Transfer request via Ticket QR',
                    'status' => 'pending',
                    'flow' => 'receiver_request',
                ]);

                $booking->transfer_status = 'transfer_pending';
                $booking->save();

                $this->ticketJourneyService->record($booking->fresh(), 'gift_transfer_pending', [
                    'actor_customer_id' => (int) $customer->id,
                    'target_customer_id' => (int) $ownerId,
                    'transfer_id' => (int) $transfer->id,
                    'metadata' => [
                        'flow' => 'receiver_request',
                        'notes' => 'Transfer request via Ticket QR',
                    ],
                ]);

                return [
                    'transfer' => $transfer,
                    'booking' => $booking->fresh(),
                ];
            });

            if (isset($result['response'])) {
                return $result['response'];
            }

            $transfer = $result['transfer'];
            $booking = $result['booking'];

            try {
                $eventTitle = optional($booking->evnt)->title ?? 'an event';
                $this->notificationService->notifyUser(
                    $owner,
                    'Ticket Request',
                    ($customer->fname ?? $customer->username) . ' wants your ticket for ' . $eventTitle . '. Open Duty to approve or reject.',
                    [
                        'type' => 'transfer_request',
                        'transfer_id' => $transfer->id,
                        'flow' => 'receiver_request',
                        'booking_id' => $booking->id,
                        'event_id' => $booking->event_id,
                    ]
                );
            } catch (\Throwable $notifyError) {
                report($notifyError);
            }

            return response()->json([
                'success' => true,
                'message' => 'Ticket transferred successfully to ' . ($recipient->fname ?? $recipient->username),
            ]);
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => 'Transfer request failed: ' . $e->getMessage()], 500);
        }
    }

    public function transferDetails($transferId)
    {
        $customer = Auth::guard('sanctum')->user();

        $transfer = TicketTransfer::with(['sender', 'receiver', 'booking', 'booking.evnt'])
            ->where('id', $transferId)
            ->where(function ($query) use ($customer) {
                $query->where('from_customer_id', $customer->id)
                    ->orWhere('to_customer_id', $customer->id);
            })
            ->first();

        if (!$transfer) {
            return response()->json(['success' => false, 'message' => 'Transfer request not found.'], 404);
        }

        return response()->json([
            'success' => true,
            'data' => $this->serializeTransfer($transfer, $customer),
        ]);
    }

    /**
     * List pending incoming transfer requests for the current user.
     */
    public function pendingTransfers()
    {
        $customer = Auth::guard('sanctum')->user();

        $transfers = TicketTransfer::where('to_customer_id', $customer->id)
            ->where('status', 'pending')
            ->with(['sender', 'receiver', 'booking', 'booking.evnt'])
            ->orderByDesc('id')
            ->get()
            ->map(fn ($transfer) => $this->serializeTransfer($transfer, $customer))
            ->values();

        return response()->json([
            'success' => true,
            'data' => $transfers,
        ]);
    }

    /**
     * List outgoing transfer requests started by the current user.
     */
    public function outboxTransfers()
    {
        $customer = Auth::guard('sanctum')->user();

        $transfers = TicketTransfer::where('from_customer_id', $customer->id)
            ->where(function ($query) {
                $query->whereNull('notes')
                    ->orWhere('notes', '!=', 'Marketplace Purchase');
            })
            ->with(['sender', 'receiver', 'booking', 'booking.evnt'])
            ->orderByDesc('id')
            ->get()
            ->map(fn ($transfer) => $this->serializeTransfer($transfer, $customer))
            ->values();

        return response()->json([
            'success' => true,
            'data' => $transfers,
        ]);
    }

    /**
     * Accept a pending transfer request.
     */
    public function acceptTransfer($transferId)
    {
        $customer = Auth::guard('sanctum')->user();

        try {
            $result = DB::transaction(function () use ($transferId, $customer) {
                $transfer = TicketTransfer::where('id', $transferId)
                    ->where('to_customer_id', $customer->id)
                    ->where('status', 'pending')
                    ->lockForUpdate()
                    ->first();

                if (!$transfer) {
                    return [
                        'response' => response()->json(['success' => false, 'message' => 'Transfer request not found or already processed.'], 404),
                    ];
                }

                $booking = Booking::where('id', $transfer->booking_id)->lockForUpdate()->first();

                if (!$booking) {
                    return [
                        'response' => response()->json(['success' => false, 'message' => 'Associated ticket no longer exists.'], 404),
                    ];
                }

                $newOwner = $this->resolveAcceptedOwner($transfer);
                if (!$newOwner) {
                    return [
                        'response' => response()->json(['success' => false, 'message' => 'The transfer recipient could not be resolved.'], 404),
                    ];
                }

                // Transfer ownership
                $booking->update([
                    'customer_id' => $newOwner->id,
                    'fname' => $newOwner->fname,
                    'lname' => $newOwner->lname,
                    'email' => $newOwner->email,
                    'phone' => $newOwner->phone,
                    'is_listed' => false,
                    'transfer_status' => null,
                ]);

                $transfer->update(['status' => 'accepted']);

                $this->ticketJourneyService->record($booking->fresh(), 'gift_transfer_accepted', [
                    'actor_customer_id' => (int) $transfer->from_customer_id,
                    'target_customer_id' => (int) $newOwner->id,
                    'transfer_id' => (int) $transfer->id,
                    'metadata' => [
                        'flow' => $transfer->flow ?? 'owner_offer',
                    ],
                ]);

                return [
                    'transfer' => $transfer->fresh(),
                    'booking' => $booking->fresh(),
                ];
            });

            if (isset($result['response'])) {
                return $result['response'];
            }

            $transfer = $result['transfer'];
            $booking = $result['booking'];

            try {
                $sender = Customer::find($transfer->from_customer_id);
                $eventTitle = optional($booking->evnt)->title ?? 'an event';

                if ($sender) {
                    $this->notificationService->notifyUser(
                        $sender,
                        'Transfer Accepted',
                        ($customer->fname ?? $customer->username) . ' accepted your ticket transfer for ' . $eventTitle . '.',
                        [
                            'type' => 'transfer_accepted',
                            'transfer_id' => $transfer->id,
                            'flow' => $transfer->flow ?? 'owner_offer',
                            'booking_id' => $booking->id,
                            'event_id' => $booking->event_id,
                        ]
                    );
                }
            } catch (\Throwable $notifyError) {
                report($notifyError);
            }

            $message = ($transfer->flow ?? 'owner_offer') === 'receiver_request'
                ? 'Transfer approved. The ticket has been sent.'
                : 'Transfer accepted! The ticket is now yours.';

            return response()->json([
                'success' => true,
                'message' => $message,
            ]);
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => 'Accept failed: ' . $e->getMessage()], 500);
        }
    }

    /**
     * Reject a pending transfer request.
     */
    public function rejectTransfer($transferId)
    {
        $customer = Auth::guard('sanctum')->user();

        try {
            $result = DB::transaction(function () use ($transferId, $customer) {
                $transfer = TicketTransfer::where('id', $transferId)
                    ->where('to_customer_id', $customer->id)
                    ->where('status', 'pending')
                    ->lockForUpdate()
                    ->first();

                if (!$transfer) {
                    return [
                        'response' => response()->json(['success' => false, 'message' => 'Transfer request not found or already processed.'], 404),
                    ];
                }

                $booking = Booking::where('id', $transfer->booking_id)->lockForUpdate()->first();
                if ($booking) {
                    $booking->update(['transfer_status' => null]);
                    $this->ticketJourneyService->record($booking->fresh(), 'gift_transfer_rejected', [
                        'actor_customer_id' => (int) $transfer->from_customer_id,
                        'target_customer_id' => (int) $customer->id,
                        'transfer_id' => (int) $transfer->id,
                        'metadata' => [
                            'flow' => $transfer->flow ?? 'owner_offer',
                        ],
                    ]);
                }

                $transfer->update(['status' => 'rejected']);

                return [
                    'transfer' => $transfer->fresh(),
                    'booking' => $booking ? $booking->fresh() : null,
                ];
            });

            if (isset($result['response'])) {
                return $result['response'];
            }

            $transfer = $result['transfer'];
            $booking = $result['booking'];

            try {
                $sender = Customer::find($transfer->from_customer_id);
                $eventTitle = optional(optional($booking)->evnt)->title ?? 'an event';

                if ($sender) {
                    $this->notificationService->notifyUser(
                        $sender,
                        'Transfer Rejected',
                        ($customer->fname ?? $customer->username) . ' rejected your ticket transfer for ' . $eventTitle . '.',
                        [
                            'type' => 'transfer_rejected',
                            'transfer_id' => $transfer->id,
                            'flow' => $transfer->flow ?? 'owner_offer',
                            'booking_id' => optional($booking)->id,
                            'event_id' => optional($booking)->event_id,
                        ]
                    );
                }
            } catch (\Throwable $notifyError) {
                report($notifyError);
            }

            return response()->json([
                'success' => true,
                'message' => 'Transfer request rejected.',
            ]);
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => 'Reject failed: ' . $e->getMessage()], 500);
        }
    }

    /**
     * Cancel a pending transfer request (by the sender).
     */
    public function cancelTransfer($transferId)
    {
        $customer = Auth::guard('sanctum')->user();

        try {
            $result = DB::transaction(function () use ($transferId, $customer) {
                $transfer = TicketTransfer::where('id', $transferId)
                    ->where('from_customer_id', $customer->id)
                    ->where('status', 'pending')
                    ->lockForUpdate()
                    ->first();

                if (!$transfer) {
                    return [
                        'response' => response()->json(['success' => false, 'message' => 'Transfer request not found or already processed.'], 404),
                    ];
                }

                $booking = Booking::where('id', $transfer->booking_id)->lockForUpdate()->first();
                if ($booking) {
                    $booking->update(['transfer_status' => null]);
                    $this->ticketJourneyService->record($booking->fresh(), 'gift_transfer_cancelled', [
                        'actor_customer_id' => (int) $customer->id,
                        'target_customer_id' => (int) $transfer->to_customer_id,
                        'transfer_id' => (int) $transfer->id,
                        'metadata' => [
                            'flow' => $transfer->flow ?? 'owner_offer',
                        ],
                    ]);
                }

                $transfer->update(['status' => 'cancelled']);

                return [
                    'transfer' => $transfer->fresh(),
                ];
            });

            if (isset($result['response'])) {
                return $result['response'];
            }

            $transfer = $result['transfer'];

            try {
                $receiver = Customer::find($transfer->to_customer_id);
                if ($receiver) {
                    $this->notificationService->notifyUser(
                        $receiver,
                        'Transfer Cancelled',
                        ($customer->fname ?? $customer->username) . ' cancelled a pending ticket transfer.',
                        [
                            'type' => 'transfer_cancelled',
                            'transfer_id' => $transfer->id,
                            'flow' => $transfer->flow ?? 'owner_offer',
                            'booking_id' => $transfer->booking_id,
                        ]
                    );
                }
            } catch (\Throwable $notifyError) {
                report($notifyError);
            }

            return response()->json([
                'success' => true,
                'message' => 'Transfer request cancelled.',
            ]);
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => 'Cancel failed: ' . $e->getMessage()], 500);
        }
    }

    /**
     * List a ticket for sale on the marketplace.
     */
    public function listForSale(Request $request, $id)
    {
        $customer = Auth::guard('sanctum')->user();
        $booking = Booking::where('id', $id)->where('customer_id', $customer->id)->first();

        if (!$booking) {
            return response()->json(['success' => false, 'message' => 'Ticket not found or not owned by you.'], 404);
        }

        // Check if the event has already concluded
        $event = \App\Models\Event::find($booking->event_id);
        if ($event && $event->end_date_time && now()->greaterThan($event->end_date_time)) {
            return response()->json(['success' => false, 'message' => 'Cannot list tickets for past events.'], 403);
        }

        $resaleError = $this->validateBookingResaleEligibility($booking);
        if ($resaleError !== null) {
            return response()->json(['success' => false, 'message' => $resaleError], 403);
        }

        $basic = \App\Models\BasicSettings\Basic::select('marketplace_max_price_rule')->first();

        $maxPriceRule = '';
        if ($basic && $basic->marketplace_max_price_rule == 1) {
            $maxPriceRule = '|max:' . $booking->price;
        }

        $validator = Validator::make($request->all(), [
            'price' => 'required|numeric|min:0',
            'is_listed' => 'required|boolean',
        ]);

        if ($validator->fails()) {
            return response()->json(['success' => false, 'errors' => $validator->errors()], 422);
        }

        $booking->update([
            'is_listed' => $request->is_listed,
            'listing_price' => $request->boolean('is_listed') ? $request->price : 0,
        ]);

        $status = $request->is_listed ? 'listed' : 'unlisted';

        $this->ticketJourneyService->record($booking->fresh(), $request->boolean('is_listed') ? 'listed' : 'unlisted', [
            'actor_customer_id' => (int) $customer->id,
            'target_customer_id' => (int) $customer->id,
            'price' => $request->boolean('is_listed') ? (float) $request->price : null,
            'metadata' => [
                'source' => 'blackmarket',
            ],
        ]);

        if ($request->boolean('is_listed') && $event) {
            $this->eventWaitlistService->notifyMarketplaceAvailability($event);
        }

        return response()->json([
            'success' => true,
            'message' => "Ticket successfully {$status}.",
            'data' => [
                'is_listed' => $booking->is_listed,
                'listing_price' => $booking->listing_price,
            ]
        ]);
    }

    /**
     * List all tickets currently for sale on the marketplace.
     */
    public function index(Request $request)
    {
        $search = $request->input('search');
        $categoryId = $request->input('category_id');
        $minPrice = $request->input('min_price');
        $maxPrice = $request->input('max_price');

        // Clean up stale resale listings so the app never keeps offering tickets
        // whose seller or event no longer exists.
        Booking::where('is_listed', true)
            ->where(function ($query) {
                $query->whereDoesntHave('customerInfo')
                    ->orWhereDoesntHave('evnt');
            })
            ->update([
                'is_listed' => false,
                'listing_price' => 0,
            ]);

        $bookings = Booking::query()
            ->visibleMarketplaceListings(Auth::guard('sanctum')->id())
            ->when($search, function ($query, $search) {
                return $query->whereHas('event', function ($q) use ($search) {
                    $q->where('title', 'like', '%' . $search . '%');
                });
            })
            ->when($categoryId, function ($query, $categoryId) {
                return $query->whereHas('event', function ($q) use ($categoryId) {
                    $q->where('event_category_id', $categoryId);
                });
            })
            ->when($minPrice !== null, function ($query) use ($minPrice) {
                return $query->where('listing_price', '>=', $minPrice);
            })
            ->when($maxPrice !== null, function ($query) use ($maxPrice) {
                return $query->where('listing_price', '<=', $maxPrice);
            })
            ->with(['customerInfo', 'evnt', 'event'])
            ->get()
            ->map(function ($booking) {
                return [
                    'id' => $booking->id,
                    'event' => [
                        'id' => $booking->evnt->id ?? null,
                        'title' => $booking->event->title ?? 'Unknown Event',
                        'thumbnail' => $booking->evnt->thumbnail ?? null,
                        'date' => $booking->event_date,
                    ],
                    'seller' => [
                        'name' => ($booking->customerInfo->fname ?? '') . ' ' . ($booking->customerInfo->lname ?? ''),
                        'username' => $booking->customerInfo->username ?? 'Unknown',
                        'photo' => $booking->customerInfo->photo ?? null,
                    ],
                    'price' => $booking->listing_price,
                    'original_price' => $booking->price,
                    'quantity' => $booking->quantity,
                ];
            });

        return response()->json([
            'success' => true,
            'data' => $bookings
        ]);
    }

    /**
     * Preview a ticket purchase from the marketplace.
     */
    public function purchasePreview(Request $request, $id)
    {
        $buyer = Auth::guard('sanctum')->user();

        try {
            $booking = $this->resolveVisibleMarketplaceBooking($id);
            if (!$booking) {
                return response()->json([
                    'success' => false,
                    'message' => 'Ticket no longer available.',
                ], 404);
            }

            if ((int) $booking->customer_id === (int) $buyer->id) {
                return response()->json([
                    'success' => false,
                    'message' => 'You cannot buy your own ticket.',
                ], 400);
            }

            $seller = Customer::find($booking->customer_id);

            $price = (float) $booking->listing_price;
            $applyWalletBalance = filter_var($request->input('apply_wallet_balance', true), FILTER_VALIDATE_BOOLEAN);
            $stripePaymentMethodId = $request->input('stripe_payment_method_id');
            if (!empty($stripePaymentMethodId) && !$this->paymentMethodBelongsToCustomer($buyer, (string) $stripePaymentMethodId)) {
                return response()->json([
                    'success' => false,
                    'message' => 'The selected card is not available for this account.',
                ], 422);
            }

            [$fundingPlan, $processingQuote] = $this->resolveMarketplaceFundingPreview(
                $buyer,
                $booking,
                $applyWalletBalance,
                $stripePaymentMethodId
            );

            $feeBreakdown = $this->feeEngine->calculate(FeeEngine::OP_MARKETPLACE_RESALE, $price, [
                'fee_base_amount' => $price,
                'total_charge_amount' => $price,
                'currency' => 'DOP',
            ]);
            $sellerPayout = (float) ($feeBreakdown['net_amount'] ?? $price);
            $sellerFee = (float) ($feeBreakdown['fee_amount'] ?? 0);

            return response()->json([
                'success' => true,
                'data' => [
                    'booking_id' => (int) $booking->id,
                    'can_purchase' => (bool) ($fundingPlan['can_purchase'] ?? false),
                    'wallet_balance' => round((float) ($fundingPlan['available_wallet_balance'] ?? 0), 2),
                    'required_amount' => round((float) ($fundingPlan['total_to_charge'] ?? $price), 2),
                    'shortage_amount' => round((float) ($fundingPlan['card_total_charge'] ?? 0), 2),
                    'payment_summary' => [
                        'requested_gateway' => $fundingPlan['requested_gateway'] ?? null,
                        'gateway' => $fundingPlan['gateway'] ?? null,
                        'gateway_family' => $fundingPlan['gateway_family'] ?? null,
                        'verification_strategy' => $fundingPlan['verification_strategy'] ?? null,
                        'subtotal' => round($price, 2),
                        'bonus_amount' => 0.0,
                        'wallet_amount' => round((float) ($fundingPlan['wallet_amount'] ?? 0), 2),
                        'card_amount' => round((float) ($fundingPlan['card_amount'] ?? 0), 2),
                        'processing_fee' => round((float) ($processingQuote['fee_amount'] ?? 0), 2),
                        'card_processing_fee' => round((float) ($processingQuote['fee_amount'] ?? 0), 2),
                        'card_total_charge' => round((float) ($fundingPlan['card_total_charge'] ?? 0), 2),
                        'remaining_balance' => round((float) ($fundingPlan['card_amount'] ?? 0), 2),
                        'requires_card' => (bool) ($fundingPlan['requires_card'] ?? false),
                        'has_selected_card' => (bool) ($fundingPlan['has_selected_card'] ?? false),
                        'total_to_pay' => round((float) ($fundingPlan['total_to_charge'] ?? $price), 2),
                    ],
                    'seller_summary' => [
                        'gross_amount' => round($price, 2),
                        'fee_amount' => round($sellerFee, 2),
                        'net_amount' => round($sellerPayout, 2),
                    ],
                    'event' => [
                        'id' => (int) ($booking->event_id ?? 0),
                        'title' => $this->resolveEventTitleFromBooking($booking),
                        'date' => $booking->event_date,
                    ],
                ],
            ]);
        } catch (\Throwable $e) {
            return response()->json([
                'success' => false,
                'message' => 'Could not preview this resale purchase right now.',
            ], 500);
        }
    }

    /**
     * Purchase a ticket from the marketplace.
     */
    public function purchase(Request $request, $id)
    {
        $buyer = Auth::guard('sanctum')->user();
        $validated = $request->validate([
            'apply_wallet_balance' => 'nullable|boolean',
            'stripe_payment_method_id' => 'nullable|string',
        ]);
        $capturedStripe = null;
        $capturedGateway = null;

        try {
            $walletService = app(\App\Services\WalletService::class);
            $paymentGatewayRegistry = app(PaymentGatewayRegistry::class);
            $result = DB::transaction(function () use ($id, $buyer, $walletService, $paymentGatewayRegistry, $validated, &$capturedStripe, &$capturedGateway) {
                $booking = $this->resolveVisibleMarketplaceBooking($id, true);
                if (!$booking) {
                    return [
                        'response' => response()->json(['success' => false, 'message' => 'Ticket no longer available.'], 404),
                    ];
                }

                if ((int) $booking->customer_id === (int) $buyer->id) {
                    return [
                        'response' => response()->json(['success' => false, 'message' => 'You cannot buy your own ticket.'], 400),
                    ];
                }

                $seller = Customer::find($booking->customer_id);
                if (!$seller) {
                    return [
                        'response' => response()->json([
                            'success' => false,
                            'message' => 'This resale listing is no longer available.',
                        ], 404),
                    ];
                }

                $price = (float) $booking->listing_price;
                $stripePaymentMethodId = $validated['stripe_payment_method_id'] ?? null;
                $applyWalletBalance = filter_var($validated['apply_wallet_balance'] ?? true, FILTER_VALIDATE_BOOLEAN);

                if (!empty($stripePaymentMethodId) && !$this->paymentMethodBelongsToCustomer($buyer, (string) $stripePaymentMethodId)) {
                    return [
                        'response' => response()->json([
                            'success' => false,
                            'message' => 'The selected card is not available for this account.',
                        ], 422),
                    ];
                }

                [$fundingPlan, $processingQuote] = $this->resolveMarketplaceFundingPreview(
                    $buyer,
                    $booking,
                    $applyWalletBalance,
                    $stripePaymentMethodId
                );

                if ((bool) ($fundingPlan['requires_card'] ?? false) && empty($stripePaymentMethodId)) {
                    return [
                        'response' => response()->json([
                            'success' => false,
                            'message' => 'Select a saved card to cover the remaining balance.',
                        ], 422),
                    ];
                }

                $feeBreakdown = $this->feeEngine->calculate(FeeEngine::OP_MARKETPLACE_RESALE, $price, [
                    'fee_base_amount' => $price,
                    'total_charge_amount' => $price,
                    'currency' => 'DOP',
                ]);
                $fee = (float) ($feeBreakdown['fee_amount'] ?? 0);
                $sellerPayout = (float) ($feeBreakdown['net_amount'] ?? max(0, $price - $fee));

                $operationKey = 'marketplace_booking_' . $booking->id . '_buyer_' . $buyer->id;

                if (((float) ($fundingPlan['wallet_amount'] ?? 0)) > 0) {
                    $walletService->debit(
                        $buyer,
                        (float) $fundingPlan['wallet_amount'],
                        'Marketplace Purchase',
                        (string) $booking->id,
                        'MP_BUY_WALLET_' . $operationKey,
                        0,
                        (float) $fundingPlan['wallet_amount'],
                        $this->buildMarketplaceGatewayMetadata($fundingPlan, 'wallet')
                    );
                }

                if (((float) ($fundingPlan['card_total_charge'] ?? 0)) > 0) {
                    $capturedGateway = (string) ($fundingPlan['requested_gateway'] ?? 'stripe');
                    $capturedStripe = $paymentGatewayRegistry->chargeSavedCard(
                        $capturedGateway,
                        $buyer,
                        (float) $fundingPlan['card_total_charge'],
                        'DOP',
                        'Marketplace Purchase #' . $booking->id,
                        (string) $stripePaymentMethodId,
                        [
                            'booking_id' => (string) $booking->id,
                            'event_id' => (string) $booking->event_id,
                            'purchase_source' => 'marketplace',
                            'funding_mode' => (string) ($fundingPlan['mode'] ?? 'card'),
                        ]
                    );
                }

                $walletService->credit(
                    $seller,
                    $sellerPayout,
                    'Marketplace Sale',
                    (string) $booking->id,
                    'MP_SELL_' . $operationKey,
                    $fee,
                    $price,
                    $this->buildMarketplaceGatewayMetadata($fundingPlan)
                );

                $transfer = TicketTransfer::create([
                    'booking_id' => $booking->id,
                    'from_customer_id' => $booking->customer_id,
                    'to_customer_id' => $buyer->id,
                    'notes' => 'Marketplace Purchase',
                ]);

                $booking->update([
                    'customer_id' => $buyer->id,
                    'fname' => $buyer->fname,
                    'lname' => $buyer->lname,
                    'email' => $buyer->email,
                    'phone' => $buyer->phone,
                    'is_listed' => false,
                    'listing_price' => 0,
                    'transfer_status' => null,
                ]);

                $this->ticketJourneyService->record($booking->fresh(), 'marketplace_purchase', [
                    'actor_customer_id' => (int) $buyer->id,
                    'target_customer_id' => (int) $buyer->id,
                    'transfer_id' => (int) $transfer->id,
                    'price' => $price,
                    'metadata' => [
                        'seller_customer_id' => (int) $seller->id,
                        'seller_payout' => round($sellerPayout, 2),
                        'marketplace_fee' => round($fee, 2),
                        'buyer_processing_fee' => round((float) ($processingQuote['fee_amount'] ?? 0), 2),
                        'wallet_amount' => round((float) ($fundingPlan['wallet_amount'] ?? 0), 2),
                        'card_total_charge' => round((float) ($fundingPlan['card_total_charge'] ?? 0), 2),
                    ] + $this->buildMarketplaceGatewayMetadata($fundingPlan),
                ]);

                $this->platformRevenueService->recordMarketplaceResale(
                    $booking->fresh(),
                    $buyer,
                    $seller,
                    $feeBreakdown,
                    $transfer,
                    $this->buildMarketplaceGatewayMetadata($fundingPlan)
                );

                if (((float) ($processingQuote['fee_amount'] ?? 0)) > 0) {
                    $this->platformRevenueService->recordMarketplaceCardProcessing(
                        $booking->fresh(),
                        $buyer,
                        $processingQuote,
                        $transfer,
                        $this->buildMarketplaceGatewayMetadata($fundingPlan)
                    );
                }

                return [
                    'seller' => $seller,
                    'booking' => $booking->fresh(),
                    'payment_summary' => [
                        'requested_gateway' => $fundingPlan['requested_gateway'] ?? null,
                        'gateway' => $fundingPlan['gateway'] ?? null,
                        'gateway_family' => $fundingPlan['gateway_family'] ?? null,
                        'verification_strategy' => $fundingPlan['verification_strategy'] ?? null,
                        'subtotal' => round($price, 2),
                        'wallet_amount' => round((float) ($fundingPlan['wallet_amount'] ?? 0), 2),
                        'card_amount' => round((float) ($fundingPlan['card_amount'] ?? 0), 2),
                        'processing_fee' => round((float) ($processingQuote['fee_amount'] ?? 0), 2),
                        'card_total_charge' => round((float) ($fundingPlan['card_total_charge'] ?? 0), 2),
                        'total_to_pay' => round((float) ($fundingPlan['total_to_charge'] ?? $price), 2),
                    ],
                ];
            });

            if (isset($result['response'])) {
                return $result['response'];
            }

            $seller = $result['seller'];
            $booking = $result['booking'];
            $paymentSummary = $result['payment_summary'] ?? null;

            try {
                $eventTitle = optional($booking->evnt)->title ?? 'an event';
                $this->notificationService->notifyUser(
                    $seller,
                    'Ticket Sold!',
                    'Your ticket for ' . $eventTitle . ' has been sold.'
                );
                $this->notificationService->notifyUser(
                    $buyer,
                    'Ticket Purchased',
                    'You have successfully purchased a ticket for ' . $eventTitle . ' from the marketplace.'
                );
            } catch (\Throwable $notifyError) {
                report($notifyError);
            }

            try {
                app(\App\Services\LoyaltyService::class)->awardFromRule(
                    $buyer,
                    'marketplace_purchase',
                    'marketplace_booking',
                    (string) $booking->id,
                    [
                        'event_id' => (int) ($booking->event_id ?? 0),
                        'booking_id' => (int) $booking->id,
                        'seller_customer_id' => (int) $seller->id,
                    ]
                );
            } catch (\Throwable $loyaltyError) {
                report($loyaltyError);
            }

            return response()->json([
                'success' => true,
                'message' => 'Ticket purchased successfully!',
                'data' => $booking,
                'payment_summary' => $paymentSummary,
            ]);
        } catch (\Throwable $e) {
            if (is_object($capturedStripe) && !empty($capturedStripe->id ?? null)) {
                try {
                    app(PaymentGatewayRegistry::class)->refund(
                        (string) ($capturedGateway ?: 'stripe'),
                        (string) $capturedStripe->id,
                        null,
                        ['reason' => 'marketplace_purchase_failed']
                    );
                } catch (\Throwable $refundError) {
                    report($refundError);
                }
            }

            return response()->json(['success' => false, 'message' => 'Purchase failed: ' . $e->getMessage()], 500);
        }
    }
}
