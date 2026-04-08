import 'package:dio/dio.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/constants/app_urls.dart';
import '../models/discovery_models.dart';
import '../models/event_category_option.dart';
import '../models/google_place_suggestion_model.dart';
import '../models/professional_dashboard_model.dart';
import '../models/professional_collaboration_summary_model.dart';
import '../models/professional_event_inventory_detail_model.dart';
import '../models/professional_event_summary_model.dart';
import '../models/professional_event_ticket_model.dart';

class ProfessionalEventRemoteDataSource {
  final ApiClient _apiClient;
  static const _nominatimUserAgent = 'DutyApp/1.0 (venue-search)';

  ProfessionalEventRemoteDataSource(this._apiClient);

  Future<List<EventCategoryOption>> getCategories() async {
    final response = await _apiClient.dio.get('/events/categories');
    final payload = response.data;
    if (payload is! Map<String, dynamic>) {
      return const [];
    }

    final rawCategories = payload['data']?['categories'];
    if (rawCategories is! List) {
      return const [];
    }

    return rawCategories
        .map(
          (item) => EventCategoryOption.fromJson(
            item is Map<String, dynamic>
                ? item
                : Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList();
  }

  Future<Map<String, dynamic>> createEvent(FormData data) async {
    final response = await _apiClient.dio.post(
      AppUrls.professionalEvents,
      data: data,
      options: Options(
        contentType: 'multipart/form-data',
        responseType: ResponseType.json,
        headers: const {'Accept': 'application/json'},
      ),
    );

    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<List<ProfessionalEventSummaryModel>> getEvents() async {
    final response = await _apiClient.dio.get(AppUrls.professionalEvents);
    final payload = response.data;
    if (payload is! Map<String, dynamic>) {
      return const [];
    }

    final rawItems = payload['data'];
    if (rawItems is! List) {
      return const [];
    }

    return rawItems
        .map(
          (item) => ProfessionalEventSummaryModel.fromJson(
            item is Map<String, dynamic>
                ? item
                : Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList();
  }

  Future<ProfessionalDashboardModel> getDashboard({
    String range = 'all',
  }) async {
    final url = range == 'all'
        ? AppUrls.professionalDashboard
        : AppUrls.professionalDashboardRange(range);
    final response = await _apiClient.dio.get(url);
    final payload = response.data;
    if (payload is! Map<String, dynamic>) {
      throw Exception('Invalid professional dashboard response');
    }

    final data = payload['data'];
    if (payload['status'] != 'success' || data is! Map<String, dynamic>) {
      throw Exception(payload['message'] ?? 'Failed to load dashboard');
    }

    return ProfessionalDashboardModel.fromJson(data);
  }

  Future<ProfessionalEventInventoryDetailModel> getInventoryDetail(
    int id,
  ) async {
    final response = await _apiClient.dio.get(
      AppUrls.professionalEventInventory(id),
    );
    final payload = response.data;
    if (payload is! Map<String, dynamic>) {
      throw Exception('Invalid professional inventory response');
    }

    final data = payload['data'];
    if (payload['status'] != 'success' || data is! Map<String, dynamic>) {
      throw Exception(payload['message'] ?? 'Failed to load inventory detail');
    }

    return ProfessionalEventInventoryDetailModel.fromJson(data);
  }

  Future<Map<String, dynamic>> claimTreasury(int id) async {
    final response = await _apiClient.dio.post(
      AppUrls.professionalEventClaim(id),
      options: Options(headers: const {'Accept': 'application/json'}),
    );

    final payload = response.data;
    if (payload is! Map<String, dynamic>) {
      throw Exception('Invalid treasury claim response');
    }

    if (payload['status'] != 'success') {
      throw Exception(payload['message'] ?? 'Failed to claim event treasury');
    }

    return payload;
  }

  Future<ProfessionalCollaborationSummary> getCollaborations() async {
    final response = await _apiClient.dio.get(
      AppUrls.professionalCollaborations,
      options: Options(headers: const {'Accept': 'application/json'}),
    );

    final payload = response.data;
    if (payload is! Map<String, dynamic>) {
      throw Exception('Invalid collaboration summary response');
    }

    if (payload['status'] != 'success') {
      throw Exception(payload['message'] ?? 'Failed to load collaborations');
    }

    final data = payload['data'];
    if (data is! Map<String, dynamic>) {
      throw Exception('Invalid collaboration summary payload');
    }

    return ProfessionalCollaborationSummary.fromJson(data);
  }

  Future<Map<String, dynamic>> claimCollaboration(int earningId) async {
    final response = await _apiClient.dio.post(
      AppUrls.professionalCollaborationClaim(earningId),
      options: Options(headers: const {'Accept': 'application/json'}),
    );

    final payload = response.data;
    if (payload is! Map<String, dynamic>) {
      throw Exception('Invalid collaboration claim response');
    }

    if (payload['status'] != 'success') {
      throw Exception(payload['message'] ?? 'Failed to claim collaboration');
    }

    return payload;
  }

  Future<Map<String, dynamic>> updateCollaborationMode(
    int earningId, {
    required bool autoRelease,
  }) async {
    final response = await _apiClient.dio.post(
      AppUrls.professionalCollaborationMode(earningId),
      data: {'auto_release': autoRelease},
      options: Options(headers: const {'Accept': 'application/json'}),
    );

    final payload = response.data;
    if (payload is! Map<String, dynamic>) {
      throw Exception('Invalid collaboration mode response');
    }

    if (payload['status'] != 'success') {
      throw Exception(
        payload['message'] ?? 'Failed to update collaboration mode',
      );
    }

    return payload;
  }

  Future<ProfessionalEventCollaborationSummary> getEventCollaborators(
    int eventId,
  ) async {
    final response = await _apiClient.dio.get(
      AppUrls.professionalEventCollaborators(eventId),
      options: Options(headers: const {'Accept': 'application/json'}),
    );

    final payload = response.data;
    if (payload is! Map<String, dynamic>) {
      throw Exception('Invalid collaborator summary response');
    }

    final data = payload['data'];
    if (payload['status'] != 'success' || data is! Map<String, dynamic>) {
      throw Exception(
        payload['message'] ?? 'Failed to load event collaborators',
      );
    }

    return ProfessionalEventCollaborationSummary.fromJson(data);
  }

  Future<ProfessionalEventCollaborationSummary> saveEventCollaborators(
    int eventId,
    List<Map<String, dynamic>> splits,
  ) async {
    final response = await _apiClient.dio.post(
      AppUrls.professionalEventCollaborators(eventId),
      data: {'splits': splits},
      options: Options(headers: const {'Accept': 'application/json'}),
    );

    final payload = response.data;
    if (payload is! Map<String, dynamic>) {
      throw Exception('Invalid collaborator update response');
    }

    final data = payload['data'];
    if (payload['status'] != 'success' || data is! Map<String, dynamic>) {
      throw Exception(
        payload['message'] ?? 'Failed to update event collaborators',
      );
    }

    return ProfessionalEventCollaborationSummary.fromJson(data);
  }

  Future<ProfessionalEventTicketsPayload> getTickets(int id) async {
    final response = await _apiClient.dio.get(
      AppUrls.professionalEventTickets(id),
    );
    final payload = response.data;
    if (payload is! Map<String, dynamic>) {
      throw Exception('Invalid professional ticket response');
    }

    final data = payload['data'];
    if (payload['status'] != 'success' || data is! Map<String, dynamic>) {
      throw Exception(payload['message'] ?? 'Failed to load event tickets');
    }

    return ProfessionalEventTicketsPayload.fromJson(data);
  }

  Future<ProfessionalManagedTicket> createTicket(
    int eventId,
    Map<String, dynamic> payload,
  ) async {
    final response = await _apiClient.dio.post(
      AppUrls.professionalEventTickets(eventId),
      data: payload,
      options: Options(headers: const {'Accept': 'application/json'}),
    );

    final body = response.data;
    if (body is! Map<String, dynamic>) {
      throw Exception('Invalid ticket create response');
    }
    final data = body['data'];
    if (body['status'] != 'success' || data is! Map<String, dynamic>) {
      throw Exception(body['message'] ?? 'Failed to create ticket');
    }

    return ProfessionalManagedTicket.fromJson(data);
  }

  Future<ProfessionalManagedTicket> updateTicket(
    int eventId,
    int ticketId,
    Map<String, dynamic> payload,
  ) async {
    final response = await _apiClient.dio.post(
      AppUrls.professionalEventTicket(eventId, ticketId),
      data: payload,
      options: Options(headers: const {'Accept': 'application/json'}),
    );

    final body = response.data;
    if (body is! Map<String, dynamic>) {
      throw Exception('Invalid ticket update response');
    }
    final data = body['data'];
    if (body['status'] != 'success' || data is! Map<String, dynamic>) {
      throw Exception(body['message'] ?? 'Failed to update ticket');
    }

    return ProfessionalManagedTicket.fromJson(data);
  }

  Future<ProfessionalManagedTicket> duplicateTicket(
    int eventId,
    int ticketId,
  ) async {
    final response = await _apiClient.dio.post(
      AppUrls.professionalEventTicketDuplicate(eventId, ticketId),
      options: Options(headers: const {'Accept': 'application/json'}),
    );

    final body = response.data;
    if (body is! Map<String, dynamic>) {
      throw Exception('Invalid ticket duplicate response');
    }
    final data = body['data'];
    if (body['status'] != 'success' || data is! Map<String, dynamic>) {
      throw Exception(body['message'] ?? 'Failed to duplicate ticket');
    }

    return ProfessionalManagedTicket.fromJson(data);
  }

  Future<ProfessionalManagedTicket> updateTicketStatus(
    int eventId,
    int ticketId,
    String saleStatus,
  ) async {
    final response = await _apiClient.dio.post(
      AppUrls.professionalEventTicketStatus(eventId, ticketId),
      data: {'sale_status': saleStatus},
      options: Options(headers: const {'Accept': 'application/json'}),
    );

    final body = response.data;
    if (body is! Map<String, dynamic>) {
      throw Exception('Invalid ticket status response');
    }
    final data = body['data'];
    if (body['status'] != 'success' || data is! Map<String, dynamic>) {
      throw Exception(body['message'] ?? 'Failed to update ticket status');
    }

    return ProfessionalManagedTicket.fromJson(data);
  }

  Future<void> issueManualTicket(
    int eventId,
    int ticketId,
    Map<String, dynamic> payload,
  ) async {
    final response = await _apiClient.dio.post(
      '${AppUrls.professionalEventTickets(eventId)}/$ticketId/issue',
      data: payload,
      options: Options(headers: const {'Accept': 'application/json'}),
    );

    final body = response.data;
    if (body is! Map<String, dynamic>) {
      throw Exception('Invalid ticket issue response');
    }
    if (body['status'] != 'success') {
      throw Exception(body['message'] ?? 'Failed to issue manual ticket');
    }
  }

  Future<Map<String, dynamic>> getEvent(int id) async {
    final response = await _apiClient.dio.get(AppUrls.professionalEvent(id));
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<Map<String, dynamic>> updateEvent(int id, FormData data) async {
    final response = await _apiClient.dio.post(
      AppUrls.professionalEvent(id),
      data: data,
      options: Options(
        contentType: 'multipart/form-data',
        responseType: ResponseType.json,
        headers: const {'Accept': 'application/json'},
      ),
    );

    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<List<DiscoveryProfileModel>> searchVenues(String query) async {
    final response = await _apiClient.dio.get(
      AppUrls.professionalVenueSearch,
      queryParameters: query.trim().isEmpty ? null : {'q': query.trim()},
    );

    final payload = response.data;
    if (payload is! Map<String, dynamic>) {
      return const [];
    }

    final rawItems = payload['data'];
    if (rawItems is! List) {
      return const [];
    }

    return rawItems
        .map(
          (item) => DiscoveryProfileModel.fromJson(
            item is Map<String, dynamic>
                ? item
                : Map<String, dynamic>.from(item as Map),
            DiscoveryKind.venues,
          ),
        )
        .toList();
  }

  Future<List<DiscoveryProfileModel>> searchArtists(String query) async {
    final response = await _apiClient.dio.get(
      AppUrls.professionalArtistSearch,
      queryParameters: query.trim().isEmpty ? null : {'q': query.trim()},
    );

    final payload = response.data;
    if (payload is! Map<String, dynamic>) {
      return const [];
    }

    final rawItems = payload['data'];
    if (rawItems is! List) {
      return const [];
    }

    return rawItems
        .map(
          (item) => DiscoveryProfileModel.fromJson(
            item is Map<String, dynamic>
                ? item
                : Map<String, dynamic>.from(item as Map),
            DiscoveryKind.artists,
          ),
        )
        .toList();
  }

  Future<List<GooglePlaceSuggestionModel>> searchGooglePlaces(
    String query, {
    String? primaryCountryCode,
    List<String>? supportedCountryCodes,
  }) async {
    if (query.trim().isEmpty) {
      return const [];
    }

    final normalizedPrimaryCountryCode = primaryCountryCode
        ?.trim()
        .toUpperCase();
    final normalizedSupportedCountryCodes = (supportedCountryCodes ?? const [])
        .map((code) => code.trim().toUpperCase())
        .where((code) => code.isNotEmpty)
        .toList();

    if (AppUrls.googleMapsApiKey.trim().isNotEmpty) {
      try {
        final queryParameters = <String, dynamic>{
          'input': query.trim(),
          'key': AppUrls.googleMapsApiKey,
          'language': 'es',
        };
        if (normalizedPrimaryCountryCode != null &&
            normalizedPrimaryCountryCode.isNotEmpty) {
          queryParameters['region'] = normalizedPrimaryCountryCode
              .toLowerCase();
          if (normalizedSupportedCountryCodes.length == 1) {
            queryParameters['components'] =
                'country:${normalizedSupportedCountryCodes.first.toLowerCase()}';
          }
        }

        final response = await _apiClient.dio.get(
          AppUrls.googlePlacesAutocomplete,
          queryParameters: queryParameters,
        );

        final payload = response.data;
        if (payload is Map<String, dynamic>) {
          final status = payload['status']?.toString();
          final predictions = payload['predictions'];
          if (status == 'OK' && predictions is List) {
            return predictions
                .map(
                  (item) => GooglePlaceSuggestionModel.fromAutocompleteJson(
                    item is Map<String, dynamic>
                        ? item
                        : Map<String, dynamic>.from(item as Map),
                  ),
                )
                .where((item) => item.placeId.isNotEmpty)
                .toList();
          }
        }
      } catch (_) {
        // Fall through to OSM fallback.
      }
    }

    return _searchOpenStreetMap(
      query,
      supportedCountryCodes: normalizedSupportedCountryCodes,
    );
  }

  Future<List<GooglePlaceSuggestionModel>> _searchOpenStreetMap(
    String query, {
    List<String>? supportedCountryCodes,
  }) async {
    final normalizedSupportedCountryCodes = (supportedCountryCodes ?? const [])
        .map((code) => code.trim().toLowerCase())
        .where((code) => code.isNotEmpty)
        .toList();
    final response = await _apiClient.dio.get(
      AppUrls.nominatimSearch,
      queryParameters: {
        'q': query.trim(),
        'format': 'jsonv2',
        'addressdetails': 1,
        'limit': 6,
        if (normalizedSupportedCountryCodes.isNotEmpty)
          'countrycodes': normalizedSupportedCountryCodes.join(','),
      },
      options: Options(headers: {'User-Agent': _nominatimUserAgent}),
    );

    final payload = response.data;
    if (payload is! List) {
      return const [];
    }

    return payload
        .map(
          (item) => GooglePlaceSuggestionModel.fromNominatimJson(
            item is Map<String, dynamic>
                ? item
                : Map<String, dynamic>.from(item as Map),
          ),
        )
        .where(
          (item) =>
              item.description.trim().isNotEmpty &&
              item.latitude != null &&
              item.longitude != null,
        )
        .toList();
  }

  Future<GooglePlaceSuggestionModel?> getGooglePlaceDetails(
    String placeId,
  ) async {
    if (placeId.startsWith('osm:')) {
      return null;
    }

    if (placeId.trim().isEmpty || AppUrls.googleMapsApiKey.trim().isEmpty) {
      return null;
    }

    final response = await _apiClient.dio.get(
      AppUrls.googlePlaceDetails,
      queryParameters: {
        'place_id': placeId.trim(),
        'fields': 'place_id,name,formatted_address,geometry,address_components',
        'key': AppUrls.googleMapsApiKey,
        'language': 'es',
      },
    );

    final payload = response.data;
    if (payload is! Map<String, dynamic>) {
      return null;
    }

    final result = payload['result'];
    if (result is! Map) {
      return null;
    }

    return GooglePlaceSuggestionModel.fromPlaceDetailsJson(
      result is Map<String, dynamic>
          ? result
          : Map<String, dynamic>.from(result),
    );
  }

  Future<GooglePlaceSuggestionModel?> reverseGeocode({
    required double latitude,
    required double longitude,
    String? primaryCountryCode,
    List<String>? supportedCountryCodes,
  }) async {
    final normalizedPrimaryCountryCode = primaryCountryCode
        ?.trim()
        .toUpperCase();
    final normalizedSupportedCountryCodes = (supportedCountryCodes ?? const [])
        .map((code) => code.trim().toUpperCase())
        .where((code) => code.isNotEmpty)
        .toList();

    if (AppUrls.googleMapsApiKey.trim().isNotEmpty) {
      try {
        final queryParameters = <String, dynamic>{
          'latlng': '$latitude,$longitude',
          'key': AppUrls.googleMapsApiKey,
          'language': 'es',
        };
        if (normalizedPrimaryCountryCode != null &&
            normalizedPrimaryCountryCode.isNotEmpty) {
          queryParameters['region'] = normalizedPrimaryCountryCode
              .toLowerCase();
        }

        final response = await _apiClient.dio.get(
          AppUrls.googleGeocode,
          queryParameters: queryParameters,
        );

        final payload = response.data;
        if (payload is Map<String, dynamic>) {
          final results = payload['results'];
          if (results is List && results.isNotEmpty) {
            GooglePlaceSuggestionModel? best;
            for (final item in results) {
              if (item is! Map) {
                continue;
              }

              final parsed = GooglePlaceSuggestionModel.fromGeocodeJson(
                item is Map<String, dynamic>
                    ? item
                    : Map<String, dynamic>.from(item),
              );

              if (best == null) {
                best = parsed;
                continue;
              }

              final bestHasLocation =
                  (best.city?.trim().isNotEmpty ?? false) &&
                  (best.country?.trim().isNotEmpty ?? false);
              final parsedHasLocation =
                  (parsed.city?.trim().isNotEmpty ?? false) &&
                  (parsed.country?.trim().isNotEmpty ?? false);

              if (!bestHasLocation && parsedHasLocation) {
                best = parsed;
                continue;
              }

              best = best.copyWith(
                city: best.city ?? parsed.city,
                state: best.state ?? parsed.state,
                country: best.country ?? parsed.country,
                countryCode: best.countryCode ?? parsed.countryCode,
                postalCode: best.postalCode ?? parsed.postalCode,
              );
            }

            if (best != null &&
                ((best.city?.trim().isNotEmpty ?? false) ||
                    (best.country?.trim().isNotEmpty ?? false)) &&
                _isSupportedCountry(
                  best.countryCode,
                  normalizedSupportedCountryCodes,
                )) {
              return best;
            }
          }
        }
      } catch (_) {
        // Fall through to OSM fallback.
      }
    }

    final response = await _apiClient.dio.get(
      AppUrls.nominatimReverse,
      queryParameters: {
        'lat': latitude,
        'lon': longitude,
        'format': 'jsonv2',
        'addressdetails': 1,
      },
      options: Options(headers: {'User-Agent': _nominatimUserAgent}),
    );

    final payload = response.data;
    if (payload is! Map<String, dynamic>) {
      return null;
    }

    if ((payload['error']?.toString().trim().isNotEmpty ?? false)) {
      return null;
    }

    final resolved = GooglePlaceSuggestionModel.fromNominatimJson(payload);
    if (_isSupportedCountry(
      resolved.countryCode,
      normalizedSupportedCountryCodes,
    )) {
      return resolved;
    }

    return null;
  }

  bool _isSupportedCountry(String? countryCode, List<String> supported) {
    if (supported.isEmpty) {
      return true;
    }

    final normalized = countryCode?.trim().toUpperCase();
    if (normalized == null || normalized.isEmpty) {
      return false;
    }

    return supported.contains(normalized);
  }
}
