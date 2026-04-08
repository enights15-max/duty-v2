import 'package:dio/dio.dart';

import '../datasources/professional_event_remote_data_source.dart';
import '../models/discovery_models.dart';
import '../models/event_category_option.dart';
import '../models/google_place_suggestion_model.dart';
import '../models/professional_collaboration_summary_model.dart';
import '../models/professional_dashboard_model.dart';
import '../models/professional_event_inventory_detail_model.dart';
import '../models/professional_event_summary_model.dart';
import '../models/professional_event_ticket_model.dart';

class ProfessionalEventRepository {
  final ProfessionalEventRemoteDataSource _remoteDataSource;

  ProfessionalEventRepository(this._remoteDataSource);

  Future<List<EventCategoryOption>> getCategories() {
    return _remoteDataSource.getCategories();
  }

  Future<Map<String, dynamic>> createEvent(FormData data) {
    return _remoteDataSource.createEvent(data);
  }

  Future<List<ProfessionalEventSummaryModel>> getEvents() {
    return _remoteDataSource.getEvents();
  }

  Future<ProfessionalDashboardModel> getDashboard({String range = 'all'}) {
    return _remoteDataSource.getDashboard(range: range);
  }

  Future<ProfessionalEventInventoryDetailModel> getInventoryDetail(int id) {
    return _remoteDataSource.getInventoryDetail(id);
  }

  Future<Map<String, dynamic>> claimTreasury(int id) {
    return _remoteDataSource.claimTreasury(id);
  }

  Future<ProfessionalCollaborationSummary> getCollaborations() {
    return _remoteDataSource.getCollaborations();
  }

  Future<Map<String, dynamic>> claimCollaboration(int earningId) {
    return _remoteDataSource.claimCollaboration(earningId);
  }

  Future<Map<String, dynamic>> updateCollaborationMode(
    int earningId, {
    required bool autoRelease,
  }) {
    return _remoteDataSource.updateCollaborationMode(
      earningId,
      autoRelease: autoRelease,
    );
  }

  Future<ProfessionalEventCollaborationSummary> getEventCollaborators(
    int eventId,
  ) {
    return _remoteDataSource.getEventCollaborators(eventId);
  }

  Future<ProfessionalEventCollaborationSummary> saveEventCollaborators(
    int eventId,
    List<Map<String, dynamic>> splits,
  ) {
    return _remoteDataSource.saveEventCollaborators(eventId, splits);
  }

  Future<ProfessionalEventTicketsPayload> getTickets(int id) {
    return _remoteDataSource.getTickets(id);
  }

  Future<Map<String, dynamic>> getEvent(int id) {
    return _remoteDataSource.getEvent(id);
  }

  Future<Map<String, dynamic>> updateEvent(int id, FormData data) {
    return _remoteDataSource.updateEvent(id, data);
  }

  Future<ProfessionalManagedTicket> createTicket(
    int eventId,
    Map<String, dynamic> payload,
  ) {
    return _remoteDataSource.createTicket(eventId, payload);
  }

  Future<ProfessionalManagedTicket> updateTicket(
    int eventId,
    int ticketId,
    Map<String, dynamic> payload,
  ) {
    return _remoteDataSource.updateTicket(eventId, ticketId, payload);
  }

  Future<ProfessionalManagedTicket> duplicateTicket(int eventId, int ticketId) {
    return _remoteDataSource.duplicateTicket(eventId, ticketId);
  }

  Future<ProfessionalManagedTicket> updateTicketStatus(
    int eventId,
    int ticketId,
    String saleStatus,
  ) {
    return _remoteDataSource.updateTicketStatus(eventId, ticketId, saleStatus);
  }

  Future<void> issueManualTicket(
    int eventId,
    int ticketId,
    Map<String, dynamic> payload,
  ) {
    return _remoteDataSource.issueManualTicket(eventId, ticketId, payload);
  }

  Future<List<DiscoveryProfileModel>> searchVenues(String query) {
    return _remoteDataSource.searchVenues(query);
  }

  Future<List<DiscoveryProfileModel>> searchArtists(String query) {
    return _remoteDataSource.searchArtists(query);
  }

  Future<List<GooglePlaceSuggestionModel>> searchGooglePlaces(
    String query, {
    String? primaryCountryCode,
    List<String>? supportedCountryCodes,
  }) {
    return _remoteDataSource.searchGooglePlaces(
      query,
      primaryCountryCode: primaryCountryCode,
      supportedCountryCodes: supportedCountryCodes,
    );
  }

  Future<GooglePlaceSuggestionModel?> getGooglePlaceDetails(String placeId) {
    return _remoteDataSource.getGooglePlaceDetails(placeId);
  }

  Future<GooglePlaceSuggestionModel?> reverseGeocode({
    required double latitude,
    required double longitude,
    String? primaryCountryCode,
    List<String>? supportedCountryCodes,
  }) {
    return _remoteDataSource.reverseGeocode(
      latitude: latitude,
      longitude: longitude,
      primaryCountryCode: primaryCountryCode,
      supportedCountryCodes: supportedCountryCodes,
    );
  }
}
