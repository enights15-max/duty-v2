import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../providers/home_provider.dart';
import '../../data/models/event_model.dart';
import '../../data/models/advertisement_model.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../profile/data/models/social_feed_model.dart';
import '../../../profile/data/repositories/social_repository.dart';
import '../../../../core/constants/app_urls.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/widgets/cached_image.dart';
import '../../../wallet/presentation/providers/wallet_provider.dart';
import '../../../chat/presentation/providers/chat_provider.dart';
import '../../../profile/presentation/providers/marketplace_provider.dart';
import '../../../profile/presentation/providers/review_prompt_provider.dart';

final isForYouGridViewProvider = StateProvider<bool>((ref) => true);

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.dutyTheme;
    // Watch home content (Ads, Events, etc)
    final homeContentAsyncValue = ref.watch(homeContentProvider);
    final eventsAsyncValue = ref.watch(homeEventsProvider);
    final currentUser = ref.watch(currentUserProvider);
    String? avatarUrl;
    final photo = currentUser?['photo']?.toString();
    if (photo != null) {
      if (photo.startsWith('http')) {
        avatarUrl = photo;
      } else {
        avatarUrl = '${AppConstants.profileImageBaseUrl}$photo';
      }
    }

    final isVerified =
        currentUser != null &&
        currentUser['email_verified_at'] != null &&
        currentUser['phone_verified_at'] != null;

    return Scaffold(
      backgroundColor: palette.background,
      body: Stack(
        children: [
          // Background Gradient (Optional, similar to Login to give depth)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topLeft,
                  radius: 1.2,
                  colors: [palette.heroGradientStart, palette.background],
                ),
              ),
            ),
          ),

          // Main Content
          SafeArea(
            bottom: false,
            child: RefreshIndicator(
              color: palette.primary,
              backgroundColor: palette.surfaceAlt,
              onRefresh: () async {
                ref.invalidate(homeContentProvider);
                ref.invalidate(socialFeedProvider);
                try {
                  await ref.read(homeContentProvider.future);
                  await ref.read(socialFeedProvider.future);
                } catch (_) {}
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  // Header
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24.0,
                        vertical: 20.0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Image.asset(
                            'assets/images/logo-w.png',
                            height: 30,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'DISCOVERY',
                                    style: GoogleFonts.outfit(
                                      color: palette.primary,
                                      fontSize: 12,
                                      letterSpacing: 2,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'DUTY.',
                                    style: GoogleFonts.outfit(
                                      color: palette.textPrimary,
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                          Row(
                            children: [
                              // Wallet balance chip
                              GestureDetector(
                                onTap: () => context.push('/wallet'),
                                child: Consumer(
                                  builder: (context, ref, _) {
                                    final walletAsync = ref.watch(
                                      walletProvider,
                                    );
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: palette.primarySurface,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: palette.borderStrong,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons
                                                .account_balance_wallet_rounded,
                                            color: palette.primary,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 6),
                                          walletAsync.when(
                                            data: (wallet) {
                                              final balance =
                                                  double.tryParse(
                                                    wallet['balance']
                                                            ?.toString() ??
                                                        '0',
                                                  ) ??
                                                  0;
                                              return Text(
                                                '\$${balance.toStringAsFixed(0)}',
                                                style: GoogleFonts.splineSans(
                                                  color: palette.textPrimary,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              );
                                            },
                                            loading: () => const SizedBox(
                                              width: 12,
                                              height: 12,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 1.5,
                                                color: kTextMuted,
                                              ),
                                            ),
                                            error: (_, _) => Text(
                                              '--',
                                              style: GoogleFonts.splineSans(
                                                color: palette.textMuted,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Chat Icon
                              Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: palette.primarySurface,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: palette.borderStrong,
                                      ),
                                    ),
                                    child: IconButton(
                                      icon: Icon(
                                        Icons.chat_bubble_outline,
                                        color: palette.textPrimary,
                                        size: 20,
                                      ),
                                      onPressed: () => context.go('/messages'),
                                      constraints: const BoxConstraints(
                                        minWidth: 40,
                                        minHeight: 40,
                                      ),
                                      padding: EdgeInsets.zero,
                                    ),
                                  ),
                                  Consumer(
                                    builder: (context, ref, _) {
                                      final unreadCountAsync = ref.watch(
                                        unreadCountProvider,
                                      );
                                      return unreadCountAsync.when(
                                        data: (count) {
                                          if (count > 0) {
                                            return Positioned(
                                              top: -2,
                                              right: -2,
                                              child: Container(
                                                padding: const EdgeInsets.all(
                                                  4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: palette.danger,
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: palette.background,
                                                    width: 1.5,
                                                  ),
                                                ),
                                                constraints:
                                                    const BoxConstraints(
                                                      minWidth: 16,
                                                      minHeight: 16,
                                                    ),
                                                child: Text(
                                                  count > 99
                                                      ? '99+'
                                                      : count.toString(),
                                                  style: const TextStyle(
                                                    color: kTextPrimary,
                                                    fontSize: 8,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            );
                                          }
                                          return const SizedBox.shrink();
                                        },
                                        loading: () => const SizedBox.shrink(),
                                        error: (_, _) =>
                                            const SizedBox.shrink(),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Dynamic Greeting
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                _getGreetingMessage(),
                                style: GoogleFonts.outfit(
                                  color: palette.textSecondary,
                                  fontSize: 16,
                                ),
                              ),
                              if (currentUser != null) ...[
                                const SizedBox(width: 4),
                                Text(
                                  'DISCOVERY',
                                  style: GoogleFonts.outfit(
                                    color: palette.primary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        GestureDetector(
                          onTap: () => context.go('/profile'),
                          child: Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              Icon(
                                Icons.location_on,
                                color: palette.primary,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Santo Domingo, RD',
                                style: GoogleFonts.inter(
                                  color: palette.textMuted,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 20)),

                  // Search Bar
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: GestureDetector(
                        onTap: () => context.push('/search'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: palette.surface,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: palette.border),
                            boxShadow: [
                              BoxShadow(
                                color: palette.shadow.withValues(alpha: 0.12),
                                blurRadius: 20,
                                offset: const Offset(0, 12),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: palette.primarySurface,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(
                                  Icons.search_rounded,
                                  color: palette.primary,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Search events, artists, venues...',
                                  style: GoogleFonts.outfit(
                                    color: palette.textMuted,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 9,
                                ),
                                decoration: BoxDecoration(
                                  color: palette.surfaceAlt,
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(color: palette.border),
                                ),
                                child: Text(
                                  'Explore',
                                  style: GoogleFonts.outfit(
                                    color: palette.primary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Search Bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 32)),

                  // Unified Services Grid (5x2)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _QuickActionTile(
                                  icon: Icons.account_balance_wallet_rounded,
                                  title: 'Wallet',
                                  color: palette.primary,
                                  onTap: () => context.push('/wallet'),
                                ),
                              ),
                              Expanded(
                                child: _QuickActionTile(
                                  icon: Icons.music_note_rounded,
                                  title: 'Artists',
                                  color: const Color(0xFFFF2D55),
                                  onTap: () => context.push('/artists'),
                                ),
                              ),
                              Expanded(
                                child: _QuickActionTile(
                                  icon: Icons.business_rounded,
                                  title: 'Organizers',
                                  color: const Color(0xFF007AFF),
                                  onTap: () => context.push('/organizers'),
                                ),
                              ),
                              Expanded(
                                child: _QuickActionTile(
                                  icon: Icons.location_on_rounded,
                                  title: 'Venues',
                                  color: const Color(0xFF00C7BE),
                                  onTap: () => context.push('/venues'),
                                ),
                              ),
                              Expanded(
                                child: _QuickActionTile(
                                  icon: Icons.storefront_rounded,
                                  title: 'Market',
                                  color: const Color(0xFFFF9500),
                                  onTap: () => context.push('/marketplace'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _QuickActionTile(
                                  icon: Icons.move_to_inbox_rounded,
                                  title: 'Inbox',
                                  color: const Color(0xFFFF2E93),
                                  badgeCount: ref.watch(
                                    pendingTransfersCountProvider,
                                  ),
                                  onTap: () =>
                                      context.push('/pending-transfers'),
                                ),
                              ),
                              Expanded(
                                child: _QuickActionTile(
                                  icon: Icons.outbox_rounded,
                                  title: 'Outbox',
                                  color: const Color(0xFF34C759),
                                  onTap: () => context.push('/transfer-outbox'),
                                ),
                              ),
                              Expanded(
                                child: _QuickActionTile(
                                  icon: Icons.confirmation_num_rounded,
                                  title: 'Reservas',
                                  color: const Color(0xFFFFD60A),
                                  onTap: () => context.push('/reservations'),
                                ),
                              ),
                              Expanded(
                                child: _QuickActionTile(
                                  icon: Icons.workspace_premium_rounded,
                                  title: 'Rewards',
                                  color: const Color(0xFFFF3B30),
                                  onTap: () => context.push('/loyalty'),
                                ),
                              ),
                              Expanded(
                                child: _QuickActionTile(
                                  icon: Icons.rate_review_rounded,
                                  title: 'Reviews',
                                  color: const Color(0xFFA4C639),
                                  badgeCount:
                                      ref
                                          .watch(pendingReviewPromptsProvider)
                                          .valueOrNull
                                          ?.length ??
                                      0,
                                  onTap: () => context.push('/reviews/pending'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 32)),

                  // Hero Section (Advertisements Slider)
                  SliverToBoxAdapter(
                    child: homeContentAsyncValue.when(
                      data: (content) {
                        if (content.advertisements.isEmpty) {
                          // Fallback to latest event if no ads
                          return eventsAsyncValue.when(
                            data: (events) {
                              if (events.isEmpty) return const SizedBox();
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24.0,
                                ),
                                child: _buildHeroSection(context, events[0]),
                              );
                            },
                            loading: () => _buildHeroShimmer(context),
                            error: (_, _) => const SizedBox(),
                          );
                        }
                        return _buildAdSlider(context, content.advertisements);
                      },
                      loading: () => _buildHeroShimmer(context),
                      error: (_, _) => const SizedBox(),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 32)),

                  SliverToBoxAdapter(
                    child: socialFeedAsyncValue.when(
                      data: (feed) => _buildSocialFeedSection(context, feed),
                      loading: () => _buildSocialFeedLoading(context),
                      error: (_, _) => const SizedBox.shrink(),
                    ),
                  ),

                  // const SliverToBoxAdapter(child: SizedBox(height: 32)),

                  // _buildDiscoveryPreviewSection(
                  //   context,
                  //   ref,
                  //   DiscoveryKind.artists,
                  // ),
                  // const SliverToBoxAdapter(child: SizedBox(height: 28)),

                  // _buildDiscoveryPreviewSection(
                  //   context,
                  //   ref,
                  //   DiscoveryKind.organizers,
                  // ),
                  // const SliverToBoxAdapter(child: SizedBox(height: 28)),

                  // _buildDiscoveryPreviewSection(
                  //   context,
                  //   ref,
                  //   DiscoveryKind.venues,
                  // ),
                  const SliverToBoxAdapter(child: SizedBox(height: 32)),

                  // Trending Title
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 7,
                                ),
                                decoration: BoxDecoration(
                                  color: palette.primarySurface,
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                    color: palette.borderStrong,
                                  ),
                                ),
                                child: Text(
                                  'DISCOVER',
                                  style: GoogleFonts.outfit(
                                    color: palette.primary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.4,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Trending Now',
                                style: GoogleFonts.outfit(
                                  color: palette.textPrimary,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () => context.push('/explore'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: palette.surfaceAlt,
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(color: palette.border),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'See All',
                                    style: GoogleFonts.outfit(
                                      color: palette.textSecondary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 15,
                                    color: palette.primary,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Icon(Icons.tune, color: Colors.grey, size: 20),
                        ],
                      ),
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 24)),

                  // Trending List (Horizontal)
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 228,
                      child: eventsAsyncValue.when(
                        data: (events) {
                          if (events.isEmpty) return const SizedBox();
                          return ListView.builder(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            itemCount: events
                                .take(3)
                                .length, // Take first 3 as trending
                            itemBuilder: (context, index) {
                              return _buildTrendingCard(
                                context,
                                events[index],
                                socialProofByEventId[events[index].id],
                              );
                            },
                          );
                        },
                        loading: () => ListView.builder(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          itemCount: 3,
                          itemBuilder: (context, index) => Shimmer.fromColors(
                            baseColor: palette.surfaceAlt,
                            highlightColor: palette.surfaceMuted,
                            child: Container(
                              width: 240,
                              margin: const EdgeInsets.only(right: 16),
                              decoration: BoxDecoration(
                                color: palette.surface,
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                        ),
                        error: (err, _) => const SizedBox(),
                      ),
                    ),
                  ),
                ),

                  // Bottom padding to clear the TabBar
                  const SliverToBoxAdapter(child: SizedBox(height: 120)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialFeedSection(BuildContext context, SocialFeedModel feed) {
    final palette = context.dutyTheme;
    final items = feed.items.take(6).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: palette.border),
          boxShadow: [
            BoxShadow(
              color: palette.primaryGlow.withValues(alpha: 0.12),
              blurRadius: 30,
              offset: const Offset(0, 18),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: palette.primarySurface,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.auto_awesome_rounded,
                        size: 14,
                        color: palette.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'YOUR SCENE',
                        style: GoogleFonts.outfit(
                          color: palette.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => context.push('/social/connections'),
                  icon: const Icon(Icons.people_alt_rounded, size: 16),
                  label: const Text('My Network'),
                  style: TextButton.styleFrom(foregroundColor: palette.primary),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'What your people are planning tonight',
              style: GoogleFonts.outfit(
                color: palette.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w700,
                height: 1.05,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              items.isEmpty
                  ? 'Start following people, organizers and venues to turn Duty into your own event graph.'
                  : 'Built from who you follow, what they save and where they are actually showing up.',
              style: GoogleFonts.inter(
                color: palette.textSecondary,
                fontSize: 13,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildSceneMetric(
                  context,
                  '${feed.summary.followingPeopleCount}',
                  'People',
                ),
                _buildSceneMetric(
                  context,
                  '${feed.summary.followingProfilesCount}',
                  'Profiles',
                ),
                _buildSceneMetric(
                  context,
                  '${feed.summary.pendingRequestsCount}',
                  'Requests',
                  highlight: feed.summary.pendingRequestsCount > 0,
                ),
              ],
            ),
            const SizedBox(height: 18),
            if (items.isEmpty)
              _buildSocialFeedEmptyState(context)
            else
              SizedBox(
                height: 228,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 14),
                  itemBuilder: (context, index) {
                    return _buildSocialFeedCard(context, items[index]);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialFeedCard(BuildContext context, SocialFeedItemModel item) {
    final palette = context.dutyTheme;
    final accent = _sceneReasonColor(item.reasonType);
    final thumbnail = item.thumbnailUrl != null && item.thumbnailUrl!.isNotEmpty
        ? item.thumbnailUrl!
        : '';

    return GestureDetector(
      onTap: () => context.push('/event-details/${event.id}'),
      child: Container(
        width: 286,
        decoration: BoxDecoration(
          color: palette.surfaceAlt,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: accent.withValues(alpha: 0.22)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                    child: thumbnail.isNotEmpty
                        ? CachedImage(
                            imageUrl: thumbnail,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                            errorWidget: _buildSocialFeedImageFallback(
                              context,
                              accent,
                            ),
                          )
                        : _buildSocialFeedImageFallback(context, accent),
                  ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.06),
                            Colors.black.withValues(alpha: 0.74),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 14,
                    left: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: accent.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        item.reasonLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 14,
                    right: 14,
                    bottom: 14,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            height: 1.05,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _formatSceneMeta(item),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
              child: Row(
                children: [
                  Expanded(
                    child: _buildScenePeopleRow(
                      context,
                      item.people,
                      item.peopleCount,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.arrow_outward_rounded,
                          color: accent,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Open',
                          style: GoogleFonts.outfit(
                            color: accent,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialFeedEmptyState(BuildContext context) {
    final palette = context.dutyTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: palette.surfaceAlt,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: palette.primarySurface,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.hub_rounded, color: palette.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Your social feed wakes up as soon as you build a network.',
                  style: GoogleFonts.outfit(
                    color: palette.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Follow people, organizers and venues you care about. Then we can show you what your scene is saving, attending and hosting.',
            style: GoogleFonts.inter(
              color: palette.textSecondary,
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.tonalIcon(
            onPressed: () => context.push('/social/connections'),
            icon: const Icon(Icons.people_alt_rounded),
            label: const Text('Open My Network'),
            style: FilledButton.styleFrom(
              foregroundColor: palette.onPrimary,
              backgroundColor: palette.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialFeedLoading(BuildContext context) {
    final palette = context.dutyTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Shimmer.fromColors(
        baseColor: palette.surfaceAlt,
        highlightColor: palette.surfaceMuted,
        child: Container(
          height: 298,
          decoration: BoxDecoration(
            color: palette.surface,
            borderRadius: BorderRadius.circular(28),
          ),
        ),
      ),
    );
  }

  Widget _buildSceneMetric(
    BuildContext context,
    String value,
    String label, {
    bool highlight = false,
  }) {
    final palette = context.dutyTheme;
    final highlightColor = palette.warning;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: highlight
            ? highlightColor.withValues(alpha: 0.14)
            : palette.surfaceAlt,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: highlight
              ? highlightColor.withValues(alpha: 0.28)
              : palette.border,
        ),
      ),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$value ',
              style: GoogleFonts.outfit(
                color: palette.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
            TextSpan(
              text: label,
              style: GoogleFonts.outfit(
                color: highlight ? highlightColor : palette.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScenePeopleRow(
    BuildContext context,
    List<SocialFeedPersonModel> people,
    int peopleCount,
  ) {
    final palette = context.dutyTheme;
    if (people.isEmpty || peopleCount <= 0) {
      return Text(
        'From your network',
        style: GoogleFonts.inter(
          color: palette.textMuted,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      );
    }

    final visiblePeople = people.take(3).toList();

    return Row(
      children: [
        SizedBox(
          width: (visiblePeople.length * 18) + 20,
          height: 24,
          child: Stack(
            children: [
              for (var i = 0; i < visiblePeople.length; i++)
                Positioned(
                  left: i * 18,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: palette.background, width: 2),
                    ),
                    child: ClipOval(
                      child:
                          visiblePeople[i].photoUrl != null &&
                              visiblePeople[i].photoUrl!.isNotEmpty
                          ? CachedImage(
                              imageUrl: visiblePeople[i].photoUrl!,
                              width: 24,
                              height: 24,
                              fit: BoxFit.cover,
                              errorWidget: _buildScenePersonFallback(context),
                            )
                          : _buildScenePersonFallback(context),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            peopleCount == 1
                ? visiblePeople.first.name
                : '$peopleCount people in your network',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              color: palette.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScenePersonFallback(BuildContext context) {
    final palette = context.dutyTheme;
    return Container(
      color: palette.surfaceMuted,
      child: Icon(Icons.person, color: palette.textMuted, size: 12),
    );
  }

  Widget _buildSocialFeedImageFallback(BuildContext context, Color accent) {
    final palette = context.dutyTheme;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [accent.withValues(alpha: 0.24), palette.background],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.local_activity_rounded,
          color: accent.withValues(alpha: 0.7),
          size: 34,
        ),
      ),
    );
  }

  Color _sceneReasonColor(String reasonType) {
    switch (reasonType) {
      case 'followed_people_going':
        return const Color(0xFF00D68F);
      case 'followed_people_interested':
        return const Color(0xFFFFB020);
      case 'followed_profile_event':
        return kPrimaryColor;
      default:
        return const Color(0xFF7C8BFF);
    }
  }

  String _formatSceneMeta(SocialFeedItemModel item) {
    final date = item.startsAt;
    final parts = <String>[
      if (item.organizerName != null && item.organizerName!.isNotEmpty)
        item.organizerName!,
      if (date != null) _sceneDateLabel(date),
      if (item.startTime != null && item.startTime!.isNotEmpty) item.startTime!,
    ];

    if (parts.isEmpty) {
      return item.address ?? 'Open event';
    }

    return parts.join(' • ');
  }

  String _sceneDateLabel(dynamic rawDate) {
    DateTime? date;
    if (rawDate is DateTime) {
      date = rawDate;
    } else if (rawDate is String && rawDate.trim().isNotEmpty) {
      date = DateTime.tryParse(rawDate.trim());
    }

    if (date == null) {
      return rawDate?.toString().trim().isNotEmpty == true
          ? rawDate.toString().trim()
          : 'Fecha por confirmar';
    }

    final local = date.toLocal();
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    final weekday = weekdays[local.weekday - 1];
    final month = months[local.month - 1];
    return '$weekday ${local.day} $month';
  }

  Widget _buildTrendingCard(
    BuildContext context,
    dynamic event,
    SocialFeedItemModel? socialProof,
  ) {
    final palette = context.dutyTheme;
    final isSoldOutTotal =
        event.showWaitlistCta ||
        (event.availabilityState == 'sold_out' &&
            event.showMarketplaceFallback != true);
    final topBadges = <Widget>[
      if (event.id % 2 == 0) _buildStatusBadge('TRENDING', kWarmGold),
      if (isSoldOutTotal)
        _buildStatusBadge(
          event.viewerWaitlistSubscribed == true ? 'EN WAITLIST' : 'SOLD OUT',
          event.viewerWaitlistSubscribed == true
              ? palette.success
              : palette.danger,
        ),
      if (event.showMarketplaceFallback == true &&
          event.marketplaceAvailableCount > 0)
        _buildStatusBadge(
          '${event.marketplaceAvailableCount} EN BLACKMARKET',
          palette.warning,
        ),
    ];

    return GestureDetector(
      onTap: () => context.push('/event-details/${event.id}'),
      child: Container(
        width: 240,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: palette.border),
          boxShadow: [
            BoxShadow(
              color: palette.shadow.withValues(alpha: 0.22),
              blurRadius: 26,
              offset: const Offset(0, 18),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl:
                          AppUrls.getEventThumbnailUrl(event.thumbnail) ?? '',
                      fit: BoxFit.cover,
                    ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.04),
                            Colors.black.withValues(alpha: 0.16),
                            palette.background.withValues(alpha: 0.86),
                            palette.background,
                          ],
                          stops: const [0.0, 0.28, 0.68, 1.0],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (topBadges.isNotEmpty)
              Positioned(
                top: 14,
                left: 14,
                right: 14,
                child: Wrap(spacing: 8, runSpacing: 8, children: topBadges),
              ),
            Positioned(
              left: 14,
              right: 14,
              bottom: socialProof != null ? 62 : 18,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    event.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(
                      color: palette.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      height: 1.04,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today_rounded,
                              size: 13,
                              color: palette.primary,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                _sceneDateLabel(event.date),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                  color: palette.textSecondary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.38),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: palette.borderStrong),
                        ),
                        child: Text(
                          event.formattedPriceLabel,
                          style: GoogleFonts.outfit(
                            color: palette.success,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (isSoldOutTotal && event.waitlistCount > 0)
              Positioned(
                left: 14,
                right: 14,
                bottom: socialProof != null ? 110 : 66,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: _buildStatusBadge(
                    event.waitlistCount == 1
                        ? '1 PERSONA ESPERANDO'
                        : '${event.waitlistCount} ESPERANDO',
                    palette.primary,
                  ),
                ),
              ),
            if (socialProof != null)
              Positioned(
                left: 14,
                right: 14,
                bottom: 14,
                child: _buildCardSocialCue(context, socialProof),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdSlider(
    BuildContext context,
    List<AdvertisementModel> advertisements,
  ) {
    final palette = context.dutyTheme;
    return Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: 200,
            viewportFraction: 0.92,
            enlargeCenterPage: true,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 5),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            autoPlayCurve: Curves.fastOutSlowIn,
            enableInfiniteScroll: advertisements.length > 1,
          ),
          items: advertisements.map((ad) {
            return Builder(
              builder: (BuildContext context) {
                return Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Stack(
                      children: [
                        // Ad Image
                        Positioned.fill(
                          child: CachedNetworkImage(
                            imageUrl: ad.image ?? '',
                            fit: BoxFit.cover,
                            placeholder: (context, url) =>
                                _buildHeroShimmer(context),
                            errorWidget: (context, url, error) => Container(
                              color: palette.surfaceAlt,
                              child: Icon(
                                Icons.broken_image_rounded,
                                color: palette.textMuted,
                                size: 40,
                              ),
                            ),
                          ),
                        ),

                        // Gradient Overlay for readability
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.4),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildHeroSection(BuildContext context, EventModel event) {
    final palette = context.dutyTheme;
    final isSoldOutTotal =
        event.availabilityState == 'sold_out' &&
        event.showMarketplaceFallback != true;
    final heroBadges = <Widget>[
      _buildStatusBadge('FEATURED', palette.primary),
      if (isSoldOutTotal)
        _buildStatusBadge(
          event.viewerWaitlistSubscribed ? 'EN WAITLIST' : 'SOLD OUT',
          event.viewerWaitlistSubscribed ? palette.success : palette.danger,
        ),
      if (event.showMarketplaceFallback && event.marketplaceAvailableCount > 0)
        _buildStatusBadge(
          '${event.marketplaceAvailableCount} EN BLACKMARKET',
          palette.warning,
        ),
    ];

    return GestureDetector(
      onTap: () => context.push('/event-details/${event.id}'),
      child: Container(
        height: 400,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: palette.primaryGlow,
              blurRadius: 30,
              offset: const Offset(0, 20),
            ),
          ],
          image: DecorationImage(
            image: CachedNetworkImageProvider(
              AppUrls.getEventThumbnailUrl(event.thumbnail) ?? '',
            ),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: 20,
              left: 20,
              right: 20,
              child: Wrap(
                alignment: WrapAlignment.end,
                spacing: 8,
                runSpacing: 8,
                children: heroBadges,
              ),
            ),
            if (isSoldOutTotal && event.waitlistCount > 0)
              Positioned(
                left: 20,
                bottom: 20,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.42),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: palette.borderStrong),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.people_alt_rounded,
                        color: palette.textPrimary,
                        size: 15,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        event.waitlistCount == 1
                            ? '1 persona esperando'
                            : '${event.waitlistCount} personas esperando',
                        style: GoogleFonts.inter(
                          color: palette.textPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroShimmer(BuildContext context) {
    final palette = context.dutyTheme;
    return Shimmer.fromColors(
      baseColor: palette.surfaceAlt,
      highlightColor: palette.surfaceMuted,
      child: Container(
        height: 400,
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(32),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Text(
        text,
        style: GoogleFonts.outfit(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.9,
        ),
      ),
    );
  }

  String _getGreetingMessage() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning,';
    if (hour < 17) return 'Good Afternoon,';
    return 'Good Evening,';
  }

  Widget _buildCardSocialCue(
    BuildContext context,
    SocialFeedItemModel item, {
    bool compact = false,
    bool elevated = false,
  }) {
    final palette = context.dutyTheme;
    final accent = _sceneReasonColor(item.reasonType);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : 12,
        vertical: compact ? 8 : 10,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: elevated ? 0.5 : 0.38),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withValues(alpha: 0.35)),
        boxShadow: elevated
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.22),
                  blurRadius: 16,
                  offset: const Offset(0, 10),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: compact ? 22 : 26,
            height: compact ? 22 : 26,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _sceneReasonIcon(item.reasonType),
              size: compact ? 12 : 14,
              color: accent,
            ),
          ),
          SizedBox(width: compact ? 8 : 10),
          Expanded(
            child: Text(
              item.reasonLabel,
              maxLines: compact ? 1 : 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.outfit(
                color: palette.textPrimary,
                fontSize: compact ? 10 : 12,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _sceneReasonIcon(String reasonType) {
    switch (reasonType) {
      case 'followed_people_going':
        return Icons.check_circle_rounded;
      case 'followed_people_interested':
        return Icons.favorite_rounded;
      case 'followed_profile_event':
        return Icons.campaign_rounded;
      default:
        return Icons.auto_awesome_rounded;
    }
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
    this.badgeCount = 0,
  });

  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    final palette = context.dutyTheme;
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 80, // Fixed width for alignment
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: color.withValues(alpha: 0.5)),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                if (badgeCount > 0)
                  Positioned(
                    top: -6,
                    right: -6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: palette.danger,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: palette.background, width: 2),
                      ),
                      child: Text(
                        badgeCount > 99 ? '99+' : '$badgeCount',
                        style: GoogleFonts.outfit(
                          color: palette.textPrimary,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    event.title,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              title.toUpperCase(),
              textAlign: TextAlign.center,
              maxLines: 2,
              style: GoogleFonts.outfit(
                color: palette.textPrimary,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
