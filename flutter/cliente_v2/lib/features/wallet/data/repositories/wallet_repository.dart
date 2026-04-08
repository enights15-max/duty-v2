import '../datasources/wallet_remote_data_source.dart';
import '../models/wallet_transaction_model.dart';

class WalletRepository {
  final WalletRemoteDataSource _remoteDataSource;

  WalletRepository(this._remoteDataSource);

  Future<Map<String, dynamic>> getWallet({required String token}) async {
    return await _remoteDataSource.getWallet(token: token);
  }

  Future<List<WalletTransactionModel>> getHistory({
    required String token,
  }) async {
    return await _remoteDataSource.getHistory(token: token);
  }

  Future<List<Map<String, dynamic>>> getWithdrawals({
    required String token,
  }) async {
    return await _remoteDataSource.getWithdrawals(token: token);
  }

  Future<Map<String, dynamic>> requestWithdrawal({
    required String token,
    required double amount,
    required String method,
    required Map<String, dynamic> paymentDetails,
  }) async {
    return await _remoteDataSource.requestWithdrawal(
      token: token,
      amount: amount,
      method: method,
      paymentDetails: paymentDetails,
    );
  }

  Future<Map<String, dynamic>> createTopupIntent({
    required String token,
    required double amount,
  }) async {
    return await _remoteDataSource.createTopupIntent(
      token: token,
      amount: amount,
    );
  }

  Future<Map<String, dynamic>> previewTopup({
    required String token,
    required double amount,
  }) async {
    return await _remoteDataSource.previewTopup(token: token, amount: amount);
  }

  Future<List<Map<String, dynamic>>> getPaymentMethods({
    required String token,
  }) async {
    return await _remoteDataSource.getPaymentMethods(token: token);
  }

  Future<String> createSetupIntent({required String token}) async {
    return await _remoteDataSource.createSetupIntent(token: token);
  }

  Future<Map<String, dynamic>> checkTopupStatus({
    required String token,
    required String paymentIntentId,
  }) async {
    return await _remoteDataSource.checkTopupStatus(
      token: token,
      paymentIntentId: paymentIntentId,
    );
  }

  Future<Map<String, dynamic>> confirmTopup({
    required String token,
    required String paymentIntentId,
  }) async {
    return await _remoteDataSource.confirmTopup(
      token: token,
      paymentIntentId: paymentIntentId,
    );
  }

  Future<bool> deletePaymentMethod({
    required String token,
    required String paymentMethodId,
  }) async {
    return await _remoteDataSource.deletePaymentMethod(
      token: token,
      paymentMethodId: paymentMethodId,
    );
  }

  Future<Map<String, dynamic>> transferFunds({
    required String token,
    required double amount,
    required String targetWalletId,
  }) async {
    return await _remoteDataSource.transferFunds(
      token: token,
      amount: amount,
      targetWalletId: targetWalletId,
    );
  }
}
