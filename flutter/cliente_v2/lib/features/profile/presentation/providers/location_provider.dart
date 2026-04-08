import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_urls.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class LocationCountry {
  final int id;
  final String name;
  final String iso2;
  final String emoji;
  final bool isDefault;

  const LocationCountry({
    required this.id,
    required this.name,
    required this.iso2,
    required this.emoji,
    this.isDefault = false,
  });

  factory LocationCountry.fromJson(Map<String, dynamic> json) {
    return LocationCountry(
      id: json['id'] as int,
      name: json['name']?.toString() ?? '',
      iso2: json['iso2']?.toString().toUpperCase() ?? '',
      emoji: json['emoji']?.toString() ?? '',
      isDefault: json['is_default'] == true,
    );
  }
}

class LocationCity {
  final int id;
  final String name;
  final int countryId;

  const LocationCity({
    required this.id,
    required this.name,
    required this.countryId,
  });

  factory LocationCity.fromJson(Map<String, dynamic> json) {
    return LocationCity(
      id: json['id'] as int,
      name: json['name']?.toString() ?? '',
      countryId: json['country_id'] as int,
    );
  }
}

class LocationSettings {
  final String defaultCountryIso2;
  final int? defaultCountryId;
  final String defaultCountryName;
  final String timezone;
  final String currencyCode;
  final String currencySymbol;
  final List<String> supportedCountryIso2s;

  const LocationSettings({
    required this.defaultCountryIso2,
    required this.defaultCountryName,
    required this.timezone,
    required this.currencyCode,
    required this.currencySymbol,
    required this.supportedCountryIso2s,
    this.defaultCountryId,
  });

  factory LocationSettings.fromJson(Map<String, dynamic>? json) {
    final supported = (json?['supported_country_iso2s'] as List? ?? const [])
        .map((value) => value.toString().toUpperCase())
        .where((value) => value.isNotEmpty)
        .toList();

    final currency = json?['currency'] is Map<String, dynamic>
        ? json!['currency'] as Map<String, dynamic>
        : json?['currency'] is Map
        ? Map<String, dynamic>.from(json!['currency'] as Map)
        : const <String, dynamic>{};

    return LocationSettings(
      defaultCountryIso2:
          json?['default_country_iso2']?.toString().toUpperCase() ?? 'DO',
      defaultCountryId: json?['default_country_id'] as int?,
      defaultCountryName:
          json?['default_country_name']?.toString() ?? 'Dominican Republic',
      timezone: json?['timezone']?.toString() ?? 'America/Santo_Domingo',
      currencyCode: currency['code']?.toString() ?? 'DOP',
      currencySymbol: currency['symbol']?.toString() ?? 'RD\$',
      supportedCountryIso2s: supported.isEmpty ? const ['DO'] : supported,
    );
  }
}

class LocationCatalog {
  final List<LocationCountry> countries;
  final LocationSettings settings;

  const LocationCatalog({required this.countries, required this.settings});
}

final locationCatalogProvider = FutureProvider<LocationCatalog>((ref) async {
  final client = ref.watch(apiClientProvider);
  final response = await client.dio.get(AppUrls.locationCountries);
  final data = response.data;
  if (data is Map && data['success'] == true) {
    final list = data['data'] as List? ?? [];
    final countries = list
        .map((e) => LocationCountry.fromJson(e as Map<String, dynamic>))
        .toList();
    final settings = LocationSettings.fromJson(
      data['meta'] is Map<String, dynamic>
          ? data['meta'] as Map<String, dynamic>
          : data['meta'] is Map
          ? Map<String, dynamic>.from(data['meta'] as Map)
          : null,
    );
    return LocationCatalog(countries: countries, settings: settings);
  }

  return const LocationCatalog(
    countries: [],
    settings: LocationSettings(
      defaultCountryIso2: 'DO',
      defaultCountryName: 'Dominican Republic',
      timezone: 'America/Santo_Domingo',
      currencyCode: 'DOP',
      currencySymbol: 'RD\$',
      supportedCountryIso2s: ['DO'],
    ),
  );
});

final countriesProvider = FutureProvider<List<LocationCountry>>((ref) async {
  final catalog = await ref.watch(locationCatalogProvider.future);
  return catalog.countries;
});

final locationSettingsProvider = FutureProvider<LocationSettings>((ref) async {
  final catalog = await ref.watch(locationCatalogProvider.future);
  return catalog.settings;
});

final citiesProvider = FutureProvider.family<List<LocationCity>, int?>((
  ref,
  countryId,
) async {
  if (countryId == null) {
    return const [];
  }

  final client = ref.watch(apiClientProvider);
  final url = AppUrls.locationCities(countryId: countryId);
  final response = await client.dio.get(url);
  final data = response.data;
  if (data is Map && data['success'] == true) {
    final list = data['data'] as List? ?? [];
    return list
        .map((e) => LocationCity.fromJson(e as Map<String, dynamic>))
        .toList();
  }
  return [];
});
