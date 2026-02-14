import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/api_client.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart'; // To get ApiClient
import '../../data/scan_remote_data_source.dart';
import '../../data/scan_repository.dart';

final scanRemoteDataSourceProvider = Provider<ScanRemoteDataSource>((ref) {
  return ScanRemoteDataSource(ref.watch(apiClientProvider));
});

final scanRepositoryProvider = Provider<ScanRepository>((ref) {
  return ScanRepository(ref.watch(scanRemoteDataSourceProvider));
});

final scanNotifierProvider =
    NotifierProvider<ScanNotifier, AsyncValue<ScanResult?>>(ScanNotifier.new);

class ScanNotifier extends Notifier<AsyncValue<ScanResult?>> {
  late final ScanRepository _repository;

  @override
  AsyncValue<ScanResult?> build() {
    _repository = ref.watch(scanRepositoryProvider);
    return const AsyncData(null);
  }

  Future<void> verifyTicket(String qrCode) async {
    state = const AsyncLoading();
    final result = await _repository.verifyTicket(qrCode);
    state = AsyncData(result);
  }

  void reset() {
    state = const AsyncData(null);
  }
}
