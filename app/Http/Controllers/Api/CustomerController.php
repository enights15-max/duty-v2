<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Controllers\FrontEnd\CustomerController as FrontEndCustomerController;
use App\Models\Admin;
use App\Models\BasicSettings\Basic;
use App\Models\BasicSettings\MailTemplate;
use App\Models\BasicSettings\PageHeading;
use App\Models\Customer;
use App\Models\Event;
use App\Models\Event\Booking;
use App\Models\Event\EventContent;
use App\Models\Language;
use App\Models\Organizer;
use App\Models\OrganizerInfo;
use App\Models\User;
use App\Services\EventTicketRewardService;
use App\Services\OrganizerPublicProfileService;
use App\Support\PublicAssetUrl;
use App\Rules\MatchEmailRule;
use App\Traits\ApiFormatTrait;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\Rule;
use Illuminate\Support\Facades\Hash;

use Illuminate\Support\Str;
use Illuminate\Support\Facades\Validator;
use PHPMailer\PHPMailer\PHPMailer;
use Laravel\Socialite\Facades\Socialite;
use Kreait\Firebase\Factory;

class CustomerController extends Controller
{
  use ApiFormatTrait;

  private $admin_user_name;
  protected OrganizerPublicProfileService $organizerPublicProfileService;
  protected EventTicketRewardService $rewardService;

  public function __construct(
    OrganizerPublicProfileService $organizerPublicProfileService = null,
    EventTicketRewardService $rewardService = null
  ) {
    $admin = Admin::select('username')->first();
    $this->admin_user_name = $admin->username ?? '';
    $this->organizerPublicProfileService = $organizerPublicProfileService ?? app(OrganizerPublicProfileService::class);
    $this->rewardService = $rewardService ?? app(EventTicketRewardService::class);
  }

  private function downloadProfilePhoto($url)
  {
    if (empty($url))
      return null;

    try {
      $fileContents = @file_get_contents($url);
      if (!$fileContents)
        return null;

      $extension = 'jpg'; // Default to jpg for social/firebase URLs
      $fileName = uniqid() . '.' . $extension;
      $directory = public_path('assets/admin/img/customer-profile/');

      if (!file_exists($directory)) {
        @mkdir($directory, 0775, true);
      }

      file_put_contents($directory . $fileName, $fileContents);
      return $fileName;
    } catch (\Exception $e) {
      return null;
    }
  }

  private function generateAvailableUsername(string $seed): string
  {
    $base = strtolower(preg_replace('/[^a-z0-9_]/', '_', $seed));
    $base = trim($base, '_');
    if ($base === '') {
      $base = 'duty_user';
    }

    $candidate = $base;
    while (User::where('username', $candidate)->exists()) {
      $suffix = '_' . strtolower(Str::random(4));
      $maxBaseLength = max(1, 60 - strlen($suffix));
      $candidate = substr($base, 0, $maxBaseLength) . $suffix;
    }

    return $candidate;
  }

  private function firebaseAdminJsonPath(): ?string
  {
    $firebaseAdminJson = DB::table('basic_settings')
      ->where('uniqid', 12345)
      ->value('firebase_admin_json');

    if (empty($firebaseAdminJson)) {
      return null;
    }

    $path = public_path('assets/file/') . $firebaseAdminJson;

    return file_exists($path) ? $path : null;
  }

  private function hasUsableFirebaseAdminJson(?string $path): bool
  {
    if (empty($path) || !file_exists($path)) {
      return false;
    }

    $payload = json_decode(file_get_contents($path), true);
    if (!is_array($payload)) {
      return false;
    }

    $requiredKeys = ['project_id', 'private_key', 'client_email'];
    foreach ($requiredKeys as $key) {
      $value = $payload[$key] ?? null;
      if (empty($value) || str_contains((string) $value, 'REPLACE_WITH_')) {
        return false;
      }
    }

    return str_contains((string) $payload['private_key'], 'BEGIN PRIVATE KEY');
  }

  private function resolveFirebaseWebApiKey(): ?string
  {
    $envKey = env('FIREBASE_WEB_API_KEY');
    if (!empty($envKey)) {
      return $envKey;
    }

    $androidConfigPath = base_path('flutter/cliente_v2/android/app/google-services.json');
    if (file_exists($androidConfigPath)) {
      $androidConfig = json_decode(file_get_contents($androidConfigPath), true);
      $apiKey = $androidConfig['client'][0]['api_key'][0]['current_key'] ?? null;
      if (!empty($apiKey)) {
        return $apiKey;
      }
    }

    return null;
  }

  private function lookupFirebaseIdentityViaApi(string $idToken): array
  {
    $apiKey = $this->resolveFirebaseWebApiKey();
    if (empty($apiKey)) {
      throw new \RuntimeException('Firebase API key is not configured for token lookup.');
    }

    $response = Http::timeout(15)
      ->acceptJson()
      ->post(
        'https://identitytoolkit.googleapis.com/v1/accounts:lookup?key=' . $apiKey,
        ['idToken' => $idToken]
      );

    if (!$response->successful()) {
      $message = data_get($response->json(), 'error.message') ?: 'Unable to validate Firebase token.';
      throw new \RuntimeException($message);
    }

    $user = data_get($response->json(), 'users.0');
    if (!is_array($user)) {
      throw new \RuntimeException('Firebase token lookup returned no user payload.');
    }

    return [
      'uid' => $user['localId'] ?? null,
      'phone' => $user['phoneNumber'] ?? null,
      'photo_url' => $user['photoUrl'] ?? null,
    ];
  }

  private function resolveFirebaseIdentity(string $idToken): array
  {
    $adminJsonPath = $this->firebaseAdminJsonPath();

    if ($this->hasUsableFirebaseAdminJson($adminJsonPath)) {
      try {
        $factory = (new Factory)->withServiceAccount($adminJsonPath);
        $auth = $factory->createAuth();
        $verifiedIdToken = $auth->verifyIdToken($idToken);
        $uid = $verifiedIdToken->claims()->get('sub');
        $firebaseUser = $auth->getUser($uid);

        return [
          'uid' => $uid,
          'phone' => $firebaseUser->phoneNumber,
          'photo_url' => $firebaseUser->photoUrl,
        ];
      } catch (\Throwable $e) {
        \Log::warning('Firebase Admin verification failed, falling back to REST lookup: ' . $e->getMessage());
      }
    }

    return $this->lookupFirebaseIdentityViaApi($idToken);
  }

  private function resolveOrCreateCoreUser(Customer $customer): ?User
  {
    if (empty($customer->email)) {
      return null;
    }

    $seedUsername = $customer->username ?: ('duty_' . $customer->id);
    $user = User::where('email', $customer->email)->first();

    if (!$user) {
      $user = User::create([
        'first_name' => $customer->fname ?: 'User',
        'last_name' => $customer->lname ?: '',
        'username' => $this->generateAvailableUsername($seedUsername),
        'email' => $customer->email,
        'password' => $customer->password ?: Hash::make(Str::random(40)),
        'contact_number' => $customer->phone,
        'address' => $customer->address,
        'city' => $customer->city,
        'state' => $customer->state,
        'country' => $customer->country,
        'status' => (int) ($customer->status ?? 1) === 1 ? 1 : 0,
        'email_verified_at' => $customer->email_verified_at,
      ]);

      return $user;
    }

    $updates = [];
    if (empty($user->first_name) && !empty($customer->fname)) {
      $updates['first_name'] = $customer->fname;
    }
    if (empty($user->last_name) && !empty($customer->lname)) {
      $updates['last_name'] = $customer->lname;
    }
    if (empty($user->username)) {
      $updates['username'] = $this->generateAvailableUsername($seedUsername);
    }
    if (empty($user->contact_number) && !empty($customer->phone)) {
      $updates['contact_number'] = $customer->phone;
    }
    if (empty($user->address) && !empty($customer->address)) {
      $updates['address'] = $customer->address;
    }
    if (empty($user->city) && !empty($customer->city)) {
      $updates['city'] = $customer->city;
    }
    if (empty($user->state) && !empty($customer->state)) {
      $updates['state'] = $customer->state;
    }
    if (empty($user->country) && !empty($customer->country)) {
      $updates['country'] = $customer->country;
    }

    if (!empty($updates)) {
      $user->fill($updates);
      $user->save();
    }

    return $user;
  }

  private function ensurePersonalIdentity(User $user, Customer $customer): Identity
  {
    $identity = Identity::where('owner_user_id', $user->id)
      ->where('type', 'personal')
      ->first();

    if (!$identity) {
      $displayName = trim(($user->first_name ?? '') . ' ' . ($user->last_name ?? ''));
      if ($displayName === '') {
        $displayName = $user->username ?: ('User ' . $user->id);
      }

      $slug = Str::slug($displayName);
      $slugCount = Identity::where('slug', 'LIKE', "{$slug}%")->count();
      $slug = $slugCount ? "{$slug}-{$slugCount}" : $slug;

      $identity = Identity::create([
        'type' => 'personal',
        'status' => 'active',
        'owner_user_id' => $user->id,
        'display_name' => $displayName,
        'slug' => $slug,
        'meta' => [
          'display_name' => $displayName,
          'country' => $customer->country ?? $user->country ?? null,
          'city' => $customer->city ?? $user->city ?? null,
        ],
      ]);
    }

    IdentityMember::firstOrCreate(
      ['identity_id' => $identity->id, 'user_id' => $user->id],
      ['role' => 'owner', 'status' => 'active']
    );

    return $identity;
  }

  private function buildIdentityPayload(Customer $customer): array
  {
    $user = $this->resolveOrCreateCoreUser($customer);
    if (!$user) {
      return [
        'identities' => [],
        'default_identity_id' => null,
      ];
    }

    $this->ensurePersonalIdentity($user, $customer);

    $identities = $user->usersIdentities()->get()->map(function ($identity) use ($customer) {
      $meta = is_array($identity->meta) ? $identity->meta : [];
      $avatarUrl = match ($identity->type) {
        'artist' => PublicAssetUrl::url($meta['photo'] ?? $meta['image'] ?? null, 'assets/admin/img/artist'),
        'venue' => PublicAssetUrl::url($meta['photo'] ?? $meta['image'] ?? null, 'assets/admin/img/venue'),
        'organizer' => PublicAssetUrl::url($meta['photo'] ?? $meta['image'] ?? null, 'assets/admin/img/organizer-photo'),
        default => PublicAssetUrl::url($customer->photo, 'assets/admin/img/customer-profile'),
      };
      $coverPhotoUrl = match ($identity->type) {
        'artist' => PublicAssetUrl::url($meta['cover_photo'] ?? null, 'assets/admin/img/artist'),
        'venue' => PublicAssetUrl::url($meta['cover_photo'] ?? null, 'assets/admin/img/venue'),
        'organizer' => PublicAssetUrl::url($meta['cover_photo'] ?? null, 'assets/admin/img/organizer-cover'),
        default => null,
      };

      return [
        'id' => $identity->id,
        'type' => $identity->type,
        'display_name' => $identity->display_name,
        'slug' => $identity->slug,
        'status' => $identity->status,
        'role' => $identity->pivot->role,
        'avatar_url' => $avatarUrl,
        'cover_photo_url' => $coverPhotoUrl,
        'meta' => $meta,
      ];
    })->values()->all();

    $defaultIdentityId = null;
    foreach ($identities as $identity) {
      if (($identity['type'] ?? null) === 'personal') {
        $defaultIdentityId = $identity['id'] ?? null;
        break;
      }
    }

    return [
      'identities' => $identities,
      'default_identity_id' => $defaultIdentityId,
    ];
  }

  private function resolveBookingOrganizerTarget(Booking $booking, ?Event $event, ?int $languageId = null): ?array
  {
    return $this->organizerPublicProfileService->resolveFromOwnership(
      $booking->organizer_identity_id ?? $event?->owner_identity_id,
      $booking->organizer_id,
      $languageId
    );
  }

  private function resolveBookingOrganizerName(Booking $booking, ?Event $event, ?int $languageId = null): string
  {
    $target = $this->resolveBookingOrganizerTarget($booking, $event, $languageId);

    return $target['name'] ?? '';
  }

  private function resolveBookingOrganizerPayload(Booking $booking, ?Event $event, ?int $languageId = null): array
  {
    $payload = $this->organizerPublicProfileService->organizerPayloadForEvent(
      $booking->organizer_identity_id ?? $event?->owner_identity_id,
      $booking->organizer_id,
      $languageId
    );

    if ($payload) {
      return $payload;
    }

    $admin = Admin::first();

    return $this->format_organizer_data($admin, 'admin');
  }

  /* ******************************
   * Show login page
   * ******************************/
  public function login(Request $request)
  {
    //get language
    $locale = $request->header('Accept-Language');
    $language = $locale ? Language::where('code', $locale)->first()
      : Language::where('is_default', 1)->first();

    $data['page_title'] = PageHeading::where('language_id', $language->id)->pluck('customer_login_page_title')->first();
    $basic_settings = Basic::query()->select('google_recaptcha_status', 'google_recaptcha_site_key', 'google_recaptcha_secret_key', 'facebook_login_status', 'facebook_app_id', 'facebook_app_secret', 'google_login_status', 'google_client_id', 'google_client_secret', 'breadcrumb')->first();
    $basic_settings['breadcrumb'] = asset('assets/admin/img/' . $basic_settings->breadcrumb);

    $data['bs'] = $basic_settings;
    return response()->json([
      'success' => true,
      'data' => $data
    ]);
  }

  /* ********************************
   * Submit login for authentication
   * ********************************/
  public function loginSubmit(Request $request)
  {
    $rules = [
      'username' => 'required',
      'password' => 'required'
    ];

    $info = Basic::select('google_recaptcha_status')->first();
    if ($info->google_recaptcha_status == 1) {
      $rules['g-recaptcha-response'] = 'required|captcha';
    }

    $messages = [];
    if ($info->google_recaptcha_status == 1) {
      $messages['g-recaptcha-response.required'] = 'Please verify that you are not a robot.';
      $messages['g-recaptcha-response.captcha'] = 'Captcha error! try again later or contact site admin.';
    }

    $validator = Validator::make($request->all(), $rules, $messages);
    if ($validator->fails()) {
      return response()->json([
        'status' => 'validation_error',
        'errors' => $validator->errors()
      ], 422);
    }

    // Attempt login manually using credentials
    $customer = Customer::where('username', $request->username)->first();

    if (!$customer || !Hash::check($request->password, $customer->password)) {
      return response()->json([
        'status' => 'error',
        'message' => 'Invalid credentials'
      ], 401);
    }

    // Removing forced email and phone verification requirements from login
    // Users can now log in without verified emails or phones.
    // Verification is enforced at the checkout step.

    // Delete ALL old tokens and create new one (prevents stale token buildup)
    $customer->tokens()->delete();
    $token = $customer->createToken($request->device_name ?? 'mobile')->plainTextToken;

    // Add full photo URL if exists
    if (!empty($customer->photo)) {
      $customer->photo = asset('assets/admin/img/customer-profile/' . $customer->photo);
    }

    // Get identities for the user
    $user = \App\Models\User::where('email', $customer->email)->first();
    $identities = [];
    $defaultIdentityId = null;

    if ($user) {
      $identities = $user->usersIdentities()->get()->map(function ($identity) {
        return [
          'id' => $identity->id,
          'type' => $identity->type,
          'display_name' => $identity->display_name,
          'status' => $identity->status,
          'role' => $identity->pivot->role,
        ];
      });

      $personalIdentity = $identities->where('type', 'personal')->first();
      $defaultIdentityId = $personalIdentity ? $personalIdentity['id'] : null;
    }

    return response()->json([
      'status' => 'success',
      'customer' => $customer,
      'token' => $token,
      'identities' => $identities,
      'default_identity_id' => $defaultIdentityId
    ], 200);
  }

  /**
   * Handle Login/Signup via Firebase verified token
   */
  public function firebaseLogin(Request $request)
  {
    $rules = [
      'idToken' => 'required',
    ];

    $validator = Validator::make($request->all(), $rules);
    if ($validator->fails()) {
      return response()->json(['status' => 'validation_error', 'errors' => $validator->errors()], 422);
    }

    try {
      // 1. Initialize Firebase
      $firebase_admin_json = DB::table('basic_settings')->where('uniqid', 12345)->value('firebase_admin_json');
      $factory = (new Factory)->withServiceAccount(public_path('assets/file/') . $firebase_admin_json);
      $auth = $factory->createAuth();

      // 2. Verify idToken
      $verifiedIdToken = $auth->verifyIdToken($request->idToken);
      $uid = $verifiedIdToken->claims()->get('sub');
      $firebaseUser = $auth->getUser($uid);
      $phone = $firebaseUser->phoneNumber;

      if (!$phone) {
        return response()->json(['status' => 'error', 'message' => 'Phone number not found in token'], 400);
      }

      // 3. Find Customer
      $customer = Customer::where('firebase_uid', $uid)
        ->orWhere('phone', $phone)
        ->first();

      if (!$customer && strlen($phone) > 8) {
        // Fallback: Check if the database phone ends with the last 10 digits of the Firebase phone
        // This handles cases where the DB stores '8493538839' but Firebase provides '+18493538839'
        $shortPhone = substr($phone, -10);
        $customer = Customer::where('phone', 'like', '%' . $shortPhone)->first();
      }
      if (!$customer && strlen($phone) > 8) {
        // Fallback: just strip the '+' sign
        $noPlus = ltrim($phone, '+');
        $customer = Customer::where('phone', $noPlus)->first();
      }

      if (!$customer) {
        return response()->json([
          'status' => 'user_not_found',
          'message' => 'No user found with this phone number',
          'uid' => $uid,
          'phone' => $phone
        ], 200);
      }

      // Update firebase_uid and phone_verified_at if needed
      $updates = ['phone_verified_at' => now()];
      if (!$customer->firebase_uid) {
        $updates['firebase_uid'] = $uid;
      }
      $customer->update($updates);

      if ($customer->status == 0) {
        return response()->json(['status' => 'error', 'message' => 'Account deactivated'], 403);
      }

      if (empty($customer->email)) {
        // Issue a temporary token to allow them to setup their email
        $customer->tokens()->where('name', 'customer-email-setup')->delete();
        $token = $customer->createToken('customer-email-setup')->plainTextToken;

        return response()->json([
          'status' => 'needs_email_setup',
          'message' => 'Please provide an email to complete your profile.',
          'customer' => $customer,
          'setup_token' => $token
        ], 200);
      }

      // 4. Issue Sanctum Token
      $customer->tokens()->delete();
      $token = $customer->createToken($request->device_name ?? 'mobile')->plainTextToken;

      // Get identities for the user
      $user = \App\Models\User::where('email', $customer->email)->first();
      $identities = [];
      $defaultIdentityId = null;

      if ($user) {
        $identities = $user->usersIdentities()->get()->map(function ($identity) {
          return [
            'id' => $identity->id,
            'type' => $identity->type,
            'display_name' => $identity->display_name,
            'status' => $identity->status,
            'role' => $identity->pivot->role,
          ];
        });

        $personalIdentity = $identities->where('type', 'personal')->first();
        $defaultIdentityId = $personalIdentity ? $personalIdentity['id'] : null;
      }

      return response()->json([
        'status' => 'success',
        'customer' => $customer,
        'token' => $token,
        'identities' => $identities,
        'default_identity_id' => $defaultIdentityId
      ], 200);

    } catch (\Exception $e) {
      return response()->json(['status' => 'error', 'message' => 'Authentication failed: ' . $e->getMessage()], 401);
    }
  }

  /**
   * Register new user via Firebase
   */
  public function firebaseSignup(Request $request)
  {
    $rules = [
      'idToken' => 'required',
      'email' => 'required|email|unique:customers',
      'fname' => 'required',
      'lname' => 'required',
    ];

    $validator = Validator::make($request->all(), $rules);
    if ($validator->fails()) {
      return response()->json(['status' => 'validation_error', 'errors' => $validator->errors()], 422);
    }

    try {
      // 1. Initialize Firebase
      $firebase_admin_json = DB::table('basic_settings')->where('uniqid', 12345)->value('firebase_admin_json');
      $factory = (new Factory)->withServiceAccount(public_path('assets/file/') . $firebase_admin_json);
      $auth = $factory->createAuth();

      // 2. Verify idToken
      $verifiedIdToken = $auth->verifyIdToken($request->idToken);
      $uid = $verifiedIdToken->claims()->get('sub');
      $firebaseUser = $auth->getUser($uid);
      $phone = $firebaseUser->phoneNumber;

      if (!$phone) {
        return response()->json(['status' => 'error', 'message' => 'Phone number not found in token'], 400);
      }

      // 3. Check if phone already exists
      $customer = Customer::where('firebase_uid', $uid)
        ->orWhere('phone', $phone)
        ->first();

      if (!$customer && strlen($phone) > 8) {
        $shortPhone = substr($phone, -10);
        $customer = Customer::where('phone', 'like', '%' . $shortPhone)->first();
      }
      if (!$customer && strlen($phone) > 8) {
        $noPlus = ltrim($phone, '+');
        $customer = Customer::where('phone', $noPlus)->first();
      }

      if (!$customer) {
        // Create Customer
        $customer = Customer::create([
          'fname' => $request->fname,
          'lname' => $request->lname,
          'email' => $request->email,
          'username' => 'user_' . Str::random(8),
          'phone' => $phone,
          'firebase_uid' => $uid,
          'status' => 1,
          'email_verified_at' => now(),
          'phone_verified_at' => now(),
        ]);
      } else {
        // Customer already exists (maybe they changed their email or signed up again)
        // Ensure firebase_uid is updated
        if (!$customer->firebase_uid) {
          $customer->update(['firebase_uid' => $uid, 'phone_verified_at' => now()]);
        }
      }

      // 4. Issue Sanctum Token
      $token = $customer->createToken($request->device_name ?? 'mobile')->plainTextToken;

      // Get identities for the user
      $user = \App\Models\User::where('email', $customer->email)->first();
      $identities = [];
      $defaultIdentityId = null;

      if ($user) {
        $identities = $user->usersIdentities()->get()->map(function ($identity) {
          return [
            'id' => $identity->id,
            'type' => $identity->type,
            'display_name' => $identity->display_name,
            'status' => $identity->status,
            'role' => $identity->pivot->role,
          ];
        });

        $personalIdentity = $identities->where('type', 'personal')->first();
        $defaultIdentityId = $personalIdentity ? $personalIdentity['id'] : null;
      }

      return response()->json([
        'status' => 'success',
        'customer' => $customer,
        'token' => $token,
        'identities' => $identities,
        'default_identity_id' => $defaultIdentityId
      ], 200);

    } catch (\Exception $e) {
      return response()->json(['status' => 'error', 'message' => 'Signup failed: ' . $e->getMessage()], 401);
    }
  }

  /**
   * Complete Email Setup after Phone Login
   */
  public function setupEmail(Request $request)
  {
    $customer = Auth::guard('sanctum')->user();
    if (!$customer) {
      return response()->json(['status' => 'error', 'message' => 'Unauthenticated.'], 401);
    }

    $rules = [
      'email' => 'required|email|unique:customers',
      'fname' => 'required',
      'lname' => 'required',
    ];

    $validator = Validator::make($request->all(), $rules);
    if ($validator->fails()) {
      return response()->json(['status' => 'validation_error', 'errors' => $validator->errors()], 422);
    }

    $customer->update([
      'email' => $request->email,
      'fname' => $request->fname,
      'lname' => $request->lname,
    ]);

    // Issue the real token now that setup is complete
    $customer->tokens()->where('name', 'customer-email-setup')->delete();
    $token = $customer->createToken($request->device_name ?? 'mobile')->plainTextToken;

    return response()->json([
      'status' => 'success',
      'customer' => $customer,
      'token' => $token,
      'identities' => [],
      'default_identity_id' => null
    ], 200);
  }

  /**
   * Complete Phone Verification Link after Email Login
   */
  public function verifyPhoneLink(Request $request)
  {
    $customer = Auth::guard('sanctum')->user();
    if (!$customer) {
      return response()->json(['status' => 'error', 'message' => 'Unauthenticated.'], 401);
    }

    $rules = [
      'idToken' => 'required',
    ];

    $validator = Validator::make($request->all(), $rules);
    if ($validator->fails()) {
      return response()->json(['status' => 'validation_error', 'errors' => $validator->errors()], 422);
    }

    try {
      // 1. Initialize Firebase
      $firebase_admin_json = DB::table('basic_settings')->where('uniqid', 12345)->value('firebase_admin_json');
      $factory = (new Factory)->withServiceAccount(public_path('assets/file/') . $firebase_admin_json);
      $auth = $factory->createAuth();

      // 2. Verify idToken
      $verifiedIdToken = $auth->verifyIdToken($request->idToken);
      $uid = $verifiedIdToken->claims()->get('sub');
      $firebaseUser = $auth->getUser($uid);
      $phone = $firebaseUser->phoneNumber;

      if (!$phone) {
        return response()->json(['status' => 'error', 'message' => 'Phone number not found in token'], 400);
      }

      // 3. Make sure phone isn't already used by someone else
      $existingPhoneUser = Customer::where('phone', $phone)->where('id', '!=', $customer->id)->first();
      if ($existingPhoneUser) {
        return response()->json(['status' => 'error', 'message' => 'This phone number is already linked to another account.'], 400);
      }

      // 4. Update customer
      $customer->update([
        'phone' => $phone,
        'firebase_uid' => $uid,
        'phone_verified_at' => now(),
      ]);

      // 5. Issue real Sanctum token
      $customer->tokens()->where('name', 'customer-phone-verification')->delete();
      $customer->tokens()->where('name', 'customer-login')->delete();
      $token = $customer->createToken($request->device_name ?? 'mobile')->plainTextToken;

    } catch (\Exception $e) {
      \Log::error('verifyPhoneLink exception: ' . $e->getMessage());
      return response()->json(['status' => 'error', 'message' => 'Phone verification failed: ' . $e->getMessage()], 401);
    }
  }

  /**
   * Check if Email or Phone Number or Username is available for registration
   */
  public function checkAvailability(Request $request)
  {
    $rules = [];
    if ($request->has('email')) {
      $rules['email'] = 'email';
    }
    // We don't enforce format here for phone or username, just uniqueness check

    $validator = Validator::make($request->all(), $rules);
    if ($validator->fails()) {
      return response()->json(['status' => 'validation_error', 'errors' => $validator->errors()], 422);
    }

    $response = ['status' => 'success'];

    if ($request->has('username')) {
      $usernameExists = Customer::where('username', $request->username)->exists();
      $response['is_username_available'] = !$usernameExists;
    }

    if ($request->has('email')) {
      $emailExists = Customer::where('email', $request->email)->exists();
      $response['is_email_available'] = !$emailExists;
    }

    if ($request->has('phone')) {
      $phoneExists = Customer::where('phone', $request->phone)->exists();
      $response['is_phone_available'] = !$phoneExists;
    }

    return response()->json($response, 200);
  }

  /* ******************************
   * Account Verification Endpoints
   * ******************************/

  public function sendEmailVerification(Request $request)
  {
    $customer = Auth::guard('sanctum')->user();
    if (!$customer) {
      return response()->json(['status' => 'error', 'message' => 'Unauthenticated.'], 401);
    }

    if ($customer->email_verified_at) {
      return response()->json(['status' => 'error', 'message' => 'Email is already verified.'], 400);
    }

    try {
      // Generate a 6-digit OTP
      $otp = rand(100000, 999999);

      // Store in password_resets for temporary holding (or custom table, but password_resets works)
      \DB::table('password_resets')->updateOrInsert(
        ['email' => $customer->email],
        ['token' => $otp, 'created_at' => now()]
      );

      // Send basic email (using Mail facade for simplicity given the environment)
      \Mail::raw("Your Duty verification code is: $otp", function ($message) use ($customer) {
        $message->to($customer->email)
          ->subject('Verify your email address');
      });

      return response()->json(['status' => 'success', 'message' => 'Verification code sent to email.']);
    } catch (\Exception $e) {
      \Log::error('sendEmailVerification error: ' . $e->getMessage());
      return response()->json(['status' => 'error', 'message' => 'Could not send verification email.'], 500);
    }
  }

  public function verifyEmailOtp(Request $request)
  {
    $customer = Auth::guard('sanctum')->user();
    if (!$customer) {
      return response()->json(['status' => 'error', 'message' => 'Unauthenticated.'], 401);
    }

    $request->validate([
      'otp' => 'required|numeric|digits:6'
    ]);

    $record = \DB::table('password_resets')
      ->where('email', $customer->email)
      ->first();

    if (!$record || $record->token !== $request->otp) {
      return response()->json(['status' => 'error', 'message' => 'Invalid or expired verification code.'], 400);
    }

    // Mark as verified
    $customer->update(['email_verified_at' => now()]);

    // Cleanup
    \DB::table('password_resets')->where('email', $customer->email)->delete();

    return response()->json(['status' => 'success', 'message' => 'Email verified successfully.']);
  }

  /* ******************************
   * forget password
   * ******************************/

  public function forget_mail(Request $request)
  {
    $rules = [
      'email' => [
        'required',
        'email:rfc,dns',
        new MatchEmailRule('customers')
      ]
    ];

    $validator = Validator::make($request->all(), $rules);

    if ($validator->fails()) {
      return response()->json([
        'success' => false,
        'errors' => $validator->errors()
      ], 422);
    }

    $user = Customer::where('email', $request->email)->first();
    $token = str_pad(random_int(0, 999999), 6, '0', STR_PAD_LEFT);
    DB::table('password_resets')->updateOrInsert(
      ['email' => $user->email],
      ['token' => Hash::make($token), 'created_at' => now()]
    );


    // first, get the mail template information from db
    $mailTemplate = MailTemplate::where('mail_type', 'reset_password')->first();
    $mailSubject = $mailTemplate->mail_subject;
    $mailBody = $mailTemplate->mail_body;

    // second, send a password reset link to user via email
    $info = DB::table('basic_settings')
      ->select('website_title', 'smtp_status', 'smtp_host', 'smtp_port', 'encryption', 'smtp_username', 'smtp_password', 'from_mail', 'from_name')
      ->first();

    $name = $user->name;
    $link = __("Your OTP: ") . $token;

    $mailBody = str_replace('{customer_name}', $name, $mailBody);
    $mailBody = str_replace('{password_reset_link}', $link, $mailBody);
    $mailBody = str_replace('{website_title}', $info->website_title, $mailBody);

    // initialize a new mail
    $mail = new PHPMailer(true);
    $mail->CharSet = 'UTF-8';
    $mail->Encoding = 'base64';

    // if smtp status == 1, then set some value for PHPMailer
    if ($info->smtp_status == 1) {
      $mail->isSMTP();
      $mail->Host = $info->smtp_host;
      $mail->SMTPAuth = true;
      $mail->Username = $info->smtp_username;
      $mail->Password = $info->smtp_password;

      if ($info->encryption == 'TLS') {
        $mail->SMTPSecure = PHPMailer::ENCRYPTION_STARTTLS;
      }

      $mail->Port = $info->smtp_port;
    }

    // finally add other informations and send the mail
    try {
      $mail->setFrom($info->from_mail, $info->from_name);
      $mail->addAddress($request->email);

      $mail->isHTML(true);
      $mail->Subject = $mailSubject;
      $mail->Body = $mailBody;
      $mail->send();

      $status = true;
      $messages = 'A mail has been sent to your email address.';
    } catch (\Exception $e) {
      $status = false;
      $messages = 'Mail could not be sent!';
    }


    return response()->json([
      'success' => $status ?? false,
      'userEmail' => $user->email,
      'message' => $messages ?? "something went wrong!"
    ]);
  }

  /* ******************************
   * reset password
   * ******************************/


  public function reset_password_submit(Request $request)
  {
    $rules = [
      'email' => 'required|email',
      'code' => 'required',
      'new_password' => 'required|confirmed',
      'new_password_confirmation' => 'required'
    ];

    $validator = Validator::make($request->all(), $rules);

    if ($validator->fails()) {
      return response()->json([
        'success' => false,
        'errors' => $validator->errors()
      ], 422);
    }

    // find the reset record by email
    $record = DB::table('password_resets')
      ->where('email', $request->email)
      ->first();

    if (!$record) {
      return response()->json([
        'status' => 'error',
        'message' => __('Invalid email or token')
      ], 400);
    }

    // check the token
    if (!Hash::check($request->code, $record->token)) {
      return response()->json([
        'status' => 'error',
        'message' => __('Invalid email or expired code')
      ], 400);
    }

    // update password
    Customer::where('email', $request->email)->update([
      'password' => Hash::make($request->new_password),
    ]);

    // delete reset record
    DB::table('password_resets')->where('email', $request->email)->delete();

    return response()->json([
      'status' => 'success',
      'message' => __('Password updated successfully')
    ]);
  }


  public function authentication_fail()
  {
    return response()->json([
      'success' => false,
      'message' => 'Unauthenticated.'
    ], 401);
  }

  /* ******************************
   * Show customer signup page
   * ******************************/
  public function signup(Request $request)
  {
    //get language
    $locale = $request->header('Accept-Language');
    $language = $locale ? Language::where('code', $locale)->first()
      : Language::where('is_default', 1)->first();

    $data['page_title'] = PageHeading::where('language_id', $language->id)->pluck('customer_signup_page_title')->first();
    $basic_settings = Basic::query()->select('google_recaptcha_status', 'google_recaptcha_site_key', 'google_recaptcha_secret_key', 'facebook_login_status', 'facebook_app_id', 'facebook_app_secret', 'google_login_status', 'google_client_id', 'google_client_secret', 'breadcrumb')->first();
    $basic_settings['breadcrumb'] = asset('assets/admin/img/' . $basic_settings->breadcrumb);

    $data['bs'] = $basic_settings;
    return response()->json([
      'success' => true,
      'data' => $data
    ]);
  }

  /* **************************************
   * Request for sign up as a new customer
   * **************************************/
  public function signupSubmit(Request $request)
  {
    //validation rules
    $rules = [
      'fname' => 'required',
      'lname' => 'required',
      'email' => 'required|email|unique:customers',
      'phone' => 'required|unique:customers',
      'username' => [
        'required',
        'alpha_dash',
        "not_in:$this->admin_user_name",
        Rule::unique('customers', 'username')
      ],
      'password' => 'required|confirmed',
      'password_confirmation' => 'required'
    ];

    $info = Basic::select('google_recaptcha_status')->first();
    if ($info->google_recaptcha_status == 1) {
      $rules['g-recaptcha-response'] = 'required|captcha';
    }

    $messages = [];

    if ($info->google_recaptcha_status == 1) {
      $messages['g-recaptcha-response.required'] = __('Please verify that you are not a robot.');
      $messages['g-recaptcha-response.captcha'] = __('Captcha error! try again later or contact site admin.');
    }

    $validator = Validator::make($request->all(), $rules, $messages);
    if ($validator->fails()) {
      return response()->json([
        'success' => false,
        'errors' => $validator->errors()
      ], 422);
    }
    //validation end

    $in = $request->all();
    $in['password'] = Hash::make($request->password);
    // first, generate a random string
    $randStr = Str::random(20);

    // second, generate a token
    $token = md5($randStr . $request->fname . $request->email);

    $in['verification_token'] = $token;

    // send a mail to user for verify his/her email address
    $customer_controller = new FrontEndCustomerController();
    $customer_controller->sendVerificationMail($request, $token);
    $customer = Customer::create($in);

    // Generate Sanctum token for auto-login
    $authToken = $customer->createToken($request->device_name ?? 'mobile')->plainTextToken;

    return response()->json([
      'success' => true,
      'message' => __('Registration successful. You are now logged in.'),
      'token' => $authToken,
      'data' => $customer
    ]);
  }

  /* ****************************
   * Customer Dashboard
   * ****************************/
  public function dashboard(Request $request)
  {
    $customer = Auth::guard('sanctum')->user();
    if (!$customer) {
      return response()->json([
        'success' => false,
        'message' => 'Unauthenticated.'
      ], 401);
    }

    $locale = $request->header('Accept-Language');
    $language = $locale ? Language::where('code', $locale)->first()
      : Language::where('is_default', 1)->first();

    $data['page_title'] = PageHeading::where('language_id', $language->id)->pluck('customer_dashboard_page_title')->first();

    $data['authUser'] = $customer;
    $bookings = Booking::where('customer_id', $customer->id)
      ->OrderBy('id', 'desc')
      ->limit(10)
      ->get();

    $bookingsData = $bookings->map(function ($booking) use ($language) {
      $event = Event::find($booking->event_id);
      $event_title = EventContent::where([
        ['event_id', $booking->event_id],
        ['language_id', $language->id]
      ])->pluck('title')->first();

      $thumbnail = $event?->thumbnail;
      $organizerName = $this->resolveBookingOrganizerName($booking, $event, $language->id);

      $booking->event_title = $event_title;
      $booking->thumbnail = asset('assets/admin/img/event/thumbnail/' . $thumbnail);
      $booking->organizer_name = $organizerName;
      return $booking;
    });

    $data['bookings'] = $bookingsData;

    return response()->json([
      'success' => true,
      'data' => $data,
    ]);
  }

  /* ****************************
   * Customer bookings
   * ****************************/
  public function bookings(Request $request)
  {
    // DEBUG: Log what the server receives
    \Log::info('BOOKINGS DEBUG', [
      'auth_header' => $request->header('Authorization'),
      'bearer_token' => $request->bearerToken(),
      'sanctum_user' => Auth::guard('sanctum')->user() ? Auth::guard('sanctum')->user()->id : 'NULL',
    ]);

    // Authenticate customer
    $customer = Auth::guard('sanctum')->user();
    if (!$customer) {
      return response()->json([
        'success' => false,
        'message' => 'Unauthenticated.'
      ], 401);
    }

    //  Detect language
    $locale = $request->header('Accept-Language');
    $language = $locale
      ? Language::where('code', $locale)->first()
      : Language::where('is_default', 1)->first();

    //  Page title
    $data['page_title'] = PageHeading::where('language_id', $language->id)
      ->pluck('customer_booking_page_title')
      ->first();

    //  Get bookings
    $bookings = Booking::where('customer_id', $customer->id)
      ->orderBy('id', 'desc')
      ->get();

    //  Transform collection
    $bookingsData = $bookings->map(function ($booking) use ($language) {
      $event = Event::find($booking->event_id);
      $event_title = EventContent::where([
        ['event_id', $booking->event_id],
        ['language_id', $language->id]
      ])->pluck('title')->first();

      $thumbnail = $event?->thumbnail;
      $organizerName = $this->resolveBookingOrganizerName($booking, $event, $language->id);

      $booking->event_title = $event_title;
      $booking->thumbnail = asset('assets/admin/img/event/thumbnail/' . $thumbnail);
      $booking->organizer_name = $organizerName;
      $booking->invoice = !empty($booking->invoice) ? asset('assets/admin/file/invoices/' . $booking->invoice) : null;
      return $booking;
    });

    //  Assign transformed bookings to data
    $data['bookings'] = $bookingsData->values();

    //  Return response
    return response()->json([
      'success' => true,
      'data' => $data,
    ]);
  }

  /* ****************************
   * Customer booking details
   * ****************************/
  public function booking_details(Request $request)
  {
    // Authenticate customer
    $customer = Auth::guard('sanctum')->user();
    if (!$customer) {
      return response()->json([
        'success' => false,
        'message' => 'Unauthenticated.'
      ], 401);
    }

    //  Get booking
    $booking = Booking::where([['customer_id', $customer->id], ['id', $request->booking_id]])->first();

    if (!$booking) {
      return response()->json([
        'success' => false,
        'message' => 'booking not found'
      ], 401);
    }

    //  Detect language
    $locale = $request->header('Accept-Language');
    $language = $locale
      ? Language::where('code', $locale)->first()
      : Language::where('is_default', 1)->first();

    //  Page title
    $data['page_title'] = PageHeading::where('language_id', $language->id)
      ->pluck('customer_booking_details_page_title')
      ->first();


    //calculation total_paid
    $booking->total_paid = number_format($booking->price + $booking->tax, 2);
    // attached invoice with path
    $booking->invoice = !empty($booking->invoice) ? asset('assets/admin/file/invoices/' . $booking->invoice) : null;

    // Load venue info
    $event = Event::with('venue')->find($booking->event_id);
    $thumbnail = $event?->thumbnail;
    $organizerName = $this->resolveBookingOrganizerName($booking, $event, $language->id);

    $booking->event_title = $event?->title ?? $booking->event_title ?? null;
    $booking->thumbnail = $thumbnail ? asset('assets/admin/img/event/thumbnail/' . $thumbnail) : null;
    $booking->organizer_name = $organizerName;
    $booking->venue_name = $event && $event->venue ? $event->venue->name : ($event?->venue_name_snapshot ?: null);
    $booking->event_end_date = $event ? $event->end_date_time : null;

    $rewards = $this->rewardService->getRewardsForBooking($booking);
    $booking->setAttribute('rewards', $rewards->values());

    $data['booking'] = $booking;

    $data['organizer'] = $this->resolveBookingOrganizerPayload($booking, $event, $language->id);

    // Rewards
    $data['rewards'] = $rewards->values();

    //  Return response
    return response()->json([
      'success' => true,
      'data' => $data,
    ]);
  }

  /* **************************
   * Edit profile
   * **************************/
  public function edit_profile(Request $request)
  {
    // Authenticate customer
    $customer = Auth::guard('sanctum')->user();

    if (!$customer) {
      return response()->json([
        'success' => false,
        'message' => 'Unauthenticated.'
      ], 401);
    }

    $customer_info = $customer;
    $customer_info->photo = asset('assets/admin/img/customer-profile/' . $customer_info->photo);

    $data['customer_info'] = $customer_info;

    return response()->json([
      'success' => true,
      'data' => $data,
    ]);
  }


  /* **************************
   * update profile
   * **************************/
  public function update_profile(Request $request)
  {
    // Authenticate customer
    $customer = Auth::guard('sanctum')->user();
    if (!$customer) {
      return response()->json([
        'success' => false,
        'message' => 'Unauthenticated.'
      ], 401);
    }

    $rules = [
      'fname' => 'required',
      'lname' => 'required',
      'email' => [
        'required',
        'email',
        Rule::unique('customers', 'email')->ignore($customer->id)
      ],
      'username' => [
        'required',
        'alpha_dash',
        "not_in:$this->admin_user_name",
        Rule::unique('customers', 'username')->ignore($customer->id)
      ],
      'date_of_birth' => 'nullable|date|before:today',
      'photo' => $request->hasFile('photo') ? 'image|mimes:jpg,jpeg,png|max:10240' : ''
    ];

    $messages = [
      'fname.required' => 'The first name field is required.',
      'lname.required' => 'The last name field is required.',
    ];

    $validator = Validator::make($request->all(), $rules, $messages);
    if ($validator->fails()) {
      return response()->json([
        'success' => false,
        'errors' => $validator->errors()
      ], 422);
    }

    $in = $request->all();
    $file = $request->file('photo');
    if ($file && $file->isValid()) {
      $extension = $file->getClientOriginalExtension();
      $directory = public_path('assets/admin/img/customer-profile/');
      $fileName = uniqid() . '.' . $extension;
      @mkdir($directory, 0775, true);
      $file->move($directory, $fileName);
      $in['photo'] = $fileName;
    }
    $id = $customer->id;
    Customer::find($id)->update($in);

    $customer_info = Customer::find($id);
    $customer_payload = $customer_info ? $customer_info->toArray() : [];
    $customer_payload['photo_url'] = PublicAssetUrl::url(
      $customer_info?->photo,
      'assets/admin/img/customer-profile'
    );

    $data['customer_info'] = $customer_payload;

    return response()->json([
      'success' => true,
      'data' => $data,
      'message' => __('Updated Successfully')
    ]);
  }

  public function updated_password(Request $request)
  {
    // Authenticate customer
    $customer = Auth::guard('sanctum')->user();
    if (!$customer) {
      return response()->json([
        'success' => false,
        'message' => 'Unauthenticated.'
      ], 401);
    }
    $rules = [
      'current_password' => 'required',
      'new_password' => 'required|confirmed',
      'new_password_confirmation' => 'required'
    ];

    $messages = [
      'new_password.confirmed' => __('Password confirmation does not match.'),
      'new_password_confirmation.required' => __('The confirm new password field is required.')
    ];

    $validator = Validator::make($request->all(), $rules, $messages);
    if ($validator->fails()) {
      return response()->json([
        'success' => false,
        'errors' => $validator->errors()
      ], 422);
    }

    $customer = Customer::where('id', $customer->id)->firstOrFail();
    if (!Hash::check($request->current_password, $customer->password)) {
      return response()->json([
        'success' => false,
        'errors' => ['current_password' => ['Current password is incorrect.']]
      ], 422);
    }

    $customer->update([
      'password' => Hash::make($request->new_password)
    ]);

    return response()->json([
      'status' => true,
      'message' => 'Password updated successfully'
    ]);
  }

  /* **************************
   * Logout customer
   * **************************/
  public function logoutSubmit(Request $request)
  {
    $request->user()->currentAccessToken()->delete();
    return response()->json([
      'status' => 'success',
      'message' => 'Logout successfully'
    ], 200);
  }
  /*
   * Login facebook
   */
  public function handleFacebookCallback()
  {
    return $this->authenticationViaProvider('facebook');
  }

  public function facebookRedirect()
  {
    return Socialite::driver('facebook')->redirect();
  }
  /*
   * Handle Google Login
   */
  public function handleGoogleCallback(Request $request)
  {
    return $this->authenticationViaProvider('google');
  }

  public function googleRedirect()
  {
    return Socialite::driver('google')->redirect();
  }

  public function authenticationViaProvider($driver)
  {
    try {

      $user = Socialite::driver($driver)->user();
      $isUser = Customer::where('provider_id', $user->getId())->first();

      if ($isUser) {
        Auth::guard('sanctum')->login($isUser);
        return response()->json([
          'status' => true,
          'message' => __('Login Successfully!'),
          'redirect_url' => route('api.customers.dashboard')
        ]);
      } else {
        //get and insert image
        $avatar = $user->getAvatar();
        $fileContents = file_get_contents($avatar);

        $avatarName = $user->getId() . '.jpg';
        $path = public_path('assets/admin/img/customer-profile/');

        file_put_contents($path . $avatarName, $fileContents);

        $createUser = Customer::create([
          'photo' => $avatarName,
          'fname' => $user->getName(),
          'email' => $user->getEmail(),
          'username' => $user->getId(),
          'provider' => $driver,
          'provider_id' => $user->getId(),
          'password' => encrypt('123456'),
          'email_verified_at' => now()
        ]);

        Auth::guard('sanctum')->login($createUser);
        return response()->json([
          'status' => true,
          'message' => __('Login Successfully!'),
          'redirect_url' => route('api.customers.dashboard')
        ]);
      }
    } catch (\Exception $e) {
      return response()->json([
        'status' => false,
        'message' => $e->getMessage(),
        'redirect_url' => null,
      ]);
    }
  }

}
