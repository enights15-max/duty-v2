import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/api_client.dart';
import '../../data/datasources/customer_remote_data_source.dart';
import '../../data/repositories/customer_repository.dart';
import '../../data/models/booking_model.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart'; // To get ApiClient/Auth info

// Data Source & Repository
final customerRemoteDataSourceProvider = Provider<CustomerRemoteDataSource>((
  ref,
) {
  return CustomerRemoteDataSource(
    ApiClient(),
  ); // Or ref.watch(apiClientProvider)
});

final customerRepositoryProvider = Provider<CustomerRepository>((ref) {
  return CustomerRepository(ref.watch(customerRemoteDataSourceProvider));
});

// Providers
final profileProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  return ref.watch(customerRepositoryProvider).getProfile();
});

final myBookingsProvider = FutureProvider<List<BookingModel>>((ref) async {
  return ref.watch(customerRepositoryProvider).getBookings();
});

final bookingDetailsProvider = FutureProvider.family<BookingModel, String>((
  ref,
  id,
) async {
  return ref.watch(customerRepositoryProvider).getBookingDetails(id);
});
