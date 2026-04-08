<?php

namespace App\Services;

use App\Models\Artist;
use App\Models\Identity;
use App\Models\IdentityBalance;
use App\Models\Organizer;
use App\Models\Venue;
use Exception;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

class ProfessionalBalanceService
{
    private const LEGACY_MODELS = [
        'organizer' => Organizer::class,
        'artist' => Artist::class,
        'venue' => Venue::class,
    ];

    public function __construct(
        private ProfessionalCatalogBridgeService $catalogBridge
    ) {
    }

    public function currentOrganizerBalance(?int $identityId = null, ?int $legacyOrganizerId = null): float
    {
        return $this->currentBalanceFor('organizer', $identityId, $legacyOrganizerId);
    }

    public function currentArtistBalance(?int $identityId = null, ?int $legacyArtistId = null): float
    {
        return $this->currentBalanceFor('artist', $identityId, $legacyArtistId);
    }

    public function currentVenueBalance(?int $identityId = null, ?int $legacyVenueId = null): float
    {
        return $this->currentBalanceFor('venue', $identityId, $legacyVenueId);
    }

    public function previewOrganizerCredit(?int $identityId = null, ?int $legacyOrganizerId = null, float $amount = 0): array
    {
        return $this->previewCreditFor('organizer', $identityId, $legacyOrganizerId, $amount);
    }

    public function previewArtistCredit(?int $identityId = null, ?int $legacyArtistId = null, float $amount = 0): array
    {
        return $this->previewCreditFor('artist', $identityId, $legacyArtistId, $amount);
    }

    public function previewVenueCredit(?int $identityId = null, ?int $legacyVenueId = null, float $amount = 0): array
    {
        return $this->previewCreditFor('venue', $identityId, $legacyVenueId, $amount);
    }

    public function previewOrganizerDebit(?int $identityId = null, ?int $legacyOrganizerId = null, float $amount = 0): array
    {
        return $this->previewDebitFor('organizer', $identityId, $legacyOrganizerId, $amount);
    }

    public function previewArtistDebit(?int $identityId = null, ?int $legacyArtistId = null, float $amount = 0): array
    {
        return $this->previewDebitFor('artist', $identityId, $legacyArtistId, $amount);
    }

    public function previewVenueDebit(?int $identityId = null, ?int $legacyVenueId = null, float $amount = 0): array
    {
        return $this->previewDebitFor('venue', $identityId, $legacyVenueId, $amount);
    }

    public function creditOrganizerBalance(?int $identityId = null, ?int $legacyOrganizerId = null, float $amount = 0, bool $syncLegacyMirror = false): array
    {
        return $this->mutateBalanceFor('organizer', $identityId, $legacyOrganizerId, abs($amount), false, $syncLegacyMirror);
    }

    public function creditArtistBalance(?int $identityId = null, ?int $legacyArtistId = null, float $amount = 0, bool $syncLegacyMirror = false): array
    {
        return $this->mutateBalanceFor('artist', $identityId, $legacyArtistId, abs($amount), false, $syncLegacyMirror);
    }

    public function creditVenueBalance(?int $identityId = null, ?int $legacyVenueId = null, float $amount = 0, bool $syncLegacyMirror = false): array
    {
        return $this->mutateBalanceFor('venue', $identityId, $legacyVenueId, abs($amount), false, $syncLegacyMirror);
    }

    public function debitOrganizerBalance(?int $identityId = null, ?int $legacyOrganizerId = null, float $amount = 0, bool $allowNegative = false, bool $syncLegacyMirror = false): array
    {
        return $this->mutateBalanceFor('organizer', $identityId, $legacyOrganizerId, -abs($amount), $allowNegative, $syncLegacyMirror);
    }

    public function debitArtistBalance(?int $identityId = null, ?int $legacyArtistId = null, float $amount = 0, bool $allowNegative = false, bool $syncLegacyMirror = false): array
    {
        return $this->mutateBalanceFor('artist', $identityId, $legacyArtistId, -abs($amount), $allowNegative, $syncLegacyMirror);
    }

    public function debitVenueBalance(?int $identityId = null, ?int $legacyVenueId = null, float $amount = 0, bool $allowNegative = false, bool $syncLegacyMirror = false): array
    {
        return $this->mutateBalanceFor('venue', $identityId, $legacyVenueId, -abs($amount), $allowNegative, $syncLegacyMirror);
    }

    public function syncLegacyOrganizerMirror(?int $identityId = null, ?int $legacyOrganizerId = null): ?float
    {
        return $this->syncLegacyMirrorFor('organizer', $identityId, $legacyOrganizerId);
    }

    public function syncLegacyArtistMirror(?int $identityId = null, ?int $legacyArtistId = null): ?float
    {
        return $this->syncLegacyMirrorFor('artist', $identityId, $legacyArtistId);
    }

    public function syncLegacyVenueMirror(?int $identityId = null, ?int $legacyVenueId = null): ?float
    {
        return $this->syncLegacyMirrorFor('venue', $identityId, $legacyVenueId);
    }

    private function currentBalanceFor(string $type, ?int $identityId = null, ?int $legacyId = null): float
    {
        $context = $this->resolveContextFor($type, $identityId, $legacyId);

        if ($context['identity']) {
            $balance = IdentityBalance::query()
                ->where('identity_id', $context['identity']->id)
                ->value('balance');

            if ($balance !== null) {
                return round((float) $balance, 2);
            }
        }

        return round((float) ($context['legacy_model']?->amount ?? 0), 2);
    }

    private function previewCreditFor(string $type, ?int $identityId = null, ?int $legacyId = null, float $amount = 0): array
    {
        $preBalance = $this->currentBalanceFor($type, $identityId, $legacyId);

        return [
            'pre_balance' => $preBalance,
            'after_balance' => round($preBalance + $amount, 2),
        ];
    }

    private function previewDebitFor(string $type, ?int $identityId = null, ?int $legacyId = null, float $amount = 0): array
    {
        $preBalance = $this->currentBalanceFor($type, $identityId, $legacyId);

        return [
            'pre_balance' => $preBalance,
            'after_balance' => round($preBalance - $amount, 2),
        ];
    }

    private function syncLegacyMirrorFor(string $type, ?int $identityId = null, ?int $legacyId = null): ?float
    {
        $context = $this->resolveContextFor($type, $identityId, $legacyId);

        if (!$context['identity'] || !$context['legacy_model']) {
            return $context['legacy_model']
                ? round((float) $context['legacy_model']->amount, 2)
                : null;
        }

        $balance = $this->currentBalanceFor($type, $context['identity']->id, $context['legacy_id']);
        $this->writeLegacyMirror($context['legacy_model'], $balance);

        return $balance;
    }

    private function mutateBalanceFor(string $type, ?int $identityId, ?int $legacyId, float $delta, bool $allowNegative, bool $syncLegacyMirror): array
    {
        $context = $this->resolveContextFor($type, $identityId, $legacyId);

        return DB::transaction(function () use ($context, $delta, $allowNegative, $syncLegacyMirror) {
            if ($context['identity']) {
                $balanceRow = $this->lockBalanceRow($context['type'], $context['identity'], $context['legacy_model']);
                $preBalance = round((float) $balanceRow->balance, 2);
                $afterBalance = round($preBalance + $delta, 2);

                if (!$allowNegative && $afterBalance < 0) {
                    throw new Exception(sprintf('Insufficient %s balance.', $context['type']));
                }

                $balanceRow->legacy_type = $context['type'];
                $balanceRow->legacy_id = $context['legacy_id'];
                $balanceRow->balance = $afterBalance;
                if ($syncLegacyMirror) {
                    $balanceRow->last_synced_at = now();
                }
                $balanceRow->save();

                if ($syncLegacyMirror) {
                    $this->writeLegacyMirror($context['legacy_model'], $afterBalance);
                }

                return [
                    'pre_balance' => $preBalance,
                    'after_balance' => $afterBalance,
                    'identity_id' => $context['identity']->id,
                    'legacy_id' => $context['legacy_id'],
                ];
            }

            $legacyModel = $context['legacy_model'];
            if (!$legacyModel) {
                return [
                    'pre_balance' => 0.0,
                    'after_balance' => round($delta, 2),
                    'identity_id' => null,
                    'legacy_id' => null,
                ];
            }

            $preBalance = round((float) ($legacyModel->amount ?? 0), 2);
            $afterBalance = round($preBalance + $delta, 2);

            if (!$allowNegative && $afterBalance < 0) {
                throw new Exception(sprintf('Insufficient %s balance.', $context['type']));
            }

            $legacyModel->amount = $afterBalance;
            $legacyModel->save();

            return [
                'pre_balance' => $preBalance,
                'after_balance' => $afterBalance,
                'identity_id' => null,
                'legacy_id' => $legacyModel->id,
            ];
        });
    }

    private function resolveContextFor(string $type, ?int $identityId, ?int $legacyId): array
    {
        $modelClass = self::LEGACY_MODELS[$type] ?? null;
        if (!$modelClass) {
            throw new Exception(sprintf('Unsupported balance actor type: %s', $type));
        }

        $identity = null;
        if ($identityId) {
            $identity = Identity::query()->find($identityId);
        }

        if (!$identity && $legacyId) {
            $identity = $this->catalogBridge->findIdentityForLegacy($type, $legacyId);
        }

        if (!$legacyId && $identity) {
            $resolvedLegacyId = $this->catalogBridge->legacyIdForIdentity($identity, $type);
            $legacyId = is_numeric($resolvedLegacyId) ? (int) $resolvedLegacyId : null;
        }

        /** @var Model|null $legacyModel */
        $legacyModel = null;
        if ($legacyId && $this->legacyTableExists($modelClass)) {
            $legacyModel = $modelClass::query()->find($legacyId);
        }

        return [
            'type' => $type,
            'identity' => $identity,
            'legacy_model' => $legacyModel,
            'legacy_id' => $legacyModel?->id ?? $legacyId,
        ];
    }

    private function legacyTableExists(string $modelClass): bool
    {
        /** @var Model $model */
        $model = new $modelClass();

        return Schema::hasTable($model->getTable());
    }

    private function lockBalanceRow(string $type, Identity $identity, ?Model $legacyModel): IdentityBalance
    {
        $row = IdentityBalance::query()
            ->where('identity_id', $identity->id)
            ->lockForUpdate()
            ->first();

        if ($row) {
            return $row;
        }

        IdentityBalance::query()->create([
            'identity_id' => $identity->id,
            'legacy_type' => $type,
            'legacy_id' => $legacyModel?->id,
            'balance' => round((float) ($legacyModel->amount ?? 0), 2),
            'last_synced_at' => now(),
        ]);

        return IdentityBalance::query()
            ->where('identity_id', $identity->id)
            ->lockForUpdate()
            ->firstOrFail();
    }

    private function writeLegacyMirror(?Model $legacyModel, float $balance): void
    {
        if (!$legacyModel) {
            return;
        }

        $legacyModel->amount = round($balance, 2);
        $legacyModel->save();
    }
}
