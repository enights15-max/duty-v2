<?php

use App\Http\Controllers\Api\ChatController;
use App\Http\Controllers\Api\CustomerController;
use App\Http\Controllers\Api\SearchController;
use App\Http\Controllers\Api\DiscoverController;
use App\Http\Controllers\Api\HomeController;
use App\Http\Controllers\Api\ArtistController;
use App\Http\Controllers\Api\ArtistTipController;
use App\Http\Controllers\Api\EventController;
use App\Http\Controllers\Api\EventWaitlistController;
use App\Http\Controllers\Api\FcmTokenController;
use App\Http\Controllers\Api\LanguageController;
use App\Http\Controllers\Api\LoyaltyController;
use App\Http\Controllers\Api\OrganizerController;
use App\Http\Controllers\Api\ProductOrderController;
use App\Http\Controllers\Api\ProfessionalEventController;
use App\Http\Controllers\Api\ProfessionalDashboardController;
use App\Http\Controllers\Api\ProfessionalEventTicketController;
use App\Http\Controllers\Api\ProfessionalLookupController;
use App\Http\Controllers\Api\PrivacySettingsController;
use App\Http\Controllers\Api\ReviewController;
use App\Http\Controllers\Api\ShopController;
use App\Http\Controllers\Api\SocialFeedController;
use App\Http\Controllers\Api\SupportTicketController;
use App\Http\Controllers\Api\WishlistController;
use App\Http\Controllers\Api\VenueController;
use App\Http\Controllers\Api\LocationController;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| is assigned the "api" middleware group. Enjoy building your API!
|
*/

// Stripe Webhooks (No Auth)
Route::post('/webhooks/stripe', [\App\Http\Controllers\WebhookController::class, 'handleStripe'])->name('api.webhooks.stripe');

// POS Capture (Device Auth via terminal_uuid)
Route::post('/pos/capture', [\App\Http\Controllers\Api\POSController::class, 'capture']);

//guest customer routes
Route::get('/', [HomeController::class, 'index'])->name('api.index');
Route::get('/get-lang/{code}', [LanguageController::class, 'getLang']);
Route::get('/get-basic', [HomeController::class, 'getBasic'])->name('getBasic');
Route::post('/push-notification-store-endpoint', [HomeController::class, 'pushNotificationStore']);
Route::post('/save-fcm-token', [FcmTokenController::class, 'store']);
Route::get('/get-notifications', [FcmTokenController::class, 'getNotifications']);

// Locations (public – used by sign-up and profile forms)
Route::get('/locations/countries', [LocationController::class, 'countries']);
Route::get('/locations/cities', [LocationController::class, 'cities']);

Route::prefix('events')->group(function () {
  Route::get('/', [EventController::class, 'index'])->name('api.events');
  Route::get('/details', [EventController::class, 'details'])->name('api.event.details');
  Route::get('/slot/seat-details', [EventController::class, 'slotMapping'])->name('api.event.slot_mapping_seat');
  Route::get('/categories', [EventController::class, 'categories'])->name('api.event.categories');
});

Route::prefix('venues')->group(function () {
  Route::get('/', [VenueController::class, 'index'])->name('api.venues.index');
  Route::get('/details/{id}', [VenueController::class, 'details'])->name('api.venues.details');
});

Route::get('/artist/{id}/profile', [ArtistController::class, 'profile'])->name('api.artist.profile');
Route::get('/venue/{id}/profile', [VenueController::class, 'profile'])->name('api.venue.profile');
Route::get('/organizer/{id}/profile', [OrganizerController::class, 'profile'])->name('api.organizer.profile');

Route::prefix('discover')->group(function () {
  Route::get('/artists', [DiscoverController::class, 'artists'])->name('api.discover.artists');
  Route::get('/organizers', [DiscoverController::class, 'organizers'])->name('api.discover.organizers');
  Route::get('/venues', [DiscoverController::class, 'venues'])->name('api.discover.venues');
});

// Universal search (optional auth for personalized results)
Route::get('/search', [SearchController::class, 'search'])->name('api.search');

// Public customer social profiles (optional auth for privacy-aware responses)
Route::prefix('customers/{id}')->group(function () {
  Route::get('/profile', [SearchController::class, 'userProfile'])->name('api.customers.public.profile');
  Route::get('/attended-events', [SearchController::class, 'userAttendedEvents'])->name('api.customers.public.attended_events');
  Route::get('/upcoming-attendance', [SearchController::class, 'userUpcomingAttendance'])->name('api.customers.public.upcoming_attendance');
  Route::get('/interested-events', [SearchController::class, 'userInterestedEvents'])->name('api.customers.public.interested_events');
  Route::get('/favorites', [SearchController::class, 'userFavorites'])->name('api.customers.public.favorites');
  Route::get('/followers', [SearchController::class, 'userFollowers'])->name('api.customers.public.followers');
});

Route::middleware('auth:sanctum')->group(function () {
  Route::get('/social/feed', [SocialFeedController::class, 'index'])->name('api.social.feed');
  Route::get('/me/identities', [\App\Http\Controllers\Api\IdentityController::class, 'index'])->name('api.identities.index');
  Route::post('/identities', [\App\Http\Controllers\Api\IdentityController::class, 'store'])->name('api.identities.store');
  Route::patch('/identities/{id}', [\App\Http\Controllers\Api\IdentityController::class, 'update'])->name('api.identities.update');
});

Route::post('/event/apply-coupon', [EventController::class, 'applyCoupon'])->name('api.event.apply_coupon');
Route::post('/event/checkout-verify', [EventController::class, 'checkoutVerify'])->name('api.event.checkout_verify');
Route::post('/event/verify-payment', [EventController::class, 'verifyPayment'])->name('api.event.payment_verify');
Route::post('/event-booking', [EventController::class, 'store_booking'])->name('api.event.booking.store');
Route::get('shop/', [ShopController::class, 'index'])->name('api.shop');
Route::get('product/details', [ShopController::class, 'details'])->name('api.product.details');

Route::post('product/review/store', [ShopController::class, 'store_review'])->name('api.product.review.store');

Route::prefix('organizers')->group(function () {
  Route::get('/', [OrganizerController::class, 'index'])->name('api.organizers.index');
  Route::get('/details/{id}', [OrganizerController::class, 'details'])->name('api.organizers.details');
  Route::post('/contact-mail', [OrganizerController::class, 'contactMail'])->name('api.organizers.contact');
  Route::post('/review', [\App\Http\Controllers\Api\OrganizerReviewController::class, 'store'])->middleware('auth:sanctum')->name('api.organizers.review');

  Route::middleware('auth:sanctum')->group(function () {
    Route::post('/follow', [\App\Http\Controllers\Api\FollowController::class, 'follow'])->name('api.follow');
    Route::post('/unfollow', [\App\Http\Controllers\Api\FollowController::class, 'unfollow'])->name('api.unfollow');
    Route::get('/followed-events', [OrganizerController::class, 'followedEvents'])->name('api.organizers.followed_events');
  });
});

// Follow requests (auth required)
Route::prefix('follows')->middleware('auth:sanctum')->group(function () {
  Route::get('/requests', [\App\Http\Controllers\Api\FollowController::class, 'getPendingRequests'])->name('api.follows.requests');
  Route::post('/requests/{id}/accept', [\App\Http\Controllers\Api\FollowController::class, 'acceptRequest'])->name('api.follows.requests.accept');
  Route::post('/requests/{id}/reject', [\App\Http\Controllers\Api\FollowController::class, 'rejectRequest'])->name('api.follows.requests.reject');
});

Route::prefix('customer')->group(function () {
  Route::get('/signup', [CustomerController::class, 'signup'])->name('api.customer.signup');
  Route::post('/signup/submit', [CustomerController::class, 'signupSubmit'])->name('api.customer.signup_submit');

  //facebook
  Route::get('login/facebook/callback', [CustomerController::class, 'handleFacebookCallback']);
  Route::get('auth/facebook', [CustomerController::class, 'facebookRedirect']);

  //google
  Route::get('login/google/callback', [CustomerController::class, 'handleGoogleCallback']);
  Route::get('auth/google', [CustomerController::class, 'googleRedirect']);

  Route::get('/login', [CustomerController::class, 'login'])->name('api.customer.login');
  Route::get('/authentication-fail', [CustomerController::class, 'authentication_fail'])->name('api.customer.authentication.fail');
  Route::post('/login/submit', [CustomerController::class, 'loginSubmit'])->name('api.customer.login_submit');
  Route::post('/login-firebase', [CustomerController::class, 'firebaseLogin'])->name('api.customer.login_firebase');
  Route::post('/signup-firebase', [CustomerController::class, 'firebaseSignup'])->name('api.customer.signup_firebase');
  Route::post('/check-availability', [CustomerController::class, 'checkAvailability'])->name('api.customer.check_availability');
  Route::post('/setup-email', [CustomerController::class, 'setupEmail'])->middleware('auth:sanctum')->name('api.customer.setup_email');
  Route::post('/verify-phone-link', [CustomerController::class, 'verifyPhoneLink'])->middleware('auth:sanctum')->name('api.customer.verify_phone_link');
  //forget password

  Route::post('/forget-password', [CustomerController::class, 'forget_mail'])->name('api.customer.forget_password');
  Route::post('/reset-password-update', [CustomerController::class, 'reset_password_submit'])->name('api.customer.update_reset_password');
});

/* ************************************
 * Customer dashboard routes are goes here
 * ************************************/
Route::prefix('/customers')->middleware('auth:sanctum')->group(function () {
  Route::get('/dashboard', [CustomerController::class, 'dashboard'])->name('api.customers.dashboard');

  /* ************************************
   * Event Bookings routes are goes here
   * ************************************/
  Route::get('/bookings', [CustomerController::class, 'bookings'])->name('api.customers.bookings');
  Route::get('/booking/details', [CustomerController::class, 'booking_details'])->name('api.customers.booking.details');

  /* ************************************
   * Payment Methods (Saved Cards)
   * ************************************/
  Route::get('/payment-methods', [\App\Http\Controllers\Api\PaymentMethodController::class, 'index']);
  Route::post('/payment-methods/setup-intent', [\App\Http\Controllers\Api\PaymentMethodController::class, 'setup']);

  /* ************************************
   * Event Bookings routes are goes here
   * ************************************/

  Route::prefix('wishlists')->group(function () {
    Route::get('/', [WishlistController::class, 'index'])->name('api.customers.wishlists.index');
    Route::post('/store', [WishlistController::class, 'store'])->name('api.customers.wishlists.store');
    Route::post('/delete', [WishlistController::class, 'delete'])->name('api.customers.wishlists.delete');
  });

  /* ************************************
   * Product order routes are goes here
   * ************************************/
  Route::get('/product-orders', [ProductOrderController::class, 'product_order'])->name('api.customers.product_orders');
  Route::get('/product-order/details', [ProductOrderController::class, 'product_order_details'])->name('api.customers.product_order.details');

  /* ************************************
   * Support ticket routes are goes here
   * ************************************/
  Route::get('/support-tickets', [SupportTicketController::class, 'index'])->name('api.customers.support_tickets');
  Route::get('/support-ticket/details', [SupportTicketController::class, 'details'])->name('api.customers.support_tickets.details');
  Route::post('/support-ticket/store', [SupportTicketController::class, 'store'])->name('api.customers.support_tickets.store');
  Route::post('/support-ticket/reply', [SupportTicketController::class, 'reply'])->name('api.customers.support_tickets.reply');

  /* ************************************
   * Account Verification
   * ************************************/
  Route::post('/send-email-verification', [CustomerController::class, 'sendEmailVerification'])->name('api.customers.send_email_verification');
  Route::post('/verify-email-otp', [CustomerController::class, 'verifyEmailOtp'])->name('api.customers.verify_email_otp');

  //edit profile
  Route::get('/edit-profile', [CustomerController::class, 'edit_profile'])->name('api.customers.edit_profile');

  /* ************************************
   * Digital Wallet routes are goes here
   * ************************************/
  Route::get('/wallet', [\App\Http\Controllers\Api\WalletController::class, 'getWallet'])->name('api.customers.wallet');
  Route::get('/wallet/history', [\App\Http\Controllers\Api\WalletController::class, 'getHistory'])->name('api.customers.wallet.history');
  Route::get('/wallet/withdrawals', [\App\Http\Controllers\Api\WalletController::class, 'getWithdrawals'])->name('api.customers.wallet.withdrawals');
  Route::post('/wallet/withdraw', [\App\Http\Controllers\Api\WalletController::class, 'requestWithdrawal'])->name('api.customers.wallet.withdraw');
  Route::post('/wallet/transfer', [\App\Http\Controllers\Api\WalletController::class, 'transfer'])->name('api.customers.wallet.transfer');
  Route::get('/bonus-wallet', [\App\Http\Controllers\Api\BonusWalletController::class, 'getWallet'])->name('api.customers.bonus_wallet');
  Route::get('/bonus-wallet/history', [\App\Http\Controllers\Api\BonusWalletController::class, 'getHistory'])->name('api.customers.bonus_wallet.history');
  Route::get('/reviews/pending', [ReviewController::class, 'pending'])->name('api.customers.reviews.pending');
  Route::post('/reviews', [ReviewController::class, 'store'])->name('api.customers.reviews.store');
  Route::post('/artists/{artist}/tip', [ArtistTipController::class, 'store'])->name('api.customers.artists.tip');
  Route::get('/loyalty/summary', [LoyaltyController::class, 'summary'])->name('api.customers.loyalty.summary');
  Route::get('/loyalty/history', [LoyaltyController::class, 'history'])->name('api.customers.loyalty.history');
  Route::get('/loyalty/rewards', [LoyaltyController::class, 'rewards'])->name('api.customers.loyalty.rewards');
  Route::get('/loyalty/redemptions', [LoyaltyController::class, 'redemptions'])->name('api.customers.loyalty.redemptions');
  Route::post('/loyalty/rewards/{reward}/redeem', [LoyaltyController::class, 'redeem'])->name('api.customers.loyalty.redeem');
  Route::get('/reservations', [\App\Http\Controllers\Api\TicketReservationController::class, 'index'])->name('api.customers.reservations.index');
  Route::get('/reservations/{id}', [\App\Http\Controllers\Api\TicketReservationController::class, 'show'])->name('api.customers.reservations.show');
  Route::post('/reservations/preview', [\App\Http\Controllers\Api\TicketReservationController::class, 'previewStore'])->name('api.customers.reservations.preview');
  Route::post('/reservations', [\App\Http\Controllers\Api\TicketReservationController::class, 'store'])->name('api.customers.reservations.store');
  Route::post('/reservations/{id}/pay-preview', [\App\Http\Controllers\Api\TicketReservationController::class, 'previewPay'])->name('api.customers.reservations.pay_preview');
  Route::post('/reservations/{id}/pay', [\App\Http\Controllers\Api\TicketReservationController::class, 'pay'])->name('api.customers.reservations.pay');
  Route::post('/payments/intent', [\App\Http\Controllers\Api\WalletController::class, 'createTopupIntent'])->name('api.customers.wallet.topup');
  Route::post('/payments/intent/preview', [\App\Http\Controllers\Api\WalletController::class, 'previewTopup'])->name('api.customers.wallet.topup_preview');
  Route::get('/wallet/topup-status/{paymentIntentId}', [\App\Http\Controllers\Api\WalletController::class, 'checkTopupStatus'])->name('api.customers.wallet.topup_status');
  Route::post('/wallet/topup-confirm/{paymentIntentId}', [\App\Http\Controllers\Api\WalletController::class, 'confirmTopup'])->name('api.customers.wallet.topup_confirm');
  Route::get('/privacy-settings', [PrivacySettingsController::class, 'show'])->name('api.customers.privacy.show');
  Route::put('/privacy-settings', [PrivacySettingsController::class, 'update'])->name('api.customers.privacy.update');

  /* ************************************
   * POS & NFC routes (Phase 4)
   * ************************************/
  Route::post('/nfc/link', [\App\Http\Controllers\Api\NFCController::class, 'link']);
  Route::post('/nfc/set-pin', [\App\Http\Controllers\Api\NFCController::class, 'setPin']);
  Route::post('/nfc/block', [\App\Http\Controllers\Api\NFCController::class, 'block']);
  Route::post('/pos/authorize', [\App\Http\Controllers\Api\POSController::class, 'authorizeTerminal']);

  Route::prefix('/professional/events')->middleware('identity.context:required')->group(function () {
    Route::get('/', [ProfessionalEventController::class, 'index'])->name('api.customers.professional.events.index');
    Route::get('/{id}', [ProfessionalEventController::class, 'show'])->name('api.customers.professional.events.show');
    Route::get('/{id}/inventory', [ProfessionalEventController::class, 'inventory'])->name('api.customers.professional.events.inventory');
    Route::post('/{id}/claim', [ProfessionalEventController::class, 'claimTreasury'])->name('api.customers.professional.events.claim');
    Route::get('/{id}/collaborators', [\App\Http\Controllers\Api\ProfessionalEventCollaboratorController::class, 'index'])->name('api.customers.professional.events.collaborators.index');
    Route::post('/{id}/collaborators', [\App\Http\Controllers\Api\ProfessionalEventCollaboratorController::class, 'store'])->name('api.customers.professional.events.collaborators.store');
    Route::get('/{id}/tickets', [ProfessionalEventTicketController::class, 'index'])->name('api.customers.professional.events.tickets.index');
    Route::post('/{id}/tickets', [ProfessionalEventTicketController::class, 'store'])->name('api.customers.professional.events.tickets.store');
    Route::post('/{id}/tickets/{ticketId}', [ProfessionalEventTicketController::class, 'update'])->name('api.customers.professional.events.tickets.update');
    Route::post('/{id}/tickets/{ticketId}/duplicate', [ProfessionalEventTicketController::class, 'duplicate'])->name('api.customers.professional.events.tickets.duplicate');
    Route::post('/{id}/tickets/{ticketId}/status', [ProfessionalEventTicketController::class, 'status'])->name('api.customers.professional.events.tickets.status');
    Route::post('/{id}/tickets/{ticketId}/issue', [ProfessionalEventTicketController::class, 'issueTicketManual'])->name('api.customers.professional.events.tickets.issue');
    Route::post('/', [ProfessionalEventController::class, 'store'])->name('api.customers.professional.events.store');
    Route::post('/{id}', [ProfessionalEventController::class, 'update'])->name('api.customers.professional.events.update');
  });

  Route::prefix('/professional')->middleware('identity.context:required')->group(function () {
    Route::get('/dashboard', [ProfessionalDashboardController::class, 'show'])->name('api.customers.professional.dashboard');
    Route::get('/collaborations', [\App\Http\Controllers\Api\ProfessionalCollaborationController::class, 'index'])->name('api.customers.professional.collaborations.index');
    Route::post('/collaborations/{earningId}/claim', [\App\Http\Controllers\Api\ProfessionalCollaborationController::class, 'claim'])->name('api.customers.professional.collaborations.claim');
    Route::post('/collaborations/{earningId}/mode', [\App\Http\Controllers\Api\ProfessionalCollaborationController::class, 'updateMode'])->name('api.customers.professional.collaborations.mode');
    Route::get('/venues/search', [ProfessionalLookupController::class, 'venues'])->name('api.customers.professional.venues.search');
    Route::get('/artists/search', [ProfessionalLookupController::class, 'artists'])->name('api.customers.professional.artists.search');
  });

  //update profile info
  Route::post('/update/profile', [CustomerController::class, 'update_profile'])->name('api.customers.update_profile');
  Route::post('/events/{id}/waitlist', [EventWaitlistController::class, 'store'])->name('api.customers.events.waitlist.store');
  Route::delete('/events/{id}/waitlist', [EventWaitlistController::class, 'destroy'])->name('api.customers.events.waitlist.destroy');

  //update password
  Route::post('/update/password', [CustomerController::class, 'updated_password'])->name('api.customers.updated_password');

  /* ************************************
   * Ticket Marketplace (Phase 6 & 7)
   * ************************************/
  Route::get('/marketplace/tickets', [\App\Http\Controllers\Api\MarketplaceController::class, 'index']);
  Route::get('/marketplace/purchase-preview/{id}', [\App\Http\Controllers\Api\MarketplaceController::class, 'purchasePreview']);
  Route::post('/marketplace/purchase/{id}', [\App\Http\Controllers\Api\MarketplaceController::class, 'purchase']);
  Route::post('/bookings/{id}/transfer', [\App\Http\Controllers\Api\MarketplaceController::class, 'transfer']);
  Route::post('/bookings/{id}/list', [\App\Http\Controllers\Api\MarketplaceController::class, 'listForSale']);

  /* ************************************
   * Subscriptions
   * ************************************/
  Route::get('/subscriptions/plans', [\App\Http\Controllers\Api\SubscriptionController::class, 'index']);
  Route::post('/subscriptions/subscribe', [\App\Http\Controllers\Api\SubscriptionController::class, 'subscribe']);

  Route::post('/logout', [CustomerController::class, 'logoutSubmit'])->name('api.customers.logout');

  Route::prefix('chats')->group(function () {
    Route::get('/', [ChatController::class, 'index']);
    Route::get('/unread-count', [ChatController::class, 'unreadCount']);
    Route::get('/{id}', [ChatController::class, 'show']);
    Route::post('/', [ChatController::class, 'store']);
    Route::post('/start', [ChatController::class, 'startChat']);
  });

  /* ************************************
   * Identity Management
   * ************************************/
  Route::get('/me/identities', [\App\Http\Controllers\Api\IdentityController::class, 'index']);
  Route::post('/identities', [\App\Http\Controllers\Api\IdentityController::class, 'store']);
  Route::patch('/identities/{id}', [\App\Http\Controllers\Api\IdentityController::class, 'update']);
});

Route::prefix('/admin')->group(function () {
  Route::group(['middleware' => 'auth:admin_sanctum'], function ($e) {
    /* ************************************
     * Identity Management (Superadmin)
     * ************************************/
    Route::get('/identities', [\App\Http\Controllers\Api\AdminIdentityController::class, 'index']);
    Route::get('/identities/{id}', [\App\Http\Controllers\Api\AdminIdentityController::class, 'show']);
    Route::post('/identities/{id}/approve', [\App\Http\Controllers\Api\AdminIdentityController::class, 'approve']);
    Route::post('/identities/{id}/reject', [\App\Http\Controllers\Api\AdminIdentityController::class, 'reject']);
    Route::post('/identities/{id}/request-info', [\App\Http\Controllers\Api\AdminIdentityController::class, 'requestInfo']);
    Route::post('/identities/{id}/suspend', [\App\Http\Controllers\Api\AdminIdentityController::class, 'suspend']);
    Route::post('/identities/{id}/reactivate', [\App\Http\Controllers\Api\AdminIdentityController::class, 'reactivate']);

    Route::get('/reviews', [\App\Http\Controllers\Api\AdminReviewController::class, 'index']);
    Route::get('/reviews/{id}', [\App\Http\Controllers\Api\AdminReviewController::class, 'show']);
    Route::post('/reviews/{id}/publish', [\App\Http\Controllers\Api\AdminReviewController::class, 'publish']);
    Route::post('/reviews/{id}/hide', [\App\Http\Controllers\Api\AdminReviewController::class, 'hide']);
    Route::post('/reviews/{id}/reject', [\App\Http\Controllers\Api\AdminReviewController::class, 'reject']);
  });
});
