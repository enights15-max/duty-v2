import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async'; // For Countdown
import 'package:flutter_html/flutter_html.dart' hide Marker;
import '../providers/event_details_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/providers/profile_state_provider.dart';
import '../../../profile/presentation/providers/marketplace_provider.dart';
import '../../../../core/constants/app_urls.dart';
import '../../../../core/theme/colors.dart';

class EventDetailsPage extends ConsumerStatefulWidget {
  final int eventId;

  const EventDetailsPage({super.key, required this.eventId});

  @override
  ConsumerState<EventDetailsPage> createState() => _EventDetailsPageState();
}

class _EventDetailsPageState extends ConsumerState<EventDetailsPage> {
  int _currentImageIndex = 0;
  bool? _isWishlistedOverride;
  int? _wishlistCountOverride;
  bool _wishlistBusy = false;
  bool? _waitlistSubscribedOverride;
  int? _waitlistCountOverride;
  bool _waitlistBusy = false;

  void _openMarketplaceForEvent(EventDetailModel event) {
    final search = event.title.trim();
    ref
        .read(marketplaceFiltersProvider.notifier)
        .state = MarketplaceFilterState(
      search: search.isEmpty ? null : search,
      eventId: event.id,
      eventTitle: event.title,
      eventDate: event.date,
    );
    ref.invalidate(marketplaceTicketsProvider);
    context.go('/marketplace');
  }

  Widget _buildRewardsSection(EventDetailModel event) {
    final palette = context.dutyTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              Text(
                'BENEFICIOS INCLUIDOS',
                style: GoogleFonts.outfit(
                  color: palette.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.auto_awesome, color: palette.primary, size: 14),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 110,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: event.rewards.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final reward = event.rewards[index];
              return Container(
                width: 220,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: palette.surface.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: palette.border.withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: palette.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        _getRewardIcon(reward.rewardType),
                        color: palette.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            reward.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.outfit(
                              color: palette.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (reward.sponsorName != null) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  'por ',
                                  style: GoogleFonts.inter(
                                    color: palette.textMuted,
                                    fontSize: 10,
                                  ),
                                ),
                                Flexible(
                                  child: Text(
                                    reward.sponsorName!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.outfit(
                                      color: palette.primary,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ] else ...[
                            const SizedBox(height: 4),
                            Text(
                              'Cortesía del evento',
                              style: GoogleFonts.inter(
                                color: palette.textMuted,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  IconData _getRewardIcon(String type) {
    switch (type) {
      case 'drink':
        return Icons.local_bar_rounded;
      case 'merch':
        return Icons.checkroom_rounded;
      case 'perk_access':
        return Icons.verified_user_rounded;
      case 'voucher':
        return Icons.confirmation_number_rounded;
      default:
        return Icons.card_giftcard_rounded;
    }
  }

  String _slugifyTitle(String value) {
    final normalized = value
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'-{2,}'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
    return normalized.isEmpty ? 'event' : normalized;
  }

  DateTime _resolveEventTargetDate(EventDetailModel event) {
    final dateValue = event.date?.trim();
    final timeValue = event.time?.trim();
    final candidates = <String>[
      if (dateValue != null &&
          dateValue.isNotEmpty &&
          timeValue != null &&
          timeValue.isNotEmpty)
        '$dateValue $timeValue',
      if (dateValue != null && dateValue.isNotEmpty) dateValue,
      if (timeValue != null && timeValue.isNotEmpty) timeValue,
    ];

    for (final candidate in candidates) {
      final parsed = DateTime.tryParse(candidate);
      if (parsed != null) return parsed;
    }

    return DateTime.now().add(const Duration(days: 7));
  }

  DateTime _resolveEventExpirationDate(EventDetailModel event) {
    // If explicit end date is provided
    final endDateValue = event.endDate?.trim();
    final endTimeValue = event.endTime?.trim();
    final endCandidates = <String>[
      if (endDateValue != null &&
          endDateValue.isNotEmpty &&
          endTimeValue != null &&
          endTimeValue.isNotEmpty)
        '$endDateValue $endTimeValue',
      if (endDateValue != null && endDateValue.isNotEmpty) endDateValue,
    ];

    for (final candidate in endCandidates) {
      final parsed = DateTime.tryParse(candidate);
      if (parsed != null) return parsed;
    }

    // Default fallback: 12 hours after the start date
    return _resolveEventTargetDate(event).add(const Duration(hours: 12));
  }

  Future<void> _shareEvent(EventDetailModel event) async {
    final shareUrl = AppUrls.eventShareBridge(
      event.id,
      slug: _slugifyTitle(event.title),
    );

    await SharePlus.instance.share(
      ShareParams(
        title: event.title,
        subject: event.title,
        uri: Uri.parse(shareUrl),
      ),
    );
  }

  Future<void> _toggleWishlist({
    required bool currentValue,
    required int currentCount,
  }) async {
    if (_wishlistBusy) return;

    final apiClient = ref.read(apiClientProvider);
    if (!apiClient.hasToken) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Log in to mark events as interested and shape your scene.',
            ),
          ),
        );
        context.push('/login');
      }
      return;
    }

    final nextValue = !currentValue;
    final nextCount = nextValue
        ? currentCount + 1
        : (currentCount > 0 ? currentCount - 1 : 0);

    setState(() {
      _wishlistBusy = true;
      _isWishlistedOverride = nextValue;
      _wishlistCountOverride = nextCount;
    });

    try {
      if (nextValue) {
        await apiClient.dio.post(
          AppUrls.wishlistsStore,
          data: {'event_id': widget.eventId},
        );
      } else {
        await apiClient.dio.post(
          AppUrls.wishlistsDelete,
          data: {'event_id': widget.eventId},
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              nextValue
                  ? 'Added to your scene. You are now interested in this event.'
                  : 'Removed from your scene.',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isWishlistedOverride = currentValue;
          _wishlistCountOverride = currentCount;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'We could not update your interested state right now.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _wishlistBusy = false);
      }
    }
  }

  Future<void> _toggleWaitlist({
    required EventDetailModel event,
    required bool currentValue,
    required int currentCount,
  }) async {
    if (_waitlistBusy) return;

    final apiClient = ref.read(apiClientProvider);
    if (!apiClient.hasToken) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Inicia sesión para unirte a la waitlist y enterarte si reaparecen entradas.',
            ),
          ),
        );
        context.push('/login');
      }
      return;
    }

    final nextValue = !currentValue;
    final optimisticCount = nextValue
        ? currentCount + 1
        : (currentCount > 0 ? currentCount - 1 : 0);

    setState(() {
      _waitlistBusy = true;
      _waitlistSubscribedOverride = nextValue;
      _waitlistCountOverride = optimisticCount;
    });

    try {
      final response = nextValue
          ? await apiClient.dio.post(AppUrls.eventWaitlist(event.id))
          : await apiClient.dio.delete(AppUrls.eventWaitlist(event.id));

      final payload = response.data;
      final map = payload is Map<String, dynamic>
          ? payload
          : payload is Map
          ? Map<String, dynamic>.from(payload)
          : const <String, dynamic>{};
      final data = map['data'];
      if (data is Map<String, dynamic>) {
        final summary = EventWaitlistSummaryModel.fromJson(data);
        if (mounted) {
          setState(() {
            _waitlistSubscribedOverride = summary.viewerSubscribed;
            _waitlistCountOverride = summary.waitlistCount;
          });
        }
      }

      ref.invalidate(eventDetailsProvider(widget.eventId));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              map['message']?.toString() ??
                  (nextValue
                      ? 'Te avisaremos si vuelven a aparecer entradas.'
                      : 'Ya no estás en la waitlist de este evento.'),
            ),
          ),
        );
      }
    } on DioException catch (error) {
      final payload = error.response?.data;
      final map = payload is Map<String, dynamic>
          ? payload
          : payload is Map
          ? Map<String, dynamic>.from(payload)
          : const <String, dynamic>{};
      final message = map['message']?.toString().trim().isNotEmpty == true
          ? map['message'].toString().trim()
          : 'No pudimos actualizar la waitlist ahora mismo. Inténtalo de nuevo.';

      if (mounted) {
        setState(() {
          _waitlistSubscribedOverride = currentValue;
          _waitlistCountOverride = currentCount;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _waitlistSubscribedOverride = currentValue;
          _waitlistCountOverride = currentCount;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No pudimos actualizar la waitlist ahora mismo. Inténtalo de nuevo.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _waitlistBusy = false);
      }
    }
  }

  Color _availabilityColor(EventInventorySummaryModel? inventory) {
    final palette = context.dutyTheme;
    switch (inventory?.availabilityState) {
      case 'sold_out_marketplace':
        return palette.warning;
      case 'sold_out':
        return palette.danger;
      case 'low_stock':
        return palette.warning;
      default:
        return palette.primary;
    }
  }

  Widget _buildAvailabilityBadge(
    String label,
    EventInventorySummaryModel? inventory,
  ) {
    final color = _availabilityColor(inventory);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.26),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.30)),
      ),
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.outfit(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildHeroMetaChip(IconData icon, String label, Color accent) {
    final palette = context.dutyTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: accent.withValues(alpha: 0.24)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: accent, size: 15),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.outfit(
              color: palette.textPrimary,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailabilityPanel(
    BuildContext context,
    EventInventorySummaryModel inventory,
    EventWaitlistSummaryModel? waitlist,
    bool isWaitlistSubscribed,
    int waitlistCount,
    EventDetailModel event,
  ) {
    final color = _availabilityColor(inventory);
    final palette = context.dutyTheme;

    String helperText;
    switch (inventory.availabilityState) {
      case 'sold_out_marketplace':
        helperText =
            'La taquilla oficial está agotada. Puedes revisar si otros usuarios tienen entradas disponibles en blackmarket.';
        break;
      case 'sold_out':
        helperText = waitlistCount > 0
            ? 'La taquilla oficial ya se agotó. ${waitlistCount == 1 ? '1 persona ya pidió alerta para este evento.' : '$waitlistCount personas ya pidieron alerta para este evento.'}'
            : 'La taquilla oficial ya se agotó. Este sold out refuerza la demanda del evento y por ahora no hay reventa disponible.';
        break;
      case 'low_stock':
        helperText = inventory.lowStockCount != null
            ? 'Quedan solo ${inventory.lowStockCount} entradas oficiales. Si te interesa, este es el mejor momento para asegurar la tuya.'
            : 'Quedan pocas entradas oficiales. Si te interesa, este es el mejor momento para asegurar la tuya.';
        break;
      default:
        helperText = inventory.primarySellThroughPercent == null
            ? 'La taquilla oficial sigue activa.'
            : 'La preventa ya va por ${inventory.primarySellThroughPercent!.toStringAsFixed(1)}% del inventario trazable.';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.local_activity_rounded, color: color, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  inventory.demandLabel,
                  style: GoogleFonts.outfit(
                    color: palette.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            helperText,
            style: GoogleFonts.inter(
              color: palette.textSecondary,
              fontSize: 13,
              height: 1.45,
            ),
          ),
          if (inventory.primaryAvailableTickets != null ||
              inventory.marketplaceAvailableCount > 0) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (inventory.primaryAvailableTickets != null)
                  _buildAvailabilityFactChip(
                    label: 'Oficial',
                    value: '${inventory.primaryAvailableTickets}',
                  ),
                if (inventory.primarySellThroughPercent != null)
                  _buildAvailabilityFactChip(
                    label: 'Sell-through',
                    value:
                        '${inventory.primarySellThroughPercent!.toStringAsFixed(1)}%',
                  ),
                if (inventory.showMarketplaceFallback)
                  _buildAvailabilityFactChip(
                    label: 'Blackmarket',
                    value: '${inventory.marketplaceAvailableCount}',
                  ),
                if (!inventory.showMarketplaceFallback &&
                    inventory.primarySoldOut)
                  _buildAvailabilityFactChip(
                    label: 'Waitlist',
                    value: '$waitlistCount',
                  ),
              ],
            ),
          ],
          if (inventory.showMarketplaceFallback) ...[
            const SizedBox(height: 14),
            OutlinedButton(
              onPressed: () => _openMarketplaceForEvent(event),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: color.withValues(alpha: 0.35)),
                foregroundColor: color,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text('Ver blackmarket'),
            ),
          ] else if (inventory.primarySoldOut) ...[
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: _waitlistBusy
                  ? null
                  : () => _toggleWaitlist(
                      event: event,
                      currentValue: isWaitlistSubscribed,
                      currentCount: waitlist?.waitlistCount ?? waitlistCount,
                    ),
              style: FilledButton.styleFrom(
                backgroundColor: isWaitlistSubscribed
                    ? palette.surfaceAlt
                    : color,
                foregroundColor: palette.textPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: Icon(
                isWaitlistSubscribed
                    ? Icons.notifications_active_rounded
                    : Icons.notifications_rounded,
              ),
              label: Text(
                _waitlistBusy
                    ? 'Actualizando...'
                    : isWaitlistSubscribed
                    ? 'Salir de la waitlist'
                    : 'Avísame si reaparecen entradas',
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAvailabilityFactChip({
    required String label,
    required String value,
  }) {
    final palette = context.dutyTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: palette.surfaceAlt,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: palette.border),
      ),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$label: ',
              style: GoogleFonts.outfit(
                color: palette.textMuted,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextSpan(
              text: value,
              style: GoogleFonts.outfit(
                color: palette.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.dutyTheme;
    final eventAsync = ref.watch(eventDetailsProvider(widget.eventId));
    final activeProfile = ref.watch(activeProfileProvider);

    return Scaffold(
      backgroundColor: palette.background,
      body: eventAsync.when(
        data: (event) {
          final isWishlisted = _isWishlistedOverride ?? event.isWishlisted;
          final wishlistCount = _wishlistCountOverride ?? event.wishlistCount;
          final socialInterestedCount = event.social == null
              ? null
              : (wishlistCount > event.social!.interestedCount
                    ? wishlistCount
                    : event.social!.interestedCount);
          final targetDate = _resolveEventTargetDate(event);
          final expirationDate = _resolveEventExpirationDate(event);
          final isPastEvent = expirationDate.isBefore(DateTime.now());
          final hasReservableTickets = event.tickets.any(
            (ticket) =>
                ticket.available &&
                ticket.pricingType == 'normal' &&
                ticket.reservationEnabled,
          );
          final availablePrices =
              event.tickets
                  .map((ticket) => ticket.currentPrice ?? ticket.price)
                  .where((price) => price > 0)
                  .toList()
                ..sort();
          final startingPrice = availablePrices.isNotEmpty
              ? availablePrices.first
              : null;
          final scheduledTickets =
              event.tickets
                  .where(
                    (ticket) =>
                        ticket.nextPrice != null &&
                        ticket.nextPriceEffectiveFrom != null,
                  )
                  .toList()
                ..sort(
                  (a, b) => a.nextPriceEffectiveFrom!.compareTo(
                    b.nextPriceEffectiveFrom!,
                  ),
                );
          final nextIncreaseTicket = scheduledTickets.isNotEmpty
              ? scheduledTickets.first
              : null;
          final nextIncreaseLabel = nextIncreaseTicket == null
              ? null
              : 'Sube a \$${nextIncreaseTicket.nextPrice!.toStringAsFixed(2)} el ${DateFormat('MMM d').format(nextIncreaseTicket.nextPriceEffectiveFrom!.toLocal())}';
          final inventory = event.inventory;
          final availabilityLabel =
              inventory?.demandLabel ?? 'Tickets disponibles';
          final waitlist = event.waitlist;
          final isWaitlistSubscribed =
              _waitlistSubscribedOverride ??
              waitlist?.viewerSubscribed ??
              false;
          final waitlistCount =
              _waitlistCountOverride ?? waitlist?.waitlistCount ?? 0;
          final showHeroWaitlistProof =
              inventory?.primarySoldOut == true &&
              inventory?.showMarketplaceFallback != true &&
              waitlistCount > 0;
          final showHeroWaitlistState =
              inventory?.primarySoldOut == true &&
              inventory?.showMarketplaceFallback != true &&
              isWaitlistSubscribed;

          // Event data is already shaped by provider; keep UI render pure.
          return Stack(
            children: [
              // Scrollable Content
              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(
                  bottom: 100,
                ), // Space for bottom bar
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- Header Section ---
                    SizedBox(
                      height: 400, // Tall header
                      child: Stack(
                        children: [
                          // Main Image Slider
                          Positioned.fill(child: _buildImageSlider(event)),
                          // Premium Gradient Overlay
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    palette.background.withValues(alpha: 0.2),
                                    palette.background.withValues(alpha: 0.8),
                                    palette.background,
                                  ],
                                  stops: const [0.0, 0.5, 0.8, 1.0],
                                ),
                              ),
                            ),
                          ),
                          // Content Overlay
                          Positioned(
                            bottom: 20,
                            left: 24,
                            right: 24,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildAvailabilityBadge(
                                  availabilityLabel,
                                  inventory,
                                ),
                                if (showHeroWaitlistProof ||
                                    showHeroWaitlistState) ...[
                                  const SizedBox(height: 10),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      if (showHeroWaitlistState)
                                        _buildHeroMetaChip(
                                          Icons.notifications_active_rounded,
                                          'En waitlist',
                                          palette.success,
                                        ),
                                      if (showHeroWaitlistProof)
                                        _buildHeroMetaChip(
                                          Icons.people_alt_rounded,
                                          waitlistCount == 1
                                              ? '1 persona esperando'
                                              : '$waitlistCount personas esperando',
                                          palette.primary,
                                        ),
                                    ],
                                  ),
                                ],
                                const SizedBox(height: 12),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        event.title,
                                        style: GoogleFonts.outfit(
                                          color: palette.textPrimary,
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                          height: 1.1,
                                        ),
                                      ),
                                    ),
                                    if (event.policies?.adultAgeRestrictions ==
                                        true) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: palette.danger.withValues(
                                            alpha: 0.2,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                          border: Border.all(
                                            color: palette.danger,
                                          ),
                                        ),
                                        child: Text(
                                          '18+',
                                          style: GoogleFonts.outfit(
                                            color: palette.danger,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 14),
                                Wrap(
                                  spacing: 10,
                                  runSpacing: 10,
                                  children: [
                                    _buildHeroMetaChip(
                                      Icons.calendar_today_rounded,
                                      '${event.date} • ${event.time}',
                                      palette.primary,
                                    ),
                                    if (inventory?.showMarketplaceFallback ==
                                        true)
                                      _buildHeroMetaChip(
                                        Icons.swap_horiz_rounded,
                                        'Blackmarket activo',
                                        palette.warning,
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // --- Countdown Timer ---
                    if (!isPastEvent)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 20,
                        ),
                        child: _CountdownTimer(targetDate: targetDate),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 20,
                        ),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            vertical: 20,
                            horizontal: 16,
                          ),
                          decoration: BoxDecoration(
                            color: palette.surface,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: palette.border),
                          ),
                          child: Center(
                            child: Text(
                              'THIS EVENT HAS CONCLUDED',
                              style: GoogleFonts.outfit(
                                color: palette.textMuted,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                        ),
                      ),

                    if (inventory != null) ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                        child: _buildAvailabilityPanel(
                          context,
                          inventory,
                          waitlist,
                          isWaitlistSubscribed,
                          waitlistCount,
                          event,
                        ),
                      ),
                    ],

                    // --- Action Buttons ---
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                      child: Row(
                        children: [
                          Expanded(
                            child: _FollowButton(
                              count: wishlistCount,
                              isWishlisted: isWishlisted,
                              isLoading: _wishlistBusy,
                              onTap: () => _toggleWishlist(
                                currentValue: isWishlisted,
                                currentCount: wishlistCount,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _ContactOrganizerButton(
                              organizerId:
                                  event.organizerModel?.legacyOrganizerId,
                              organizerName:
                                  event.organizerModel?.name ??
                                  event.organizer ??
                                  'Organizer',
                              eventTitle: event.title,
                              supportsContact:
                                  event.organizerModel?.supportsContact ?? true,
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (event.rewards.isNotEmpty) ...[
                      _buildRewardsSection(event),
                    ],

                    if (event.social?.hasAnyData == true) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          'THE CROWD',
                          style: GoogleFonts.outfit(
                            color: palette.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: _EventSocialPanel(
                          social: event.social!,
                          interestedCountOverride: socialInterestedCount,
                          isViewerInterested: isWishlisted,
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],

                    if (event.lineup.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: _EventLineupSection(lineup: event.lineup),
                      ),
                      const SizedBox(height: 32),
                    ],

                    // --- About Section ---
                    /*
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ABOUT THE EXPERIENCE',
                            style: GoogleFonts.outfit(
                              color: kPrimaryColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Html(
                            data: event.description,
                            style: {
                              "body": Style(
                                color: palette.textMuted,
                                fontSize: FontSize(14),
                                fontFamily: GoogleFonts.inter().fontFamily,
                                lineHeight: LineHeight(1.6),
                                margin: Margins.zero,
                                padding: HtmlPaddings.zero,
                              ),
                              "p": Style(
                                margin: Margins.zero,
                                padding: HtmlPaddings.zero,
                              ),
                            },
                          ),
                          TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              'READ MORE',
                              style: GoogleFonts.outfit(
                                color: kPrimaryColor,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
*/
                    const SizedBox(height: 32),

                    // --- Organizer Section ---
                    if (event.organizerModel != null) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          'Organizer',
                          style: GoogleFonts.outfit(
                            color: palette.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: GestureDetector(
                          onTap: () => context.push(
                            '/organizer-profile/${event.organizerModel!.id}',
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: palette.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: palette.border),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundImage:
                                      event.organizerModel!.photo != null
                                      ? NetworkImage(
                                          event.organizerModel!.photo!,
                                        )
                                      : null,
                                  onBackgroundImageError:
                                      event.organizerModel!.photo != null
                                      ? (_, _) {}
                                      : null,
                                  child: event.organizerModel!.photo == null
                                      ? Icon(
                                          Icons.person,
                                          color: palette.textPrimary,
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        event.organizerModel!.name,
                                        style: GoogleFonts.outfit(
                                          color: palette.textPrimary,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        'View Profile',
                                        style: GoogleFonts.inter(
                                          color: palette.primary,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                  color: palette.textMuted,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],

                    // --- Venue Section ---
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'The Venue',
                            style: GoogleFonts.outfit(
                              color: palette.textPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (event.venue != null)
                            TextButton(
                              onPressed: () => context.push(
                                '/venue-profile/${event.venue!.id}',
                              ),
                              child: Text(
                                'View Profile',
                                style: GoogleFonts.inter(
                                  color: palette.primary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (event.latitude != null && event.longitude != null)
                      EventLocationMap(
                        latitude: event.latitude!,
                        longitude: event.longitude!,
                        address: event.address ?? 'TBA',
                      )
                    else
                      GestureDetector(
                        onTap: event.venue != null
                            ? () => context.push(
                                '/venue-profile/${event.venue!.id}',
                              )
                            : null,
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 24),
                          height: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            image: const DecorationImage(
                              image: NetworkImage(
                                'https://docs.mapbox.com/mapbox-gl-js/assets/radar.gif',
                              ),
                              fit: BoxFit.cover,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: palette.shadow.withValues(alpha: 0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.vertical(
                                      bottom: Radius.circular(24),
                                    ),
                                    gradient: LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                      colors: [
                                        palette.background.withValues(
                                          alpha: 0.92,
                                        ),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              event.address ?? 'TBA',
                                              style: GoogleFonts.outfit(
                                                color: palette.textPrimary,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              'Location',
                                              style: GoogleFonts.inter(
                                                color: palette.textSecondary,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: palette.primary,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.map,
                                          color: palette.textPrimary,
                                          size: 20,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 100), // Extra space
                  ],
                ),
              ),

              // --- Top App Bar ---
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildGlassIcon(
                          Icons.arrow_back_ios_new,
                          () => context.pop(),
                        ),
                        Row(
                          children: [
                            _buildGlassIcon(Icons.share, () {}),
                            const SizedBox(width: 12),
                            _buildGlassIcon(
                              icon: isWishlisted
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              onTap: () => _toggleWishlist(
                                currentValue: isWishlisted,
                                currentCount: wishlistCount,
                              ),
                              iconColor: isWishlisted
                                  ? palette.primary
                                  : palette.textPrimary,
                              backgroundColor: isWishlisted
                                  ? palette.primarySurface
                                  : palette.surfaceAlt.withValues(alpha: 0.92),
                              borderColor: isWishlisted
                                  ? palette.borderStrong
                                  : palette.border,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // --- Bottom Bar ---
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: palette.surfaceAlt.withValues(alpha: 0.95),
                    border: Border(top: BorderSide(color: palette.border)),
                  ),
                  child: SafeArea(
                    top: false,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final isCompact = constraints.maxWidth < 520;
                        final stackButtons = constraints.maxWidth < 390;
                        final showMarketplaceAction =
                            inventory?.showMarketplaceFallback == true;
                        final showWaitlistAction =
                            inventory?.showWaitlistCta == true ||
                            (inventory?.primarySoldOut == true &&
                                inventory?.showMarketplaceFallback != true);

                        if (isPastEvent) {
                          return Align(
                            alignment: Alignment.centerLeft,
                            child: _buildBottomStatusPill('Ended'),
                          );
                        }

                        if (isCompact) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    flex: 9,
                                    child: _buildBottomPricePanel(
                                      startingPrice: startingPrice,
                                      nextIncreaseLabel: null,
                                      compact: true,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    flex: 11,
                                    child: _buildBottomActionButton(
                                      label: showMarketplaceAction
                                          ? 'Ver reventa'
                                          : showWaitlistAction
                                          ? (isWaitlistSubscribed
                                                ? 'Salir de waitlist'
                                                : 'Avísame')
                                          : 'Buy Tickets',
                                      icon: showMarketplaceAction
                                          ? Icons.storefront_rounded
                                          : showWaitlistAction
                                          ? Icons.notifications_active_rounded
                                          : Icons.confirmation_number,
                                      onTap: showMarketplaceAction
                                          ? () =>
                                                _openMarketplaceForEvent(event)
                                          : showWaitlistAction
                                          ? () => _toggleWaitlist(
                                              event: event,
                                              currentValue:
                                                  isWaitlistSubscribed,
                                              currentCount: waitlistCount,
                                            )
                                          : () => context.push(
                                              '/checkout',
                                              extra: event,
                                            ),
                                      compact: stackButtons,
                                    ),
                                  ),
                                ],
                              ),
                              if (nextIncreaseLabel != null) ...[
                                const SizedBox(height: 8),
                                _buildBottomNoticeChip(
                                  nextIncreaseLabel,
                                  icon: Icons.trending_up_rounded,
                                  compact: true,
                                ),
                              ] else ...[
                                const SizedBox(height: 8),
                              ],
                              if (showWaitlistAction && waitlistCount > 0) ...[
                                _buildBottomNoticeChip(
                                  waitlistCount == 1
                                      ? '1 persona ya pidió alerta'
                                      : '$waitlistCount personas ya pidieron alerta',
                                  icon: Icons.group_rounded,
                                  compact: true,
                                ),
                                const SizedBox(height: 8),
                              ],
                              if (hasReservableTickets) ...[
                                _buildBottomActionButton(
                                  label: 'Reservar',
                                  icon: Icons.lock_clock_rounded,
                                  onTap: () => context.push(
                                    '/reservations/create',
                                    extra: event,
                                  ),
                                  outlined: true,
                                  compact: stackButtons,
                                ),
                              ],
                            ],
                          );
                        }

                        return Row(
                          children: [
                            Text(
                              'STARTING AT',
                              style: GoogleFonts.inter(
                                color: Colors.white54,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: hasReservableTickets ? 2 : 1,
                              child: Row(
                                children: [
                                  if (hasReservableTickets) ...[
                                    Expanded(
                                      child: _buildBottomActionButton(
                                        label: 'Reservar',
                                        icon: Icons.lock_clock_rounded,
                                        onTap: () => context.push(
                                          '/reservations/create',
                                          extra: event,
                                        ),
                                        outlined: true,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                  ],
                                  Expanded(
                                    child: _buildBottomActionButton(
                                      label: showMarketplaceAction
                                          ? 'Ver reventa'
                                          : showWaitlistAction
                                          ? (isWaitlistSubscribed
                                                ? 'Salir de waitlist'
                                                : 'Avísame')
                                          : 'Buy Tickets',
                                      icon: showMarketplaceAction
                                          ? Icons.storefront_rounded
                                          : showWaitlistAction
                                          ? Icons.notifications_active_rounded
                                          : Icons.confirmation_number,
                                      onTap: showMarketplaceAction
                                          ? () =>
                                                _openMarketplaceForEvent(event)
                                          : showWaitlistAction
                                          ? () => _toggleWaitlist(
                                              event: event,
                                              currentValue:
                                                  isWaitlistSubscribed,
                                              currentCount: waitlistCount,
                                            )
                                          : () => context.push(
                                              '/checkout',
                                              extra: event,
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        InkWell(
                          onTap: () => context.push('/checkout', extra: event),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF6200EE), Color(0xFFA855F7)],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF6200EE,
                                  ).withOpacity(0.5),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Text(
                                  'Buy Tickets',
                                  style: GoogleFonts.outfit(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.confirmation_number,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Text(
            'Error: $err',
            style: TextStyle(color: palette.textPrimary),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomPricePanel({
    required double? startingPrice,
    required String? nextIncreaseLabel,
    bool compact = false,
  }) {
    final palette = context.dutyTheme;
    final priceLabel = startingPrice == null
        ? 'Free'
        : '\$${startingPrice.toStringAsFixed(2)}';

    return Container(
      constraints: BoxConstraints(minHeight: compact ? 74 : 92),
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 14 : 16,
        vertical: compact ? 11 : 14,
      ),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: palette.border),
        boxShadow: compact
            ? null
            : [
                BoxShadow(
                  color: palette.shadow.withValues(alpha: 0.22),
                  blurRadius: 24,
                  offset: const Offset(0, 16),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'FROM',
            style: GoogleFonts.outfit(
              color: palette.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
            ),
          ),
          SizedBox(height: compact ? 6 : 4),
          if (compact)
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                priceLabel,
                style: GoogleFonts.outfit(
                  color: palette.textPrimary,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
            )
          else
            Text(
              priceLabel,
              style: GoogleFonts.outfit(
                color: palette.textPrimary,
                fontSize: 26,
                fontWeight: FontWeight.w800,
                height: 1,
              ),
            ),
          if (nextIncreaseLabel != null) ...[
            const SizedBox(height: 6),
            Text(
              nextIncreaseLabel,
              maxLines: compact ? 2 : 3,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                color: palette.warning,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                height: 1.25,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomActionButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    bool outlined = false,
    bool compact = false,
  }) {
    final palette = context.dutyTheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(minHeight: compact ? 74 : 92),
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 12 : 16,
          vertical: compact ? 12 : 16,
        ),
        decoration: BoxDecoration(
          color: outlined ? palette.surface : null,
          gradient: outlined
              ? null
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [palette.primary, palette.primaryGlow],
                ),
          borderRadius: BorderRadius.circular(24),
          border: outlined
              ? Border.all(color: palette.warning.withValues(alpha: 0.28))
              : null,
          boxShadow: outlined
              ? null
              : [
                  BoxShadow(
                    color: palette.primaryGlow.withValues(alpha: 0.30),
                    blurRadius: 22,
                    offset: const Offset(0, 12),
                  ),
                ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Icon(
              icon,
              color: outlined ? palette.warning : palette.textPrimary,
              size: compact ? 16 : 18,
            ),
            SizedBox(width: compact ? 6 : 8),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.outfit(
                  color: palette.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: compact ? 15 : 15.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNoticeChip(
    String label, {
    required IconData icon,
    bool compact = false,
  }) {
    final palette = context.dutyTheme;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 12 : 14,
        vertical: compact ? 8 : 10,
      ),
      decoration: BoxDecoration(
        color: palette.warning.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: palette.warning.withValues(alpha: 0.22)),
      ),
      child: Row(
        children: [
          Icon(icon, size: compact ? 15 : 16, color: palette.warning),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              maxLines: compact ? 2 : 3,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.outfit(
                color: palette.warning,
                fontSize: compact ? 11 : 12,
                fontWeight: FontWeight.w700,
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomStatusPill(String label) {
    final palette = context.dutyTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: BoxDecoration(
        color: palette.surfaceAlt,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.outfit(
          color: palette.textMuted,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildImageSlider(dynamic event) {
    final palette = context.dutyTheme;
    // Determine which images to show
    final List<String> imagesToShow = [];

    if (event.images.isNotEmpty) {
      imagesToShow.addAll(event.images);
    } else {
      // Fallback to cover/thumbnail
      if (event.coverImage != null && event.coverImage!.isNotEmpty) {
        imagesToShow.add(event.coverImage!);
      } else if (event.thumbnail.isNotEmpty) {
        imagesToShow.add(event.thumbnail);
      }
    }

    if (imagesToShow.isEmpty) {
      return Container(
        color: palette.surfaceAlt,
        child: Center(
          child: Icon(
            Icons.image_not_supported,
            size: 50,
            color: palette.textMuted,
          ),
        ),
      );
    }

    return Stack(
      children: [
        PageView.builder(
          itemCount: imagesToShow.length,
          onPageChanged: (index) {
            setState(() {
              _currentImageIndex = index;
            });
          },
          itemBuilder: (context, index) {
            return CachedNetworkImage(
              imageUrl: imagesToShow[index],
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: palette.surfaceAlt,
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: palette.textMuted,
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: palette.surfaceAlt,
                child: Center(
                  child: Icon(
                    Icons.broken_image,
                    size: 50,
                    color: palette.textMuted,
                  ),
                ),
              ),
            );
          },
        ),
        // Indicators
        if (imagesToShow.length > 1)
          Positioned(
            bottom: 30, // Above the gradient content
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(imagesToShow.length, (index) {
                return Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentImageIndex == index
                        ? palette.primary
                        : palette.textMuted.withValues(alpha: 0.5),
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }

  Widget _buildGlassIcon({
    required IconData icon,
    required VoidCallback onTap,
    Color? iconColor,
    Color? backgroundColor,
    Color? borderColor,
  }) {
    final palette = context.dutyTheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: backgroundColor ?? palette.surfaceAlt.withValues(alpha: 0.85),
          shape: BoxShape.circle,
          border: Border.all(color: borderColor ?? palette.border),
        ),
        child: Icon(icon, color: iconColor ?? palette.textPrimary, size: 21),
      ),
    );
  }
}

class _CountdownTimer extends StatefulWidget {
  final DateTime targetDate;

  const _CountdownTimer({required this.targetDate});

  @override
  State<_CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<_CountdownTimer> {
  late Timer _timer;
  Duration _timeLeft = Duration.zero;

  @override
  void initState() {
    super.initState();
    _calculateTimeLeft();
    _timer = Timer.periodic(
      const Duration(minutes: 1),
      (timer) => _calculateTimeLeft(),
    );
  }

  void _calculateTimeLeft() {
    final now = DateTime.now();
    if (widget.targetDate.isAfter(now)) {
      setState(() {
        _timeLeft = widget.targetDate.difference(now);
      });
    } else {
      _timer.cancel();
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.dutyTheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: palette.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildTimeItem(_timeLeft.inDays.toString().padLeft(2, '0'), 'DAYS'),
          _buildDivider(),
          _buildTimeItem(
            (_timeLeft.inHours % 24).toString().padLeft(2, '0'),
            'HOURS',
          ),
          _buildDivider(),
          _buildTimeItem(
            (_timeLeft.inMinutes % 60).toString().padLeft(2, '0'),
            'MINS',
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    final palette = context.dutyTheme;
    return Container(height: 30, width: 1, color: palette.borderStrong);
  }

  Widget _buildTimeItem(String value, String label) {
    final palette = context.dutyTheme;
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.outfit(
            color: palette.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(
            color: palette.primary,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}

class EventLocationMap extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String address;

  const EventLocationMap({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.address,
  });

  @override
  State<EventLocationMap> createState() => _EventLocationMapState();
}

class _EventLocationMapState extends State<EventLocationMap> {
  late final Set<Marker> _markers;
  late final CameraPosition _initialPosition;
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    _initialPosition = CameraPosition(
      target: LatLng(widget.latitude, widget.longitude),
      zoom: 15,
    );
    _markers = {
      Marker(
        markerId: const MarkerId('venue'),
        position: LatLng(widget.latitude, widget.longitude),
        infoWindow: InfoWindow(title: widget.address),
      ),
    };
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.dutyTheme;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: palette.shadow.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: GoogleMap(
          initialCameraPosition: _initialPosition,
          markers: _markers,
          liteModeEnabled: true,
          mapToolbarEnabled: true,
          zoomControlsEnabled: false,
          myLocationButtonEnabled: false,
          onMapCreated: (controller) {
            _mapController = controller;
          },
        ),
      ),
    );
  }
}

class _FollowButton extends StatelessWidget {
  final int count;
  final bool isWishlisted;
  final bool isLoading;
  final VoidCallback onTap;

  const _FollowButton({
    required this.count,
    required this.isWishlisted,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.dutyTheme;
    final subtitle = count == 1
        ? '1 person interested'
        : '$count people interested';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: isWishlisted ? palette.primarySurface : palette.surface,
          border: Border.all(
            color: isWishlisted
                ? palette.primary.withValues(alpha: 0.5)
                : palette.border,
            width: isWishlisted ? 1.5 : 1.0,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(kTextPrimary),
                    ),
                  )
                : Icon(
                    isWishlisted ? Icons.favorite : Icons.favorite_border,
                    color: isWishlisted ? palette.primary : palette.textPrimary,
                    size: 20,
                  ),
            const SizedBox(width: 8),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isWishlisted ? 'Interested' : 'Mark Interested',
                  style: GoogleFonts.outfit(
                    color: isWishlisted ? palette.primary : palette.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    color: palette.textMuted,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactOrganizerButton extends ConsumerStatefulWidget {
  final int? organizerId;
  final String organizerName;
  final String eventTitle;
  final bool supportsContact;

  const _ContactOrganizerButton({
    required this.organizerId,
    required this.organizerName,
    required this.eventTitle,
    required this.supportsContact,
  });

  @override
  ConsumerState<_ContactOrganizerButton> createState() =>
      _ContactOrganizerButtonState();
}

class _ContactOrganizerButtonState
    extends ConsumerState<_ContactOrganizerButton> {
  Future<void> _openContactSheet() async {
    if (widget.organizerId == null || !widget.supportsContact) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Direct contact is not available for this organizer yet.',
          ),
        ),
      );
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ContactOrganizerSheet(
        organizerId: widget.organizerId!,
        organizerName: widget.organizerName,
        eventTitle: widget.eventTitle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.dutyTheme;
    final isEnabled = widget.organizerId != null && widget.supportsContact;

    return GestureDetector(
      onTap: isEnabled ? _openContactSheet : null,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: isEnabled
              ? palette.surfaceAlt
              : palette.surfaceAlt.withValues(alpha: 0.55),
          border: Border.all(
            color: isEnabled
                ? palette.border
                : palette.border.withValues(alpha: 0.6),
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              color: isEnabled ? palette.textPrimary : palette.textSecondary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Contact\nOrganizer',
              style: GoogleFonts.outfit(
                color: isEnabled ? palette.textPrimary : palette.textSecondary,
                fontWeight: FontWeight.bold,
                fontSize: 12,
                height: 1.1,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactOrganizerSheet extends ConsumerStatefulWidget {
  final int organizerId;
  final String organizerName;
  final String eventTitle;

  const _ContactOrganizerSheet({
    required this.organizerId,
    required this.organizerName,
    required this.eventTitle,
  });

  @override
  ConsumerState<_ContactOrganizerSheet> createState() =>
      _ContactOrganizerSheetState();
}

class _ContactOrganizerSheetState
    extends ConsumerState<_ContactOrganizerSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _subjectController;
  late final TextEditingController _messageController;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    final currentUser = ref.read(currentUserProvider);
    final firstName = currentUser?['fname']?.toString().trim() ?? '';
    final lastName = currentUser?['lname']?.toString().trim() ?? '';
    final fullName = [
      firstName,
      lastName,
    ].where((value) => value.isNotEmpty).join(' ').trim();

    _nameController = TextEditingController(text: fullName);
    _emailController = TextEditingController(
      text: currentUser?['email']?.toString().trim() ?? '',
    );
    _subjectController = TextEditingController(
      text: 'Question about ${widget.eventTitle}',
    );
    _messageController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSending) return;
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    setState(() => _isSending = true);

    try {
      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.dio.post(
        AppUrls.sendEmailToOrganizerUrl,
        data: {
          'organizer_id': widget.organizerId,
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'subject': _subjectController.text.trim(),
          'message': _messageController.text.trim(),
        },
      );

      final data = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : <String, dynamic>{};

      if (!mounted) return;

      if (data['success'] == true) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              data['message']?.toString() ??
                  'Your message was sent to the organizer.',
            ),
            backgroundColor: const Color(0xFF20C997),
          ),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            data['message']?.toString() ?? 'We could not send your message.',
          ),
          backgroundColor: kDangerColor,
        ),
      );
    } on DioException catch (error) {
      if (!mounted) return;

      final responseData = error.response?.data;
      String message = 'We could not send your message.';

      if (responseData is Map<String, dynamic>) {
        final errors = responseData['errors'];
        if (errors is Map && errors.isNotEmpty) {
          final firstError = errors.values.first;
          if (firstError is List && firstError.isNotEmpty) {
            message = firstError.first.toString();
          } else if (firstError != null) {
            message = firstError.toString();
          }
        } else if (responseData['message'] != null) {
          message = responseData['message'].toString();
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: kDangerColor),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Something went wrong while sending your message.'),
          backgroundColor: kDangerColor,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.dutyTheme;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border.all(color: palette.border),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 44,
                        height: 5,
                        decoration: BoxDecoration(
                          color: palette.borderStrong,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Contact ${widget.organizerName}',
                      style: GoogleFonts.outfit(
                        color: palette.textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Send a direct question about this event. The organizer will receive it by email.',
                      style: GoogleFonts.inter(
                        color: palette.textSecondary,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _DutyField(
                      controller: _nameController,
                      label: 'Your name',
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your name.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    _DutyField(
                      controller: _emailController,
                      label: 'Email',
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        final email = value?.trim() ?? '';
                        if (email.isEmpty) {
                          return 'Please enter your email.';
                        }
                        if (!RegExp(
                          r'^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$',
                        ).hasMatch(email)) {
                          return 'Enter a valid email address.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    _DutyField(
                      controller: _subjectController,
                      label: 'Subject',
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please add a subject.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    _DutyField(
                      controller: _messageController,
                      label: 'Message',
                      minLines: 5,
                      maxLines: 7,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please write your message.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSending ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: palette.primary,
                          foregroundColor: palette.textPrimary,
                          disabledBackgroundColor: palette.primary.withValues(
                            alpha: 0.45,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _isSending
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    palette.textPrimary,
                                  ),
                                ),
                              )
                            : Text(
                                'Send message',
                                style: GoogleFonts.outfit(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DutyField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final int minLines;
  final int maxLines;

  const _DutyField({
    required this.controller,
    required this.label,
    this.validator,
    this.keyboardType,
    this.minLines = 1,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.dutyTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            color: palette.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          minLines: minLines,
          maxLines: maxLines,
          style: GoogleFonts.inter(color: palette.textPrimary, fontSize: 15),
          decoration: InputDecoration(
            filled: true,
            fillColor: palette.surfaceAlt,
            hintStyle: GoogleFonts.inter(color: palette.textMuted),
            errorStyle: GoogleFonts.inter(color: palette.danger),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(color: palette.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(color: palette.primary, width: 1.4),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(color: palette.danger),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(color: palette.danger),
            ),
          ),
        ),
      ],
    );
  }
}

class _EventSocialPanel extends StatelessWidget {
  const _EventSocialPanel({
    required this.social,
    this.interestedCountOverride,
    this.isViewerInterested = false,
  });

  final EventSocialSummaryModel social;
  final int? interestedCountOverride;
  final bool isViewerInterested;

  @override
  Widget build(BuildContext context) {
    final palette = context.dutyTheme;
    final interestedCount = interestedCountOverride ?? social.interestedCount;
    /*
    final visibleInterestedCount =
        interestedCount < social.visibleInterestedCount
            ? interestedCount
            : social.visibleInterestedCount;
    final highlightedInterested = social.followedInterestedPeople.isNotEmpty
        ? social.followedInterestedPeople
        : social.interestedPeople;
    */

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isViewerInterested) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: palette.primarySurface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: palette.borderStrong),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.favorite, color: palette.primary, size: 16),
                const SizedBox(width: 8),
                Text(
                  'You are interested in this event',
                  style: GoogleFonts.inter(
                    color: palette.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
        ],
        Row(
          children: [
            Expanded(
              child: _SocialMetricCard(
                label: 'Interested',
                value: interestedCount,
                icon: Icons.bookmark_added_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SocialMetricCard(
                label: 'Going',
                value: social.attendingCount,
                icon: Icons.confirmation_num_outlined,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _EventLineupSection extends StatelessWidget {
  const _EventLineupSection({required this.lineup});

  final List<EventLineupModel> lineup;

  @override
  Widget build(BuildContext context) {
    final palette = context.dutyTheme;
    final sortedLineup = [...lineup]
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    final headliner = sortedLineup.cast<EventLineupModel?>().firstWhere(
      (item) => item?.isHeadliner == true,
      orElse: () => sortedLineup.isNotEmpty ? sortedLineup.first : null,
    );
    final supporting = sortedLineup
        .where((item) => headliner == null || item.key != headliner.key)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'LINEUP',
          style: GoogleFonts.outfit(
            color: palette.primary,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Who is playing',
          style: GoogleFonts.outfit(
            color: palette.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.w700,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Discover the artists behind this date and jump into their profiles when available.',
          style: GoogleFonts.inter(
            color: palette.textSecondary,
            fontSize: 13,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 18),
        if (headliner != null) _EventHeadlinerCard(item: headliner),
        if (supporting.isNotEmpty) ...[
          const SizedBox(height: 14),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: supporting
                .map((item) => _EventLineupChip(item: item))
                .toList(),
          ),
        ],
      ],
    );
  }
}

class _EventHeadlinerCard extends StatelessWidget {
  const _EventHeadlinerCard({required this.item});

  final EventLineupModel item;

  @override
  Widget build(BuildContext context) {
    final palette = context.dutyTheme;
    final card = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [palette.surfaceAlt, palette.surface],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: palette.borderStrong),
        boxShadow: [
          BoxShadow(
            color: palette.primaryGlow.withValues(alpha: 0.16),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: palette.surfaceMuted,
              border: Border.all(color: palette.border),
            ),
            child: Icon(
              Icons.graphic_eq_rounded,
              color: palette.warning,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: palette.warning.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    item.badgeLabel,
                    style: GoogleFonts.outfit(
                      color: palette.warning,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.3,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  item.displayName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.outfit(
                    color: palette.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.hasProfile
                      ? 'Tap to open artist profile'
                      : 'Guest appearance listed by the organizer',
                  style: GoogleFonts.inter(
                    color: palette.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (item.hasProfile)
            Padding(
              padding: EdgeInsets.only(left: 12),
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                color: palette.textMuted,
                size: 18,
              ),
            ),
        ],
      ),
    );

    if (!item.hasProfile) {
      return card;
    }

    return GestureDetector(
      onTap: () => context.push('/artist-profile/${item.artistId}'),
      child: card,
    );
  }
}

class _EventLineupChip extends StatelessWidget {
  const _EventLineupChip({required this.item});

  final EventLineupModel item;

  @override
  Widget build(BuildContext context) {
    final palette = context.dutyTheme;
    final chip = Container(
      constraints: const BoxConstraints(minWidth: 152, maxWidth: 260),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: palette.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: palette.primarySurface,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              item.sourceType == 'artist'
                  ? Icons.headphones_rounded
                  : Icons.mic_external_on_rounded,
              color: palette.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.outfit(
                    color: palette.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.hasProfile
                      ? 'Artist profile available'
                      : 'Manual lineup item',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    color: palette.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (item.hasProfile)
            Icon(Icons.north_east_rounded, color: palette.textMuted, size: 18),
        ],
      ),
    );

    if (!item.hasProfile) {
      return chip;
    }

    return GestureDetector(
      onTap: () => context.push('/artist-profile/${item.artistId}'),
      child: chip,
    );
  }
}

class _SocialMetricCard extends StatelessWidget {
  const _SocialMetricCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final int value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final palette = context.dutyTheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [palette.surfaceAlt, palette.surface],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: palette.border),
        boxShadow: [
          BoxShadow(
            color: palette.shadow.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: palette.surfaceMuted,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: palette.border),
            ),
            child: Icon(icon, color: palette.primary),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$value',
                style: GoogleFonts.outfit(
                  color: palette.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: GoogleFonts.inter(
                  color: palette.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
