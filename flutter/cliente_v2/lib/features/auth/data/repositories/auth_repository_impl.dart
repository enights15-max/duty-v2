import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_urls.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final SharedPreferences _prefs;
  final FlutterSecureStorage _secureStorage;

  AuthRepository(this._remoteDataSource, this._prefs, this._secureStorage);

  List<dynamic> _hydrateIdentityAvatars(
    dynamic rawIdentities,
    Map<String, dynamic>? customer,
  ) {
    if (rawIdentities is! List) {
      return const [];
    }

    final personalAvatarUrl = AppUrls.getCustomerAvatarUrl(customer);

    return rawIdentities.map((item) {
      if (item is! Map) {
        return item;
      }

      final next = Map<String, dynamic>.from(item);
      final type = next['type']?.toString();
      if (type == 'personal' &&
          personalAvatarUrl != null &&
          (next['avatar_url'] == null ||
              next['avatar_url'].toString().trim().isEmpty)) {
        next['avatar_url'] = personalAvatarUrl;
      }
      return next;
    }).toList();
  }

  Future<void> _persistSessionPayload(
    Map<String, dynamic> response, {
    required bool keepSignedIn,
  }) async {
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

    final identities = _hydrateIdentityAvatars(
      response['identities'],
      customer is Map<String, dynamic>
          ? customer
          : customer is Map
          ? Map<String, dynamic>.from(customer)
          : null,
    );
    if (identities.isNotEmpty) {
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
  }

  Future<Map<String, dynamic>> checkAvailability({
    String? email,
    String? phone,
    String? username,
  }) async {
    try {
      final response = await _remoteDataSource.checkAvailability(
        email: email,
        phone: phone,
        username: username,
      );
      return response;
    } catch (e) {
      if (e is DioException) {
        throw Exception(_handleDioError(e));
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _remoteDataSource.submitLogin(email, password);

      if (response['status'] == 'success' || response['success'] == true) {
        await _persistSessionPayload(response, keepSignedIn: keepSignedIn);
        return response;
      } else if (response['status'] == 'needs_phone_verification') {
        return response;
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

  Future<Map<String, dynamic>> loginWithFirebase(String idToken) async {
    try {
      final response = await _remoteDataSource.loginFirebase(idToken);

      if (response['status'] == 'success') {
        await _persistSessionPayload(response, keepSignedIn: keepSignedIn);
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
        await _persistSessionPayload(response, keepSignedIn: keepSignedIn);
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

  Future<Map<String, dynamic>> signup(Map<String, dynamic> data) async {
    try {
      final response = await _remoteDataSource.signup(data);

      if (response['success'] == true) {
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
        return response;
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

  Future<Map<String, dynamic>> setupEmail({
    required String email,
    required String fname,
    required String lname,
    required String token,
  }) async {
    try {
      final response = await _remoteDataSource.setupEmail(
        email: email,
        fname: fname,
        lname: lname,
        token: token,
      );

      if (response['status'] == 'success') {
        await _persistSessionPayload(response, keepSignedIn: keepSignedIn);
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
  }) async {
    try {
      final response = await _remoteDataSource.verifyPhoneLink(
        idToken: idToken,
        token: token,
      );

      if (response['status'] == 'success') {
        await _persistSessionPayload(response, keepSignedIn: keepSignedIn);
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

  Future<void> logout() async {
    await _secureStorage.delete(key: AppConstants.secureTokenKey);
    await _prefs.remove(AppConstants.userKey);
    await _prefs.remove('user_identities_key');
    await _prefs.remove('active_identity_id_key');
  }

  Future<bool> isAuthenticated() async {
    final token = await _secureStorage.read(key: AppConstants.secureTokenKey);
    return token != null;
  }

  Future<String?> getToken() async {
    return await _secureStorage.read(key: AppConstants.secureTokenKey);
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
