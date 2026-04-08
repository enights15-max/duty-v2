import '../datasources/customer_remote_data_source.dart';
import '../models/booking_model.dart';

class CustomerRepository {
  final CustomerRemoteDataSource _remoteDataSource;

  CustomerRepository(this._remoteDataSource);

  Future<Map<String, dynamic>> updateProfile(
    dynamic data, {
    String? token,
  }) async {
    return await _remoteDataSource.updateProfile(data, token: token);
  }

  Future<Map<String, dynamic>> getProfile({String? token}) async {
    return await _remoteDataSource.getProfile(token: token);
  }

  Future<List<BookingModel>> getBookings({String? token}) async {
    final rawList = await _remoteDataSource.getBookings(token: token);
    return rawList.map((e) => BookingModel.fromJson(e)).toList();
  }

  Future<BookingModel> getBookingDetails(String id, {String? token}) async {
    final data = await _remoteDataSource.getBookingDetails(id, token: token);
    final nestedBooking = data['booking'];
    final bookingPayload = nestedBooking is Map<String, dynamic>
        ? Map<String, dynamic>.from(nestedBooking)
        : Map<String, dynamic>.from(data);

    final rewards = data['rewards'];
    if (rewards is List && bookingPayload['rewards'] == null) {
      bookingPayload['rewards'] = rewards;
    }

    return BookingModel.fromJson(bookingPayload);
  }

  Future<List<dynamic>> getIdentities() async {
    return await _remoteDataSource.getIdentities();
  }

  Future<Map<String, dynamic>> requestIdentity(
    dynamic data, {
    String? token,
  }) async {
    return await _remoteDataSource.requestIdentity(data, token: token);
  }

  Future<Map<String, dynamic>> updateIdentity(
    String id,
    dynamic data, {
    String? token,
  }) async {
    return await _remoteDataSource.updateIdentity(id, data, token: token);
  }
}
