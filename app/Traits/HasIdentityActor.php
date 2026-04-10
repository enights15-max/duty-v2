<?php

namespace App\Traits;

use App\Models\Identity;
use Illuminate\Support\Facades\Auth;

trait HasIdentityActor
{
    /**
     * Get the active actor (Identity) for the current request.
     */
    protected function getActiveIdentity(): ?Identity
    {
        return request()->get('active_identity');
    }

    /**
     * Get the legacy ID (from organizers/venues table) for the current actor.
     * 
     * @param string $type The expected identity type (organizer, venue, artist)
     * @return int|null
     */
    protected function getActiveLegacyId(string $type): ?int
    {
        // 1. Check if we have an active identity context (Mobile/Accounts Center)
        $identity = $this->getActiveIdentity();
        if ($identity && $identity->type === $type) {
            $meta = is_array($identity->meta) ? $identity->meta : [];

            if (isset($meta['legacy_id']) && is_numeric((string) $meta['legacy_id'])) {
                return (int) $meta['legacy_id'];
            }

            if (isset($meta['id']) && is_numeric((string) $meta['id'])) {
                return (int) $meta['id'];
            }

            return null;
        }

        // 2. Fallback to legacy guards (Web Panels)
        $guard = match ($type) {
            'organizer' => 'organizer',
            'venue' => 'venue',
            'artist' => 'artist',
            default => null
        };

        if ($guard && Auth::guard($guard)->check()) {
            return Auth::guard($guard)->user()->id;
        }

        return null;
    }

    /**
     * Get the organizer ID for the current context.
     */
    protected function getOrganizerId(): ?int
    {
        return $this->getActiveLegacyId('organizer');
    }

    /**
     * Get the venue ID for the current context.
     */
    protected function getVenueId(): ?int
    {
        return $this->getActiveLegacyId('venue');
    }

    /**
     * Get the artist ID for the current context.
     */
    protected function getArtistId(): ?int
    {
        return $this->getActiveLegacyId('artist');
    }
}
