import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';

class AuthRemoteDataSource {
  final ApiClient _apiClient;

  AuthRemoteDataSource(this._apiClient);

  Future<Map<String, dynamic>> login(
    String username,
    String password, {
    bool isAdmin = false,
  }) async {
    final endpoint = isAdmin
        ? '/admin/login/submit'
        : '/organizer/login/submit';
    try {
      final response = await _apiClient.dio.post(
        endpoint,
        data: {
          'username': username,
          'password': password,
          'device_name': 'mobile_app',
        },
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout({bool isAdmin = false}) async {
    final endpoint = isAdmin ? '/admin/logout' : '/organizer/logout';
    try {
      await _apiClient.dio.post(endpoint);
    } catch (e) {
      // Ignore logout errors
    }
  }
}
