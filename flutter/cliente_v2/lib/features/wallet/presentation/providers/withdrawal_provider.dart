import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import 'wallet_provider.dart';

final withdrawalHistoryProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
      final token = await ref.watch(authTokenProvider.future);
      if (token == null) throw Exception('User not authenticated');

      return ref.watch(walletRepositoryProvider).getWithdrawals(token: token);
    });

class WithdrawalNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  WithdrawalNotifier(this._ref) : super(const AsyncValue.data(null));

  Future<void> requestWithdrawal({
    required double amount,
    required String method,
    required Map<String, dynamic> paymentDetails,
  }) async {
    state = const AsyncValue.loading();

    try {
      final token = await _ref.read(authTokenProvider.future);
      if (token == null) throw Exception('User not authenticated');

      await _ref
          .read(walletRepositoryProvider)
          .requestWithdrawal(
            token: token,
            amount: amount,
            method: method,
            paymentDetails: paymentDetails,
          );

      state = const AsyncValue.data(null);

      // Refresh wallet and history
      _ref.invalidate(walletProvider);
      _ref.invalidate(walletHistoryProvider);
      _ref.invalidate(withdrawalHistoryProvider);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final withdrawalProvider =
    StateNotifierProvider<WithdrawalNotifier, AsyncValue<void>>((ref) {
      return WithdrawalNotifier(ref);
    });
