import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:duty_client/core/constants/app_urls.dart';
import 'package:duty_client/features/profile/domain/models/profile_model.dart';
import 'package:duty_client/features/auth/presentation/providers/auth_provider.dart';

List<AppProfile> _enrichProfilesWithCurrentUserAvatar(
  List<AppProfile> profiles,
  Map<String, dynamic>? currentUser,
) {
  final personalAvatarUrl = AppUrls.getCustomerAvatarUrl(currentUser);
  if (personalAvatarUrl == null) {
    return profiles;
  }

  return profiles.map((profile) {
    if (profile.type != ProfileType.personal) {
      return profile;
    }

    return profile.copyWith(avatarUrl: personalAvatarUrl);
  }).toList();
}

// The ID of the currently active profile
final activeProfileIdProvider = StateProvider<String?>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return prefs.getString('active_identity_id_key');
});

// List of available profiles for the user
final userProfilesProvider = StateProvider<List<AppProfile>>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final currentUser = ref.watch(currentUserProvider);
  final profilesJson = prefs.getString('user_identities_key');
  if (profilesJson != null) {
    try {
      final List<dynamic> list = jsonDecode(profilesJson);
      final profiles = list.map((item) => AppProfile.fromJson(item)).toList();
      return _enrichProfilesWithCurrentUserAvatar(profiles, currentUser);
    } catch (e) {
      return [];
    }
  }
  return [];
});

// Convenient provider to get the full profile object of the active profile
final activeProfileProvider = Provider<AppProfile?>((ref) {
  final activeId = ref.watch(activeProfileIdProvider);
  final profiles = ref.watch(userProfilesProvider);

  if (activeId == null || profiles.isEmpty) return null;

  try {
    return profiles.firstWhere((p) => p.id == activeId);
  } catch (_) {
    return null;
  }
});

String resolveLandingRouteForProfile(AppProfile? profile) {
  if (profile == null || profile.type == ProfileType.personal) {
    return '/home';
  }

  return '/dashboard';
}

final activeProfileLandingRouteProvider = Provider<String>((ref) {
  final activeProfile = ref.watch(activeProfileProvider);
  return resolveLandingRouteForProfile(activeProfile);
});
