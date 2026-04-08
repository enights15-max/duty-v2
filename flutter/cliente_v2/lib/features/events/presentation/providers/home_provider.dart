import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/event_remote_data_source.dart';
import '../../data/repositories/event_repository_impl.dart';
import '../../data/models/event_model.dart';

// Dependency Injection
final eventRemoteDataSourceProvider = Provider<EventRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return EventRemoteDataSource(apiClient);
});

final eventRepositoryProvider = Provider<EventRepository>((ref) {
  return EventRepository(ref.watch(eventRemoteDataSourceProvider));
});

// State Provider for Home Page
final homeEventsProvider = FutureProvider<List<EventModel>>((ref) async {
  final repository = ref.watch(eventRepositoryProvider);
  return await repository.getEvents();
});

final categoriesProvider = FutureProvider<List<dynamic>>((ref) async {
  final repository = ref.watch(eventRepositoryProvider);
  return await repository.getCategories();
});
