import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/constants/app_urls.dart';

class MarketplaceRemoteDataSource {
  final ApiClient _apiClient;

  MarketplaceRemoteDataSource(this._apiClient);

  Future<Map<String, dynamic>> transferTicket({
    required int bookingId,
    required String recipient,
    String? token,
  }) async {
    try {
      final options = Options(
        headers: token != null ? {'Authorization': 'Bearer $token'} : null,
      );

      final response = await _apiClient.dio.post(
        AppUrls.transferTicket(bookingId),
        data: {'recipient': recipient},
        options: options,
      );

      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> listTicket({
    required int bookingId,
    required double price,
    required bool isListed,
    String? token,
  }) async {
    try {
      final options = Options(
        headers: token != null ? {'Authorization': 'Bearer $token'} : null,
      );

      final response = await _apiClient.dio.post(
        AppUrls.listTicket(bookingId),
        data: {'price': price, 'is_listed': isListed},
        options: options,
      );

      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> getMarketplaceTickets({
    String? token,
    String? search,
    int? categoryId,
    double? minPrice,
    double? maxPrice,
  }) async {
    try {
      final options = Options(
        headers: token != null ? {'Authorization': 'Bearer $token'} : null,
      );

      final queryParameters = <String, dynamic>{};
      if (search != null && search.isNotEmpty)
        queryParameters['search'] = search;
      if (categoryId != null) queryParameters['category_id'] = categoryId;
      if (minPrice != null) queryParameters['min_price'] = minPrice;
      if (maxPrice != null) queryParameters['max_price'] = maxPrice;

      final response = await _apiClient.dio.get(
        AppUrls.marketplaceTickets,
        queryParameters: queryParameters,
        options: options,
      );

      if (response.data != null && response.data['data'] is List) {
        return response.data['data'];
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> purchaseMarketplaceTicket({
    required int bookingId,
    bool? applyWalletBalance,
    String? stripePaymentMethodId,
    String? token,
  }) async {
    try {
      final options = Options(
        headers: token != null ? {'Authorization': 'Bearer $token'} : null,
      );

      final response = await _apiClient.dio.post(
        AppUrls.purchaseMarketplaceTicket(bookingId),
        data: {
          ...?applyWalletBalance?.let(
            (value) => {'apply_wallet_balance': value},
          ),
          ...?stripePaymentMethodId?.let(
            (value) => {'stripe_payment_method_id': value},
          ),
        },
        options: options,
      );

      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> previewMarketplaceTicketPurchase({
    required int bookingId,
    bool? applyWalletBalance,
    String? stripePaymentMethodId,
    String? token,
  }) async {
    try {
      final options = Options(
        headers: token != null ? {'Authorization': 'Bearer $token'} : null,
      );

      final response = await _apiClient.dio.get(
        AppUrls.marketplacePurchasePreview(bookingId),
        queryParameters: {
          ...?applyWalletBalance?.let(
            (value) => {'apply_wallet_balance': value},
          ),
          ...?stripePaymentMethodId?.let(
            (value) => {'stripe_payment_method_id': value},
          ),
        },
        options: options,
      );

      return response.data;
    } catch (e) {
      rethrow;
    }
  }
}

extension _OptionalMapValue<T> on T {
  R let<R>(R Function(T value) callback) => callback(this);
}
