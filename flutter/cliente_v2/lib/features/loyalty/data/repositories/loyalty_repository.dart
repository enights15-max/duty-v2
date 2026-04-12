import '../datasources/loyalty_remote_data_source.dart';
import '../models/loyalty_models.dart';

class LoyaltyRepository {
  final LoyaltyRemoteDataSource _remoteDataSource;

  LoyaltyRepository(this._remoteDataSource);

  Future<LoyaltySummaryModel> getSummary() =>
      _remoteDataSource.getSummary();

  Future<List<LoyaltyHistoryItemModel>> getHistory() =>
      _remoteDataSource.getHistory();

  Future<List<LoyaltyRewardModel>> getRewards() =>
      _remoteDataSource.getRewards();

  Future<List<LoyaltyRedemptionModel>> getRedemptions() =>
      _remoteDataSource.getRedemptions();

  Future<LoyaltyRedeemResult> redeemReward(int rewardId) =>
      _remoteDataSource.redeemReward(rewardId);
}
