<?php

namespace App\Models;

use App\Models\Event\Booking;
use App\Models\ShopManagement\ProductOrder;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Transaction extends Model
{
    use HasFactory;

    protected $fillable = [
        'transcation_id',
        'booking_id',
        'transcation_type',
        'customer_id',
        'organizer_id',
        'organizer_identity_id',
        'venue_id',
        'venue_identity_id',
        'artist_id',
        'artist_identity_id',
        'payment_status',
        'payment_method',
        'grand_total',
        'pre_balance',
        'after_balance',
        'commission',
        'tax',
        'gateway_type',
        'currency_symbol',
        'currency_symbol_position'
    ];
    //method
    public function method()
    {
        return $this->belongsTo(WithdrawPaymentMethod::class, 'payment_method', 'id');
    }

    //room_booking 
    public function product_order()
    {
        return $this->belongsTo(ProductOrder::class, 'booking_id', 'id');
    }
    //event_booking 
    public function event_booking()
    {
        return $this->belongsTo(Booking::class, 'booking_id', 'id');
    }

    public function organizer()
    {
        return $this->belongsTo(Organizer::class);
    }

    public function scopeOwnedByOrganizerActor(Builder $query, ?int $identityId = null, ?int $legacyOrganizerId = null): Builder
    {
        return $this->scopeOwnedByProfessionalActor($query, 'organizer', $identityId, $legacyOrganizerId);
    }

    public function scopeOwnedByArtistActor(Builder $query, ?int $identityId = null, ?int $legacyArtistId = null): Builder
    {
        return $this->scopeOwnedByProfessionalActor($query, 'artist', $identityId, $legacyArtistId);
    }

    public function scopeOwnedByVenueActor(Builder $query, ?int $identityId = null, ?int $legacyVenueId = null): Builder
    {
        return $this->scopeOwnedByProfessionalActor($query, 'venue', $identityId, $legacyVenueId);
    }

    private function scopeOwnedByProfessionalActor(Builder $query, string $type, ?int $identityId = null, ?int $legacyId = null): Builder
    {
        $identityColumn = $type . '_identity_id';
        $legacyColumn = $type . '_id';

        return $query->where(function (Builder $builder) use ($identityColumn, $legacyColumn, $identityId, $legacyId): void {
            if ($identityId !== null) {
                $builder->where($identityColumn, $identityId);
            }

            if ($legacyId !== null) {
                $builder->orWhere(function (Builder $fallback) use ($identityColumn, $legacyColumn, $legacyId): void {
                    $fallback
                        ->whereNull($identityColumn)
                        ->where($legacyColumn, $legacyId);
                });
            }
        });
    }
}
