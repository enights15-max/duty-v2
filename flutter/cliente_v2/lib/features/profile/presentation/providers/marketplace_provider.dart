import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/marketplace_remote_data_source.dart';
import '../../data/repositories/marketplace_repository.dart';

final marketplaceRemoteDataSourceProvider = Provider((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return MarketplaceRemoteDataSource(apiClient);
});

final marketplaceRepositoryProvider = Provider((ref) {
  final remoteDataSource = ref.watch(marketplaceRemoteDataSourceProvider);
  return MarketplaceRepository(remoteDataSource);
});

class MarketplaceFilterState {
  final String? sortBy; // 'price_asc', 'price_desc', 'date_asc'
  final String? search;
  final int? categoryId;
  final double? minPrice;
  final double? maxPrice;

  MarketplaceFilterState({
    this.sortBy,
    this.search,
    this.categoryId,
    this.minPrice,
    this.maxPrice,
  });

  MarketplaceFilterState copyWith({
    String? sortBy,
    String? search,
    int? categoryId,
    double? minPrice,
    double? maxPrice,
    bool clearSort = false,
    bool clearSearch = false,
    bool clearCategory = false,
    bool clearMinPrice = false,
    bool clearMaxPrice = false,
  }) {
    return MarketplaceFilterState(
      sortBy: clearSort ? null : (sortBy ?? this.sortBy),
      search: clearSearch ? null : (search ?? this.search),
      categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
      minPrice: clearMinPrice ? null : (minPrice ?? this.minPrice),
      maxPrice: clearMaxPrice ? null : (maxPrice ?? this.maxPrice),
    );
  }

  bool get hasFilters =>
      sortBy != null ||
      (search != null && search!.isNotEmpty) ||
      categoryId != null ||
      minPrice != null ||
      maxPrice != null;
}

final marketplaceFiltersProvider = StateProvider<MarketplaceFilterState>(
  (ref) => MarketplaceFilterState(),
);

final marketplaceTicketsProvider = FutureProvider<List<dynamic>>((ref) async {
  final repository = ref.watch(marketplaceRepositoryProvider);
  final token = ref.watch(authTokenProvider).valueOrNull;
  final filters = ref.watch(marketplaceFiltersProvider);

  final tickets = await repository.getMarketplaceTickets(
    token: token,
    search: filters.search,
    categoryId: filters.categoryId,
    minPrice: filters.minPrice,
    maxPrice: filters.maxPrice,
  );

  if (filters.sortBy == null) return tickets;

  // Sorting logic
  final List<dynamic> sortedTickets = List.from(tickets);
  switch (filters.sortBy) {
    case 'price_asc':
      sortedTickets.sort(
        (a, b) =>
            ((a['price'] ?? 0) as num).compareTo((b['price'] ?? 0) as num),
      );
      break;
    case 'price_desc':
      sortedTickets.sort(
        (a, b) =>
            ((b['price'] ?? 0) as num).compareTo((a['price'] ?? 0) as num),
      );
      break;
    case 'date_asc':
      sortedTickets.sort((a, b) {
        final dateA =
            DateTime.tryParse(a['event']?['date'] ?? '') ?? DateTime(9999);
        final dateB =
            DateTime.tryParse(b['event']?['date'] ?? '') ?? DateTime(9999);
        return dateA.compareTo(dateB);
      });
      break;
  }

  return sortedTickets;
});

/// Provider for pending transfer requests (incoming)
final pendingTransfersProvider = FutureProvider<List<dynamic>>((ref) async {
  final repository = ref.watch(marketplaceRepositoryProvider);
  final token = ref.watch(authTokenProvider).valueOrNull;
  return await repository.getPendingTransfers(token: token);
});

final pendingTransfersCountProvider = Provider<int>((ref) {
  final asyncTransfers = ref.watch(pendingTransfersProvider);
  return asyncTransfers.maybeWhen(
    data: (transfers) => transfers.length,
    orElse: () => 0,
  );
});

final outboxTransfersProvider = FutureProvider<List<dynamic>>((ref) async {
  final repository = ref.watch(marketplaceRepositoryProvider);
  final token = ref.watch(authTokenProvider).valueOrNull;
  return await repository.getOutboxTransfers(token: token);
});

final transferDetailsProvider =
    FutureProvider.family<Map<String, dynamic>?, int>((ref, transferId) async {
      final repository = ref.watch(marketplaceRepositoryProvider);
      final token = ref.watch(authTokenProvider).valueOrNull;
      final result = await repository.getTransferDetails(
        transferId: transferId,
        token: token,
      );
      if (result['success'] == true) {
        return result['data'] as Map<String, dynamic>;
      }
      return null;
    });

final marketplaceProvider =
    StateNotifierProvider<MarketplaceNotifier, AsyncValue<void>>((ref) {
      final repository = ref.watch(marketplaceRepositoryProvider);
      return MarketplaceNotifier(repository, ref);
    });

class MarketplaceNotifier extends StateNotifier<AsyncValue<void>> {
  final MarketplaceRepository _repository;
  final Ref _ref;

  MarketplaceNotifier(this._repository, this._ref)
    : super(const AsyncValue.data(null));

  /// Verify if a recipient user exists
  Future<Map<String, dynamic>?> verifyRecipient({
    String? recipient,
    int? recipientId,
  }) async {
    try {
      final token = _ref.read(authTokenProvider).valueOrNull;
      final result = await _repository.verifyRecipient(
        recipient: recipient,
        recipientId: recipientId,
        token: token,
      );
      if (result['success'] == true) {
        return result['data'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Send a transfer request (now creates a pending request)
  Future<void> transferTicket({
    required int bookingId,
    String? recipient,
    int? recipientId,
  }) async {
    state = const AsyncValue.loading();
    try {
      final token = _ref.read(authTokenProvider).valueOrNull;
      await _repository.transferTicket(
        bookingId: bookingId,
        recipient: recipient,
        recipientId: recipientId,
        token: token,
      );
      state = const AsyncValue.data(null);
      _ref.invalidate(outboxTransfersProvider);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<Map<String, dynamic>?> getTransferTicketQr({
    required int bookingId,
  }) async {
    try {
      final token = _ref.read(authTokenProvider).valueOrNull;
      final result = await _repository.getTransferTicketQr(
        bookingId: bookingId,
        token: token,
      );
      if (result['success'] == true) {
        return result['data'] as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> requestTransferFromScan({
    required String transferToken,
  }) async {
    state = const AsyncValue.loading();
    try {
      final token = _ref.read(authTokenProvider).valueOrNull;
      final result = await _repository.requestTransferFromScan(
        transferToken: transferToken,
        token: token,
      );
      state = const AsyncValue.data(null);
      _ref.invalidate(pendingTransfersProvider);
      _ref.invalidate(outboxTransfersProvider);
      return result['data'] as Map<String, dynamic>?;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return null;
    }
  }

  /// Accept an incoming transfer request
  Future<void> acceptTransfer({required int transferId}) async {
    state = const AsyncValue.loading();
    try {
      final token = _ref.read(authTokenProvider).valueOrNull;
      await _repository.acceptTransfer(transferId: transferId, token: token);
      state = const AsyncValue.data(null);
      _ref.invalidate(pendingTransfersProvider);
      _ref.invalidate(outboxTransfersProvider);
      _ref.invalidate(transferDetailsProvider(transferId));
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Reject an incoming transfer request
  Future<void> rejectTransfer({required int transferId}) async {
    state = const AsyncValue.loading();
    try {
      final token = _ref.read(authTokenProvider).valueOrNull;
      await _repository.rejectTransfer(transferId: transferId, token: token);
      state = const AsyncValue.data(null);
      _ref.invalidate(pendingTransfersProvider);
      _ref.invalidate(outboxTransfersProvider);
      _ref.invalidate(transferDetailsProvider(transferId));
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Cancel a transfer request (sender side)
  Future<void> cancelTransfer({required int transferId}) async {
    state = const AsyncValue.loading();
    try {
      final token = _ref.read(authTokenProvider).valueOrNull;
      await _repository.cancelTransfer(transferId: transferId, token: token);
      state = const AsyncValue.data(null);
      _ref.invalidate(pendingTransfersProvider);
      _ref.invalidate(outboxTransfersProvider);
      _ref.invalidate(transferDetailsProvider(transferId));
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> listTicket({
    required int bookingId,
    required double price,
    required bool isListed,
  }) async {
    state = const AsyncValue.loading();
    try {
      final token = _ref.read(authTokenProvider).valueOrNull;
      await _repository.listTicket(
        bookingId: bookingId,
        price: price,
        isListed: isListed,
        token: token,
      );
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> purchaseTicket({required int bookingId}) async {
    state = const AsyncValue.loading();
    try {
      final token = _ref.read(authTokenProvider).valueOrNull;
      await _repository.purchaseMarketplaceTicket(
        bookingId: bookingId,
        token: token,
      );
      state = const AsyncValue.data(null);
      // Refresh tickets list after purchase
      _ref.invalidate(marketplaceTicketsProvider);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final favoritesProvider = StateNotifierProvider<FavoritesNotifier, Set<String>>(
  (ref) {
    return FavoritesNotifier();
  },
);

class FavoritesNotifier extends StateNotifier<Set<String>> {
  static const _key = 'marketplace_favorites';

  FavoritesNotifier() : super({}) {
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    state = list.toSet();
  }

  Future<void> toggleFavorite(String ticketId) async {
    final newState = Set<String>.from(state);
    if (newState.contains(ticketId)) {
      newState.remove(ticketId);
    } else {
      newState.add(ticketId);
    }
    state = newState;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, newState.toList());
  }

  bool isFavorite(String ticketId) => state.contains(ticketId);
}
