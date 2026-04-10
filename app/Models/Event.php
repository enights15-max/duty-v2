<?php

namespace App\Models;

use App\Models\Event\Booking;
use App\Models\Event\EventContent;
use App\Models\Event\EventDates;
use App\Models\Event\EventImage;
use App\Models\Event\EventLineup;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Model;
use App\Models\Event\Ticket;
use App\Models\Event\Wishlist;
use App\Models\Reservation\TicketReservation;

class Event extends Model
{
  use HasFactory;
  protected $fillable = [
    'venue_id',
    'organizer_id',
    'owner_identity_id',
    'venue_identity_id',
    'venue_source',
    'venue_name_snapshot',
    'venue_address_snapshot',
    'venue_city_snapshot',
    'venue_state_snapshot',
    'venue_country_snapshot',
    'venue_postal_code_snapshot',
    'venue_google_place_id',
    'thumbnail',
    'status',
    'review_status',
    'review_notes',
    'reviewed_at',
    'reviewed_by_admin_id',
    'age_limit',
    'countdown_status',
    'date_type',
    'start_date',
    'start_time',
    'duration',
    'end_date',
    'end_time',
    'end_date_time',
    'is_featured',
    'event_type',
    'latitude',
    'longitude',
    'ticket_image',
    'instructions',
    'meeting_url',
    'ticket_logo',
    'ticket_slot_image'
  ];

  protected $casts = [
    'reviewed_at' => 'datetime',
  ];
  public function ticket()
  {
    return $this->hasOne(Ticket::class);
  }
  public function tickets()
  {
    return $this->hasMany(Ticket::class);
  }
  //information
  public function information()
  {
    return $this->hasOne(EventContent::class);
  }
  //bookings
  public function booking()
  {
    return $this->hasMany(Booking::class);
  }

  public function reservations()
  {
    return $this->hasMany(TicketReservation::class);
  }

  public function treasury()
  {
    return $this->hasOne(EventTreasury::class);
  }

  public function settlementSettings()
  {
    return $this->hasOne(EventSettlementSetting::class);
  }

  public function financialEntries()
  {
    return $this->hasMany(EventFinancialEntry::class);
  }

  public function collaboratorSplits()
  {
    return $this->hasMany(EventCollaboratorSplit::class)->orderBy('created_at');
  }

  public function collaboratorEarnings()
  {
    return $this->hasMany(EventCollaboratorEarning::class)->orderBy('created_at');
  }

  public function rewardDefinitions()
  {
    return $this->hasMany(EventRewardDefinition::class)->orderBy('created_at');
  }

  public function rewardInstances()
  {
    return $this->hasMany(EventRewardInstance::class)->orderBy('created_at');
  }

  //venue
  public function venue()
  {
    return $this->belongsTo(Venue::class);
  }

  //wishtlist
  public function wishlists()
  {
    return $this->hasMany(Wishlist::class, 'event_id', 'id');
  }

  public function organizer()
  {
    return $this->belongsTo(Organizer::class);
  }

  public function galleries()
  {
    return $this->hasMany(EventImage::class);
  }

  public function dates()
  {
    return $this->hasMany(EventDates::class);
  }

  public function artists()
  {
    return $this->belongsToMany(Artist::class, 'event_artist');
  }

  public function ownerIdentity()
  {
    return $this->belongsTo(Identity::class, 'owner_identity_id');
  }

  public function venueIdentity()
  {
    return $this->belongsTo(Identity::class, 'venue_identity_id');
  }

  public function lineups()
  {
    return $this->hasMany(EventLineup::class)->orderBy('sort_order');
  }

  public function scopeOwnedByOrganizerActor(Builder $query, ?int $identityId = null, ?int $legacyOrganizerId = null): Builder
  {
    $ownerIdentityColumn = $this->qualifyColumn('owner_identity_id');
    $legacyOrganizerColumn = $this->qualifyColumn('organizer_id');

    return $query->where(function (Builder $builder) use ($identityId, $legacyOrganizerId, $ownerIdentityColumn, $legacyOrganizerColumn) {
      if ($identityId !== null) {
        $builder->where($ownerIdentityColumn, $identityId);

        if ($legacyOrganizerId !== null) {
          $builder->orWhere(function (Builder $fallback) use ($legacyOrganizerColumn, $legacyOrganizerId, $ownerIdentityColumn) {
            $fallback->whereNull($ownerIdentityColumn)
              ->where($legacyOrganizerColumn, $legacyOrganizerId);
          });
        }

        return;
      }

      if ($legacyOrganizerId !== null) {
        $builder->where($legacyOrganizerColumn, $legacyOrganizerId);
        return;
      }

      $builder->whereRaw('1 = 0');
    });
  }

  public function scopeOwnedByVenueActor(Builder $query, ?int $identityId = null, ?int $legacyVenueId = null): Builder
  {
    $venueIdentityColumn = $this->qualifyColumn('venue_identity_id');
    $legacyVenueColumn = $this->qualifyColumn('venue_id');
    $ownerIdentityColumn = $this->qualifyColumn('owner_identity_id');
    $legacyOrganizerColumn = $this->qualifyColumn('organizer_id');

    return $query->where(function (Builder $builder) use ($identityId, $legacyVenueId, $venueIdentityColumn, $legacyVenueColumn, $ownerIdentityColumn, $legacyOrganizerColumn) {
      if ($identityId !== null) {
        // A venue can manage events it owns directly, or legacy venue-owned events
        // that have not been attached to an organizer owner. Being the hosting venue
        // for an organizer-owned event is not enough to grant management access.
        $builder->where(function (Builder $ownedVenueEvents) use ($venueIdentityColumn, $identityId, $ownerIdentityColumn, $legacyOrganizerColumn) {
          $ownedVenueEvents->where($venueIdentityColumn, $identityId)
            ->whereNull($ownerIdentityColumn)
            ->whereNull($legacyOrganizerColumn);
        });

        // Some migrated venue-owned events may still store the active venue identity
        // as the owner identity.
        $builder->orWhere($ownerIdentityColumn, $identityId);

        if ($legacyVenueId !== null) {
          $builder->orWhere(function (Builder $fallback) use ($legacyVenueColumn, $legacyVenueId, $venueIdentityColumn, $ownerIdentityColumn, $legacyOrganizerColumn) {
            $fallback->whereNull($venueIdentityColumn)
              ->whereNull($ownerIdentityColumn)
              ->whereNull($legacyOrganizerColumn)
              ->where($legacyVenueColumn, $legacyVenueId);
          });
        }

        return;
      }

      if ($legacyVenueId !== null) {
        $builder->where($legacyVenueColumn, $legacyVenueId);
        return;
      }

      $builder->whereRaw('1 = 0');
    });
  }

  public function scopeParticipatesAsArtistActor(Builder $query, ?int $identityId = null, ?int $legacyArtistId = null): Builder
  {
    $ownerIdentityColumn = $this->qualifyColumn('owner_identity_id');

    return $query->where(function (Builder $builder) use ($identityId, $legacyArtistId, $ownerIdentityColumn) {
      if ($identityId !== null) {
        $builder->where($ownerIdentityColumn, $identityId);
      }

      if ($legacyArtistId !== null) {
        $builder->orWhereHas('lineups', function ($q) use ($legacyArtistId) {
          $q->where('artist_id', $legacyArtistId);
        });
      }

      if ($identityId === null && $legacyArtistId === null) {
        $builder->whereRaw('1 = 0');
      }
    });
  }

  public function isOwnedByOrganizerActor(?int $identityId = null, ?int $legacyOrganizerId = null): bool
  {
    if ($identityId !== null && (int) $this->owner_identity_id === $identityId) {
      return true;
    }

    return $legacyOrganizerId !== null
      && $this->owner_identity_id === null
      && (int) $this->organizer_id === $legacyOrganizerId;
  }

  public function isOwnedByVenueActor(?int $identityId = null, ?int $legacyVenueId = null): bool
  {
    if ($identityId !== null) {
      $isVenueOwnedEvent =
        (int) $this->venue_identity_id === $identityId &&
        $this->owner_identity_id === null &&
        $this->organizer_id === null;

      if ($isVenueOwnedEvent || (int) $this->owner_identity_id === $identityId) {
        return true;
      }
    }

    return $legacyVenueId !== null
      && $this->venue_identity_id === null
      && $this->owner_identity_id === null
      && $this->organizer_id === null
      && (int) $this->venue_id === $legacyVenueId;
  }
}
