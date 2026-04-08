import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/providers/profile_state_provider.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../providers/profile_provider.dart';
import '../providers/marketplace_provider.dart';
import '../widgets/profile_tab_views.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_urls.dart';
import '../../domain/models/profile_model.dart';

class UserProfilePage extends ConsumerStatefulWidget {
  const UserProfilePage({super.key});

  @override
  ConsumerState<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends ConsumerState<UserProfilePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(profileControllerProvider)
          .refreshIdentities()
          .catchError((_) => <AppProfile>[]);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Enforcing dark mode as per the design requirements
    const backgroundColor = kBackgroundDark;
    const textColor = Colors.white;

    final profileAsync = ref.watch(profileProvider);
    final bookingsAsync = ref.watch(myBookingsProvider);
    final activeProfile = ref.watch(activeProfileProvider);

    final transferInboxCount = ref.watch(pendingTransfersCountProvider);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // Ambient Background Glows
          Positioned(
            top: -250,
            left: 0,
            right: 0,
            height: 500,
            child: Container(
              decoration: BoxDecoration(
                color: kPrimaryColor.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 120, sigmaY: 120),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            right: -100,
            width: 256,
            height: 256,
            child: Container(
              decoration: BoxDecoration(
                color: kPrimaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),

          // Main Content
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _glassIconButton(Icons.arrow_back_rounded, () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('/home');
                        }
                      }),
                      Text(
                        'PROFILE',
                        style: GoogleFonts.splineSans(
                          color: textColor.withValues(alpha: 0.5),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 2.0,
                        ),
                      ),
                      _glassIconButton(
                        Icons.settings_rounded,
                        () => context.push('/settings'),
                        badgeCount: transferInboxCount,
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: Builder(
                    builder: (context) {
                      final currentUser = ref.watch(currentUserProvider);
                      // Use API data if available, otherwise fall back to cached current user
                      final data = profileAsync.valueOrNull ?? currentUser;
                      final isLoading = profileAsync.isLoading;

                      if (data == null) {
                        if (isLoading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        return Center(
                          child: Text(
                            'Error loading profile: ${profileAsync.error}',
                          ),
                        );
                      }

                      final user =
                          data['data'] ?? data; // Handle likely "data" wrapper
                      final name = user['fname'] != null
                          ? '${user['fname']} ${user['lname'] ?? ''}'
                          : (user['name'] ?? 'Guest User');

                      // Use normalized avatar URL
                      final String? photo = currentUser?['photo']?.toString();
                      final String? avatarUrl = AppUrls.getAvatarUrl(photo);

                      final isVip =
                          user['is_vip'] == true ||
                          user['is_vip'] == 1 ||
                          user['vip_status'] == 'active';

                      // Stats - Use booking count for events attended
                      final stats = user['stats'] ?? {};
                      final eventsCount =
                          bookingsAsync.valueOrNull?.length.toString() ??
                          stats['events_count']?.toString() ??
                          '0';

                      return DefaultTabController(
                        length: 3,
                        child: NestedScrollView(
                          headerSliverBuilder: (context, innerBoxIsScrolled) {
                            return [
                              SliverToBoxAdapter(
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 32),
                                  child: Column(
                                    children: [
                                      if (isLoading &&
                                          profileAsync.valueOrNull == null)
                                        const LinearProgressIndicator(
                                          minHeight: 2,
                                          color: Color(0xFF6200EE),
                                        ),

                                      // Hero Section (Avatar, Info, Stats, Buttons)
                                      _buildHeroSection(
                                        context,
                                        user,
                                        name,
                                        avatarUrl,
                                        isVip,
                                        eventsCount,
                                        activeProfile,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SliverPersistentHeader(
                                pinned: true,
                                delegate: _SliverAppBarDelegate(
                                  TabBar(
                                    indicatorColor: kPrimaryColor,
                                    labelColor: Colors.white,
                                    unselectedLabelColor: Colors.white54,
                                    dividerColor: Colors.white12,
                                    tabs: const [
                                      Tab(text: 'Asistidos'),
                                      Tab(text: 'Intereses'),
                                      Tab(text: 'Favoritos'),
                                    ],
                                  ),
                                ),
                              ),
                            ];
                          },
                          body: TabBarView(
                            children: [
                              ProfileAttendedEventsTab(
                                userId:
                                    int.tryParse(
                                      user['id']?.toString() ?? '',
                                    ) ??
                                    0,
                              ),
                              ProfileInterestedEventsTab(
                                userId:
                                    int.tryParse(
                                      user['id']?.toString() ?? '',
                                    ) ??
                                    0,
                              ),
                              ProfileFavoritesTab(
                                userId:
                                    int.tryParse(
                                      user['id']?.toString() ?? '',
                                    ) ??
                                    0,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(
    BuildContext context,
    Map<String, dynamic> user,
    String name,
    String? avatarUrl,
    bool isVip,
    String eventsCount,
    AppProfile? activeProfile,
  ) {
    final handle =
        user['username'] ?? user['fname']?.toString().toLowerCase() ?? 'user';
    final displayHandle = '@$handle';
    final followersCount = user['followers_count']?.toString() ?? '0';
    final followingCount = user['following_count']?.toString() ?? '0';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [kPrimaryColor.withValues(alpha: 0.1), Colors.transparent],
        ),
      ),
      padding: const EdgeInsets.only(top: 32, bottom: 24),
      child: Column(
        children: [
          // Avatar
          Stack(
            alignment: Alignment.center,
            children: [
              // Glowing Backdrop
              Container(
                width: 136,
                height: 136,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [kPrimaryColor, Colors.purpleAccent, kPrimaryColor],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: kPrimaryColor.withValues(alpha: 0.75),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
              // The actual image container
              Container(
                width: 128,
                height: 128,
                decoration: BoxDecoration(
                  color: kBackgroundDark,
                  shape: BoxShape.circle,
                  border: Border.all(color: kBackgroundDark, width: 2),
                ),
                child: ClipOval(
                  child: avatarUrl != null && avatarUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: avatarUrl,
                          fit: BoxFit.cover,
                          width: 128,
                          height: 128,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[900],
                            child: const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: kPrimaryColor,
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[800],
                            child: const Icon(
                              Icons.person,
                              size: 50,
                              color: Colors.white54,
                            ),
                          ),
                        )
                      : Container(
                          color: Colors.grey[800],
                          child: const Icon(
                            Icons.person,
                            size: 50,
                            color: Colors.white54,
                          ),
                        ),
                ),
              ),
              // Verified badge
              if (isVip)
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: kPrimaryColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: kBackgroundDark, width: 2),
                    ),
                    child: const Icon(
                      Icons.verified_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          // Name
          Text(
            name,
            style: GoogleFonts.splineSans(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          // Handle • ELITE MEMBER
          Text(
            '$displayHandle ${isVip ? '• ELITE MEMBER' : ''}',
            style: GoogleFonts.splineSans(
              color: kPrimaryColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),

          // Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStatItem(
                followersCount,
                'Followers',
                onTap: () => context.push('/social/connections?tab=followers'),
              ),
              const SizedBox(width: 32),
              _buildStatItem(
                followingCount,
                'Following',
                onTap: () => context.push('/social/connections?tab=following'),
              ),
              const SizedBox(width: 32),
              _buildStatItem(eventsCount, 'Events'),
            ],
          ),

          const SizedBox(height: 24),

          if (activeProfile != null)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: kPrimaryColor.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: kPrimaryColor.withValues(alpha: 0.45),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.verified_user_rounded,
                    size: 14,
                    color: kPrimaryColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Modo activo: ${_identityTypeLabel(activeProfile.type)}',
                    style: GoogleFonts.splineSans(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          if (activeProfile != null) const SizedBox(height: 24),

          // Action Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                // Primary Button -> Edit Profile
                Expanded(
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: kPrimaryColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: kPrimaryColor.withValues(alpha: 0.2),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => context.push('/settings/edit-profile'),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.edit_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Editar perfil',
                                style: GoogleFonts.splineSans(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Glass Button -> Share
                Expanded(
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.03),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => context.push('/account-center'),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.account_tree_outlined,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Centro cuentas',
                                    style: GoogleFonts.splineSans(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Glass Icon Button -> Settings
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.03),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => context.push('/settings'),
                          child: Center(
                            child: Icon(
                              Icons.settings_rounded,
                              color: kPrimaryColor,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.splineSans(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label.toUpperCase(),
            style: GoogleFonts.splineSans(
              color: const Color(0xFF94A3B8), // text-slate-400 equivalent
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  String _identityTypeLabel(ProfileType type) {
    switch (type) {
      case ProfileType.personal:
        return 'Personal';
      case ProfileType.artist:
        return 'Artista';
      case ProfileType.venue:
        return 'Venue';
      case ProfileType.organizer:
        return 'Organizador';
    }
  }

  Widget _glassIconButton(
    IconData icon,
    VoidCallback onTap, {
    int badgeCount = 0,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 40,
        height: 40,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Icon(icon, size: 20, color: Colors.white70),
            ),
            if (badgeCount > 0)
              Positioned(
                top: -3,
                right: -3,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: kPrimaryColor,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: kBackgroundDark, width: 2),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    badgeCount > 99 ? '99+' : '$badgeCount',
                    style: GoogleFonts.splineSans(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
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
      color: const Color(0xFF0D0812), // kDarkBackground
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
