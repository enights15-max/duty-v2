<?php

namespace Tests\Support;

use RuntimeException;
use Tests\TestCase;

abstract class ActorFeatureTestCase extends TestCase
{
    use ActorTestSchema;

    /**
     * Supported values:
     * - users_customers
     * - wallets
     * - payment_methods
     * - nfc_tokens
     * - withdrawal_requests
     * - marketplace
     * - followers
     * - subscription_plans
     * - identities
     * - admins_permissions
     * - subscriptions
     * - legacy_identity_sources
     * - discovery_catalog
     * - loyalty
     * - economy
     * - event_treasury
     * - event_rewards
     */
    protected array $baselineSchema = ['users_customers'];
    protected array $baselineTruncate = [];
    protected bool $baselineDefaultLanguage = false;

    protected function setUp(): void
    {
        parent::setUp();
        $this->applyActorBaseline();
    }

    protected function applyActorBaseline(): void
    {
        $this->assertSafeActorTestDatabase();

        foreach ($this->baselineSchema as $schemaPart) {
            $this->ensureSchemaPart($schemaPart);
        }

        if ($this->baselineDefaultLanguage) {
            $this->ensureDefaultLanguage();
        }

        if ($this->baselineTruncate !== []) {
            $this->truncateTables($this->baselineTruncate);
        }
    }

    private function ensureSchemaPart(string $schemaPart): void
    {
        switch ($schemaPart) {
            case 'users_customers':
                $this->ensureUsersAndCustomersTables();
                break;
            case 'wallets':
                $this->ensureWalletTables();
                break;
            case 'payment_methods':
                $this->ensurePaymentMethodsTable();
                break;
            case 'nfc_tokens':
                $this->ensureNfcTokensTable();
                break;
            case 'withdrawal_requests':
                $this->ensureWithdrawalRequestsTable();
                break;
            case 'marketplace':
                $this->ensureMarketplaceTables();
                break;
            case 'followers':
                $this->ensureFollowersTable();
                break;
            case 'subscription_plans':
                $this->ensureSubscriptionPlansTable();
                break;
            case 'identities':
                $this->ensureIdentityTables();
                break;
            case 'admins_permissions':
                $this->ensureAdminPermissionTables();
                break;
            case 'subscriptions':
                $this->ensureSubscriptionsTable();
                break;
            case 'legacy_identity_sources':
                $this->ensureLegacyIdentitySourceTables();
                break;
            case 'discovery_catalog':
                $this->ensureDiscoveryCatalogTables();
                break;
            case 'loyalty':
                $this->ensureLoyaltyTables();
                break;
            case 'economy':
                $this->ensureEconomyTables();
                break;
            case 'event_treasury':
                $this->ensureEventTreasuryTables();
                break;
            case 'event_rewards':
                $this->ensureEventRewardTables();
                break;
            default:
                throw new RuntimeException('Unsupported baseline schema part: ' . $schemaPart);
        }
    }

    private function assertSafeActorTestDatabase(): void
    {
        $environment = (string) app()->environment();
        $connection = (string) config('database.default');
        $database = (string) config('database.connections.' . $connection . '.database');

        if ($environment !== 'testing') {
            throw new RuntimeException(sprintf(
                'ActorFeatureTestCase refused to run outside the testing environment. Current environment: [%s].',
                $environment
            ));
        }

        if ($connection !== 'sqlite' || $database !== ':memory:') {
            throw new RuntimeException(sprintf(
                'ActorFeatureTestCase refused to touch database connection [%s] with database [%s]. Expected sqlite/:memory: for safe test isolation.',
                $connection,
                $database !== '' ? $database : '(empty)'
            ));
        }
    }
}
