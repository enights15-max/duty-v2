import '../../../../core/api/api_client.dart';
import '../models/event_model.dart';
import '../models/event_detail_model.dart';

class EventRemoteDataSource {
  final ApiClient _apiClient;

  EventRemoteDataSource(this._apiClient);

  Future<List<EventModel>> getEvents() async {
    try {
      final response = await _apiClient.dio.get('/events');

      if (response.data['success'] == true && response.data['data'] != null) {
        final eventsData = response.data['data']['events'] as List;
        return eventsData.map((e) => EventModel.fromJson(e)).toList();
      } else {
        return [];
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<EventDetailModel> getEventDetails(int id) async {
    try {
      final response = await _apiClient.dio.get(
        '/events/details',
        queryParameters: {'event_id': id},
      );
      if (response.data['success'] == true && response.data['data'] != null) {
        return EventDetailModel.fromJson(response.data['data']);
      } else {
        throw Exception('Event not found');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> getCategories() async {
    try {
      final response = await _apiClient.dio.get('/events/categories');
      if (response.data['success'] == true && response.data['data'] != null) {
        return response.data['data']['categories'] as List;
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }
}
