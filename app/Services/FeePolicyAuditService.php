<?php

namespace App\Services;

use App\Models\FeePolicy;
use App\Models\FeePolicyAuditLog;

class FeePolicyAuditService
{
    public function log(
        FeePolicy $policy,
        string $action,
        ?int $adminId = null,
        array $before = [],
        array $after = [],
        array $meta = []
    ): FeePolicyAuditLog {
        return FeePolicyAuditLog::create([
            'fee_policy_id' => $policy->id,
            'admin_id' => $adminId,
            'action' => $action,
            'before' => $before,
            'after' => $after,
            'meta' => $meta,
        ]);
    }
}
