import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/constants/app_urls.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/widgets/cached_image.dart';
import '../providers/organizer_provider.dart';
import '../../../chat/presentation/providers/chat_provider.dart';
import '../../data/models/organizer_model.dart';
import '../../data/models/event_model.dart';

class OrganizerProfilePage extends ConsumerWidget {
  final int organizerId;

  const OrganizerProfilePage({super.key, required this.organizerId});

  @override
  ConsumerState<OrganizerProfilePage> createState() =>
      _OrganizerProfilePageState();
}

class _OrganizerProfilePageState extends ConsumerState<OrganizerProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.dutyTheme;
    final profileAsync = ref.watch(
      organizerProfileProvider(widget.organizerId),
    );

    return Scaffold(
      backgroundColor: kBackgroundDark, // background-dark
      body: profileAsync.when(
        data: (data) {
          final organizer = data['organizer'] as OrganizerModel;
          final events = data['events'] as List<EventModel>;

          return CustomScrollView(
            slivers: [
              _buildHeader(context, organizer),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    _buildHeroSection(organizer),
                    _buildCTAButtons(context, ref, organizer),
                    _buildMetricsGrid(organizer, events.length),
                    _buildAboutSection(organizer),
                    _buildUpcomingShows(context, events),
                  ],
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: kPrimaryColor),
        ),
        error: (err, stack) => Center(
          child: Text(
            'Error: $err',
            style: TextStyle(color: palette.textPrimary),
          ),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, OrganizerModel organizer) {
    final palette = context.dutyTheme;
    return SliverAppBar(
      pinned: true,
      stretch: true,
      backgroundColor: kBackgroundDark,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: palette.surface.withValues(alpha: 0.78),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.arrow_back, color: palette.textPrimary, size: 20),
        ),
        onPressed: () => context.pop(),
      ),
      centerTitle: true,
      title: const SizedBox.shrink(),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: palette.surface.withValues(alpha: 0.78),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.share, color: palette.textPrimary, size: 20),
          ),
          onPressed: () {
            SharePlus.instance.share(
              ShareParams(
                text:
                    'Check out ${organizer.name} on Duty! https://duty.do/organizer/${organizer.username ?? organizer.id}',
              ),
            );
          },
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [
          StretchMode.zoomBackground,
          StretchMode.blurBackground,
        ],
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (organizer.coverPhoto != null)
              CachedNetworkImage(
                imageUrl:
                    AppUrls.getOrganizerCoverImageUrl(organizer.coverPhoto) ??
                    '',
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF211922), kBackgroundDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF211922), kBackgroundDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.image_not_supported,
                      color: Colors.white10,
                      size: 40,
                    ),
                  ),
                ),
              )
            else
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF211922), kBackgroundDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.2),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.9),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(OrganizerModel organizer) {
    final palette = context.dutyTheme;
    final avatarUrl = AppUrls.getAvatarUrl(organizer.photo, isOrganizer: true);
    return SliverToBoxAdapter(
      child: Transform.translate(
        offset: const Offset(0, -40),
        child: Column(
          children: [
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: kBackgroundDark, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.5),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: avatarUrl != null
                        ? CachedImage(
                            imageUrl: avatarUrl,
                            fit: BoxFit.cover,
                            errorWidget: Container(
                              color: Colors.white.withValues(alpha: 0.04),
                              child: const Icon(
                                Icons.person,
                                size: 50,
                                color: Colors.white24,
                              ),
                            ),
                          )
                        : const Icon(
                            Icons.person,
                            size: 50,
                            color: Colors.white24,
                          ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFD700),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.verified,
                      size: 14,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              organizer.name,
              style: GoogleFonts.splineSans(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: palette.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            if (organizer.username != null &&
                organizer.username!.isNotEmpty) ...[
              Text(
                '@${organizer.username}',
                style: GoogleFonts.splineSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: kPrimaryColor,
                ),
              ),
              const SizedBox(height: 6),
            ],
            Text(
              organizer.designation ?? 'Event Organizer',
              style: GoogleFonts.splineSans(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: kPrimaryColor,
                letterSpacing: 1.1,
              ),
            ),
            if (organizer.location != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: palette.surface.withValues(alpha: 0.72),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: kPrimaryColor.withValues(alpha: 0.15),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.place_outlined,
                      size: 16,
                      color: palette.textMuted,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      organizer.location!,
                      style: GoogleFonts.splineSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: palette.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            _buildCTAButtons(context, ref, organizer),
          ],
        ),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 128,
                height: 128,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF8F0DF2).withOpacity(0.2),
                    width: 4,
                  ),
                  image: organizer.photo != null
                      ? DecorationImage(
                          image: NetworkImage(organizer.photo!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: organizer.photo == null
                    ? const Icon(
                        Icons.business,
                        color: Colors.white54,
                        size: 64,
                      )
                    : null,
              ),
              Positioned(
                bottom: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD700), // accent-gold
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF0D0812),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.verified,
                    size: 14,
                    color: Color(0xFF0D0812),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            organizer.name,
            style: GoogleFonts.splineSans(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            organizer.designation ?? 'Event Organizer',
            style: GoogleFonts.splineSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF8F0DF2),
              letterSpacing: 1.2,
            ),
          ),
          if (organizer.location != null) ...[
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.location_on, size: 14, color: Colors.white54),
                const SizedBox(width: 4),
                Text(
                  organizer.location!,
                  style: GoogleFonts.splineSans(
                    fontSize: 12,
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCTAButtons(
    BuildContext context,
    WidgetRef ref,
    OrganizerModel organizer,
  ) {
    final palette = context.dutyTheme;
    final followState = ref.watch(followActionProvider);
    final isFollowed = organizer.isFollowed;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: !canFollow || followState.isLoading
                      ? null
                      : () async {
                          await ref
                              .read(followActionProvider.notifier)
                              .toggleFollow(
                                organizer.id,
                                socialTargetId,
                                isFollowed,
                              );

                          if (context.mounted && followState.hasError) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  followState.error.toString(),
                                  style: TextStyle(color: palette.onPrimary),
                                ),
                                backgroundColor: kDangerColor,
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isFollowed
                        ? palette.surface.withValues(alpha: 0.82)
                        : kPrimaryColor,
                    foregroundColor: isFollowed
                        ? palette.textMuted
                        : palette.onPrimary,
                    minimumSize: const Size(0, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: isFollowed
                          ? BorderSide(
                              color: kPrimaryColor.withValues(alpha: 0.3),
                            )
                          : BorderSide.none,
                    ),
                    elevation: isFollowed ? 0 : 4,
                    shadowColor: kPrimaryColor.withValues(alpha: 0.2),
                  ),
                  child: followState.isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: isFollowed
                                ? palette.textMuted
                                : palette.onPrimary,
                          ),

                        )
                      : Text(
                          isFollowed ? 'Following' : 'Follow',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: !canContact
                      ? null
                      : () async {
                          final chat = await ref
                              .read(chatActionProvider.notifier)
                              .startChat(
                                targetId: socialTargetId,
                                targetType: 'organizer',
                              );

                          if (chat != null && context.mounted) {
                            context.push('/chat-room', extra: chat);
                          } else if (context.mounted) {
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
                          }
                        },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: palette.surfaceAlt,
                    foregroundColor: palette.textPrimary,
                    minimumSize: const Size(0, 48),
                    side: BorderSide(
                      color: kPrimaryColor.withValues(alpha: 0.2),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: ref.watch(chatActionProvider).isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: palette.textPrimary,
                          ),
                        )
                      : Text(
                          canContact ? 'Message' : 'Contact unavailable',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
          if (organizer.website != null && organizer.website!.isNotEmpty) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _openExternalLink(
                  _normalizeSocialUrl(organizer.website!, 'website'),
                ),
                style: OutlinedButton.styleFrom(
                  backgroundColor: palette.surface.withValues(alpha: 0.68),
                  foregroundColor: palette.textMuted,
                  minimumSize: const Size(0, 44),
                  side: BorderSide(color: palette.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.language_rounded, size: 18),
                label: const Text(
                  'Visit website',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAboutSection(OrganizerModel organizer) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMetricsGrid(organizer),
            const SizedBox(height: 24),
            _buildSnapshotSection(organizer),
            const SizedBox(height: 24),
            Text(
              'About',
              style: GoogleFonts.splineSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              organizer.details ?? 'No description available.',
              style: GoogleFonts.splineSans(
                fontSize: 14,
                color: Colors.white70,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                if (organizer.location != null)
                  _buildInfoPill(Icons.public_rounded, organizer.location!),
                if (organizer.website != null && organizer.website!.isNotEmpty)
                  _buildInfoPill(Icons.language_rounded, 'Website available'),
                if (organizer.supportsContact)
                  _buildInfoPill(
                    Icons.chat_bubble_outline_rounded,
                    'Chat on Duty',
                  ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Connect with this organizer',
              style: GoogleFonts.splineSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 14,
              runSpacing: 14,
              children: [
                if (organizer.website != null && organizer.website!.isNotEmpty)
                  _buildSocialButton(
                    Icons.language_rounded,
                    _normalizeSocialUrl(organizer.website!, 'website'),
                    const Color(0xFF00BCD4),
                  ),
                if (organizer.instagram != null &&
                    organizer.instagram!.isNotEmpty)
                  _buildSocialButton(
                    Icons.camera_alt_outlined,
                    _normalizeSocialUrl(organizer.instagram!, 'instagram'),
                    const Color(0xFFE1306C),
                  ),
                if (organizer.facebook != null &&
                    organizer.facebook!.isNotEmpty)
                  _buildSocialButton(
                    Icons.facebook,
                    _normalizeSocialUrl(organizer.facebook!, 'facebook'),
                    const Color(0xFF1877F2),
                  ),
                if (organizer.tiktok != null && organizer.tiktok!.isNotEmpty)
                  _buildSocialButton(
                    Icons.music_note_rounded,
                    _normalizeSocialUrl(organizer.tiktok!, 'tiktok'),
                    const Color(0xFF00F2EA),
                  ),
                if (organizer.twitter != null && organizer.twitter!.isNotEmpty)
                  _buildSocialButton(
                    Icons.alternate_email_rounded,
                    _normalizeSocialUrl(organizer.twitter!, 'twitter'),
                    const Color(0xFF1DA1F2),
                  ),
                if (organizer.linkedin != null &&
                    organizer.linkedin!.isNotEmpty)
                  _buildSocialButton(
                    Icons.business_center_outlined,
                    _normalizeSocialUrl(organizer.linkedin!, 'linkedin'),
                    const Color(0xFF0077B5),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoPill(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF211922),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kPrimaryColor.withValues(alpha: 0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white70),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.splineSans(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSnapshotSection(OrganizerModel organizer) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF211922),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kPrimaryColor.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Organizer Snapshot',
            style: GoogleFonts.splineSans(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            organizer.details?.trim().isNotEmpty == true
                ? organizer.details!
                : 'Builds lineups, curates nights and manages live experiences through Duty.',
            style: GoogleFonts.splineSans(
              color: Colors.white70,
              fontSize: 13,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              if (organizer.location != null)
                _buildInfoPill(Icons.place_outlined, organizer.location!),
              if ((organizer.eventsCount ?? 0) > 0)
                _buildInfoPill(
                  Icons.event_available_outlined,
                  '${organizer.eventsCount} active events',
                ),
              if (organizer.website != null && organizer.website!.isNotEmpty)
                _buildInfoPill(Icons.language_rounded, 'Website ready'),
              if (organizer.supportsContact)
                _buildInfoPill(
                  Icons.chat_bubble_outline_rounded,
                  'Chat on Duty',
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    final palette = context.dutyTheme;
    return SliverPersistentHeader(
      pinned: true,
      delegate: _SliverAppBarDelegate(
        TabBar(
          controller: _tabController,
          indicatorColor: kPrimaryColor,
          indicatorSize: TabBarIndicatorSize.label,
          labelColor: kPrimaryColor,
          unselectedLabelColor: palette.textSecondary,
          labelStyle: GoogleFonts.splineSans(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Past'),
          ],
        ),
      ),
    );
  }

  Widget _buildEventsTab(
    BuildContext context,
    WidgetRef ref,
    OrganizerModel organizer,
    List<EventModel> events, {
    required bool isPast,
  }) {
    if (events.isEmpty) {
      return SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 200,
              child: Center(
                child: Text(
                  isPast ? 'No past events' : 'No upcoming events',
                  style: TextStyle(color: context.dutyTheme.textSecondary),
                ),
              ),
            ),
            _buildReviewsTab(context, ref, organizer),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildMetricItem(eventsCount.toString(), 'Events'),
          const SizedBox(width: 12),
          _buildMetricItem(_formatCount(organizer.followersCount), 'Followers'),
          const SizedBox(width: 12),
          _buildMetricItem('4.9', 'Rating', isRating: true),
        ],
      ),
    );
  }

  Widget _buildReviewsTab(
    BuildContext context,
    WidgetRef ref,
    OrganizerModel organizer,
  ) {
    return SingleChildScrollView(
      child: _buildReviewsSection(context, ref, organizer),
    );
  }

  Widget _buildSocialButton(IconData icon, String? url, Color color) {
    bool isAvailable = url != null && url.isNotEmpty;
    return InkWell(
      onTap: isAvailable ? () => _openExternalLink(url) : null,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: isAvailable ? 0.1 : 0.05),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: isAvailable ? 0.2 : 0.05),
          ),
        ),
        child: Icon(
          icon,
          color: isAvailable ? Colors.white : Colors.white10,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildMetricsGrid(OrganizerModel organizer) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        SizedBox(
          width: 160,
          child: _buildMetricItem(
            organizer.followersCount.toString(),
            'Followers',
          ),
        ),
        SizedBox(
          width: 160,
          child: _buildMetricItem(
            (organizer.eventsCount ?? 0).toString(),
            'Events',
          ),
        ),
        SizedBox(
          width: 160,
          child: _buildMetricItem(
            organizer.averageRating.toStringAsFixed(1),
            'Rating',
            isRating: true,
          ),
        ),
        SizedBox(
          width: 160,
          child: _buildMetricItem(organizer.reviewCount.toString(), 'Reviews'),
        ),
      ],
    );
  }

  Widget _buildMetricItem(String value, String label, {bool isRating = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF211922),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: kPrimaryColor.withValues(alpha: 0.05)),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                if (isRating) ...[
                  const SizedBox(width: 4),
                  const Icon(Icons.star, color: Color(0xFFFFD700), size: 14),
                ],
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label.toUpperCase(),
              style: GoogleFonts.splineSans(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.white54,
                letterSpacing: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection(OrganizerModel organizer) {
    if (organizer.details == null || organizer.details!.isEmpty)
      return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About ${organizer.name}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF16111D).withOpacity(0.4),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF8F0DF2).withOpacity(0.05),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  organizer.details!,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.white70,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildSocialIcon(Icons.public),
                    const SizedBox(width: 16),
                    _buildSocialIcon(Icons.alternate_email),
                    const SizedBox(width: 16),
                    _buildSocialIcon(Icons.share),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon) {
    return Icon(
      icon,
      color: const Color(0xFF8F0DF2).withOpacity(0.6),
      size: 20,
    );
  }

  Widget _buildUpcomingShows(BuildContext context, List<EventModel> events) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Upcoming Shows',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          if (events.isEmpty)
            const Center(
              child: Text(
                'No upcoming shows',
                style: TextStyle(color: Colors.white54),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: events.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final event = events[index];
                return _buildUpcomingShowItem(context, event);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildUpcomingShowItem(BuildContext context, EventModel event) {
    // Parse date for visual badge
    String day = '';
    String month = '';
    try {
      if (event.date != null) {
        final date = DateTime.parse(
          event.date!,
        ); // Assuming ISO format or similar
        day = date.day.toString();
        month = _getMonth(date.month);
      }
    } catch (e) {
      day = '??';
      month = '???';
    }

    return GestureDetector(
      onTap: () => context.push('/event-details/${event.id}'),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF211922).withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kPrimaryColor.withValues(alpha: 0.05)),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: AppUrls.getEventThumbnailUrl(event.thumbnail) ?? '',
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  width: 60,
                  height: 60,
                  color: Colors.white10,
                  child: const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: kPrimaryColor,
                    ),
                  ),
                  Text(
                    day,
                    style: const TextStyle(
                      color: Color(0xFF8F0DF2),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${event.address ?? 'Location'} • ${event.time ?? ''}',
                    style: const TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white24),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewsSection(
    BuildContext context,
    WidgetRef ref,
    OrganizerModel organizer,
  ) {
    final reviews = organizer.reviews ?? [];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Reviews (${organizer.reviewCount})',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              if (organizer.supportsReviews &&
                  organizer.legacyOrganizerId != null)
                TextButton.icon(
                  onPressed: () => _showReviewDialog(
                    context,
                    ref,
                    organizer.legacyOrganizerId!,
                  ),
                  icon: const Icon(Icons.rate_review, size: 18),
                  label: const Text('Add Review'),
                  style: TextButton.styleFrom(foregroundColor: kPrimaryColor),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (reviews.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF211922).withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: kPrimaryColor.withValues(alpha: 0.05),
                ),
              ),
              child: const Column(
                children: [
                  Icon(Icons.star_border, color: Colors.white24, size: 48),
                  SizedBox(height: 8),
                  Text(
                    'No reviews yet. Be the first to rate!',
                    style: TextStyle(color: Colors.white54, fontSize: 13),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: reviews.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final review = reviews[index];
                return _buildReviewItem(review);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildReviewItem(dynamic review) {
    final customerPhoto = AppUrls.getAvatarUrl(review.customerPhoto);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF211922).withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kPrimaryColor.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: kPrimaryColor.withValues(alpha: 0.2),
                child: customerPhoto != null
                    ? ClipOval(
                        child: CachedImage(
                          imageUrl: customerPhoto,
                          width: 32,
                          height: 32,
                          fit: BoxFit.cover,
                          errorWidget: Container(
                            width: 32,
                            height: 32,
                            color: kPrimaryColor.withValues(alpha: 0.2),
                            child: Icon(
                              Icons.person,
                              size: 16,
                              color: context.dutyTheme.textPrimary,
                            ),
                          ),
                        ),
                      )
                    : const Icon(Icons.person, size: 16, color: Colors.white),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.customerName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      _formatDate(review.createdAt),
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < review.rating ? Icons.star : Icons.star_border,
                    color: const Color(0xFFFFD700),
                    size: 14,
                  );
                }),
              ),
            ],
          ),
          if (review.comment != null && review.comment!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              review.comment!,
              style: GoogleFonts.inter(fontSize: 13, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  String _getMonth(int month) {
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
    return months[month - 1];
  }

  Future<void> _openExternalLink(String? url) async {
    if (url == null || url.trim().isEmpty) {
      return;
    }

    final uri = Uri.tryParse(url);
    if (uri == null) {
      return;
    }

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  String _normalizeSocialUrl(String value, String kind) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return trimmed;
    }

    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }

    final clean = trimmed.startsWith('@') ? trimmed.substring(1) : trimmed;
    switch (kind) {
      case 'website':
        return 'https://$clean';
      case 'instagram':
        return 'https://instagram.com/$clean';
      case 'facebook':
        return 'https://facebook.com/$clean';
      case 'tiktok':
        return clean.contains('tiktok.com/')
            ? 'https://$clean'.replaceFirst('https://https://', 'https://')
            : 'https://www.tiktok.com/@$clean';
      case 'twitter':
        return 'https://x.com/$clean';
      case 'linkedin':
        return clean.contains('linkedin.com/')
            ? 'https://$clean'.replaceFirst('https://https://', 'https://')
            : 'https://linkedin.com/in/$clean';
      default:
        return trimmed;
    }
  }

  void _showReviewDialog(BuildContext context, WidgetRef ref, int organizerId) {
    int rating = 5;
    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF211922),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: kPrimaryColor.withValues(alpha: 0.2)),
              ),
              title: const Text(
                'Rate Organizer',
                style: TextStyle(color: Colors.white),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return IconButton(
                          onPressed: () => setState(() => rating = index + 1),
                          icon: Icon(
                            index < rating ? Icons.star : Icons.star_border,
                            color: const Color(0xFFFFD700),
                            size: 32,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: commentController,
                      maxLines: 3,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Share your experience...',
                        hintStyle: const TextStyle(color: Colors.white38),
                        fillColor: Colors.black26,
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.white54),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final notifier = ref.read(reviewActionProvider.notifier);
                    await notifier.submitReview(
                      profileId: widget.organizerId,
                      organizerId: organizerId,
                      rating: rating,
                      comment: commentController.text,
                    );

                    if (context.mounted) {
                      Navigator.pop(context);
                      final state = ref.read(reviewActionProvider);
                      if (state.hasError) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              state.error.toString().replaceAll(
                                'Exception: ',
                                '',
                              ),
                            ),
                            backgroundColor: kDangerColor,
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Review submitted successfully!'),
                            backgroundColor: kSuccessColor,
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                  ),
                  child: const Text('Submit'),
                ),
              ],
            );
          },
        );
      },
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
      color: kBackgroundDark, // background-dark
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
