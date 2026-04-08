import '../datasources/booking_remote_data_source.dart';

class BookingRepository {
  final BookingRemoteDataSource _remoteDataSource;

  BookingRepository(this._remoteDataSource);

  Future<Map<String, dynamic>> verifyCheckout({
    required int eventId,
    required List<int>
    quantities, // Simplified for MVP (assuming list matches ticket types)
    // Add other necessary fields based on API requirements
  }) async {
    // Construct the payload matching the controller's expectation
    final data = {
      'event_id': eventId,
      'quantity': quantities,
      'event_guest_checkout_status': 1, // 1 for guest allowed or check logic
      'pricing_type': 'normal', // Defaulting to normal for MVP
      // 'seat_data': null,
    };

    return await _remoteDataSource.verifyCheckout(data);
  }

  Future<Map<String, dynamic>> createBooking(
    Map<String, dynamic> bookingData,
  ) async {
    return await _remoteDataSource.bookTicket(bookingData);
  }
<<<<<<< Updated upstream
=======

  Future<Map<String, dynamic>> applyCoupon(Map<String, dynamic> data) async {
    return await _remoteDataSource.applyCoupon(data);
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

  Future<Map<String, dynamic>> getBonusWallet() async {
    final response = await _remoteDataSource.getBonusWallet();
    if (response['success'] == true) {
      return response['wallet'];
    }
    throw Exception(response['message'] ?? 'Failed to fetch bonus wallet info');
  }
>>>>>>> Stashed changes
}
