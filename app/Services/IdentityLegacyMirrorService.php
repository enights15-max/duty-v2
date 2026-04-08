<?php

namespace App\Services;

use App\Models\Artist;
use App\Models\Identity;
use App\Models\Organizer;
use App\Models\OrganizerInfo;
use App\Models\User;
use App\Models\Venue;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Str;

class IdentityLegacyMirrorService
{
    public function syncIdentity(Identity $identity): ?int
    {
        return match ($identity->type) {
            'artist' => $this->syncArtist($identity),
            'venue' => $this->syncVenue($identity),
            'organizer' => $this->syncOrganizer($identity),
            default => null,
        };
    }

    public function syncOwnerProfessionalIdentities(int $ownerUserId, array $types = ['artist', 'venue', 'organizer']): void
    {
        Identity::query()
            ->where('owner_user_id', $ownerUserId)
            ->whereIn('type', $types)
            ->where('status', 'active')
            ->get()
            ->each(fn (Identity $identity) => $this->syncIdentity($identity));
    }

    public function syncMatchingActiveIdentities(string $type, string $query, int $limit = 12): void
    {
        $normalized = trim($query);
        if ($normalized === '') {
            return;
        }

        $term = mb_strtolower($normalized);
        $like = '%' . $term . '%';

        $metaCastSql = DB::connection()->getDriverName() === 'sqlite'
            ? 'LOWER(CAST(meta AS TEXT)) LIKE ?'
            : 'LOWER(CAST(meta AS CHAR)) LIKE ?';

        Identity::query()
            ->where('type', $type)
            ->where('status', 'active')
            ->where(function ($builder) use ($like, $metaCastSql) {
                $builder->whereRaw('LOWER(display_name) LIKE ?', [$like])
                    ->orWhereRaw('LOWER(slug) LIKE ?', [$like])
                    ->orWhereRaw($metaCastSql, [$like]);
            })
            ->limit(max(1, min($limit, 25)))
            ->get()
            ->each(fn (Identity $identity) => $this->syncIdentity($identity));
    }

    private function syncArtist(Identity $identity): ?int
    {
        $owner = $identity->owner;
        $meta = is_array($identity->meta) ? $identity->meta : [];
        $legacyId = $this->resolveLegacyId($identity);

        /** @var Artist|null $artist */
        $artist = $legacyId ? Artist::query()->find($legacyId) : null;
        if (!$artist) {
            $artist = Artist::query()
                ->when(!empty($identity->slug), fn ($query) => $query->orWhere('username', $identity->slug))
                ->when(
                    $owner?->email && $this->hasColumn(Artist::class, 'email'),
                    fn ($query) => $query->orWhere('email', $owner->email)
                )
                ->first();
        }

        if (!$artist) {
            $artist = new Artist();
            if ($this->hasColumn(Artist::class, 'password')) {
                $artist->password = $owner?->password ?: bcrypt(Str::random(32));
            }
        }

        $artist->name = $identity->display_name;
        $artist->username = $this->uniqueValue(
            Artist::class,
            'username',
            $this->preferredHandle($identity),
            $artist->exists ? (int) $artist->id : null
        );
        if ($this->hasColumn(Artist::class, 'email')) {
            $artist->email = $this->resolveUniqueEmail(
                Artist::class,
                $owner,
                $artist->exists ? (int) $artist->id : null,
                'artist',
                (int) $identity->id
            );
        }
        $artist->photo = $meta['photo'] ?? $meta['image'] ?? $artist->photo;
        $artist->details = $meta['bio'] ?? $meta['booking_notes'] ?? $artist->details;
        if ($this->hasColumn(Artist::class, 'facebook')) {
            $artist->facebook = $meta['facebook'] ?? $artist->facebook;
        }
        if ($this->hasColumn(Artist::class, 'twitter')) {
            $artist->twitter = $meta['twitter'] ?? $meta['instagram'] ?? $artist->twitter;
        }
        if ($this->hasColumn(Artist::class, 'linkedin')) {
            $artist->linkedin = $meta['website'] ?? $meta['youtube'] ?? $artist->linkedin;
        }
        $artist->status = $identity->status === 'active' ? 1 : 0;
        if ($this->hasColumn(Artist::class, 'email_verified_at')) {
            $artist->email_verified_at = $owner?->email_verified_at;
        }
        $artist->save();

        $this->persistLegacyPointer($identity, (int) $artist->id, 'artist');

        return (int) $artist->id;
    }

    private function syncVenue(Identity $identity): ?int
    {
        $owner = $identity->owner;
        $meta = is_array($identity->meta) ? $identity->meta : [];
        $legacyId = $this->resolveLegacyId($identity);

        /** @var Venue|null $venue */
        $venue = $legacyId ? Venue::query()->find($legacyId) : null;
        if (!$venue) {
            $venue = Venue::query()
                ->when(!empty($identity->slug), fn ($query) => $query->orWhere('slug', $identity->slug)->orWhere('username', $identity->slug))
                ->when(
                    $owner?->email && $this->hasColumn(Venue::class, 'email'),
                    fn ($query) => $query->orWhere('email', $owner->email)
                )
                ->first();
        }

        if (!$venue) {
            $venue = new Venue();
            if ($this->hasColumn(Venue::class, 'password')) {
                $venue->password = $owner?->password ?: bcrypt(Str::random(32));
            }
        }

        $handle = $this->preferredHandle($identity);
        $venue->name = $identity->display_name;
        $venue->slug = $this->uniqueValue(
            Venue::class,
            'slug',
            Str::slug($handle),
            $venue->exists ? (int) $venue->id : null
        );
        if (Schema::hasColumn('venues', 'username')) {
            $venue->username = $this->uniqueValue(
                Venue::class,
                'username',
                $handle,
                $venue->exists ? (int) $venue->id : null
            );
        }
        if (Schema::hasColumn('venues', 'email')) {
            $venue->email = $this->resolveUniqueEmail(
                Venue::class,
                $owner,
                $venue->exists ? (int) $venue->id : null,
                'venue',
                (int) $identity->id
            );
        }
        if (Schema::hasColumn('venues', 'password') && empty($venue->password)) {
            $venue->password = $owner?->password ?: bcrypt(Str::random(32));
        }
        if (Schema::hasColumn('venues', 'email_verified_at')) {
            $venue->email_verified_at = $owner?->email_verified_at;
        }
        if ($this->hasColumn(Venue::class, 'address')) {
            $venue->address = $meta['address_line'] ?? $venue->address;
        }
        if ($this->hasColumn(Venue::class, 'city')) {
            $venue->city = $meta['city'] ?? $venue->city;
        }
        if ($this->hasColumn(Venue::class, 'state')) {
            $venue->state = $meta['state'] ?? $venue->state;
        }
        if ($this->hasColumn(Venue::class, 'country')) {
            $venue->country = $meta['country'] ?? $venue->country;
        }
        if ($this->hasColumn(Venue::class, 'zip_code')) {
            $venue->zip_code = $meta['zip_code'] ?? $meta['postal_code'] ?? $venue->zip_code;
        }
        if ($this->hasColumn(Venue::class, 'latitude')) {
            $venue->latitude = $meta['latitude'] ?? $venue->latitude;
        }
        if ($this->hasColumn(Venue::class, 'longitude')) {
            $venue->longitude = $meta['longitude'] ?? $venue->longitude;
        }
        if ($this->hasColumn(Venue::class, 'description')) {
            $venue->description = $meta['description'] ?? $venue->description;
        }
        if ($this->hasColumn(Venue::class, 'image')) {
            $venue->image = $meta['photo'] ?? $meta['image'] ?? $venue->image;
        }
        $venue->status = $identity->status === 'active' ? 1 : 0;
        $venue->save();

        $this->persistLegacyPointer($identity, (int) $venue->id, 'venue');

        return (int) $venue->id;
    }

    private function syncOrganizer(Identity $identity): ?int
    {
        $owner = $identity->owner;
        $meta = is_array($identity->meta) ? $identity->meta : [];
        $legacyId = $this->resolveLegacyId($identity);

        /** @var Organizer|null $organizer */
        $organizer = $legacyId ? Organizer::query()->find($legacyId) : null;
        if (!$organizer) {
            $organizer = Organizer::query()
                ->when(!empty($identity->slug), fn ($query) => $query->orWhere('username', $identity->slug))
                ->when(
                    $owner?->email && $this->hasColumn(Organizer::class, 'email'),
                    fn ($query) => $query->orWhere('email', $owner->email)
                )
                ->first();
        }

        if (!$organizer) {
            $organizer = new Organizer();
            if ($this->hasColumn(Organizer::class, 'password')) {
                $organizer->password = $owner?->password ?: bcrypt(Str::random(32));
            }
        }

        $organizer->photo = $meta['photo'] ?? $meta['image'] ?? $organizer->photo;
        if ($this->hasColumn(Organizer::class, 'cover_photo')) {
            $organizer->cover_photo = $meta['cover_photo'] ?? $organizer->cover_photo;
        }
        if ($this->hasColumn(Organizer::class, 'email')) {
            $organizer->email = $this->resolveUniqueEmail(
                Organizer::class,
                $owner,
                $organizer->exists ? (int) $organizer->id : null,
                'organizer',
                (int) $identity->id
            );
        }
        if ($this->hasColumn(Organizer::class, 'phone')) {
            $organizer->phone = $meta['whatsapp'] ?? $meta['contact_phone'] ?? $owner?->contact_number ?? $organizer->phone;
        }
        $organizer->username = $this->uniqueValue(
            Organizer::class,
            'username',
            $this->preferredHandle($identity),
            $organizer->exists ? (int) $organizer->id : null
        );
        $organizer->status = $identity->status === 'active' ? 1 : 0;
        if ($this->hasColumn(Organizer::class, 'facebook')) {
            $organizer->facebook = $meta['facebook'] ?? $organizer->facebook;
        }
        if ($this->hasColumn(Organizer::class, 'twitter')) {
            $organizer->twitter = $meta['instagram'] ?? $meta['twitter'] ?? $organizer->twitter;
        }
        if ($this->hasColumn(Organizer::class, 'linkedin')) {
            $organizer->linkedin = $meta['website'] ?? $organizer->linkedin;
        }
        if ($this->hasColumn(Organizer::class, 'email_verified_at')) {
            $organizer->email_verified_at = $owner?->email_verified_at;
        }
        $organizer->save();

        $defaultLanguageId = 1;
        if (Schema::hasTable('languages')) {
            $defaultLanguageId = (int) (\App\Models\Language::query()
                ->where('is_default', 1)
                ->value('id') ?? \App\Models\Language::query()->value('id') ?? 1);
        }

        OrganizerInfo::updateOrCreate(
            [
                'organizer_id' => $organizer->id,
                'language_id' => $defaultLanguageId,
            ],
            [
                'name' => $identity->display_name,
                'country' => $meta['country'] ?? null,
                'city' => $meta['city'] ?? null,
                'state' => $meta['state'] ?? null,
                'zip_code' => $meta['zip_code'] ?? $meta['postal_code'] ?? null,
                'address' => $meta['address_line'] ?? null,
                'details' => $meta['bio'] ?? $meta['details'] ?? null,
                'designation' => $meta['company_type'] ?? $meta['designation'] ?? null,
            ]
        );

        $this->persistLegacyPointer($identity, (int) $organizer->id, 'organizer');

        return (int) $organizer->id;
    }

    private function resolveLegacyId(Identity $identity): ?int
    {
        $meta = is_array($identity->meta) ? $identity->meta : [];
        $legacyId = $meta['legacy_id'] ?? $meta['id'] ?? null;
        return is_numeric($legacyId) ? (int) $legacyId : null;
    }

    private function persistLegacyPointer(Identity $identity, int $legacyId, string $source): void
    {
        $meta = is_array($identity->meta) ? $identity->meta : [];
        $dirty = false;

        if (($meta['legacy_id'] ?? null) !== $legacyId) {
            $meta['legacy_id'] = $legacyId;
            $dirty = true;
        }
        if (($meta['id'] ?? null) !== $legacyId) {
            $meta['id'] = $legacyId;
            $dirty = true;
        }
        if (($meta['legacy_source'] ?? null) !== $source) {
            $meta['legacy_source'] = $source;
            $dirty = true;
        }

        if ($dirty) {
            $identity->meta = $meta;
            $identity->save();
        }
    }

    private function preferredHandle(Identity $identity): string
    {
        $meta = is_array($identity->meta) ? $identity->meta : [];
        $raw = $identity->slug
            ?: ($meta['username'] ?? null)
            ?: ($meta['handle'] ?? null)
            ?: $identity->display_name
            ?: ($identity->type . '-' . $identity->id);

        $normalized = Str::slug(ltrim((string) $raw, '@'));

        return $normalized !== '' ? $normalized : ($identity->type . '-' . $identity->id);
    }

    private function uniqueValue(string $modelClass, string $column, string $preferred, ?int $ignoreId = null): string
    {
        $base = trim($preferred) !== '' ? trim($preferred) : Str::random(8);
        $candidate = $base;
        $suffix = 2;

        while ($this->valueExists($modelClass, $column, $candidate, $ignoreId)) {
            $candidate = $base . '-' . $suffix;
            $suffix++;
        }

        return $candidate;
    }

    private function valueExists(string $modelClass, string $column, string $value, ?int $ignoreId = null): bool
    {
        /** @var Model $modelClass */
        $query = $modelClass::query()->where($column, $value);
        if ($ignoreId) {
            $query->where('id', '!=', $ignoreId);
        }

        return $query->exists();
    }

    private function resolveUniqueEmail(string $modelClass, ?User $owner, ?int $ignoreId, string $prefix, int $identityId): string
    {
        $preferred = trim((string) ($owner?->email ?? ''));
        if ($preferred !== '' && !$this->valueExists($modelClass, 'email', $preferred, $ignoreId)) {
            return $preferred;
        }

        $base = "{$prefix}+{$identityId}@profiles.duty.local";
        if (!$this->valueExists($modelClass, 'email', $base, $ignoreId)) {
            return $base;
        }

        $suffix = 2;
        do {
            $candidate = "{$prefix}+{$identityId}-{$suffix}@profiles.duty.local";
            $suffix++;
        } while ($this->valueExists($modelClass, 'email', $candidate, $ignoreId));

        return $candidate;
    }

    private function hasColumn(string $modelClass, string $column): bool
    {
        /** @var Model $instance */
        $instance = new $modelClass();

        return Schema::hasColumn($instance->getTable(), $column);
    }
}
