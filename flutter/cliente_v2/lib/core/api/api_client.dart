import 'package:dio/dio.dart';
import '../constants/app_urls.dart';

/// Callback type for session expiration events
typedef SessionExpiredCallback = void Function();

class ApiClient {
  final Dio _dio;
  SessionExpiredCallback? _onSessionExpired;

  ApiClient()
    : _dio = Dio(
        BaseOptions(
          baseUrl: AppUrls.apiBaseUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 60),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onResponse: (response, handler) {
          if (response.statusCode == 401) {
            _handleSessionExpired();
          }
          handler.next(response);
        },
        onError: (DioException error, handler) {
          if (error.response?.statusCode == 401) {
            _handleSessionExpired();
          }
          handler.next(error);
        },
      ),
    );
  }

  Dio get dio => _dio;

  void setToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  void removeToken() {
    _dio.options.headers.remove('Authorization');
  }

  void setProfileId(String profileId) {
    _dio.options.headers['X-Identity-Id'] = profileId;
  }

  void removeProfileId() {
    _dio.options.headers.remove('X-Identity-Id');
  }

  bool get hasToken => _dio.options.headers.containsKey('Authorization');

  /// Set a callback to be notified when the session expires (401)
  void onSessionExpired(SessionExpiredCallback callback) {
    _onSessionExpired = callback;
  }

  void _handleSessionExpired() {
    // Notify the app about the session expiration
    // The individual pages handle the UX (Login Again button)
    _onSessionExpired?.call();
  }
}
