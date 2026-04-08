import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/colors.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../providers/profile_provider.dart';
import '../providers/marketplace_provider.dart';
import '../widgets/profile_tab_views.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_urls.dart';
import '../../domain/models/profile_model.dart';
import '../../data/repositories/social_repository.dart';

class UserProfilePage extends ConsumerStatefulWidget {
  const UserProfilePage({super.key});

  @override
  ConsumerState<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends ConsumerState<UserProfilePage> {
  @override
  Widget build(BuildContext context) {
    print('DEBUG: UserProfilePage build called');
    // Enforcing dark mode as per the design requirements
    const backgroundColor = kBackgroundDark;
    const textColor = Colors.white;

    final profileAsync = ref.watch(profileProvider);
    final bookingsAsync = ref.watch(myBookingsProvider);
    final activeProfile = ref.watch(activeProfileProvider);
    final landingRoute = ref.watch(activeProfileLandingRouteProvider);

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
                      _GlassIconButton(Icons.arrow_back_rounded, () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go(landingRoute);
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
                      _GlassIconButton(
                        Icons.settings_rounded,
                        () => context.push('/settings'),
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

                      // Extract Data safely with fallbacks
                      final user =
                          data['data'] ?? data; // Handle likely "data" wrapper
                      final name = user['fname'] != null
                          ? '${user['fname']} ${user['lname'] ?? ''}'
                          : (user['name'] ?? 'Guest User');

                      final String? personalPhoto =
                          currentUser?['photo_url']?.toString() ??
                          currentUser?['photo']?.toString();
                      final String? avatarUrl =
                          activeProfile?.isProfessional == true
                          ? activeProfile?.avatarUrl
                          : AppUrls.getAvatarUrl(personalPhoto);

                      // Handle full URL vs relative path for avatar
                      String avatarUrl = avatar;
                      if (!avatarUrl.startsWith('http')) {
                        avatarUrl =
                            '${AppConstants.profileImageBaseUrl}$avatarUrl';
                      }

                      final memberSince = user['created_at'] != null
                          ? _formatDate(user['created_at'])
                          : 'Member since 2024';
                      final dateOfBirth = user['date_of_birth'] != null
                          ? _formatDateOnly(user['date_of_birth'].toString())
                          : 'Not Provided';
                      final balance =
                          num.tryParse(user['balance']?.toString() ?? '0') ?? 0;
                      // Determine VIP status - check various possible flags
                      final isVip =
                          user['is_vip'] == true ||
                          user['is_vip'] == 1 ||
                          user['vip_status'] == 'active';

                      // Stats - if using cached user, stats might be null, default to 0
                      final stats = user['stats'] ?? {};
                      final eventsCount =
                          stats['events_count']?.toString() ?? '0';
                      final artistsCount =
                          stats['artists_count']?.toString() ?? '0';
                      final communitiesCount =
                          stats['communities_count']?.toString() ?? '0';

                      // activeProfile.userId holds the numeric customer id (e.g. "43")
                      // currentUser['id'] can be either the numeric id OR the identity UUID
                      // depending on which value got stored. Prefer activeProfile.userId.
                      final int userId =
                          int.tryParse(activeProfile?.userId ?? '') ??
                          int.tryParse(currentUser?['id']?.toString() ?? '') ??
                          int.tryParse(
                            currentUser?['user_id']?.toString() ?? '',
                          ) ??
                          0;

                      final liveProfileAsync = userId != 0
                          ? ref.watch(userProfileProvider(userId))
                          : const AsyncValue<Map<String, dynamic>>.data({});

                      return DefaultTabController(
                        length: 2,
                        child: RefreshIndicator(
                          onRefresh: () async {
                            await Future.wait([
                              ref
                                  .read(profileControllerProvider)
                                  .refreshIdentities(),
                              ref.refresh(profileProvider.future),
                              ref.refresh(myBookingsProvider.future),
                              if (userId != 0) ...[
                                ref.refresh(userProfileProvider(userId).future),
                                ref.refresh(
                                  userAttendedEventsProvider(userId).future,
                                ),
                                ref.refresh(
                                  userInterestedEventsProvider(userId).future,
                                ),
                              ],
                            ]);
                          },
                          color: kPrimaryColor,
                          backgroundColor: kSurfaceColor,
                          child: NestedScrollView(
                            headerSliverBuilder: (context, innerBoxIsScrolled) {
                              return [
                                SliverToBoxAdapter(
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 0),
                                    child: Column(
                                      children: [
                                        if (isLoading &&
                                            profileAsync.valueOrNull == null)
                                          const LinearProgressIndicator(
                                            minHeight: 2,
                                            color: kPrimaryColor,
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
                                          currentUser: currentUser,
                                          liveProfile:
                                              liveProfileAsync.valueOrNull,
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
                                      ],
                                    ),
                                  ),
                                ),
                              ];
                            },
                            body: userId == 0
                                ? const Center(
                                    child: Text(
                                      'Unable to identify user profile.',
                                      style: TextStyle(color: Colors.white54),
                                    ),
                                  )
                                : TabBarView(
                                    children: [
                                      ProfileAttendedEventsTab(userId: userId),
                                      ProfileInterestedEventsTab(
                                        userId: userId,
                                      ),
                                    ],
                                  ),
                          ),

                          // Balance Section
                          const SizedBox(height: 32),
                          _buildBalanceSection(
                            context,
                            textColor,
                            walletAsync,
                            balance,
                          ),

                          // Stats Row
                          const SizedBox(height: 32),
                          _buildStatsRow(
                            eventsCount,
                            artistsCount,
                            communitiesCount,
                          ),

                          // My Tickets Button
                          const SizedBox(height: 24),
                          _buildVipMembershipCard(
                            context,
                            user['is_vip'] ?? false,
                          ),
                          const SizedBox(height: 16),
                          _buildSecondaryMarketCard(context),
                          const SizedBox(height: 16),
                          _buildMyTicketsButton(context),

                          // Collectibles Gallery
                          const SizedBox(height: 40),
                          _buildCollectiblesSection(
                            textColor,
                            (user['collectibles'] is List)
                                ? user['collectibles']
                                : [],
                          ),

                          // Recent Activity
                          const SizedBox(height: 32),
                          _buildHistorySection(
                            textColor,
                            (user['history'] is List) ? user['history'] : [],
                          ),
                        ],
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
    AppProfile? activeProfile, {
    Map<String, dynamic>? currentUser,
    Map<String, dynamic>? liveProfile,
  }) {
    final displayHandle = _resolveDisplayHandle(
      user: user,
      currentUser: currentUser,
      activeProfile: activeProfile,
    );

    // Use live stats if available, otherwise fallback to cached user data
    final followersCount =
        (liveProfile?['followers_count'] ?? user['followers_count'] ?? '0')
            .toString();
    final followingCount =
        (liveProfile?['following_count'] ?? user['following_count'] ?? '0')
            .toString();

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
                    colors: [kPrimaryColor, kPrimaryColorDeep, kPrimaryColor],
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
          if (displayHandle != null || isVip)
            Text(
              [
                ...?displayHandle != null ? [displayHandle] : null,
                if (isVip) 'ELITE MEMBER',
              ].join(' • '),
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
                        onTap: () {
                          if (activeProfile != null &&
                              activeProfile.isProfessional) {
                            context.push(
                              '/identity-request',
                              extra: {'profile': activeProfile},
                            );
                            return;
                          }
                          context.push('/settings/edit-profile');
                        },
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                activeProfile != null &&
                                        activeProfile.isProfessional
                                    ? Icons.manage_accounts_rounded
                                    : Icons.edit_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                activeProfile != null &&
                                        activeProfile.isProfessional
                                    ? 'Editar perfil pro'
                                    : 'Editar perfil',
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
            // VIP Badge
            if (isVip)
              Positioned(
                bottom: -12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: kPrimaryColor.withValues(alpha: 0.5),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: kPrimaryColor.withValues(alpha: 0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.verified_rounded,
                        color: Colors.amber,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'VIP MEMBER',
                        style: GoogleFonts.splineSans(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          name,
          style: GoogleFonts.splineSans(
            color: textColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          memberSince,
          style: GoogleFonts.splineSans(
            color: textColor.withValues(alpha: 0.4),
            fontSize: 14,
            fontWeight: FontWeight.w300,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'DOB: $dateOfBirth',
          style: GoogleFonts.splineSans(
            color: textColor.withValues(alpha: 0.4),
            fontSize: 14,
            fontWeight: FontWeight.w300,
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceSection(
    BuildContext context,
    Color textColor,
    AsyncValue<Map<String, dynamic>> walletAsync,
    dynamic fallbackBalance,
  ) {
    // Format balance
    final balance =
        num.tryParse(
          (walletAsync.valueOrNull?['balance'] ?? fallbackBalance).toString(),
        ) ??
        0;
    final formattedBalance = NumberFormat("#,##0.00", "en_US").format(balance);

    return InkWell(
      onTap: () => context.push('/wallet'),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(
              'TOTAL BALANCE',
              style: GoogleFonts.splineSans(
                color: textColor.withValues(alpha: 0.4),
                fontSize: 12,
                fontWeight: FontWeight.w500,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Colors.white, Colors.white70],
                  ).createShader(bounds),
                  child: Text(
                    formattedBalance,
                    style: GoogleFonts.splineSans(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  'DUTY',
                  style: GoogleFonts.splineSans(
                    color: kPrimaryColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String? _resolveDisplayHandle({
    required Map<String, dynamic> user,
    required Map<String, dynamic>? currentUser,
    required AppProfile? activeProfile,
  }) {
    String? normalize(dynamic raw) {
      final value = raw?.toString().trim();
      if (value == null || value.isEmpty) {
        return null;
      }
      final normalized = value.startsWith('@') ? value.substring(1) : value;
      return normalized.trim().isEmpty ? null : '@$normalized';
    }

    String? slugifyName(String? value) {
      final source = (value ?? '').trim().toLowerCase();
      if (source.isEmpty) {
        return null;
      }

      final slug = source
          .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
          .replaceAll(RegExp(r'-{2,}'), '-')
          .replaceAll(RegExp(r'^-|-$'), '');

      if (slug.isEmpty) {
        return null;
      }

      return '@$slug';
    }

    if (activeProfile?.isProfessional == true) {
      final professionalCandidates = <dynamic>[
        activeProfile?.slug,
        user['slug'],
        activeProfile?.metadata['username'],
        activeProfile?.metadata['slug'],
        activeProfile?.metadata['handle'],
      ];

      for (final candidate in professionalCandidates) {
        final resolved = normalize(candidate);
        if (resolved != null) {
          return resolved;
        }
      }

      return slugifyName(activeProfile?.name ?? user['name']?.toString());
    }

    final candidates = <dynamic>[
      user['username'],
      currentUser?['username'],
      user['slug'],
    ];

    for (final candidate in candidates) {
      final resolved = normalize(candidate);
      if (resolved != null) {
        return resolved;
      }
    }

    return null;
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
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            style: GoogleFonts.splineSans(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 10,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollectiblesSection(
    Color textColor,
    List<dynamic> collectibles,
  ) {
    // If empty, show some mocks or empty state. For now, showing mocks if empty to populate UI
    if (collectibles.isEmpty) {
      return _buildMockCollectibles(textColor);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'COLLECTIBLES',
                style: GoogleFonts.splineSans(
                  color: textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              Text(
                'View All',
                style: GoogleFonts.splineSans(
                  color: kPrimaryColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 224,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: collectibles.length,
            itemBuilder: (context, index) {
              final item = collectibles[index];
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: _buildCollectibleCard(
                  imageUrl: item['image'] ?? '',
                  rarity: item['rarity'] ?? 'Common',
                  rarityColor: _getRarityColor(item['rarity']),
                  title: item['name'] ?? 'Unknown',
                  subtitle: item['description'] ?? '',
                  shadowColor: _getRarityColor(item['rarity']),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMockCollectibles(Color textColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'COLLECTIBLES',
                style: GoogleFonts.splineSans(
                  color: textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              Text(
                'View All',
                style: GoogleFonts.splineSans(
                  color: kPrimaryColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 224,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            children: [
              _buildCollectibleCard(
                imageUrl:
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuCE8saTxUc9oJu2sQcJ-Syruout1t7sD2zH6hkAdmTSvaaRkZD9MjVQPAWJ3glXxz8Eolkq5jtoVId8UNxpqCuAKaNhSzF24bVaBIlBb2qQnZY9pwPejyhbqz-LseZmodusLXAcddcnouRcK6nTRI8zIANR0IFepXFNFcFCVB59J_7HHDZIimcYXkpNKvcXIYwonA4w_ZIVR-iePiBQWMvBs1Q3o9nOlf45-8GUsnE-wa5n8ul0IXHOg3WoA0eqQwKEK8irZsjND_wf',
                rarity: 'Rare',
                rarityColor: const Color(0xFF4ADE80),
                title: 'Genesis Pass',
                subtitle: '#0422 Minted',
                shadowColor: const Color(0xFF8C25F4),
              ),
              const SizedBox(width: 16),
              _buildCollectibleCard(
                imageUrl:
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuBi8a-WkMXRnv1FhRvPLhJe6DclGCljGzktqsJvQF76arSaXoyxe_rmtzXjtvQ4tWBbKRxVtR0hbaCPaPTDIn2E1Q0RRotjYHNi4j0HJrNqYTCV0SiXU3pwG659cYCRyC1FLx6hJpFZUw2l3LhJHBfJXHfEc-tIlrjFuvfsWEVFDTAFTcr-3sB5LpYcJCyztymg72VOgMtuNGtz1fXdKKEAOqnnVmJV48D4nHWSWBWW-gpuHFW2L2XqmKEehNYEPo_5T_TkXp-UgH3l',
                rarity: 'Epic',
                rarityColor: Colors.blueAccent,
                title: 'Tokyo Fashion',
                subtitle: 'Event Token',
                shadowColor: Colors.blue,
              ),
              const SizedBox(width: 16),
              _buildCollectibleCard(
                imageUrl:
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuBhqBBHKvegUw5pX1lvT6r8m8BZ8H1YBe8e4lAsaZvsPqtYtezypZFredhpRK3c3WPZzidfr5t1E8nruelNfXuWB5qf0mXkcwmHhTWO-hKCLDHznPFZ7qJpuJVLVs_LDZTtKpiTMj_jgC7f38m1hS25N-EKEipaVJ7me8O23RFIr4e-UB2ISX2NJzJUmEmuqDyaM31aU5rUGcdbQEYHB_6rfvjn6kpyrE6vMVYdteCjYfTJmld1AWjIa135wUv2gKfKtrkFe4EmOQpX',
                rarity: 'Legendary',
                rarityColor: Colors.purpleAccent,
                title: 'VIP Lounge',
                subtitle: 'Access Key',
                shadowColor: Colors.purple,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getRarityColor(String? rarity) {
    if (rarity == null) return Colors.grey;
    switch (rarity.toLowerCase()) {
      case 'rare':
        return const Color(0xFF4ADE80);
      case 'epic':
        return Colors.blueAccent;
      case 'legendary':
        return Colors.purpleAccent;
      default:
        return Colors.grey;
    }
  }

  Widget _buildCollectibleCard({
    required String imageUrl,
    required String rarity,
    required Color rarityColor,
    required String title,
    required String subtitle,
    required Color shadowColor,
  }) {
    return Container(
      width: 160,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Stack(
        children: [
          // Hover/Glow effect simulated
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    shadowColor.withValues(alpha: 0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Dot
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: rarityColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: rarityColor.withValues(alpha: 0.8),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
          ),
          // Content
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              Expanded(
                child: Center(
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    height: 100,
                    width: 100,
                    fit: BoxFit.contain,
                    placeholder: (context, url) => const SizedBox(
                      width: 100,
                      height: 100,
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white24,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.token, color: Colors.white, size: 50),
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.8),
                      Colors.transparent,
                    ],
                  ),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(24),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rarity.toUpperCase(),
                      style: GoogleFonts.splineSans(
                        color: rarityColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      title,
                      style: GoogleFonts.splineSans(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.splineSans(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistorySection(Color textColor, List<dynamic> history) {
    // Mock if empty
    if (history.isEmpty) {
      return _buildMockHistory(textColor);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'HISTORY',
            style: GoogleFonts.splineSans(
              color: textColor,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          ...history.map(
            (item) => _buildHistoryItem(
              icon: Icons.local_activity_rounded,
              title: item['title'] ?? 'Activity',
              subtitle: item['subtitle'] ?? '',
              amount: item['amount'] ?? '',
              date: item['date'] ?? '',
              isPositive: item['is_positive'] == true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMockHistory(Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'HISTORY',
            style: GoogleFonts.splineSans(
              color: textColor,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          _buildHistoryItem(
            icon: Icons.local_activity_rounded,
            title: 'Met Gala Afterparty',
            subtitle: 'Payment Processed',
            amount: '- 5,000 DUTY',
            date: 'Yesterday',
            isPositive: false,
          ),
          _buildHistoryItem(
            icon: Icons.diamond_rounded,
            title: 'Exclusive Drop #4',
            subtitle: 'Collectible Received',
            amount: '+ 1 NFT',
            date: '2 Days Ago',
            isPositive: true,
            isNft: true,
          ),
          _buildHistoryItem(
            icon: Icons.group_rounded,
            title: 'Community Meetup',
            subtitle: 'Checked In',
            amount: '+ 200 DUTY',
            date: 'Oct 24',
            isPositive: true,
          ),
          _buildHistoryItem(
            icon: Icons.qr_code_scanner_rounded,
            title: 'Main Stage Access',
            subtitle: 'Ticket Scanned',
            amount: 'Verified',
            date: 'Oct 22',
            isNeutral: true,
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String amount,
    required String date,
    bool isPositive = false,
    bool isNeutral = false,
    bool isNft = false,
  }) {
    Color amountColor;
    if (isNeutral) {
      amountColor = Colors.white.withValues(alpha: 0.5);
    } else if (isNft) {
      amountColor = const Color(0xFF4ADE80);
    } else if (isPositive) {
      amountColor = kPrimaryColor;
    } else {
      amountColor = Colors.white;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: Icon(icon, color: Colors.white70, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.splineSans(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.splineSans(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: GoogleFonts.splineSans(
                  color: amountColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                date.toUpperCase(),
                style: GoogleFonts.splineSans(
                  color: Colors.white.withValues(alpha: 0.3),
                  fontSize: 10,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _GlassIconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.05),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Icon(icon, size: 20, color: Colors.white70),
      ),
    );
  }

  Widget _buildVipMembershipCard(BuildContext context, bool isVip) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GestureDetector(
        onTap: () => context.push('/memberships'),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                kPrimaryColor.withValues(alpha: 0.15),
                kPrimaryColor.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: kPrimaryColor.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: kPrimaryColor.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.stars_rounded,
                  color: Colors.amber,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isVip ? 'VIP MEMBERSHIP ACTIVE' : 'UPGRADE TO VIP',
                      style: GoogleFonts.splineSans(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isVip
                          ? 'You are enjoying premium benefits'
                          : 'Unlock exclusive perks and priority access',
                      style: GoogleFonts.splineSans(
                        color: Colors.white60,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white38,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMyTicketsButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GestureDetector(
        onTap: () => context.push('/my-tickets'),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF8655F6).withValues(alpha: 0.2),
                const Color(0xFF8655F6).withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFF8655F6).withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF8655F6).withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.confirmation_number_outlined,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'My Tickets',
                      style: GoogleFonts.splineSans(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'View your upcoming events',
                      style: GoogleFonts.splineSans(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white54,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryMarketCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GestureDetector(
        onTap: () => context.push('/marketplace'),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.storefront_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SECONDARY MARKET',
                      style: GoogleFonts.splineSans(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Buy resale tickets from other fans',
                      style: GoogleFonts.splineSans(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white24,
                size: 16,
              ),
            ],
          ),
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
      color: kBackgroundDark, // kDarkBackground
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
