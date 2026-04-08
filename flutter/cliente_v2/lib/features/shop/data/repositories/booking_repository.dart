import '../datasources/booking_remote_data_source.dart';

class BookingRepository {
  final BookingRemoteDataSource _remoteDataSource;

  BookingRepository(this._remoteDataSource);

  Future<Map<String, dynamic>> verifyCheckout(
    Map<String, dynamic> data,
  ) async {
    return await _remoteDataSource.verifyCheckout(data);
  }

  Future<Map<String, dynamic>> createBooking(
    Map<String, dynamic> bookingData,
  ) async {
    return await _remoteDataSource.bookTicket(bookingData);
  }

  Future<List<Map<String, dynamic>>> getPaymentMethods() async {
    final response = await _remoteDataSource.getPaymentMethods();
    if (response['status'] == 'success') {
      return List<Map<String, dynamic>>.from(response['data']);
    }
    return [];
  }

  Future<String> createSetupIntent() async {
    final response = await _remoteDataSource.createSetupIntent();
    if (response['status'] == 'success') {
      return response['client_secret'];
    }
    throw Exception(response['message'] ?? 'Failed to create SetupIntent');
  }

  Future<Map<String, dynamic>> getWallet() async {
    final response = await _remoteDataSource.getWallet();
    if (response['success'] == true) {
      return response['wallet'];
    }
    throw Exception(response['message'] ?? 'Failed to fetch wallet info');
  }
}
