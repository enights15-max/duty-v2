import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/constants/app_urls.dart';

class MembershipRemoteDataSource {
  final ApiClient _apiClient;

  MembershipRemoteDataSource(this._apiClient);

  Future<List<dynamic>> getSubscriptionPlans({String? token}) async {
    try {
      final options = Options(
        headers: token != null ? {'Authorization': 'Bearer $token'} : null,
      );

      final response = await _apiClient.dio.get(
        AppUrls.subscriptionPlans,
        options: options,
      );

      if (response.data['status'] == 'success') {
        return response.data['data'] as List;
      }
      throw Exception(response.data['message'] ?? 'Failed to fetch plans');
    } catch (e) {
      rethrow;
    }
  }

  Future<String> subscribe(
    String planId, {
    required String successUrl,
    required String cancelUrl,
    String? token,
  }) async {
    try {
      final options = Options(
        headers: token != null ? {'Authorization': 'Bearer $token'} : null,
      );

      final response = await _apiClient.dio.post(
        AppUrls.subscribe,
        data: {
          'plan_id': planId,
          'success_url': successUrl,
          'cancel_url': cancelUrl,
        },
        options: options,
      );

      if (response.data['status'] == 'success') {
        return response.data['checkout_url'];
      }
      throw Exception(
        response.data['message'] ?? 'Failed to initiate subscription',
      );
    } catch (e) {
      rethrow;
    }
  }
}
