import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../models/privacy_settings_model.dart';
import '../models/social_feed_model.dart';
import '../datasources/social_remote_data_source.dart';
import '../../../../core/constants/app_urls.dart';

final socialRemoteDataSourceProvider = Provider<SocialRemoteDataSource>((ref) {
  return SocialRemoteDataSource(ref.watch(apiClientProvider));
});

class SocialRepository {
  final SocialRemoteDataSource remoteDataSource;

  SocialRepository({required this.remoteDataSource});

  Future<Map<String, dynamic>> follow(String type, int id) {
    return remoteDataSource.followEntity(type, id);
  }

  Future<Map<String, dynamic>> unfollow(String type, int id) {
    return remoteDataSource.unfollowEntity(type, id);
  }

  Future<Map<String, dynamic>> acceptRequest(int requestId) {
    return remoteDataSource.acceptRequest(requestId);
  }

  Future<Map<String, dynamic>> rejectRequest(int requestId) {
    return remoteDataSource.rejectRequest(requestId);
  }

  Future<List<dynamic>> getPendingRequests() {
    return remoteDataSource.getPendingRequests();
  }

  Future<SocialFeedModel> getSocialFeed() {
    return remoteDataSource.getSocialFeed();
  }

  Future<List<dynamic>> getUserAttendedEvents(int userId) {
    return remoteDataSource.getUserAttendedEvents(userId);
  }

  Future<List<dynamic>> getUserUpcomingAttendance(int userId) {
    return remoteDataSource.getUserUpcomingAttendance(userId);
  }

  Future<List<dynamic>> getUserInterestedEvents(int userId) {
    return remoteDataSource.getUserInterestedEvents(userId);
  }

  Future<List<dynamic>> getUserFavorites(int userId) {
    return remoteDataSource.getUserFavorites(userId);
  }

  Future<List<dynamic>> getUserFollowers(int userId) {
    return remoteDataSource.getUserFollowers(userId);
  }

  Future<PrivacySettingsModel> getPrivacySettings() {
    return remoteDataSource.getPrivacySettings();
  }

  Future<PrivacySettingsModel> updatePrivacySettings(
    Map<String, dynamic> payload,
  ) {
    return remoteDataSource.updatePrivacySettings(payload);
  }
}

final socialRepositoryProvider = Provider<SocialRepository>((ref) {
  return SocialRepository(
    remoteDataSource: ref.watch(socialRemoteDataSourceProvider),
  );
});

// A provider for handling follow actions with loading state
class FollowActionNotifier extends StateNotifier<AsyncValue<void>> {
  final SocialRepository repository;

  FollowActionNotifier(this.repository) : super(const AsyncValue.data(null));

  Future<Map<String, dynamic>?> follow(String type, int id) async {
    state = const AsyncValue.loading();
    try {
      final result = await repository.follow(type, id);
      state = const AsyncValue.data(null);
      return result;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<bool> unfollow(String type, int id) async {
    state = const AsyncValue.loading();
    try {
      await repository.unfollow(type, id);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}

final followActionProvider =
    StateNotifierProvider<FollowActionNotifier, AsyncValue<void>>((ref) {
      return FollowActionNotifier(ref.watch(socialRepositoryProvider));
    });

// Profile Data Providers
final userProfileProvider = FutureProvider.family<Map<String, dynamic>, int>((
  ref,
  userId,
) async {
  final apiClient = ref.watch(apiClientProvider);
  final response = await apiClient.dio.get(AppUrls.userProfile(userId));
  if (response.statusCode == 200) {
    final data = response.data;
    if (data is Map<String, dynamic> && data['success'] == true) {
      return data['data'] as Map<String, dynamic>;
    }
  }
  throw Exception('Failed to load profile data');
});

final userAttendedEventsProvider = FutureProvider.family<List<dynamic>, int>((
  ref,
  userId,
) async {
  return ref.watch(socialRepositoryProvider).getUserAttendedEvents(userId);
});

final userUpcomingAttendanceProvider = FutureProvider.family<List<dynamic>, int>((
  ref,
  userId,
) async {
  return ref.watch(socialRepositoryProvider).getUserUpcomingAttendance(userId);
});

final userInterestedEventsProvider = FutureProvider.family<List<dynamic>, int>((
  ref,
  userId,
) async {
  return ref.watch(socialRepositoryProvider).getUserInterestedEvents(userId);
});

final userFavoritesProvider = FutureProvider.family<List<dynamic>, int>((
  ref,
  userId,
) async {
  return ref.watch(socialRepositoryProvider).getUserFavorites(userId);
});

final userFollowersListProvider = FutureProvider.family<List<dynamic>, int>((
  ref,
  userId,
) async {
  return ref.watch(socialRepositoryProvider).getUserFollowers(userId);
});

final pendingFollowRequestsProvider = FutureProvider<List<dynamic>>((ref) async {
  return ref.watch(socialRepositoryProvider).getPendingRequests();
});

final socialFeedProvider = FutureProvider<SocialFeedModel>((ref) async {
  return ref.watch(socialRepositoryProvider).getSocialFeed();
});

final privacySettingsProvider = FutureProvider<PrivacySettingsModel>((ref) async {
  return ref.watch(socialRepositoryProvider).getPrivacySettings();
});
