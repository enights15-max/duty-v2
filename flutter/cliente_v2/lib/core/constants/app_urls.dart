class AppUrls {
  AppUrls._();

  // Live Server
  // static const String _apiBase = 'https://duty.do';
  // Local Server (localhost for iOS Simulator, use 10.0.2.2 for Android Emulator)
  // Local Server (localhost for iOS Simulator, use 10.0.2.2 for Android Emulator)
  static const String _fallbackApiBase = 'http://localhost/v2';

  static const String _baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '$_fallbackApiBase/api',
  );
  static const String _publicBaseOverride = String.fromEnvironment(
    'PUBLIC_BASE_URL',
  );
  static const String googleMapsApiKey = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
    defaultValue: 'AIzaSyCzyVlmlrKExOxJpeermwm_wEWgr-2UkLs',
  );
  static const String googlePlacesAutocomplete =
      'https://maps.googleapis.com/maps/api/place/autocomplete/json';
  static const String googlePlaceDetails =
      'https://maps.googleapis.com/maps/api/place/details/json';
  static const String googleGeocode =
      'https://maps.googleapis.com/maps/api/geocode/json';
  static const String nominatimSearch =
      'https://nominatim.openstreetmap.org/search';
  static const String nominatimReverse =
      'https://nominatim.openstreetmap.org/reverse';

  static String get _apiBase {
    if (_baseUrl.startsWith('http')) {
      if (_baseUrl.endsWith('/api')) {
        return _baseUrl.substring(0, _baseUrl.length - 4);
      }
      return _baseUrl;
    }
    return _fallbackApiBase;
  }

  static String get publicBaseUrl {
    if (_publicBaseOverride.isNotEmpty) {
      return _publicBaseOverride;
    }
    return _apiBase;
  }

  static bool get canUseRichSharePreview {
    if (_publicBaseOverride.isNotEmpty) {
      return true;
    }
    return !_isLocalOrPrivateBase(_apiBase);
  }

  static bool _isLocalOrPrivateBase(String url) {
    final parsed = Uri.tryParse(url);
    final host = parsed?.host.toLowerCase() ?? '';
    if (host.isEmpty) {
      return true;
    }

    if (host == 'localhost' || host == '127.0.0.1' || host == '::1') {
      return true;
    }

    if (host.startsWith('10.') ||
        host.startsWith('192.168.') ||
        host.startsWith('172.16.') ||
        host.startsWith('172.17.') ||
        host.startsWith('172.18.') ||
        host.startsWith('172.19.') ||
        host.startsWith('172.2') ||
        host.startsWith('172.30.') ||
        host.startsWith('172.31.')) {
      return true;
    }

    return false;
  }

  static const String apiBaseUrl = _baseUrl; // Public accessor for Dio client

  // Endpoints
  static const String home = _baseUrl;
  static const String events = '$_baseUrl/events';
  static String eventDetails(int id) =>
      '$_baseUrl/events/details/?event_id=$id';
  static String seatDetails({
    required int eventId,
    required int ticketId,
    required int slotUniqueId,
  }) =>
      '$_baseUrl/events/slot/seat-details?event_id=$eventId&ticket_id=$ticketId&slot_unique_id=$slotUniqueId';
  static const String login = '$_baseUrl/customer/login/submit';
  static const String signup = '$_baseUrl/customer/signup/submit';
  static const String organizers = '$_baseUrl/organizers';
  static String organizerDetails(int id, {required bool isAdmin}) =>
      '$_baseUrl/organizers/details/$id?${isAdmin ? 'admin=true' : 'organizer=true'}';
  static const String dashboard = '$_baseUrl/customers/dashboard';
  static const String bookings = '$_baseUrl/customers/bookings';
  static String bookingDetails(int id) =>
      '$_baseUrl/customers/booking/details/?booking_id=$id';
  static const String eventBooking = '$_baseUrl/event-booking';
  static const String eventCheckoutVerify = '$_baseUrl/event/checkout-verify';
  // Verify payable amount with the backend before hitting PGW
  static const String eventVerifyPayment = '$_baseUrl/event/verify-payment';
  // Finalize/submit payment + booking (alias to eventBooking for this app)
  static const String paymentProcessUrl = eventBooking;
  // Apply coupon to event booking (assumed endpoint naming)
  static const String eventCouponApply = '$_baseUrl/event/apply-coupon';

  // Wallet
  static const String wallet = '$_baseUrl/customers/wallet';
  static const String walletHistory = '$_baseUrl/customers/wallet/history';
  static const String walletWithdrawals =
      '$_baseUrl/customers/wallet/withdrawals';
  static const String walletWithdraw = '$_baseUrl/customers/wallet/withdraw';
  static const String walletTransfer = '$_baseUrl/customers/wallet/transfer';
  static String walletQr(String walletId) => 'duty-wallet://$walletId';
  static const String bonusWallet = '$_baseUrl/customers/bonus-wallet';
  static const String bonusWalletHistory =
      '$_baseUrl/customers/bonus-wallet/history';
  static const String loyaltySummary = '$_baseUrl/customers/loyalty/summary';
  static const String loyaltyHistory = '$_baseUrl/customers/loyalty/history';
  static const String loyaltyRewards = '$_baseUrl/customers/loyalty/rewards';
  static const String loyaltyRedemptions =
      '$_baseUrl/customers/loyalty/redemptions';
  static String loyaltyRedeem(int rewardId) =>
      '$_baseUrl/customers/loyalty/rewards/$rewardId/redeem';
  static const String reviewPending = '$_baseUrl/customers/reviews/pending';
  static const String submitReview = '$_baseUrl/customers/reviews';
  static String tipArtist(int artistId) =>
      '$_baseUrl/customers/artists/$artistId/tip';
  static const String reservations = '$_baseUrl/customers/reservations';
  static const String reservationPreview =
      '$_baseUrl/customers/reservations/preview';
  static String reservationDetails(int id) =>
      '$_baseUrl/customers/reservations/$id';
  static String reservationPayPreview(int id) =>
      '$_baseUrl/customers/reservations/$id/pay-preview';
  static String reservationPay(int id) =>
      '$_baseUrl/customers/reservations/$id/pay';

  // Subscriptions (Phase 5)
  static const String subscriptionPlans =
      '$_baseUrl/customers/subscriptions/plans';
  static const String subscribe = '$_baseUrl/customers/subscriptions/subscribe';

  // Scanner (Organizer/Staff)
  static const String claimReward = '$_baseUrl/scanner/organizer/claim-reward';

  // Marketplace (Phase 6 & 7)
  static String transferTicket(int bookingId) =>
      '$_baseUrl/customers/bookings/$bookingId/transfer';
  static String listTicket(int bookingId) =>
      '$_baseUrl/customers/bookings/$bookingId/list';
  static const String marketplaceTickets =
      '$_baseUrl/customers/marketplace/tickets';
  static String marketplacePurchasePreview(int bookingId) =>
      '$_baseUrl/customers/marketplace/purchase-preview/$bookingId';
  static String purchaseMarketplaceTicket(int bookingId) =>
      '$_baseUrl/customers/marketplace/purchase/$bookingId';

  // Payment gateway helpers (non-API helpers hosted on same host)
  static String get stripeCreatePaymentIntent =>
      '$_apiBase/pgw/create-payment-intent.php';
  static String get flutterwaveCreatePayment =>
      '$_apiBase/pgw/flutterwave-create-payment.php';
  static String get flutterwaveVerifyPayment =>
      '$_apiBase/pgw/flutterwave-verify-payment.php';
  static const String wishlists = '$_baseUrl/customers/wishlists';
  static const String wishlistsStore = '$_baseUrl/customers/wishlists/store';
  static const String wishlistsDelete = '$_baseUrl/customers/wishlists/delete';
  static const String supportTickets = '$_baseUrl/customers/support-tickets';
  static const String supportTicketStore =
      '$_baseUrl/customers/support-ticket/store';
  static const String loginFirebase = '$_baseUrl/customer/login-firebase';
  static const String signupFirebase = '$_baseUrl/customer/signup-firebase';
  static const String setupEmail = '$_baseUrl/customer/setup-email';
  static const String verifyPhoneLink = '$_baseUrl/customer/verify-phone-link';
  static const String sendEmailVerification =
      '$_baseUrl/customers/send-email-verification';
  static const String verifyEmailOtp = '$_baseUrl/customers/verify-email-otp';
  static const String checkAvailability =
      '$_baseUrl/customer/check-availability';
  static String supportTicketDetails(int id) =>
      '$_baseUrl/customers/support-ticket/details/?ticket_id=$id';
  static const String supportTicketReply =
      '$_baseUrl/customers/support-ticket/reply';
  static const String updateProfile = '$_baseUrl/customers/update/profile';
  static const String updatePassword = '$_baseUrl/customers/update/password';
  static const String privacySettings = '$_baseUrl/customers/privacy-settings';
  static const String socialFeed = '$_baseUrl/social/feed';
  static const String walletTopupPreview =
      '$_baseUrl/customers/payments/intent/preview';
  static const String forgetPassword = '$_baseUrl/customer/forget-password';
  static const String resetPasswordUpdate =
      '$_baseUrl/customer/reset-password-update';

  static String getLangUrl(String languageCode) =>
      '$_baseUrl/get-lang/$languageCode';

  // Basic app info including languages list
  static const String basic = '$_baseUrl/get-basic';

  static String get sendEmailToOrganizerUrl =>
      '$_baseUrl/organizers/contact-mail';

  // Web push subscription storage endpoint
  static const String pushNotificationStoreEndpoint =
      '$_baseUrl/push-notification-store-endpoint';

  // Save FCM token to server
  static const String saveFcmToken = '$_baseUrl/save-fcm-token';

  // Fetch existing notifications for a user (expects query params user_id, fcm_token)
  static const String getNotifications = '$_baseUrl/get-notifications';

  // Chat
  static const String chats = '$_baseUrl/customers/chats';
  static const String chatsUnreadCount =
      '$_baseUrl/customers/chats/unread-count';
  static String chatMessages(int chatId) => '$_baseUrl/customers/chats/$chatId';
  static const String startChat = '$_baseUrl/customers/chats/start';

  // Unified verification URL (POST JSON). Kept as a helper for callers.
  static String verifyPaymentUrl({
    required String amount,
    required String gateway,
  }) => eventVerifyPayment;

  static const String identities = '$_baseUrl/customers/me/identities';
  static const String requestIdentity = '$_baseUrl/customers/identities';
  static String updateIdentity(String id) =>
      '$_baseUrl/customers/identities/$id';
  // Locations
  static const String locationCountries = '$_baseUrl/locations/countries';
  static String locationCities({int? countryId}) => countryId != null
      ? '$_baseUrl/locations/cities?country_id=$countryId'
      : '$_baseUrl/locations/cities';
  static String eventWaitlist(int id) =>
      '$_baseUrl/customers/events/$id/waitlist';
  static const String professionalEvents =
      '$_baseUrl/customers/professional/events';
  static const String professionalDashboard =
      '$_baseUrl/customers/professional/dashboard';
  static String professionalDashboardRange(String range) =>
      '$professionalDashboard?range=$range';
  static String professionalEvent(int id) => '$professionalEvents/$id';
  static String professionalEventInventory(int id) =>
      '$professionalEvents/$id/inventory';
  static String professionalEventClaim(int id) =>
      '$professionalEvents/$id/claim';
  static String professionalEventCollaborators(int id) =>
      '$professionalEvents/$id/collaborators';
  static String professionalEventTickets(int id) =>
      '$professionalEvents/$id/tickets';
  static String professionalEventTicket(int eventId, int ticketId) =>
      '${professionalEventTickets(eventId)}/$ticketId';
  static String professionalEventTicketDuplicate(int eventId, int ticketId) =>
      '${professionalEventTicket(eventId, ticketId)}/duplicate';
  static String professionalEventTicketStatus(int eventId, int ticketId) =>
      '${professionalEventTicket(eventId, ticketId)}/status';
  static const String professionalVenueSearch =
      '$_baseUrl/customers/professional/venues/search';
  static const String professionalArtistSearch =
      '$_baseUrl/customers/professional/artists/search';
  static const String professionalCollaborations =
      '$_baseUrl/customers/professional/collaborations';
  static String professionalCollaborationClaim(int earningId) =>
      '$professionalCollaborations/$earningId/claim';
  static String professionalCollaborationMode(int earningId) =>
      '$professionalCollaborations/$earningId/mode';

  // Images
  static String get imageBaseUrl =>
      '$_apiBase/assets/admin/img/event/thumbnail/';
  static String get eventCoverBaseUrl =>
      '$_apiBase/assets/admin/img/event-gallery/';
  static String get profileImageBaseUrl =>
      '$_apiBase/assets/admin/img/customer-profile/';
  static String get organizerImageBaseUrl =>
      '$_apiBase/assets/admin/img/organizer-photo/';
  static String get organizerCoverImageBaseUrl =>
      '$_apiBase/assets/admin/img/organizer-cover/';
  static String get venueImageBaseUrl => '$_apiBase/assets/admin/img/venue/';
  static String get artistImageBaseUrl => '$_apiBase/assets/admin/img/artist/';

  static String? getIdentityAvatarUrl(String type, String? photo) {
    if (photo == null || photo.trim().isEmpty) return null;
    final normalized = photo.trim();
    if (normalized.startsWith('http')) {
      return normalized;
    }

    final cleanPhoto = normalized.startsWith('/')
        ? normalized.substring(1)
        : normalized;

    if (cleanPhoto.contains('assets/admin/img/')) {
      return '$_apiBase/$cleanPhoto';
    }

    switch (type) {
      case 'artist':
        return '$artistImageBaseUrl$cleanPhoto';
      case 'venue':
        return '$venueImageBaseUrl$cleanPhoto';
      case 'organizer':
        return '$organizerImageBaseUrl$cleanPhoto';
      default:
        return getAvatarUrl(cleanPhoto);
    }
  }

  static String? getIdentityCoverUrl(String type, String? photo) {
    if (photo == null || photo.trim().isEmpty) return null;
    final normalized = photo.trim();
    if (normalized.startsWith('http')) {
      return normalized;
    }

    final cleanPhoto = normalized.startsWith('/')
        ? normalized.substring(1)
        : normalized;

    if (cleanPhoto.contains('assets/admin/img/')) {
      return '$_apiBase/$cleanPhoto';
    }

    switch (type) {
      case 'artist':
        return '$artistImageBaseUrl$cleanPhoto';
      case 'venue':
        return '$venueImageBaseUrl$cleanPhoto';
      case 'organizer':
        return '$organizerCoverImageBaseUrl$cleanPhoto';
      default:
        return null;
    }
  }

  /// Helper to get the full avatar URL for a customer or organizer.
  /// Handles both full URLs (http) and relative file paths.
  static String? getAvatarUrl(String? photo, {bool isOrganizer = false}) {
    if (photo == null || photo.trim().isEmpty) return null;
    final normalized = photo.trim();
    if (normalized.startsWith('http')) {
      final sanitized = normalized.replaceAll(RegExp(r'/+$'), '');
      if (sanitized.endsWith('/assets/admin/img/organizer-photo') ||
          sanitized.endsWith('/assets/admin/img/customer-profile') ||
          sanitized.endsWith('/assets/admin/img/admins') ||
          sanitized.endsWith('/assets/admin/img/venue') ||
          sanitized.endsWith('/assets/admin/img/artist')) {
        return null;
      }
      return normalized;
    }

    // Remove leading slash if present
    final cleanPhoto = normalized.startsWith('/')
        ? normalized.substring(1)
        : normalized;
    if (cleanPhoto.contains('assets/admin/img/')) {
      return '$_apiBase/$cleanPhoto';
    }
    final baseUrl = isOrganizer ? organizerImageBaseUrl : profileImageBaseUrl;
    return '$baseUrl$cleanPhoto';
  }

  static String? getCustomerAvatarUrl(Map<String, dynamic>? user) {
    if (user == null) return null;

    String? resolveCandidate(dynamic value) {
      final normalized = value?.toString().trim();
      if (normalized == null || normalized.isEmpty) {
        return null;
      }
      return getAvatarUrl(normalized);
    }

    final directCandidates = [
      user['photo_url'],
      user['avatar_url'],
      user['avatar'],
      user['photoUrl'],
      user['photo'],
      user['image'],
    ];

    for (final candidate in directCandidates) {
      final resolved = resolveCandidate(candidate);
      if (resolved != null) {
        return resolved;
      }
    }

    final customerInfo = user['customer_info'];
    if (customerInfo is Map<String, dynamic>) {
      final nested = getCustomerAvatarUrl(customerInfo);
      if (nested != null) {
        return nested;
      }
    } else if (customerInfo is Map) {
      final nested = getCustomerAvatarUrl(
        Map<String, dynamic>.from(customerInfo),
      );
      if (nested != null) {
        return nested;
      }
    }

    final data = user['data'];
    if (data is Map<String, dynamic>) {
      final nested = getCustomerAvatarUrl(data);
      if (nested != null) {
        return nested;
      }
    } else if (data is Map) {
      final nested = getCustomerAvatarUrl(Map<String, dynamic>.from(data));
      if (nested != null) {
        return nested;
      }
    }

    return null;
  }

  /// Helper to get the full event thumbnail URL.
  static String? getEventThumbnailUrl(String? photo) {
    if (photo == null || photo.trim().isEmpty) return null;
    if (photo.startsWith('http')) return photo;

    final cleanPhoto = photo.startsWith('/') ? photo.substring(1) : photo;
    return '$imageBaseUrl$cleanPhoto';
  }

  /// Helper to get the full event gallery image URL.
  static String? getEventGalleryImageUrl(String? photo) {
    if (photo == null || photo.trim().isEmpty) return null;
    if (photo.startsWith('http')) return photo;

    final cleanPhoto = photo.startsWith('/') ? photo.substring(1) : photo;
    return '$eventCoverBaseUrl$cleanPhoto';
  }

  static String? getArtistImageUrl(String? photo) {
    if (photo == null || photo.trim().isEmpty) return null;
    if (photo.startsWith('http')) return photo;

    final cleanPhoto = photo.startsWith('/') ? photo.substring(1) : photo;
    if (cleanPhoto.contains('assets/admin/img/')) {
      return '$_apiBase/$cleanPhoto';
    }
    return '$artistImageBaseUrl$cleanPhoto';
  }

  /// Helper to get the full venue image URL.
  static String? getVenueImageUrl(String? photo) {
    if (photo == null || photo.trim().isEmpty) return null;
    if (photo.startsWith('http')) return photo;

    final cleanPhoto = photo.startsWith('/') ? photo.substring(1) : photo;
    if (cleanPhoto.contains('assets/admin/img/')) {
      return '$_apiBase/$cleanPhoto';
    }
    return '$venueImageBaseUrl$cleanPhoto';
  }

  /// Helper to get organizer cover image URL.
  static String? getOrganizerCoverImageUrl(String? photo) {
    if (photo == null || photo.trim().isEmpty) return null;
    if (photo.startsWith('http')) return photo;

    final cleanPhoto = photo.startsWith('/') ? photo.substring(1) : photo;
    return '$organizerCoverImageBaseUrl$cleanPhoto';
  }

  // Search
  static String get search => '$_baseUrl/search';

  // Social
  static String get follow => '$_baseUrl/organizers/follow';
  static String get unfollow => '$_baseUrl/organizers/unfollow';
  // NOTE: follow-request system not yet implemented in backend
  static String get pendingFollowRequests => '$_baseUrl/follows/requests';
  static String acceptFollowRequest(int id) =>
      '$_baseUrl/follows/requests/$id/accept';
  static String rejectFollowRequest(int id) =>
      '$_baseUrl/follows/requests/$id/reject';

  // User social profile endpoints (backend routes TBD)
  static String userAttendedEvents(int userId) =>
      '$_baseUrl/customers/$userId/attended-events';
  static String userUpcomingAttendance(int userId) =>
      '$_baseUrl/customers/$userId/upcoming-attendance';
  static String userInterestedEvents(int userId) =>
      '$_baseUrl/customers/$userId/interested-events';
  static String userFavorites(int userId) =>
      '$_baseUrl/customers/$userId/favorites';
  static String userFollowers(int userId) =>
      '$_baseUrl/customers/$userId/followers';
}
