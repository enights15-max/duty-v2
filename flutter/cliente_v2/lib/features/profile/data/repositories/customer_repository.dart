import '../datasources/customer_remote_data_source.dart';
import '../models/booking_model.dart';

class CustomerRepository {
  final CustomerRemoteDataSource _remoteDataSource;

  CustomerRepository(this._remoteDataSource);

  Future<Map<String, dynamic>> getProfile() async {
    return await _remoteDataSource.getProfile();
  }

  Future<List<BookingModel>> getBookings() async {
    final rawList = await _remoteDataSource.getBookings();
    return rawList.map((e) => BookingModel.fromJson(e)).toList();
  }

  Future<BookingModel> getBookingDetails(String id) async {
    final data = await _remoteDataSource.getBookingDetails(id);
    // Assuming data['data'] contains the booking info
    return BookingModel.fromJson(data['data'] ?? data);
  }
}
