import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_constants.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final SharedPreferences _prefs;

  AuthRepository(this._remoteDataSource, this._prefs);

  Future<void> login(String email, String password) async {
    try {
      // The API seems to have both GET /login (likely for view) and POST /login/submit
      // Checking api.php line 71: Route::post('/login/submit', [CustomerController::class, 'loginSubmit'])
      // We should use the submit endpoint for actual authentication.

<<<<<<< Updated upstream
=======
  Future<Map<String, dynamic>> login(
    String email,
    String password, {
    bool keepSignedIn = true,
  }) async {
    try {
>>>>>>> Stashed changes
      final response = await _remoteDataSource.submitLogin(email, password);

      if (response['status'] == 'success' || response['success'] == true) {
        // Adjust based on actual API response
        final token = response['token'];
        if (token != null) {
          await _prefs.setString(AppConstants.tokenKey, token);
        }
<<<<<<< Updated upstream
        // Save user data if available
        // await _prefs.setString(AppConstants.userKey, jsonEncode(response['user']));
=======

        final customer = response['customer'];
        if (customer != null) {
          await _prefs.setString(AppConstants.userKey, jsonEncode(customer));
        }

        final identities = response['identities'];
        if (identities != null) {
          await _prefs.setString('user_identities_key', jsonEncode(identities));
        }

        final defaultIdentityId = response['default_identity_id'];
        if (defaultIdentityId != null) {
          await _prefs.setString(
            'active_identity_id_key',
            defaultIdentityId.toString(),
          );
        }
        await _prefs.setBool(AppConstants.keepSignedInKey, keepSignedIn);
        return response;
      } else if (response['status'] == 'needs_phone_verification') {
        return response;
>>>>>>> Stashed changes
      } else {
        throw Exception(response['message'] ?? 'Login failed');
      }
    } catch (e) {
      if (e is DioException) {
        throw Exception(_handleDioError(e));
      }
      rethrow;
    }
  }

<<<<<<< Updated upstream
  Future<void> signup(Map<String, dynamic> data) async {
=======
  Future<Map<String, dynamic>> loginWithFirebase(
    String idToken, {
    bool keepSignedIn = true,
  }) async {
    try {
      final response = await _remoteDataSource.loginFirebase(idToken);

      if (response['status'] == 'success') {
        final token = response['token'];
        if (token != null) {
          await _secureStorage.write(
            key: AppConstants.secureTokenKey,
            value: token,
          );
        }

        final customer = response['customer'];
        if (customer != null) {
          await _prefs.setString(AppConstants.userKey, jsonEncode(customer));
        }

        final identities = response['identities'];
        if (identities != null) {
          await _prefs.setString('user_identities_key', jsonEncode(identities));
        }

        final defaultIdentityId = response['default_identity_id'];
        if (defaultIdentityId != null) {
          await _prefs.setString(
            'active_identity_id_key',
            defaultIdentityId.toString(),
          );
        }
        await _prefs.setBool(AppConstants.keepSignedInKey, keepSignedIn);
        return response;
      } else if (response['status'] == 'user_not_found') {
        return response;
      } else if (response['status'] == 'needs_email_setup') {
        return response;
      } else {
        throw Exception(response['message'] ?? 'Firebase Login failed');
      }
    } catch (e) {
      if (e is DioException) {
        throw Exception(_handleDioError(e));
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> signupWithFirebase({
    required String idToken,
    required String fname,
    required String lname,
    required String email,
    String? dateOfBirth,
    bool keepSignedIn = true,
  }) async {
    try {
      final response = await _remoteDataSource.signupFirebase(
        idToken: idToken,
        fname: fname,
        lname: lname,
        email: email,
        dateOfBirth: dateOfBirth,
      );

      if (response['status'] == 'success') {
        final token = response['token'];
        if (token != null) {
          await _secureStorage.write(
            key: AppConstants.secureTokenKey,
            value: token,
          );
        }

        final customer = response['customer'];
        if (customer != null) {
          await _prefs.setString(AppConstants.userKey, jsonEncode(customer));
        }

        final identities = response['identities'];
        if (identities != null) {
          await _prefs.setString('user_identities_key', jsonEncode(identities));
        }

        final defaultIdentityId = response['default_identity_id'];
        if (defaultIdentityId != null) {
          await _prefs.setString(
            'active_identity_id_key',
            defaultIdentityId.toString(),
          );
        }
        await _prefs.setBool(AppConstants.keepSignedInKey, keepSignedIn);
        return response; // RETURN RESPONSE
      } else {
        throw Exception(response['message'] ?? 'Signup failed');
      }
    } catch (e) {
      if (e is DioException) {
        throw Exception(_handleDioError(e));
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> signup(
    Map<String, dynamic> data, {
    bool keepSignedIn = true,
  }) async {
>>>>>>> Stashed changes
    try {
      final response = await _remoteDataSource.signup(data);

      if (response['success'] == true) {
<<<<<<< Updated upstream
        // Signup successful, usually sends verification email or logs in
        // Check if data contains token/user for auto-login
        /*
         if (response['data'] != null) {
            // Auto login logic if API supported returning token on signup
         }
         */
=======
        final token = response['token'];
        if (token != null) {
          await _secureStorage.write(
            key: AppConstants.secureTokenKey,
            value: token,
          );
        }

        final customer = response['data'];
        if (customer != null) {
          await _prefs.setString(AppConstants.userKey, jsonEncode(customer));
        }
        await _prefs.setBool(AppConstants.keepSignedInKey, keepSignedIn);
        return response;
>>>>>>> Stashed changes
      } else {
        throw Exception(response['message'] ?? 'Signup failed');
      }
    } catch (e) {
      if (e is DioException) {
        throw Exception(_handleDioError(e));
      }
      rethrow;
    }
  }

<<<<<<< Updated upstream
  Future<void> logout() async {
    await _prefs.remove(AppConstants.tokenKey);
    await _prefs.remove(AppConstants.userKey);
=======
  Future<Map<String, dynamic>> setupEmail({
    required String email,
    required String fname,
    required String lname,
    required String token,
    bool keepSignedIn = true,
  }) async {
    try {
      final response = await _remoteDataSource.setupEmail(
        email: email,
        fname: fname,
        lname: lname,
        token: token,
      );

      if (response['status'] == 'success') {
        final finalToken = response['token'];
        if (finalToken != null) {
          await _secureStorage.write(
            key: AppConstants.secureTokenKey,
            value: finalToken,
          );
        }

        final customer = response['customer'];
        if (customer != null) {
          await _prefs.setString(AppConstants.userKey, jsonEncode(customer));
        }
        await _prefs.setBool(AppConstants.keepSignedInKey, keepSignedIn);
        return response;
      } else {
        throw Exception(response['message'] ?? 'Email setup failed');
      }
    } catch (e) {
      if (e is DioException) throw Exception(_handleDioError(e));
      rethrow;
    }
  }

  Future<Map<String, dynamic>> verifyPhoneLink({
    required String idToken,
    required String token,
    bool keepSignedIn = true,
  }) async {
    try {
      final response = await _remoteDataSource.verifyPhoneLink(
        idToken: idToken,
        token: token,
      );

      if (response['status'] == 'success') {
        final finalToken = response['token'];
        if (finalToken != null) {
          await _secureStorage.write(
            key: AppConstants.secureTokenKey,
            value: finalToken,
          );
        }

        final customer = response['customer'];
        if (customer != null) {
          await _prefs.setString(AppConstants.userKey, jsonEncode(customer));
        }
        await _prefs.setBool(AppConstants.keepSignedInKey, keepSignedIn);
        return response;
      } else {
        throw Exception(response['message'] ?? 'Phone verification failed');
      }
    } catch (e) {
      if (e is DioException) throw Exception(_handleDioError(e));
      rethrow;
    }
  }

  Future<Map<String, dynamic>> sendEmailVerification() async {
    try {
      final response = await _remoteDataSource.sendEmailVerification();
      return response;
    } catch (e) {
      if (e is DioException) throw Exception(_handleDioError(e));
      rethrow;
    }
  }

  Future<Map<String, dynamic>> verifyEmailOtp(String otp) async {
    try {
      final response = await _remoteDataSource.verifyEmailOtp(otp);
      return response;
    } catch (e) {
      if (e is DioException) throw Exception(_handleDioError(e));
      rethrow;
    }
  }

  Future<Map<String, dynamic>> requestPasswordResetCode(String email) async {
    try {
      return await _remoteDataSource.requestPasswordResetCode(email);
    } catch (e) {
      if (e is DioException) throw Exception(_handleDioError(e));
      rethrow;
    }
  }

  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String code,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    try {
      return await _remoteDataSource.resetPassword(
        email: email,
        code: code,
        newPassword: newPassword,
        newPasswordConfirmation: newPasswordConfirmation,
      );
    } catch (e) {
      if (e is DioException) throw Exception(_handleDioError(e));
      rethrow;
    }
  }

  Future<void> logout() async {
    await _secureStorage.delete(key: AppConstants.tokenKey);
    await _secureStorage.delete(key: AppConstants.secureTokenKey);
    await _prefs.remove(AppConstants.userKey);
    await _prefs.remove(AppConstants.tokenKey);
    await _prefs.remove(AppConstants.userProfilesKey);
    await _prefs.remove(AppConstants.activeProfileIdKey);
    await _prefs.remove('user_identities_key');
    await _prefs.remove('active_identity_id_key');
    await _prefs.remove(AppConstants.keepSignedInKey);
>>>>>>> Stashed changes
  }

  bool isAuthenticated() {
    return _prefs.containsKey(AppConstants.tokenKey);
  }

  String _handleDioError(DioException error) {
    if (error.response != null) {
      final data = error.response?.data;

      // Handle Validation Errors (422)
      if (error.response?.statusCode == 422) {
        if (data is Map<String, dynamic>) {
          if (data['errors'] != null) {
            final errors = data['errors'] as Map<String, dynamic>;
            // Return the first error message found
            if (errors.isNotEmpty) {
              final firstKey = errors.keys.first;
              final firstErrorList = errors[firstKey] as List;
              if (firstErrorList.isNotEmpty) {
                return firstErrorList.first.toString();
              }
            }
          }
          if (data['message'] != null) {
            return data['message'].toString();
          }
        }
      }

      // Handle other Errors
      if (data is Map<String, dynamic> && data['message'] != null) {
        return data['message'].toString();
      }
    }

    return 'Ocurrió un error inesperado de conexión.';
  }
}
