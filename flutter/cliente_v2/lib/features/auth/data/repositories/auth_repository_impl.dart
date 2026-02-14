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

      final response = await _remoteDataSource.submitLogin(email, password);

      if (response['status'] == 'success' || response['success'] == true) {
        // Adjust based on actual API response
        final token = response['token'];
        if (token != null) {
          await _prefs.setString(AppConstants.tokenKey, token);
        }
        // Save user data if available
        // await _prefs.setString(AppConstants.userKey, jsonEncode(response['user']));
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

  Future<void> signup(Map<String, dynamic> data) async {
    try {
      final response = await _remoteDataSource.signup(data);

      if (response['success'] == true) {
        // Signup successful, usually sends verification email or logs in
        // Check if data contains token/user for auto-login
        /*
         if (response['data'] != null) {
            // Auto login logic if API supported returning token on signup
         }
         */
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

  Future<void> logout() async {
    await _prefs.remove(AppConstants.tokenKey);
    await _prefs.remove(AppConstants.userKey);
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
