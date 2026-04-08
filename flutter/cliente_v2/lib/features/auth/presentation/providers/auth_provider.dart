import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';

// Providers
final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences not initialized');
});

<<<<<<< Updated upstream
=======
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

final keepSignedInProvider = Provider<bool>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return prefs.getBool(AppConstants.keepSignedInKey) ?? true;
});

final onboardingSeenProvider = Provider<bool>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return prefs.getBool(AppConstants.onboardingSeenKey) ?? false;
});

final userTypeProvider = Provider<String?>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return prefs.getString(AppConstants.userTypeKey);
});

>>>>>>> Stashed changes
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthRemoteDataSource(apiClient);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final remoteDataSource = ref.watch(authRemoteDataSourceProvider);
  final sharedPreferences = ref.watch(sharedPreferencesProvider);

  return AuthRepository(remoteDataSource, sharedPreferences);
});

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<void>>((ref) {
      final repository = ref.watch(authRepositoryProvider);
      return AuthController(repository);
    });

class AuthController extends StateNotifier<AsyncValue<void>> {
  final AuthRepository _repository;

  AuthController(this._repository) : super(const AsyncValue.data(null));

<<<<<<< Updated upstream
  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.login(email, password));
  }

  Future<void> signup(Map<String, dynamic> data) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.signup(data));
=======
  Future<Map<String, dynamic>?> login(
    String email,
    String password, {
    bool keepSignedIn = true,
  }) async {
    state = const AsyncValue.loading();
    try {
      final response = await _repository.login(
        email,
        password,
        keepSignedIn: keepSignedIn,
      );
      if (response['status'] == 'success') {
        _ref.invalidate(authTokenProvider);
        _ref.invalidate(currentUserProvider);
        _ref.invalidate(keepSignedInProvider);
      }
      state = const AsyncValue.data(null);
      return response;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<Map<String, dynamic>?> loginWithFirebase(
    String idToken, {
    bool keepSignedIn = true,
  }) async {
    state = const AsyncValue.loading();
    try {
      final response = await _repository.loginWithFirebase(
        idToken,
        keepSignedIn: keepSignedIn,
      );
      if (response['status'] == 'success') {
        _ref.invalidate(authTokenProvider);
        _ref.invalidate(currentUserProvider);
        _ref.invalidate(keepSignedInProvider);
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
    bool keepSignedIn = true,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _repository.signupWithFirebase(
        idToken: idToken,
        fname: fname,
        lname: lname,
        email: email,
        dateOfBirth: dateOfBirth,
        keepSignedIn: keepSignedIn,
      );
      _ref.invalidate(authTokenProvider);
      _ref.invalidate(currentUserProvider);
      _ref.invalidate(keepSignedInProvider);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> signup(
    Map<String, dynamic> data, {
    bool keepSignedIn = true,
  }) async {
    state = const AsyncValue.loading();
    try {
      final response = await _repository.signup(
        data,
        keepSignedIn: keepSignedIn,
      );
      if (response['success'] == true) {
        _ref.invalidate(authTokenProvider);
        _ref.invalidate(currentUserProvider);
        _ref.invalidate(keepSignedInProvider);
      }
      state = const AsyncValue.data(null);
      return response;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
>>>>>>> Stashed changes
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    // Assuming logout is synchronous or fast
    await _repository.logout();
<<<<<<< Updated upstream
    state = const AsyncValue.data(null);
  }
=======
    _ref.invalidate(authTokenProvider);
    _ref.invalidate(currentUserProvider);
    _ref.invalidate(keepSignedInProvider);
    _ref.invalidate(activeProfileIdProvider);
    _ref.invalidate(userProfilesProvider);
    _ref.invalidate(activeProfileProvider);
    _ref.invalidate(apiClientProvider);
    state = const AsyncValue.data(null);
  }

  Future<Map<String, dynamic>?> setupEmail({
    required String email,
    required String fname,
    required String lname,
    required String token,
    bool keepSignedIn = true,
  }) async {
    state = const AsyncValue.loading();
    try {
      final response = await _repository.setupEmail(
        email: email,
        fname: fname,
        lname: lname,
        token: token,
        keepSignedIn: keepSignedIn,
      );
      if (response['status'] == 'success') {
        _ref.invalidate(authTokenProvider);
        _ref.invalidate(currentUserProvider);
        _ref.invalidate(keepSignedInProvider);
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
    bool keepSignedIn = true,
  }) async {
    state = const AsyncValue.loading();
    try {
      final response = await _repository.verifyPhoneLink(
        idToken: idToken,
        token: token,
        keepSignedIn: keepSignedIn,
      );
      if (response['status'] == 'success') {
        _ref.invalidate(authTokenProvider);
        _ref.invalidate(currentUserProvider);
        _ref.invalidate(keepSignedInProvider);
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
      appLog('Exception in checkAvailability: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> requestPasswordResetCode(String email) async {
    state = const AsyncValue.loading();
    try {
      final response = await _repository.requestPasswordResetCode(email);
      state = const AsyncValue.data(null);
      return response;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<Map<String, dynamic>?> resetPassword({
    required String email,
    required String code,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    state = const AsyncValue.loading();
    try {
      final response = await _repository.resetPassword(
        email: email,
        code: code,
        newPassword: newPassword,
        newPasswordConfirmation: newPasswordConfirmation,
      );
      state = const AsyncValue.data(null);
      return response;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }
>>>>>>> Stashed changes
}

class AuthState {
  // Can add specific auth state class if needed later
}
