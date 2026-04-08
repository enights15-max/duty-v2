import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
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
  final String? search;
  final int? categoryId;
  final double? minPrice;
  final double? maxPrice;
  final int? eventId;
  final String? eventTitle;
  final String? eventDate;

  MarketplaceFilterState({
    this.search,
    this.categoryId,
    this.minPrice,
    this.maxPrice,
    this.eventId,
    this.eventTitle,
    this.eventDate,
  });

  MarketplaceFilterState copyWith({
    String? search,
    int? categoryId,
    double? minPrice,
    double? maxPrice,
    int? eventId,
    String? eventTitle,
    String? eventDate,
    bool clearSort = false,
    bool clearSearch = false,
    bool clearCategory = false,
    bool clearMinPrice = false,
    bool clearMaxPrice = false,
    bool clearEventContext = false,
  }) {
    return MarketplaceFilterState(
      search: clearSearch ? null : (search ?? this.search),
      categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
      minPrice: clearMinPrice ? null : (minPrice ?? this.minPrice),
      maxPrice: clearMaxPrice ? null : (maxPrice ?? this.maxPrice),
      eventId: clearEventContext ? null : (eventId ?? this.eventId),
      eventTitle: clearEventContext ? null : (eventTitle ?? this.eventTitle),
      eventDate: clearEventContext ? null : (eventDate ?? this.eventDate),
    );
  }

  bool get hasFilters =>
      (search != null && search!.isNotEmpty) ||
      categoryId != null ||
      minPrice != null ||
      maxPrice != null ||
      eventId != null;
}

final marketplaceFiltersProvider = StateProvider<MarketplaceFilterState>(
  (ref) => MarketplaceFilterState(),
);

final marketplaceTicketsProvider = FutureProvider<List<dynamic>>((ref) async {
  final repository = ref.watch(marketplaceRepositoryProvider);
  final token = ref.watch(authTokenProvider).valueOrNull;
  final filters = ref.watch(marketplaceFiltersProvider);

  return await repository.getMarketplaceTickets(
    token: token,
    search: filters.search,
    categoryId: filters.categoryId,
    minPrice: filters.minPrice,
    maxPrice: filters.maxPrice,
  );

  final filteredByEvent = filters.eventId == null
      ? tickets
      : tickets.where((ticket) {
          final event = ticket['event'];
          final eventId = int.tryParse(event?['id']?.toString() ?? '');
          return eventId == filters.eventId;
        }).toList();

  if (filters.sortBy == null) return filteredByEvent;

  // Sorting logic
  final List<dynamic> sortedTickets = List.from(filteredByEvent);
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

final marketplaceProvider =
    StateNotifierProvider<MarketplaceNotifier, AsyncValue<void>>((ref) {
      final repository = ref.watch(marketplaceRepositoryProvider);
      return MarketplaceNotifier(repository, ref);
    });

class MarketplaceNotifier extends StateNotifier<AsyncValue<void>> {
  final MarketplaceRepository _repository;
  final Ref _ref;
  String? _lastError;
  String? get lastError => _lastError;

  MarketplaceNotifier(this._repository, this._ref)
    : super(const AsyncValue.data(null));

  String _friendlyMarketplaceError(Object error, {bool forPreview = false}) {
    if (error is DioException) {
      final payload = error.response?.data;
      if (payload is Map && payload['message'] != null) {
        return payload['message'].toString();
      }

      return switch (error.response?.statusCode) {
        402 =>
          forPreview
              ? 'No tienes fondos suficientes para cubrir esta reventa con la configuración actual.'
              : 'No tienes fondos suficientes para completar esta reventa.',
        404 => 'Esta reventa ya no está disponible.',
        422 =>
          payload is Map && payload['message'] != null
              ? payload['message'].toString()
              : 'Revisa la tarjeta seleccionada y vuelve a intentarlo.',
        _ =>
          forPreview
              ? 'No pudimos preparar el resumen de esta reventa ahora mismo.'
              : 'No pudimos completar la compra de reventa ahora mismo.',
      };
    }

    return error.toString();
  }

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
    required String recipient,
  }) async {
    state = const AsyncValue.loading();
    try {
      final token = _ref.read(authTokenProvider).valueOrNull;
      await _repository.transferTicket(
        bookingId: bookingId,
        recipient: recipient,
        token: token,
      );
      state = const AsyncValue.data(null);
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

  Future<void> purchaseTicket({
    required int bookingId,
    bool? applyWalletBalance,
    String? stripePaymentMethodId,
  }) async {
    state = const AsyncValue.loading();
    _lastError = null;
    try {
      final token = _ref.read(authTokenProvider).valueOrNull;
      await _repository.purchaseMarketplaceTicket(
        bookingId: bookingId,
        applyWalletBalance: applyWalletBalance,
        stripePaymentMethodId: stripePaymentMethodId,
        token: token,
      );
      state = const AsyncValue.data(null);
      // Refresh tickets list after purchase
      _ref.invalidate(marketplaceTicketsProvider);
    } catch (e, stack) {
      var shouldRefreshListings = false;
      if (e is DioException) {
        final payload = e.response?.data;
        if (payload is Map && payload['message'] != null) {
          _lastError = payload['message'].toString();
        } else if (e.response?.statusCode == 402 ||
            e.response?.statusCode == 404) {
          _lastError = _friendlyMarketplaceError(e);
        } else {
          _lastError = _friendlyMarketplaceError(e);
        }
        if (e.response?.statusCode == 404) {
          shouldRefreshListings = true;
        }
      } else {
        _lastError = e.toString();
      }

      if (shouldRefreshListings) {
        _ref.invalidate(marketplaceTicketsProvider);
        try {
          await _ref.read(marketplaceTicketsProvider.future);
        } catch (_) {
          // Keep the friendly purchase error and swallow the refresh failure.
        }
        state = const AsyncValue.data(null);
        return;
      }

      state = AsyncValue.error(e, stack);
    }
  }

  Future<Map<String, dynamic>?> previewPurchase({
    required int bookingId,
    bool? applyWalletBalance,
    String? stripePaymentMethodId,
  }) async {
    _lastError = null;
    try {
      final token = _ref.read(authTokenProvider).valueOrNull;
      final result = await _repository.previewMarketplaceTicketPurchase(
        bookingId: bookingId,
        applyWalletBalance: applyWalletBalance,
        stripePaymentMethodId: stripePaymentMethodId,
        token: token,
      );

      if (result['success'] == true && result['data'] is Map) {
        return Map<String, dynamic>.from(result['data'] as Map);
      }

      _lastError =
          result['message']?.toString() ??
          'No pudimos preparar el resumen de esta reventa ahora mismo.';
      return null;
    } catch (error) {
      _lastError = _friendlyMarketplaceError(error, forPreview: true);
      if (error is DioException && error.response?.statusCode == 404) {
        _ref.invalidate(marketplaceTicketsProvider);
      }
      return null;
    }
  }
}
