import 'package:dio/dio.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/constants/app_urls.dart';

class MarketplaceRemoteDataSource {
  final ApiClient _apiClient;

  MarketplaceRemoteDataSource(this._apiClient);

  Future<Map<String, dynamic>> transferTicket({
    required int bookingId,
    String? recipient,
    int? recipientId,
    String? token,
  }) async {
    try {
      final recipientValue = recipient?.trim();
      final options = Options(
        headers: token != null ? {'Authorization': 'Bearer $token'} : null,
      );

      final response = await _apiClient.dio.post(
        AppUrls.transferTicket(bookingId),
        data: {
          ...?((recipientValue?.isNotEmpty ?? false)
              ? {'recipient': recipientValue}
              : null),
          ...?(recipientId != null ? {'recipient_id': recipientId} : null),
        },
        options: options,
      );

      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getTransferTicketQr({
    required int bookingId,
    String? token,
  }) async {
    final options = Options(
      headers: token != null ? {'Authorization': 'Bearer $token'} : null,
    );

    final response = await _apiClient.dio.get(
      AppUrls.transferTicketQr(bookingId),
      options: options,
    );

    return response.data;
  }

  Future<Map<String, dynamic>> requestTransferFromScan({
    required String transferToken,
    String? token,
  }) async {
    final options = Options(
      headers: token != null ? {'Authorization': 'Bearer $token'} : null,
    );

    final response = await _apiClient.dio.post(
      AppUrls.requestTransferFromScan,
      data: {'transfer_token': transferToken},
      options: options,
    );

    return response.data;
  }

  Future<Map<String, dynamic>> verifyRecipient({
    String? recipient,
    int? recipientId,
    String? token,
  }) async {
    try {
      final recipientValue = recipient?.trim();
      final options = Options(
        headers: token != null ? {'Authorization': 'Bearer $token'} : null,
      );

      final response = await _apiClient.dio.post(
        AppUrls.verifyRecipient,
        data: {
          ...?((recipientValue?.isNotEmpty ?? false)
              ? {'recipient': recipientValue}
              : null),
          ...?(recipientId != null ? {'recipient_id': recipientId} : null),
        },
        options: options,
      );

      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> getPendingTransfers({String? token}) async {
    try {
      final options = Options(
        headers: token != null ? {'Authorization': 'Bearer $token'} : null,
      );

      final response = await _apiClient.dio.get(
        AppUrls.pendingTransfers,
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

  Future<List<dynamic>> getOutboxTransfers({String? token}) async {
    try {
      final options = Options(
        headers: token != null ? {'Authorization': 'Bearer $token'} : null,
      );

      final response = await _apiClient.dio.get(
        AppUrls.outboxTransfers,
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

  Future<Map<String, dynamic>> getTransferDetails({
    required int transferId,
    String? token,
  }) async {
    final options = Options(
      headers: token != null ? {'Authorization': 'Bearer $token'} : null,
    );

    final response = await _apiClient.dio.get(
      AppUrls.transferDetails(transferId),
      options: options,
    );

    return response.data;
  }

  Future<Map<String, dynamic>> acceptTransfer({
    required int transferId,
    String? token,
  }) async {
    try {
      final options = Options(
        headers: token != null ? {'Authorization': 'Bearer $token'} : null,
      );

      final response = await _apiClient.dio.post(
        AppUrls.acceptTransfer(transferId),
        options: options,
      );

      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> rejectTransfer({
    required int transferId,
    String? token,
  }) async {
    try {
      final options = Options(
        headers: token != null ? {'Authorization': 'Bearer $token'} : null,
      );

      final response = await _apiClient.dio.post(
        AppUrls.rejectTransfer(transferId),
        options: options,
      );

      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> cancelTransfer({
    required int transferId,
    String? token,
  }) async {
    try {
      final options = Options(
        headers: token != null ? {'Authorization': 'Bearer $token'} : null,
      );

      final response = await _apiClient.dio.post(
        AppUrls.cancelTransfer(transferId),
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
      if (search != null && search.isNotEmpty) {
        queryParameters['search'] = search;
      }
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
    String? token,
  }) async {
    try {
      final options = Options(
        headers: token != null ? {'Authorization': 'Bearer $token'} : null,
      );

      final response = await _apiClient.dio.post(
        AppUrls.purchaseMarketplaceTicket(bookingId),
        options: options,
      );

      return response.data;
    } catch (e) {
      rethrow;
    }
  }
}
