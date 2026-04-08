import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:duty_client/core/providers/profile_state_provider.dart';
import 'package:duty_client/core/api/api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:duty_client/core/constants/app_constants.dart';
import 'package:duty_client/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:duty_client/features/auth/data/repositories/auth_repository_impl.dart';

// Providers
final apiClientProvider = Provider<ApiClient>((ref) {
  final client = ApiClient();
  final tokenState = ref.watch(authTokenProvider);
  final token = tokenState.valueOrNull;

  if (token != null) {
    client.setToken(token);
  }

  // Handle active profile header
  final activeProfile = ref.watch(activeProfileProvider);
  if (activeProfile != null) {
    client.setProfileId(activeProfile.id);
  } else {
    client.removeProfileId();
  }

  return client;
});

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences not initialized');
});

final flutterSecureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

final authTokenProvider = FutureProvider<String?>((ref) async {
  final secureStorage = ref.watch(flutterSecureStorageProvider);
  return await secureStorage.read(key: AppConstants.secureTokenKey);
});

final currentUserProvider = StateProvider<Map<String, dynamic>?>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final userJson = prefs.getString(AppConstants.userKey);
  if (userJson != null) {
    try {
      return jsonDecode(userJson) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }
  return null;
});

final faceIdEnabledProvider = Provider<bool>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return prefs.getBool(AppConstants.faceIdKey) ?? false;
});

final onboardingSeenProvider = Provider<bool>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return prefs.getBool(AppConstants.onboardingSeenKey) ?? false;
});

final userTypeProvider = Provider<String?>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return prefs.getString(AppConstants.userTypeKey);
});

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthRemoteDataSource(apiClient);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final remoteDataSource = ref.watch(authRemoteDataSourceProvider);
  final sharedPreferences = ref.watch(sharedPreferencesProvider);
  final secureStorage = ref.watch(flutterSecureStorageProvider);

  return AuthRepository(remoteDataSource, sharedPreferences, secureStorage);
});

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<void>>((ref) {
      final repository = ref.watch(authRepositoryProvider);
      return AuthController(repository, ref);
    });

final onboardingControllerProvider = Provider((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return OnboardingController(prefs, ref);
});

class OnboardingController {
  final SharedPreferences _prefs;
  final Ref _ref;

  OnboardingController(this._prefs, this._ref);

  Future<void> completeOnboarding() async {
    await _prefs.setBool(AppConstants.onboardingSeenKey, true);
    _ref.invalidate(onboardingSeenProvider);
  }
}

final userTypeControllerProvider = Provider((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return UserTypeController(prefs, ref);
});

class UserTypeController {
  final SharedPreferences _prefs;
  final Ref _ref;

  UserTypeController(this._prefs, this._ref);

  Future<void> setUserType(String type) async {
    await _prefs.setString(AppConstants.userTypeKey, type);
    _ref.invalidate(userTypeProvider);
  }
}

class AuthController extends StateNotifier<AsyncValue<void>> {
  final AuthRepository _repository;
  final Ref _ref;

  AuthController(this._repository, this._ref)
    : super(const AsyncValue.data(null));

  void _refreshSessionState() {
    _ref.invalidate(authTokenProvider);
    _ref.invalidate(currentUserProvider);
    _ref.invalidate(keepSignedInProvider);
    _ref.invalidate(activeProfileIdProvider);
    _ref.invalidate(userProfilesProvider);
    _ref.invalidate(activeProfileProvider);
    _ref.invalidate(apiClientProvider);
  }

  Future<Map<String, dynamic>?> login(
    String email,
    String password, {
    bool keepSignedIn = true,
  }) async {
    state = const AsyncValue.loading();
    try {
      final response = await _repository.login(email, password);
      if (response['status'] == 'success') {
        _refreshSessionState();
      }
      state = const AsyncValue.data(null);
      return response;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<Map<String, dynamic>?> loginWithFirebase(String idToken) async {
    state = const AsyncValue.loading();
    try {
      final response = await _repository.loginWithFirebase(idToken);
      if (response['status'] == 'success') {
        _refreshSessionState();
      }
      state = const AsyncValue.data(null);
      return response;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<void> signupWithFirebase({
    required String idToken,
    required String fname,
    required String lname,
    required String email,
    String? dateOfBirth,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _repository.signupWithFirebase(
        idToken: idToken,
        fname: fname,
        lname: lname,
        email: email,
        dateOfBirth: dateOfBirth,
      );
      _refreshSessionState();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> signup(Map<String, dynamic> data) async {
    state = const AsyncValue.loading();
    try {
      final response = await _repository.signup(data);
      if (response['success'] == true) {
        _refreshSessionState();
      }
      state = const AsyncValue.data(null);
      return response;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    await _repository.logout();
    _ref.invalidate(authTokenProvider);
    _ref.invalidate(currentUserProvider);
    state = const AsyncValue.data(null);
  }

  Future<Map<String, dynamic>?> setupEmail({
    required String email,
    required String fname,
    required String lname,
    required String token,
  }) async {
    state = const AsyncValue.loading();
    try {
      final response = await _repository.setupEmail(
        email: email,
        fname: fname,
        lname: lname,
        token: token,
      );
      if (response['status'] == 'success') {
        _refreshSessionState();
      }
      state = const AsyncValue.data(null);
      return response;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<Map<String, dynamic>?> verifyPhoneLink({
    required String idToken,
    required String token,
  }) async {
    state = const AsyncValue.loading();
    try {
      final response = await _repository.verifyPhoneLink(
        idToken: idToken,
        token: token,
      );
      if (response['status'] == 'success') {
        _refreshSessionState();
      }
      state = const AsyncValue.data(null);
      return response;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<Map<String, dynamic>?> sendEmailVerification() async {
    state = const AsyncValue.loading();
    try {
      final response = await _repository.sendEmailVerification();
      state = const AsyncValue.data(null);
      return response;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<Map<String, dynamic>?> verifyEmailOtp(String otp) async {
    state = const AsyncValue.loading();
    try {
      final response = await _repository.verifyEmailOtp(otp);
      if (response['status'] == 'success') {
        _ref.invalidate(
          currentUserProvider,
        ); // Refresh user profile to get new verification state
      }
      state = const AsyncValue.data(null);
      return response;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<Map<String, dynamic>?> checkAvailability({
    String? email,
    String? phone,
    String? username,
  }) async {
    try {
      return await _repository.checkAvailability(
        email: email,
        phone: phone,
        username: username,
      );
    } catch (e) {
      debugPrint('Exception in checkAvailability: $e');
      return null;
    }
  }
}

class AuthState {
  // Can add specific auth state class if needed later
}
