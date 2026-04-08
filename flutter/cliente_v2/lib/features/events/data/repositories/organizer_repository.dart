import '../datasources/organizer_remote_data_source.dart';
import '../models/organizer_model.dart';
import '../models/event_model.dart';

class OrganizerRepository {
  final OrganizerRemoteDataSource _remoteDataSource;

  OrganizerRepository(this._remoteDataSource);

  Future<Map<String, dynamic>> getOrganizerProfile(int id) async {
    final rawData = await _remoteDataSource.getOrganizerDetails(id);

    final organizer = OrganizerModel.fromJson(rawData['organizer']);

    // Extract events from all categories and flatten them
    final List<EventModel> events = [];
    if (rawData['events'] != null && rawData['events']['categories'] != null) {
      final categories =
          rawData['events']['categories'] as Map<String, dynamic>;
      for (var categoryEvents in categories.values) {
        if (categoryEvents is List) {
          events.addAll(
            categoryEvents.map((e) => EventModel.fromJson(e)).toList(),
          );
        }
      }
    }

    return {'organizer': organizer, 'events': events};
  }

  Future<Map<String, dynamic>> followOrganizer(int id) async {
    return await _remoteDataSource.followOrganizer(id);
  }

  Future<Map<String, dynamic>> unfollowOrganizer(int id) async {
    return await _remoteDataSource.unfollowOrganizer(id);
  }

  Future<List<EventModel>> getFollowedEvents() async {
    final rawData = await _remoteDataSource.getFollowedEvents();
    return rawData.map((e) => EventModel.fromJson(e)).toList();
  }
}
