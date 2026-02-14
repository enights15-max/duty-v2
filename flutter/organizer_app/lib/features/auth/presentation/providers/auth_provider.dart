import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/api_client.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/repositories/auth_repository.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource(ref.watch(apiClientProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(authRemoteDataSourceProvider));
});

final authNotifierProvider = NotifierProvider<AuthNotifier, AsyncValue<void>>(
  AuthNotifier.new,
);

class AuthNotifier extends Notifier<AsyncValue<void>> {
  late final AuthRepository _repository;

  @override
  AsyncValue<void> build() {
    _repository = ref.watch(authRepositoryProvider);
    return const AsyncData(null);
  }

  Future<bool> login(
    String username,
    String password, {
    bool isAdmin = false,
  }) async {
    state = const AsyncLoading();
    try {
      final success = await _repository.login(
        username,
        password,
        isAdmin: isAdmin,
      );
      if (success) {
        state = const AsyncData(null);
        return true;
      } else {
        state = const AsyncError('Credenciales inválidas', StackTrace.empty);
        return false;
      }
    } catch (e, st) {
      state = AsyncError(e, st);
      return false;
    }
  }

  Future<void> logout() async {
    await _repository.logout();
  }

  Future<bool> checkAuth() async {
    return await _repository.isLoggedIn();
  }
}
