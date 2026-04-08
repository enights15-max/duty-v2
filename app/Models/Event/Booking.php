<?php

namespace App\Models\Event;

use App\Models\Customer;
use App\Models\Event;
use App\Models\Organizer;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\Schema;

class Booking extends Model
{
  use HasFactory;
  protected $fillable = [
    'customer_id',
    'booking_id',
    'order_number',
    'event_id',
    'organizer_id',
    'ticket_id',
    'fname',
    'lname',
    'email',
    'phone',
    'country',
    'state',
    'city',
    'zip_code',
    'address',
    'variation',
    'price',
    'tax_percentage',
    'commission_percentage',
    'tax',
    'commission',
    'quantity',
    'discount',
    'early_bird_discount',
    'currencyText',
    'currencyTextPosition',
    'currencySymbol',
    'currencySymbolPosition',
    'paymentMethod',
    'gatewayType',
    'paymentStatus',
    'invoice',
    'attachmentFile',
    'event_date',
    'scan_status',
    'conversation_id',
    'fcm_token',
    'is_transferable',
    'is_resellable',
    'resale_restriction_reason',
    'acquisition_source',
    'coupon_code',
    'is_listed',
    'listing_price',
    'transfer_status',
    'promoter_split_id',
  ];

  protected $casts = [
    'is_transferable' => 'boolean',
    'is_resellable' => 'boolean',
    'is_listed' => 'boolean',
    'listing_price' => 'float',
  ];

  public function promoterSplit()
  {
    return $this->belongsTo(\App\Models\EventCollaboratorSplit::class, 'promoter_split_id');
  }

  public function event()
  {
    return $this->hasOne(EventContent::class, 'event_id', 'event_id');
  }
  public function evnt()
  {
    return $this->belongsTo(Event::class, 'event_id', 'id');
  }
  //userInfo
  public function customerInfo()
  {
    return $this->hasOne(Customer::class, 'id', 'customer_id');
  }
  public function organizer()
  {
    return $this->belongsTo(Organizer::class);
  }

  public function paymentAllocations()
  {
    return $this->hasMany(BookingPaymentAllocation::class);
  }

  public function journeyEvents()
  {
    return $this->hasMany(\App\Models\TicketJourneyEvent::class, 'booking_id');
  }

  public function reservation()
  {
    return $this->belongsTo(\App\Models\Reservation\TicketReservation::class, 'reservation_id');
  }

  public function rewardInstances()
  {
    return $this->hasMany(\App\Models\EventRewardInstance::class, 'booking_id');
  }

  public function scopeOwnedByOrganizerActor(Builder $query, ?int $identityId = null, ?int $legacyOrganizerId = null): Builder
  {
    return $query->where(function (Builder $builder) use ($identityId, $legacyOrganizerId) {
      if ($identityId !== null) {
        $builder->whereHas('evnt', function (Builder $eventQuery) use ($identityId) {
          $eventQuery->where('owner_identity_id', $identityId);
        });

        if ($legacyOrganizerId !== null) {
          $builder->orWhere(function (Builder $fallback) use ($legacyOrganizerId) {
            $fallback->whereHas('evnt', function (Builder $eventQuery) use ($legacyOrganizerId) {
              $eventQuery->whereNull('owner_identity_id')
                ->where('organizer_id', $legacyOrganizerId);
            });
          });
        }

        return;
      }

      if ($legacyOrganizerId !== null) {
        $builder->where(function (Builder $fallback) use ($legacyOrganizerId) {
          $fallback->whereHas('evnt', function (Builder $eventQuery) use ($legacyOrganizerId) {
            $eventQuery->where('organizer_id', $legacyOrganizerId);
          })->orWhere('organizer_id', $legacyOrganizerId);
        });

        return;
      }

      $builder->whereRaw('1 = 0');
    });
  }

  public function isOwnedByOrganizerActor(?int $identityId = null, ?int $legacyOrganizerId = null): bool
  {
    $event = $this->relationLoaded('evnt') ? $this->getRelation('evnt') : $this->evnt;

    if ($identityId !== null && $event && (int) $event->owner_identity_id === $identityId) {
      return true;
    }

    if ($legacyOrganizerId === null) {
      return false;
    }

    if ($event && $event->owner_identity_id === null && (int) $event->organizer_id === $legacyOrganizerId) {
      return true;
    }

    return (int) $this->organizer_id === $legacyOrganizerId;
  }

  public function scopeVisibleMarketplaceListings(Builder $query, ?int $excludeCustomerId = null): Builder
  {
    $query
      ->where('is_listed', true)
      ->where(function (Builder $builder) {
        $builder->whereNull('paymentStatus')
          ->orWhereNotIn('paymentStatus', ['pending', 'rejected']);
      })
      ->whereHas('customerInfo')
      ->whereHas('evnt', function (Builder $eventQuery) {
        $eventQuery->where(function (Builder $dateQuery) {
          $dateQuery->whereNull('end_date_time')
            ->orWhere('end_date_time', '>', now());
        });
      });

    if ($excludeCustomerId !== null) {
      $query->where('customer_id', '!=', $excludeCustomerId);
    }

    if (Schema::hasColumn($this->getTable(), 'is_transferable')) {
      $query->where('is_transferable', true);
    }

    if (Schema::hasColumn($this->getTable(), 'transfer_status')) {
      $query->where(function (Builder $builder) {
        $builder->whereNull('transfer_status')
          ->orWhere('transfer_status', '!=', 'transfer_pending');
      });
    }

    if (Schema::hasColumn($this->getTable(), 'is_resellable')) {
      $query->where('is_resellable', true);
    }

    return $query;
  }

  protected static function boot()
  {
    parent::boot();
    static::deleting(function ($booking) {
      if (!empty($booking->variation)) {
        $veriations = json_decode($booking->variation, true);
        if (count($veriations) > 0) {
          $seatIds = array_column($veriations, 'seat_id');
          $slotIds = array_column($veriations, 'slot_id');
          Slot::whereIn('id', $slotIds)->update(['is_booked' => 0]);
          SlotSeats::whereIn('id', $seatIds)->update(['is_booked' => 0]);
        }
      }
    });
  }

}
