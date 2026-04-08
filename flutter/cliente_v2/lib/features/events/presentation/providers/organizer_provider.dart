import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/organizer_remote_data_source.dart';
import '../../data/repositories/organizer_repository.dart';
import '../../data/models/event_model.dart';

final organizerRemoteDataSourceProvider = Provider<OrganizerRemoteDataSource>((
  ref,
) {
  final apiClient = ref.watch(apiClientProvider);
  return OrganizerRemoteDataSource(apiClient);
});

final organizerRepositoryProvider = Provider<OrganizerRepository>((ref) {
  final dataSource = ref.watch(organizerRemoteDataSourceProvider);
  return OrganizerRepository(dataSource);
});

final organizerProfileProvider =
    FutureProvider.family<Map<String, dynamic>, int>((ref, id) async {
      final repository = ref.watch(organizerRepositoryProvider);
      return await repository.getOrganizerProfile(id);
    });

final followedEventsProvider = FutureProvider<List<EventModel>>((ref) async {
  final repository = ref.watch(organizerRepositoryProvider);
  return await repository.getFollowedEvents();
});

final followActionProvider =
    StateNotifierProvider<FollowActionNotifier, AsyncValue<void>>((ref) {
      final repository = ref.watch(organizerRepositoryProvider);
      return FollowActionNotifier(repository, ref);
    });

class FollowActionNotifier extends StateNotifier<AsyncValue<void>> {
  final OrganizerRepository _repository;
  final Ref _ref;

  FollowActionNotifier(this._repository, this._ref)
    : super(const AsyncValue.data(null));

  Future<void> toggleFollow(int id, bool isCurrentlyFollowed) async {
    state = const AsyncValue.loading();
    try {
      if (isCurrentlyFollowed) {
        await _repository.unfollowOrganizer(id);
      } else {
        await _repository.followOrganizer(id);
      }
      state = const AsyncValue.data(null);
      // Invalidate the profile provider to refresh the UI with new counts/status
      _ref.invalidate(organizerProfileProvider(id));
      _ref.invalidate(followedEventsProvider);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
