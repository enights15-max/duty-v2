import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/wallet_remote_data_source.dart';
import '../../data/models/wallet_transaction_model.dart';
import '../../data/repositories/wallet_repository.dart';

final walletRemoteDataSourceProvider = Provider<WalletRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return WalletRemoteDataSource(apiClient);
});

final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  return WalletRepository(ref.watch(walletRemoteDataSourceProvider));
});

final walletProvider = FutureProvider.autoDispose<Map<String, dynamic>>((
  ref,
) async {
  final token = await ref.watch(authTokenProvider.future);
  if (token == null) {
    throw Exception('User not authenticated');
  }
  return ref.watch(walletRepositoryProvider).getWallet(token: token);
});

final walletHistoryProvider =
    FutureProvider.autoDispose<List<WalletTransactionModel>>((ref) async {
      final token = await ref.watch(authTokenProvider.future);
      if (token == null) {
        throw Exception('User not authenticated');
      }
      return ref.watch(walletRepositoryProvider).getHistory(token: token);
    });
