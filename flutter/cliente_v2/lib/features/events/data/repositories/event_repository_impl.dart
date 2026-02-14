import '../datasources/event_remote_data_source.dart';
import '../models/event_model.dart';
import '../models/event_detail_model.dart';

class EventRepository {
  final EventRemoteDataSource _remoteDataSource;

  EventRepository(this._remoteDataSource);

  Future<List<EventModel>> getEvents() async {
    return await _remoteDataSource.getEvents();
  }

  Future<EventDetailModel> getEventDetails(int id) async {
    return await _remoteDataSource.getEventDetails(id);
  }
}
