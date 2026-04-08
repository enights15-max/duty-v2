enum ProfileType { personal, artist, venue, organizer }

class AppProfile {
  final String id;
  final String userId;
  final ProfileType type;
  final String name;
  final String? slug;
  final String status;
  final String? bio;
  final String? avatarUrl;
  final String? coverPhotoUrl;
  final Map<String, dynamic> metadata;
  final bool isPublic;

  AppProfile({
    required this.id,
    required this.userId,
    required this.type,
    required this.name,
    this.slug,
    this.status = 'pending',
    this.bio,
    this.avatarUrl,
    this.coverPhotoUrl,
    this.metadata = const {},
    this.isPublic = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'type': type.name,
      'name': name,
      'slug': slug,
      'status': status,
      'bio': bio,
      'avatar_url': avatarUrl,
      'cover_photo_url': coverPhotoUrl,
      'metadata': metadata,
      'is_public': isPublic,
    };
  }

  factory AppProfile.fromJson(Map<String, dynamic> json) {
    final metadata = Map<String, dynamic>.from(
      json['meta'] ?? json['metadata'] ?? {},
    );
    final typeName = json['type']?.toString() ?? ProfileType.personal.name;
    final rawAvatar =
        json['avatar_url']?.toString() ??
        json['photo_url']?.toString() ??
        json['photo']?.toString() ??
        json['avatar']?.toString() ??
        metadata['avatar_url']?.toString() ??
        metadata['photo_url']?.toString() ??
        metadata['avatar']?.toString() ??
        metadata['photo']?.toString() ??
        metadata['image']?.toString();
    final avatarUrl =
        AppUrls.getIdentityAvatarUrl(typeName, rawAvatar) ??
        AppUrls.getAvatarUrl(rawAvatar);
    final coverPhotoUrl = AppUrls.getIdentityCoverUrl(
      typeName,
      json['cover_photo_url']?.toString() ??
          metadata['cover_photo']?.toString(),
    );

    return AppProfile(
      id: json['id'].toString(),
      userId: (json['owner_user_id'] ?? json['user_id']).toString(),
      type: ProfileType.values.firstWhere(
        (e) => e.name == typeName,
        orElse: () => ProfileType.personal,
      ),
      name: json['display_name'] ?? json['name'] ?? '',
      slug: json['slug']?.toString(),
      status: (json['status'] ?? 'pending').toString(),
      bio: json['bio'] as String?,
      avatarUrl: avatarUrl,
      coverPhotoUrl: coverPhotoUrl,
      metadata: metadata,
      isPublic: json['is_public'] as bool? ?? true,
    );
  }

  AppProfile copyWith({
    String? name,
    String? slug,
    String? status,
    String? bio,
    String? avatarUrl,
    String? coverPhotoUrl,
    Map<String, dynamic>? metadata,
    bool? isPublic,
  }) {
    return AppProfile(
      id: id,
      userId: userId,
      type: type,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      status: status ?? this.status,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      coverPhotoUrl: coverPhotoUrl ?? this.coverPhotoUrl,
      metadata: metadata ?? this.metadata,
      isPublic: isPublic ?? this.isPublic,
    );
  }

  String? resolveAvatarUrl(Map<String, dynamic>? currentUser) {
    if (avatarUrl != null && avatarUrl!.trim().isNotEmpty) {
      return avatarUrl;
    }

    final metadataAvatar = AppUrls.getIdentityAvatarUrl(
      type.name,
      metadata['avatar_url']?.toString() ??
          metadata['photo_url']?.toString() ??
          metadata['avatar']?.toString() ??
          metadata['photo']?.toString() ??
          metadata['image']?.toString(),
    );

    if (type == ProfileType.personal) {
      return AppUrls.getCustomerAvatarUrl(currentUser) ?? metadataAvatar;
    }

    return metadataAvatar;
  }
}
