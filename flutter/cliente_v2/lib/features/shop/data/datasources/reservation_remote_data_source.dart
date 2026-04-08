import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/constants/app_urls.dart';

class ReservationRemoteDataSource {
  final ApiClient _apiClient;

  ReservationRemoteDataSource(this._apiClient);

  Options _safeOptions() =>
      Options(validateStatus: (status) => status != null && status < 500);

  Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    if (data is String) {
      final decoded = jsonDecode(data);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    }
    throw Exception('Invalid reservation payload');
  }

  String _errorPayload(dynamic data) {
    try {
      return jsonEncode(data);
    } catch (_) {
      return '$data';
    }
  }

  Future<List<dynamic>> getReservations() async {
    final response = await _apiClient.dio.get(
      AppUrls.reservations,
      options: _safeOptions(),
    );

    if (response.statusCode == 200) {
      final payload = _asMap(response.data);
      return payload['reservations'] as List<dynamic>? ?? const [];
    }

    throw Exception(
      'Failed to load reservations: ${_errorPayload(response.data)}',
    );
  }

  Future<Map<String, dynamic>> getReservation(int id) async {
    final response = await _apiClient.dio.get(
      AppUrls.reservationDetails(id),
      options: _safeOptions(),
    );

    if (response.statusCode == 200) {
      final payload = _asMap(response.data);
      return Map<String, dynamic>.from(payload['reservation'] as Map);
    }

    throw Exception(
      'Failed to load reservation: ${_errorPayload(response.data)}',
    );
  }

  Future<Map<String, dynamic>> createReservation(
    Map<String, dynamic> payload,
  ) async {
    final response = await _apiClient.dio.post(
      AppUrls.reservations,
      data: payload,
      options: _safeOptions(),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final json = _asMap(response.data);
      if (json['success'] == true && json['reservation'] is Map) {
        return Map<String, dynamic>.from(json['reservation'] as Map);
      }
    }

    final payloadMap = _asMap(response.data);
    throw Exception(
      payloadMap['message']?.toString() ?? _errorPayload(response.data),
    );
  }

  Future<Map<String, dynamic>> previewReservation(
    Map<String, dynamic> payload,
  ) async {
    final response = await _apiClient.dio.post(
      AppUrls.reservationPreview,
      data: payload,
      options: _safeOptions(),
    );

    final payloadMap = _asMap(response.data);
    if (response.statusCode == 200 && payloadMap['success'] == true) {
      return Map<String, dynamic>.from(payloadMap['data'] as Map? ?? const {});
    }

    throw Exception(
      payloadMap['message']?.toString() ?? _errorPayload(response.data),
    );
  }

  Future<Map<String, dynamic>> payReservation(
    int reservationId,
    Map<String, dynamic> payload,
  ) async {
    final response = await _apiClient.dio.post(
      AppUrls.reservationPay(reservationId),
      data: payload,
      options: _safeOptions(),
    );

    if (response.statusCode == 200) {
      final json = _asMap(response.data);
      if (json['success'] == true && json['reservation'] is Map) {
        return Map<String, dynamic>.from(json['reservation'] as Map);
      }
    }

    final payloadMap = _asMap(response.data);
    throw Exception(
      payloadMap['message']?.toString() ?? _errorPayload(response.data),
    );
  }

  Future<Map<String, dynamic>> previewReservationPayment(
    int reservationId,
    Map<String, dynamic> payload,
  ) async {
    final response = await _apiClient.dio.post(
      AppUrls.reservationPayPreview(reservationId),
      data: payload,
      options: _safeOptions(),
    );

    final payloadMap = _asMap(response.data);
    if (response.statusCode == 200 && payloadMap['success'] == true) {
      return Map<String, dynamic>.from(payloadMap['data'] as Map? ?? const {});
    }

    throw Exception(
      payloadMap['message']?.toString() ?? _errorPayload(response.data),
    );
  }
}
