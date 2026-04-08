import '../../../../core/constants/app_urls.dart';

class OrganizerModel {
  final int id;
  final String name;
  final String? username;
  final String? email;
  final String? phone;
  final String? photo;
  final String? designation;
  final String? details;
  final String? facebook;
  final String? twitter;
  final String? linkedin;
  final String? instagram;
  final String? tiktok;
  final String? website;
  final String? country;
  final String? city;
  final String? state;
  final String? zipCode;
  final String? address;
  final int? status;
  final int followersCount;
  final int? eventsCount;
  final bool isFollowed;

  OrganizerModel({
    required this.id,
    required this.name,
    this.username,
    this.email,
    this.phone,
    this.photo,
    this.designation,
    this.details,
    this.facebook,
    this.twitter,
    this.linkedin,
    this.instagram,
    this.tiktok,
    this.website,
    this.country,
    this.city,
    this.state,
    this.zipCode,
    this.address,
    this.status,
    this.followersCount = 0,
    this.eventsCount = 0,
    this.isFollowed = false,
  });

  factory OrganizerModel.fromJson(dynamic json) {
    if (json is! Map<String, dynamic>) {
      return OrganizerModel(id: 0, name: 'Organizer');
    }
    // If it's a simple model (from event highlights)
    if (json['id'] == null &&
        (json['name'] != null || json['username'] != null)) {
      return OrganizerModel(
        id: 0,
        name: json['name'] ?? json['username'] ?? 'Organizer',
        email: json['email'],
        photo: json['photo'] != null
            ? (json['photo'].toString().startsWith('http')
                  ? json['photo'].toString()
                  : '${AppUrls.organizerImageBaseUrl}${json['photo']}')
            : null,
      );
    }

    // Full model from details API
    return OrganizerModel(
      id: json['id'] is String ? int.parse(json['id']) : (json['id'] ?? 0),
      name:
          json['organizer_name'] ??
          json['username'] ??
          json['name'] ??
          'Organizer',
      username: json['username'],
      email: json['email'],
      phone: json['phone'],
      photo: json['photo'] != null
          ? (json['photo'].toString().startsWith('http')
                ? json['photo'].toString()
                : '${AppUrls.organizerImageBaseUrl}${json['photo']}')
          : null,
      designation: json['designation'],
      details: json['details'],
      facebook: json['facebook'],
      twitter: json['twitter'],
      linkedin: json['linkedin'],
      instagram: json['instagram'],
      tiktok: json['tiktok'],
      website: json['website'],
      country: json['country'],
      city: json['city'],
      state: json['state'],
      zipCode: json['zip_code'],
      address: json['address'],
      status: json['status'] != null
          ? int.tryParse(json['status'].toString())
          : null,
      followersCount:
          int.tryParse(json['followers_count']?.toString() ?? '0') ?? 0,
      eventsCount:
          int.tryParse(
            json['events_count']?.toString() ??
                json['total_events']?.toString() ??
                '0',
          ) ??
          0,
      isFollowed:
          json['is_followed'] == true ||
          json['is_followed'] == 1 ||
          json['is_followed'].toString() == 'true',
    );
  }

  OrganizerModel copyWith({
    int? id,
    String? name,
    String? username,
    String? email,
    String? phone,
    String? photo,
    String? coverPhoto,
    String? designation,
    String? details,
    String? facebook,
    String? twitter,
    String? linkedin,
    String? instagram,
    String? tiktok,
    String? website,
    String? country,
    String? city,
    String? state,
    String? zipCode,
    String? address,
    int? status,
    int? followersCount,
    int? eventsCount,
    bool? isFollowed,
  }) {
    return OrganizerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      photo: photo ?? this.photo,
      coverPhoto: coverPhoto ?? this.coverPhoto,
      designation: designation ?? this.designation,
      details: details ?? this.details,
      facebook: facebook ?? this.facebook,
      twitter: twitter ?? this.twitter,
      linkedin: linkedin ?? this.linkedin,
      instagram: instagram ?? this.instagram,
      tiktok: tiktok ?? this.tiktok,
      website: website ?? this.website,
      country: country ?? this.country,
      city: city ?? this.city,
      state: state ?? this.state,
      zipCode: zipCode ?? this.zipCode,
      address: address ?? this.address,
      status: status ?? this.status,
      followersCount: followersCount ?? this.followersCount,
      eventsCount: eventsCount ?? this.eventsCount,
      isFollowed: isFollowed ?? this.isFollowed,
    );
  }

  String? get location {
    List<String> parts = [];
    if (city != null && city!.isNotEmpty) parts.add(city!);
    if (country != null && country!.isNotEmpty) parts.add(country!);
    return parts.isNotEmpty ? parts.join(', ') : null;
  }
}
