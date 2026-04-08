import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/constants/app_urls.dart';

class CustomerRemoteDataSource {
  final ApiClient _apiClient;

  CustomerRemoteDataSource(this._apiClient);

  Map<String, dynamic>? _decodeJsonMap(dynamic body) {
    if (body is Map<String, dynamic>) return body;
    if (body is Map) return Map<String, dynamic>.from(body);
    if (body is String) {
      final trimmed = body.trim();
      if (trimmed.isEmpty) return null;
      if (!(trimmed.startsWith('{') || trimmed.startsWith('['))) {
        return null;
      }
      final decoded = jsonDecode(trimmed);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    }
    return null;
  }

  String _nonJsonResponseMessage(dynamic body, {int? statusCode}) {
    final source = body?.toString().trim() ?? '';
    if (source.isEmpty) {
      return 'El servidor devolvió una respuesta vacía.';
    }

    final compact = source.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (compact.startsWith('<!DOCTYPE') ||
        compact.startsWith('<html') ||
        compact.startsWith('<')) {
      return statusCode != null && statusCode >= 400
          ? 'El servidor devolvió una página HTML en vez de JSON (HTTP $statusCode).'
          : 'El servidor devolvió una respuesta HTML inesperada.';
    }

    return compact.length > 220 ? '${compact.substring(0, 220)}…' : compact;
  }

  Future<Map<String, dynamic>> getProfile({String? token}) async {
    try {
      final options = Options(
        validateStatus: (status) => status != null && status < 500,
        headers: token != null ? {'Authorization': 'Bearer $token'} : null,
      );

      final response = await _apiClient.dio.get(
        AppUrls.dashboard,
        options: options,
      );

      if (response.statusCode == 401) {
        throw Exception('Unauthorized');
      }

      Map<String, dynamic> responseData;
      if (response.data is String) {
        responseData = jsonDecode(response.data) as Map<String, dynamic>;
      } else {
        responseData = response.data as Map<String, dynamic>;
      }

      final data = responseData['data'];
      if (data == null) throw Exception('Invalid profile data');

      final authUser = data['authUser'];
      final bookings = data['bookings'] as List?;

      return {
        'name': '${authUser['fname']} ${authUser['lname']}',
        'username': authUser['username'],
        'email': authUser['email'],
        'avatar': authUser['photo'] != null
            ? '${AppUrls.profileImageBaseUrl}${authUser['photo']}'
            : null,
        'created_at': authUser['created_at'],
        'balance': authUser['amount'] ?? 0,
        'is_vip': authUser['is_vip'] ?? false,
        'stats': {
          'events_count': bookings?.length ?? 0,
          'artists_count': 0,
          'communities_count': 0,
        },
        'raw_user': authUser,
      };
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateProfile(
    dynamic data, {
    String? token,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        AppUrls.updateProfile,
        data: data,
        options: Options(
          validateStatus: (status) => status != null && status < 500,
          headers: {if (token != null) 'Authorization': 'Bearer $token'},
          contentType: data is FormData ? 'multipart/form-data' : null,
          responseType: ResponseType.plain,
        ),
      );

      final body = _decodeJsonMap(response.data);
      if (body != null) {
        if ((response.statusCode ?? 0) >= 400) {
          final msg = body['message']?.toString().trim();
          final errors = body['errors'];
          if (errors is Map && errors.isNotEmpty) {
            final first = errors.values.first;
            throw Exception(
              first is List ? first.first.toString() : first.toString(),
            );
          }
          if (msg != null && msg.isNotEmpty) {
            throw Exception(msg);
          }
          throw Exception('Error ${response.statusCode}');
        }
        return body;
      }

      throw Exception(
        _nonJsonResponseMessage(response.data, statusCode: response.statusCode),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> getBookings({String? token}) async {
    try {
      final headers = <String, dynamic>{
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final options = Options(
        validateStatus: (status) => status != null && status < 500,
        headers: headers,
      );

      print(
        'DEBUG BOOKINGS: Sending token=${token != null ? "${token.substring(0, 10)}..." : "NONE"}',
      );

      final response = await _apiClient.dio.get(
        AppUrls.bookings,
        options: options,
      );

      print(
        'DEBUG BOOKINGS: status=${response.statusCode} dataType=${response.data.runtimeType}',
      );
      if (response.statusCode == 401) {
        print('DEBUG BOOKINGS: 401 response body=${response.data}');
      }

      if (response.statusCode == 401) {
        throw Exception('Unauthorized');
      }

      // Handle string responses (e.g. HTML redirects)
      dynamic data = response.data;
      if (data is String) {
        try {
          data = jsonDecode(data);
        } catch (_) {
          print(
            'DEBUG BOOKINGS: Response was non-JSON string: ${data.substring(0, 200)}',
          );
          return [];
        }
      }

      List<dynamic> bookingsList = [];

      if (data is Map<String, dynamic>) {
        // Backend returns { success, data: { bookings: [...] } }
        final innerData = data['data'];
        final bookingsRaw =
            (innerData is Map ? innerData['bookings'] : null) ??
            data['bookings'];

        print(
          'DEBUG BOOKINGS: innerData type=${innerData.runtimeType}, bookingsRaw type=${bookingsRaw.runtimeType}',
        );

        if (bookingsRaw is List) {
          bookingsList = bookingsRaw;
        } else if (bookingsRaw is Map) {
          bookingsList = bookingsRaw.values.toList();
        } else if (innerData is List) {
          bookingsList = innerData;
        }
      }

      print('DEBUG BOOKINGS: parsed ${bookingsList.length} bookings');
      return bookingsList;
    } catch (e) {
      print('DEBUG BOOKINGS ERROR: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getBookingDetails(
    String id, {
    String? token,
  }) async {
    try {
      final intId = int.tryParse(id);
      if (intId == null) throw Exception('Invalid Booking ID');

      final options = Options(
        validateStatus: (status) => status != null && status < 500,
        headers: token != null ? {'Authorization': 'Bearer $token'} : null,
      );

      final response = await _apiClient.dio.get(
        AppUrls.bookingDetails(intId),
        options: options,
      );

      if (response.statusCode == 401) {
        throw Exception('Unauthorized');
      }

      final data = response.data;
      if (data is Map<String, dynamic>) {
        return data['data'] ?? data;
      }
      return data;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> getIdentities() async {
    try {
      final response = await _apiClient.dio.get(
        AppUrls.identities,
        options: Options(
          validateStatus: (status) => status != null && status < 500,
          responseType: ResponseType.plain,
        ),
      );

      final data = _decodeJsonMap(response.data);
      if (data != null) {
        final identities = data['identities'];
        if (identities is List) {
          return identities;
        }
        if ((response.statusCode ?? 0) >= 400) {
          throw Exception(
            data['message']?.toString() ?? 'Failed to load identities',
          );
        }
        return [];
      }

      if ((response.statusCode ?? 0) >= 400) {
        throw Exception(
          _nonJsonResponseMessage(
            response.data,
            statusCode: response.statusCode,
          ),
        );
      }

      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> requestIdentity(
    dynamic data, {
    String? token,
  }) async {
    try {
      final options = Options(
        validateStatus: (status) => status != null && status < 500,
        headers: {if (token != null) 'Authorization': 'Bearer $token'},
        contentType: data is FormData ? 'multipart/form-data' : null,
        responseType: ResponseType.plain,
      );

      final response = await _apiClient.dio.post(
        AppUrls.requestIdentity,
        data: data,
        options: options,
      );

      final body = _decodeJsonMap(response.data);

      if (body != null) {
        if ((response.statusCode ?? 0) >= 400) {
          final msg = body['message']?.toString().trim();
          final errors = body['errors'];
          // Handle errors as List (from validateMeta)
          if (errors is List && errors.isNotEmpty) {
            throw Exception(errors.first.toString());
          }
          // Handle errors as Map (from Laravel validator)
          if (errors is Map && errors.isNotEmpty) {
            final first = errors.values.first;
            throw Exception(
              first is List ? first.first.toString() : first.toString(),
            );
          }
          if (msg != null && msg.isNotEmpty) throw Exception(msg);
          throw Exception('Error ${response.statusCode}');
        }
        return body;
      }

      throw Exception(
        _nonJsonResponseMessage(response.data, statusCode: response.statusCode),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateIdentity(
    String id,
    dynamic data, {
    String? token,
  }) async {
    try {
      final options = Options(
        validateStatus: (status) => status != null && status < 500,
        headers: {if (token != null) 'Authorization': 'Bearer $token'},
        contentType: data is FormData ? 'multipart/form-data' : null,
        responseType: ResponseType.plain,
      );

      final response = data is FormData
          ? await _apiClient.dio.post(
              AppUrls.updateIdentity(id),
              data: data..fields.add(const MapEntry('_method', 'PATCH')),
              options: options,
            )
          : await _apiClient.dio.patch(
              AppUrls.updateIdentity(id),
              data: data,
              options: options,
            );

      final body = _decodeJsonMap(response.data);

      if (body != null) {
        if ((response.statusCode ?? 0) >= 400) {
          final msg = body['message']?.toString().trim();
          final errors = body['errors'];
          // Handle errors as List (from validateMeta)
          if (errors is List && errors.isNotEmpty) {
            throw Exception(errors.first.toString());
          }
          // Handle errors as Map (from Laravel validator)
          if (errors is Map && errors.isNotEmpty) {
            final first = errors.values.first;
            throw Exception(
              first is List ? first.first.toString() : first.toString(),
            );
          }
          if (msg != null && msg.isNotEmpty) throw Exception(msg);
          throw Exception('Error ${response.statusCode}');
        }
        return body;
      }

      throw Exception(
        _nonJsonResponseMessage(response.data, statusCode: response.statusCode),
      );
    } catch (e) {
      rethrow;
    }
  }
}
