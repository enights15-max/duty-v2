import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/venue_remote_data_source.dart';
import '../../data/repositories/venue_repository.dart';

final venueRemoteDataSourceProvider = Provider<VenueRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return VenueRemoteDataSource(apiClient);
});

final venueRepositoryProvider = Provider<VenueRepository>((ref) {
  final dataSource = ref.watch(venueRemoteDataSourceProvider);
  return VenueRepository(dataSource);
});

final venueProfileProvider = FutureProvider.family<Map<String, dynamic>, int>((
  ref,
  id,
) async {
  final repository = ref.watch(venueRepositoryProvider);
  return await repository.getVenueProfile(id);
});
