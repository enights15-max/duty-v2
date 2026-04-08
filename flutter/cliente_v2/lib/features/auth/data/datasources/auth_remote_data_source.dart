import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';

class AuthRemoteDataSource {
  final ApiClient _apiClient;

  AuthRemoteDataSource(this._apiClient);

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _apiClient.dio.get(
        '/customer/login', // Using GET as per api.php route definition: Route::get('/login', ...)
        queryParameters: {'email': email, 'password': password},
      );

      // Note: The API likely returns a token on successful login.
      // Based on typical Laravel Sanctum & Controller analysis:
      // It might return a token directly or within a data object.
      // We will need to verify the exact response structure.
      return response.data;
    } catch (e) {
      if (e is DioException) {
        // print('Login Error: ${e.response?.statusCode} - ${e.response?.data}');
      }
      rethrow;
    }
  }

  // Example for future use if POST is used or for other auth methods
  Future<Map<String, dynamic>> submitLogin(
    String username,
    String password,
  ) async {
    try {
      // print(
      //   'Autenticando con Usuario: "$username" (Password len: ${password.length})',
      // );
      final response = await _apiClient.dio.post(
        '/customer/login/submit',
        data: {'username': username, 'password': password},
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      return response.data;
    } catch (e) {
      if (e is DioException) {
        // print(
        //   'Login Submit Error: ${e.response?.statusCode} - ${e.response?.data}',
        // );
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> signup(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.post(
        '/customer/signup/submit',
        data: data,
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      return response.data;
    } catch (e) {
      if (e is DioException) {
        // print('Signup Error: ${e.response?.statusCode} - ${e.response?.data}');
      }
      rethrow;
    }
  }
<<<<<<< Updated upstream
=======

  Future<Map<String, dynamic>> loginFirebase(String idToken) async {
    try {
      final response = await _apiClient.dio.post(
        '/customer/login-firebase',
        data: {'idToken': idToken},
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> signupFirebase({
    required String idToken,
    required String fname,
    required String lname,
    required String email,
    String? dateOfBirth,
  }) async {
    final response = await _apiClient.dio.post(
      '/customer/signup-firebase',
      data: {
        'idToken': idToken,
        'fname': fname,
        'lname': lname,
        'email': email,
        'date_of_birth': ?dateOfBirth,
      },
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );
    return response.data;
  }

  Future<Map<String, dynamic>> checkAvailability({
    String? email,
    String? phone,
    String? username,
  }) async {
    final response = await _apiClient.dio.post(
      '/customer/check-availability',
      data: {'email': ?email, 'phone': ?phone, 'username': ?username},
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );
    return response.data;
  }

  Future<Map<String, dynamic>> setupEmail({
    required String email,
    required String fname,
    required String lname,
    required String token,
  }) async {
    final response = await _apiClient.dio.post(
      '/customer/setup-email',
      data: {'email': email, 'fname': fname, 'lname': lname},
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
        headers: token.isNotEmpty ? {'Authorization': 'Bearer $token'} : null,
      ),
    );
    return response.data;
  }

  Future<Map<String, dynamic>> verifyPhoneLink({
    required String idToken,
    required String token,
  }) async {
    final response = await _apiClient.dio.post(
      '/customer/verify-phone-link',
      data: {'idToken': idToken},
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
        headers: token.isNotEmpty ? {'Authorization': 'Bearer $token'} : null,
      ),
    );
    return response.data;
  }

  Future<Map<String, dynamic>> sendEmailVerification() async {
    final response = await _apiClient.dio.post(
      AppUrls.sendEmailVerification,
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );
    return response.data;
  }

  Future<Map<String, dynamic>> verifyEmailOtp(String otp) async {
    final response = await _apiClient.dio.post(
      AppUrls.verifyEmailOtp,
      data: {'otp': otp},
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );
    return response.data;
  }

  Future<Map<String, dynamic>> requestPasswordResetCode(String email) async {
    final response = await _apiClient.dio.post(
      AppUrls.forgetPassword,
      data: {'email': email},
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );
    return response.data;
  }

  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String code,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    final response = await _apiClient.dio.post(
      AppUrls.resetPasswordUpdate,
      data: {
        'email': email,
        'code': code,
        'new_password': newPassword,
        'new_password_confirmation': newPasswordConfirmation,
      },
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );
    return response.data;
  }
>>>>>>> Stashed changes
}
