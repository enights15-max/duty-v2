import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/colors.dart';
import '../../../../core/providers/profile_state_provider.dart';
import '../../../profile/domain/models/profile_model.dart';
import '../../data/models/discovery_models.dart';
import '../../data/models/event_category_option.dart';
import '../../data/models/google_place_suggestion_model.dart';
import '../providers/professional_event_provider.dart';

class _LineupDraftItem {
  const _LineupDraftItem({
    required this.key,
    required this.sourceType,
    required this.displayName,
    this.artistId,
    this.username,
    this.photo,
  });

  factory _LineupDraftItem.registered(DiscoveryProfileModel artist) {
    return _LineupDraftItem(
      key: 'artist:${artist.id}',
      sourceType: 'artist',
      displayName: artist.name,
      artistId: artist.id,
      username: artist.username,
      photo: artist.photo,
    );
  }

  factory _LineupDraftItem.manual(String name) {
    final normalized = name.replaceAll(RegExp(r'\s+'), ' ').trim();
    return _LineupDraftItem(
      key: 'manual:$normalized',
      sourceType: 'manual',
      displayName: normalized,
    );
  }

  final String key;
  final String sourceType;
  final String displayName;
  final int? artistId;
  final String? username;
  final String? photo;

  bool get isArtist => sourceType == 'artist' && artistId != null;
}

class _EventDateDraft {
  _EventDateDraft({
    this.id,
    this.startDate,
    this.startTime,
    this.endDate,
    this.endTime,
  });

  int? id;
  DateTime? startDate;
  TimeOfDay? startTime;
  DateTime? endDate;
  TimeOfDay? endTime;

  bool get isComplete =>
      startDate != null &&
      startTime != null &&
      endDate != null &&
      endTime != null;
}

class _RewardDraftItem {
  const _RewardDraftItem({
    required this.localKey,
    this.id,
    this.title = '',
    this.description = '',
    this.rewardType = 'welcome_drink',
    this.triggerMode = 'on_ticket_scan',
    this.fulfillmentMode = 'qr_claim',
    this.perTicketQuantity = 1,
    this.inventoryLimit = '',
    this.claimCodePrefix = '',
    this.isActive = true,
  });

  final String localKey;
  final int? id;
  final String title;
  final String description;
  final String rewardType;
  final String triggerMode;
  final String fulfillmentMode;
  final int perTicketQuantity;
  final String inventoryLimit;
  final String claimCodePrefix;
  final bool isActive;

  _RewardDraftItem copyWith({
    int? id,
    String? title,
    String? description,
    String? rewardType,
    String? triggerMode,
    String? fulfillmentMode,
    int? perTicketQuantity,
    String? inventoryLimit,
    String? claimCodePrefix,
    bool? isActive,
  }) {
    return _RewardDraftItem(
      localKey: localKey,
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      rewardType: rewardType ?? this.rewardType,
      triggerMode: triggerMode ?? this.triggerMode,
      fulfillmentMode: fulfillmentMode ?? this.fulfillmentMode,
      perTicketQuantity: perTicketQuantity ?? this.perTicketQuantity,
      inventoryLimit: inventoryLimit ?? this.inventoryLimit,
      claimCodePrefix: claimCodePrefix ?? this.claimCodePrefix,
      isActive: isActive ?? this.isActive,
    );
  }

  factory _RewardDraftItem.fromPayload(
    Map<String, dynamic> payload,
    String key,
  ) {
    final quantity =
        int.tryParse(payload['per_ticket_quantity']?.toString() ?? '') ?? 1;
    final inventoryLimit = payload['inventory_limit']?.toString() ?? '';
    final claimCodePrefix =
        payload['claim_code_prefix']?.toString() ??
        (payload['meta'] is Map
            ? (payload['meta'] as Map)['claim_code_prefix']?.toString() ?? ''
            : '');

    return _RewardDraftItem(
      localKey: key,
      id: int.tryParse(payload['id']?.toString() ?? ''),
      title: payload['title']?.toString() ?? '',
      description: payload['description']?.toString() ?? '',
      rewardType: payload['reward_type']?.toString() ?? 'welcome_drink',
      triggerMode: payload['trigger_mode']?.toString() ?? 'on_ticket_scan',
      fulfillmentMode: payload['fulfillment_mode']?.toString() ?? 'qr_claim',
      perTicketQuantity: quantity <= 0 ? 1 : quantity,
      inventoryLimit: inventoryLimit,
      claimCodePrefix: claimCodePrefix,
      isActive: (payload['status']?.toString() ?? 'active') != 'inactive',
    );
  }

  Map<String, dynamic> toPayload() {
    final payload = <String, dynamic>{
      if (id != null) 'id': id,
      'title': title.trim(),
      'reward_type': rewardType,
      'trigger_mode': triggerMode,
      'fulfillment_mode': fulfillmentMode,
      'per_ticket_quantity': perTicketQuantity,
      'status': isActive ? 'active' : 'inactive',
    };

    if (description.trim().isNotEmpty) {
      payload['description'] = description.trim();
    }

    final inventory = int.tryParse(inventoryLimit.trim());
    if (inventory != null && inventory > 0) {
      payload['inventory_limit'] = inventory;
    }

    final normalizedPrefix = claimCodePrefix
        .replaceAll(RegExp(r'[^A-Za-z0-9]'), '')
        .toUpperCase()
        .trim();
    if (normalizedPrefix.isNotEmpty) {
      payload['meta'] = {
        'claim_code_prefix': normalizedPrefix.substring(
          0,
          normalizedPrefix.length > 8 ? 8 : normalizedPrefix.length,
        ),
      };
    }

    return payload;
  }
}

class ProfessionalEventCreatePage extends ConsumerStatefulWidget {
  const ProfessionalEventCreatePage({super.key, this.eventId});

  final int? eventId;

  @override
  ConsumerState<ProfessionalEventCreatePage> createState() =>
      _ProfessionalEventCreatePageState();
}

class _ProfessionalEventCreatePageState
    extends ConsumerState<ProfessionalEventCreatePage> {
  static const int _thumbnailMaxBytes = 700 * 1024;
  static const int _galleryImageMaxBytes = 900 * 1024;
  static const int _totalUploadBudgetBytes = 6 * 1024 * 1024;
  static const int _maxGalleryImages = 5;

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _refundPolicyController = TextEditingController();
  final _ageLimitController = TextEditingController();
  final _meetingUrlController = TextEditingController();
  final _onlinePriceController = TextEditingController();
  final _onlineTicketAvailableController = TextEditingController();
  final _onlineMaxBuyController = TextEditingController();
  final _earlyBirdAmountController = TextEditingController();
  final _manualArtistsController = TextEditingController();
  final _venueQueryController = TextEditingController();
  final _artistQueryController = TextEditingController();
  final _venueNameController = TextEditingController();
  final _venueAddressController = TextEditingController();
  final _venueCityController = TextEditingController();
  final _venueStateController = TextEditingController();
  final _venueCountryController = TextEditingController();
  final _venuePostalCodeController = TextEditingController();
  final _venueLatitudeController = TextEditingController();
  final _venueLongitudeController = TextEditingController();
  final _googlePlaceIdController = TextEditingController();

  final ImagePicker _imagePicker = ImagePicker();

  List<EventCategoryOption> _categories = const [];
  List<DiscoveryProfileModel> _venueResults = const [];
  List<DiscoveryProfileModel> _artistResults = const [];
  List<GooglePlaceSuggestionModel> _googlePlaceResults = const [];
  final List<_LineupDraftItem> _lineupItems = [];
  final List<_RewardDraftItem> _rewardItems = [];

  DiscoveryProfileModel? _selectedVenue;
  String _eventType = 'venue';
  DateTime? _startDate;
  TimeOfDay? _startTime;
  DateTime? _endDate;
  TimeOfDay? _endTime;
  DateTime? _earlyBirdDate;
  TimeOfDay? _earlyBirdTime;
  String _dateType = 'single';
  final List<_EventDateDraft> _dateSlots = [];
  String? _existingThumbnailUrl;
  List<Map<String, dynamic>> _existingGallery = const [];
  File? _thumbnailFile;
  List<File> _galleryFiles = const [];
  String _venueSource = 'registered';
  int? _selectedCategoryId;
  bool _isBootstrapping = true;
  bool _isSubmitting = false;
  bool _isSearchingVenues = false;
  bool _isSearchingArtists = false;
  bool _isSearchingGooglePlaces = false;
  bool _mobileEditingSupported = true;
  String? _mobileEditingReason;
  String? _managedByType;
  String? _hostingVenueName;
  String _settlementHoldMode = 'auto_after_grace_period';
  int _settlementGraceHours = 72;
  int _refundWindowHours = 72;
  bool _autoReleaseOwnerShare = false;
  bool _requireAdminApproval = false;
  String? _headlinerKey;
  String _currentStatus = '0';
  String _currentFeatured = 'no';
  String? _reviewStatus;
  String? _reviewNotes;
  String _onlineTicketAvailabilityType = 'limited';
  String _onlineMaxBuyType = 'limited';
  String _onlineEarlyBirdMode = 'disable';
  String _onlineDiscountType = 'fixed';
  bool _hasVenueSearchAttempted = false;
  bool _hasArtistSearchAttempted = false;
  Timer? _venueSearchDebounce;
  Timer? _artistSearchDebounce;
  int _rewardDraftSeed = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bootstrap();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _refundPolicyController.dispose();
    _ageLimitController.dispose();
    _meetingUrlController.dispose();
    _onlinePriceController.dispose();
    _onlineTicketAvailableController.dispose();
    _onlineMaxBuyController.dispose();
    _earlyBirdAmountController.dispose();
    _manualArtistsController.dispose();
    _venueQueryController.dispose();
    _artistQueryController.dispose();
    _venueNameController.dispose();
    _venueAddressController.dispose();
    _venueCityController.dispose();
    _venueStateController.dispose();
    _venueCountryController.dispose();
    _venuePostalCodeController.dispose();
    _venueLatitudeController.dispose();
    _venueLongitudeController.dispose();
    _googlePlaceIdController.dispose();
    _venueSearchDebounce?.cancel();
    _artistSearchDebounce?.cancel();
    super.dispose();
  }

  AppProfile? get _activeProfile => ref.read(activeProfileProvider);
  bool get _isEditMode => widget.eventId != null;
  bool get _canPublishOnline => _activeProfile?.type == ProfileType.organizer;
  bool get _isVenueIdentityAuthoring =>
      _activeProfile?.type == ProfileType.venue;
  DutyThemeTokens get _palette => context.dutyTheme;
  Color get _authoringAccentColor =>
      _isVenueIdentityAuthoring ? kInfoColor : kPrimaryColor;

  bool get _canAuthorEvents {
    final profile = _activeProfile;
    if (profile == null || !profile.isActive) {
      return false;
    }

    return profile.type == ProfileType.organizer ||
        profile.type == ProfileType.venue;
  }

  DiscoveryProfileModel? _preferredVenueFromResults(
    List<DiscoveryProfileModel> results,
  ) {
    final activeProfile = _activeProfile;
    final activeIdentityId = int.tryParse(activeProfile?.id ?? '');
    if (activeProfile == null || results.isEmpty) {
      return null;
    }

    for (final venue in results) {
      if (activeIdentityId != null && venue.identity?.id == activeIdentityId) {
        return venue;
      }
    }

    if (_isVenueIdentityAuthoring) {
      for (final venue in results) {
        if (venue.isOwnedByActiveAccount) {
          return venue;
        }
      }
    }

    return null;
  }

  void _switchEventType(String value) {
    if (_eventType == value) {
      return;
    }

    if (value == 'online' && !_canPublishOnline) {
      _showInlineError(
        'Solo un perfil profesional de organizador puede publicar eventos online.',
      );
      return;
    }

    setState(() {
      _eventType = value;
      if (_eventType == 'online') {
        _dateType = 'single';
        _selectedVenue = null;
        _clearExternalVenueFields();
      } else {
        _meetingUrlController.clear();
        _onlinePriceController.clear();
        _onlineTicketAvailableController.clear();
        _onlineMaxBuyController.clear();
        _earlyBirdAmountController.clear();
        _onlineTicketAvailabilityType = 'limited';
        _onlineMaxBuyType = 'limited';
        _onlineEarlyBirdMode = 'disable';
        _onlineDiscountType = 'fixed';
        _earlyBirdDate = null;
        _earlyBirdTime = null;
      }
    });
  }

  Future<void> _bootstrap() async {
    setState(() => _isBootstrapping = true);

    try {
      final repository = ref.read(professionalEventRepositoryProvider);
      final categories = await repository.getCategories();
      final eventDetail = _isEditMode
          ? await repository.getEvent(widget.eventId!)
          : const <String, dynamic>{};
      final venueResults = await repository.searchVenues('');
      final artistResults = await repository.searchArtists('');

      if (!mounted) return;
      final preferredVenue = _preferredVenueFromResults(venueResults);
      setState(() {
        _categories = categories;
        _selectedCategoryId = categories.isNotEmpty
            ? categories.first.id
            : null;
        _venueResults = venueResults;
        _artistResults = artistResults;
        if (_isVenueIdentityAuthoring && preferredVenue != null) {
          _selectedVenue = preferredVenue;
          _venueSource = 'registered';
        }
        if (_isEditMode) {
          final detailPayload = eventDetail['data'];
          _hydrateFromEventDetail(
            detailPayload is Map<String, dynamic>
                ? detailPayload
                : detailPayload is Map
                ? Map<String, dynamic>.from(detailPayload)
                : null,
          );
        }
        _isBootstrapping = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _isBootstrapping = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_extractApiErrorMessage(error))));
    }
  }

  void _hydrateFromEventDetail(Map<String, dynamic>? payload) {
    if (payload == null) {
      _mobileEditingSupported = false;
      _mobileEditingReason = 'No se pudo cargar el evento.';
      return;
    }

    _mobileEditingSupported = payload['mobile_authoring_supported'] == true;
    _mobileEditingReason = payload['mobile_authoring_reason']?.toString();
    final managementSummary =
        payload['management_summary'] is Map<String, dynamic>
        ? payload['management_summary'] as Map<String, dynamic>
        : payload['management_summary'] is Map
        ? Map<String, dynamic>.from(payload['management_summary'] as Map)
        : const <String, dynamic>{};
    final hostingVenueSummary =
        payload['hosting_venue_summary'] is Map<String, dynamic>
        ? payload['hosting_venue_summary'] as Map<String, dynamic>
        : payload['hosting_venue_summary'] is Map
        ? Map<String, dynamic>.from(payload['hosting_venue_summary'] as Map)
        : const <String, dynamic>{};
    _managedByType = managementSummary['managed_by_type']?.toString();
    _hostingVenueName = hostingVenueSummary['name']?.toString();

    final defaults = payload['form_defaults'] is Map<String, dynamic>
        ? payload['form_defaults'] as Map<String, dynamic>
        : payload['form_defaults'] is Map
        ? Map<String, dynamic>.from(payload['form_defaults'] as Map)
        : const <String, dynamic>{};

    _titleController.text = defaults['title']?.toString() ?? '';
    _descriptionController.text = defaults['description']?.toString() ?? '';
    _refundPolicyController.text = defaults['refund_policy']?.toString() ?? '';
    _ageLimitController.text = payload['age_limit']?.toString() ?? '';
    _eventType = defaults['event_type']?.toString() == 'online'
        ? 'online'
        : 'venue';
    _meetingUrlController.text = defaults['meeting_url']?.toString() ?? '';
    _onlinePriceController.text = defaults['price']?.toString() ?? '';
    _onlineTicketAvailableController.text =
        defaults['ticket_available']?.toString() ?? '';
    _onlineMaxBuyController.text = defaults['max_buy_ticket']?.toString() ?? '';
    _earlyBirdAmountController.text =
        defaults['early_bird_discount_amount']?.toString() ?? '';
    _onlineTicketAvailabilityType =
        defaults['ticket_available_type']?.toString() == 'unlimited'
        ? 'unlimited'
        : 'limited';
    _onlineMaxBuyType =
        defaults['max_ticket_buy_type']?.toString() == 'unlimited'
        ? 'unlimited'
        : 'limited';
    _onlineEarlyBirdMode =
        defaults['early_bird_discount_type']?.toString() == 'enable'
        ? 'enable'
        : 'disable';
    _onlineDiscountType = defaults['discount_type']?.toString() == 'percentage'
        ? 'percentage'
        : 'fixed';
    _settlementHoldMode = defaults['hold_mode']?.toString() == 'manual_admin'
        ? 'manual_admin'
        : 'auto_after_grace_period';
    _settlementGraceHours =
        int.tryParse(defaults['grace_period_hours']?.toString() ?? '') ?? 72;
    _refundWindowHours =
        int.tryParse(defaults['refund_window_hours']?.toString() ?? '') ?? 72;
    _autoReleaseOwnerShare = _parseBoolValue(
      defaults['auto_release_owner_share'],
    );
    _requireAdminApproval = _parseBoolValue(defaults['require_admin_approval']);
    _selectedCategoryId =
        int.tryParse(defaults['category_id']?.toString() ?? '') ??
        _selectedCategoryId;
    final venueSource = defaults['venue_source']?.toString();
    _venueSource = switch (venueSource) {
      'external' => 'external',
      'manual' => 'manual',
      _ => 'registered',
    };

    _existingThumbnailUrl = payload['thumbnail_url']?.toString();
    _currentStatus = payload['status']?.toString() == '1' ? '1' : '0';
    _currentFeatured = payload['is_featured']?.toString() == 'yes'
        ? 'yes'
        : 'no';
    _reviewStatus = payload['review_status']?.toString();
    _reviewNotes = payload['review_notes']?.toString();
    _dateType = payload['date_type']?.toString() == 'multiple'
        ? 'multiple'
        : 'single';
    if (_eventType == 'online') {
      _dateType = 'single';
    }

    final gallery = payload['gallery'];
    if (gallery is List) {
      _existingGallery = gallery
          .map(
            (item) => item is Map<String, dynamic>
                ? item
                : Map<String, dynamic>.from(item as Map),
          )
          .toList();
    }

    _startDate = _parseDate(payload['start_date']?.toString());
    _endDate = _parseDate(payload['end_date']?.toString());
    _startTime = _parseTime(payload['start_time']?.toString());
    _endTime = _parseTime(payload['end_time']?.toString());
    _earlyBirdDate = _parseDate(
      defaults['early_bird_discount_date']?.toString(),
    );
    _earlyBirdTime = _parseTime(
      defaults['early_bird_discount_time']?.toString(),
    );
    _dateSlots.clear();
    final dates = payload['dates'];
    if (dates is List) {
      for (final item in dates) {
        final dateMap = item is Map<String, dynamic>
            ? item
            : Map<String, dynamic>.from(item as Map);
        _dateSlots.add(
          _EventDateDraft(
            id: int.tryParse(dateMap['id']?.toString() ?? ''),
            startDate: _parseDate(dateMap['start_date']?.toString()),
            startTime: _parseTime(dateMap['start_time']?.toString()),
            endDate: _parseDate(dateMap['end_date']?.toString()),
            endTime: _parseTime(dateMap['end_time']?.toString()),
          ),
        );
      }
    }
    if (_dateType == 'multiple' && _dateSlots.isEmpty) {
      _dateSlots.add(
        _EventDateDraft(
          startDate: _startDate,
          startTime: _startTime,
          endDate: _endDate,
          endTime: _endTime,
        ),
      );
    }

    if (_venueSource == 'registered') {
      final selectedVenue = payload['selected_venue'];
      final venueMap = selectedVenue is Map<String, dynamic>
          ? selectedVenue
          : selectedVenue is Map
          ? Map<String, dynamic>.from(selectedVenue)
          : null;
      if (venueMap != null) {
        _selectedVenue = DiscoveryProfileModel(
          id: int.tryParse(venueMap['id']?.toString() ?? '') ?? 0,
          type: 'venue',
          name: venueMap['name']?.toString() ?? 'Venue',
          username: venueMap['username']?.toString(),
          city: venueMap['city']?.toString(),
          country: venueMap['country']?.toString(),
        );
      }
    } else {
      _venueNameController.text = defaults['venue_name']?.toString() ?? '';
      _venueAddressController.text =
          defaults['venue_address']?.toString() ?? '';
      _venueCityController.text = defaults['venue_city']?.toString() ?? '';
      _venueStateController.text = defaults['venue_state']?.toString() ?? '';
      _venueCountryController.text =
          defaults['venue_country']?.toString() ?? '';
      _venuePostalCodeController.text =
          defaults['venue_postal_code']?.toString() ?? '';
      _venueLatitudeController.text = defaults['latitude']?.toString() ?? '';
      _venueLongitudeController.text = defaults['longitude']?.toString() ?? '';
      _googlePlaceIdController.text =
          defaults['venue_google_place_id']?.toString() ?? '';
    }

    final selectedArtistProfiles = <int, DiscoveryProfileModel>{};
    final selectedArtists = payload['selected_artists'];
    if (selectedArtists is List) {
      for (final item in selectedArtists) {
        final artist = item is Map<String, dynamic>
            ? item
            : Map<String, dynamic>.from(item as Map);
        final artistId = int.tryParse(artist['id']?.toString() ?? '') ?? 0;
        if (artistId <= 0) {
          continue;
        }

        selectedArtistProfiles[artistId] = DiscoveryProfileModel(
          id: artistId,
          type: 'artist',
          name:
              artist['display_name']?.toString() ??
              artist['name']?.toString() ??
              'Artist',
          username: artist['username']?.toString(),
          photo: artist['photo']?.toString(),
        );
      }
    }

    _lineupItems.clear();
    final lineup = payload['lineup'];
    if (lineup is List && lineup.isNotEmpty) {
      for (final item in lineup) {
        final lineupItem = item is Map<String, dynamic>
            ? item
            : Map<String, dynamic>.from(item as Map);
        final sourceType = lineupItem['source_type']?.toString() ?? 'manual';
        if (sourceType == 'artist') {
          final artistId =
              int.tryParse(lineupItem['artist_id']?.toString() ?? '') ?? 0;
          if (artistId <= 0) {
            continue;
          }
          final artistProfile =
              selectedArtistProfiles[artistId] ??
              DiscoveryProfileModel(
                id: artistId,
                type: 'artist',
                name: lineupItem['display_name']?.toString() ?? 'Artist',
              );
          _lineupItems.add(_LineupDraftItem.registered(artistProfile));
        } else {
          final displayName = lineupItem['display_name']?.toString().trim();
          if (displayName == null || displayName.isEmpty) {
            continue;
          }
          _lineupItems.add(_LineupDraftItem.manual(displayName));
        }
      }
    } else {
      _lineupItems.addAll(
        selectedArtistProfiles.values.map(_LineupDraftItem.registered),
      );
      final manualArtistsText =
          defaults['manual_artists_text']?.toString() ?? '';
      for (final name in manualArtistsText.split(RegExp(r'[\r\n,]+'))) {
        final normalized = name.replaceAll(RegExp(r'\s+'), ' ').trim();
        if (normalized.isNotEmpty) {
          _lineupItems.add(_LineupDraftItem.manual(normalized));
        }
      }
    }

    _headlinerKey = payload['headliner_key']?.toString();
    _ensureHeadliner();
    _hydrateRewardDrafts(payload, defaults);
  }

  void _hydrateRewardDrafts(
    Map<String, dynamic> payload,
    Map<String, dynamic> defaults,
  ) {
    final rawRewards = payload['reward_definitions'] is List
        ? payload['reward_definitions'] as List
        : defaults['reward_definitions'] is List
        ? defaults['reward_definitions'] as List
        : const [];

    _rewardItems
      ..clear()
      ..addAll(
        rawRewards
            .map(
              (item) => item is Map<String, dynamic>
                  ? item
                  : item is Map
                  ? Map<String, dynamic>.from(item)
                  : null,
            )
            .whereType<Map<String, dynamic>>()
            .map(
              (item) =>
                  _RewardDraftItem.fromPayload(item, _nextRewardDraftKey()),
            ),
      );
  }

  DateTime? _parseDate(String? value) {
    if (value == null || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }

  TimeOfDay? _parseTime(String? value) {
    if (value == null || value.isEmpty) return null;
    final parts = value.split(':');
    if (parts.length < 2) return null;
    return TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 0,
      minute: int.tryParse(parts[1]) ?? 0,
    );
  }

  bool _parseBoolValue(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    final normalized = value?.toString().trim().toLowerCase();
    return normalized == '1' || normalized == 'true' || normalized == 'yes';
  }

  String _nextRewardDraftKey() {
    _rewardDraftSeed += 1;
    return 'reward-$_rewardDraftSeed';
  }

  void _addRewardDraft() {
    if (_rewardItems.length >= 8) {
      _showInlineError(
        'Por ahora recomendamos un máximo de 8 rewards por evento para mantener la operación clara.',
      );
      return;
    }

    setState(() {
      _rewardItems.add(
        _RewardDraftItem(
          localKey: _nextRewardDraftKey(),
          claimCodePrefix: 'RWD${_rewardItems.length + 1}',
        ),
      );
    });
  }

  void _removeRewardDraft(String localKey) {
    setState(() {
      _rewardItems.removeWhere((item) => item.localKey == localKey);
    });
  }

  void _updateRewardDraft(
    String localKey,
    _RewardDraftItem Function(_RewardDraftItem current) transform,
  ) {
    final index = _rewardItems.indexWhere((item) => item.localKey == localKey);
    if (index < 0) {
      return;
    }

    setState(() {
      _rewardItems[index] = transform(_rewardItems[index]);
    });
  }

  bool _validateRewardDrafts() {
    for (final reward in _rewardItems) {
      if (reward.title.trim().isEmpty) {
        _showInlineError(
          'Cada reward necesita un título claro para operación y claim.',
        );
        return false;
      }

      final inventoryValue = reward.inventoryLimit.trim();
      if (inventoryValue.isNotEmpty) {
        final parsedInventory = int.tryParse(inventoryValue);
        if (parsedInventory == null || parsedInventory <= 0) {
          _showInlineError(
            'Si defines un inventario de reward, debe ser un número mayor que cero.',
          );
          return false;
        }
      }

      final normalizedPrefix = reward.claimCodePrefix
          .replaceAll(RegExp(r'[^A-Za-z0-9]'), '')
          .trim();
      if (reward.claimCodePrefix.trim().isNotEmpty &&
          (normalizedPrefix.isEmpty || normalizedPrefix.length > 8)) {
        _showInlineError(
          'El prefijo del claim code debe ser alfanumérico y tener máximo 8 caracteres.',
        );
        return false;
      }
    }

    return true;
  }

  Future<void> _searchVenues([String query = '']) async {
    final trimmed = query.trim();
    setState(() => _isSearchingVenues = true);
    try {
      final results = await ref
          .read(professionalEventRepositoryProvider)
          .searchVenues(trimmed);
      if (!mounted) return;
      final preferredVenue = _preferredVenueFromResults(results);
      setState(() {
        _hasVenueSearchAttempted = trimmed.isNotEmpty;
        _venueResults = results;
        if (_isVenueIdentityAuthoring && preferredVenue != null) {
          _selectedVenue = preferredVenue;
          _venueSource = 'registered';
        }
        _isSearchingVenues = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSearchingVenues = false);
    }
  }

  Future<void> _searchArtists([String query = '']) async {
    final trimmed = query.trim();
    setState(() => _isSearchingArtists = true);
    try {
      final results = await ref
          .read(professionalEventRepositoryProvider)
          .searchArtists(trimmed);
      if (!mounted) return;
      setState(() {
        _hasArtistSearchAttempted = trimmed.isNotEmpty;
        _artistResults = results;
        _isSearchingArtists = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSearchingArtists = false);
    }
  }

  void _scheduleVenueSearch(String query) {
    _venueSearchDebounce?.cancel();
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      setState(() {
        _hasVenueSearchAttempted = false;
      });
      _searchVenues('');
      return;
    }

    _venueSearchDebounce = Timer(const Duration(milliseconds: 300), () {
      _searchVenues(trimmed);
    });
  }

  void _scheduleArtistSearch(String query) {
    _artistSearchDebounce?.cancel();
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      setState(() {
        _hasArtistSearchAttempted = false;
      });
      _searchArtists('');
      return;
    }

    _artistSearchDebounce = Timer(const Duration(milliseconds: 300), () {
      _searchArtists(trimmed);
    });
  }

  Future<void> _searchGooglePlaces([String query = '']) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      if (!mounted) return;
      setState(() {
        _googlePlaceResults = const [];
        _isSearchingGooglePlaces = false;
      });
      return;
    }

    setState(() => _isSearchingGooglePlaces = true);
    try {
      final results = await ref
          .read(professionalEventRepositoryProvider)
          .searchGooglePlaces(trimmed);
      if (!mounted) return;
      setState(() {
        _googlePlaceResults = results;
        _isSearchingGooglePlaces = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSearchingGooglePlaces = false);
    }
  }

  Future<void> _selectGooglePlace(GooglePlaceSuggestionModel suggestion) async {
    setState(() => _isSearchingGooglePlaces = true);
    try {
      final details = await ref
          .read(professionalEventRepositoryProvider)
          .getGooglePlaceDetails(suggestion.placeId);
      if (!mounted) return;
      final resolved = details ?? suggestion;
      setState(() {
        _venueQueryController.text = resolved.description;
        _venueNameController.text = resolved.name ?? resolved.title;
        _venueAddressController.text = resolved.address ?? resolved.description;
        _venueCityController.text = resolved.city ?? '';
        _venueStateController.text = resolved.state ?? '';
        _venueCountryController.text = resolved.country ?? '';
        _venuePostalCodeController.text = resolved.postalCode ?? '';
        _venueLatitudeController.text = resolved.latitude?.toString() ?? '';
        _venueLongitudeController.text = resolved.longitude?.toString() ?? '';
        _googlePlaceIdController.text = resolved.placeId;
        _googlePlaceResults = const [];
        _isSearchingGooglePlaces = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSearchingGooglePlaces = false);
      _showInlineError(
        'No se pudo cargar el detalle del lugar en Google Maps.',
      );
    }
  }

  Future<void> _pickThumbnail() async {
    final image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 82,
      maxWidth: 1600,
      maxHeight: 1600,
    );
    if (image == null) return;
    final optimized = await _optimizeEventImage(
      File(image.path),
      prefix: 'event_thumb',
      targetWidth: 720,
      targetHeight: 520,
      quality: 72,
      maxBytes: _thumbnailMaxBytes,
    );
    if (optimized.lengthSync() > _thumbnailMaxBytes) {
      _showInlineError(
        'El thumbnail sigue demasiado pesado. Intenta con una imagen más liviana.',
      );
      return;
    }
    setState(() {
      _thumbnailFile = optimized;
    });
  }

  Future<void> _pickGalleryImages() async {
    final remainingSlots = _maxGalleryImages - _galleryFiles.length;
    if (remainingSlots <= 0) {
      _showInlineError(
        'Puedes subir hasta $_maxGalleryImages imágenes en la galería del evento.',
      );
      return;
    }

    final images = await _imagePicker.pickMultiImage(
      imageQuality: 76,
      maxWidth: 1440,
      maxHeight: 1440,
    );
    if (images.isEmpty) return;
    final limitedImages = images.take(remainingSlots).toList();
    if (images.length > remainingSlots) {
      _showInlineError(
        'Solo se agregarán $remainingSlots imágenes para mantener la galería ligera.',
      );
    }
    final optimizedImages = <File>[];
    for (final image in limitedImages) {
      final optimized = await _optimizeEventImage(
        File(image.path),
        prefix: 'event_gallery',
        targetWidth: 1280,
        targetHeight: 720,
        quality: 72,
        maxBytes: _galleryImageMaxBytes,
      );
      if (optimized.lengthSync() > _galleryImageMaxBytes) {
        _showInlineError(
          'Una de las imágenes de galería sigue muy pesada y no se agregó.',
        );
        continue;
      }
      optimizedImages.add(optimized);
    }
    if (optimizedImages.isEmpty) return;
    final projectedTotalBytes = _calculateUploadBudgetBytes(
      thumbnail: _thumbnailFile,
      gallery: [..._galleryFiles, ...optimizedImages],
    );
    if (projectedTotalBytes > _totalUploadBudgetBytes) {
      _showInlineError(
        'La suma del thumbnail y la galería supera el límite del formulario. Usa menos imágenes o más ligeras.',
      );
      return;
    }
    setState(() {
      _galleryFiles = [..._galleryFiles, ...optimizedImages];
    });
  }

  String _buildCompressedPath(String originalPath, String prefix) {
    final lastSlash = originalPath.lastIndexOf('/');
    final dir = lastSlash == -1
        ? Directory.systemTemp.path
        : originalPath.substring(0, lastSlash);
    return '$dir/${prefix}_${DateTime.now().microsecondsSinceEpoch}.jpg';
  }

  Future<File> _optimizeEventImage(
    File source, {
    required String prefix,
    required int targetWidth,
    required int targetHeight,
    required int quality,
    required int maxBytes,
  }) async {
    try {
      File currentFile = source;
      var currentQuality = quality;
      var currentWidth = targetWidth;
      var currentHeight = targetHeight;

      while (true) {
        final compressed = await FlutterImageCompress.compressAndGetFile(
          currentFile.absolute.path,
          _buildCompressedPath(source.path, prefix),
          quality: currentQuality,
          minWidth: currentWidth,
          minHeight: currentHeight,
          format: CompressFormat.jpeg,
          keepExif: false,
          autoCorrectionAngle: true,
        );

        if (compressed == null) {
          return currentFile;
        }

        final optimized = File(compressed.path);
        if (optimized.lengthSync() <= maxBytes || currentQuality <= 42) {
          return optimized;
        }

        currentFile = optimized;
        currentQuality -= 6;
        currentWidth = (currentWidth * 0.88).round().clamp(420, targetWidth);
        currentHeight = (currentHeight * 0.88).round().clamp(300, targetHeight);
      }
    } on MissingPluginException {
      return source;
    } catch (_) {
      return source;
    }
  }

  int _calculateUploadBudgetBytes({
    required File? thumbnail,
    required List<File> gallery,
  }) {
    var total = 0;
    if (thumbnail != null && thumbnail.existsSync()) {
      total += thumbnail.lengthSync();
    }
    for (final file in gallery) {
      if (file.existsSync()) {
        total += file.lengthSync();
      }
    }
    return total;
  }

  String _formatBytes(int value) {
    final kb = value / 1024;
    if (kb < 1024) {
      return '${kb.toStringAsFixed(0)} KB';
    }
    return '${(kb / 1024).toStringAsFixed(1)} MB';
  }

  Future<void> _selectDate({required bool isStart}) async {
    final now = DateTime.now();
    final firstDate = DateUtils.dateOnly(now);
    
    // Ensure initial date is not before firstDate to avoid assertion error
    DateTime initialDate = isStart
        ? (_startDate ?? now)
        : (_endDate ?? _startDate ?? now);
    
    if (initialDate.isBefore(firstDate)) {
      initialDate = firstDate;
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: now.add(const Duration(days: 730)),
      builder: _darkDatePickerBuilder,
    );

    if (picked == null || !mounted) return;

    setState(() {
      if (isStart) {
        _startDate = picked;
        _endDate ??= picked;
      } else {
        _endDate = picked;
      }
    });
  }

  Widget _darkDatePickerBuilder(BuildContext context, Widget? child) {
    final palette = context.dutyTheme;
    return Theme(
      data: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.dark(
          primary: _authoringAccentColor,
          onPrimary: palette.onPrimary,
          surface: palette.surface,
          onSurface: palette.textPrimary,
        ),
      ),
      child: child!,
    );
  }

  Future<void> _selectTime({required bool isStart}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart
          ? (_startTime ?? const TimeOfDay(hour: 20, minute: 0))
          : (_endTime ?? const TimeOfDay(hour: 1, minute: 0)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(primary: _authoringAccentColor),
          ),
          child: child!,
        );
      },
    );

    if (picked == null || !mounted) return;
    setState(() {
      if (isStart) {
        _startTime = picked;
      } else {
        _endTime = picked;
      }
    });
  }

  void _switchDateType(String value) {
    if (_dateType == value) {
      return;
    }

    if (_eventType == 'online' && value != 'single') {
      return;
    }

    setState(() {
      _dateType = value;
      if (_dateType == 'multiple') {
        if (_dateSlots.isEmpty) {
          _dateSlots.add(
            _EventDateDraft(
              startDate: _startDate,
              startTime: _startTime,
              endDate: _endDate,
              endTime: _endTime,
            ),
          );
        }
      } else if (_dateSlots.isNotEmpty) {
        final first = _dateSlots.first;
        final last = _dateSlots.last;
        _startDate = first.startDate ?? _startDate;
        _startTime = first.startTime ?? _startTime;
        _endDate = last.endDate ?? _endDate;
        _endTime = last.endTime ?? _endTime;
      }
    });
  }

  void _addDateSlot() {
    setState(() {
      _dateSlots.add(
        _EventDateDraft(
          startDate: _dateSlots.isNotEmpty
              ? _dateSlots.last.endDate
              : _startDate,
          startTime: _dateSlots.isNotEmpty
              ? _dateSlots.last.startTime
              : _startTime,
          endDate: _dateSlots.isNotEmpty ? _dateSlots.last.endDate : _endDate,
          endTime: _dateSlots.isNotEmpty ? _dateSlots.last.endTime : _endTime,
        ),
      );
    });
  }

  void _removeDateSlot(int index) {
    if (index < 0 || index >= _dateSlots.length) {
      return;
    }

    setState(() {
      _dateSlots.removeAt(index);
      if (_dateSlots.isEmpty) {
        _dateSlots.add(_EventDateDraft());
      }
    });
  }

  Future<void> _selectDateSlotDate(int index, {required bool isStart}) async {
    if (index < 0 || index >= _dateSlots.length) {
      return;
    }

    final slot = _dateSlots[index];
    final now = DateTime.now();
    final initialDate = isStart
        ? (slot.startDate ?? now)
        : (slot.endDate ?? slot.startDate ?? now);
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: now,
      lastDate: now.add(const Duration(days: 730)),
      builder: _darkDatePickerBuilder,
    );

    if (picked == null || !mounted) return;

    setState(() {
      if (isStart) {
        slot.startDate = picked;
        slot.endDate ??= picked;
      } else {
        slot.endDate = picked;
      }
    });
  }

  Future<void> _selectDateSlotTime(int index, {required bool isStart}) async {
    if (index < 0 || index >= _dateSlots.length) {
      return;
    }

    final slot = _dateSlots[index];
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart
          ? (slot.startTime ?? const TimeOfDay(hour: 20, minute: 0))
          : (slot.endTime ?? const TimeOfDay(hour: 1, minute: 0)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(primary: _authoringAccentColor),
          ),
          child: child!,
        );
      },
    );

    if (picked == null || !mounted) return;

    setState(() {
      if (isStart) {
        slot.startTime = picked;
      } else {
        slot.endTime = picked;
      }
    });
  }

  Future<void> _selectEarlyBirdDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _earlyBirdDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 730)),
      builder: _darkDatePickerBuilder,
    );

    if (picked == null || !mounted) return;
    setState(() => _earlyBirdDate = picked);
  }

  Future<void> _selectEarlyBirdTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _earlyBirdTime ?? const TimeOfDay(hour: 18, minute: 0),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(primary: _authoringAccentColor),
          ),
          child: child!,
        );
      },
    );

    if (picked == null || !mounted) return;
    setState(() => _earlyBirdTime = picked);
  }

  bool _isArtistSelected(int artistId) {
    return _lineupItems.any(
      (item) => item.isArtist && item.artistId == artistId,
    );
  }

  void _ensureHeadliner() {
    if (_lineupItems.isEmpty) {
      _headlinerKey = null;
      return;
    }

    if (_headlinerKey == null ||
        !_lineupItems.any((item) => item.key == _headlinerKey)) {
      _headlinerKey = _lineupItems.first.key;
    }
  }

  void _addArtist(DiscoveryProfileModel artist) {
    if (_isArtistSelected(artist.id)) return;
    setState(() {
      _lineupItems.add(_LineupDraftItem.registered(artist));
      _ensureHeadliner();
    });
  }

  void _addManualArtist() {
    final normalized = _manualArtistsController.text
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    if (normalized.isEmpty) {
      return;
    }

    final manualItem = _LineupDraftItem.manual(normalized);
    if (_lineupItems.any((item) => item.key == manualItem.key)) {
      _showInlineError('Ese artista manual ya está en el lineup.');
      return;
    }

    setState(() {
      _lineupItems.add(manualItem);
      _manualArtistsController.clear();
      _ensureHeadliner();
    });
  }

  void _removeLineupItem(String key) {
    setState(() {
      _lineupItems.removeWhere((item) => item.key == key);
      _ensureHeadliner();
    });
  }

  void _moveLineupItem(String key, int direction) {
    final index = _lineupItems.indexWhere((item) => item.key == key);
    if (index < 0) {
      return;
    }

    final nextIndex = index + direction;
    if (nextIndex < 0 || nextIndex >= _lineupItems.length) {
      return;
    }

    setState(() {
      final item = _lineupItems.removeAt(index);
      _lineupItems.insert(nextIndex, item);
      _ensureHeadliner();
    });
  }

  void _setHeadliner(String key) {
    setState(() {
      _headlinerKey = key;
      _ensureHeadliner();
    });
  }

  Future<void> _submit() async {
    if (!_canAuthorEvents) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Necesitas una identidad activa de organizador o venue para crear eventos.',
          ),
        ),
      );
      return;
    }

    if (_isEditMode && !_mobileEditingSupported) {
      _showInlineError(
        _mobileEditingReason ??
            'Este evento no es compatible con el editor móvil actual.',
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    if (_thumbnailFile == null &&
        (!_isEditMode ||
            _existingThumbnailUrl == null ||
            _existingThumbnailUrl!.isEmpty)) {
      _showInlineError('Selecciona un thumbnail para el evento.');
      return;
    }

    if (_galleryFiles.isEmpty && (!_isEditMode || _existingGallery.isEmpty)) {
      _showInlineError('Agrega al menos una imagen de galería.');
      return;
    }

    if (_thumbnailFile != null &&
        _thumbnailFile!.lengthSync() > _thumbnailMaxBytes) {
      _showInlineError(
        'El thumbnail excede el peso recomendado (${_formatBytes(_thumbnailMaxBytes)}). Elige una imagen más ligera.',
      );
      return;
    }

    for (final file in _galleryFiles) {
      if (file.lengthSync() > _galleryImageMaxBytes) {
        _showInlineError(
          'Una imagen de la galería excede el peso recomendado (${_formatBytes(_galleryImageMaxBytes)}).',
        );
        return;
      }
    }

    final totalUploadBytes = _calculateUploadBudgetBytes(
      thumbnail: _thumbnailFile,
      gallery: _galleryFiles,
    );
    if (totalUploadBytes > _totalUploadBudgetBytes) {
      _showInlineError(
        'El total de imágenes del evento supera el límite permitido (${_formatBytes(_totalUploadBudgetBytes)}). Reduce la galería o usa imágenes más ligeras.',
      );
      return;
    }

    DateTime? startDateTime;
    DateTime? endDateTime;
    if (_dateType == 'single') {
      if (_startDate == null ||
          _endDate == null ||
          _startTime == null ||
          _endTime == null) {
        _showInlineError('Completa la fecha y horario del evento.');
        return;
      }

      startDateTime = DateTime(
        _startDate!.year,
        _startDate!.month,
        _startDate!.day,
        _startTime!.hour,
        _startTime!.minute,
      );
      endDateTime = DateTime(
        _endDate!.year,
        _endDate!.month,
        _endDate!.day,
        _endTime!.hour,
        _endTime!.minute,
      );

      if (!endDateTime.isAfter(startDateTime)) {
        _showInlineError('La fecha final debe ser posterior al inicio.');
        return;
      }
    } else {
      if (_dateSlots.isEmpty) {
        _showInlineError('Agrega al menos una fecha al evento.');
        return;
      }

      for (var index = 0; index < _dateSlots.length; index++) {
        final slot = _dateSlots[index];
        if (!slot.isComplete) {
          _showInlineError(
            'Completa inicio y cierre de la fecha #${index + 1}.',
          );
          return;
        }

        final slotStart = DateTime(
          slot.startDate!.year,
          slot.startDate!.month,
          slot.startDate!.day,
          slot.startTime!.hour,
          slot.startTime!.minute,
        );
        final slotEnd = DateTime(
          slot.endDate!.year,
          slot.endDate!.month,
          slot.endDate!.day,
          slot.endTime!.hour,
          slot.endTime!.minute,
        );
        if (!slotEnd.isAfter(slotStart)) {
          _showInlineError(
            'La fecha #${index + 1} debe cerrar después de su hora de inicio.',
          );
          return;
        }
      }
    }

    if (_selectedCategoryId == null) {
      _showInlineError('Selecciona una categoría.');
      return;
    }

    if (!_validateRewardDrafts()) {
      return;
    }

    if (_eventType == 'venue') {
      if (_venueSource == 'registered' &&
          _selectedVenue == null &&
          !_isVenueIdentityAuthoring) {
        _showInlineError('Selecciona un venue registrado.');
        return;
      }

      if (_venueSource == 'external') {
        if (_venueLatitudeController.text.trim().isEmpty ||
            _venueLongitudeController.text.trim().isEmpty) {
          _showInlineError(
            'Para un venue externo necesitas latitud y longitud tomadas de Google Maps.',
          );
          return;
        }
      }
    } else {
      if (_meetingUrlController.text.trim().isEmpty) {
        _showInlineError('Agrega el enlace de acceso del evento online.');
        return;
      }

      if (_onlinePriceController.text.trim().isEmpty) {
        _showInlineError('Define el precio de la entrada online.');
        return;
      }

      if (_onlineTicketAvailabilityType == 'limited' &&
          _onlineTicketAvailableController.text.trim().isEmpty) {
        _showInlineError('Indica cuántos tickets online estarán disponibles.');
        return;
      }

      if (_onlineMaxBuyType == 'limited' &&
          _onlineMaxBuyController.text.trim().isEmpty) {
        _showInlineError('Indica cuántos tickets puede comprar cada usuario.');
        return;
      }

      if (_onlineEarlyBirdMode == 'enable') {
        if (_earlyBirdAmountController.text.trim().isEmpty ||
            _earlyBirdDate == null ||
            _earlyBirdTime == null) {
          _showInlineError(
            'Completa monto, fecha y hora del early bird para el evento online.',
          );
          return;
        }
      }
    }

    setState(() => _isSubmitting = true);

    try {
      final repository = ref.read(professionalEventRepositoryProvider);
      final formatter = DateFormat('yyyy-MM-dd');
      final timeFormatter = DateFormat('HH:mm');
      final metaKeywords = <String>{
        _titleController.text.trim(),
        ..._lineupItems.map((item) => item.displayName.trim()),
      }.where((keyword) => keyword.isNotEmpty).join(',');

      final formData = FormData();
      formData.fields.addAll([
        if (_isEditMode) MapEntry('event_id', widget.eventId.toString()),
        MapEntry('status', _isEditMode ? _currentStatus : '0'),
        MapEntry('is_featured', _isEditMode ? _currentFeatured : 'no'),
        MapEntry('event_type', _eventType),
        MapEntry('date_type', _eventType == 'online' ? 'single' : _dateType),
        MapEntry('en_title', _titleController.text.trim()),
        MapEntry('en_category_id', _selectedCategoryId.toString()),
        MapEntry('en_description', _descriptionController.text.trim()),
        MapEntry(
          'en_refund_policy',
          _refundPolicyController.text.trim().isEmpty
              ? 'Refund policy pending organizer confirmation.'
              : _refundPolicyController.text.trim(),
        ),
        MapEntry('en_meta_keywords', metaKeywords),
        MapEntry(
          'en_meta_description',
          _buildMetaDescription(_descriptionController.text.trim()),
        ),
        MapEntry('hold_mode', _settlementHoldMode),
        MapEntry('grace_period_hours', _settlementGraceHours.toString()),
        MapEntry('refund_window_hours', _refundWindowHours.toString()),
        MapEntry(
          'auto_release_owner_share',
          _autoReleaseOwnerShare ? '1' : '0',
        ),
        const MapEntry('auto_release_collaborator_shares', '0'),
        MapEntry('require_admin_approval', _requireAdminApproval ? '1' : '0'),
        if (_ageLimitController.text.trim().isNotEmpty)
          MapEntry('age_limit', _ageLimitController.text.trim()),
      ]);

      if (_eventType == 'online' || _dateType == 'single') {
        formData.fields.addAll([
          MapEntry('start_date', formatter.format(_startDate!)),
          MapEntry('start_time', timeFormatter.format(startDateTime!)),
          MapEntry('end_date', formatter.format(_endDate!)),
          MapEntry('end_time', timeFormatter.format(endDateTime!)),
        ]);
      } else {
        for (final slot in _dateSlots) {
          formData.fields.addAll([
            MapEntry('date_ids[]', slot.id?.toString() ?? ''),
            MapEntry('m_start_date[]', formatter.format(slot.startDate!)),
            MapEntry('m_start_time[]', _formatTimeForPayload(slot.startTime!)),
            MapEntry('m_end_date[]', formatter.format(slot.endDate!)),
            MapEntry('m_end_time[]', _formatTimeForPayload(slot.endTime!)),
          ]);
        }
      }

      if (_eventType == 'venue') {
        formData.fields.add(MapEntry('venue_source', _venueSource));
        if (_venueSource == 'registered' && _selectedVenue != null) {
          formData.fields.add(
            MapEntry('venue_id', _selectedVenue!.id.toString()),
          );
        } else {
          formData.fields.addAll([
            MapEntry('venue_name', _venueNameController.text.trim()),
            MapEntry('venue_address', _venueAddressController.text.trim()),
            MapEntry('venue_city', _venueCityController.text.trim()),
            MapEntry('venue_state', _venueStateController.text.trim()),
            MapEntry('venue_country', _venueCountryController.text.trim()),
            MapEntry(
              'venue_postal_code',
              _venuePostalCodeController.text.trim(),
            ),
            if (_venueSource == 'external')
              MapEntry('latitude', _venueLatitudeController.text.trim()),
            if (_venueSource == 'external')
              MapEntry('longitude', _venueLongitudeController.text.trim()),
            if (_venueSource == 'external' &&
                _googlePlaceIdController.text.trim().isNotEmpty)
              MapEntry(
                'venue_google_place_id',
                _googlePlaceIdController.text.trim(),
              ),
          ]);
        }
      } else {
        formData.fields.addAll([
          MapEntry('meeting_url', _meetingUrlController.text.trim()),
          MapEntry('price', _onlinePriceController.text.trim()),
          const MapEntry('pricing_type', 'normal'),
          MapEntry('ticket_available_type', _onlineTicketAvailabilityType),
          if (_onlineTicketAvailabilityType == 'limited')
            MapEntry(
              'ticket_available',
              _onlineTicketAvailableController.text.trim(),
            ),
          MapEntry('max_ticket_buy_type', _onlineMaxBuyType),
          if (_onlineMaxBuyType == 'limited')
            MapEntry('max_buy_ticket', _onlineMaxBuyController.text.trim()),
          MapEntry('early_bird_discount_type', _onlineEarlyBirdMode),
          if (_onlineEarlyBirdMode == 'enable')
            MapEntry('discount_type', _onlineDiscountType),
          if (_onlineEarlyBirdMode == 'enable')
            MapEntry(
              'early_bird_discount_amount',
              _earlyBirdAmountController.text.trim(),
            ),
          if (_onlineEarlyBirdMode == 'enable' && _earlyBirdDate != null)
            MapEntry(
              'early_bird_discount_date',
              formatter.format(_earlyBirdDate!),
            ),
          if (_onlineEarlyBirdMode == 'enable' && _earlyBirdTime != null)
            MapEntry(
              'early_bird_discount_time',
              _formatTimeForPayload(_earlyBirdTime!),
            ),
        ]);
      }

      for (final artist in _lineupItems.where((item) => item.isArtist)) {
        formData.fields.add(
          MapEntry('artist_ids[]', artist.artistId!.toString()),
        );
      }

      final manualArtists = _lineupItems
          .where((item) => item.sourceType == 'manual')
          .map((item) => item.displayName)
          .toList();
      for (final manualArtist in manualArtists) {
        formData.fields.add(MapEntry('manual_artists[]', manualArtist));
      }
      if (manualArtists.isNotEmpty) {
        formData.fields.add(
          MapEntry('manual_artists_text', manualArtists.join('\n')),
        );
      }
      for (final item in _lineupItems) {
        formData.fields.add(MapEntry('lineup_order[]', item.key));
      }
      if (_headlinerKey != null && _headlinerKey!.isNotEmpty) {
        formData.fields.add(MapEntry('headliner_key', _headlinerKey!));
      }

      formData.fields.add(
        MapEntry(
          'reward_definitions_payload',
          jsonEncode(_rewardItems.map((item) => item.toPayload()).toList()),
        ),
      );

      if (_thumbnailFile != null) {
        formData.files.add(
          MapEntry(
            'thumbnail',
            await MultipartFile.fromFile(
              _thumbnailFile!.path,
              filename: _thumbnailFile!.path.split('/').last,
            ),
          ),
        );
      }

      for (final file in _galleryFiles) {
        formData.files.add(
          MapEntry(
            'slider_files[]',
            await MultipartFile.fromFile(
              file.path,
              filename: file.path.split('/').last,
            ),
          ),
        );
      }

      final response = _isEditMode
          ? await repository.updateEvent(widget.eventId!, formData)
          : await repository.createEvent(formData);
      final message = response['message']?.toString().trim();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message?.isNotEmpty == true
                ? message!
                : _isEditMode
                ? 'Cambios enviados a revisión del equipo Duty.'
                : 'Evento enviado a revisión del equipo Duty.',
          ),
        ),
      );

      ref.invalidate(professionalDashboardProvider);

      context.go('/professional/events');
    } catch (error) {
      if (!mounted) return;
      _showInlineError(_extractApiErrorMessage(error));
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  String _buildMetaDescription(String description) {
    final normalized = description.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (normalized.length <= 155) {
      return normalized;
    }
    return '${normalized.substring(0, 152)}...';
  }

  void _showInlineError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String get _effectiveManagedByType {
    final managedByType = _managedByType;
    if (managedByType != null &&
        (managedByType == 'organizer' || managedByType == 'venue')) {
      return managedByType;
    }

    return _isVenueIdentityAuthoring ? 'venue' : 'organizer';
  }

  bool get _isOrganizerManaged => _effectiveManagedByType == 'organizer';
  bool get _isVenueManaged => _effectiveManagedByType == 'venue';

  String get _managementContextLabel => switch (_effectiveManagedByType) {
    'venue' => 'Gestionado por venue',
    _ => 'Gestionado por organizer',
  };

  String? get _resolvedHostingVenueLabel {
    if (_eventType != 'venue' || !_isOrganizerManaged) {
      return null;
    }

    final registeredVenueName = _venueSource == 'registered'
        ? _selectedVenue?.name
        : null;
    final manualVenueName =
        _venueSource == 'external' || _venueSource == 'manual'
        ? _venueNameController.text.trim()
        : '';
    final resolvedName = registeredVenueName?.trim().isNotEmpty == true
        ? registeredVenueName!.trim()
        : manualVenueName.isNotEmpty
        ? manualVenueName
        : (_hostingVenueName?.trim().isNotEmpty == true
              ? _hostingVenueName!.trim()
              : null);

    return resolvedName == null ? null : 'Venue anfitrión: $resolvedName';
  }

  String _extractApiErrorMessage(Object error) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map<String, dynamic>) {
        final message = data['message']?.toString().trim();
        if (message != null && message.isNotEmpty) {
          return message;
        }

        final errors = data['errors'];
        if (errors is Map && errors.isNotEmpty) {
          final first = errors.values.first;
          if (first is List && first.isNotEmpty) {
            return _normalizeUploadError(first.first.toString());
          }
          return _normalizeUploadError(first.toString());
        }
      }

      if (data is String && data.trim().isNotEmpty) {
        return _normalizeUploadError(data.trim());
      }

      final fallback = error.message?.trim();
      if (fallback != null && fallback.isNotEmpty) {
        return _normalizeUploadError(fallback);
      }
    }

    final fallback = error.toString().trim();
    if (fallback.isNotEmpty && fallback != 'null') {
      return _normalizeUploadError(fallback);
    }

    return _isEditMode
        ? 'No se pudo actualizar el evento.'
        : 'No se pudo crear el evento.';
  }

  String _normalizeUploadError(String value) {
    final normalized = value.trim();
    final lower = normalized.toLowerCase();
    if ((lower.contains('thumbnail') && lower.contains('failed to upload')) ||
        lower.contains('slider files') ||
        lower.contains('slider_files') ||
        lower.contains('failed to upload') ||
        lower.contains('post_max_size') ||
        lower.contains('upload_max_filesize')) {
      return 'Las imágenes del evento pesan demasiado para el límite actual del servidor. Usa 1 thumbnail ligero y una galería corta; la app ya intenta optimizarlas, pero si siguen pesadas debes elegir archivos más livianos.';
    }
    return normalized;
  }

  @override
  Widget build(BuildContext context) {
    final activeProfile = ref.watch(activeProfileProvider);
    final palette = _palette;

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        backgroundColor: palette.background,
        elevation: 0,
        title: Text(
          _isEditMode ? 'Editar Evento' : 'Crear Evento',
          style: GoogleFonts.splineSans(
            color: palette.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: _isBootstrapping
          ? const Center(child: CircularProgressIndicator())
          : !_canAuthorEvents
          ? _buildBlockedState(activeProfile)
          : SafeArea(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  children: [
                    _buildIdentityBanner(activeProfile!),
                    const SizedBox(height: 16),
                    _buildManagementContextCard(),
                    const SizedBox(height: 16),
                    _buildApprovalReviewCard(),
                    if (_isEditMode && _reviewStatus != null) ...[
                      const SizedBox(height: 16),
                      _buildReviewFeedbackCard(),
                    ],
                    const SizedBox(height: 16),
                    _buildSectionCard(
                      title: 'Media',
                      subtitle: _isEditMode
                          ? 'Puedes conservar la media actual o sustituirla. La app optimiza las imágenes y el servidor las adapta al formato del evento.'
                          : 'Sube el thumbnail y la galería principal. La app optimiza las imágenes y el servidor las adapta al formato del evento.',
                      child: Column(
                        children: [
                          if (_isEditMode && _existingThumbnailUrl != null)
                            _buildExistingMediaPreview(
                              label: 'Thumbnail actual',
                              items: [_existingThumbnailUrl!],
                            ),
                          if (_isEditMode && _existingThumbnailUrl != null)
                            const SizedBox(height: 12),
                          _buildMediaPicker(
                            label: 'Thumbnail 320x230',
                            onTap: _pickThumbnail,
                            file: _thumbnailFile,
                            icon: Icons.image_outlined,
                          ),
                          const SizedBox(height: 12),
                          if (_isEditMode && _existingGallery.isNotEmpty)
                            _buildExistingMediaPreview(
                              label: 'Galería actual',
                              items: _existingGallery
                                  .map((item) => item['url']?.toString() ?? '')
                                  .where((item) => item.isNotEmpty)
                                  .toList(),
                            ),
                          if (_isEditMode && _existingGallery.isNotEmpty)
                            const SizedBox(height: 12),
                          _buildGalleryPicker(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildSectionCard(
                      title: 'Datos base',
                      subtitle: _isEditMode
                          ? 'Edita los datos base del evento profesional desde la app.'
                          : 'Este wizard crea el evento profesional y lo deja listo para completar su operación principal.',
                      child: Column(
                        children: [
                          if (activeProfile.type == ProfileType.organizer) ...[
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Tipo de evento',
                                style: GoogleFonts.splineSans(
                                  color: palette.textPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: [
                                _buildEventTypeChip('venue', 'Venue'),
                                _buildEventTypeChip('online', 'Online'),
                              ],
                            ),
                            const SizedBox(height: 12),
                          ] else
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: palette.surfaceAlt,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: palette.border),
                              ),
                              child: Text(
                                'Este perfil publica eventos presenciales asociados a un venue.',
                                style: GoogleFonts.splineSans(
                                  color: palette.textSecondary,
                                ),
                              ),
                            ),
                          if (activeProfile.type != ProfileType.organizer)
                            const SizedBox(height: 12),
                          _buildTextField(
                            controller: _titleController,
                            label: 'Título del evento',
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Escribe un título';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<int>(
                            initialValue: _selectedCategoryId,
                            dropdownColor: palette.surface,
                            style: GoogleFonts.splineSans(
                              color: palette.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                            iconEnabledColor: palette.textSecondary,
                            decoration: _inputDecoration('Categoría'),
                            items: _categories
                                .map(
                                  (category) => DropdownMenuItem<int>(
                                    value: category.id,
                                    child: Text(
                                      category.name,
                                      style: GoogleFonts.splineSans(
                                        color: palette.textPrimary,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              setState(() => _selectedCategoryId = value);
                            },
                            validator: (value) => value == null
                                ? 'Selecciona una categoría'
                                : null,
                          ),
                          const SizedBox(height: 12),
                          _buildTextField(
                            controller: _descriptionController,
                            label: 'Descripción',
                            maxLines: 5,
                            validator: (value) {
                              if (value == null || value.trim().length < 30) {
                                return 'La descripción debe tener al menos 30 caracteres';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          _buildTextField(
                            controller: _refundPolicyController,
                            label: 'Política de reembolso',
                            maxLines: 3,
                          ),
                          const SizedBox(height: 12),
                          _buildTextField(
                            controller: _ageLimitController,
                            label: 'Edad mínima (opcional)',
                            keyboardType: TextInputType.number,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildSettlementSection(),
                    const SizedBox(height: 16),
                    _buildSectionCard(
                      title: 'Horario',
                      subtitle: _eventType == 'online'
                          ? 'Los eventos online se gestionan como una sola fecha con acceso programado.'
                          : _dateType == 'single'
                          ? 'Define una sola fecha de inicio y cierre.'
                          : 'Agrega todas las fechas del evento y ordénalas cronológicamente.',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_eventType == 'online')
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: palette.surfaceAlt,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: palette.border),
                              ),
                              child: Text(
                                'Modo single-date fijo para eventos online.',
                                style: GoogleFonts.splineSans(
                                  color: palette.textSecondary,
                                ),
                              ),
                            )
                          else
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: [
                                _buildDateTypeChip('single', 'Una fecha'),
                                _buildDateTypeChip('multiple', 'Varias fechas'),
                              ],
                            ),
                          const SizedBox(height: 12),
                          if (_dateType == 'single')
                            Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildDateButton(
                                        label: 'Fecha inicio',
                                        value: _formatDate(_startDate),
                                        onTap: () => _selectDate(isStart: true),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildTimeButton(
                                        label: 'Hora inicio',
                                        value: _formatTime(_startTime),
                                        onTap: () => _selectTime(isStart: true),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildDateButton(
                                        label: 'Fecha cierre',
                                        value: _formatDate(_endDate),
                                        onTap: () =>
                                            _selectDate(isStart: false),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildTimeButton(
                                        label: 'Hora cierre',
                                        value: _formatTime(_endTime),
                                        onTap: () =>
                                            _selectTime(isStart: false),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            )
                          else
                            _buildMultipleDateScheduler(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_eventType == 'venue') ...[
                      _buildVenueSection(),
                      const SizedBox(height: 16),
                    ] else ...[
                      _buildOnlineTicketingSection(),
                      const SizedBox(height: 16),
                    ],
                    _buildRewardsSection(),
                    const SizedBox(height: 16),
                    _buildArtistSection(),
                    const SizedBox(height: 20),
                    if (_isEditMode && !_mobileEditingSupported)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildUnsupportedEditCard(),
                      ),
                    SizedBox(
                      height: 54,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _authoringAccentColor,
                          foregroundColor: palette.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed:
                            _isSubmitting ||
                                (_isEditMode && !_mobileEditingSupported)
                            ? null
                            : _submit,
                        child: _isSubmitting
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: palette.onPrimary,
                                ),
                              )
                            : Text(
                                _isEditMode
                                    ? 'Guardar cambios'
                                    : 'Enviar a revisión',
                                style: GoogleFonts.splineSans(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildBlockedState(AppProfile? activeProfile) {
    final palette = _palette;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: palette.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: palette.border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.lock_outline_rounded,
                size: 48,
                color: palette.textSecondary,
              ),
              const SizedBox(height: 12),
              Text(
                'Acceso profesional requerido',
                style: GoogleFonts.splineSans(
                  color: palette.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                activeProfile == null
                    ? 'Activa una identidad aprobada de organizador o venue desde el centro de cuentas.'
                    : 'Tu perfil activo actual no puede crear eventos desde esta herramienta.',
                textAlign: TextAlign.center,
                style: GoogleFonts.splineSans(color: palette.textSecondary),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () => context.push('/account-center'),
                child: const Text('Ir al centro de cuentas'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIdentityBanner(AppProfile activeProfile) {
    final palette = _palette;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            _authoringAccentColor.withValues(alpha: 0.16),
            palette.heroGradientStart,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: _authoringAccentColor.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: _authoringAccentColor.withValues(alpha: 0.18),
            ),
            child: Icon(
              activeProfile.type == ProfileType.organizer
                  ? Icons.event_available_rounded
                  : Icons.location_city_rounded,
              color: palette.textPrimary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activeProfile.name,
                  style: GoogleFonts.splineSans(
                    color: palette.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Creando como ${activeProfile.type == ProfileType.organizer ? 'organizador' : 'venue'} activo.',
                  style: GoogleFonts.splineSans(
                    color: palette.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApprovalReviewCard() {
    final palette = _palette;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.warning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: palette.warning.withValues(alpha: 0.36)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.fact_check_outlined, color: palette.warning),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Revisión administrativa obligatoria',
                  style: GoogleFonts.splineSans(
                    color: palette.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Los eventos creados desde la app no se publican automáticamente. Quedan en revisión hasta que el equipo admin los apruebe en el panel.',
                  style: GoogleFonts.splineSans(
                    color: palette.textSecondary,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewFeedbackCard() {
    final palette = _palette;
    final status = _reviewStatus ?? 'pending';
    final tone = switch (status) {
      'approved' => palette.success,
      'changes_requested' => palette.warning,
      'rejected' => palette.danger,
      _ => palette.info,
    };
    final title = switch (status) {
      'approved' => 'Evento aprobado',
      'changes_requested' => 'Cambios solicitados',
      'rejected' => 'Evento rechazado',
      _ => 'Evento en revisión',
    };
    final body = switch (status) {
      'approved' =>
        'Este evento ya fue aprobado por el equipo Duty. Si haces cambios y guardas, volverá a revisión.',
      'changes_requested' =>
        'El equipo Duty devolvió este evento con observaciones. Corrígelo aquí y vuelve a enviarlo.',
      'rejected' =>
        'Este evento fue rechazado. Puedes revisar las notas, ajustar la propuesta y enviarla nuevamente.',
      _ =>
        'Este evento sigue en revisión administrativa y todavía no está publicado.',
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: tone.withValues(alpha: 0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.rule_folder_outlined, color: tone),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.splineSans(
                    color: palette.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: GoogleFonts.splineSans(
              color: palette.textSecondary,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          if (_reviewNotes != null && _reviewNotes!.trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: palette.surfaceAlt.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: palette.border),
              ),
              child: Text(
                _reviewNotes!.trim(),
                style: GoogleFonts.splineSans(
                  color: palette.textPrimary,
                  fontSize: 13,
                  height: 1.45,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDateTypeChip(String value, String label) {
    final selected = _dateType == value;
    return _buildSegmentChip(
      label: label,
      selected: selected,
      onTap: () => _switchDateType(value),
      accent: _authoringAccentColor,
      icon: value == 'single'
          ? Icons.calendar_today_rounded
          : Icons.date_range_rounded,
    );
  }

  Widget _buildEventTypeChip(String value, String label) {
    final selected = _eventType == value;
    return _buildSegmentChip(
      label: label,
      selected: selected,
      onTap: () => _switchEventType(value),
      accent: _authoringAccentColor,
      icon: value == 'online'
          ? Icons.wifi_tethering_rounded
          : Icons.location_on_outlined,
    );
  }

  Widget _buildMultipleDateScheduler() {
    final palette = _palette;
    return Column(
      children: [
        if (_dateSlots.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: palette.surfaceAlt,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: palette.border),
            ),
            child: Text(
              'Agrega la primera fecha del evento.',
              style: GoogleFonts.splineSans(color: palette.textSecondary),
            ),
          )
        else
          Column(
            children: List.generate(
              _dateSlots.length,
              (index) => _buildDateSlotCard(index),
            ),
          ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: _addDateSlot,
            icon: const Icon(Icons.add_circle_outline_rounded),
            label: const Text('Agregar fecha'),
          ),
        ),
      ],
    );
  }

  Widget _buildDateSlotCard(int index) {
    final palette = _palette;
    final slot = _dateSlots[index];

    return Container(
      margin: EdgeInsets.only(bottom: index == _dateSlots.length - 1 ? 0 : 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: palette.surfaceAlt,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Fecha #${index + 1}',
                style: GoogleFonts.splineSans(
                  color: palette.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              if (_dateSlots.length > 1)
                IconButton(
                  onPressed: () => _removeDateSlot(index),
                  icon: const Icon(Icons.delete_outline_rounded),
                ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: _buildDateButton(
                  label: 'Inicio',
                  value: _formatDate(slot.startDate),
                  onTap: () => _selectDateSlotDate(index, isStart: true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTimeButton(
                  label: 'Hora inicio',
                  value: _formatTime(slot.startTime),
                  onTap: () => _selectDateSlotTime(index, isStart: true),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDateButton(
                  label: 'Cierre',
                  value: _formatDate(slot.endDate),
                  onTap: () => _selectDateSlotDate(index, isStart: false),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTimeButton(
                  label: 'Hora cierre',
                  value: _formatTime(slot.endTime),
                  onTap: () => _selectDateSlotTime(index, isStart: false),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVenueSection() {
    final palette = _palette;
    return _buildSectionCard(
      title: 'Venue',
      subtitle:
          'Elige un venue registrado, una ubicacion de Google Maps o una referencia manual simple.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isVenueIdentityAuthoring) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _authoringAccentColor.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _authoringAccentColor.withValues(alpha: 0.28),
                ),
              ),
              child: Text(
                'Este evento quedará vinculado al venue activo de tu cuenta. Puedes revisar la ficha, pero la publicación usará ese espacio automáticamente.',
                style: GoogleFonts.splineSans(
                  color: palette.textSecondary,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ] else ...[
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _buildChoiceChip(
                  'registered',
                  'Venue registrado',
                  icon: Icons.storefront_outlined,
                ),
                _buildChoiceChip(
                  'external',
                  'Google Maps / externo',
                  icon: Icons.map_outlined,
                ),
                _buildChoiceChip(
                  'manual',
                  'Venue manual',
                  icon: Icons.edit_location_alt_outlined,
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
          if (_venueSource == 'registered') ...[
            _buildSearchBar(
              controller: _venueQueryController,
              hint: _isVenueIdentityAuthoring
                  ? 'Tu venue activo se usará automáticamente'
                  : 'Buscar venue registrado',
              isLoading: _isSearchingVenues,
              onSubmitted: _searchVenues,
              onSearchTap: () => _searchVenues(_venueQueryController.text),
              onChanged: _scheduleVenueSearch,
            ),
            const SizedBox(height: 12),
            if (_selectedVenue != null) _buildSelectedVenueCard(),
            if (!_isVenueIdentityAuthoring && _venueResults.isNotEmpty)
              ..._venueResults.take(5).map(_buildVenueResultTile),
            if (!_isVenueIdentityAuthoring &&
                _hasVenueSearchAttempted &&
                !_isSearchingVenues &&
                _venueResults.isEmpty)
              _buildEmptySearchState(
                'No encontramos venues registrados con ese nombre todavía.',
              ),
          ] else ...[
            if (_venueSource == 'external') ...[
              _buildSearchBar(
                controller: _venueQueryController,
                hint: 'Buscar lugar en Google Maps',
                isLoading: _isSearchingGooglePlaces,
                onSubmitted: _searchGooglePlaces,
                onSearchTap: () =>
                    _searchGooglePlaces(_venueQueryController.text),
              ),
              if (_googlePlaceResults.isNotEmpty) ...[
                const SizedBox(height: 12),
                ..._googlePlaceResults.take(5).map(_buildGooglePlaceResultTile),
              ],
            ] else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: palette.surfaceAlt,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: palette.border),
                ),
                child: Text(
                  'Usa venue manual cuando solo quieras guardar el nombre y la referencia del lugar sin depender de Google Maps.',
                  style: GoogleFonts.splineSans(color: palette.textSecondary),
                ),
              ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _venueNameController,
              label: 'Nombre del venue',
              validator: (value) {
                if ((_venueSource == 'external' || _venueSource == 'manual') &&
                    (value == null || value.trim().isEmpty)) {
                  return 'Escribe el nombre del venue';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _venueAddressController,
              label: _venueSource == 'external'
                  ? 'Direccion / referencia Google Maps'
                  : 'Direccion o referencia',
              validator: (value) {
                if ((_venueSource == 'external' || _venueSource == 'manual') &&
                    (value == null || value.trim().isEmpty)) {
                  return 'Escribe la dirección';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _venueCityController,
                    label: 'Ciudad',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    controller: _venueStateController,
                    label: 'Estado / provincia',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _venueCountryController,
                    label: 'País',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    controller: _venuePostalCodeController,
                    label: 'Código postal',
                  ),
                ),
              ],
            ),
            if (_venueSource == 'external') ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _venueLatitudeController,
                      label: 'Latitud',
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                      validator: (value) {
                        if (_venueSource == 'external' &&
                            (value == null || value.trim().isEmpty)) {
                          return 'Requerido';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      controller: _venueLongitudeController,
                      label: 'Longitud',
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                      validator: (value) {
                        if (_venueSource == 'external' &&
                            (value == null || value.trim().isEmpty)) {
                          return 'Requerido';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _googlePlaceIdController,
                label: 'Google Place ID (opcional)',
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildManagementContextCard() {
    final palette = _palette;
    final hostingVenueLabel = _resolvedHostingVenueLabel;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: _authoringAccentColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  _isVenueManaged
                      ? Icons.storefront_outlined
                      : Icons.hub_outlined,
                  color: _authoringAccentColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _managementContextLabel,
                      style: GoogleFonts.splineSans(
                        color: palette.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _isVenueManaged
                          ? 'Este perfil venue conserva toda la gestión del evento.'
                          : 'El organizer conserva la gestión aunque selecciones un venue anfitrión.',
                      style: GoogleFonts.splineSans(
                        color: palette.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (hostingVenueLabel != null) ...[
            const SizedBox(height: 14),
            _buildManagementMetaPill(
              hostingVenueLabel,
              icon: Icons.location_on_outlined,
            ),
          ],
          if (_isOrganizerManaged) ...[
            const SizedBox(height: 12),
            Text(
              'Seleccionar un venue solo define la sede del evento. No transfiere acceso de gestión a ese venue dentro del centro de cuentas.',
              style: GoogleFonts.splineSans(
                color: palette.textMuted,
                fontSize: 12.5,
                height: 1.45,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildManagementMetaPill(String label, {required IconData icon}) {
    final palette = _palette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: palette.surfaceAlt,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: palette.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: palette.textSecondary),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              style: GoogleFonts.splineSans(
                color: palette.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettlementSection() {
    final palette = _palette;
    return _buildSectionCard(
      title: 'Retención y liquidación',
      subtitle:
          'Define cuánto tiempo se retiene el dinero del evento antes de poder liberarlo al organizer o venue.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Modo de retención',
            style: GoogleFonts.splineSans(
              color: palette.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _buildSegmentChip(
                label: 'Revisión manual',
                selected: _settlementHoldMode == 'manual_admin',
                accent: _authoringAccentColor,
                icon: Icons.admin_panel_settings_outlined,
                onTap: () {
                  setState(() {
                    _settlementHoldMode = 'manual_admin';
                    _autoReleaseOwnerShare = false;
                  });
                },
              ),
              _buildSegmentChip(
                label: 'Auto tras gracia',
                selected: _settlementHoldMode == 'auto_after_grace_period',
                accent: _authoringAccentColor,
                icon: Icons.schedule_outlined,
                onTap: () {
                  setState(() {
                    _settlementHoldMode = 'auto_after_grace_period';
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Período de gracia',
            style: GoogleFonts.splineSans(
              color: palette.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [24, 48, 72, 168]
                .map(
                  (hours) => _buildSegmentChip(
                    label: hours == 168 ? '7 días' : '$hours h',
                    selected: _settlementGraceHours == hours,
                    accent: _authoringAccentColor,
                    onTap: () {
                      setState(() => _settlementGraceHours = hours);
                    },
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          Text(
            'Ventana de reembolso tras reprogramación',
            style: GoogleFonts.splineSans(
              color: palette.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [24, 48, 72, 168]
                .map(
                  (hours) => _buildSegmentChip(
                    label: hours == 168 ? '7 días' : '$hours h',
                    selected: _refundWindowHours == hours,
                    accent: _authoringAccentColor,
                    onTap: () {
                      setState(() => _refundWindowHours = hours);
                    },
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          _buildSettlementToggleTile(
            title: 'Liberar automáticamente al wallet al cerrar el hold',
            subtitle: _settlementHoldMode == 'manual_admin'
                ? 'Desactivado mientras el evento requiera revisión manual.'
                : 'Si está activo, el share del organizer/venue podrá pasar al wallet al terminar el período de gracia.',
            value: _autoReleaseOwnerShare,
            enabled: _settlementHoldMode == 'auto_after_grace_period',
            onChanged: (value) {
              setState(() => _autoReleaseOwnerShare = value);
            },
          ),
          const SizedBox(height: 10),
          _buildSettlementToggleTile(
            title: 'Requerir validación admin antes de liberar fondos',
            subtitle:
                'Útil para eventos sensibles, cambios de fecha o revisión operativa posterior.',
            value: _requireAdminApproval,
            onChanged: (value) {
              setState(() => _requireAdminApproval = value);
            },
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: palette.surfaceAlt,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: palette.border),
            ),
            child: Text(
              'Hold actual: ${_settlementHoldMode == 'manual_admin' ? 'manual hasta revisión admin' : 'auto luego de ${_settlementGraceHours == 168 ? '7 días' : '$_settlementGraceHours horas'}'}. Reembolsos por reprogramación: ${_refundWindowHours == 168 ? '7 días' : '$_refundWindowHours horas'}.',
              style: GoogleFonts.splineSans(
                color: palette.textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettlementToggleTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool enabled = true,
  }) {
    final palette = _palette;
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 180),
      opacity: enabled ? 1 : 0.58,
      child: Container(
        decoration: BoxDecoration(
          color: palette.surfaceAlt,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: palette.border),
        ),
        child: SwitchListTile.adaptive(
          value: value,
          onChanged: enabled ? onChanged : null,
          activeThumbColor: _authoringAccentColor,
          activeTrackColor: _authoringAccentColor.withValues(alpha: 0.42),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 4,
          ),
          title: Text(
            title,
            style: GoogleFonts.splineSans(
              color: palette.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: GoogleFonts.splineSans(
              color: palette.textMuted,
              height: 1.35,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGooglePlaceResultTile(GooglePlaceSuggestionModel place) {
    final palette = _palette;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: palette.surfaceAlt,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: palette.border),
      ),
      child: ListTile(
        onTap: () => _selectGooglePlace(place),
        title: Text(
          place.title,
          style: GoogleFonts.splineSans(color: palette.textPrimary),
        ),
        subtitle: Text(
          place.subtitle ?? place.description,
          style: GoogleFonts.splineSans(color: palette.textMuted),
        ),
        trailing: Icon(Icons.place_outlined, color: _authoringAccentColor),
      ),
    );
  }

  Widget _buildOnlineTicketingSection() {
    final palette = _palette;
    return _buildSectionCard(
      title: 'Ticketing online',
      subtitle:
          'Configura el acceso, el precio y las reglas de venta del evento online.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField(
            controller: _meetingUrlController,
            label: 'Meeting URL',
            hint: 'https://zoom.us/j/... o enlace privado',
          ),
          const SizedBox(height: 12),
          _buildTextField(
            controller: _onlinePriceController,
            label: 'Precio',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 16),
          Text(
            'Disponibilidad de tickets',
            style: GoogleFonts.splineSans(
              color: palette.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _buildSegmentChip(
                label: 'Limitada',
                selected: _onlineTicketAvailabilityType == 'limited',
                onTap: () =>
                    setState(() => _onlineTicketAvailabilityType = 'limited'),
                accent: _authoringAccentColor,
              ),
              _buildSegmentChip(
                label: 'Ilimitada',
                selected: _onlineTicketAvailabilityType == 'unlimited',
                onTap: () =>
                    setState(() => _onlineTicketAvailabilityType = 'unlimited'),
                accent: _authoringAccentColor,
              ),
            ],
          ),
          if (_onlineTicketAvailabilityType == 'limited') ...[
            const SizedBox(height: 12),
            _buildTextField(
              controller: _onlineTicketAvailableController,
              label: 'Cantidad disponible',
              keyboardType: TextInputType.number,
            ),
          ],
          const SizedBox(height: 16),
          Text(
            'Límite por comprador',
            style: GoogleFonts.splineSans(
              color: palette.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _buildSegmentChip(
                label: 'Limitado',
                selected: _onlineMaxBuyType == 'limited',
                onTap: () => setState(() => _onlineMaxBuyType = 'limited'),
                accent: _authoringAccentColor,
              ),
              _buildSegmentChip(
                label: 'Ilimitado',
                selected: _onlineMaxBuyType == 'unlimited',
                onTap: () => setState(() => _onlineMaxBuyType = 'unlimited'),
                accent: _authoringAccentColor,
              ),
            ],
          ),
          if (_onlineMaxBuyType == 'limited') ...[
            const SizedBox(height: 12),
            _buildTextField(
              controller: _onlineMaxBuyController,
              label: 'Máximo por usuario',
              keyboardType: TextInputType.number,
            ),
          ],
          const SizedBox(height: 16),
          Text(
            'Early bird',
            style: GoogleFonts.splineSans(
              color: palette.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _buildSegmentChip(
                label: 'Sin early bird',
                selected: _onlineEarlyBirdMode == 'disable',
                onTap: () => setState(() => _onlineEarlyBirdMode = 'disable'),
                accent: _authoringAccentColor,
              ),
              _buildSegmentChip(
                label: 'Activar early bird',
                selected: _onlineEarlyBirdMode == 'enable',
                onTap: () => setState(() => _onlineEarlyBirdMode = 'enable'),
                accent: _authoringAccentColor,
              ),
            ],
          ),
          if (_onlineEarlyBirdMode == 'enable') ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _buildSegmentChip(
                  label: 'Monto fijo',
                  selected: _onlineDiscountType == 'fixed',
                  onTap: () => setState(() => _onlineDiscountType = 'fixed'),
                  accent: _authoringAccentColor,
                ),
                _buildSegmentChip(
                  label: 'Porcentaje',
                  selected: _onlineDiscountType == 'percentage',
                  onTap: () =>
                      setState(() => _onlineDiscountType = 'percentage'),
                  accent: _authoringAccentColor,
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _earlyBirdAmountController,
              label: _onlineDiscountType == 'percentage'
                  ? 'Descuento %'
                  : 'Descuento',
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildDateButton(
                    label: 'Fecha límite',
                    value: _formatDate(_earlyBirdDate),
                    onTap: _selectEarlyBirdDate,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTimeButton(
                    label: 'Hora límite',
                    value: _formatTime(_earlyBirdTime),
                    onTap: _selectEarlyBirdTime,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRewardsSection() {
    final palette = _palette;

    return _buildSectionCard(
      title: 'Rewards & Perks',
      subtitle:
          'Configura perks que el sistema emitirá con la compra y podrá activar al escanear la boleta.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: palette.surfaceAlt,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: palette.border),
            ),
            child: Text(
              'V1: estos rewards aplican a las compras del evento completo. Luego podremos segmentarlos por ticket, sponsor o estación.',
              style: GoogleFonts.splineSans(
                color: palette.textSecondary,
                height: 1.45,
              ),
            ),
          ),
          const SizedBox(height: 14),
          if (_rewardItems.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: palette.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: palette.border),
              ),
              child: Text(
                'Aún no has configurado perks. Puedes empezar con algo simple como Welcome drink, merch claim o acceso prioritario.',
                style: GoogleFonts.splineSans(
                  color: palette.textSecondary,
                  height: 1.45,
                ),
              ),
            )
          else
            Column(
              children: _rewardItems
                  .map((reward) => _buildRewardDraftCard(reward))
                  .toList(),
            ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _addRewardDraft,
              icon: const Icon(Icons.local_bar_outlined),
              label: const Text('Agregar reward'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardDraftCard(_RewardDraftItem reward) {
    final palette = _palette;

    return Container(
      key: ValueKey(reward.localKey),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: reward.isActive
              ? _authoringAccentColor.withValues(alpha: 0.18)
              : palette.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: _authoringAccentColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  _rewardTypeIcon(reward.rewardType),
                  color: _authoringAccentColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reward.title.trim().isEmpty
                          ? 'Nuevo reward'
                          : reward.title.trim(),
                      style: GoogleFonts.splineSans(
                        color: palette.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      reward.isActive
                          ? 'Activo para emitir y activar'
                          : 'Guardado en estado inactivo',
                      style: GoogleFonts.splineSans(
                        color: palette.textMuted,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton.filledTonal(
                onPressed: () => _removeRewardDraft(reward.localKey),
                icon: const Icon(Icons.delete_outline_rounded),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildTextField(
            fieldKey: ValueKey('${reward.localKey}-title'),
            initialValue: reward.title,
            label: 'Título del reward',
            hint: 'Ej: Welcome drink',
            onChanged: (value) => _updateRewardDraft(
              reward.localKey,
              (current) => current.copyWith(title: value),
            ),
          ),
          const SizedBox(height: 12),
          _buildTextField(
            fieldKey: ValueKey('${reward.localKey}-description'),
            initialValue: reward.description,
            label: 'Descripción operativa',
            hint:
                'Ej: Un trago de bienvenida reclamable en la barra principal.',
            maxLines: 3,
            onChanged: (value) => _updateRewardDraft(
              reward.localKey,
              (current) => current.copyWith(description: value),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Tipo de reward',
            style: GoogleFonts.splineSans(
              color: palette.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _buildRewardTypeChip(
                reward,
                value: 'welcome_drink',
                label: 'Welcome drink',
              ),
              _buildRewardTypeChip(
                reward,
                value: 'drink_voucher',
                label: 'Voucher de bebida',
              ),
              _buildRewardTypeChip(reward, value: 'merch', label: 'Merch'),
              _buildRewardTypeChip(
                reward,
                value: 'perk_access',
                label: 'Acceso / perk',
              ),
              _buildRewardTypeChip(reward, value: 'custom', label: 'Custom'),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Momento de activación',
            style: GoogleFonts.splineSans(
              color: palette.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _buildRewardTriggerChip(
                reward,
                value: 'on_ticket_scan',
                label: 'Al escanear ticket',
                icon: Icons.qr_code_scanner_rounded,
              ),
              _buildRewardTriggerChip(
                reward,
                value: 'on_booking_completed',
                label: 'Al completar compra',
                icon: Icons.shopping_bag_outlined,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  fieldKey: ValueKey('${reward.localKey}-quantity'),
                  initialValue: reward.perTicketQuantity.toString(),
                  label: 'Cantidad por ticket',
                  keyboardType: TextInputType.number,
                  onChanged: (value) => _updateRewardDraft(
                    reward.localKey,
                    (current) => current.copyWith(
                      perTicketQuantity:
                          int.tryParse(value.trim()) != null &&
                              int.parse(value.trim()) > 0
                          ? int.parse(value.trim())
                          : 1,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  fieldKey: ValueKey('${reward.localKey}-inventory'),
                  initialValue: reward.inventoryLimit,
                  label: 'Inventario total (opcional)',
                  keyboardType: TextInputType.number,
                  onChanged: (value) => _updateRewardDraft(
                    reward.localKey,
                    (current) => current.copyWith(inventoryLimit: value),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildTextField(
            fieldKey: ValueKey('${reward.localKey}-prefix'),
            initialValue: reward.claimCodePrefix,
            label: 'Prefijo del claim code',
            hint: 'Ej: DRINK',
            onChanged: (value) => _updateRewardDraft(
              reward.localKey,
              (current) => current.copyWith(claimCodePrefix: value),
            ),
          ),
          const SizedBox(height: 12),
          _buildSettlementToggleTile(
            title: 'Reward activo',
            subtitle:
                'Si lo apagas, se mantiene en el evento pero no se emitirá para nuevas compras.',
            value: reward.isActive,
            onChanged: (value) => _updateRewardDraft(
              reward.localKey,
              (current) => current.copyWith(isActive: value),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardTypeChip(
    _RewardDraftItem reward, {
    required String value,
    required String label,
  }) {
    return _buildSegmentChip(
      label: label,
      selected: reward.rewardType == value,
      accent: _authoringAccentColor,
      onTap: () => _updateRewardDraft(
        reward.localKey,
        (current) => current.copyWith(rewardType: value),
      ),
    );
  }

  Widget _buildRewardTriggerChip(
    _RewardDraftItem reward, {
    required String value,
    required String label,
    required IconData icon,
  }) {
    return _buildSegmentChip(
      label: label,
      icon: icon,
      selected: reward.triggerMode == value,
      accent: _authoringAccentColor,
      onTap: () => _updateRewardDraft(
        reward.localKey,
        (current) => current.copyWith(triggerMode: value),
      ),
    );
  }

  IconData _rewardTypeIcon(String rewardType) {
    switch (rewardType) {
      case 'welcome_drink':
      case 'drink_voucher':
        return Icons.local_bar_outlined;
      case 'merch':
        return Icons.redeem_outlined;
      case 'perk_access':
        return Icons.workspace_premium_outlined;
      default:
        return Icons.card_giftcard_outlined;
    }
  }

  Widget _buildArtistSection() {
    final palette = _palette;
    return _buildSectionCard(
      title: 'Lineup',
      subtitle:
          'Combina artistas registrados con nombres manuales, ordénalos y marca un headliner.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_lineupItems.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: palette.surfaceAlt,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: palette.border),
              ),
              child: Text(
                'Aún no has armado el lineup. Agrega artistas registrados o nombres manuales y luego define el orden.',
                style: GoogleFonts.splineSans(color: palette.textSecondary),
              ),
            )
          else
            _buildLineupDraftList(),
          const SizedBox(height: 16),
          _buildSearchBar(
            controller: _artistQueryController,
            hint: 'Buscar artista registrado',
            isLoading: _isSearchingArtists,
            onSubmitted: _searchArtists,
            onSearchTap: () => _searchArtists(_artistQueryController.text),
            onChanged: _scheduleArtistSearch,
          ),
          const SizedBox(height: 12),
          if (_artistResults.isNotEmpty) ...[
            const SizedBox(height: 4),
            ..._artistResults.take(6).map(_buildArtistResultTile),
          ],
          if (_hasArtistSearchAttempted &&
              !_isSearchingArtists &&
              _artistResults.isEmpty)
            _buildEmptySearchState(
              'No encontramos artistas registrados con ese nombre todavía.',
            ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _manualArtistsController,
                  label: 'Agregar artista manual',
                  hint: 'Ej: Surprise Guest',
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                height: 54,
                child: OutlinedButton.icon(
                  onPressed: _addManualArtist,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Agregar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLineupDraftList() {
    final palette = _palette;
    return Column(
      children: List.generate(_lineupItems.length, (index) {
        final item = _lineupItems[index];
        final isHeadliner = item.key == _headlinerKey;
        final isFirst = index == 0;
        final isLast = index == _lineupItems.length - 1;

        return Container(
          margin: EdgeInsets.only(bottom: isLast ? 0 : 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: palette.surfaceAlt,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isHeadliner ? _authoringAccentColor : palette.border,
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: palette.surfaceMuted,
                    ),
                    child: Text(
                      '${index + 1}',
                      style: GoogleFonts.splineSans(
                        color: palette.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.displayName,
                          style: GoogleFonts.splineSans(
                            color: palette.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildLineupMetaChip(
                              item.isArtist ? 'Registrado' : 'Manual',
                              isHeadliner
                                  ? _authoringAccentColor.withValues(
                                      alpha: 0.24,
                                    )
                                  : palette.surfaceMuted,
                            ),
                            if (isHeadliner)
                              _buildLineupMetaChip(
                                'Headliner',
                                _authoringAccentColor.withValues(alpha: 0.28),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: isFirst
                        ? null
                        : () => _moveLineupItem(item.key, -1),
                    icon: const Icon(Icons.keyboard_arrow_up_rounded),
                  ),
                  IconButton(
                    onPressed: isLast
                        ? null
                        : () => _moveLineupItem(item.key, 1),
                    icon: const Icon(Icons.keyboard_arrow_down_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: isHeadliner
                          ? null
                          : () => _setHeadliner(item.key),
                      icon: const Icon(Icons.workspace_premium_outlined),
                      label: Text(
                        isHeadliner ? 'Headliner actual' : 'Marcar headliner',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton.filledTonal(
                    onPressed: () => _removeLineupItem(item.key),
                    icon: const Icon(Icons.delete_outline_rounded),
                  ),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildLineupMetaChip(String label, Color background) {
    final palette = _palette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: GoogleFonts.splineSans(
          color: palette.textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _buildChoiceChip(String value, String label, {IconData? icon}) {
    final selected = _venueSource == value;
    return _buildSegmentChip(
      label: label,
      icon: icon,
      selected: selected,
      accent: _authoringAccentColor,
      onTap: () {
        setState(() {
          _venueSource = value;
          if (value == 'registered') {
            _clearExternalVenueFields();
          } else {
            _selectedVenue = null;
            _googlePlaceResults = const [];
            if (value != 'external') {
              _venueQueryController.clear();
            }
          }
        });
      },
    );
  }

  void _clearExternalVenueFields() {
    _googlePlaceResults = const [];
    _venueQueryController.clear();
    _venueNameController.clear();
    _venueAddressController.clear();
    _venueCityController.clear();
    _venueStateController.clear();
    _venueCountryController.clear();
    _venuePostalCodeController.clear();
    _venueLatitudeController.clear();
    _venueLongitudeController.clear();
    _googlePlaceIdController.clear();
  }

  Widget _buildSelectedVenueCard() {
    final palette = _palette;
    final venue = _selectedVenue!;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _authoringAccentColor.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _authoringAccentColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: palette.textPrimary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  venue.name,
                  style: GoogleFonts.splineSans(
                    color: palette.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (venue.location != null)
                  Text(
                    venue.location!,
                    style: GoogleFonts.splineSans(color: palette.textSecondary),
                  ),
              ],
            ),
          ),
          if (_isVenueIdentityAuthoring)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _authoringAccentColor.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                'Vinculado',
                style: GoogleFonts.splineSans(
                  color: _authoringAccentColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
            )
          else
            TextButton(
              onPressed: () => setState(() => _selectedVenue = null),
              child: const Text('Cambiar'),
            ),
        ],
      ),
    );
  }

  Widget _buildVenueResultTile(DiscoveryProfileModel venue) {
    final palette = _palette;
    final selected = _selectedVenue?.id == venue.id;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: palette.surfaceAlt,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: selected ? _authoringAccentColor : palette.border,
        ),
      ),
      child: ListTile(
        onTap: () => setState(() => _selectedVenue = venue),
        title: Text(
          venue.name,
          style: GoogleFonts.splineSans(color: palette.textPrimary),
        ),
        subtitle: Text(
          venue.location ?? 'Venue registrado en Duty',
          style: GoogleFonts.splineSans(color: palette.textMuted),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (venue.isOwnedByActiveAccount)
              Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _authoringAccentColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Tu cuenta',
                  style: GoogleFonts.splineSans(
                    color: _authoringAccentColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
            selected
                ? Icon(Icons.check_circle_rounded, color: _authoringAccentColor)
                : const Icon(Icons.arrow_forward_ios_rounded, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildArtistResultTile(DiscoveryProfileModel artist) {
    final palette = _palette;
    final selected = _isArtistSelected(artist.id);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: palette.surfaceAlt,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: selected ? _authoringAccentColor : palette.border,
        ),
      ),
      child: ListTile(
        onTap: () => _addArtist(artist),
        title: Text(
          artist.name,
          style: GoogleFonts.splineSans(color: palette.textPrimary),
        ),
        subtitle: Text(
          artist.subtitle ?? 'Artista registrado',
          style: GoogleFonts.splineSans(color: palette.textMuted),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (artist.isOwnedByActiveAccount)
              Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _authoringAccentColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Tu cuenta',
                  style: GoogleFonts.splineSans(
                    color: _authoringAccentColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
            selected
                ? Icon(Icons.check_circle_rounded, color: _authoringAccentColor)
                : Icon(
                    Icons.add_circle_outline_rounded,
                    color: palette.textSecondary,
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
    required Color accent,
    IconData? icon,
  }) {
    final palette = _palette;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? accent.withValues(alpha: 0.18) : palette.surfaceAlt,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? accent.withValues(alpha: 0.82) : palette.border,
            width: selected ? 1.5 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.18),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ]
              : const [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: selected ? palette.textPrimary : palette.textSecondary,
              ),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: GoogleFonts.splineSans(
                color: selected ? palette.textPrimary : palette.textSecondary,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExistingMediaPreview({
    required String label,
    required List<String> items,
  }) {
    final palette = _palette;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: palette.surfaceAlt,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.splineSans(
              color: palette.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 84,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) => ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  items[index],
                  width: 136,
                  height: 84,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 136,
                    height: 84,
                    color: palette.surfaceMuted,
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.broken_image_outlined,
                      color: palette.textMuted,
                    ),
                  ),
                ),
              ),
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemCount: items.length,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnsupportedEditCard() {
    final palette = _palette;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: palette.warning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.warning.withValues(alpha: 0.32)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: palette.warning),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _mobileEditingReason ??
                  'Este evento todavía no puede editarse desde el flujo móvil actual.',
              style: GoogleFonts.splineSans(color: palette.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGalleryPicker() {
    final palette = _palette;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: palette.surfaceAlt,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Galería 1170x570',
                style: GoogleFonts.splineSans(
                  color: palette.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: _pickGalleryImages,
                icon: const Icon(Icons.add_photo_alternate_outlined),
                label: const Text('Agregar'),
              ),
            ],
          ),
          if (_galleryFiles.isEmpty)
            Text(
              'Aún no has agregado imágenes.',
              style: GoogleFonts.splineSans(color: palette.textMuted),
            )
          else
            SizedBox(
              height: 92,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  final file = _galleryFiles[index];
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.file(
                          file,
                          width: 148,
                          height: 92,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 6,
                        right: 6,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _galleryFiles = List<File>.from(_galleryFiles)
                                ..removeAt(index);
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: palette.shadow.withValues(alpha: 0.72),
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(4),
                            child: Icon(
                              Icons.close,
                              color: palette.textPrimary,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemCount: _galleryFiles.length,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMediaPicker({
    required String label,
    required VoidCallback onTap,
    required File? file,
    required IconData icon,
  }) {
    final palette = _palette;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 140,
        decoration: BoxDecoration(
          color: palette.surfaceAlt,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: palette.border),
        ),
        child: file == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: palette.textSecondary),
                  const SizedBox(height: 10),
                  Text(
                    label,
                    style: GoogleFonts.splineSans(color: palette.textPrimary),
                  ),
                ],
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(file, fit: BoxFit.cover),
                    Positioned(
                      bottom: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: palette.shadow.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'Cambiar',
                          style: GoogleFonts.splineSans(
                            color: palette.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildSearchBar({
    required TextEditingController controller,
    required String hint,
    required bool isLoading,
    required Future<void> Function(String) onSubmitted,
    required VoidCallback onSearchTap,
    ValueChanged<String>? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      decoration: _inputDecoration(hint).copyWith(
        prefixIcon: Icon(Icons.search_rounded, color: _palette.textMuted),
        suffixIcon: isLoading
            ? const Padding(
                padding: EdgeInsets.all(14),
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            : IconButton(
                onPressed: onSearchTap,
                icon: Icon(
                  Icons.arrow_forward_rounded,
                  color: _authoringAccentColor,
                ),
              ),
      ),
    );
  }

  Widget _buildEmptySearchState(String message) {
    final palette = _palette;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: palette.surfaceAlt,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.border),
      ),
      child: Text(
        message,
        style: GoogleFonts.splineSans(color: palette.textMuted, height: 1.4),
      ),
    );
  }

  Widget _buildTextField({
    Key? fieldKey,
    TextEditingController? controller,
    String? initialValue,
    required String label,
    String? hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    ValueChanged<String>? onChanged,
  }) {
    final palette = _palette;
    return TextFormField(
      key: fieldKey,
      controller: controller,
      initialValue: controller == null ? initialValue : null,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged,
      style: GoogleFonts.splineSans(color: palette.textPrimary),
      decoration: _inputDecoration(label).copyWith(hintText: hint),
    );
  }

  InputDecoration _inputDecoration(String label) {
    final palette = _palette;
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.splineSans(
        color: palette.textSecondary,
        fontWeight: FontWeight.w500,
      ),
      hintStyle: GoogleFonts.splineSans(color: palette.textMuted),
      filled: true,
      fillColor: palette.surfaceAlt,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: palette.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: _authoringAccentColor, width: 1.4),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: palette.danger),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: palette.danger),
      ),
    );
  }

  Widget _buildDateButton({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return _buildPickerButton(
      label: label,
      value: value,
      onTap: onTap,
      icon: Icons.calendar_today_rounded,
    );
  }

  Widget _buildTimeButton({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return _buildPickerButton(
      label: label,
      value: value,
      onTap: onTap,
      icon: Icons.schedule_rounded,
    );
  }

  Widget _buildPickerButton({
    required String label,
    required String value,
    required VoidCallback onTap,
    required IconData icon,
  }) {
    final palette = _palette;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: palette.surfaceAlt,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: palette.border),
        ),
        child: Row(
          children: [
            Icon(icon, color: palette.textSecondary, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.splineSans(
                      color: palette.textMuted,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    value,
                    style: GoogleFonts.splineSans(
                      color: palette.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Seleccionar';
    return DateFormat('dd MMM yyyy').format(date);
  }

  String _formatTime(TimeOfDay? time) {
    if (time == null) return 'Seleccionar';
    final now = DateTime.now();
    final value = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    return DateFormat('hh:mm a').format(value);
  }

  String _formatTimeForPayload(TimeOfDay time) {
    final now = DateTime.now();
    final value = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    return DateFormat('HH:mm').format(value);
  }

  Widget _buildSectionCard({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    final palette = _palette;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.splineSans(
              color: palette.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: GoogleFonts.splineSans(
              color: palette.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
