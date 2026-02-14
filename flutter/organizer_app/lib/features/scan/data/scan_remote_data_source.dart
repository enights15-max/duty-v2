import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScanRemoteDataSource {
  final ApiClient _apiClient;

  ScanRemoteDataSource(this._apiClient);

  Future<Map<String, dynamic>> verifyTicket(String qrCode) async {
    // Determine if admin or organizer based on stored pref (or check Auth Provider)
    final prefs = await SharedPreferences.getInstance();
    final isAdmin = prefs.getBool('is_admin') ?? false;
    final endpoint = isAdmin
        ? '/admin/check-qrcode'
        : '/organizer/check-qrcode';

    try {
      final response = await _apiClient.dio.post(
        endpoint,
        data: {'booking_id': qrCode},
      );
      return response.data;
    } catch (e) {
      if (e is DioException && e.response != null) {
        return e.response!.data; // Return error data (e.g. "Already scanned")
      }
      rethrow;
    }
  }
}
