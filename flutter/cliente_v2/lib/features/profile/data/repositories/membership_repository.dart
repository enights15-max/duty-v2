import '../datasources/membership_remote_data_source.dart';

class MembershipRepository {
  final MembershipRemoteDataSource _remoteDataSource;

  MembershipRepository(this._remoteDataSource);

  Future<List<dynamic>> getSubscriptionPlans({String? token}) async {
    return await _remoteDataSource.getSubscriptionPlans(token: token);
  }

  Future<String> subscribe(
    String planId, {
    required String successUrl,
    required String cancelUrl,
    String? token,
  }) async {
    return await _remoteDataSource.subscribe(
      planId,
      successUrl: successUrl,
      cancelUrl: cancelUrl,
      token: token,
    );
  }
}
