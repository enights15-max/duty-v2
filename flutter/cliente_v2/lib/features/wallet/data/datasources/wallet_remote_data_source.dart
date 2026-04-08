import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../../../core/api/api_client.dart';
import '../../../../../core/constants/app_urls.dart';
import '../models/wallet_transaction_model.dart';

class WalletRemoteDataSource {
  final ApiClient _apiClient;

  WalletRemoteDataSource(this._apiClient);

  Future<Map<String, dynamic>> getWallet({required String token}) async {
    try {
      final options = Options(headers: {'Authorization': 'Bearer $token'});
      final response = await _apiClient.dio.get(
        AppUrls.wallet,
        options: options,
      );

      Map<String, dynamic> responseData;
      if (response.data is String) {
        responseData = jsonDecode(response.data) as Map<String, dynamic>;
      } else {
        responseData = response.data as Map<String, dynamic>;
      }

      if (responseData['success'] == true && responseData['wallet'] != null) {
        return responseData['wallet'];
      }
      throw Exception('Invalid wallet data');
    } catch (e) {
      rethrow;
    }
  }

  Future<List<WalletTransactionModel>> getHistory({
    required String token,
  }) async {
    try {
      final options = Options(headers: {'Authorization': 'Bearer $token'});
      final response = await _apiClient.dio.get(
        AppUrls.walletHistory,
        options: options,
      );

      Map<String, dynamic> responseData;
      if (response.data is String) {
        responseData = jsonDecode(response.data) as Map<String, dynamic>;
      } else {
        responseData = response.data as Map<String, dynamic>;
      }

      if (responseData['success'] == true &&
          responseData['transactions'] != null) {
        final List<dynamic> txList = responseData['transactions'];
        return txList.map((tx) => WalletTransactionModel.fromJson(tx)).toList();
      }
      throw Exception('Invalid transaction history data');
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getWithdrawals({
    required String token,
  }) async {
    try {
      final options = Options(headers: {'Authorization': 'Bearer $token'});
      final response = await _apiClient.dio.get(
        AppUrls.walletWithdrawals,
        options: options,
      );

      final responseData = response.data as Map<String, dynamic>;
      if (responseData['success'] == true) {
        return List<Map<String, dynamic>>.from(responseData['withdrawals']);
      }
      throw Exception('Invalid withdrawal data');
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> requestWithdrawal({
    required String token,
    required double amount,
    required String method,
    required Map<String, dynamic> paymentDetails,
  }) async {
    try {
      final options = Options(headers: {'Authorization': 'Bearer $token'});
      final response = await _apiClient.dio.post(
        AppUrls.walletWithdraw,
        data: {
          'amount': amount,
          'method': method,
          'payment_details': paymentDetails,
        },
        options: options,
      );

      final responseData = response.data as Map<String, dynamic>;
      if (responseData['success'] == true) {
        return responseData['withdrawal'];
      }
      throw Exception(responseData['message'] ?? 'Withdrawal request failed');
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createTopupIntent({
    required String token,
    required double amount,
  }) async {
    try {
      final options = Options(headers: {'Authorization': 'Bearer $token'});
      final response = await _apiClient.dio.post(
        '${AppUrls.apiBaseUrl}/customers/payments/intent',
        data: {'amount': amount},
        options: options,
      );

      Map<String, dynamic> responseData;
      if (response.data is String) {
        responseData = jsonDecode(response.data) as Map<String, dynamic>;
      } else {
        responseData = response.data as Map<String, dynamic>;
      }

      if (responseData['success'] == true) {
        return responseData;
      }
      throw Exception(
        responseData['error'] ?? 'Failed to create top-up intent',
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> previewTopup({
    required String token,
    required double amount,
  }) async {
    try {
      final options = Options(headers: {'Authorization': 'Bearer $token'});
      final response = await _apiClient.dio.post(
        AppUrls.walletTopupPreview,
        data: {'amount': amount},
        options: options,
      );

      Map<String, dynamic> responseData;
      if (response.data is String) {
        responseData = jsonDecode(response.data) as Map<String, dynamic>;
      } else {
        responseData = response.data as Map<String, dynamic>;
      }

      if (responseData['success'] == true) {
        final data = responseData['data'];
        if (data is Map<String, dynamic>) {
          return data;
        }
        if (data is Map) {
          return Map<String, dynamic>.from(data);
        }
      }

      throw Exception(
        responseData['error'] ??
            responseData['message'] ??
            'Failed to preview top-up',
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getPaymentMethods({
    required String token,
  }) async {
    try {
      final options = Options(headers: {'Authorization': 'Bearer $token'});
      final response = await _apiClient.dio.get(
        '${AppUrls.apiBaseUrl}/customers/payment-methods',
        options: options,
      );

      Map<String, dynamic> responseData;
      if (response.data is String) {
        responseData = jsonDecode(response.data) as Map<String, dynamic>;
      } else {
        responseData = response.data as Map<String, dynamic>;
      }

      if (responseData['status'] == 'success') {
        return List<Map<String, dynamic>>.from(responseData['data']);
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> deletePaymentMethod({
    required String token,
    required String paymentMethodId,
  }) async {
    try {
      final options = Options(headers: {'Authorization': 'Bearer $token'});
      final response = await _apiClient.dio.delete(
        '${AppUrls.apiBaseUrl}/customers/payment-methods/$paymentMethodId',
        options: options,
      );

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      rethrow;
    }
  }

  Future<String> createSetupIntent({required String token}) async {
    try {
      final options = Options(headers: {'Authorization': 'Bearer $token'});
      final response = await _apiClient.dio.post(
        '${AppUrls.apiBaseUrl}/customers/payment-methods/setup-intent',
        options: options,
      );

      Map<String, dynamic> responseData;
      if (response.data is String) {
        responseData = jsonDecode(response.data) as Map<String, dynamic>;
      } else {
        responseData = response.data as Map<String, dynamic>;
      }

      if (responseData['status'] == 'success') {
        return responseData['client_secret'];
      }
      throw Exception('Failed to create setup intent');
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> checkTopupStatus({
    required String token,
    required String paymentIntentId,
  }) async {
    try {
      final options = Options(headers: {'Authorization': 'Bearer $token'});
      final response = await _apiClient.dio.get(
        '${AppUrls.apiBaseUrl}/customers/wallet/topup-status/$paymentIntentId',
        options: options,
      );

      Map<String, dynamic> responseData;
      if (response.data is String) {
        responseData = jsonDecode(response.data) as Map<String, dynamic>;
      } else {
        responseData = response.data as Map<String, dynamic>;
      }

      return responseData;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> confirmTopup({
    required String token,
    required String paymentIntentId,
  }) async {
    try {
      final options = Options(headers: {'Authorization': 'Bearer $token'});
      final response = await _apiClient.dio.post(
        '${AppUrls.apiBaseUrl}/customers/wallet/topup-confirm/$paymentIntentId',
        options: options,
      );

      Map<String, dynamic> responseData;
      if (response.data is String) {
        responseData = jsonDecode(response.data) as Map<String, dynamic>;
      } else {
        responseData = response.data as Map<String, dynamic>;
      }

      return responseData;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> transferFunds({
    required String token,
    required double amount,
    required String targetWalletId,
  }) async {
    try {
      final options = Options(headers: {'Authorization': 'Bearer $token'});
      final response = await _apiClient.dio.post(
        AppUrls.walletTransfer,
        data: {'amount': amount, 'target_wallet_id': targetWalletId},
        options: options,
      );

      final responseData = response.data as Map<String, dynamic>;
      if (responseData['success'] == true) {
        return responseData;
      }
      throw Exception(responseData['message'] ?? 'Transfer failed');
    } catch (e) {
      rethrow;
    }
  }
}
