import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../shop/presentation/providers/checkout_provider.dart';
import '../../../shop/presentation/providers/reservation_provider.dart';
import '../../data/datasources/loyalty_remote_data_source.dart';
import '../../data/models/loyalty_models.dart';
import '../../data/repositories/loyalty_repository.dart';

final loyaltyRemoteDataSourceProvider = Provider<LoyaltyRemoteDataSource>((
  ref,
) {
  final apiClient = ref.watch(apiClientProvider);
  return LoyaltyRemoteDataSource(apiClient);
});

final loyaltyRepositoryProvider = Provider<LoyaltyRepository>((ref) {
  return LoyaltyRepository(ref.watch(loyaltyRemoteDataSourceProvider));
});

final loyaltySummaryProvider = FutureProvider.autoDispose<LoyaltySummaryModel>((
  ref,
) async {
  return ref.watch(loyaltyRepositoryProvider).getSummary();
});

final loyaltyHistoryProvider =
    FutureProvider.autoDispose<List<LoyaltyHistoryItemModel>>((ref) async {
      return ref.watch(loyaltyRepositoryProvider).getHistory();
    });

final loyaltyRewardsProvider =
    FutureProvider.autoDispose<List<LoyaltyRewardModel>>((ref) async {
      return ref.watch(loyaltyRepositoryProvider).getRewards();
    });

final loyaltyRedemptionsProvider =
    FutureProvider.autoDispose<List<LoyaltyRedemptionModel>>((ref) async {
      return ref.watch(loyaltyRepositoryProvider).getRedemptions();
    });

void refreshLoyaltyProviders(Ref ref) {
  ref.invalidate(loyaltySummaryProvider);
  ref.invalidate(loyaltyHistoryProvider);
  ref.invalidate(loyaltyRewardsProvider);
  ref.invalidate(loyaltyRedemptionsProvider);
  // Keep purchase flows in sync after claiming points into bonus wallet.
  ref.invalidate(checkoutProvider);
  ref.invalidate(reservationFlowProvider);
}

class LoyaltyRedeemState {
  final bool isLoading;
  final int? rewardId;
  final String? error;

  const LoyaltyRedeemState({this.isLoading = false, this.rewardId, this.error});
}

final loyaltyRedeemProvider =
    StateNotifierProvider<LoyaltyRedeemNotifier, LoyaltyRedeemState>((ref) {
      return LoyaltyRedeemNotifier(ref.watch(loyaltyRepositoryProvider), ref);
    });

class LoyaltyRedeemNotifier extends StateNotifier<LoyaltyRedeemState> {
  final LoyaltyRepository _repository;
  final Ref _ref;

  LoyaltyRedeemNotifier(this._repository, this._ref)
    : super(const LoyaltyRedeemState());

  Future<LoyaltyRedeemResult> redeem(LoyaltyRewardModel reward) async {
    state = LoyaltyRedeemState(isLoading: true, rewardId: reward.id);

    try {
      final result = await _repository.redeemReward(reward.id);
      refreshLoyaltyProviders(_ref);
      state = const LoyaltyRedeemState();
      return result;
    } catch (error) {
      state = LoyaltyRedeemState(
        isLoading: false,
        rewardId: reward.id,
        error: _extractErrorMessage(error),
      );
      rethrow;
    }
  }

  void clearError() {
    state = const LoyaltyRedeemState();
  }
}

String _extractErrorMessage(Object error) {
  final raw = error.toString();
  if (raw.startsWith('Exception: ')) {
    return raw.substring('Exception: '.length);
  }
  return raw;
}
