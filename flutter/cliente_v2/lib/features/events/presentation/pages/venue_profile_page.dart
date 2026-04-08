import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_urls.dart';
import '../../../../core/theme/colors.dart';
import '../../../chat/presentation/providers/chat_provider.dart';
import '../../../profile/data/repositories/social_repository.dart';
import '../../data/models/event_model.dart';
import '../../data/models/venue_model.dart';
import '../providers/venue_provider.dart';

class VenueProfilePage extends ConsumerWidget {
  final int venueId;

  const VenueProfilePage({super.key, required this.venueId});

  static const Color _background = kBackgroundDark;
  static const Color _surface = kSurfaceColor;
  static const Color _surfaceAlt = Color(0xFF211922);
  static const Color _accent = kInfoColor;
  static const Color _accentSoft = kPrimaryColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(venueProfileProvider(venueId));

    return Scaffold(
      backgroundColor: _background,
      body: profileAsync.when(
        data: (data) {
          final venue = data['venue'] as VenueModel;
          final upcomingEvents = data['events'] as List<EventModel>;
          final pastEvents = data['pastEvents'] as List<EventModel>;

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildHeader(context, venue),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeroSection(
                      context,
                      ref,
                      venue,
                      upcomingEvents.length,
                      pastEvents.length,
                    ),
                    _buildQuickFacts(
                      context,
                      venue,
                      upcomingEvents.length,
                      pastEvents.length,
                    ),
                    _buildAboutSection(venue),
                    _buildConnectSection(venue),
                    _buildCalendarSection(
                      context,
                      title: 'Upcoming at this venue',
                      subtitle: 'What is scheduled next in this space.',
                      events: upcomingEvents,
                      emptyTitle: 'No upcoming events scheduled',
                      emptyBody:
                          'This venue does not have published events right now.',
                    ),
                    _buildCalendarSection(
                      context,
                      title: 'Past events',
                      subtitle: 'A quick look at the venue archive.',
                      events: pastEvents,
                      emptyTitle: 'No archived events yet',
                      emptyBody:
                          'Past events will appear here once the venue builds history.',
                      isPast: true,
                    ),
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () =>
            const Center(child: CircularProgressIndicator(color: _accentSoft)),
        error: (err, stack) => _VenueErrorState(
          message: 'We could not load this venue right now.',
          details: err.toString(),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, VenueModel venue) {
    final palette = context.dutyTheme;
    return SliverAppBar(
      pinned: true,
      stretch: true,
      backgroundColor: _background.withValues(alpha: 0.90),
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: _glassIconButton(
          icon: Icons.arrow_back_ios_new_rounded,
          onTap: () => context.pop(),
        ),
      ),
      centerTitle: true,
      title: Text(
        venue.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.outfit(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: palette.textPrimary,
        ),
      ),
    );
  }

  Widget _buildHeroSection(
    BuildContext context,
    WidgetRef ref,
    VenueModel venue,
    int upcomingCount,
    int pastCount,
  ) {
    final palette = context.dutyTheme;
    final locationSummary = _locationSummary(venue);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Container(
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: palette.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                SizedBox(
                  height: 280,
                  width: double.infinity,
                  child:
                      (venue.coverPhoto ?? venue.image) != null &&
                          (venue.coverPhoto ?? venue.image)!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl:
                              AppUrls.getVenueImageUrl(
                                venue.coverPhoto ?? venue.image,
                              ) ??
                              '',
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: palette.surface.withValues(alpha: 0.82),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: palette.primary,
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                          errorWidget: (_, _, _) => _buildHeroFallback(),
                        )
                      : _buildHeroFallback(),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.20),
                          Colors.black.withValues(alpha: 0.55),
                          _background,
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 18,
                  left: 18,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _HeroPill(
                        icon: Icons.location_city_rounded,
                        label: 'Venue profile',
                        color: _accent,
                      ),
                      if (locationSummary.isNotEmpty)
                        _HeroPill(
                          icon: Icons.place_outlined,
                          label: locationSummary,
                          color: _accentSoft,
                        ),
                    ],
                  ),
                ),
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: 22,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (venue.image != null && venue.image!.isNotEmpty) ...[
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: palette.textPrimary.withValues(
                                alpha: 0.82,
                              ),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.22),
                                blurRadius: 18,
                                offset: const Offset(0, 8),
                              ),
                            ],
                            image: DecorationImage(
                              image: CachedNetworkImageProvider(
                                AppUrls.getVenueImageUrl(venue.image) ?? '',
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      Text(
                        venue.name,
                        style: GoogleFonts.outfit(
                          color: palette.textPrimary,
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          height: 0.98,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _InfoChip(
                            icon: Icons.people_alt_outlined,
                            label: '${venue.followersCount} followers',
                          ),
                          _InfoChip(
                            icon: Icons.event_available_rounded,
                            label: '$upcomingCount upcoming',
                          ),
                          _InfoChip(
                            icon: Icons.history_rounded,
                            label: '$pastCount archived',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    locationSummary.isNotEmpty
                        ? locationSummary
                        : 'A public venue profile inside Duty.',
                    style: GoogleFonts.inter(
                      color: palette.textMuted,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(child: _BuildVenueFollowButton(venue: venue)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final chat = await ref
                                .read(chatActionProvider.notifier)
                                .startChat(
                                  targetId: venue.id,
                                  targetType: 'venue',
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
                                        'Could not open contact for this venue.',
                                  ),
                                  backgroundColor: kDangerColor,
                                ),
                              );
                            }
                          },
                          icon: const Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: 18,
                          ),
                          label: const Text('Contact'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: palette.textPrimary,
                            side: BorderSide(
                              color: _accent.withValues(alpha: 0.40),
                            ),
                            backgroundColor: palette.surface.withValues(
                              alpha: 0.02,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
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

  Widget _buildQuickFacts(
    BuildContext context,
    VenueModel venue,
    int upcomingCount,
    int pastCount,
  ) {
    final palette = context.dutyTheme;
    final mapsAvailable =
        venue.latitude != null ||
        venue.longitude != null ||
        (venue.address?.trim().isNotEmpty ?? false);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Scene snapshot',
            style: GoogleFonts.outfit(
              color: palette.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _SnapshotCard(
                  icon: Icons.event_seat_rounded,
                  label: 'Upcoming',
                  value: '$upcomingCount',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SnapshotCard(
                  icon: Icons.collections_bookmark_outlined,
                  label: 'Archive',
                  value: '$pastCount',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SnapshotCard(
                  icon: mapsAvailable
                      ? Icons.near_me_rounded
                      : Icons.place_outlined,
                  label: mapsAvailable ? 'Mapped' : 'Address',
                  value: mapsAvailable ? 'Ready' : 'Manual',
                  accent: mapsAvailable ? _accent : _accentSoft,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: _surfaceAlt,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: palette.border),
            ),
            child: Column(
              children: [
                _FactRow(
                  icon: Icons.place_outlined,
                  title: 'Address',
                  value:
                      [
                        if ((venue.address ?? '').trim().isNotEmpty)
                          venue.address!.trim(),
                        if ((venue.city ?? '').trim().isNotEmpty)
                          venue.city!.trim(),
                        if ((venue.state ?? '').trim().isNotEmpty)
                          venue.state!.trim(),
                        if ((venue.country ?? '').trim().isNotEmpty)
                          venue.country!.trim(),
                      ].join(', ').isNotEmpty
                      ? [
                          if ((venue.address ?? '').trim().isNotEmpty)
                            venue.address!.trim(),
                          if ((venue.city ?? '').trim().isNotEmpty)
                            venue.city!.trim(),
                          if ((venue.state ?? '').trim().isNotEmpty)
                            venue.state!.trim(),
                          if ((venue.country ?? '').trim().isNotEmpty)
                            venue.country!.trim(),
                        ].join(', ')
                      : 'No public address yet',
                ),
                const SizedBox(height: 14),
                _FactRow(
                  icon: Icons.verified_rounded,
                  title: 'Profile status',
                  value: venue.status == 1
                      ? 'Active venue'
                      : 'Status $venue.status',
                ),
                const SizedBox(height: 14),
                _FactRow(
                  icon: Icons.route_outlined,
                  title: 'Open in maps',
                  value: mapsAvailable
                      ? 'Launch directions from your phone'
                      : 'Location data not available yet',
                  trailing: mapsAvailable
                      ? TextButton(
                          onPressed: () => _openInMaps(venue),
                          child: const Text('Open'),
                        )
                      : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection(VenueModel venue) {
    final description = (venue.description ?? '').trim().isNotEmpty
        ? venue.description!.trim()
        : 'This venue profile is live on Duty. Explore the space, follow it, and keep an eye on what is happening there next.';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'About this venue',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: GoogleFonts.inter(
                color: Colors.white70,
                fontSize: 14,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectSection(VenueModel venue) {
    final links = <_VenueLinkAction>[
      if ((venue.whatsapp ?? '').trim().isNotEmpty)
        _VenueLinkAction(
          icon: Icons.phone_in_talk_rounded,
          label: 'WhatsApp',
          accent: const Color(0xFF25D366),
          onTap: () => _openWhatsApp(venue.whatsapp!),
        ),
      if ((venue.instagram ?? '').trim().isNotEmpty)
        _VenueLinkAction(
          icon: Icons.camera_alt_outlined,
          label: 'Instagram',
          accent: const Color(0xFFE1306C),
          onTap: () => _openExternalLink(
            _normalizeSocialUrl(venue.instagram!, 'instagram'),
          ),
        ),
      if ((venue.facebook ?? '').trim().isNotEmpty)
        _VenueLinkAction(
          icon: Icons.facebook_rounded,
          label: 'Facebook',
          accent: const Color(0xFF1877F2),
          onTap: () => _openExternalLink(
            _normalizeSocialUrl(venue.facebook!, 'facebook'),
          ),
        ),
      if ((venue.tiktok ?? '').trim().isNotEmpty)
        _VenueLinkAction(
          icon: Icons.music_note_rounded,
          label: 'TikTok',
          accent: Colors.white,
          onTap: () =>
              _openExternalLink(_normalizeSocialUrl(venue.tiktok!, 'tiktok')),
        ),
    ];

    if (links.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Connect with this venue',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Chat in Duty stays as the main contact channel. These public links help people discover the venue faster.',
              style: GoogleFonts.inter(
                color: Colors.white60,
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: links.map((item) {
                return InkWell(
                  onTap: item.onTap,
                  borderRadius: BorderRadius.circular(18),
                  child: Ink(
                    width: 150,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: _surfaceAlt,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: item.accent.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: item.accent.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(item.icon, color: item.accent, size: 19),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            item.label,
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarSection(
    BuildContext context, {
    required String title,
    required String subtitle,
    required List<EventModel> events,
    required String emptyTitle,
    required String emptyBody,
    bool isPast = false,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        color: Colors.white54,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: Colors.white10),
                ),
                child: Text(
                  '${events.length}',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (events.isEmpty)
            _VenueEmptyCard(title: emptyTitle, body: emptyBody)
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: events.length,
              separatorBuilder: (_, _) => const SizedBox(height: 14),
              itemBuilder: (context, index) =>
                  _buildEventCard(context, events[index], isPast: isPast),
            ),
        ],
      ),
    );
  }

  Widget _buildEventCard(
    BuildContext context,
    EventModel event, {
    bool isPast = false,
  }) {
    final location = (event.address ?? '').trim();
    final schedule = [
      if ((event.date ?? '').trim().isNotEmpty) event.date!.trim(),
      if ((event.time ?? '').trim().isNotEmpty) event.time!.trim(),
    ].join(' • ');

    return GestureDetector(
      onTap: () => context.push('/event-details/${event.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                SizedBox(
                  height: 168,
                  width: double.infinity,
                  child: CachedNetworkImage(
                    imageUrl:
                        AppUrls.getEventThumbnailUrl(event.thumbnail) ?? '',
                    fit: BoxFit.cover,
                    errorWidget: (_, _, _) => Container(
                      color: Colors.white10,
                      child: const Center(
                        child: Icon(
                          Icons.image_outlined,
                          color: Colors.white24,
                          size: 34,
                        ),
                      ),
                    ),
                    placeholder: (context, url) => Container(
                      color: Colors.white10,
                      child: const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: _accentSoft,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.55),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: _background.withValues(alpha: 0.84),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Text(
                      _priceLabel(event, isPast: isPast),
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (schedule.isNotEmpty)
                    _EventMetaRow(
                      icon: Icons.calendar_today_rounded,
                      label: schedule,
                    ),
                  if (location.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _EventMetaRow(icon: Icons.place_outlined, label: location),
                  ],
                  if ((event.organizer ?? '').trim().isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _EventMetaRow(
                      icon: Icons.campaign_outlined,
                      label: event.organizer!.trim(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroFallback() {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_accent, _accentSoft, _background],
        ),
      ),
      child: Center(
        child: Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.10),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white24),
          ),
          child: const Icon(
            Icons.location_city_rounded,
            color: Colors.white,
            size: 42,
          ),
        ),
      ),
    );
  }

  String _locationSummary(VenueModel venue) {
    return [
      if ((venue.city ?? '').trim().isNotEmpty) venue.city!.trim(),
      if ((venue.state ?? '').trim().isNotEmpty) venue.state!.trim(),
      if ((venue.country ?? '').trim().isNotEmpty) venue.country!.trim(),
    ].join(', ');
  }

  String _priceLabel(EventModel event, {required bool isPast}) {
    if (isPast) {
      return 'ARCHIVED';
    }
    final price = event.startPrice?.toString().trim().toLowerCase();
    if (price == null || price.isEmpty) {
      return 'DETAILS';
    }
    if (price == 'free') {
      return 'FREE';
    }
    return '\$${event.startPrice}';
  }

  Future<void> _openInMaps(VenueModel venue) async {
    final query = venue.latitude != null && venue.longitude != null
        ? '${venue.latitude},${venue.longitude}'
        : [
            if ((venue.address ?? '').trim().isNotEmpty) venue.address!.trim(),
            if ((venue.city ?? '').trim().isNotEmpty) venue.city!.trim(),
            if ((venue.state ?? '').trim().isNotEmpty) venue.state!.trim(),
            if ((venue.country ?? '').trim().isNotEmpty) venue.country!.trim(),
          ].join(', ');

    if (query.isEmpty) {
      return;
    }

    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(query)}',
    );

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _openExternalLink(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      return;
    }

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _openWhatsApp(String rawNumber) async {
    final directNumber = rawNumber.replaceAll(RegExp(r'[^0-9]'), '');
    if (directNumber.isEmpty) {
      return;
    }

    final uri = Uri.parse('https://wa.me/$directNumber');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  String _normalizeSocialUrl(String value, String kind) {
    final trimmed = value.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }

    final clean = trimmed.startsWith('@') ? trimmed.substring(1) : trimmed;
    switch (kind) {
      case 'instagram':
        return 'https://instagram.com/$clean';
      case 'facebook':
        return 'https://facebook.com/$clean';
      case 'tiktok':
        return clean.startsWith('www.') || clean.contains('tiktok.com/')
            ? 'https://$clean'
            : 'https://www.tiktok.com/@$clean';
      default:
        return trimmed;
    }
  }

  Widget _glassIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.10),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}

class _VenueLinkAction {
  final IconData icon;
  final String label;
  final Color accent;
  final VoidCallback onTap;

  const _VenueLinkAction({
    required this.icon,
    required this.label,
    required this.accent,
    required this.onTap,
  });
}

class _BuildVenueFollowButton extends ConsumerWidget {
  final VenueModel venue;

  const _BuildVenueFollowButton({required this.venue});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (venue.isFollowing) {
      return ElevatedButton(
        onPressed: () async {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: kSurfaceColor,
              title: Text(
                'Unfollow venue?',
                style: GoogleFonts.outfit(color: Colors.white),
              ),
              content: Text(
                'You will stop receiving updates from this venue in your scene.',
                style: GoogleFonts.inter(color: Colors.white70),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.inter(color: Colors.white54),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(
                    'Unfollow',
                    style: GoogleFonts.inter(color: kDangerColor),
                  ),
                ),
              ],
            ),
          );

          if (confirm != true) return;

          final success = await ref
              .read(followActionProvider.notifier)
              .unfollow('venue', venue.id);
          if (success) {
            ref.invalidate(venueProfileProvider(venue.id));
          } else {
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to unfollow venue')),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white12,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(vertical: 15),
        ),
        child: const Text('Following'),
      );
    }

    return ElevatedButton(
      onPressed: () async {
        final success = await ref
            .read(followActionProvider.notifier)
            .follow('venue', venue.id);
        if (success != null && success['success'] == true) {
          ref.invalidate(venueProfileProvider(venue.id));
        } else {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to follow venue')),
          );
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: kInfoColor,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(vertical: 15),
      ),
      child: const Text('Follow venue'),
    );
  }
}

class _HeroPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _HeroPill({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.dutyTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.34),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: palette.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.outfit(
              color: palette.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final palette = context.dutyTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: palette.surface.withValues(alpha: 0.84),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: palette.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: palette.textMuted, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              color: palette.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SnapshotCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color accent;

  const _SnapshotCard({
    required this.icon,
    required this.label,
    required this.value,
    this.accent = VenueProfilePage._accentSoft,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.dutyTheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: VenueProfilePage._surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: accent, size: 18),
          const SizedBox(height: 18),
          Text(
            value,
            style: GoogleFonts.outfit(
              color: palette.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              color: palette.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _FactRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Widget? trailing;

  const _FactRow({
    required this.icon,
    required this.title,
    required this.value,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.dutyTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: palette.surface.withValues(alpha: 0.84),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: VenueProfilePage._accent, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.outfit(
                  color: palette.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.inter(
                  color: palette.textMuted,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        if (trailing != null) ...[const SizedBox(width: 12), trailing!],
      ],
    );
  }
}

class _EventMetaRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _EventMetaRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final palette = context.dutyTheme;
    return Row(
      children: [
        Icon(icon, size: 14, color: VenueProfilePage._accent),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.inter(color: palette.textMuted, fontSize: 13),
          ),
        ),
      ],
    );
  }
}

class _VenueEmptyCard extends StatelessWidget {
  final String title;
  final String body;

  const _VenueEmptyCard({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    final palette = context.dutyTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: VenueProfilePage._surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        children: [
          Icon(
            Icons.calendar_month_outlined,
            size: 40,
            color: palette.textSecondary,
          ),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              color: palette.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              color: palette.textMuted,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _VenueErrorState extends StatelessWidget {
  final String message;
  final String details;

  const _VenueErrorState({required this.message, required this.details});

  @override
  Widget build(BuildContext context) {
    final palette = context.dutyTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_off_outlined,
              color: palette.textSecondary,
              size: 52,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                color: palette.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              details,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: palette.textSecondary,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
