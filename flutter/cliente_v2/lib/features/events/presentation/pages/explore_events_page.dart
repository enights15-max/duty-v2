import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/cupertino.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/constants/app_urls.dart';
import '../../../../core/widgets/cached_image.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/home_provider.dart';
import '../../data/models/event_model.dart';

final isExploreGridViewProvider = StateProvider<bool>((ref) => true);
final exploreSearchQueryProvider = StateProvider<String>((ref) => '');
final explorePriceFilterProvider = StateProvider<String>(
  (ref) => 'All',
); // All, Free, Paid

final filteredExploreEventsProvider = Provider<AsyncValue<List<EventModel>>>((
  ref,
) {
  final eventsAsync = ref.watch(homeEventsProvider);
  final query = ref.watch(exploreSearchQueryProvider).toLowerCase().trim();
  final priceFilter = ref.watch(explorePriceFilterProvider);

  return eventsAsync.whenData((events) {
    return events.where((event) {
      // Search matching
      final matchTitle = event.title.toLowerCase().contains(query);
      final matchOrg = event.organizer?.toLowerCase().contains(query) ?? false;
      final matchVenue = event.address?.toLowerCase().contains(query) ?? false;
      final matchesSearch =
          query.isEmpty || matchTitle || matchOrg || matchVenue;
      if (!matchesSearch) return false;

      // Price matching
      final startPriceStr =
          event.startPrice?.toString().toLowerCase() ?? 'free';
      final isFree =
          startPriceStr == 'free' ||
          startPriceStr == '0' ||
          startPriceStr == '0.0' ||
          startPriceStr == '0.00';
      if (priceFilter == 'Free' && !isFree) return false;
      if (priceFilter == 'Paid' && isFree) return false;

      return true;
    }).toList();
  });
});

class ExploreEventsPage extends ConsumerStatefulWidget {
  const ExploreEventsPage({super.key});

  @override
  ConsumerState<ExploreEventsPage> createState() => _ExploreEventsPageState();
}

class _ExploreEventsPageState extends ConsumerState<ExploreEventsPage> {
  DutyThemeTokens get _palette => context.dutyTheme;
  final Map<int, bool> _waitlistSubscribedOverrides = {};
  final Map<int, int> _waitlistCountOverrides = {};
  final Set<int> _busyWaitlistEvents = <int>{};

  bool _waitlistSubscribed(EventModel event) =>
      _waitlistSubscribedOverrides[event.id] ?? event.viewerWaitlistSubscribed;

  int _waitlistCount(EventModel event) =>
      _waitlistCountOverrides[event.id] ?? event.waitlistCount;

  bool _canWaitlistFromSurface(EventModel event) =>
      event.showWaitlistCta ||
      (event.availabilityState == 'sold_out' && !event.showMarketplaceFallback);

  Future<void> _toggleWaitlist(EventModel event) async {
    if (_busyWaitlistEvents.contains(event.id)) return;

    final apiClient = ref.read(apiClientProvider);
    if (!apiClient.hasToken) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Inicia sesión para unirte a la waitlist y enterarte si reaparecen entradas.',
          ),
        ),
      );
      context.push('/login');
      return;
    }

    final currentValue = _waitlistSubscribed(event);
    final currentCount = _waitlistCount(event);
    final nextValue = !currentValue;
    final optimisticCount = nextValue
        ? currentCount + 1
        : (currentCount > 0 ? currentCount - 1 : 0);

    setState(() {
      _busyWaitlistEvents.add(event.id);
      _waitlistSubscribedOverrides[event.id] = nextValue;
      _waitlistCountOverrides[event.id] = optimisticCount;
    });

    try {
      final response = nextValue
          ? await apiClient.dio.post(AppUrls.eventWaitlist(event.id))
          : await apiClient.dio.delete(AppUrls.eventWaitlist(event.id));

      final payload = response.data;
      final data = payload is Map<String, dynamic>
          ? payload['data']
          : payload is Map
          ? Map<String, dynamic>.from(payload)['data']
          : null;

      if (data is Map) {
        final normalized = Map<String, dynamic>.from(data);
        if (!mounted) return;
        setState(() {
          _waitlistSubscribedOverrides[event.id] =
              normalized['viewer_waitlist_subscribed'] == true;
          _waitlistCountOverrides[event.id] =
              int.tryParse(normalized['waitlist_count']?.toString() ?? '0') ??
              0;
        });
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            response.data is Map && response.data['message'] != null
                ? response.data['message'].toString()
                : nextValue
                ? 'Te avisaremos si reaparecen entradas para este evento.'
                : 'Ya no estás en la waitlist de este evento.',
          ),
        ),
      );
    } on DioException catch (error) {
      final payload = error.response?.data;
      String message = 'No pudimos actualizar la waitlist ahora mismo.';
      if (payload is Map && payload['message'] != null) {
        message = payload['message'].toString();
      }

      if (!mounted) return;
      setState(() {
        _waitlistSubscribedOverrides[event.id] = currentValue;
        _waitlistCountOverrides[event.id] = currentCount;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _waitlistSubscribedOverrides[event.id] = currentValue;
        _waitlistCountOverrides[event.id] = currentCount;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No pudimos actualizar la waitlist ahora mismo.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _busyWaitlistEvents.remove(event.id));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredEventsAsyncValue = ref.watch(filteredExploreEventsProvider);
    final isGrid = ref.watch(isExploreGridViewProvider);
    final currentPriceFilter = ref.watch(explorePriceFilterProvider);
    final palette = _palette;
    final double bottomContentInset =
        MediaQuery.of(context).padding.bottom + 132;

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        backgroundColor: palette.background,
        elevation: 0,
        title: Text(
          'EXPLORE EVENTS',
          style: GoogleFonts.outfit(
            color: palette.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.6,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.grid_view_rounded,
              color: isGrid ? palette.primary : palette.textMuted,
            ),
            onPressed: () =>
                ref.read(isExploreGridViewProvider.notifier).state = true,
          ),
          IconButton(
            icon: Icon(
              Icons.view_list_rounded,
              color: !isGrid ? palette.primary : palette.textMuted,
            ),
            onPressed: () =>
                ref.read(isExploreGridViewProvider.notifier).state = false,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          _buildSearchAndFilters(context, ref, currentPriceFilter),
          Expanded(
            child: filteredEventsAsyncValue.when(
              data: (events) {
                if (events.isEmpty) {
                  return Center(
                    child: Text(
                      'No events found.',
                      style: GoogleFonts.outfit(
                        color: palette.textSecondary,
                        fontSize: 16,
                      ),
                    ),
                  );
                }

                if (isGrid) {
                  return GridView.builder(
                    padding: EdgeInsets.fromLTRB(
                      20,
                      18,
                      20,
                      bottomContentInset,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          mainAxisExtent: 332,
                        ),
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      return _buildEventGridCard(context, events[index]);
                    },
                  );
                } else {
                  return ListView.builder(
                    padding: EdgeInsets.fromLTRB(
                      24,
                      16,
                      24,
                      bottomContentInset,
                    ),
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      return _buildEventListCard(context, events[index]);
                    },
                  );
                }
              },
              loading: () => const Center(
                child: CircularProgressIndicator(color: kPrimaryColor),
              ),
              error: (error, _) => Center(
                child: Text(
                  'Failed to load events',
                  style: GoogleFonts.outfit(color: kDangerColor, fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters(
    BuildContext context,
    WidgetRef ref,
    String currentFilter,
  ) {
    final palette = _palette;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            decoration: BoxDecoration(
              color: palette.surfaceAlt,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: palette.border),
              boxShadow: [
                BoxShadow(
                  color: palette.shadow.withValues(alpha: 0.12),
                  blurRadius: 16,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(CupertinoIcons.search, color: palette.textMuted, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    onChanged: (val) =>
                        ref.read(exploreSearchQueryProvider.notifier).state =
                            val,
                    style: GoogleFonts.outfit(
                      color: palette.textPrimary,
                      fontSize: 14,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search events, organizers, or venues...',
                      hintStyle: GoogleFonts.outfit(
                        color: palette.textMuted,
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(ref, 'All', currentFilter),
                const SizedBox(width: 8),
                _buildFilterChip(ref, 'Free', currentFilter),
                const SizedBox(width: 8),
                _buildFilterChip(ref, 'Paid', currentFilter),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(WidgetRef ref, String label, String currentFilter) {
    final palette = _palette;
    final isSelected = label == currentFilter;
    return GestureDetector(
      onTap: () => ref.read(explorePriceFilterProvider.notifier).state = label,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? palette.primary : palette.surfaceAlt,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isSelected ? palette.primary : palette.border,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            color: isSelected ? palette.onPrimary : palette.textSecondary,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildMetaRow({
    required IconData icon,
    required String text,
    int maxLines = 1,
  }) {
    final palette = _palette;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: palette.textMuted, size: 12),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.outfit(
              color: palette.textSecondary,
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              height: 1.25,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateTag(String value) {
    final palette = _palette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: palette.surfaceMuted,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: palette.borderStrong),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.calendar_today_rounded, size: 11, color: palette.primary),
          const SizedBox(width: 6),
          Text(
            value,
            style: GoogleFonts.outfit(
              color: palette.primary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceTag(String value) {
    final palette = _palette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: palette.border),
      ),
      child: Text(
        value,
        style: GoogleFonts.outfit(
          color: const Color(0xFF63F2B0),
          fontSize: 13,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildEventGridCard(BuildContext context, EventModel event) {
    final String startPrice = event.startPrice?.toString() ?? 'Free';
    final bool isFree = startPrice.toLowerCase() == 'free' || startPrice == '0';
    final String priceStr = isFree ? 'FREE' : '\$$startPrice';

    final String dateStr = _formatExploreDate(event.date);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push('/event-details/${event.id}'),
        child: Container(
          decoration: BoxDecoration(
            color: _palette.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: _palette.border),
            boxShadow: [
              BoxShadow(
                color: _palette.shadow.withValues(alpha: 0.18),
                blurRadius: 22,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 1.18,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedImage(imageUrl: event.thumbnail, fit: BoxFit.cover),
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.06),
                              Colors.black.withValues(alpha: 0.34),
                            ],
                            stops: const [0.0, 0.58, 1.0],
                          ),
                        ),
                      ),
                    ),
                    if (_canWaitlistFromSurface(event))
                      Positioned(
                        top: 10,
                        left: 10,
                        child: _buildAvailabilityChip(
                          label: _waitlistSubscribed(event)
                              ? 'EN WAITLIST'
                              : 'SOLD OUT',
                          color: _waitlistSubscribed(event)
                              ? const Color(0xFF2ECC71)
                              : const Color(0xFFFF6B6B),
                        ),
                      )
                    else if (event.showMarketplaceFallback)
                      Positioned(
                        top: 10,
                        left: 10,
                        child: _buildAvailabilityChip(
                          label:
                              '${event.marketplaceAvailableCount} EN BLACKMARKET',
                          color: const Color(0xFFFFB84D),
                        ),
                      ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: _buildPriceTag(priceStr),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.outfit(
                          color: _palette.textPrimary,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          height: 1.16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (event.organizer != null &&
                          event.organizer!.isNotEmpty)
                        _buildMetaRow(
                          icon: Icons.person_rounded,
                          text: event.organizer!,
                        ),
                      if (event.address != null &&
                          event.address!.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        _buildMetaRow(
                          icon: Icons.location_on_rounded,
                          text: event.address!,
                        ),
                      ],
                      const SizedBox(height: 12),
                      _buildDateTag(dateStr),
                      if (_canWaitlistFromSurface(event)) ...[
                        const SizedBox(height: 10),
                        _buildWaitlistButton(event, compact: true),
                      ] else if (event.showMarketplaceFallback) ...[
                        const SizedBox(height: 10),
                        Text(
                          '${event.marketplaceAvailableCount} en blackmarket',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.outfit(
                            color: const Color(0xFFFFB84D),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventListCard(BuildContext context, EventModel event) {
    final String startPrice = event.startPrice?.toString() ?? 'Free';
    final bool isFree = startPrice.toLowerCase() == 'free' || startPrice == '0';
    final String priceStr = isFree ? 'FREE' : '\$$startPrice';
    final bool showsWaitlistFooter = _canWaitlistFromSurface(event);
    final bool showsMarketplaceFooter = event.showMarketplaceFallback;
    final double cardHeight = showsWaitlistFooter
        ? 212
        : showsMarketplaceFooter
        ? 184
        : 162;

    final String dateStr = _formatExploreDate(event.date);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push('/event-details/${event.id}'),
        child: Container(
          height: cardHeight,
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: _palette.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _palette.border),
            boxShadow: [
              BoxShadow(
                color: _palette.shadow.withValues(alpha: 0.16),
                blurRadius: 18,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Row(
            children: [
              SizedBox(
                width: 118,
                height: cardHeight,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedImage(imageUrl: event.thumbnail, fit: BoxFit.cover),
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.08),
                              Colors.black.withValues(alpha: 0.26),
                            ],
                            stops: const [0.0, 0.6, 1.0],
                          ),
                        ),
                      ),
                    ),
                    if (_canWaitlistFromSurface(event))
                      Positioned(
                        left: 8,
                        top: 8,
                        child: _buildAvailabilityChip(
                          label: _waitlistSubscribed(event)
                              ? 'EN WAITLIST'
                              : 'SOLD OUT',
                          color: _waitlistSubscribed(event)
                              ? const Color(0xFF2ECC71)
                              : const Color(0xFFFF6B6B),
                        ),
                      )
                    else if (event.showMarketplaceFallback)
                      Positioned(
                        left: 8,
                        top: 8,
                        child: _buildAvailabilityChip(
                          label:
                              '${event.marketplaceAvailableCount} EN BLACKMARKET',
                          color: const Color(0xFFFFB84D),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        event.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.outfit(
                          color: _palette.textPrimary,
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          height: 1.16,
                        ),
                      ),
                      if (event.organizer != null &&
                          event.organizer!.isNotEmpty)
                        _buildMetaRow(
                          icon: Icons.person_rounded,
                          text: event.organizer!,
                        ),
                      if (event.address != null && event.address!.isNotEmpty)
                        _buildMetaRow(
                          icon: Icons.location_on_rounded,
                          text: event.address!,
                        ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildDateTag(dateStr),
                          _buildPriceTag(priceStr),
                        ],
                      ),
                      if (_canWaitlistFromSurface(event)) ...[
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Text(
                                _waitlistCount(event) > 0
                                    ? '${_waitlistCount(event)} persona(s) ya pidieron alerta'
                                    : 'Sold out total. Avísame si reaparecen entradas.',
                                style: GoogleFonts.outfit(
                                  color: _palette.textSecondary,
                                  fontSize: 10.5,
                                  height: 1.25,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            _buildWaitlistButton(event, compact: true),
                          ],
                        ),
                      ] else if (event.showMarketplaceFallback) ...[
                        const SizedBox(height: 6),
                        Text(
                          'Taquilla agotada · ${event.marketplaceAvailableCount} en blackmarket',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFFFFB84D),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvailabilityChip({required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Text(
        label,
        style: GoogleFonts.outfit(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildWaitlistButton(EventModel event, {bool compact = false}) {
    final palette = _palette;
    final subscribed = _waitlistSubscribed(event);
    final busy = _busyWaitlistEvents.contains(event.id);

    return SizedBox(
      height: compact ? 28 : 32,
      child: ElevatedButton.icon(
        onPressed: busy ? null : () => _toggleWaitlist(event),
        style: ElevatedButton.styleFrom(
          backgroundColor: subscribed ? palette.success : palette.primary,
          foregroundColor: palette.onPrimary,
          disabledBackgroundColor: palette.surfaceMuted,
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 10 : 12,
            vertical: 0,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        icon: Icon(
          subscribed
              ? Icons.notifications_active_rounded
              : Icons.notifications_outlined,
          size: compact ? 14 : 16,
        ),
        label: Text(
          subscribed ? 'En waitlist' : 'Avísame',
          style: GoogleFonts.outfit(
            fontSize: compact ? 10 : 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  String _formatExploreDate(dynamic rawDate) {
    if (rawDate == null) return 'TBA';
    if (rawDate is DateTime) {
      final local = rawDate.toLocal();
      return '${local.year.toString().padLeft(4, '0')}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
    }

    final value = rawDate.toString().trim();
    if (value.isEmpty) return 'TBA';
    final parsed = DateTime.tryParse(value);
    if (parsed == null) return value;
    final local = parsed.toLocal();
    return '${local.year.toString().padLeft(4, '0')}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
  }
}
