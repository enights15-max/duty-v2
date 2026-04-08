import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';

class BookingRemoteDataSource {
  final ApiClient _apiClient;

  BookingRemoteDataSource(this._apiClient);

  Future<Map<String, dynamic>> verifyCheckout(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.post(
        '/event/checkout-verify',
        data: data,
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> bookTicket(
    Map<String, dynamic> bookingData,
  ) async {
    try {
      // Endpoint identified: /event-booking (api.event.booking.store)
      final response = await _apiClient.dio.post(
        '/event-booking',
        data: bookingData,
      );
      return response.data;
<<<<<<< Updated upstream
=======
      // Expected response for Stripe:
      // {
      //   "status": "success",
      //   "client_secret": "pi_...",
      //   "ephemeral_key": "ek_...",
      //   "customer_id": "cus_..."
      // }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> applyCoupon(Map<String, dynamic> data) async {
    try {
      final response = await _apiClient.dio.post(
        AppUrls.eventCouponApply,
        data: data,
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getPaymentMethods() async {
    try {
      final response = await _apiClient.dio.get(
        '${AppUrls.apiBaseUrl}/customers/payment-methods',
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createSetupIntent() async {
    try {
      final response = await _apiClient.dio.post(
        '${AppUrls.apiBaseUrl}/customers/payment-methods/setup-intent',
      );
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getWallet() async {
    try {
      final response = await _apiClient.dio.get(AppUrls.wallet);
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getBonusWallet() async {
    try {
      final response = await _apiClient.dio.get(AppUrls.bonusWallet);
      return response.data;
>>>>>>> Stashed changes
    } catch (e) {
      rethrow;
    }
  }
}
