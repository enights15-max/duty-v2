<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Identity extends Model
{
    use HasFactory;

    protected $fillable = [
        'type',
        'status',
        'owner_user_id',
        'display_name',
        'slug',
        'meta',
    ];

    protected $casts = [
        'meta' => 'array',
    ];

    public function owner()
    {
        return $this->belongsTo(User::class, 'owner_user_id');
    }

    public function members()
    {
        return $this->hasMany(IdentityMember::class);
    }

    public function users()
    {
        return $this->belongsToMany(User::class, 'identity_members')
            ->withPivot(['role', 'permissions', 'status'])
            ->withTimestamps();
    }

    public function events()
    {
        return $this->hasMany(Event::class, 'owner_identity_id');
    }

    public function venueEvents()
    {
        return $this->hasMany(Event::class, 'venue_identity_id');
    }

    /**
     * Get required fields in meta based on identity type.
     */
    public static function getRequiredFieldsByType($type)
    {
        return match ($type) {
            'personal' => ['display_name'],
            'organizer' => ['display_name', 'company_type', 'country', 'city'],
            'venue' => ['display_name', 'address_line', 'city', 'country', 'capacity', 'whatsapp'],
            'artist' => ['display_name', 'country', 'genres'],
            default => [],
        };
    }

    /**
     * Validate meta data.
     */
    public function validateMeta()
    {
        $required = self::getRequiredFieldsByType($this->type);
        $errors = [];

        foreach ($required as $field) {
            if ($field === 'display_name') {
                if (empty($this->display_name)) {
                    $errors[] = "display_name is required";
                }
                continue;
            }

            if (!isset($this->meta[$field]) || empty($this->meta[$field])) {
                $errors[] = "meta.{$field} is required";
            }
        }

        return $errors;
    }

    /**
     * Find an identity by legacy type and ID (stored in meta).
     */
    public static function findForLegacy(string $type, $legacyId): ?self
    {
        return self::where('type', $type)
            ->where('meta->id', $legacyId)
            ->first();
    }
}
