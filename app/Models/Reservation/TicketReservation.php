<?php

namespace App\Models\Reservation;

use App\Models\Customer;
use App\Models\Event;
use App\Models\Event\Booking;
use App\Models\Event\Ticket;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class TicketReservation extends Model
{
    use HasFactory;

    protected $fillable = [
        'customer_id',
        'event_id',
        'ticket_id',
        'reservation_code',
        'booking_order_number',
        'quantity',
        'reserved_unit_price',
        'total_amount',
        'deposit_required',
        'amount_paid',
        'remaining_balance',
        'deposit_type',
        'deposit_value',
        'minimum_installment_amount',
        'final_due_date',
        'expires_at',
        'event_date',
        'status',
        'payment_method',
        'fname',
        'lname',
        'email',
        'phone',
        'country',
        'state',
        'city',
        'zip_code',
        'address',
    ];

    protected $casts = [
        'final_due_date' => 'datetime',
        'expires_at' => 'datetime',
    ];

    public function customer()
    {
        return $this->belongsTo(Customer::class);
    }

    public function event()
    {
        return $this->belongsTo(Event::class);
    }

    public function ticket()
    {
        return $this->belongsTo(Ticket::class);
    }

    public function payments()
    {
        return $this->hasMany(ReservationPayment::class, 'reservation_id');
    }

    public function bookings()
    {
        return $this->hasMany(Booking::class, 'reservation_id');
    }

    public function actionLogs()
    {
        return $this->hasMany(TicketReservationActionLog::class, 'reservation_id')->latest();
    }

    public function scopeOwnedByOrganizerActor(Builder $query, ?int $identityId = null, ?int $legacyOrganizerId = null): Builder
    {
        return $query->where(function (Builder $builder) use ($identityId, $legacyOrganizerId) {
            if ($identityId !== null) {
                $builder->whereHas('event', function (Builder $eventQuery) use ($identityId) {
                    $eventQuery->where('owner_identity_id', $identityId);
                });

                if ($legacyOrganizerId !== null) {
                    $builder->orWhere(function (Builder $fallback) use ($legacyOrganizerId) {
                        $fallback->whereHas('event', function (Builder $eventQuery) use ($legacyOrganizerId) {
                            $eventQuery->whereNull('owner_identity_id')
                                ->where('organizer_id', $legacyOrganizerId);
                        });
                    });
                }

                return;
            }

            if ($legacyOrganizerId !== null) {
                $builder->whereHas('event', function (Builder $eventQuery) use ($legacyOrganizerId) {
                    $eventQuery->where('organizer_id', $legacyOrganizerId);
                });

                return;
            }

            $builder->whereRaw('1 = 0');
        });
    }

    public function isOwnedByOrganizerActor(?int $identityId = null, ?int $legacyOrganizerId = null): bool
    {
        $event = $this->relationLoaded('event') ? $this->getRelation('event') : $this->event;

        if ($identityId !== null && $event && (int) $event->owner_identity_id === $identityId) {
            return true;
        }

        return $legacyOrganizerId !== null
            && $event
            && $event->owner_identity_id === null
            && (int) $event->organizer_id === $legacyOrganizerId;
    }
}
