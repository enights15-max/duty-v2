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
}
