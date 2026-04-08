import '../datasources/venue_remote_data_source.dart';
import '../models/venue_model.dart';
import '../models/event_model.dart';

class VenueRepository {
  final VenueRemoteDataSource _remoteDataSource;

  VenueRepository(this._remoteDataSource);

  Future<Map<String, dynamic>> getVenueProfile(int id) async {
    final rawData = await _remoteDataSource.getVenueDetails(id);

    final venue = VenueModel.fromJson(rawData);

    final List<EventModel> events = [];
    if (rawData['events'] != null) {
      final eventsList = rawData['events'] as List;
      events.addAll(eventsList.map((e) => EventModel.fromJson(e)).toList());
    }

    return {'venue': venue, 'events': events};
  }
}
