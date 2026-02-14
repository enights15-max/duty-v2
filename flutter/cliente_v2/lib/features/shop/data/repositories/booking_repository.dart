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
}
