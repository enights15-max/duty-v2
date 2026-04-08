import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/membership_remote_data_source.dart';
import '../../data/repositories/membership_repository.dart';

final membershipRemoteDataSourceProvider = Provider((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return MembershipRemoteDataSource(apiClient);
});

final membershipRepositoryProvider = Provider((ref) {
  final remoteDataSource = ref.watch(membershipRemoteDataSourceProvider);
  return MembershipRepository(remoteDataSource);
});

final subscriptionPlansProvider = FutureProvider<List<dynamic>>((ref) async {
  final repository = ref.watch(membershipRepositoryProvider);
  final token = ref.watch(authTokenProvider).valueOrNull;
  return await repository.getSubscriptionPlans(token: token);
});

final membershipProvider =
    StateNotifierProvider<MembershipNotifier, AsyncValue<String?>>((ref) {
      final repository = ref.watch(membershipRepositoryProvider);
      return MembershipNotifier(repository, ref);
    });

class MembershipNotifier extends StateNotifier<AsyncValue<String?>> {
  final MembershipRepository _repository;
  final Ref _ref;

  MembershipNotifier(this._repository, this._ref)
    : super(const AsyncValue.data(null));

  Future<void> subscribe(
    String planId, {
    required String successUrl,
    required String cancelUrl,
  }) async {
    state = const AsyncValue.loading();
    try {
      final token = _ref.read(authTokenProvider).valueOrNull;
      final checkoutUrl = await _repository.subscribe(
        planId,
        successUrl: successUrl,
        cancelUrl: cancelUrl,
        token: token,
      );
      state = AsyncValue.data(checkoutUrl);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}
