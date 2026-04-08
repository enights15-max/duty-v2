import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/home_provider.dart';
<<<<<<< Updated upstream
=======
import '../../data/models/event_model.dart';
import '../../data/models/advertisement_model.dart';
import '../../data/models/discovery_models.dart';
import '../providers/discovery_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../profile/data/models/social_feed_model.dart';
import '../../../profile/data/repositories/social_repository.dart';
import '../../../../core/constants/app_urls.dart';
import '../../../../core/widgets/cached_image.dart';
import '../../../wallet/presentation/providers/wallet_provider.dart';
import '../../../chat/presentation/providers/chat_provider.dart';
import '../../../profile/presentation/providers/marketplace_provider.dart';
import '../../../profile/presentation/providers/review_prompt_provider.dart';

final isForYouGridViewProvider = StateProvider<bool>((ref) => true);
>>>>>>> Stashed changes

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch events
    final eventsAsyncValue = ref.watch(homeEventsProvider);

<<<<<<< Updated upstream
=======
    final socialFeedAsyncValue = ref.watch(socialFeedProvider);
    final currentUser = ref.watch(currentUserProvider);
    final socialProofByEventId = {
      for (final item
          in socialFeedAsyncValue.valueOrNull?.items ??
              const <SocialFeedItemModel>[])
        item.eventId: item,
    };
>>>>>>> Stashed changes
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A), // Dark Background
      body: Stack(
        children: [
          // Background Gradient (Optional, similar to Login to give depth)
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topLeft,
                  radius: 1.2,
                  colors: [
                    Color(0xFF2A1B3D), // Purple glow top-left
                    Color(0xFF0F0F1A), // Dark base
                  ],
                ),
              ),
            ),
          ),

          // Main Content
          SafeArea(
            bottom: false,
<<<<<<< Updated upstream
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 20.0,
=======
            child: RefreshIndicator(
              color: const Color(0xFF6200EE),
              backgroundColor: const Color(0xFF1E1E2C),
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
                                      color: const Color(0xFF6200EE),
                                      fontSize: 12,
                                      letterSpacing: 2,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'DUTY.',
                                    style: GoogleFonts.outfit(
                                      color: Colors.white,
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
                                        color: const Color(
                                          0xFF6200EE,
                                        ).withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: const Color(
                                            0xFF6200EE,
                                          ).withValues(alpha: 0.3),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons
                                                .account_balance_wallet_rounded,
                                            color: Color(0xFF6200EE),
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
                                                  color: Colors.white,
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
                                                color: Colors.white38,
                                              ),
                                            ),
                                            error: (_, _) => Text(
                                              '--',
                                              style: GoogleFonts.splineSans(
                                                color: Colors.white38,
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
                                      color: const Color(0xFF6200EE).withValues(alpha: 0.15),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: const Color(0xFF6200EE).withValues(alpha: 0.3),
                                      ),
                                    ),
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.chat_bubble_outline,
                                        color: Colors.white,
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
                                  Consumer(builder: (context, ref, _) {
                                    final unreadCountAsync = ref.watch(unreadCountProvider);
                                    return unreadCountAsync.when(
                                      data: (count) {
                                        if (count > 0) {
                                          return Positioned(
                                            top: -2,
                                            right: -2,
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                color: Colors.red,
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                    color: const Color(0xFF0F0F1A),
                                                    width: 1.5),
                                              ),
                                              constraints: const BoxConstraints(
                                                minWidth: 16,
                                                minHeight: 16,
                                              ),
                                              child: Text(
                                                count > 99 ? '99+' : count.toString(),
                                                style: const TextStyle(
                                                  color: Colors.white,
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
                                      error: (_, _) => const SizedBox.shrink(),
                                    );
                                  }),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
>>>>>>> Stashed changes
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
                                    color: const Color(0xFF6200EE),
                                    fontSize: 12,
                                    letterSpacing: 2,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'DUTY.',
                                  style: GoogleFonts.outfit(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF6200EE),
                              width: 2,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 20,
                            backgroundImage: NetworkImage(
                              'https://i.pravatar.cc/150?img=12',
                            ), // Mock Profile
                            onBackgroundImageError: (_, __) {},
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
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E2C),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.05),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search, color: Colors.purpleAccent),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Search festivals, artists, or wallets',
                              style: GoogleFonts.inter(
                                color: Colors.white.withOpacity(0.3),
                                fontSize: 14,
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

<<<<<<< Updated upstream
                // Categories
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 80,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      children: [
                        _buildCategoryItem(
                          Icons.account_balance_wallet,
                          'WALLET',
                          true,
                        ),
                        _buildCategoryItem(
                          Icons.confirmation_number,
                          'PASS',
                          false,
                        ),
                        _buildCategoryItem(Icons.bolt, 'DROPS', false),
                        _buildCategoryItem(Icons.more_horiz, 'MORE', false),
                      ],
=======
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
                                  color: const Color(0xFF8655F6),
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
                                  badgeCount: ref.watch(pendingTransfersCountProvider),
                                  onTap: () => context.push('/pending-transfers'),
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
                                  badgeCount: ref.watch(pendingReviewPromptsProvider).valueOrNull?.length ?? 0,
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
                            loading: () => _buildHeroShimmer(),
                            error: (_, _) => const SizedBox(),
                          );
                        }
                        return _buildAdSlider(context, content.advertisements);
                      },
                      loading: () => _buildHeroShimmer(),
                      error: (_, _) => const SizedBox(),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 32)),

                  SliverToBoxAdapter(
                    child: socialFeedAsyncValue.when(
                      data: (feed) => _buildSocialFeedSection(context, feed),
                      loading: () => _buildSocialFeedLoading(),
                      error: (_, _) => const SizedBox.shrink(),
>>>>>>> Stashed changes
                    ),
                  ),
                ),

<<<<<<< Updated upstream
                const SliverToBoxAdapter(child: SizedBox(height: 32)),

                // Trending Title
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Trending Now',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
=======
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
                        children: [
                          Text(
                            'Trending Now',
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
>>>>>>> Stashed changes
                          ),
                        ),
                        Text(
                          'See All',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFF6200EE),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // Trending List (Horizontal)
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 180, // Height for trending cards
                    child: eventsAsyncValue.when(
                      data: (events) {
                        if (events.isEmpty) return const SizedBox();
                        return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 24),
<<<<<<< Updated upstream
                          itemCount: events
                              .take(3)
                              .length, // Take first 3 as trending
                          itemBuilder: (context, index) {
                            return _buildTrendingCard(context, events[index]);
                          },
                        );
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (err, _) => const SizedBox(),
                    ),
                  ),
                ),
=======
                          itemCount: 3,
                          itemBuilder: (context, index) => Shimmer.fromColors(
                            baseColor: const Color(0xFF1E1E2C),
                            highlightColor: const Color(0xFF2A2A3D),
                            child: Container(
                              width: 240,
                              margin: const EdgeInsets.only(right: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                        ),
                        error: (err, _) => const SizedBox(),
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
>>>>>>> Stashed changes

                const SliverToBoxAdapter(child: SizedBox(height: 32)),

                // For You Title
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Text(
                      'For You',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // For You List (Vertical)
                eventsAsyncValue.when(
                  data: (events) {
                    // Skip the first 3 used in trending, or just show all
                    final forYouEvents = events.length > 3
                        ? events.sublist(3)
                        : events;

                    return SliverPadding(
                      padding: const EdgeInsets.fromLTRB(
                        24,
                        0,
                        24,
                        100,
                      ), // Bottom padding for NavBar
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          return _buildForYouCard(context, forYouEvents[index]);
                        }, childCount: forYouEvents.length),
                      ),
                    );
                  },
                  loading: () => const SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: CircularProgressIndicator(),
                      ),
                    ),
<<<<<<< Updated upstream
=======
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 198,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return _buildDiscoveryPreviewCard(context, kind, item);
                  },
                ),
              ),
            ],
          ),
        );
      },
      loading: () => SliverToBoxAdapter(
        child: SizedBox(
          height: 198,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: 3,
            itemBuilder: (context, index) => Shimmer.fromColors(
              baseColor: const Color(0xFF1E1E2C),
              highlightColor: const Color(0xFF2A2A3D),
              child: Container(
                width: 250,
                margin: const EdgeInsets.only(right: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ),
        ),
      ),
      error: (_, _) => const SliverToBoxAdapter(child: SizedBox.shrink()),
    );
  }

  Widget _buildSocialFeedSection(BuildContext context, SocialFeedModel feed) {
    final items = feed.items.take(6).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
        decoration: BoxDecoration(
          color: const Color(0xFF151122),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF8655F6).withValues(alpha: 0.12),
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
>>>>>>> Stashed changes
                  ),
                  error: (err, _) => SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        'Error: $err',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

<<<<<<< Updated upstream
          // Bottom Navigation Bar (Custom Floating)
          Positioned(
            bottom: 24,
            left: 24,
            right: 24,
            child: Container(
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E2C),
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
=======
  Widget _buildSocialFeedCard(BuildContext context, SocialFeedItemModel item) {
    final accent = _sceneReasonColor(item.reasonType);
    final thumbnail = item.thumbnailUrl != null && item.thumbnailUrl!.isNotEmpty
        ? item.thumbnailUrl!
        : '';

    return GestureDetector(
      onTap: () => context.push('/event-details/${item.eventId}'),
      child: Container(
        width: 286,
        decoration: BoxDecoration(
          color: const Color(0xFF100D1A),
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
                            errorWidget: _buildSocialFeedImageFallback(accent),
                          )
                        : _buildSocialFeedImageFallback(accent),
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
>>>>>>> Stashed changes
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.home, color: Color(0xFF6200EE)),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.explore, color: Colors.grey),
                    onPressed: () {},
                  ),

                  // FAB in middle
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: Color(0xFF6200EE),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF6200EE),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.qr_code_scanner,
                      color: Colors.white,
                    ),
                  ),

                  IconButton(
                    icon: const Icon(
                      Icons.confirmation_number,
                      color: Colors.grey,
                    ),
                    onPressed: () => context.push('/my-tickets'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.person, color: Colors.grey),
                    onPressed: () => context.push('/profile'),
                  ),
                ],
              ),
            ),
<<<<<<< Updated upstream
=======
          ],
        ),
      ),
    );
  }

  Widget _buildSocialFeedEmptyState(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white10),
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
                  color: const Color(0xFF8655F6).withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.hub_rounded, color: Color(0xFFB494FF)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Your social feed wakes up as soon as you build a network.',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
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
              color: Colors.white70,
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
              foregroundColor: Colors.white,
              backgroundColor: const Color(0xFF8655F6).withValues(alpha: 0.22),
            ),
>>>>>>> Stashed changes
          ),
        ],
      ),
    );
  }

<<<<<<< Updated upstream
  Widget _buildCategoryItem(IconData icon, String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF2A1B3D)
                  : const Color(0xFF1E1E2C),
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(16),
              border: isSelected
                  ? Border.all(color: const Color(0xFF6200EE).withOpacity(0.5))
                  : null,
            ),
            child: Icon(
              icon,
              color: isSelected ? const Color(0xFF6200EE) : Colors.grey,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.outfit(
              color: isSelected ? Colors.white : Colors.grey,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
=======
  Widget _buildSocialFeedLoading() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Shimmer.fromColors(
        baseColor: const Color(0xFF1E1E2C),
        highlightColor: const Color(0xFF2A2A3D),
        child: Container(
          height: 298,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
          ),
        ),
      ),
    );
  }

  Widget _buildSceneMetric(
    String value,
    String label, {
    bool highlight = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: highlight
            ? const Color(0xFFFFC14A).withValues(alpha: 0.14)
            : Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: highlight
              ? const Color(0xFFFFC14A).withValues(alpha: 0.28)
              : Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$value ',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
            TextSpan(
              text: label,
              style: GoogleFonts.outfit(
                color: highlight ? const Color(0xFFFFD986) : Colors.white70,
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
    List<SocialFeedPersonModel> people,
    int peopleCount,
  ) {
    if (people.isEmpty || peopleCount <= 0) {
      return Text(
        'From your network',
        style: GoogleFonts.inter(
          color: Colors.white60,
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
                      border: Border.all(
                        color: const Color(0xFF151122),
                        width: 2,
                      ),
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
                              errorWidget: _buildScenePersonFallback(),
                            )
                          : _buildScenePersonFallback(),
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
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScenePersonFallback() {
    return Container(
      color: const Color(0xFF2A243A),
      child: const Icon(Icons.person, color: Colors.white38, size: 12),
    );
  }

  Widget _buildSocialFeedImageFallback(Color accent) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [accent.withValues(alpha: 0.24), const Color(0xFF130F1E)],
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
        return const Color(0xFF8655F6);
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

  String _sceneDateLabel(DateTime date) {
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

  Widget _buildDiscoveryPreviewCard(
    BuildContext context,
    DiscoveryKind kind,
    DiscoveryProfileModel item,
  ) {
    return GestureDetector(
      onTap: () => context.push(kind.profileRoute(item.id)),
      child: Container(
        width: 250,
        margin: const EdgeInsets.only(right: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E2C),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: kind.accentColor.withValues(alpha: 0.18)),
        ),
        child: Row(
          children: [
            _buildDiscoveryAvatar(kind, item.photo),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    item.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.subtitle ??
                        item.location ??
                        _previewFallbackLabel(kind),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      color: Colors.white60,
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _buildMiniCount(
                        '${item.followersCount}',
                        'Followers',
                        kind.accentColor,
                      ),
                      _buildMiniCount(
                        '${item.upcomingEventsCount}',
                        'Upcoming',
                        kind.accentColor,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiscoveryAvatar(DiscoveryKind kind, String? photoUrl) {
    return Container(
      width: 74,
      height: 74,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: kind.accentColor.withValues(alpha: 0.12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: photoUrl != null && photoUrl.isNotEmpty
            ? CachedImage(
                imageUrl: photoUrl,
                width: 74,
                height: 74,
                fit: BoxFit.cover,
                errorWidget: Center(
                  child: Icon(kind.icon, color: Colors.white38, size: 28),
                ),
              )
            : Icon(kind.icon, color: Colors.white38, size: 28),
      ),
    );
  }

  Widget _buildMiniCount(String value, String label, Color accent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$value $label',
        style: GoogleFonts.inter(
          color: Colors.white70,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _previewFallbackLabel(DiscoveryKind kind) {
    switch (kind) {
      case DiscoveryKind.artists:
        return 'Artist profile';
      case DiscoveryKind.organizers:
        return 'Organizer profile';
      case DiscoveryKind.venues:
        return 'Venue profile';
    }
  }


>>>>>>> Stashed changes

  Widget _buildTrendingCard(BuildContext context, dynamic event) {
    return GestureDetector(
      onTap: () => context.push('/event-details/${event.id}'),
      child: Container(
        width: 240,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          image: DecorationImage(
            image: NetworkImage(event.thumbnail),
            onError: (_, __) {},
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.3),
              BlendMode.darken,
            ),
          ),
        ),
        child: Stack(
          children: [
<<<<<<< Updated upstream
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF6200EE).withOpacity(0.8),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'LIVE DROP',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
=======
            if (event.id % 2 == 0)
              Positioned(
                top: 12,
                left: 12,
                child: _buildStatusBadge('TRENDING', Colors.orangeAccent),
              ),
            if (socialProof != null)
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: _buildCardSocialCue(socialProof),
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
>>>>>>> Stashed changes
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          event.address ?? 'Unknown Location',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'JOIN',
                      style: GoogleFonts.outfit(
                        color: Colors.black,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
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

<<<<<<< Updated upstream
  Widget _buildForYouCard(BuildContext context, dynamic event) {
    return GestureDetector(
      onTap: () => context.push('/event-details/${event.id}'),
      child: Container(
        height: 380,
        margin: const EdgeInsets.only(bottom: 24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          image: DecorationImage(
            image: NetworkImage(event.thumbnail),
            onError: (_, __) {},
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.2),
              BlendMode.darken,
            ),
          ),
        ),
        child: Stack(
          children: [
            // Gradient overlay for text readability
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                    stops: const [0.6, 1.0],
                  ),
                ),
              ),
            ),

            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundImage: NetworkImage(
                          'https://i.pravatar.cc/150?img=5',
                        ), // Mock organizer
                        onBackgroundImageError: (_, __) {},
                      ),
                      const SizedBox(width: 8),
                      Text(
                        event.organizer ?? 'Duty Events',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
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
                  const SizedBox(height: 4),
                  Text(
                    'The biggest event of the year is selling out fast. Get your tickets now!', // Mock description
                    style: GoogleFonts.inter(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.favorite, color: Colors.pinkAccent),
                          const SizedBox(width: 4),
                          Text(
                            '14.2k',
                            style: GoogleFonts.outfit(color: Colors.white),
                          ),
                          const SizedBox(width: 16),
                          const Icon(Icons.comment, color: Colors.white70),
                          const SizedBox(width: 4),
                          Text(
                            '842',
                            style: GoogleFonts.outfit(color: Colors.white),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6200EE), Colors.purpleAccent],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'QUICK BUY',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
=======


  Widget _buildHeroShimmer() {
    return Shimmer.fromColors(
      baseColor: const Color(0xFF1E1E2C),
      highlightColor: const Color(0xFF2A2A3D),
      child: Container(
        height: 400,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
>>>>>>> Stashed changes
        ),
      ),
    );
  }
<<<<<<< Updated upstream
=======

  Widget _buildStatusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: GoogleFonts.outfit(
          color: Colors.white,
          fontSize: 8,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
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
    SocialFeedItemModel item, {
    bool compact = false,
    bool elevated = false,
  }) {
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
                color: Colors.white,
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
>>>>>>> Stashed changes
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
                        color: const Color(0xFFFF3B30),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF0D0812), // Match dark background
                          width: 2,
                        ),
                      ),
                      child: Text(
                        badgeCount > 99 ? '99+' : '$badgeCount',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
                color: Colors.white,
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
