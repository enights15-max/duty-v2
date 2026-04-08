import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_urls.dart';
import '../../../../core/providers/profile_state_provider.dart';
import '../../../../core/theme/colors.dart';
import '../../domain/models/profile_model.dart';
import '../../../events/data/models/google_place_suggestion_model.dart';
import '../../../events/presentation/providers/professional_event_provider.dart';
import '../providers/profile_provider.dart';
import '../providers/location_provider.dart';

// ─── App Colors ─────────────────────────────────────────────────────────────────
const _kBg = kBackgroundDark;
const _kSurface = kSurfaceColor;
const _kCard = Color(0xFF211922);
const _kPrimary = kPrimaryColor;
const _kBorder = Color(0xFF312936);
const _kTextMuted = kTextMuted;

// ─── Per-type accent colors ─────────────────────────────────────────────────────
const _kOrganizerAccent = kPrimaryColor;
const _kVenueAccent = kInfoColor;
const _kArtistAccent = kDustRose;
const _kProfileImageQuality = 74;
const _kCoverImageQuality = 78;
const _kGalleryImageQuality = 72;
const _kProfileImageMaxDimension = 1200;
const _kCoverImageMaxDimension = 1800;
const _kGalleryImageMaxDimension = 1400;
const _kSingleUploadHardLimitBytes = 3 * 1024 * 1024;
const _kTotalUploadHardLimitBytes = 8 * 1024 * 1024;

class IdentityRequestPage extends ConsumerStatefulWidget {
  final String initialType;
  const IdentityRequestPage({super.key, this.initialType = 'organizer'});

  @override
  ConsumerState<IdentityRequestPage> createState() =>
      _IdentityRequestPageState();
}

class _IdentityRequestPageState extends ConsumerState<IdentityRequestPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _imagePicker = ImagePicker();
  Timer? _venueSearchDebounce;
  late String _selectedType;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  // ── Shared fields
  final _displayNameCtrl = TextEditingController();
  final _handleCtrl = TextEditingController();
  final _legalNameCtrl = TextEditingController();
  final _contactNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _whatsappCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();

  // ── Location state
  LocationCountry? _selectedCountry;

  // ── Organizer-specific
  final _websiteCtrl = TextEditingController();
  final _instagramCtrl = TextEditingController();
  final _facebookCtrl = TextEditingController();
  final _tiktokCtrl = TextEditingController();
  String _companyType = 'individual';

  // ── Venue-specific
  final _venueSearchCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _capacityCtrl = TextEditingController();
  final _venueTypeCtrl = TextEditingController();
  String? _venueGooglePlaceId;
  double? _venueLatitude;
  double? _venueLongitude;
  File? _organizerLogoFile;
  File? _organizerCoverFile;
  File? _venueLogoFile;
  File? _venueCoverFile;
  bool _isSearchingVenuePlaces = false;
  bool _isResolvingVenuePin = false;
  List<GooglePlaceSuggestionModel> _venuePlaceResults = const [];

  // ── Artist-specific
  final _genresCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  final _spotifyCtrl = TextEditingController();
  final _soundcloudCtrl = TextEditingController();
  final _youtubeCtrl = TextEditingController();
  final _bookingNotesCtrl = TextEditingController();
  File? _artistPhotoFile;
  File? _artistCoverFile;
  List<_ArtistGalleryAsset> _artistGalleryAssets = const [];

  bool _isLoading = false;
  bool _didCustomizeHandle = false;
  bool _updatingHandleProgrammatically = false;

  bool get _isEditing => widget.existingProfile != null;
  bool get _isResubmission =>
      !_isEditing && (widget.prefillProfile?.isRejected ?? false);
  AppProfile? get _sourceProfile {
    final requestedId = widget.existingProfile?.id ?? widget.prefillProfile?.id;
    if (requestedId != null) {
      for (final profile in ref.read(userProfilesProvider)) {
        if (profile.id == requestedId) {
          return profile;
        }
      }
    }

    return widget.existingProfile ?? widget.prefillProfile;
  }

  Color get _accentColor {
    switch (_selectedType) {
      case 'venue':
        return _kVenueAccent;
      case 'artist':
        return _kArtistAccent;
      default:
        return _kOrganizerAccent;
    }
  }

  String? _existingMediaUrl({required bool isCover, String? fallbackType}) {
    final profile = _sourceProfile;
    if (profile == null) {
      return null;
    }

    if (isCover && profile.coverPhotoUrl != null) {
      return profile.coverPhotoUrl;
    }
    if (!isCover && profile.avatarUrl != null) {
      return profile.avatarUrl;
    }

    final type = fallbackType ?? profile.type.name;
    final meta = profile.metadata;
    final rawValue = isCover
        ? meta['cover_photo']?.toString()
        : (meta['photo']?.toString() ?? meta['image']?.toString());

    return isCover
        ? AppUrls.getIdentityCoverUrl(type, rawValue)
        : AppUrls.getIdentityAvatarUrl(type, rawValue);
  }

  @override
  void initState() {
    super.initState();
    _selectedType = _sourceProfile?.type.name ?? widget.initialType;
    _prefill();
    _displayNameCtrl.addListener(_syncSuggestedHandleFromDisplayName);
    _handleCtrl.addListener(_trackHandleCustomization);
    _venueSearchCtrl.addListener(_handleVenueSearchChanged);
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
    Future.microtask(_primeCountrySelection);
  }

  @override
  void dispose() {
    _venueSearchDebounce?.cancel();
    _displayNameCtrl.removeListener(_syncSuggestedHandleFromDisplayName);
    _handleCtrl.removeListener(_trackHandleCustomization);
    _venueSearchCtrl.removeListener(_handleVenueSearchChanged);
    _animController.dispose();
    for (final c in [
      _displayNameCtrl,
      _handleCtrl,
      _legalNameCtrl,
      _contactNameCtrl,
      _emailCtrl,
      _phoneCtrl,
      _whatsappCtrl,
      _cityCtrl,
      _websiteCtrl,
      _instagramCtrl,
      _facebookCtrl,
      _tiktokCtrl,
      _venueSearchCtrl,
      _addressCtrl,
      _capacityCtrl,
      _venueTypeCtrl,
      _genresCtrl,
      _bioCtrl,
      _spotifyCtrl,
      _soundcloudCtrl,
      _youtubeCtrl,
      _bookingNotesCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _prefill() {
    final p = _sourceProfile;
    if (p == null) {
      _syncSuggestedHandleFromDisplayName();
      return;
    }
    final m = p.metadata;
    _displayNameCtrl.text = p.name;
    _setHandleText(
      p.slug ?? m['slug']?.toString() ?? m['username']?.toString() ?? '',
    );
    _legalNameCtrl.text = m['legal_name']?.toString() ?? '';
    _contactNameCtrl.text = m['contact_name']?.toString() ?? '';
    _emailCtrl.text = m['contact_email']?.toString() ?? '';
    _phoneCtrl.text = m['contact_phone']?.toString() ?? '';
    _whatsappCtrl.text = m['whatsapp']?.toString() ?? '';
    _cityCtrl.text = m['city']?.toString() ?? '';
    _websiteCtrl.text = m['website']?.toString() ?? '';
    _instagramCtrl.text = m['instagram']?.toString() ?? '';
    _facebookCtrl.text = m['facebook']?.toString() ?? '';
    _tiktokCtrl.text = m['tiktok']?.toString() ?? '';
    _companyType = m['company_type']?.toString() == 'company'
        ? 'company'
        : 'individual';
    _addressCtrl.text = m['address_line']?.toString() ?? '';
    _capacityCtrl.text = m['capacity']?.toString() ?? '';
    _venueTypeCtrl.text = m['venue_type']?.toString() ?? '';
    _venueGooglePlaceId = m['google_place_id']?.toString();
    _venueLatitude = double.tryParse(m['latitude']?.toString() ?? '');
    _venueLongitude = double.tryParse(m['longitude']?.toString() ?? '');
    _venueSearchCtrl.text = _addressCtrl.text;
    final genres = m['genres'];
    _genresCtrl.text = genres is List
        ? genres.map((e) => e.toString()).join(', ')
        : genres?.toString() ?? '';
    _bioCtrl.text = m['bio']?.toString() ?? '';
    _spotifyCtrl.text = m['spotify']?.toString() ?? '';
    _soundcloudCtrl.text = m['soundcloud']?.toString() ?? '';
    _youtubeCtrl.text = m['youtube']?.toString() ?? '';
    _bookingNotesCtrl.text = m['booking_notes']?.toString() ?? '';
    final gallery = m['gallery'];
    if (gallery is List) {
      _artistGalleryAssets = gallery
          .map((item) => item.toString())
          .where((item) => item.trim().isNotEmpty)
          .map(_ArtistGalleryAsset.existing)
          .toList();
    }
  }

  void _setHandleText(String value) {
    _updatingHandleProgrammatically = true;
    _handleCtrl.text = value;
    _updatingHandleProgrammatically = false;
  }

  String _slugifyHandle(String value) {
    final lower = value.trim().toLowerCase();
    if (lower.isEmpty) return '';
    final withoutAt = lower.startsWith('@') ? lower.substring(1) : lower;
    return withoutAt
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'-{2,}'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
  }

  void _trackHandleCustomization() {
    if (_updatingHandleProgrammatically) {
      return;
    }

    final current = _handleCtrl.text.trim();
    final suggested = _slugifyHandle(_displayNameCtrl.text);
    _didCustomizeHandle = current.isNotEmpty && current != suggested;
  }

  void _syncSuggestedHandleFromDisplayName() {
    if (_didCustomizeHandle) {
      return;
    }

    final suggested = _slugifyHandle(_displayNameCtrl.text);
    if (_handleCtrl.text.trim() == suggested) {
      return;
    }
    _setHandleText(suggested);
  }

  void _switchType(String type) {
    if (type == _selectedType) return;
    HapticFeedback.selectionClick();
    _animController.reset();
    setState(() => _selectedType = type);
    _animController.forward();
  }

  void _handleVenueSearchChanged() {
    if (_selectedType != 'venue') {
      return;
    }

    final query = _venueSearchCtrl.text.trim();
    _venueSearchDebounce?.cancel();

    if (query.isEmpty) {
      if (mounted) {
        setState(() {
          _venuePlaceResults = const [];
          _isSearchingVenuePlaces = false;
        });
      }
      return;
    }

    if (query.length < 2) {
      return;
    }

    _venueSearchDebounce = Timer(const Duration(milliseconds: 320), () {
      if (!mounted || _venueSearchCtrl.text.trim() != query) {
        return;
      }
      _searchVenuePlaces(query);
    });
  }

  // ── Country picker ─────────────────────────────────────────────────────────────

  Future<void> _pickCountry() async {
    final countriesAsync = ref.read(countriesProvider);
    final countries = countriesAsync.valueOrNull ?? [];

    final result = await showModalBottomSheet<LocationCountry>(
      context: context,
      isScrollControlled: true,
      backgroundColor: _kSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _CountryPickerSheet(
        countries: countries,
        selected: _selectedCountry,
        accent: _accentColor,
      ),
    );
    if (result != null) setState(() => _selectedCountry = result);
  }

  Future<void> _syncCountryByName(String? countryName) async {
    final normalized = _normalizeLocationToken(countryName);
    if (normalized.isEmpty) return;

    final List<LocationCountry> countries =
        ref.read(countriesProvider).valueOrNull ??
        await ref.read(countriesProvider.future);

    for (final country in countries) {
      final countryNameNormalized = _normalizeLocationToken(country.name);
      final isoNormalized = _normalizeLocationToken(country.iso2);
      final aliasMatches = <String>{
        if (country.iso2.toUpperCase() == 'DO') 'republicadominicana',
        if (country.iso2.toUpperCase() == 'DO') 'dominicanrepublic',
      };

      if (countryNameNormalized == normalized ||
          isoNormalized == normalized ||
          aliasMatches.contains(normalized)) {
        if (mounted) {
          setState(() => _selectedCountry = country);
        }
        return;
      }
    }
  }

  Future<void> _primeCountrySelection() async {
    if (_selectedCountry != null) {
      return;
    }

    final sourceCountry = _sourceProfile?.metadata['country']?.toString();
    if ((sourceCountry ?? '').trim().isNotEmpty) {
      await _syncCountryByName(sourceCountry);
      if (_selectedCountry != null) {
        return;
      }
    }

    final settings = await _readLocationSettings();
    final countries = await _readCountries();

    LocationCountry? defaultCountry;
    for (final country in countries) {
      if (country.iso2.toUpperCase() == settings.defaultCountryIso2) {
        defaultCountry = country;
        break;
      }
    }
    defaultCountry ??= countries.isNotEmpty ? countries.first : null;

    if (defaultCountry != null && mounted) {
      setState(() => _selectedCountry = defaultCountry);
    }
  }

  Future<LocationSettings> _readLocationSettings() async {
    return ref
        .read(locationSettingsProvider)
        .maybeWhen(
          data: (settings) => settings,
          orElse: () => ref.read(locationSettingsProvider.future),
        );
  }

  Future<List<LocationCountry>> _readCountries() async {
    return ref
        .read(countriesProvider)
        .maybeWhen(
          data: (countries) => countries,
          orElse: () => ref.read(countriesProvider.future),
        );
  }

  Future<void> _searchVenuePlaces([String query = '']) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      if (!mounted) return;
      setState(() {
        _venuePlaceResults = const [];
        _isSearchingVenuePlaces = false;
      });
      return;
    }

    setState(() => _isSearchingVenuePlaces = true);
    try {
      final locationSettings = await _readLocationSettings();
      final results = await ref
          .read(professionalEventRepositoryProvider)
          .searchGooglePlaces(
            trimmed,
            primaryCountryCode: locationSettings.defaultCountryIso2,
            supportedCountryCodes: locationSettings.supportedCountryIso2s,
          );
      if (!mounted) return;
      setState(() {
        _venuePlaceResults = results;
        _isSearchingVenuePlaces = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSearchingVenuePlaces = false);
    }
  }

  Future<void> _applyVenuePlace(GooglePlaceSuggestionModel place) async {
    final derivedCity = [place.city, place.state, place.subtitle]
        .map((value) => value?.trim() ?? '')
        .firstWhere((value) => value.isNotEmpty, orElse: () => '');

    if (mounted) {
      setState(() {
        _venueSearchCtrl.text = place.description;
        _addressCtrl.text = place.address ?? place.description;
        if (derivedCity.isNotEmpty) {
          _cityCtrl.text = derivedCity;
        }
        _venueGooglePlaceId = place.placeId.isEmpty ? null : place.placeId;
        _venueLatitude = place.latitude;
        _venueLongitude = place.longitude;
        _venuePlaceResults = const [];
      });
    }
    await _syncCountryByName(place.countryCode ?? place.country);
  }

  String _normalizeLocationToken(String? value) {
    final source = (value ?? '').trim().toLowerCase();
    if (source.isEmpty) return '';

    const replacements = {
      'á': 'a',
      'é': 'e',
      'í': 'i',
      'ó': 'o',
      'ú': 'u',
      'ü': 'u',
      'ñ': 'n',
    };

    final buffer = StringBuffer();
    for (final rune in source.runes) {
      final char = String.fromCharCode(rune);
      buffer.write(replacements[char] ?? char);
    }

    return buffer.toString().replaceAll(RegExp(r'[^a-z0-9]'), '');
  }

  Future<void> _selectVenuePlace(GooglePlaceSuggestionModel suggestion) async {
    setState(() => _isSearchingVenuePlaces = true);
    try {
      final details = await ref
          .read(professionalEventRepositoryProvider)
          .getGooglePlaceDetails(suggestion.placeId);
      if (!mounted) return;
      final resolved = details ?? suggestion;
      await _applyVenuePlace(resolved);
      if (!mounted) return;
      setState(() => _isSearchingVenuePlaces = false);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSearchingVenuePlaces = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('No se pudo cargar el lugar desde Google Maps.'),
          backgroundColor: kDangerColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  Future<void> _pickVenueOnMap() async {
    final selected = await showModalBottomSheet<LatLng>(
      context: context,
      isScrollControlled: true,
      backgroundColor: _kSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) => _VenueMapPickerSheet(
        accent: _accentColor,
        initialLatLng: _venueLatitude != null && _venueLongitude != null
            ? LatLng(_venueLatitude!, _venueLongitude!)
            : const LatLng(18.4861, -69.9312),
      ),
    );

    if (selected == null) return;

    setState(() {
      _isResolvingVenuePin = true;
      _venueLatitude = selected.latitude;
      _venueLongitude = selected.longitude;
    });

    try {
      final locationSettings = await _readLocationSettings();
      final resolved = await ref
          .read(professionalEventRepositoryProvider)
          .reverseGeocode(
            latitude: selected.latitude,
            longitude: selected.longitude,
            primaryCountryCode: locationSettings.defaultCountryIso2,
            supportedCountryCodes: locationSettings.supportedCountryIso2s,
          );

      if (!mounted) return;

      if (resolved != null) {
        await _applyVenuePlace(resolved);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'No pudimos detectar ciudad y país desde ese punto. Intenta buscar el venue por texto o mover el pin.',
            ),
            backgroundColor: kWarningColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        _addressCtrl.text =
            'Ubicación seleccionada en mapa (${selected.latitude.toStringAsFixed(5)}, ${selected.longitude.toStringAsFixed(5)})';
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'No pudimos resolver la ubicación desde el mapa. Busca el venue por texto para completar ciudad y país.',
          ),
          backgroundColor: kWarningColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      _addressCtrl.text =
          'Ubicación seleccionada en mapa (${selected.latitude.toStringAsFixed(5)}, ${selected.longitude.toStringAsFixed(5)})';
    } finally {
      if (mounted) {
        setState(() => _isResolvingVenuePin = false);
      }
    }
  }

  // ── Meta builder ───────────────────────────────────────────────────────────────

  Map<String, dynamic> _buildMeta() {
    final base = _sourceProfile != null
        ? Map<String, dynamic>.from(_sourceProfile!.metadata)
        : <String, dynamic>{};

    if (_selectedType == 'organizer') {
      base.removeWhere(
        (key, _) => const {
          'legal_name',
          'contact_name',
          'contact_email',
          'contact_phone',
          'whatsapp',
          'address_line',
          'capacity',
          'venue_type',
          'google_place_id',
          'latitude',
          'longitude',
          'spotify',
          'soundcloud',
          'youtube',
          'genres',
          'bio',
          'booking_notes',
          'gallery',
          'gallery_order',
          'gallery_clear',
        }.contains(key),
      );
      base.addAll({
        'country': _selectedCountry?.name ?? '',
        'city': _cityCtrl.text.trim(),
      });
      base['company_type'] = _companyType;
      base['website'] = _websiteCtrl.text.trim();
      base['instagram'] = _instagramCtrl.text.trim();
      base['facebook'] = _facebookCtrl.text.trim();
      base['tiktok'] = _tiktokCtrl.text.trim();
      base['owner_is_primary_contact'] = true;
      base['preferred_contact_channel'] = 'chat';
    }
    if (_selectedType == 'venue') {
      base.removeWhere(
        (key, _) => const {
          'legal_name',
          'contact_name',
          'contact_email',
          'contact_phone',
          'website',
        }.contains(key),
      );
      base['country'] = _selectedCountry?.name ?? '';
      base['city'] = _cityCtrl.text.trim();
      base['address_line'] = _addressCtrl.text.trim();
      base['capacity'] = int.tryParse(_capacityCtrl.text.trim()) ?? 0;
      base['venue_type'] = _venueTypeCtrl.text.trim();
      base['whatsapp'] = _whatsappCtrl.text.trim();
      base['instagram'] = _instagramCtrl.text.trim();
      base['facebook'] = _facebookCtrl.text.trim();
      base['tiktok'] = _tiktokCtrl.text.trim();
      base['owner_is_primary_contact'] = true;
      base['preferred_contact_channel'] = 'chat';
      if (_venueGooglePlaceId != null &&
          _venueGooglePlaceId!.trim().isNotEmpty) {
        base['google_place_id'] = _venueGooglePlaceId!.trim();
      }
      if (_venueLatitude != null) {
        base['latitude'] = _venueLatitude;
      }
      if (_venueLongitude != null) {
        base['longitude'] = _venueLongitude;
      }
    }
    if (_selectedType == 'artist') {
      base.removeWhere(
        (key, _) => const {
          'legal_name',
          'contact_name',
          'contact_email',
          'contact_phone',
          'website',
          'whatsapp',
          'address_line',
          'capacity',
          'venue_type',
          'google_place_id',
          'latitude',
          'longitude',
        }.contains(key),
      );
      base['country'] = _selectedCountry?.name ?? '';
      base['city'] = _cityCtrl.text.trim();
      base['genres'] = _genresCtrl.text
          .split(',')
          .map((g) => g.trim())
          .where((g) => g.isNotEmpty)
          .toList();
      base['bio'] = _bioCtrl.text.trim();
      base['spotify'] = _spotifyCtrl.text.trim();
      base['soundcloud'] = _soundcloudCtrl.text.trim();
      base['youtube'] = _youtubeCtrl.text.trim();
      base['booking_notes'] = _bookingNotesCtrl.text.trim();
      base['instagram'] = _instagramCtrl.text.trim();
      base['facebook'] = _facebookCtrl.text.trim();
      base['tiktok'] = _tiktokCtrl.text.trim();
      base['owner_is_primary_contact'] = true;
      base['preferred_contact_channel'] = 'chat';
    }

    if (widget.existingProfile?.hasRevisionRequest == true) {
      base['revision_response'] = {
        'submitted_at': DateTime.now().toIso8601String(),
      };
    }

    // Strip null and empty-string values to prevent backend validation failures
    base.removeWhere(
      (key, value) =>
          value == null ||
          (value is String && value.isEmpty) ||
          (value is List && value.isEmpty),
    );

    if (_selectedType == 'artist') {
      base['gallery'] = _artistGalleryAssets
          .where((item) => item.existingFileName != null)
          .map((item) => item.existingFileName!)
          .toList();
      base['gallery_order'] = _buildArtistGalleryOrder();
      if (_artistGalleryAssets.isEmpty) {
        base['gallery_clear'] = 1;
      }
    }

    return base;
  }

  String? _normalizedHandleOrNull() {
    final normalized = _slugifyHandle(_handleCtrl.text);
    return normalized.isEmpty ? null : normalized;
  }

  Future<dynamic> _buildPayload({required String displayName}) async {
    final meta = _buildMeta();
    final handle = _normalizedHandleOrNull();

    final shouldUseMultipart =
        (_selectedType == 'organizer' &&
            (_organizerLogoFile != null || _organizerCoverFile != null)) ||
        (_selectedType == 'venue' &&
            (_venueLogoFile != null || _venueCoverFile != null)) ||
        (_selectedType == 'artist' &&
            (_artistPhotoFile != null ||
                _artistCoverFile != null ||
                _artistGalleryAssets.any((item) => item.localFile != null)));

    if (!shouldUseMultipart) {
      final payload = <String, dynamic>{
        'display_name': displayName,
        'meta': meta,
      };
      if (handle != null) {
        payload['slug'] = handle;
      }
      return payload;
    }

    final fields = <String, dynamic>{
      if (!_isEditing) 'type': _selectedType,
      'display_name': displayName,
    };
    if (handle != null) {
      fields['slug'] = handle;
    }

    meta.forEach((key, value) {
      if (value is List) {
        for (var i = 0; i < value.length; i++) {
          fields['meta[$key][$i]'] = value[i].toString();
        }
      } else {
        fields['meta[$key]'] = value;
      }
    });

    final formData = FormData.fromMap(fields);

    final primaryImageFile = switch (_selectedType) {
      'artist' => _artistPhotoFile,
      'organizer' => _organizerLogoFile,
      _ => _venueLogoFile,
    };
    final coverImageFile = switch (_selectedType) {
      'artist' => _artistCoverFile,
      'organizer' => _organizerCoverFile,
      _ => _venueCoverFile,
    };

    if (primaryImageFile != null) {
      formData.files.add(
        MapEntry(
          'logo',
          await MultipartFile.fromFile(
            primaryImageFile.path,
            filename: primaryImageFile.path.split('/').last,
          ),
        ),
      );
    }

    if (coverImageFile != null) {
      formData.files.add(
        MapEntry(
          'cover_photo',
          await MultipartFile.fromFile(
            coverImageFile.path,
            filename: coverImageFile.path.split('/').last,
          ),
        ),
      );
    }

    if (_selectedType == 'artist') {
      final orderedLocalGallery = _artistGalleryAssets
          .where((item) => item.localFile != null)
          .map((item) => item.localFile!)
          .toList();
      for (var i = 0; i < orderedLocalGallery.length; i++) {
        final image = orderedLocalGallery[i];
        formData.files.add(
          MapEntry(
            'gallery[$i]',
            await MultipartFile.fromFile(
              image.path,
              filename: image.path.split('/').last,
            ),
          ),
        );
      }
    }

    return formData;
  }

  String _buildCompressedPath(String originalPath, String prefix) {
    final lastSlash = originalPath.lastIndexOf('/');
    final dir = lastSlash == -1
        ? Directory.systemTemp.path
        : originalPath.substring(0, lastSlash);
    return '$dir/${prefix}_${DateTime.now().microsecondsSinceEpoch}.jpg';
  }

  Future<File> _optimizeImageFile(
    File source, {
    required String prefix,
    required int quality,
    required int maxDimension,
  }) async {
    try {
      final compressed = await FlutterImageCompress.compressAndGetFile(
        source.absolute.path,
        _buildCompressedPath(source.path, prefix),
        quality: quality,
        minWidth: maxDimension,
        minHeight: maxDimension,
        format: CompressFormat.jpeg,
        keepExif: false,
        autoCorrectionAngle: true,
      );

      return compressed != null ? File(compressed.path) : source;
    } on MissingPluginException {
      // If the native plugin is not registered yet, fall back to the image
      // picker resized file so the form still works after a hot restart.
      return source;
    } catch (_) {
      return source;
    }
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    final kb = bytes / 1024;
    if (kb < 1024) return '${kb.toStringAsFixed(kb >= 100 ? 0 : 1)} KB';
    final mb = kb / 1024;
    return '${mb.toStringAsFixed(mb >= 100 ? 0 : 1)} MB';
  }

  Future<void> _showUploadLimitSnack(String message) async {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: kWarningColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<File?> _pickOptimizedImage({
    required bool isCover,
    required String label,
  }) async {
    final picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: isCover ? _kCoverImageQuality : _kProfileImageQuality,
      maxWidth:
          (isCover ? _kCoverImageMaxDimension : _kProfileImageMaxDimension)
              .toDouble(),
      maxHeight:
          (isCover ? _kCoverImageMaxDimension : _kProfileImageMaxDimension)
              .toDouble(),
    );
    if (picked == null) return null;

    final optimized = await _optimizeImageFile(
      File(picked.path),
      prefix: isCover ? 'cover' : 'profile',
      quality: isCover ? _kCoverImageQuality : _kProfileImageQuality,
      maxDimension: isCover
          ? _kCoverImageMaxDimension
          : _kProfileImageMaxDimension,
    );

    final bytes = await optimized.length();
    if (bytes > _kSingleUploadHardLimitBytes) {
      await _showUploadLimitSnack(
        'La $label sigue muy pesada (${_formatBytes(bytes)}). Prueba una imagen más ligera o recórtala antes de subirla.',
      );
      return null;
    }

    return optimized;
  }

  Future<List<File>> _pickOptimizedGalleryImages() async {
    final picked = await _imagePicker.pickMultiImage(
      imageQuality: _kGalleryImageQuality,
      maxWidth: _kGalleryImageMaxDimension.toDouble(),
      maxHeight: _kGalleryImageMaxDimension.toDouble(),
    );
    if (picked.isEmpty) {
      return const [];
    }

    final optimized = <File>[];
    var skippedCount = 0;

    for (final image in picked) {
      final file = await _optimizeImageFile(
        File(image.path),
        prefix: 'artist_gallery',
        quality: _kGalleryImageQuality,
        maxDimension: _kGalleryImageMaxDimension,
      );
      final bytes = await file.length();
      if (bytes > _kSingleUploadHardLimitBytes) {
        skippedCount++;
        continue;
      }
      optimized.add(file);
    }

    if (skippedCount > 0) {
      await _showUploadLimitSnack(
        'Saltamos $skippedCount foto${skippedCount == 1 ? '' : 's'} de galería porque seguían demasiado pesadas después de optimizarlas.',
      );
    }

    return optimized;
  }

  Future<int> _calculatePendingUploadBytes() async {
    final files = <File>[
      ?_organizerLogoFile,
      ?_organizerCoverFile,
      ?_venueLogoFile,
      ?_venueCoverFile,
      ?_artistPhotoFile,
      ?_artistCoverFile,
      ..._artistGalleryAssets
          .where((item) => item.localFile != null)
          .map((item) => item.localFile!),
    ];

    var total = 0;
    for (final file in files) {
      if (await file.exists()) {
        total += await file.length();
      }
    }
    return total;
  }

  Future<bool> _validatePendingUploadBudget() async {
    final totalBytes = await _calculatePendingUploadBytes();
    if (totalBytes <= _kTotalUploadHardLimitBytes) {
      return true;
    }

    await _showUploadLimitSnack(
      'Las imágenes seleccionadas pesan ${_formatBytes(totalBytes)} en total. Para evitar errores al guardar, deja menos fotos o usa archivos más livianos.',
    );
    return false;
  }

  Future<void> _pickVenueMedia({required bool isCover}) async {
    final optimized = await _pickOptimizedImage(
      isCover: isCover,
      label: isCover ? 'portada' : 'foto de perfil',
    );
    if (optimized == null || !mounted) return;

    setState(() {
      if (isCover) {
        _venueCoverFile = optimized;
      } else {
        _venueLogoFile = optimized;
      }
    });
  }

  Future<void> _pickOrganizerMedia({required bool isCover}) async {
    final optimized = await _pickOptimizedImage(
      isCover: isCover,
      label: isCover ? 'portada' : 'foto de perfil',
    );
    if (optimized == null || !mounted) return;

    setState(() {
      if (isCover) {
        _organizerCoverFile = optimized;
      } else {
        _organizerLogoFile = optimized;
      }
    });
  }

  Future<void> _pickArtistMedia({required bool isCover}) async {
    final optimized = await _pickOptimizedImage(
      isCover: isCover,
      label: isCover ? 'portada' : 'foto de perfil',
    );
    if (optimized == null || !mounted) return;

    setState(() {
      if (isCover) {
        _artistCoverFile = optimized;
      } else {
        _artistPhotoFile = optimized;
      }
    });
  }

  Future<void> _pickArtistGalleryMedia() async {
    await _pickArtistGalleryMediaWithMode(replaceAll: false);
  }

  Future<void> _pickArtistGalleryMediaWithMode({
    required bool replaceAll,
  }) async {
    final optimizedFiles = await _pickOptimizedGalleryImages();
    if (optimizedFiles.isEmpty || !mounted) return;

    final newAssets = optimizedFiles.map(_ArtistGalleryAsset.local).toList();
    final desiredLength = replaceAll
        ? newAssets.length
        : _artistGalleryAssets.length + newAssets.length;

    setState(() {
      final nextAssets = replaceAll
          ? newAssets
          : [..._artistGalleryAssets, ...newAssets];
      _artistGalleryAssets = nextAssets.take(8).toList();
    });

    if (desiredLength > 8 && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'La galería admite hasta 8 fotos. Dejamos las primeras 8 para mantener el perfil claro.',
          ),
          backgroundColor: kWarningColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  List<String> _buildArtistGalleryOrder() {
    final tokens = <String>[];
    var newIndex = 0;

    for (final item in _artistGalleryAssets) {
      if (item.existingFileName != null) {
        tokens.add('existing:${item.existingFileName!}');
        continue;
      }
      if (item.localFile != null) {
        tokens.add('new:$newIndex');
        newIndex++;
      }
    }

    return tokens;
  }

  void _removeArtistGalleryAsset(int index) {
    if (index < 0 || index >= _artistGalleryAssets.length) return;
    setState(() {
      final next = [..._artistGalleryAssets]..removeAt(index);
      _artistGalleryAssets = next;
    });
  }

  void _moveArtistGalleryAsset(int index, int delta) {
    final targetIndex = index + delta;
    if (index < 0 ||
        index >= _artistGalleryAssets.length ||
        targetIndex < 0 ||
        targetIndex >= _artistGalleryAssets.length) {
      return;
    }

    setState(() {
      final next = [..._artistGalleryAssets];
      final item = next.removeAt(index);
      next.insert(targetIndex, item);
      _artistGalleryAssets = next;
    });
  }

  // ── Submit ─────────────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedType != 'venue' && _selectedCountry == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Por favor selecciona un país'),
          backgroundColor: kDangerColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }
    if (_selectedType == 'venue' &&
        (_selectedCountry == null || _cityCtrl.text.trim().isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Todavía no pudimos detectar ciudad y país. Busca el venue en Google Maps o ajusta el pin hasta que se complete la ubicación.',
          ),
          backgroundColor: kDangerColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }
    if (!await _validatePendingUploadBudget()) {
      return;
    }
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final displayName = _displayNameCtrl.text.trim();
      final handle = _normalizedHandleOrNull();
      if (handle == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Incluye un @handle válido para este perfil profesional.',
            ),
            backgroundColor: kDangerColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        return;
      }
      final payload = await _buildPayload(displayName: displayName);
      Map<String, dynamic> response;

      if (_isEditing) {
        response = await ref
            .read(profileControllerProvider)
            .updateIdentity(
              id: widget.existingProfile!.id,
              displayName: displayName,
              meta: payload,
            );
      } else {
        response = await ref
            .read(profileControllerProvider)
            .requestIdentity(
              type: _selectedType,
              displayName: displayName,
              meta: payload,
            );
      }

      final message = response['message']?.toString().trim();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              message ??
                  (_isEditing
                      ? 'Actualización enviada para revisión'
                      : _isResubmission
                      ? 'Perfil reenviado para revisión'
                      : 'Solicitud enviada para aprobación'),
            ),
            backgroundColor: _accentColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_friendlyError(e)),
            backgroundColor: kDangerColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _friendlyError(Object e) {
    if (e is DioException) {
      if (e.response?.statusCode == 413 ||
          (e.message?.contains('413') ?? false)) {
        return 'Las imágenes pesan demasiado para el servidor. Ya optimizamos la subida, pero esta selección todavía excede el límite. Prueba una foto más ligera o reduce la galería.';
      }
      final data = e.response?.data;
      if (data is Map<String, dynamic>) {
        final msg = data['message']?.toString().trim();
        if (msg != null && msg.isNotEmpty && !msg.contains('422')) return msg;

        final errors = data['errors'];
        if (errors is List && errors.isNotEmpty) {
          return errors.first.toString();
        }
        if (errors is Map && errors.isNotEmpty) {
          final first = errors.values.first;
          if (first is List && first.isNotEmpty) return first.first.toString();
          return first.toString();
        }
      }
      if (e.message != null &&
          e.message!.isNotEmpty &&
          !e.message!.contains('422')) {
        return e.message!;
      }
    }
    if (e is Exception) {
      final msg = e.toString().replaceFirst('Exception: ', '').trim();
      if (msg.contains('HTTP 413') || msg.contains('413')) {
        return 'Las imágenes pesan demasiado para el servidor. Prueba una foto más ligera o reduce la galería antes de guardar.';
      }
      if (msg.isNotEmpty && msg != 'null') return msg;
    }
    return 'No se pudo completar la solicitud';
  }

  // ────────────────────────────────────────────────────────────────────────────
  // BUILD
  // ────────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // Pre-load countries in background
    ref.watch(countriesProvider);

    final title = _isEditing
        ? 'Actualizar Perfil'
        : _isResubmission
        ? 'Reenviar Solicitud'
        : 'Perfil Profesional';

    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: _kBg,
        inputDecorationTheme: _inputTheme(),
        colorScheme: ColorScheme.dark(primary: _accentColor),
      ),
      child: Scaffold(
        backgroundColor: _kBg,
        body: CustomScrollView(
          slivers: [
            _buildAppBar(title),
            SliverToBoxAdapter(
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (widget.existingProfile?.hasRevisionRequest == true)
                        _infoCard(
                          icon: Icons.info_outline_rounded,
                          color: kWarningColor,
                          title: 'Revisión requerida',
                          body:
                              widget.existingProfile!.revisionReason ??
                              'El equipo solicitó información adicional.',
                          sub:
                              widget
                                  .existingProfile!
                                  .revisionRequiredFields
                                  .isNotEmpty
                              ? 'Campos: ${widget.existingProfile!.revisionRequiredFields.join(', ')}'
                              : null,
                        ),
                      if (_isResubmission && widget.prefillProfile != null)
                        _infoCard(
                          icon: Icons.replay_circle_filled_rounded,
                          color: kDangerColor,
                          title: 'Reenvío de solicitud',
                          body:
                              'Este perfil fue rechazado. Actualiza y reenvía para revisión.',
                          sub: widget
                              .prefillProfile!
                              .metadata['rejection_reason']
                              ?.toString()
                              .trim(),
                        ),

                      const SizedBox(height: 8),

                      if (!_isEditing && !_isResubmission) ...[
                        _sectionLabel('Tipo de cuenta profesional'),
                        const SizedBox(height: 12),
                        _typeSelector(),
                        const SizedBox(height: 28),
                      ],

                      FadeTransition(
                        opacity: _fadeAnim,
                        child: _buildFormForType(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: _buildBottomBar(),
      ),
    );
  }

  // ── App bar ─────────────────────────────────────────────────────────────────

  SliverAppBar _buildAppBar(String title) {
    final landingRoute = ref.read(activeProfileLandingRouteProvider);
    final palette = context.dutyTheme;

    return SliverAppBar(
      backgroundColor: _kBg,
      pinned: true,
      expandedHeight: 130,
      leading: GestureDetector(
        onTap: () =>
            context.canPop() ? context.pop() : context.go(landingRoute),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: palette.surface.withValues(alpha: 0.78),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.arrow_back_rounded, color: palette.textPrimary),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.splineSans(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: palette.textPrimary,
              ),
            ),
            Text(
              _typeSubtitle(),
              style: GoogleFonts.splineSans(
                fontSize: 11,
                color: _accentColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_accentColor.withValues(alpha: 0.18), _kBg],
            ),
          ),
        ),
      ),
    );
  }

  String _typeSubtitle() {
    switch (_selectedType) {
      case 'venue':
        return 'Para establecimientos y espacios de eventos';
      case 'artist':
        return 'Para artistas, músicos y performers';
      default:
        return 'Para empresas y promotoras de eventos';
    }
  }

  // ── Type selector ────────────────────────────────────────────────────────────

  Widget _typeSelector() {
    return Row(
      children: [
        _typeCard(
          'organizer',
          Icons.domain_rounded,
          'Organizador',
          _kOrganizerAccent,
        ),
        const SizedBox(width: 10),
        _typeCard('venue', Icons.location_city_rounded, 'Venue', _kVenueAccent),
        const SizedBox(width: 10),
        _typeCard(
          'artist',
          Icons.headphones_rounded,
          'Artista',
          _kArtistAccent,
        ),
      ],
    );
  }

  Widget _typeCard(String type, IconData icon, String label, Color accent) {
    final selected = _selectedType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => _switchType(type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: BoxDecoration(
            color: selected ? accent.withValues(alpha: 0.15) : _kCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? accent : _kBorder,
              width: selected ? 1.5 : 1,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.25),
                      blurRadius: 12,
                    ),
                  ]
                : [],
          ),
          child: Column(
            children: [
              Icon(icon, color: selected ? accent : _kTextMuted, size: 26),
              const SizedBox(height: 6),
              Text(
                label,
                style: GoogleFonts.splineSans(
                  fontSize: 11,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                  color: selected ? accent : _kTextMuted,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Per-type form routing ────────────────────────────────────────────────────

  Widget _buildFormForType() {
    switch (_selectedType) {
      case 'venue':
        return _buildVenueForm();
      case 'artist':
        return _buildArtistForm();
      default:
        return _buildOrganizerForm();
    }
  }

  // ── Location section (shared) ────────────────────────────────────────────────

  Widget _locationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionLabel('Ubicación'),
        // Country picker button
        GestureDetector(
          onTap: _pickCountry,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: _kCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _selectedCountry == null ? _kBorder : _accentColor,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.public_rounded, size: 18, color: _kTextMuted),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _selectedCountry != null
                        ? '${_selectedCountry!.emoji}  ${_selectedCountry!.name}'
                        : 'Seleccionar país',
                    style: GoogleFonts.splineSans(
                      color: _selectedCountry != null
                          ? context.dutyTheme.textPrimary
                          : _kTextMuted,
                      fontSize: 14,
                    ),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: _kTextMuted,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        _field(
          _cityCtrl,
          'Ciudad',
          icon: Icons.location_on_outlined,
          required: true,
        ),
      ],
    );
  }

  Widget _venueDerivedLocationSection() {
    final countryLabel = _selectedCountry != null
        ? '${_selectedCountry!.emoji}  ${_selectedCountry!.name}'
        : 'Se completará desde Google Maps';
    final cityLabel = _cityCtrl.text.trim().isNotEmpty
        ? _cityCtrl.text.trim()
        : 'La ciudad se detectará automáticamente';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionLabel('Ubicación detectada'),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: _kCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _selectedCountry == null ? _kBorder : _accentColor,
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.public_rounded, size: 18, color: _kTextMuted),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  countryLabel,
                  style: GoogleFonts.splineSans(
                    color: _selectedCountry != null
                        ? context.dutyTheme.textPrimary
                        : _kTextMuted,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: _kCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _cityCtrl.text.trim().isEmpty ? _kBorder : _accentColor,
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.location_on_outlined, size: 18, color: _kTextMuted),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  cityLabel,
                  style: GoogleFonts.splineSans(
                    color: _cityCtrl.text.trim().isNotEmpty
                        ? context.dutyTheme.textPrimary
                        : _kTextMuted,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Ciudad y país se llenan automáticamente cuando eliges una ubicación desde Google Maps.',
          style: GoogleFonts.splineSans(color: _kTextMuted, fontSize: 11),
        ),
      ],
    );
  }

  Widget _mediaPickerCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    File? file,
    String? existingImageUrl,
  }) {
    final previewImage = file != null
        ? FileImage(file) as ImageProvider
        : (existingImageUrl != null && existingImageUrl.trim().isNotEmpty
              ? NetworkImage(existingImageUrl)
              : null);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        decoration: BoxDecoration(
          color: _kCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                file != null ||
                    (existingImageUrl != null && existingImageUrl.isNotEmpty)
                ? _accentColor
                : _kBorder,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 92,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white.withValues(alpha: 0.04),
                  image: previewImage != null
                      ? DecorationImage(image: previewImage, fit: BoxFit.cover)
                      : null,
                ),
                child: previewImage == null
                    ? Icon(icon, color: _kTextMuted, size: 30)
                    : null,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: GoogleFonts.splineSans(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                file != null
                    ? 'Imagen seleccionada'
                    : (existingImageUrl != null && existingImageUrl.isNotEmpty
                          ? 'Imagen actual'
                          : subtitle),
                style: GoogleFonts.splineSans(color: _kTextMuted, fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── ORGANIZER form ───────────────────────────────────────────────────────────

  Widget _buildOrganizerForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionLabel('Nombre público'),
        _field(
          _displayNameCtrl,
          'Nombre de la promotora / empresa',
          icon: Icons.badge_outlined,
          required: true,
        ),
        const SizedBox(height: 12),
        _field(
          _handleCtrl,
          '@handle público',
          icon: Icons.alternate_email_rounded,
          required: true,
          helperText:
              'Se usará como identificador del perfil y enlace público. Ejemplo: @hidden-community',
          validator: (v) {
            final normalized = _slugifyHandle(v ?? '');
            if (normalized.isEmpty) return 'Incluye un handle válido';
            return null;
          },
        ),

        const SizedBox(height: 24),
        _sectionLabel('Branding del organizador'),
        Row(
          children: [
            Expanded(
              child: _mediaPickerCard(
                title: 'Foto de perfil',
                subtitle: 'Avatar del organizador',
                icon: Icons.account_circle_outlined,
                file: _organizerLogoFile,
                existingImageUrl: _existingMediaUrl(isCover: false),
                onTap: () => _pickOrganizerMedia(isCover: false),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _mediaPickerCard(
                title: 'Portada',
                subtitle: 'Hero del perfil',
                icon: Icons.landscape_outlined,
                file: _organizerCoverFile,
                existingImageUrl: _existingMediaUrl(isCover: true),
                onTap: () => _pickOrganizerMedia(isCover: true),
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),
        _sectionLabel('Tipo de estructura'),
        const SizedBox(height: 12),
        _segmentRow(
          value: _companyType,
          options: const {
            'individual': 'Persona física',
            'company': 'Empresa/Sociedad',
          },
          onChanged: (v) => setState(() => _companyType = v),
          accent: _kOrganizerAccent,
        ),

        const SizedBox(height: 24),
        _infoCard(
          icon: Icons.verified_user_outlined,
          color: _kOrganizerAccent,
          title: 'Responsable del perfil',
          body:
              'Este perfil de organizador quedará vinculado a tu cuenta actual. No hace falta registrar otra persona como contacto.',
          sub:
              'El canal principal de comunicación será el chat interno de Duty.',
        ),

        const SizedBox(height: 20),
        _locationSection(),

        const SizedBox(height: 24),
        _sectionLabel('Presencia digital (opcional)'),
        _field(_websiteCtrl, 'Sitio web', icon: Icons.language_rounded),
        const SizedBox(height: 12),
        _field(
          _instagramCtrl,
          'Instagram (@handle)',
          icon: Icons.camera_alt_outlined,
        ),
        const SizedBox(height: 12),
        _field(_facebookCtrl, 'Facebook', icon: Icons.facebook_rounded),
        const SizedBox(height: 12),
        _field(_tiktokCtrl, 'TikTok', icon: Icons.music_note_rounded),
      ],
    );
  }

  // ── VENUE form ───────────────────────────────────────────────────────────────

  Widget _buildVenueForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionLabel('Nombre del venue'),
        _field(
          _displayNameCtrl,
          'Nombre público del lugar',
          icon: Icons.place_outlined,
          required: true,
        ),
        const SizedBox(height: 12),
        _field(
          _handleCtrl,
          '@handle del venue',
          icon: Icons.alternate_email_rounded,
          required: true,
          helperText:
              'Este será el usuario visible del venue. Ejemplo: @santo-santo',
          validator: (v) {
            final normalized = _slugifyHandle(v ?? '');
            if (normalized.isEmpty) return 'Incluye un handle válido';
            return null;
          },
        ),

        const SizedBox(height: 24),
        _sectionLabel('Branding del venue'),
        Row(
          children: [
            Expanded(
              child: _mediaPickerCard(
                title: 'Logo',
                subtitle: 'Avatar del venue',
                icon: Icons.shield_outlined,
                file: _venueLogoFile,
                existingImageUrl: _existingMediaUrl(isCover: false),
                onTap: () => _pickVenueMedia(isCover: false),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _mediaPickerCard(
                title: 'Portada',
                subtitle: 'Hero del perfil',
                icon: Icons.landscape_outlined,
                file: _venueCoverFile,
                existingImageUrl: _existingMediaUrl(isCover: true),
                onTap: () => _pickVenueMedia(isCover: true),
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),
        _sectionLabel('Ubicación con Google Maps'),
        _field(
          _venueSearchCtrl,
          'Buscar lugar, dirección o referencia',
          icon: Icons.search_rounded,
          helperText:
              'Escribe al menos 2 caracteres para ver resultados en vivo o elige el punto directamente en el mapa.',
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isSearchingVenuePlaces
                    ? null
                    : () => _searchVenuePlaces(_venueSearchCtrl.text),
                icon: _isSearchingVenuePlaces
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.travel_explore_rounded, size: 18),
                label: const Text('Buscar en Maps'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(color: _accentColor.withValues(alpha: 0.45)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isResolvingVenuePin ? null : _pickVenueOnMap,
                icon: _isResolvingVenuePin
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.map_rounded, size: 18),
                label: const Text('Elegir en mapa'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: _kBorder),
                  backgroundColor: _kCard,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
        if (_venuePlaceResults.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: _kCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _kBorder),
            ),
            child: Column(
              children: _venuePlaceResults
                  .take(5)
                  .map(
                    (place) => ListTile(
                      onTap: () => _selectVenuePlace(place),
                      leading: Icon(
                        Icons.place_outlined,
                        color: _accentColor,
                        size: 18,
                      ),
                      title: Text(
                        place.title,
                        style: GoogleFonts.splineSans(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        [
                          if ((place.subtitle ?? '').trim().isNotEmpty)
                            place.subtitle!.trim()
                          else
                            place.description,
                          if ((place.city ?? '').trim().isNotEmpty)
                            place.city!.trim(),
                          if ((place.country ?? '').trim().isNotEmpty)
                            place.country!.trim(),
                        ].join(' · '),
                        style: GoogleFonts.splineSans(
                          color: _kTextMuted,
                          fontSize: 11,
                        ),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _accentColor.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'Usar',
                          style: GoogleFonts.splineSans(
                            color: _accentColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ] else if (_venueSearchCtrl.text.trim().length >= 2 &&
            !_isSearchingVenuePlaces) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: _kCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _kBorder),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  color: _kTextMuted,
                  size: 16,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'No encontramos resultados todavía. Prueba con un nombre más específico o usa el mapa.',
                    style: GoogleFonts.splineSans(
                      color: _kTextMuted,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 12),
        _field(
          _addressCtrl,
          'Dirección completa',
          icon: Icons.map_outlined,
          required: true,
          maxLines: 2,
        ),
        if (_venueLatitude != null && _venueLongitude != null) ...[
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: _accentColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _accentColor.withValues(alpha: 0.30)),
            ),
            child: Row(
              children: [
                Icon(Icons.my_location_rounded, color: _accentColor, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Ubicación lista: ${_venueLatitude!.toStringAsFixed(5)}, ${_venueLongitude!.toStringAsFixed(5)}',
                    style: GoogleFonts.splineSans(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 12),
        _venueDerivedLocationSection(),

        const SizedBox(height: 24),
        _sectionLabel('Datos del espacio'),
        _field(
          _venueTypeCtrl,
          'Tipo de venue (ej: Club, Teatro, Playa)',
          icon: Icons.category_outlined,
        ),
        const SizedBox(height: 12),
        _field(
          _capacityCtrl,
          'Capacidad máx. de personas',
          icon: Icons.group_outlined,
          keyboardType: TextInputType.number,
          required: true,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: (v) {
            final n = int.tryParse((v ?? '').trim());
            if (n == null || n <= 0) return 'Capacidad inválida';
            return null;
          },
        ),

        const SizedBox(height: 24),
        _infoCard(
          icon: Icons.verified_user_outlined,
          color: _accentColor,
          title: 'Responsable del venue',
          body:
              'Este venue quedará vinculado a tu cuenta actual. No hace falta registrar otra persona responsable.',
          sub:
              'Los usuarios podrán comunicarse con el venue a través del chat interno de Duty.',
        ),

        const SizedBox(height: 12),
        _sectionLabel('Contacto y redes'),
        _field(
          _whatsappCtrl,
          'Número de WhatsApp',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          required: true,
        ),
        const SizedBox(height: 12),
        _field(
          _instagramCtrl,
          'Instagram (@handle)',
          icon: Icons.camera_alt_outlined,
        ),
        const SizedBox(height: 12),
        _field(_facebookCtrl, 'Facebook', icon: Icons.facebook_rounded),
        const SizedBox(height: 12),
        _field(_tiktokCtrl, 'TikTok', icon: Icons.music_note_rounded),
      ],
    );
  }

  // ── ARTIST form ───────────────────────────────────────────────────────────────

  Widget _buildArtistForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionLabel('Nombre artístico'),
        _field(
          _displayNameCtrl,
          'Nombre público / nombre de artista',
          icon: Icons.star_outline_rounded,
          required: true,
        ),
        const SizedBox(height: 12),
        _field(
          _handleCtrl,
          '@handle del artista',
          icon: Icons.alternate_email_rounded,
          required: true,
          helperText:
              'Se usará como identificador público del artista. Ejemplo: @gianvald-live',
          validator: (v) {
            final normalized = _slugifyHandle(v ?? '');
            if (normalized.isEmpty) return 'Incluye un handle válido';
            return null;
          },
        ),

        const SizedBox(height: 24),
        _sectionLabel('Branding del artista'),
        Row(
          children: [
            Expanded(
              child: _mediaPickerCard(
                title: 'Foto de perfil',
                subtitle: 'Avatar del artista',
                icon: Icons.account_circle_outlined,
                file: _artistPhotoFile,
                existingImageUrl: _existingMediaUrl(isCover: false),
                onTap: () => _pickArtistMedia(isCover: false),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _mediaPickerCard(
                title: 'Portada',
                subtitle: 'Hero del perfil',
                icon: Icons.landscape_outlined,
                file: _artistCoverFile,
                existingImageUrl: _existingMediaUrl(isCover: true),
                onTap: () => _pickArtistMedia(isCover: true),
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),
        _sectionLabel('Press gallery'),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _pickArtistGalleryMedia,
                icon: const Icon(Icons.add_photo_alternate_outlined, size: 18),
                label: const Text('Agregar fotos'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(color: _accentColor.withValues(alpha: 0.45)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _artistGalleryAssets.isEmpty
                    ? null
                    : () => _pickArtistGalleryMediaWithMode(replaceAll: true),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Reemplazar todo'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(color: _accentColor.withValues(alpha: 0.28)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          'Usa retratos, fotos de escenario y visuales que ayuden a venues y promoters a leer el proyecto rápido. Puedes moverlas, quitar las que sobren y dejar primero la imagen más fuerte.',
          style: GoogleFonts.splineSans(color: _kTextMuted, fontSize: 12),
        ),
        if (_artistGalleryAssets.isNotEmpty) ...[
          const SizedBox(height: 14),
          _buildArtistGalleryEditor(),
        ],

        const SizedBox(height: 24),
        _sectionLabel('Género musical'),
        _field(
          _genresCtrl,
          'Géneros (ej: Techno, House, Reggaeton)',
          icon: Icons.music_note_outlined,
          required: true,
          helperText: 'Separa múltiples géneros con coma',
          validator: (v) {
            final hasOne = (v ?? '')
                .split(',')
                .map((g) => g.trim())
                .any((g) => g.isNotEmpty);
            return hasOne ? null : 'Incluye al menos un género';
          },
        ),

        const SizedBox(height: 24),
        _sectionLabel('Sobre ti'),
        _field(
          _bioCtrl,
          'Biografía corta',
          icon: Icons.article_outlined,
          maxLines: 3,
        ),

        const SizedBox(height: 24),
        _sectionLabel('Booking notes'),
        _field(
          _bookingNotesCtrl,
          'Notas para venues, promoters o prensa',
          icon: Icons.campaign_outlined,
          maxLines: 4,
          helperText:
              'Incluye enfoque musical, tipo de show, ciudades preferidas, disponibilidad o cualquier contexto útil para bookings.',
        ),

        const SizedBox(height: 24),
        _locationSection(),

        const SizedBox(height: 24),
        _infoCard(
          icon: Icons.verified_user_outlined,
          color: _accentColor,
          title: 'Responsable del perfil',
          body:
              'Este perfil de artista quedará vinculado a tu cuenta actual. No hace falta registrar otra persona como contacto.',
          sub:
              'Los usuarios podrán comunicarse contigo principalmente a través del chat interno de Duty.',
        ),

        const SizedBox(height: 24),
        _sectionLabel('Presencia digital (opcional)'),
        _field(
          _instagramCtrl,
          'Instagram (@handle)',
          icon: Icons.camera_alt_outlined,
        ),
        const SizedBox(height: 12),
        _field(_facebookCtrl, 'Facebook', icon: Icons.facebook_rounded),
        const SizedBox(height: 12),
        _field(_tiktokCtrl, 'TikTok', icon: Icons.music_note_rounded),
        const SizedBox(height: 12),
        _field(
          _spotifyCtrl,
          'Spotify (URL o perfil)',
          icon: Icons.queue_music_rounded,
        ),
        const SizedBox(height: 12),
        _field(
          _soundcloudCtrl,
          'SoundCloud (URL o perfil)',
          icon: Icons.graphic_eq_rounded,
        ),
        const SizedBox(height: 12),
        _field(
          _youtubeCtrl,
          'YouTube (canal o URL)',
          icon: Icons.ondemand_video_rounded,
        ),
      ],
    );
  }

  // ── Submit bar ────────────────────────────────────────────────────────────────

  Widget _buildBottomBar() {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).padding.bottom + 16,
        top: 16,
      ),
      decoration: BoxDecoration(
        color: _kSurface,
        border: Border(top: BorderSide(color: _kBorder)),
      ),
      child: SizedBox(
        height: 52,
        child: ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: _accentColor,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            shadowColor: _accentColor.withValues(alpha: 0.4),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(_submitIcon(), size: 18),
                    const SizedBox(width: 8),
                    Text(
                      _submitLabel(),
                      style: GoogleFonts.splineSans(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildArtistGalleryEditor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: _accentColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _accentColor.withValues(alpha: 0.25)),
          ),
          child: Row(
            children: [
              Icon(Icons.view_carousel_outlined, color: _accentColor, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'La primera foto tendrá más peso visual en el perfil y en el press surface.',
                  style: GoogleFonts.splineSans(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 198,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _artistGalleryAssets.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final item = _artistGalleryAssets[index];
              final imageProvider = item.localFile != null
                  ? FileImage(item.localFile!)
                  : NetworkImage(
                          AppUrls.getArtistImageUrl(item.existingFileName!) ??
                              '',
                        )
                        as ImageProvider;

              return Container(
                width: 156,
                decoration: BoxDecoration(
                  color: _kCard,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: index == 0
                        ? _accentColor.withValues(alpha: 0.85)
                        : _kBorder,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Stack(
                          children: [
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                image: DecorationImage(
                                  image: imageProvider,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 8,
                              left: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.58),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  '#${index + 1}',
                                  style: GoogleFonts.splineSans(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: GestureDetector(
                                onTap: () => _removeArtistGalleryAsset(index),
                                child: Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.58),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close_rounded,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        item.isLocal ? 'Nueva foto' : 'Foto actual',
                        style: GoogleFonts.splineSans(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: index == 0
                                  ? null
                                  : () => _moveArtistGalleryAsset(index, -1),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: const BorderSide(color: _kBorder),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                size: 14,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton(
                              onPressed:
                                  index == _artistGalleryAssets.length - 1
                                  ? null
                                  : () => _moveArtistGalleryAsset(index, 1),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: const BorderSide(color: _kBorder),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  IconData _submitIcon() => _isEditing
      ? Icons.save_rounded
      : _isResubmission
      ? Icons.replay_rounded
      : Icons.send_rounded;

  String _submitLabel() => _isEditing
      ? 'Guardar cambios'
      : _isResubmission
      ? 'Reenviar solicitud'
      : 'Enviar solicitud';

  // ── Reusable widgets ─────────────────────────────────────────────────────────

  Widget _sectionLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(
      text.toUpperCase(),
      style: GoogleFonts.splineSans(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.4,
        color: _kTextMuted,
      ),
    ),
  );

  Widget _field(
    TextEditingController ctrl,
    String placeholder, {
    IconData? icon,
    bool required = false,
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? helperText,
    String? Function(String?)? validator,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: GoogleFonts.splineSans(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        hintText: placeholder,
        helperText: helperText,
        prefixIcon: icon != null
            ? Icon(icon, size: 18, color: _kTextMuted)
            : null,
      ),
      validator:
          validator ??
          (required
              ? (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null
              : null),
    ),
  );

  Widget _segmentRow({
    required String value,
    required Map<String, String> options,
    required void Function(String) onChanged,
    required Color accent,
  }) => Row(
    children: options.entries.map((entry) {
      final selected = value == entry.key;
      return Expanded(
        child: GestureDetector(
          onTap: () => onChanged(entry.key),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: EdgeInsets.only(
              right: entry.key == options.keys.last ? 0 : 8,
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: selected ? accent.withValues(alpha: 0.15) : _kCard,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: selected ? accent : _kBorder),
            ),
            child: Text(
              entry.value,
              textAlign: TextAlign.center,
              style: GoogleFonts.splineSans(
                fontSize: 12,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                color: selected ? accent : _kTextMuted,
              ),
            ),
          ),
        ),
      );
    }).toList(),
  );

  Widget _infoCard({
    required IconData icon,
    required Color color,
    required String title,
    required String body,
    String? sub,
  }) => Container(
    margin: const EdgeInsets.only(bottom: 20),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: color.withValues(alpha: 0.35)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(
              title,
              style: GoogleFonts.splineSans(
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          body,
          style: GoogleFonts.splineSans(color: Colors.white70, fontSize: 13),
        ),
        if (sub != null && sub.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            sub,
            style: GoogleFonts.splineSans(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    ),
  );

  InputDecorationTheme _inputTheme() => InputDecorationTheme(
    filled: true,
    fillColor: _kCard,
    hintStyle: GoogleFonts.splineSans(color: _kTextMuted, fontSize: 14),
    helperStyle: GoogleFonts.splineSans(color: _kTextMuted, fontSize: 11),
    errorStyle: GoogleFonts.splineSans(color: kDangerColor, fontSize: 11),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: _kBorder),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: _kBorder),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: _kPrimary, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: kDangerColor),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: kDangerColor, width: 1.5),
    ),
  );
}

// ────────────────────────────────────────────────────────────────────────────────
// Venue Map Picker
// ────────────────────────────────────────────────────────────────────────────────

class _VenueMapPickerSheet extends StatefulWidget {
  final Color accent;
  final LatLng initialLatLng;

  const _VenueMapPickerSheet({
    required this.accent,
    required this.initialLatLng,
  });

  @override
  State<_VenueMapPickerSheet> createState() => _VenueMapPickerSheetState();
}

class _VenueMapPickerSheetState extends State<_VenueMapPickerSheet> {
  late LatLng _selectedLatLng;

  @override
  void initState() {
    super.initState();
    _selectedLatLng = widget.initialLatLng;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.82,
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF3D3252),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Elegir ubicación en el mapa',
                    style: GoogleFonts.splineSans(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Toca el mapa para mover el pin y usar esa dirección en tu venue.',
                    style: GoogleFonts.splineSans(
                      color: _kTextMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(18),
                ),
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: widget.initialLatLng,
                    zoom: 14,
                  ),
                  onTap: (position) =>
                      setState(() => _selectedLatLng = position),
                  markers: {
                    Marker(
                      markerId: const MarkerId('venue-location'),
                      position: _selectedLatLng,
                    ),
                  },
                  zoomControlsEnabled: false,
                  myLocationButtonEnabled: false,
                  mapToolbarEnabled: false,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).pop(_selectedLatLng),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.accent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.check_circle_outline_rounded),
                  label: const Text('Usar esta ubicación'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArtistGalleryAsset {
  final File? localFile;
  final String? existingFileName;

  const _ArtistGalleryAsset._({this.localFile, this.existingFileName});

  factory _ArtistGalleryAsset.local(File file) =>
      _ArtistGalleryAsset._(localFile: file);

  factory _ArtistGalleryAsset.existing(String fileName) =>
      _ArtistGalleryAsset._(existingFileName: fileName);

  bool get isLocal => localFile != null;
}

// ────────────────────────────────────────────────────────────────────────────────
// Country Picker Bottom Sheet
// ────────────────────────────────────────────────────────────────────────────────

class _CountryPickerSheet extends StatefulWidget {
  final List<LocationCountry> countries;
  final LocationCountry? selected;
  final Color accent;

  const _CountryPickerSheet({
    required this.countries,
    required this.selected,
    required this.accent,
  });

  @override
  State<_CountryPickerSheet> createState() => _CountryPickerSheetState();
}

class _CountryPickerSheetState extends State<_CountryPickerSheet> {
  final _searchCtrl = TextEditingController();
  late List<LocationCountry> _filtered;

  @override
  void initState() {
    super.initState();
    _filtered = widget.countries;
    _searchCtrl.addListener(() {
      final q = _searchCtrl.text.toLowerCase();
      setState(() {
        _filtered = widget.countries
            .where(
              (c) =>
                  c.name.toLowerCase().contains(q) ||
                  c.iso2.toLowerCase().contains(q),
            )
            .toList();
      });
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (_, scrollController) => Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFF3D3252),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Text(
              'Selecciona un país',
              style: GoogleFonts.splineSans(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
          // Search field
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: TextField(
              controller: _searchCtrl,
              autofocus: true,
              style: GoogleFonts.splineSans(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Buscar país...',
                hintStyle: GoogleFonts.splineSans(
                  color: const Color(0xFF7A6B9A),
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: Color(0xFF7A6B9A),
                  size: 18,
                ),
                filled: true,
                fillColor: const Color(0xFF1C1527),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF2D2240)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF2D2240)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: widget.accent, width: 1.5),
                ),
              ),
            ),
          ),
          // List
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              itemCount: _filtered.length,
              itemBuilder: (_, i) {
                final c = _filtered[i];
                final isSelected = widget.selected?.id == c.id;
                return ListTile(
                  leading: Text(c.emoji, style: const TextStyle(fontSize: 22)),
                  title: Text(
                    c.name,
                    style: GoogleFonts.splineSans(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w400,
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(
                          Icons.check_circle_rounded,
                          color: widget.accent,
                          size: 20,
                        )
                      : null,
                  tileColor: isSelected
                      ? widget.accent.withValues(alpha: 0.08)
                      : null,
                  onTap: () => Navigator.of(context).pop(c),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
