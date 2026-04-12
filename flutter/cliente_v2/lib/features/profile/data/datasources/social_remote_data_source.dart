import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/constants/app_urls.dart';
import '../models/privacy_settings_model.dart';
import '../models/social_feed_model.dart';

class SocialRemoteDataSource {
  final ApiClient _apiClient;

  SocialRemoteDataSource(this._apiClient);

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
    throw Exception('Invalid response payload');
  }

  String _errorPayload(dynamic data) {
    try {
      return jsonEncode(data);
    } catch (_) {
      return '$data';
    }
  }

  Future<Map<String, dynamic>> followEntity(String type, int id) async {
    final response = await _apiClient.dio.post(
      AppUrls.follow,
      data: {'type': type, 'id': id},
      options: _safeOptions(),
    );

    if (response.statusCode == 200) {
      return _asMap(response.data);
    } else {
      throw Exception(
        'Failed to follow entity: ${_errorPayload(response.data)}',
      );
    }
  }

  Future<Map<String, dynamic>> unfollowEntity(String type, int id) async {
    final response = await _apiClient.dio.post(
      AppUrls.unfollow,
      data: {'type': type, 'id': id},
      options: _safeOptions(),
    );

    if (response.statusCode == 200) {
      return _asMap(response.data);
    } else {
      throw Exception(
        'Failed to unfollow entity: ${_errorPayload(response.data)}',
      );
    }
  }

  Future<Map<String, dynamic>> acceptRequest(int requestId) async {
    final response = await _apiClient.dio.post(
      AppUrls.acceptFollowRequest(requestId),
      options: _safeOptions(),
    );

    if (response.statusCode == 200) {
      return _asMap(response.data);
    } else {
      throw Exception(
        'Failed to accept request: ${_errorPayload(response.data)}',
      );
    }
  }

  Future<Map<String, dynamic>> rejectRequest(int requestId) async {
    final response = await _apiClient.dio.post(
      AppUrls.rejectFollowRequest(requestId),
      options: _safeOptions(),
    );

    if (response.statusCode == 200) {
      return _asMap(response.data);
    } else {
      throw Exception(
        'Failed to reject request: ${_errorPayload(response.data)}',
      );
    }
  }

  Future<List<dynamic>> getPendingRequests() async {
    final response = await _apiClient.dio.get(
      AppUrls.pendingFollowRequests,
      options: _safeOptions(),
    );

    if (response.statusCode == 200) {
      final json = _asMap(response.data);
      return json['data'] as List<dynamic>;
    } else {
      throw Exception(
        'Failed to load pending requests: ${_errorPayload(response.data)}',
      );
    }
  }

  Future<SocialFeedModel> getSocialFeed() async {
    final response = await _apiClient.dio.get(
      AppUrls.socialFeed,
      options: _safeOptions(),
    );

    if (response.statusCode == 200) {
      final json = _asMap(response.data);
      return SocialFeedModel.fromJson(
        Map<String, dynamic>.from((json['data'] as Map?) ?? const {}),
      );
    }

    throw Exception(
      'Failed to load social feed: ${_errorPayload(response.data)}',
    );
  }

  Future<List<dynamic>> getUserAttendedEvents(int userId) async {
    final response = await _apiClient.dio.get(
      AppUrls.userAttendedEvents(userId),
      options: _safeOptions(),
    );

    if (response.statusCode == 200) {
      final json = _asMap(response.data);
      return json['data'] as List<dynamic>;
    }
    throw Exception(
      'Failed to load attended events: ${_errorPayload(response.data)}',
    );
  }

  Future<List<dynamic>> getUserUpcomingAttendance(int userId) async {
    final response = await _apiClient.dio.get(
      AppUrls.userUpcomingAttendance(userId),
      options: _safeOptions(),
    );

    if (response.statusCode == 200) {
      final json = _asMap(response.data);
      return json['data'] as List<dynamic>;
    }
    throw Exception(
      'Failed to load upcoming attendance: ${_errorPayload(response.data)}',
    );
  }

  Future<List<dynamic>> getUserInterestedEvents(int userId) async {
    final response = await _apiClient.dio.get(
      AppUrls.userInterestedEvents(userId),
      options: _safeOptions(),
    );

    if (response.statusCode == 200) {
      final json = _asMap(response.data);
      return json['data'] as List<dynamic>;
    }
    throw Exception(
      'Failed to load interested events: ${_errorPayload(response.data)}',
    );
  }

  Future<List<dynamic>> getUserFavorites(int userId) async {
    final response = await _apiClient.dio.get(
      AppUrls.userFavorites(userId),
      options: _safeOptions(),
    );

    if (response.statusCode == 200) {
      final json = _asMap(response.data);
      return json['data'] as List<dynamic>;
    }
    throw Exception(
      'Failed to load favorites: ${_errorPayload(response.data)}',
    );
  }

  Future<List<dynamic>> getUserFollowers(int userId) async {
    final response = await _apiClient.dio.get(
      AppUrls.userFollowers(userId),
      options: _safeOptions(),
    );

    if (response.statusCode == 200) {
      final json = _asMap(response.data);
      return json['data'] as List<dynamic>;
    }
    throw Exception('Failed to load followers.');
  }

  Future<PrivacySettingsModel> getPrivacySettings() async {
    final response = await _apiClient.dio.get(
      AppUrls.privacySettings,
      options: _safeOptions(),
    );

    if (response.statusCode == 200) {
      final json = _asMap(response.data);
      return PrivacySettingsModel.fromJson(
        Map<String, dynamic>.from(json['data'] as Map),
      );
    }

    throw Exception(
      'Failed to load privacy settings: ${_errorPayload(response.data)}',
    );
  }

  Future<PrivacySettingsModel> updatePrivacySettings(
    Map<String, dynamic> payload,
  ) async {
    final response = await _apiClient.dio.put(
      AppUrls.privacySettings,
      data: payload,
      options: _safeOptions(),
    );

    if (response.statusCode == 200) {
      final json = _asMap(response.data);
      return PrivacySettingsModel.fromJson(
        Map<String, dynamic>.from(json['data'] as Map),
      );
    }

    throw Exception(
      'Failed to update privacy settings: ${_errorPayload(response.data)}',
    );
  }
}
