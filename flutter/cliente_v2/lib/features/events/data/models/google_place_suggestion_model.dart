class GooglePlaceSuggestionModel {
  const GooglePlaceSuggestionModel({
    required this.placeId,
    required this.title,
    required this.description,
    this.subtitle,
    this.name,
    this.address,
    this.latitude,
    this.longitude,
    this.city,
    this.state,
    this.country,
    this.countryCode,
    this.postalCode,
  });

  final String placeId;
  final String title;
  final String description;
  final String? subtitle;
  final String? name;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? city;
  final String? state;
  final String? country;
  final String? countryCode;
  final String? postalCode;

  factory GooglePlaceSuggestionModel.fromAutocompleteJson(
    Map<String, dynamic> json,
  ) {
    final formatting = _asMap(json['structured_formatting']);
    final title =
        formatting['main_text']?.toString() ??
        json['description']?.toString() ??
        'Lugar';
    final subtitle = formatting['secondary_text']?.toString();

    return GooglePlaceSuggestionModel(
      placeId: json['place_id']?.toString() ?? '',
      title: title,
      description: json['description']?.toString() ?? title,
      subtitle: subtitle,
    );
  }

  factory GooglePlaceSuggestionModel.fromPlaceDetailsJson(
    Map<String, dynamic> json,
  ) {
    final components = (json['address_components'] as List? ?? const [])
        .map((item) => item is Map<String, dynamic> ? item : _asMap(item))
        .toList();
    final geometry = _asMap(json['geometry']);
    final location = _asMap(geometry['location']);
    final address = json['formatted_address']?.toString();
    final name = json['name']?.toString();

    return GooglePlaceSuggestionModel(
      placeId: json['place_id']?.toString() ?? '',
      title: name ?? address ?? 'Lugar',
      description: address ?? name ?? 'Lugar',
      subtitle: address,
      name: name,
      address: address,
      latitude: _asDouble(location['lat']),
      longitude: _asDouble(location['lng']),
      city: _componentValue(components, const [
        'locality',
        'postal_town',
        'administrative_area_level_3',
        'administrative_area_level_2',
        'sublocality',
        'sublocality_level_1',
        'neighborhood',
      ]),
      state: _componentValue(components, const ['administrative_area_level_1']),
      country: _componentValue(components, const ['country']),
      countryCode: _componentShortValue(components, const ['country']),
      postalCode: _componentValue(components, const ['postal_code']),
    );
  }

  factory GooglePlaceSuggestionModel.fromGeocodeJson(
    Map<String, dynamic> json,
  ) {
    final components = (json['address_components'] as List? ?? const [])
        .map((item) => item is Map<String, dynamic> ? item : _asMap(item))
        .toList();
    final geometry = _asMap(json['geometry']);
    final location = _asMap(geometry['location']);
    final address = json['formatted_address']?.toString();

    return GooglePlaceSuggestionModel(
      placeId: json['place_id']?.toString() ?? '',
      title: address ?? 'Lugar',
      description: address ?? 'Lugar',
      subtitle: address,
      name: address,
      address: address,
      latitude: _asDouble(location['lat']),
      longitude: _asDouble(location['lng']),
      city: _componentValue(components, const [
        'locality',
        'postal_town',
        'administrative_area_level_3',
        'administrative_area_level_2',
        'sublocality',
        'sublocality_level_1',
        'neighborhood',
      ]),
      state: _componentValue(components, const ['administrative_area_level_1']),
      country: _componentValue(components, const ['country']),
      countryCode: _componentShortValue(components, const ['country']),
      postalCode: _componentValue(components, const ['postal_code']),
    );
  }

  factory GooglePlaceSuggestionModel.fromNominatimJson(
    Map<String, dynamic> json,
  ) {
    final address = _asMap(json['address']);
    final displayName = json['display_name']?.toString() ?? 'Lugar';
    final road = address['road']?.toString();
    final houseNumber = address['house_number']?.toString();
    final formattedAddress = [
      if (road != null && road.trim().isNotEmpty) road.trim(),
      if (houseNumber != null && houseNumber.trim().isNotEmpty) houseNumber.trim(),
    ].join(' ');

    final city = [
      address['city'],
      address['town'],
      address['village'],
      address['municipality'],
      address['county'],
      address['state_district'],
      address['state'],
    ].map((value) => value?.toString().trim() ?? '').firstWhere(
          (value) => value.isNotEmpty,
          orElse: () => '',
        );

    return GooglePlaceSuggestionModel(
      placeId: 'osm:${json['place_id']?.toString() ?? ''}',
      title: json['name']?.toString() ??
          (formattedAddress.isNotEmpty ? formattedAddress : displayName),
      description: displayName,
      subtitle: [
        if (city.isNotEmpty) city,
        if ((address['country']?.toString() ?? '').trim().isNotEmpty)
          address['country'].toString().trim(),
      ].join(' · '),
      name: json['name']?.toString(),
      address: formattedAddress.isNotEmpty ? formattedAddress : displayName,
      latitude: _asDouble(json['lat']),
      longitude: _asDouble(json['lon']),
      city: city.isNotEmpty ? city : null,
      state: address['state']?.toString(),
      country: address['country']?.toString(),
      countryCode: address['country_code']?.toString().toUpperCase(),
      postalCode: address['postcode']?.toString(),
    );
  }

  GooglePlaceSuggestionModel copyWith({
    String? placeId,
    String? title,
    String? description,
    String? subtitle,
    String? name,
    String? address,
    double? latitude,
    double? longitude,
    String? city,
    String? state,
    String? country,
    String? countryCode,
    String? postalCode,
  }) {
    return GooglePlaceSuggestionModel(
      placeId: placeId ?? this.placeId,
      title: title ?? this.title,
      description: description ?? this.description,
      subtitle: subtitle ?? this.subtitle,
      name: name ?? this.name,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      countryCode: countryCode ?? this.countryCode,
      postalCode: postalCode ?? this.postalCode,
    );
  }
}

double? _asDouble(dynamic value) {
  if (value is double) return value;
  if (value is int) return value.toDouble();
  return double.tryParse(value?.toString() ?? '');
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return const <String, dynamic>{};
}

String? _componentValue(
  List<Map<String, dynamic>> components,
  List<String> types,
) {
  for (final component in components) {
    final componentTypes = (component['types'] as List? ?? const [])
        .map((value) => value.toString())
        .toSet();
    if (types.any(componentTypes.contains)) {
      final longName = component['long_name']?.toString();
      if (longName != null && longName.trim().isNotEmpty) {
        return longName.trim();
      }
    }
  }

  return null;
}

String? _componentShortValue(
  List<Map<String, dynamic>> components,
  List<String> types,
) {
  for (final component in components) {
    final componentTypes = (component['types'] as List? ?? const [])
        .map((value) => value.toString())
        .toSet();
    if (types.any(componentTypes.contains)) {
      final shortName = component['short_name']?.toString();
      if (shortName != null && shortName.trim().isNotEmpty) {
        return shortName.trim();
      }
    }
  }

  return null;
}
