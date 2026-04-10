<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Withdraw extends Model
{
  use HasFactory;
  public function method()
  {
    return $this->belongsTo(WithdrawPaymentMethod::class, 'method_id', 'id');
  }
  public function organizer()
  {
    return $this->belongsTo(Organizer::class);
  }
  public function venue()
  {
    return $this->belongsTo(Venue::class);
  }
  public function artist()
  {
    return $this->belongsTo(Artist::class);
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
