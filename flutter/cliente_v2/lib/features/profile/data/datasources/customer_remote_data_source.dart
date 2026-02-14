import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';

class CustomerRemoteDataSource {
  final ApiClient _apiClient;

  CustomerRemoteDataSource(this._apiClient);

  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await _apiClient.dio.get('/customers/dashboard');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.post(
        '/customers/update/profile',
        data: data,
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> getBookings() async {
    try {
      final response = await _apiClient.dio.get('/customers/bookings');
      // Assuming response structure contains a list under 'data' or similar
      // Adjusting based on common Laravel API patterns or inspecting controller if needed
      // Logic: response.data['bookings'] or similar
      if (response.data['bookings'] != null &&
          response.data['bookings']['data'] != null) {
        return response.data['bookings']['data'];
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getBookingDetails(String id) async {
    try {
      final response = await _apiClient.dio.get(
        '/customers/booking/details',
        queryParameters: {'booking_id': id},
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
}
