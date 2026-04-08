import 'package:duty_client/core/constants/app_constants.dart';

class VenueModel {
  final int id;
  final String name;
  final String slug;
  final String? address;
  final String? city;
  final String? state;
  final String? country;
  final String? zipCode;
  final double? latitude;
  final double? longitude;
  final String? description;
  final String? image;
  final String? coverPhoto;
  final String? instagram;
  final String? facebook;
  final String? tiktok;
  final String? whatsapp;
  final int status;

  VenueModel({
    required this.id,
    required this.name,
    required this.slug,
    this.address,
    this.city,
    this.state,
    this.country,
    this.zipCode,
    this.latitude,
    this.longitude,
    this.description,
    this.image,
    this.coverPhoto,
    this.instagram,
    this.facebook,
    this.tiktok,
    this.whatsapp,
    required this.status,
  });

  factory VenueModel.fromJson(Map<String, dynamic> json) {
    return VenueModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      address: json['address'],
      city: json['city'],
      state: json['state'],
      country: json['country'],
      zipCode: json['zip_code'],
      latitude: double.tryParse(json['latitude']?.toString() ?? ''),
      longitude: double.tryParse(json['longitude']?.toString() ?? ''),
      description: json['description'],
      image:
          (json['image'] != null &&
              !json['image'].toString().startsWith('http'))
          ? '${AppConstants.venueImageBaseUrl}${json['image']}'
          : json['image'],
      coverPhoto:
          (json['cover_photo'] != null &&
              !json['cover_photo'].toString().startsWith('http'))
          ? '${AppConstants.venueImageBaseUrl}${json['cover_photo']}'
          : json['cover_photo'],
      instagram: _socialValue(json, 'instagram'),
      facebook: _socialValue(json, 'facebook'),
      tiktok: _socialValue(json, 'tiktok'),
      whatsapp: _socialValue(json, 'whatsapp'),
      status: int.tryParse(json['status'].toString()) ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'address': address,
      'city': city,
      'state': state,
      'country': country,
      'zip_code': zipCode,
      'latitude': latitude,
      'longitude': longitude,
      'description': description,
      'image': image,
      'cover_photo': coverPhoto,
      'instagram': instagram,
      'facebook': facebook,
      'tiktok': tiktok,
      'whatsapp': whatsapp,
      'status': status,
    };
  }

  @override
  String toString() {
    return 'VenueModel(id: $id, name: $name, slug: $slug, address: $address, city: $city)';
  }
}

String? _socialValue(Map<String, dynamic> json, String key) {
  final socials = json['socials'];
  if (socials is Map && socials[key] != null) {
    return socials[key]?.toString();
  }
  return json[key]?.toString();
}
