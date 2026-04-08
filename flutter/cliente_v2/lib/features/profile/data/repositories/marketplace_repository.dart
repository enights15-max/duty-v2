import '../datasources/marketplace_remote_data_source.dart';

class MarketplaceRepository {
  final MarketplaceRemoteDataSource _remoteDataSource;

  MarketplaceRepository(this._remoteDataSource);

  Future<Map<String, dynamic>> transferTicket({
    required int bookingId,
    String? recipient,
    int? recipientId,
    String? token,
  }) {
    return _remoteDataSource.transferTicket(
      bookingId: bookingId,
      recipient: recipient,
      recipientId: recipientId,
      token: token,
    );
  }

  Future<Map<String, dynamic>> getTransferTicketQr({
    required int bookingId,
    String? token,
  }) {
    return _remoteDataSource.getTransferTicketQr(
      bookingId: bookingId,
      token: token,
    );
  }

  Future<Map<String, dynamic>> requestTransferFromScan({
    required String transferToken,
    String? token,
  }) {
    return _remoteDataSource.requestTransferFromScan(
      transferToken: transferToken,
      token: token,
    );
  }

  Future<Map<String, dynamic>> verifyRecipient({
    String? recipient,
    int? recipientId,
    String? token,
  }) {
    return _remoteDataSource.verifyRecipient(
      recipient: recipient,
      recipientId: recipientId,
      token: token,
    );
  }

  Future<List<dynamic>> getPendingTransfers({String? token}) {
    return _remoteDataSource.getPendingTransfers(token: token);
  }

  Future<List<dynamic>> getOutboxTransfers({String? token}) {
    return _remoteDataSource.getOutboxTransfers(token: token);
  }

  Future<Map<String, dynamic>> getTransferDetails({
    required int transferId,
    String? token,
  }) {
    return _remoteDataSource.getTransferDetails(
      transferId: transferId,
      token: token,
    );
  }

  Future<Map<String, dynamic>> acceptTransfer({
    required int transferId,
    String? token,
  }) {
    return _remoteDataSource.acceptTransfer(
      transferId: transferId,
      token: token,
    );
  }

  Future<Map<String, dynamic>> rejectTransfer({
    required int transferId,
    String? token,
  }) {
    return _remoteDataSource.rejectTransfer(
      transferId: transferId,
      token: token,
    );
  }

  Future<Map<String, dynamic>> cancelTransfer({
    required int transferId,
    String? token,
  }) {
    return _remoteDataSource.cancelTransfer(
      transferId: transferId,
      token: token,
    );
  }

  Future<Map<String, dynamic>> listTicket({
    required int bookingId,
    required double price,
    required bool isListed,
    String? token,
  }) {
    return _remoteDataSource.listTicket(
      bookingId: bookingId,
      price: price,
      isListed: isListed,
      token: token,
    );
  }

  Future<List<dynamic>> getMarketplaceTickets({
    String? token,
    String? search,
    int? categoryId,
    double? minPrice,
    double? maxPrice,
  }) {
    return _remoteDataSource.getMarketplaceTickets(
      token: token,
      search: search,
      categoryId: categoryId,
      minPrice: minPrice,
      maxPrice: maxPrice,
    );
  }

  Future<Map<String, dynamic>> purchaseMarketplaceTicket({
    required int bookingId,
    String? token,
  }) {
    return _remoteDataSource.purchaseMarketplaceTicket(
      bookingId: bookingId,
      token: token,
    );
  }
}
