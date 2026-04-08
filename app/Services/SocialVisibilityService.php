<?php

namespace App\Services;

use App\Models\Customer;

class SocialVisibilityService
{
    public function canViewProfileActivity(?Customer $viewer, Customer $target): bool
    {
        if ($viewer && (int) $viewer->id === (int) $target->id) {
            return true;
        }

        if (!$this->flag($target, 'is_private', false)) {
            return true;
        }

        if (!$viewer) {
            return false;
        }

        return $viewer->isFollowing($target);
    }

    public function canViewActivity(?Customer $viewer, Customer $target, string $activity): bool
    {
        if (!$this->canViewProfileActivity($viewer, $target)) {
            return false;
        }

        return match ($activity) {
            'interested' => $this->flag($target, 'show_interested_events', true),
            'attended' => $this->flag($target, 'show_attended_events', true),
            'upcoming' => $this->flag($target, 'show_upcoming_attendance', true),
            'favorites' => true,
            default => false,
        };
    }

    public function profileVisibility(?Customer $viewer, Customer $target): array
    {
        $canViewActivity = $this->canViewProfileActivity($viewer, $target);

        return [
            'can_view_activity' => $canViewActivity,
            'activity_visibility' => [
                'interested' => $canViewActivity && $this->flag($target, 'show_interested_events', true),
                'attended' => $canViewActivity && $this->flag($target, 'show_attended_events', true),
                'upcoming' => $canViewActivity && $this->flag($target, 'show_upcoming_attendance', true),
                'favorites' => $canViewActivity,
            ],
        ];
    }

    private function flag(Customer $customer, string $field, bool $default): bool
    {
        $value = $customer->getAttribute($field);

        if ($value === null) {
            return $default;
        }

        return filter_var($value, FILTER_VALIDATE_BOOL, FILTER_NULL_ON_FAILURE) ?? (bool) $value;
    }
}
