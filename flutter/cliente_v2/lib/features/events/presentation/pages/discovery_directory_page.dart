import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/colors.dart';
import '../../../../core/widgets/cached_image.dart';
import '../../data/models/discovery_models.dart';
import '../providers/discovery_provider.dart';

class DiscoveryDirectoryPage extends ConsumerStatefulWidget {
  final DiscoveryKind kind;

  const DiscoveryDirectoryPage({super.key, required this.kind});

  @override
  ConsumerState<DiscoveryDirectoryPage> createState() =>
      _DiscoveryDirectoryPageState();
}

class _DiscoveryDirectoryPageState
    extends ConsumerState<DiscoveryDirectoryPage> {
  static const Color _background = kBackgroundDark;
  static const Color _surface = kSurfaceColor;

  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  String _query = '';
  late String _selectedSectionKey;

  @override
  void initState() {
    super.initState();
    _selectedSectionKey = widget.kind.defaultSectionKey;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final request = DiscoveryRequest(kind: widget.kind, query: _query);
    final feedAsync = ref.watch(discoveryFeedProvider(request));
    final accent = widget.kind.accentColor;

    return Scaffold(
      backgroundColor: _background,
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.25,
            colors: [accent.withValues(alpha: 0.18), _background],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: RefreshIndicator(
            color: accent,
            onRefresh: () async {
              ref.invalidate(discoveryFeedProvider(request));
              await ref.read(discoveryFeedProvider(request).future);
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                SliverToBoxAdapter(child: _buildTopBar(context)),
                SliverToBoxAdapter(child: _buildHero(accent)),
                SliverToBoxAdapter(child: _buildSearchBar(accent)),
                SliverToBoxAdapter(
                  child: feedAsync.when(
                    data: (feed) => _buildSectionChips(feed, accent),
                    loading: () => _buildSectionChipsSkeleton(),
                    error: (_, _) => const SizedBox.shrink(),
                  ),
                ),
                feedAsync.when(
                  data: (feed) {
                    final items = feed.section(_selectedSectionKey);
                    return SliverList(
                      delegate: SliverChildListDelegate([
                        const SizedBox(height: 20),
                        _buildSectionHeader(
                          title: _sectionLabel(_selectedSectionKey),
                          actionLabel: '${items.length} profiles',
                        ),
                        const SizedBox(height: 12),
                        if (items.isEmpty)
                          _buildEmptyState()
                        else
                          ...items.map(
                            (item) => _buildProfileCard(context, item),
                          ),
                        const SizedBox(height: 8),
                        _buildSectionHeader(
                          title: 'Upcoming Events',
                          actionLabel: '${feed.upcomingEvents.length} dates',
                        ),
                        const SizedBox(height: 12),
                        if (feed.upcomingEvents.isEmpty)
                          _buildUpcomingEmptyState()
                        else
                          SizedBox(
                            height: 228,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                              itemBuilder: (context, index) =>
                                  _buildUpcomingCard(
                                    context,
                                    feed.upcomingEvents[index],
                                  ),
                              separatorBuilder: (_, _) =>
                                  const SizedBox(width: 16),
                              itemCount: feed.upcomingEvents.length,
                            ),
                          ),
                        const SizedBox(height: 120),
                      ]),
                    );
                  },
                  loading: () => SliverList(
                    delegate: SliverChildListDelegate([
                      const SizedBox(height: 20),
                      _buildSectionHeader(
                        title: _sectionLabel(_selectedSectionKey),
                        actionLabel: 'Loading',
                      ),
                      const SizedBox(height: 12),
                      ...List.generate(3, (_) => _buildProfileSkeleton()),
                      const SizedBox(height: 12),
                      _buildSectionHeader(
                        title: 'Upcoming Events',
                        actionLabel: 'Loading',
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 228,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          itemBuilder: (_, _) => _buildUpcomingSkeleton(),
                          separatorBuilder: (_, _) => const SizedBox(width: 16),
                          itemCount: 3,
                        ),
                      ),
                      const SizedBox(height: 120),
                    ]),
                  ),
                  error: (error, _) => SliverFillRemaining(
                    hasScrollBody: false,
                    child: _buildErrorState(error.toString(), accent),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 24, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              widget.kind.pageTitle,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHero(Color accent) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(widget.kind.icon, color: accent, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    widget.kind.pageTitle.toUpperCase(),
                    style: GoogleFonts.outfit(
                      color: accent,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.kind.pageSubtitle,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 24,
                height: 1.18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(Color accent) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
      child: Container(
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: TextField(
          controller: _searchController,
          style: GoogleFonts.inter(color: Colors.white),
          onChanged: (value) {
            _debounce?.cancel();
            _debounce = Timer(const Duration(milliseconds: 350), () {
              if (!mounted) return;
              setState(() {
                _query = value.trim();
              });
            });
          },
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: widget.kind.searchHint,
            hintStyle: GoogleFonts.inter(
              color: Colors.white.withValues(alpha: 0.3),
            ),
            prefixIcon: Icon(Icons.search_rounded, color: accent),
            suffixIcon: _searchController.text.isEmpty
                ? null
                : IconButton(
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _query = '';
                      });
                    },
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Colors.white38,
                    ),
                  ),
            contentPadding: const EdgeInsets.symmetric(vertical: 15),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionChips(DiscoveryFeedModel feed, Color accent) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: widget.kind.sections.map((section) {
          final selected = section.key == _selectedSectionKey;
          final count = feed.section(section.key).length;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedSectionKey = section.key;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: selected
                    ? accent.withValues(alpha: 0.16)
                    : Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: selected
                      ? accent.withValues(alpha: 0.55)
                      : Colors.white.withValues(alpha: 0.06),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    section.label,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '$count',
                      style: GoogleFonts.inter(
                        color: Colors.white70,
                        fontSize: 11,
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
    );
  }

  Widget _buildSectionChipsSkeleton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: List.generate(
          2,
          (_) => Container(
            width: 116,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(18),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String actionLabel,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            actionLabel,
            style: GoogleFonts.inter(
              color: Colors.white54,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context, DiscoveryProfileModel item) {
    final accent = widget.kind.accentColor;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 14),
      child: GestureDetector(
        onTap: () => context.push(widget.kind.profileRoute(item.id)),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white.withValues(alpha: 0.05),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: item.photo != null && item.photo!.isNotEmpty
                      ? CachedImage(
                          imageUrl: item.photo!,
                          width: 72,
                          height: 72,
                          fit: BoxFit.cover,
                          errorWidget: Center(
                            child: Icon(
                              widget.kind.icon,
                              color: Colors.white24,
                              size: 30,
                            ),
                          ),
                        )
                      : Icon(widget.kind.icon, color: Colors.white24, size: 30),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.name,
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (item.identity?.isVerified == true)
                          Icon(Icons.verified_rounded, color: accent, size: 18),
                      ],
                    ),
                    if ((item.subtitle ?? '').isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        item.subtitle!,
                        style: GoogleFonts.inter(
                          color: Colors.white60,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                    if ((item.details ?? '').isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        item.details!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          color: Colors.white70,
                          fontSize: 13,
                          height: 1.35,
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (item.reviewCount > 0)
                          _buildStatPill(
                            '${item.averageRating.toStringAsFixed(1)} ★',
                            '${item.reviewCount} reviews',
                            highlighted: true,
                          ),
                        _buildStatPill('${item.followersCount}', 'Followers'),
                        _buildStatPill(
                          '${item.upcomingEventsCount}',
                          'Upcoming',
                        ),
                        _buildStatPill('${item.totalEventsCount}', 'Catalog'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white.withValues(alpha: 0.35),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatPill(
    String value,
    String label, {
    bool highlighted = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: highlighted
            ? widget.kind.accentColor.withValues(alpha: 0.16)
            : Colors.black.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(14),
      ),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$value ',
              style: GoogleFonts.outfit(
                color: highlighted ? widget.kind.accentColor : Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            TextSpan(
              text: label,
              style: GoogleFonts.inter(
                color: Colors.white54,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingCard(BuildContext context, DiscoveryEventModel event) {
    final formattedDate = event.startsAt != null
        ? DateFormat('MMM d').format(event.startsAt!)
        : 'Soon';

    return GestureDetector(
      onTap: () => context.push('/event-details/${event.id}'),
      child: Container(
        width: 272,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: Colors.white.withValues(alpha: 0.05),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                child: event.thumbnail != null
                    ? CachedNetworkImage(
                        imageUrl: event.thumbnail!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      )
                    : Container(
                        color: Colors.white.withValues(alpha: 0.04),
                        child: Center(
                          child: Icon(
                            Icons.event_rounded,
                            color: Colors.white.withValues(alpha: 0.2),
                            size: 42,
                          ),
                        ),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${event.subject.name} · $formattedDate',
                    style: GoogleFonts.inter(
                      color: Colors.white60,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
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

  Widget _buildProfileSkeleton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 14),
      child: Container(
        height: 128,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(24),
        ),
      ),
    );
  }

  Widget _buildUpcomingSkeleton() {
    return Container(
      width: 272,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(24),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            Icon(
              Icons.travel_explore_rounded,
              color: Colors.white.withValues(alpha: 0.22),
              size: 38,
            ),
            const SizedBox(height: 12),
            Text(
              'No profiles found for this filter.',
              style: GoogleFonts.outfit(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingEmptyState() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          'No upcoming events in this directory yet.',
          style: GoogleFonts.inter(color: Colors.white60),
        ),
      ),
    );
  }

  Widget _buildErrorState(String message, Color accent) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded, color: accent, size: 42),
          const SizedBox(height: 16),
          Text(
            'Could not load ${widget.kind.pageTitle.toLowerCase()} right now.',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(color: Colors.white54),
          ),
          const SizedBox(height: 18),
          ElevatedButton(
            onPressed: () {
              ref.invalidate(
                discoveryFeedProvider(
                  DiscoveryRequest(kind: widget.kind, query: _query),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: accent,
              foregroundColor: Colors.white,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  String _sectionLabel(String key) {
    for (final section in widget.kind.sections) {
      if (section.key == key) {
        return section.label;
      }
    }
    return key;
  }
}
