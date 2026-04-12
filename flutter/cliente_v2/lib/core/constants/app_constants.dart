import 'app_urls.dart';

class AppConstants {
  static const String appName = 'Duty';
  static const String apiBaseUrl = AppUrls.apiBaseUrl;

  static String get imageBaseUrl => AppUrls.imageBaseUrl;
  static String get eventCoverBaseUrl => AppUrls.eventCoverBaseUrl;
  static String get profileImageBaseUrl => AppUrls.profileImageBaseUrl;
  static String get venueImageBaseUrl => AppUrls.venueImageBaseUrl;

  // Storage Keys
  static const String tokenKey = 'auth_token'; // Legacy (SharedPreferences)
  static const String secureTokenKey =
      'secure_auth_token'; // New (SecureStorage)
  static const String userKey = 'auth_user_data';
  static const String themeKey = 'app_theme';
  static const String langKey = 'app_lang';
  static const String faceIdKey = 'face_id_enabled';
  static const String onboardingSeenKey = 'onboarding_seen';
  static const String userTypeKey = 'user_type';
  static const String userProfilesKey = 'user_profiles';
  static const String activeProfileIdKey = 'active_profile_id';

  // API Endpoints
  static const String profileEndpoint = AppUrls.dashboard;
}
