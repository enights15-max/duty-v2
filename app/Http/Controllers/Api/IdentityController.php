<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Identity;
use App\Models\IdentityMember;
use App\Models\Customer;
use App\Models\User;
use App\Services\IdentityLegacyMirrorService;
use App\Support\PublicAssetUrl;
use Illuminate\Support\Str;
use Illuminate\Support\Facades\Validator;
use Illuminate\Http\UploadedFile;

class IdentityController extends Controller
{
    public function __construct(
        protected IdentityLegacyMirrorService $legacyMirror
    ) {
    }

    /**
     * List all identities for the current user.
     */
    public function index(Request $request)
    {
        \Illuminate\Support\Facades\Log::info("IDENTITY INDEX REQUEST", [
            'auth_user' => $request->user() ? $request->user()->id : 'NONE',
        ]);
        $authUser = $request->user();
        $user = $this->resolveIdentityUser($authUser);
        if (!$user) {
            return response()->json(['status' => 'error', 'message' => 'Unauthorized'], 401);

        $identities = $user->usersIdentities()->get()->map(function ($identity) {
            return [
                'id' => $identity->id,
                'type' => $identity->type,
                'display_name' => $identity->display_name,
                'slug' => $identity->slug,
                'status' => $identity->status,
                'role' => $identity->pivot->role,
                'avatar_url' => $this->resolveIdentityAvatarUrl($identity),
                'cover_photo_url' => $this->resolveIdentityCoverPhotoUrl($identity),
                'meta' => $identity->meta,
            ];
        });

        return response()->json([
            'status' => 'success',
            'identities' => $identities
        ]);
    }

    /**
     * Request a new identity.
     */
    public function store(Request $request)
    {
        \Illuminate\Support\Facades\Log::info("IDENTITY STORE REQUEST", [
            'auth_user' => $request->user() ? $request->user()->id : 'NONE',
            'type' => $request->input('type'),
            'display_name' => $request->input('display_name'),
        ]);

        $meta = $this->normalizeMetaInput($request);

        $validator = Validator::make($request->all(), [
            'type' => 'required|in:organizer,venue,artist',
            'display_name' => 'required|string|max:255',
            'slug' => 'nullable|string|max:80',
            'logo' => 'nullable|image|mimes:jpg,jpeg,png,webp|max:10240',
            'cover_photo' => 'nullable|image|mimes:jpg,jpeg,png,webp|max:10240',
            'gallery' => 'nullable|array|max:8',
            'gallery.*' => 'nullable|image|mimes:jpg,jpeg,png,webp|max:10240',
        ]);

        if ($validator->fails()) {
            return response()->json(['status' => 'validation_error', 'errors' => $validator->errors()], 422);
        }

        [$requestedSlug, $slugError] = $this->resolveRequestedSlug($request);
        if ($slugError) {
            return response()->json(['status' => 'validation_error', 'errors' => ['slug' => [$slugError]]], 422);
        }

        if (!is_array($meta)) {
            return response()->json(['status' => 'validation_error', 'errors' => ['meta' => ['meta must be an array']]], 422);
        }

        $authUser = $request->user();
        $user = $this->resolveIdentityUser($authUser);
        if (!$user) {
            return response()->json([
                'status' => 'error',
                'message' => 'A verified personal account is required before requesting a professional profile.'
            ], 422);
        }

        // Prevent duplicate requests of same type by same owner if still pending
        $existing = Identity::where('owner_user_id', $user->id)
            ->where('type', $request->type)
            ->whereIn('status', ['pending', 'active'])
            ->first();

        if ($existing) {
            return response()->json(['status' => 'error', 'message' => "You already have a {$request->type} identity."], 400);
        }

        $rejectedIdentity = Identity::where('owner_user_id', $user->id)
            ->where('type', $request->type)
            ->where('status', 'rejected')
            ->orderByDesc('updated_at')
            ->first();

        if ($rejectedIdentity) {
            $rejectedIdentity->display_name = $request->display_name;
            $rejectedIdentity->slug = $requestedSlug ?: $this->generateUniqueSlug($request->display_name, (int) $rejectedIdentity->id);
            $rejectedIdentity->status = 'pending';
            $rejectedIdentity->meta = $this->buildResubmissionMeta(
                is_array($rejectedIdentity->meta) ? $rejectedIdentity->meta : [],
                $meta
            );
            $rejectedIdentity->meta = $this->mergeUploadedIdentityMedia($request, $rejectedIdentity->meta, $rejectedIdentity);

            $errors = $rejectedIdentity->validateMeta();
            if (!empty($errors)) {
                return response()->json(['status' => 'validation_error', 'errors' => $errors], 422);
            }

            $rejectedIdentity->save();
            if ($rejectedIdentity->status === 'active') {
                $this->legacyMirror->syncIdentity($rejectedIdentity);
            }

            IdentityMember::updateOrCreate(
                [
                    'identity_id' => $rejectedIdentity->id,
                    'user_id' => $user->id,
                ],
                [
                    'role' => 'owner',
                    'status' => 'active',
                ]
            );

            return response()->json([
                'status' => 'success',
                'message' => 'Identity re-submitted for approval.',
                'identity' => $rejectedIdentity,
            ]);
        }

        $identity = new Identity();
        $identity->fill([
            'type' => $request->type,
            'status' => 'pending',
            'owner_user_id' => $user->id,
            'display_name' => $request->display_name,
            'slug' => $requestedSlug ?: $this->generateUniqueSlug($request->display_name),
            'meta' => $this->mergeUploadedIdentityMedia($request, $meta),
        ]);

        $errors = $identity->validateMeta();
        if (!empty($errors)) {
            return response()->json(['status' => 'validation_error', 'errors' => $errors], 422);
        }

        $identity->save();
        if ($identity->status === 'active') {
            $this->legacyMirror->syncIdentity($identity);
        }

        IdentityMember::create([
            'identity_id' => $identity->id,
            'user_id' => $user->id,
            'role' => 'owner',
            'status' => 'active',
        ]);

        return response()->json([
            'status' => 'success',
            'message' => 'Identity request submitted for approval.',
            'identity' => $identity
        ], 201);
    }

    /**
     * Update identity details.
     */
    public function update(Request $request, $id)
    {
        $identity = Identity::findOrFail($id);
        $user = $request->user();

        // Check if user is owner or admin of this identity
        $membership = IdentityMember::where('identity_id', $identity->id)
            ->where('user_id', $user->id)
            ->whereIn('role', ['owner', 'admin'])
            ->first();

        if (!$membership) {
            return response()->json(['status' => 'error', 'message' => 'Unauthorized'], 403);
        }

        if (!in_array($identity->status, ['pending', 'active'], true)) {
            return response()->json([
                'status' => 'error',
                'message' => 'Only pending or active identities can be updated.',
            ], 400);
        }

        $validator = Validator::make($request->all(), [
            'display_name' => 'sometimes|string|max:255',
            'slug' => 'nullable|string|max:80',
            'logo' => 'nullable|image|mimes:jpg,jpeg,png,webp|max:10240',
            'cover_photo' => 'nullable|image|mimes:jpg,jpeg,png,webp|max:10240',
            'gallery' => 'nullable|array|max:8',
            'gallery.*' => 'nullable|image|mimes:jpg,jpeg,png,webp|max:10240',
        ]);

        if ($validator->fails()) {
            return response()->json(['status' => 'validation_error', 'errors' => $validator->errors()], 422);
        }

        [$requestedSlug, $slugError] = $this->resolveRequestedSlug($request, (int) $identity->id);
        if ($slugError) {
            return response()->json(['status' => 'validation_error', 'errors' => ['slug' => [$slugError]]], 422);
        }

        if ($request->has('display_name')) {
            $identity->display_name = $request->display_name;
        }

        if ($requestedSlug) {
            $identity->slug = $requestedSlug;
        } elseif (empty($identity->slug) && !empty($identity->display_name)) {
            $identity->slug = $this->generateUniqueSlug($identity->display_name, (int) $identity->id);
        }

        $meta = $this->normalizeMetaInput($request, false);

        if (is_array($meta) && !empty($meta)) {
            $identity->meta = array_merge($identity->meta ?? [], $meta);
        }

        $identity->meta = $this->mergeUploadedIdentityMedia($request, $identity->meta ?? [], $identity);

        $errors = $identity->validateMeta();
        if (!empty($errors)) {
            return response()->json(['status' => 'validation_error', 'errors' => $errors], 422);
        }

        $identity->save();
        if ($identity->status === 'active') {
            $this->legacyMirror->syncIdentity($identity);
        }

        return response()->json([
            'status' => 'success',
            'message' => 'Identity updated successfully.',
            'identity' => $identity
        ]);
    }

    protected function normalizeMetaInput(Request $request, bool $required = true): ?array
    {
        $meta = $request->input('meta');

        if (is_array($meta)) {
            return $meta;
        }

        if (is_string($meta) && $meta !== '') {
            $decoded = json_decode($meta, true);
            if (is_array($decoded)) {
                return $decoded;
            }
        }

        return $required ? null : [];
    }

    protected function resolveRequestedSlug(Request $request, ?int $ignoreId = null): array
    {
        if (!$request->exists('slug')) {
            return [null, null];
        }

        $normalized = $this->normalizeHandleToSlug($request->input('slug'));
        if ($normalized === null || $normalized === '') {
            return [null, 'The profile handle is invalid.'];
        }

        if (strlen($normalized) > 80) {
            return [null, 'The profile handle may not be greater than 80 characters.'];
        }

        $query = Identity::query()->where('slug', $normalized);
        if (!is_null($ignoreId)) {
            $query->where('id', '!=', $ignoreId);
        }

        if ($query->exists()) {
            return [null, 'This profile handle is already in use.'];
        }

        return [$normalized, null];
    }

    protected function normalizeHandleToSlug($value): ?string
    {
        if ($value === null) {
            return null;
        }

        $raw = trim((string) $value);
        if ($raw === '') {
            return '';
        }

        $raw = ltrim($raw, '@');
        $slug = Str::slug($raw);

        return $slug !== '' ? $slug : '';
    }

    protected function mergeUploadedIdentityMedia(
        Request $request,
        array $meta,
        ?Identity $identity = null
    ): array {
        $identityType = $identity?->type ?: $request->input('type');

        foreach ([
            'logo' => 'image',
            'cover_photo' => 'cover_photo',
        ] as $requestKey => $metaKey) {
            if (!$request->hasFile($requestKey)) {
                continue;
            }

            $stored = $this->storeIdentityMediaFile(
                $request->file($requestKey),
                $meta[$metaKey] ?? null,
                $identityType,
                $requestKey
            );
            if ($stored) {
                $meta[$metaKey] = $stored;
                if ($requestKey === 'logo') {
                    $meta['photo'] = $stored;
                }
            }
        }

        $hasGalleryIntent = $request->hasFile('gallery')
            || array_key_exists('gallery', $meta)
            || array_key_exists('gallery_order', $meta)
            || array_key_exists('gallery_clear', $meta);

        if ($hasGalleryIntent) {
            $previousGallery = array_values(array_filter(
                (array) ($identity?->meta['gallery'] ?? []),
                fn ($fileName) => $this->isStoredGalleryFile($fileName)
            ));
            $retainedGallery = array_values(array_filter(
                (array) ($meta['gallery'] ?? []),
                fn ($fileName) => $this->isStoredGalleryFile($fileName)
            ));
            $galleryOrder = array_values(array_filter(
                (array) ($meta['gallery_order'] ?? []),
                fn ($token) => trim((string) $token) !== ''
            ));

            $uploadedGallery = [];
            foreach ((array) $request->file('gallery', []) as $galleryIndex => $galleryFile) {
                if (!$galleryFile instanceof UploadedFile) {
                    continue;
                }

                $stored = $this->storeIdentityMediaFile($galleryFile, null, $identityType);
                if ($stored) {
                    $uploadedGallery[(string) $galleryIndex] = $stored;
                }
            }

            $finalGallery = $this->resolveOrderedGallery(
                $retainedGallery,
                $galleryOrder,
                $uploadedGallery
            );

            $removedGallery = array_values(array_diff($previousGallery, $finalGallery));
            if (!empty($removedGallery)) {
                $this->deleteIdentityGalleryFiles($removedGallery, $identityType);
            }

            if (!empty($finalGallery)) {
                $meta['gallery'] = $finalGallery;
            } else {
                unset($meta['gallery']);
            }

            unset($meta['gallery_order']);
            unset($meta['gallery_clear']);
        }

        return $meta;
    }

    protected function resolveOrderedGallery(
        array $retainedGallery,
        array $galleryOrder,
        array $uploadedGallery
    ): array {
        $allowedExisting = array_values(array_unique(array_filter(
            $retainedGallery,
            fn ($fileName) => $this->isStoredGalleryFile($fileName)
        )));
        $existingLookup = array_fill_keys($allowedExisting, true);
        $resolved = [];

        foreach ($galleryOrder as $token) {
            $normalized = trim((string) $token);
            if ($normalized === '') {
                continue;
            }

            if (str_starts_with($normalized, 'existing:')) {
                $fileName = trim(substr($normalized, strlen('existing:')));
                if ($fileName !== '' && isset($existingLookup[$fileName]) && !in_array($fileName, $resolved, true)) {
                    $resolved[] = $fileName;
                }
                continue;
            }

            if (str_starts_with($normalized, 'new:')) {
                $uploadIndex = trim(substr($normalized, strlen('new:')));
                if ($uploadIndex !== '' && isset($uploadedGallery[$uploadIndex])) {
                    $resolved[] = $uploadedGallery[$uploadIndex];
                }
            }
        }

        foreach ($allowedExisting as $fileName) {
            if (!in_array($fileName, $resolved, true)) {
                $resolved[] = $fileName;
            }
        }

        foreach ($uploadedGallery as $fileName) {
            if (!in_array($fileName, $resolved, true)) {
                $resolved[] = $fileName;
            }
        }

        return array_values(array_unique($resolved));
    }

    protected function isStoredGalleryFile($fileName): bool
    {
        $normalized = trim((string) $fileName);

        return $normalized !== '' && !filter_var($normalized, FILTER_VALIDATE_URL);
    }

    protected function storeIdentityMediaFile(
        UploadedFile $file,
        ?string $existing = null,
        ?string $identityType = null,
        ?string $mediaKind = null
    ): ?string
    {
        $directory = match ($identityType) {
            'artist' => public_path('assets/admin/img/artist/'),
            'organizer' => $this->resolveOrganizerMediaDirectory($existing, $mediaKind),
            default => public_path('assets/admin/img/venue/'),
        };
        if (!file_exists($directory)) {
            @mkdir($directory, 0775, true);
        }

        $extension = $file->getClientOriginalExtension() ?: 'jpg';
        $fileName = uniqid('identity_', true) . '.' . strtolower($extension);
        $file->move($directory, $fileName);

        if (!empty($existing) && file_exists($directory . $existing)) {
            @unlink($directory . $existing);
        }

        return $fileName;
    }

    protected function deleteIdentityGalleryFiles(array $gallery, ?string $identityType = null): void
    {
        $directory = match ($identityType) {
            'artist' => public_path('assets/admin/img/artist/'),
            'organizer' => public_path('assets/admin/img/organizer-photo/'),
            default => public_path('assets/admin/img/venue/'),
        };

        foreach ($gallery as $fileName) {
            $normalized = trim((string) $fileName);
            if ($normalized === '' || filter_var($normalized, FILTER_VALIDATE_URL)) {
                continue;
            }

            $path = $directory . ltrim($normalized, '/');
            if (file_exists($path)) {
                @unlink($path);
            }
        }
    }

    protected function generateUniqueSlug($title, ?int $ignoreId = null)
    {
        $slug = Str::slug($title);
        $count = Identity::where('slug', 'LIKE', "{$slug}%")->count();
        return $count ? "{$slug}-{$count}" : $slug;
    }

    protected function buildResubmissionMeta(array $currentMeta, array $incomingMeta): array
    {
        $meta = array_merge($currentMeta, $incomingMeta);

        unset(
            $meta['rejection_reason'],
            $meta['rejected_at'],
            $meta['rejected_by_admin_id'],
            $meta['revision_request']
        );

        $history = $meta['moderation_history'] ?? [];
        if (!is_array($history)) {
            $history = [];
        }

        $history[] = [
            'action_id' => (string) Str::ulid(),
            'action' => 'resubmitted',
            'admin_id' => null,
            'at' => now()->toIso8601String(),
            'details' => [
                'source' => 'customer_identity_store',
            ],
        ];

        $meta['moderation_history'] = $history;

        return $meta;
    }

    protected function resolveIdentityAvatarUrl(Identity $identity): ?string
    {
        $meta = is_array($identity->meta) ? $identity->meta : [];
        $rawPhoto = $meta['photo'] ?? $meta['image'] ?? null;

        return match ($identity->type) {
            'artist' => PublicAssetUrl::url($rawPhoto, 'assets/admin/img/artist'),
            'venue' => PublicAssetUrl::url($rawPhoto, 'assets/admin/img/venue'),
            'organizer' => PublicAssetUrl::url($rawPhoto, 'assets/admin/img/organizer-photo'),
            default => $this->resolvePersonalAvatarUrl($identity),
        };
    }

    protected function resolveIdentityCoverPhotoUrl(Identity $identity): ?string
    {
        $meta = is_array($identity->meta) ? $identity->meta : [];
        $rawCover = $meta['cover_photo'] ?? null;

        return match ($identity->type) {
            'artist' => PublicAssetUrl::url($rawCover, 'assets/admin/img/artist'),
            'venue' => PublicAssetUrl::url($rawCover, 'assets/admin/img/venue'),
            'organizer' => PublicAssetUrl::url($rawCover, 'assets/admin/img/organizer-cover'),
            default => null,
        };
    }

    protected function resolveOrganizerMediaDirectory(?string $existing = null, ?string $mediaKind = null): string
    {
        if ($mediaKind === 'cover_photo') {
            return public_path('assets/admin/img/organizer-cover/');
        }

        $existingValue = trim((string) $existing);
        $isCoverLike = str_contains($existingValue, 'cover')
            || str_contains($existingValue, 'hero')
            || str_contains($existingValue, 'banner');

        return $isCoverLike
            ? public_path('assets/admin/img/organizer-cover/')
            : public_path('assets/admin/img/organizer-photo/');
    }

    protected function resolvePersonalAvatarUrl(Identity $identity): ?string
    {
        $owner = User::find($identity->owner_user_id);
        if (!$owner || empty($owner->email)) {
            return null;
        }

        $customerPhoto = Customer::where('email', $owner->email)->value('photo');
        return PublicAssetUrl::url($customerPhoto, 'assets/admin/img/customer-profile');
    }

    protected function resolveIdentityUser($authUser): ?User
    {
        if ($authUser instanceof User) {
            return $authUser;
        }

        if (!($authUser instanceof Customer)) {
            return null;
        }

        if (empty($authUser->email)) {
            return null;
        }

        $seedUsername = $authUser->username ?: 'duty_' . $authUser->id;

        $user = User::firstOrCreate(
            ['email' => $authUser->email],
            [
                'first_name' => $authUser->fname ?: 'User',
                'last_name' => $authUser->lname ?: '',
                'username' => $this->generateAvailableUsername($seedUsername),
                'password' => $authUser->password ?: bcrypt(Str::random(40)),
                'contact_number' => $authUser->phone,
                'address' => $authUser->address,
                'city' => $authUser->city,
                'state' => $authUser->state,
                'country' => $authUser->country,
                'status' => (int) ($authUser->status ?? 1) === 1 ? 1 : 0,
                'email_verified_at' => $authUser->email_verified_at,
            ]
        );

        $updates = [];
        if (empty($user->first_name) && !empty($authUser->fname)) {
            $updates['first_name'] = $authUser->fname;
        }
        if (empty($user->last_name) && !empty($authUser->lname)) {
            $updates['last_name'] = $authUser->lname;
        }
        if (empty($user->username)) {
            $updates['username'] = $this->generateAvailableUsername($seedUsername);
        }
        if (empty($user->contact_number) && !empty($authUser->phone)) {
            $updates['contact_number'] = $authUser->phone;
        }
        if (empty($user->address) && !empty($authUser->address)) {
            $updates['address'] = $authUser->address;
        }
        if (empty($user->city) && !empty($authUser->city)) {
            $updates['city'] = $authUser->city;
        }
        if (empty($user->state) && !empty($authUser->state)) {
            $updates['state'] = $authUser->state;
        }
        if (empty($user->country) && !empty($authUser->country)) {
            $updates['country'] = $authUser->country;
        }

        if (!empty($updates)) {
            $user->fill($updates);
            $user->save();
        }

        return $user;
    }

    protected function ensurePersonalIdentity(User $user, ?Customer $customer = null): Identity
    {
        $identity = Identity::where('owner_user_id', $user->id)
            ->where('type', 'personal')
            ->first();

        if (!$identity) {
            $displayName = trim(($user->first_name ?? '') . ' ' . ($user->last_name ?? ''));
            if ($displayName === '') {
                $displayName = $user->username ?: ('User ' . $user->id);
            }

            $identity = Identity::create([
                'type' => 'personal',
                'status' => 'active',
                'owner_user_id' => $user->id,
                'display_name' => $displayName,
                'slug' => $this->generateUniqueSlug($displayName),
                'meta' => [
                    'display_name' => $displayName,
                    'country' => $customer?->country ?? $user->country ?? null,
                    'city' => $customer?->city ?? $user->city ?? null,
                ],
            ]);
        }

        IdentityMember::firstOrCreate(
            ['identity_id' => $identity->id, 'user_id' => $user->id],
            ['role' => 'owner', 'status' => 'active']
        );

        return $identity;
    }

    protected function generateAvailableUsername(string $seed): string
    {
        $base = Str::of($seed)
            ->lower()
            ->replaceMatches('/[^a-z0-9_]/', '_')
            ->trim('_')
            ->value();

        if ($base === '') {
            $base = 'duty_user';
        }

        $candidate = $base;
        $attempt = 0;

        while (User::where('username', $candidate)->exists()) {
            $attempt++;
            $suffix = '_' . Str::lower(Str::random(4));
            $maxBaseLength = max(1, 60 - strlen($suffix));
            $candidate = Str::limit($base, $maxBaseLength, '') . $suffix;
        }

        return $candidate;
    }
}
