import 'package:dio/dio.dart';
import '../../../../../core/api/api_client.dart';
import '../../../../../core/constants/app_urls.dart';
import '../models/loyalty_models.dart';

class LoyaltyRemoteDataSource {
  final ApiClient _apiClient;

  LoyaltyRemoteDataSource(this._apiClient);

  Future<LoyaltySummaryModel> getSummary() async {
    final response = await _apiClient.dio.get(AppUrls.loyaltySummary);
    final body = response.data as Map<String, dynamic>;
    return LoyaltySummaryModel.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<List<LoyaltyHistoryItemModel>> getHistory() async {
    final response = await _apiClient.dio.get(AppUrls.loyaltyHistory);
    final body = response.data as Map<String, dynamic>;
    final items = (body['data'] as Map<String, dynamic>)['items'] as List;
    return items
        .map((e) => LoyaltyHistoryItemModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<LoyaltyRewardModel>> getRewards() async {
    final response = await _apiClient.dio.get(AppUrls.loyaltyRewards);
    final body = response.data as Map<String, dynamic>;
    final items = (body['data'] as Map<String, dynamic>)['items'] as List;
    return items
        .map((e) => LoyaltyRewardModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<LoyaltyRedemptionModel>> getRedemptions() async {
    final response = await _apiClient.dio.get(AppUrls.loyaltyRedemptions);
    final body = response.data as Map<String, dynamic>;
    final items = (body['data'] as Map<String, dynamic>)['items'] as List;
    return items
        .map(
          (e) => LoyaltyRedemptionModel.fromJson(e as Map<String, dynamic>),
        )
        .toList();
  }

  Future<LoyaltyRedeemResult> redeemReward(int rewardId) async {
    try {
      final response = await _apiClient.dio.post(
        AppUrls.loyaltyRedeem(rewardId),
      );
      final body = response.data as Map<String, dynamic>;
      return LoyaltyRedeemResult.fromJson(body['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      final msg = (e.response?.data as Map?)?.containsKey('message') == true
          ? e.response!.data['message'].toString()
          : 'Failed to redeem reward.';
      throw Exception(msg);
    }
  }
}
