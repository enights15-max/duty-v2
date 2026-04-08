class AppUser {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? photo;
  final bool isVerified;
  final bool isSuperAdmin;
  final List<String> profileIds;
  final String? activeProfileId;

  AppUser({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.photo,
    this.isVerified = false,
    this.isSuperAdmin = false,
    this.profileIds = const [],
    this.activeProfileId,
  });

  String get fullName => '$firstName $lastName';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'photo': photo,
      'is_verified': isVerified,
      'is_super_admin': isSuperAdmin,
      'profile_ids': profileIds,
      'active_profile_id': activeProfileId,
    };
  }

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      email: json['email'] as String,
      firstName:
          json['first_name'] as String? ?? json['fname'] as String? ?? '',
      lastName: json['last_name'] as String? ?? json['lname'] as String? ?? '',
      photo: json['photo'] as String?,
      isVerified: json['is_verified'] as bool? ?? false,
      isSuperAdmin: json['is_super_admin'] as bool? ?? false,
      profileIds: List<String>.from(json['profile_ids'] ?? []),
      activeProfileId: json['active_profile_id'] as String?,
    );
  }

  AppUser copyWith({
    String? firstName,
    String? lastName,
    String? photo,
    bool? isVerified,
    bool? isSuperAdmin,
    List<String>? profileIds,
    String? activeProfileId,
  }) {
    return AppUser(
      id: id,
      email: email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      photo: photo ?? this.photo,
      isVerified: isVerified ?? this.isVerified,
      isSuperAdmin: isSuperAdmin ?? this.isSuperAdmin,
      profileIds: profileIds ?? this.profileIds,
      activeProfileId: activeProfileId ?? this.activeProfileId,
    );
  }
}
