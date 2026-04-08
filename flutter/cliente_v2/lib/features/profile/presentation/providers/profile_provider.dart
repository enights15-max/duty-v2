import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:duty_client/core/constants/app_urls.dart';
import 'package:duty_client/core/providers/profile_state_provider.dart';
import 'package:duty_client/features/auth/presentation/providers/auth_provider.dart';
import 'package:duty_client/core/constants/app_constants.dart';
import 'package:duty_client/features/profile/domain/models/profile_model.dart';
import 'package:duty_client/features/profile/data/models/booking_model.dart';
import 'package:duty_client/features/profile/data/datasources/customer_remote_data_source.dart';
import 'package:duty_client/features/profile/data/repositories/customer_repository.dart';

// --- Controllers ---

final profileControllerProvider = Provider((ref) {
  return ProfileController(ref);
});

class ProfileController {
  final Ref _ref;

  ProfileController(this._ref);

  Map<String, dynamic> _normalizeIdentityPayload({
    required String displayName,
    required dynamic payload,
    String? type,
  }) {
    if (payload is Map<String, dynamic>) {
      final hasNestedMeta = payload.containsKey('meta');
      final hasTopLevelIdentityFields =
          payload.containsKey('display_name') ||
          payload.containsKey('slug') ||
          payload.containsKey('type');

      if (hasNestedMeta || hasTopLevelIdentityFields) {
        return {
          if (type != null && !payload.containsKey('type')) 'type': type,
          if (!payload.containsKey('display_name')) 'display_name': displayName,
          ...payload,
        };
      }

      final normalized = <String, dynamic>{
        'display_name': displayName,
        'meta': payload,
      };
      if (type != null) {
        normalized['type'] = type;
      }
      return normalized;
    }

    throw ArgumentError('Identity payload must be a map or multipart form.');
  }

  Future<void> switchProfile(String profileId) async {
    final user = _ref.read(currentUserProvider);
    if (user == null) return;

    final updatedUser = Map<String, dynamic>.from(user);
    updatedUser['active_profile_id'] = profileId;

    final prefs = _ref.read(sharedPreferencesProvider);
    await prefs.setString(AppConstants.userKey, jsonEncode(updatedUser));
    await prefs.setString('active_identity_id_key', profileId);

    _ref.read(currentUserProvider.notifier).state = updatedUser;
    _ref.read(activeProfileIdProvider.notifier).state = profileId;

    // Invalidate dependent providers
    _ref.invalidate(apiClientProvider);
  }

  Future<void> createProfile(AppProfile profile) async {
    final profiles = _ref.read(userProfilesProvider);
    final updatedProfiles = [...profiles, profile];

    final prefs = _ref.read(sharedPreferencesProvider);
    await prefs.setString(
      'user_identities_key',
      jsonEncode(updatedProfiles.map((p) => p.toJson()).toList()),
    );

    _ref.read(userProfilesProvider.notifier).state = updatedProfiles;
  }

  Future<void> requestIdentity({
    required String type,
    required String displayName,
    required dynamic meta,
  }) async {
    final repository = _ref.read(customerRepositoryProvider);
    final token = await _ref.read(authTokenProvider.future);
    final payload = meta;
    final response = await repository.requestIdentity(
      payload is Map<String, dynamic>
          ? _normalizeIdentityPayload(
              displayName: displayName,
              payload: payload,
              type: type,
            )
          : payload,
      token: token,
    );

    try {
      await refreshIdentities();
    } catch (_) {
      _ref.invalidate(apiClientProvider);
    }
    return response;
  }

  Future<Map<String, dynamic>> updateIdentity({
    required String id,
    required String displayName,
    required dynamic meta,
  }) async {
    final repository = _ref.read(customerRepositoryProvider);
    final token = await _ref.read(authTokenProvider.future);
    final payload = meta;
    final response = await repository.updateIdentity(
      id,
      payload is Map<String, dynamic>
          ? _normalizeIdentityPayload(
              displayName: displayName,
              payload: payload,
            )
          : payload,
      token: token,
    );

    try {
      await refreshIdentities();
    } catch (_) {
      _ref.invalidate(apiClientProvider);
    }
    return response;
  }

  Future<List<AppProfile>> refreshIdentities() async {
    final repository = _ref.read(customerRepositoryProvider);
    final rawIdentities = await repository.getIdentities();
    final currentUser = _ref.read(currentUserProvider);
    final personalAvatarUrl = AppUrls.getCustomerAvatarUrl(currentUser);
    final identities = rawIdentities
        .whereType<Map<String, dynamic>>()
        .map(AppProfile.fromJson)
        .map((profile) {
          if (profile.type == ProfileType.personal &&
              personalAvatarUrl != null) {
            return profile.copyWith(avatarUrl: personalAvatarUrl);
          }
          return profile;
        })
        .toList();

    final prefs = _ref.read(sharedPreferencesProvider);
    await prefs.setString('user_identities_key', jsonEncode(rawIdentities));
    _ref.read(userProfilesProvider.notifier).state = identities;

    if (nextActiveId != null) {
      await prefs.setString('active_identity_id_key', nextActiveId);
      _ref.read(activeProfileIdProvider.notifier).state = nextActiveId;
    } else {
      await prefs.remove('active_identity_id_key');
      _ref.read(activeProfileIdProvider.notifier).state = null;
    }

    if (currentUser != null) {
      final updatedUser = Map<String, dynamic>.from(currentUser);
      if (nextActiveId != null) {
        updatedUser['active_profile_id'] = nextActiveId;
      } else {
        updatedUser.remove('active_profile_id');
      }

      await prefs.setString(AppConstants.userKey, jsonEncode(updatedUser));
      _ref.read(currentUserProvider.notifier).state = updatedUser;
    }

    _ref.invalidate(apiClientProvider);
    return identities;
  }

  String? _resolveActiveIdentityId(
    List<AppProfile> identities, {
    String? currentActiveId,
  }) {
    if (identities.isEmpty) {
      return null;
    }

    if (currentActiveId != null) {
      for (final profile in identities) {
        if (profile.id == currentActiveId && profile.isActive) {
          return profile.id;
        }
      }
    }

    for (final profile in identities) {
      if (profile.type == ProfileType.personal && profile.isActive) {
        return profile.id;
      }
    }

    for (final profile in identities) {
      if (profile.isActive) {
        return profile.id;
      }
    }

    return null;
  }
}

// --- Legacy Providers (Restored for Compatibility) ---

final profileProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final activeProfile = ref.watch(activeProfileProvider);
  if (activeProfile != null) {
    return activeProfile.toJson();
  }

  // Fallback to current user map if no active profile
  final user = ref.watch(currentUserProvider);
  return user ?? {};
});

final customerRemoteDataSourceProvider = Provider((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return CustomerRemoteDataSource(apiClient);
});

final customerRepositoryProvider = Provider((ref) {
  final remoteDataSource = ref.watch(customerRemoteDataSourceProvider);
  return CustomerRepository(remoteDataSource);
});

final myBookingsProvider = FutureProvider<List<BookingModel>>((ref) async {
  final repository = ref.watch(customerRepositoryProvider);
  final tokenState = ref.watch(authTokenProvider);
  final token = tokenState.valueOrNull;

  return await repository.getBookings(token: token);
});
