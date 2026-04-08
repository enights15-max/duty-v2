import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_urls.dart';
import '../../../../core/theme/colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../chat/presentation/providers/chat_provider.dart';
import '../../data/repositories/social_repository.dart';
import '../widgets/profile_tab_views.dart';

class PublicUserProfilePage extends ConsumerStatefulWidget {
  final int userId;

  const PublicUserProfilePage({super.key, required this.userId});

  @override
  ConsumerState<PublicUserProfilePage> createState() =>
      _PublicUserProfilePageState();
}

class _PublicUserProfilePageState extends ConsumerState<PublicUserProfilePage> {
  static const Color kPrimaryColor = kPrimaryColorDeep;
  static const Color kDarkBackground = kBackgroundDark;
  static const Color kCardColor = kSurfaceColor;

  Map<String, dynamic>? _profileData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    try {
      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.dio.get(
        AppUrls.userProfile(widget.userId),
        options: Options(
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode == 200) {
        final json = _asMap(response.data);
        if (json['success'] == true) {
          if (!mounted) return;
          setState(() {
            _profileData = json['data'];
            _isLoading = false;
          });
          return;
        }
      }
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load profile. Please try again.';
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'An error occurred. Check your connection.';
        _isLoading = false;
      });
    }
  }

  Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    if (data is String) {
      final decoded = jsonDecode(data);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    }
    return <String, dynamic>{};
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.dutyTheme;
    if (_isLoading) {
      return Scaffold(
        backgroundColor: kDarkBackground,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: BackButton(color: palette.textPrimary),
        ),
        body: const Center(
          child: CircularProgressIndicator(color: kPrimaryColor),
        ),
      );
    }

    if (_error != null || _profileData == null) {
      return Scaffold(
        backgroundColor: kDarkBackground,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: BackButton(color: palette.textPrimary),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: palette.textSecondary, size: 48),
              const SizedBox(height: 16),
              Text(
                _error ?? 'Profile not found',
                style: GoogleFonts.manrope(color: palette.textMuted),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _error = null;
                  });
                  _fetchProfile();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    final data = _profileData!;
    final name = data['name'] ?? 'Unknown User';
    final username = data['username'] ?? '';
    final photo = data['photo'];
    final city = data['city'];
    final country = data['country'];
    final isVerified = data['is_verified'] == true;
    final isPrivate = data['is_private'] == true;
    final canViewActivity = data['can_view_activity'] != false;
    final followsYou = data['follows_you'] == true;
    final mutualConnection = data['mutual_connection'] == true;
    final activityVisibility = Map<String, dynamic>.from(
      data['activity_visibility'] as Map? ?? const {},
    );
    final profileTabs = <({Tab tab, Widget child})>[
      if (canViewActivity && activityVisibility['upcoming'] == true)
        (
          tab: const Tab(text: 'Going'),
          child: ProfileUpcomingAttendanceTab(userId: widget.userId),
        ),
      if (canViewActivity && activityVisibility['attended'] == true)
        (
          tab: const Tab(text: 'Attended'),
          child: ProfileAttendedEventsTab(userId: widget.userId),
        ),
      if (canViewActivity && activityVisibility['interested'] == true)
        (
          tab: const Tab(text: 'Interested'),
          child: ProfileInterestedEventsTab(userId: widget.userId),
        ),
      if (canViewActivity && activityVisibility['favorites'] != false)
        (
          tab: const Tab(text: 'Favorites'),
          child: ProfileFavoritesTab(userId: widget.userId),
        ),
    ];
    final isLocked = isPrivate && !canViewActivity;

    final memberSince = data['member_since'] ?? 'Recently';
    final upcomingCount = data['stats']?['upcoming_attendance'] ?? 0;

    return DefaultTabController(
      length: profileTabs.isEmpty ? 1 : profileTabs.length,
      child: Scaffold(
        backgroundColor: kDarkBackground,
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                backgroundColor: kDarkBackground,
                elevation: 0,
                leading: BackButton(color: palette.textPrimary),
                title: Text(
                  '@$username',
                  style: GoogleFonts.manrope(
                    color: palette.textMuted,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                centerTitle: true,
                pinned: true,
              ),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    // Avatar
                    Center(
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: kPrimaryColor.withValues(alpha: 0.5),
                            width: 3,
                          ),
                          color: kCardColor,
                        ),
                        child: photo != null && photo.isNotEmpty
                            ? ClipOval(
                                child: CachedNetworkImage(
                                  imageUrl: AppUrls.getAvatarUrl(photo) ?? '',
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => const Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: kPrimaryColor,
                                    ),
                                  ),
                                  errorWidget: (_, _, _) => const Icon(
                                    Icons.person,
                                    color: Colors.white38,
                                    size: 60,
                                  ),
                                ),
                              )
                            : const Icon(
                                Icons.person,
                                color: kPrimaryColor,
                                size: 60,
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Name & Verification
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          name,
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (isVerified) ...[
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.verified,
                            color: kInfoColor,
                            size: 20,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Location & Join Date
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (city != null && city.isNotEmpty) ...[
                          const Icon(
                            Icons.location_on,
                            color: Colors.white54,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$city${country != null ? ', $country' : ''}',
                            style: GoogleFonts.manrope(
                              color: Colors.white54,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 16),
                        ],
                        const Icon(
                          Icons.calendar_today,
                          color: Colors.white54,
                          size: 13,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Joined $memberSince',
                          style: GoogleFonts.manrope(
                            color: Colors.white54,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Followers Stats
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildSimpleStat(
                          '${data['stats']?['events_attended'] ?? 0}',
                          'Events',
                        ),
                        const SizedBox(width: 24),
                        _buildSimpleStat(
                          '${data['followers_count'] ?? 0}',
                          'Followers',
                          onTap: () => context.push(
                            '/social/connections?userId=${widget.userId}&tab=followers&title=${Uri.encodeComponent('$name Connections')}',
                          ),
                        ),
                        const SizedBox(width: 24),
                        _buildSimpleStat(
                          '${data['following_count'] ?? 0}',
                          'Following',
                          onTap: () => context.push(
                            '/social/connections?userId=${widget.userId}&tab=following&title=${Uri.encodeComponent('$name Connections')}',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (upcomingCount > 0)
                          _buildSignalChip(
                            '$upcomingCount upcoming',
                            Icons.local_activity_outlined,
                          ),
                        if (followsYou)
                          _buildSignalChip(
                            'Follows you',
                            Icons.favorite_border_rounded,
                          ),
                        if (mutualConnection)
                          _buildSignalChip(
                            'Mutual connection',
                            Icons.people_alt_outlined,
                            highlighted: true,
                          ),
                        if (isPrivate)
                          _buildSignalChip(
                            'Private activity',
                            Icons.lock_outline_rounded,
                          ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Interactivity: Follow / Message Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildFollowButton(
                          isFollowing: data['is_following'] == true,
                          hasPendingRequest:
                              data['has_pending_request'] == true,
                          onFollow: () => _handleFollow(data['id']),
                          onUnfollow: () => _handleUnfollow(data['id']),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: () async {
                            final chat = await ref
                                .read(chatActionProvider.notifier)
                                .startChat(
                                  targetId: data['id'],
                                  targetType: 'user',
                                );
                            if (!context.mounted) return;
                            if (chat != null) {
                              context.push('/chat-room', extra: chat);
                              return;
                            }
                            final error = ref
                                .read(chatActionProvider.notifier)
                                .lastError;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  error ??
                                      'Failed to start chat. Are you logged in?',
                                ),
                                backgroundColor: kDangerColor,
                              ),
                            );
                          },
                          icon: const Icon(Icons.chat_bubble_outline, size: 18),
                          label: const Text('Message'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white12,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    if (isLocked)
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: kCardColor,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.lock_outline,
                                color: Colors.white38,
                                size: 48,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'This account is private',
                                style: GoogleFonts.manrope(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Follow this user to see their shared event activity.',
                                style: GoogleFonts.manrope(
                                  color: Colors.white54,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              if (!isLocked && profileTabs.isNotEmpty)
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SliverAppBarDelegate(
                    TabBar(
                      indicatorColor: kPrimaryColor,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.white54,
                      dividerColor: Colors.white12,
                      tabs: profileTabs.map((entry) => entry.tab).toList(),
                    ),
                  ),
                ),
            ];
          },
          body: isLocked
              ? const SizedBox.shrink()
              : profileTabs.isEmpty
              ? Center(
                  child: Text(
                    'This user is not sharing activity right now.',
                    style: GoogleFonts.manrope(color: Colors.white54),
                  ),
                )
              : TabBarView(
                  children: profileTabs.map((entry) => entry.child).toList(),
                ),
        ),
      ),
    );
  }

  Widget _buildSimpleStat(String value, String label, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.manrope(color: Colors.white54, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildSignalChip(
    String label,
    IconData icon, {
    bool highlighted = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: highlighted
            ? kPrimaryColor.withValues(alpha: 0.14)
            : Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: highlighted
              ? kPrimaryColor.withValues(alpha: 0.26)
              : Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: highlighted ? kPrimaryColor : Colors.white70,
            size: 14,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.manrope(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFollowButton({
    required bool isFollowing,
    required bool hasPendingRequest,
    required VoidCallback onFollow,
    required VoidCallback onUnfollow,
  }) {
    if (isFollowing) {
      return ElevatedButton(
        onPressed: onUnfollow,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white12,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
        child: const Text('Following'),
      );
    } else if (hasPendingRequest) {
      return ElevatedButton(
        onPressed: onUnfollow, // Cancel request
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white12,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
        child: const Text('Requested'),
      );
    } else {
      return ElevatedButton(
        onPressed: onFollow,
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
        child: const Text('Follow'),
      );
    }
  }

  Future<void> _handleFollow(int targetId) async {
    final success = await ref
        .read(followActionProvider.notifier)
        .follow('user', targetId);
    if (success != null && success['success'] == true) {
      // Re-fetch profile to update state
      _fetchProfile();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to follow user')));
      }
    }
  }

  Future<void> _handleUnfollow(int targetId) async {
    // Show confirmation dialog before unfollowing
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kCardColor,
        title: Text(
          'Unfollow?',
          style: GoogleFonts.plusJakartaSans(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to unfollow this user?',
          style: GoogleFonts.manrope(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.manrope(color: Colors.white54),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Unfollow',
              style: GoogleFonts.manrope(color: kDangerColor),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final success = await ref
        .read(followActionProvider.notifier)
        .unfollow('user', targetId);
    if (success) {
      _fetchProfile(); // refresh state
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to unfollow user')),
        );
      }
    }
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: kBackgroundDark, // kDarkBackground
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
