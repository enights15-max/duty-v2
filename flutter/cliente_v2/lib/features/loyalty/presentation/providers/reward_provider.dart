import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/constants/app_urls.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

final rewardProvider =
    StateNotifierProvider<RewardController, AsyncValue<void>>((ref) {
      final apiClient = ref.watch(apiClientProvider);
      return RewardController(apiClient);
    });

class RewardController extends StateNotifier<AsyncValue<void>> {
  final ApiClient _apiClient;

  RewardController(this._apiClient) : super(const AsyncValue.data(null));

  Future<Map<String, dynamic>?> claimReward(String code) async {
    state = const AsyncValue.loading();
    try {
      final response = await _apiClient.dio.post(
        AppUrls.claimReward,
        data: {'claim_code': code, 'reward_claim_code': code},
      );

      state = const AsyncValue.data(null);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e, st) {
      state = AsyncValue.error(e, st);

      final responseData = e.response?.data;
      if (responseData is Map<String, dynamic>) {
        return responseData;
      }

      if (responseData is Map) {
        return Map<String, dynamic>.from(responseData);
      }

      return {
        'status': 'error',
        'message': 'Unable to process reward claim right now.',
      };
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return {
        'status': 'error',
        'message': 'Unable to process reward claim right now.',
      };
    }
  }
}
