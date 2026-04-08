import '../datasources/marketplace_remote_data_source.dart';

class MarketplaceRepository {
  final MarketplaceRemoteDataSource _remoteDataSource;

  MarketplaceRepository(this._remoteDataSource);

  Future<Map<String, dynamic>> transferTicket({
    required int bookingId,
    required String recipient,
    String? token,
  }) {
    return _remoteDataSource.transferTicket(
      bookingId: bookingId,
      recipient: recipient,
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
    bool? applyWalletBalance,
    String? stripePaymentMethodId,
    String? token,
  }) {
    return _remoteDataSource.purchaseMarketplaceTicket(
      bookingId: bookingId,
      applyWalletBalance: applyWalletBalance,
      stripePaymentMethodId: stripePaymentMethodId,
      token: token,
    );
  }

  Future<Map<String, dynamic>> previewMarketplaceTicketPurchase({
    required int bookingId,
    bool? applyWalletBalance,
    String? stripePaymentMethodId,
    String? token,
  }) {
    return _remoteDataSource.previewMarketplaceTicketPurchase(
      bookingId: bookingId,
      applyWalletBalance: applyWalletBalance,
      stripePaymentMethodId: stripePaymentMethodId,
      token: token,
    );
  }
}
