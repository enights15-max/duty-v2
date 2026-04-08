import '../../../../core/api/api_client.dart';
import '../../../../core/constants/app_urls.dart';

class OrganizerRemoteDataSource {
  final ApiClient _apiClient;

  OrganizerRemoteDataSource(this._apiClient);

  Future<Map<String, dynamic>> getOrganizerDetails(int id) async {
    try {
      final response = await _apiClient.dio.get(
        '${AppUrls.apiBaseUrl}/organizers/details/$id',
        queryParameters: id == 0 ? {'admin': '1'} : null,
      );

      if (response.data['success'] == true) {
        return response.data['data'];
      } else {
        throw Exception('Failed to load organizer details');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> followOrganizer(int id) async {
    try {
      final response = await _apiClient.dio.post(
        '${AppUrls.apiBaseUrl}/organizers/follow',
        data: {
          'id': id,
          'type': 'organizer',
        },
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> unfollowOrganizer(int id) async {
    try {
      final response = await _apiClient.dio.post(
        '${AppUrls.apiBaseUrl}/organizers/unfollow',
        data: {
          'id': id,
          'type': 'organizer',
        },
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> getFollowedEvents() async {
    try {
      final response = await _apiClient.dio.get(
        '${AppUrls.apiBaseUrl}/organizers/followed-events',
      );

      if (response.data['success'] == true) {
        return response.data['data'];
      } else {
        throw Exception('Failed to load followed events');
      }
    } catch (e) {
      rethrow;
    }
  }
}
