import '../../../../core/api/api_client.dart';
import '../models/venue_model.dart';

class VenueRemoteDataSource {
  final ApiClient _apiClient;

  VenueRemoteDataSource(this._apiClient);

  Future<List<VenueModel>> getVenues() async {
    try {
      final response = await _apiClient.dio.get('/venues');
      if (response.data['status'] == 'success' &&
          response.data['data'] != null) {
        final List venuesData = response.data['data'];
        return venuesData.map((e) => VenueModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getVenueDetails(int id) async {
    try {
      final response = await _apiClient.dio.get('/venues/details/$id');
      if (response.data['status'] == 'success' &&
          response.data['data'] != null) {
        return response.data['data'];
      } else {
        throw Exception('Venue not found');
      }
    } catch (e) {
      rethrow;
    }
  }
}
