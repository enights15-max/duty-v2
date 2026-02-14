import 'package:shared_preferences/shared_preferences.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepository(this._remoteDataSource);

  Future<bool> login(
    String username,
    String password, {
    bool isAdmin = false,
  }) async {
    try {
      final response = await _remoteDataSource.login(
        username,
        password,
        isAdmin: isAdmin,
      );

      if (response['status'] == 'success' || response['success'] == true) {
        // Check both formats
        final token = response['token'];
        if (token != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', token);
          await prefs.setBool('is_admin', isAdmin);
          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final isAdmin = prefs.getBool('is_admin') ?? false;
    await _remoteDataSource.logout(isAdmin: isAdmin);
    await prefs.remove('auth_token');
    await prefs.remove('is_admin');
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('auth_token');
  }
}
