import 'package:flutter/material.dart';

import '../../../../core/constants/app_urls.dart';

enum DiscoveryKind { artists, organizers, venues }

class DiscoverySectionDefinition {
  final String key;
  final String label;

  const DiscoverySectionDefinition({required this.key, required this.label});
}

extension DiscoveryKindX on DiscoveryKind {
  String get endpoint {
    switch (this) {
      case DiscoveryKind.artists:
        return AppUrls.discoverArtists;
      case DiscoveryKind.organizers:
        return AppUrls.discoverOrganizers;
      case DiscoveryKind.venues:
        return AppUrls.discoverVenues;
    }
  }

  String get routePath {
    switch (this) {
      case DiscoveryKind.artists:
        return '/artists';
      case DiscoveryKind.organizers:
        return '/organizers';
      case DiscoveryKind.venues:
        return '/venues';
    }
  }

  String get profileRoutePrefix {
    switch (this) {
      case DiscoveryKind.artists:
        return '/artist-profile';
      case DiscoveryKind.organizers:
        return '/organizer-profile';
      case DiscoveryKind.venues:
        return '/venue-profile';
    }
  }

  String get subjectKey {
    switch (this) {
      case DiscoveryKind.artists:
        return 'artist';
      case DiscoveryKind.organizers:
        return 'organizer';
      case DiscoveryKind.venues:
        return 'venue';
    }
  }

  String get defaultSectionKey {
    switch (this) {
      case DiscoveryKind.artists:
        return 'popular';
      case DiscoveryKind.organizers:
        return 'popular';
      case DiscoveryKind.venues:
        return 'recommended';
    }
  }

  String get homePreviewKey {
    switch (this) {
      case DiscoveryKind.artists:
        return 'new';
      case DiscoveryKind.organizers:
        return 'popular';
      case DiscoveryKind.venues:
        return 'recommended';
    }
  }

  String get pageTitle {
    switch (this) {
      case DiscoveryKind.artists:
        return 'Artists & DJs';
      case DiscoveryKind.organizers:
        return 'Organizers';
      case DiscoveryKind.venues:
        return 'Venues Guide';
    }
  }

  String get pageSubtitle {
    switch (this) {
      case DiscoveryKind.artists:
        return 'New talent, crowd favorites and the next events shaping the scene.';
      case DiscoveryKind.organizers:
        return 'Teams moving the culture, with the most active calendars and strongest communities.';
      case DiscoveryKind.venues:
        return 'Spaces worth knowing before you go out, with the hottest upcoming dates.';
    }
  }

  String get searchHint {
    switch (this) {
      case DiscoveryKind.artists:
        return 'Search artist or DJ';
      case DiscoveryKind.organizers:
        return 'Search organizer';
      case DiscoveryKind.venues:
        return 'Search venue or city';
    }
  }

  String get homeSectionTitle {
    switch (this) {
      case DiscoveryKind.artists:
        return 'Fresh Artists';
      case DiscoveryKind.organizers:
        return 'Organizer Spotlight';
      case DiscoveryKind.venues:
        return 'Venue Guide';
    }
  }

  IconData get icon {
    switch (this) {
      case DiscoveryKind.artists:
        return Icons.music_note_rounded;
      case DiscoveryKind.organizers:
        return Icons.business_rounded;
      case DiscoveryKind.venues:
        return Icons.location_on_rounded;
    }
  }

  Color get accentColor {
    switch (this) {
      case DiscoveryKind.artists:
        return const Color(0xFFFF2D55);
      case DiscoveryKind.organizers:
        return const Color(0xFF007AFF);
      case DiscoveryKind.venues:
        return const Color(0xFF00C7BE);
    }
  }

  List<DiscoverySectionDefinition> get sections {
    switch (this) {
      case DiscoveryKind.artists:
        return const [
          DiscoverySectionDefinition(key: 'popular', label: 'Popular'),
          DiscoverySectionDefinition(key: 'top_rated', label: 'Top rated'),
          DiscoverySectionDefinition(key: 'new', label: 'New'),
        ];
      case DiscoveryKind.organizers:
        return const [
          DiscoverySectionDefinition(key: 'popular', label: 'Popular'),
          DiscoverySectionDefinition(key: 'top_rated', label: 'Top rated'),
          DiscoverySectionDefinition(key: 'active', label: 'Active'),
        ];
      case DiscoveryKind.venues:
        return const [
          DiscoverySectionDefinition(key: 'recommended', label: 'Recommended'),
          DiscoverySectionDefinition(key: 'top_rated', label: 'Top rated'),
          DiscoverySectionDefinition(key: 'new', label: 'New'),
        ];
    }
  }

  String profileRoute(int id) => '$profileRoutePrefix/$id';
}

class DiscoveryRequest {
  final DiscoveryKind kind;
  final String query;

  const DiscoveryRequest({required this.kind, this.query = ''});

  @override
  bool operator ==(Object other) {
    return other is DiscoveryRequest &&
        other.kind == kind &&
        other.query == query;
  }

  @override
  int get hashCode => Object.hash(kind, query);
}

class DiscoveryIdentityModel {
  final int id;
  final String type;
  final String status;
  final String slug;
  final String displayName;
  final bool isVerified;

  const DiscoveryIdentityModel({
    required this.id,
    required this.type,
    required this.status,
    required this.slug,
    required this.displayName,
    required this.isVerified,
  });

  factory DiscoveryIdentityModel.fromJson(Map<String, dynamic> json) {
    return DiscoveryIdentityModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      type: json['type']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      displayName: json['display_name']?.toString() ?? '',
      isVerified: json['is_verified'] == true,
    );
  }
}

class DiscoveryProfileModel {
  final int id;
  final String type;
  final String name;
  final String? username;
  final String? slug;
  final String? photo;
  final String? details;
  final String? city;
  final String? country;
  final String? designation;
  final int followersCount;
  final int upcomingEventsCount;
  final int totalEventsCount;
  final double averageRating;
  final int reviewCount;
  final bool hasIdentity;
  final bool isOwnedByActiveAccount;
  final DiscoveryIdentityModel? identity;

  const DiscoveryProfileModel({
    required this.id,
    required this.type,
    required this.name,
    this.username,
    this.slug,
    this.photo,
    this.details,
    this.city,
    this.country,
    this.designation,
    this.followersCount = 0,
    this.upcomingEventsCount = 0,
    this.totalEventsCount = 0,
    this.averageRating = 0,
    this.reviewCount = 0,
    this.hasIdentity = false,
    this.isOwnedByActiveAccount = false,
    this.identity,
  });

  factory DiscoveryProfileModel.fromJson(
    Map<String, dynamic> json,
    DiscoveryKind kind,
  ) {
    final rawType = json['type']?.toString();
    final photoValue = json['photo']?.toString();

    return DiscoveryProfileModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      type: rawType ?? kind.subjectKey,
      name: json['name']?.toString() ?? 'Unknown',
      username: json['username']?.toString(),
      slug: json['slug']?.toString(),
      photo: _resolvePhoto(photoValue, kind),
      details: json['details']?.toString() ?? json['description']?.toString(),
      city: json['city']?.toString(),
      country: json['country']?.toString(),
      designation: json['designation']?.toString(),
      followersCount:
          int.tryParse(json['followers_count']?.toString() ?? '0') ?? 0,
      upcomingEventsCount:
          int.tryParse(json['upcoming_events_count']?.toString() ?? '0') ?? 0,
      totalEventsCount:
          int.tryParse(json['total_events_count']?.toString() ?? '0') ?? 0,
      averageRating:
          double.tryParse(json['average_rating']?.toString() ?? '0') ?? 0,
      reviewCount: int.tryParse(json['review_count']?.toString() ?? '0') ?? 0,
      hasIdentity: json['has_identity'] == true,
      isOwnedByActiveAccount: json['is_owned_by_active_account'] == true,
      identity: json['identity'] is Map<String, dynamic>
          ? DiscoveryIdentityModel.fromJson(json['identity'])
          : (json['identity'] is Map
                ? DiscoveryIdentityModel.fromJson(
                    Map<String, dynamic>.from(json['identity']),
                  )
                : null),
    );
  }

  String? get subtitle {
    switch (type) {
      case 'artist':
        if (username != null && username!.isNotEmpty) {
          return '@$username';
        }
        return details;
      case 'organizer':
        if (designation != null && designation!.isNotEmpty) {
          return designation;
        }
        return location;
      case 'venue':
        return location;
      default:
        return details ?? location;
    }
  }

  String? get location {
    final parts = <String>[
      if (city != null && city!.isNotEmpty) city!,
      if (country != null && country!.isNotEmpty) country!,
    ];
    if (parts.isEmpty) return null;
    return parts.join(', ');
  }

  static String? _resolvePhoto(String? value, DiscoveryKind kind) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    if (value.startsWith('http')) {
      return value;
    }

    switch (kind) {
      case DiscoveryKind.artists:
        return AppUrls.getArtistImageUrl(value);
      case DiscoveryKind.organizers:
        return AppUrls.getAvatarUrl(value, isOrganizer: true);
      case DiscoveryKind.venues:
        return AppUrls.getVenueImageUrl(value);
    }
  }
}

class DiscoveryEventModel {
  final int id;
  final String title;
  final String? thumbnail;
  final DateTime? startsAt;
  final DateTime? endsAt;
  final DiscoveryProfileModel subject;

  const DiscoveryEventModel({
    required this.id,
    required this.title,
    required this.subject,
    this.thumbnail,
    this.startsAt,
    this.endsAt,
  });

  factory DiscoveryEventModel.fromJson(
    Map<String, dynamic> json,
    DiscoveryKind kind,
  ) {
    final rawSubject = json[kind.subjectKey];
    final subjectMap = rawSubject is Map<String, dynamic>
        ? rawSubject
        : rawSubject is Map
        ? Map<String, dynamic>.from(rawSubject)
        : <String, dynamic>{};

    return DiscoveryEventModel(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      title: json['title']?.toString() ?? 'Upcoming event',
      thumbnail: AppUrls.getEventThumbnailUrl(json['thumbnail']?.toString()),
      startsAt: DateTime.tryParse(json['starts_at']?.toString() ?? ''),
      endsAt: DateTime.tryParse(json['ends_at']?.toString() ?? ''),
      subject: DiscoveryProfileModel.fromJson({
        ...subjectMap,
        'type': kind.subjectKey,
      }, kind),
    );
  }
}

class DiscoveryFeedModel {
  final DiscoveryKind kind;
  final String query;
  final Map<String, List<DiscoveryProfileModel>> sections;
  final List<DiscoveryEventModel> upcomingEvents;

  const DiscoveryFeedModel({
    required this.kind,
    required this.query,
    required this.sections,
    required this.upcomingEvents,
  });

  factory DiscoveryFeedModel.fromJson(
    DiscoveryKind kind,
    Map<String, dynamic> json,
  ) {
    final sections = <String, List<DiscoveryProfileModel>>{};

    for (final section in kind.sections) {
      final rawSection = json[section.key];
      final items = rawSection is List ? rawSection : const [];
      sections[section.key] = items
          .map(
            (item) => DiscoveryProfileModel.fromJson(
              item is Map<String, dynamic>
                  ? item
                  : Map<String, dynamic>.from(item as Map),
              kind,
            ),
          )
          .toList();
    }

    final upcomingItems = json['upcoming_events'] is List
        ? json['upcoming_events'] as List
        : const [];

    return DiscoveryFeedModel(
      kind: kind,
      query: json['query']?.toString() ?? '',
      sections: sections,
      upcomingEvents: upcomingItems
          .map(
            (item) => DiscoveryEventModel.fromJson(
              item is Map<String, dynamic>
                  ? item
                  : Map<String, dynamic>.from(item as Map),
              kind,
            ),
          )
          .toList(),
    );
  }

  List<DiscoveryProfileModel> section(String key) => sections[key] ?? const [];
}
