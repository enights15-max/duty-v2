import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/constants/app_urls.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/widgets/card_setup_sheet.dart';
import '../../../events/presentation/providers/home_provider.dart';
import '../../../shop/presentation/providers/checkout_provider.dart'
    show bookingRepositoryProvider;
import '../../../wallet/presentation/providers/wallet_provider.dart';
import '../providers/marketplace_provider.dart';
import '../../../chat/presentation/providers/chat_provider.dart';

class BlackmarketPage extends ConsumerStatefulWidget {
  const BlackmarketPage({super.key});

  @override
  ConsumerState<BlackmarketPage> createState() => _BlackmarketPageState();
}

class _BlackmarketPageState extends ConsumerState<BlackmarketPage> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: ref.read(marketplaceFiltersProvider).search ?? '',
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.invalidate(marketplaceTicketsProvider);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refreshMarketplace() async {
    ref.invalidate(marketplaceTicketsProvider);
    try {
      await ref.read(marketplaceTicketsProvider.future);
    } catch (_) {
      // The page already renders its own error state if the fetch fails.
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.dutyTheme;
    final ticketsAsync = ref.watch(marketplaceTicketsProvider);
    final filters = ref.watch(marketplaceFiltersProvider);
    final hasEventContext = filters.eventId != null;

    if (_searchController.text != (filters.search ?? '')) {
      _searchController.value = TextEditingValue(
        text: filters.search ?? '',
        selection: TextSelection.collapsed(
          offset: (filters.search ?? '').length,
        ),
      );
    }

    return Scaffold(
      backgroundColor: palette.background,
      body: RefreshIndicator.adaptive(
        color: palette.primary,
        backgroundColor: palette.surface,
        onRefresh: _refreshMarketplace,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              backgroundColor: palette.background,
              floating: true,
              pinned: true,
              elevation: 0,
              title: Text(
                'Blackmarket',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w800,
                  color: palette.textPrimary,
                  fontSize: 24,
                ),
              ),
              actions: [
                IconButton(
                  onPressed: () {
                    _searchController.clear();
                    ref.read(marketplaceFiltersProvider.notifier).state =
                        MarketplaceFilterState();
                    _refreshMarketplace();
                  },
                  icon: Icon(Icons.refresh, color: palette.textSecondary),
                ),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(80),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: palette.surfaceAlt,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: palette.border),
                          ),
                          child: TextField(
                            controller: _searchController,
                            style: TextStyle(color: palette.textPrimary),
                            onChanged: (value) {
                              ref
                                  .read(marketplaceFiltersProvider.notifier)
                                  .state = filters.copyWith(
                                search: value,
                                clearEventContext: value.trim().isEmpty,
                              );
                            },
                            decoration: InputDecoration(
                              hintText: hasEventContext
                                  ? 'Search inside this event...'
                                  : 'Search events...',
                              hintStyle: GoogleFonts.manrope(
                                color: palette.textMuted,
                                fontSize: 14,
                              ),
                              prefixIcon: Icon(
                                Icons.search,
                                color: palette.textMuted,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () => _showFilterBottomSheet(context, ref),
                        child: Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            color: filters.hasFilters
                                ? palette.primary
                                : palette.surfaceAlt,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: filters.hasFilters
                                  ? palette.primary
                                  : palette.border,
                            ),
                          ),
                          child: Icon(
                            Icons.tune,
                            color: filters.hasFilters
                                ? palette.textPrimary
                                : palette.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (hasEventContext)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: palette.surfaceAlt,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: palette.border),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: palette.warning.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.swap_horiz_rounded,
                            color: palette.warning,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Fallback de taquilla agotada',
                                style: GoogleFonts.outfit(
                                  color: palette.textPrimary,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                filters.eventDate == null
                                    ? 'Viendo boletas publicadas en blackmarket para ${filters.eventTitle ?? 'este evento'}.'
                                    : 'Viendo boletas publicadas en blackmarket para ${filters.eventTitle ?? 'este evento'} · ${filters.eventDate}.',
                                style: GoogleFonts.inter(
                                  color: palette.textSecondary,
                                  fontSize: 12.5,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () {
                            _searchController.clear();
                            ref
                                    .read(marketplaceFiltersProvider.notifier)
                                    .state =
                                MarketplaceFilterState();
                            _refreshMarketplace();
                          },
                          icon: Icon(
                            Icons.close_rounded,
                            color: palette.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ticketsAsync.when(
              data: (tickets) => tickets.isEmpty
                  ? SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              hasEventContext
                                  ? Icons.local_activity_outlined
                                  : filters.hasFilters
                                  ? Icons.search_off
                                  : Icons.confirmation_num_outlined,
                              size: 64,
                              color: palette.textMuted.withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              hasEventContext
                                  ? 'No hay reventa activa para este evento todavía'
                                  : filters.hasFilters
                                  ? 'No results found for your filters'
                                  : 'No tickets for sale yet',
                              style: GoogleFonts.manrope(
                                color: palette.textSecondary,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            if (hasEventContext) ...[
                              const SizedBox(height: 10),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 28,
                                ),
                                child: Text(
                                  'La taquilla principal ya se agotó, pero todavía no hay boletas publicadas en blackmarket para ${filters.eventTitle ?? 'este evento'}.',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.manrope(
                                    color: palette.textMuted,
                                    fontSize: 13,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 18),
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                alignment: WrapAlignment.center,
                                children: [
                                  if (filters.eventId != null)
                                    OutlinedButton(
                                      onPressed: () => context.push(
                                        '/event-details/${filters.eventId}',
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: palette.textPrimary,
                                        side: BorderSide(color: palette.border),
                                      ),
                                      child: const Text('Volver al evento'),
                                    ),
                                  TextButton(
                                    onPressed: () {
                                      _searchController.clear();
                                      ref
                                              .read(
                                                marketplaceFiltersProvider
                                                    .notifier,
                                              )
                                              .state =
                                          MarketplaceFilterState();
                                      _refreshMarketplace();
                                    },
                                    child: Text(
                                      'Ver todo blackmarket',
                                      style: TextStyle(color: palette.primary),
                                    ),
                                  ),
                                ],
                              ),
                            ] else if (filters.hasFilters)
                              TextButton(
                                onPressed: () {
                                  _searchController.clear();
                                  ref
                                          .read(
                                            marketplaceFiltersProvider.notifier,
                                          )
                                          .state =
                                      MarketplaceFilterState();
                                  _refreshMarketplace();
                                },
                                child: Text(
                                  'Clear all filters',
                                  style: TextStyle(color: palette.primary),
                                ),
                              ),
                          ],
                        ),
                      ),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.only(
                        left: 20,
                        right: 20,
                        top: 20,
                        bottom: 120, // Add space for bottom nav bar
                      ),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final ticket = tickets[index];
                          return _ResaleTicketCard(
                            ticket: ticket,
                            eventContextTitle: filters.eventTitle,
                          );
                        }, childCount: tickets.length),
                      ),
                    ),
              loading: () => SliverPadding(
                padding: const EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 20,
                  bottom: 120,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => const _ShimmerTicketCard(),
                    childCount: 3,
                  ),
                ),
              ),
              error: (err, stack) => SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'No pudimos cargar el blackmarket ahora mismo. Desliza para reintentar.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.manrope(
                        color: palette.danger,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _BlackmarketFilterPanel(),
    );
  }
}

class _BlackmarketFilterPanel extends ConsumerStatefulWidget {
  const _BlackmarketFilterPanel();

  @override
  ConsumerState<_BlackmarketFilterPanel> createState() =>
      _BlackmarketFilterPanelState();
}

class _BlackmarketFilterPanelState
    extends ConsumerState<_BlackmarketFilterPanel> {
  int? selectedCategoryId;
  RangeValues priceRange = const RangeValues(0, 1000);
  String? selectedSortBy;

  @override
  void initState() {
    super.initState();
    final filters = ref.read(marketplaceFiltersProvider);
    selectedCategoryId = filters.categoryId;
    priceRange = RangeValues(filters.minPrice ?? 0, filters.maxPrice ?? 1000);
    selectedSortBy = filters.sortBy;
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.dutyTheme;
    final categoriesAsync = ref.watch(categoriesProvider);

    return Container(
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(color: palette.border),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filters',
                style: GoogleFonts.manrope(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: palette.textPrimary,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.close, color: palette.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Category',
            style: GoogleFonts.manrope(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: palette.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          categoriesAsync.when(
            data: (categories) => SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterChip(
                    label: 'All',
                    isSelected: selectedCategoryId == null,
                    onTap: () => setState(() => selectedCategoryId = null),
                  ),
                  ...categories.map(
                    (cat) => _FilterChip(
                      label: cat['name'],
                      isSelected: selectedCategoryId == cat['id'],
                      onTap: () =>
                          setState(() => selectedCategoryId = cat['id']),
                    ),
                  ),
                ],
              ),
            ),
            loading: () => LinearProgressIndicator(color: palette.primary),
            error: (_, _) => Text(
              'Error loading categories',
              style: GoogleFonts.manrope(color: palette.danger),
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Price Range',
                style: GoogleFonts.manrope(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: palette.textSecondary,
                ),
              ),
              Text(
                '\$${priceRange.start.round()} - \$${priceRange.end.round()}',
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  color: palette.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          RangeSlider(
            values: priceRange,
            min: 0,
            max: 1000,
            activeColor: palette.primary,
            inactiveColor: palette.border,
            onChanged: (values) => setState(() => priceRange = values),
          ),
          const SizedBox(height: 32),
          Text(
            'Sort by',
            style: GoogleFonts.manrope(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: palette.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _FilterChip(
                  label: 'Default',
                  isSelected: selectedSortBy == null,
                  onTap: () => setState(() => selectedSortBy = null),
                ),
                _FilterChip(
                  label: 'Price: Low to High',
                  isSelected: selectedSortBy == 'price_asc',
                  onTap: () => setState(() => selectedSortBy = 'price_asc'),
                ),
                _FilterChip(
                  label: 'Price: High to Low',
                  isSelected: selectedSortBy == 'price_desc',
                  onTap: () => setState(() => selectedSortBy = 'price_desc'),
                ),
                _FilterChip(
                  label: 'Soonest First',
                  isSelected: selectedSortBy == 'date_asc',
                  onTap: () => setState(() => selectedSortBy = 'date_asc'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () {
                    ref.read(marketplaceFiltersProvider.notifier).state =
                        MarketplaceFilterState();
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Reset',
                    style: TextStyle(color: palette.textMuted),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: palette.primary,
                    foregroundColor: palette.textPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    final currentFilters = ref.read(marketplaceFiltersProvider);
                    ref
                        .read(marketplaceFiltersProvider.notifier)
                        .state = currentFilters.copyWith(
                      categoryId: selectedCategoryId,
                      minPrice: priceRange.start,
                      maxPrice: priceRange.end,
                      sortBy: selectedSortBy,
                      clearCategory: selectedCategoryId == null,
                      clearSort: selectedSortBy == null,
                    );
                    Navigator.pop(context);
                  },
                  child: const Text('Apply Filters'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.dutyTheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? palette.primary : palette.surfaceAlt,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? palette.primary : palette.border,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.manrope(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? palette.textPrimary : palette.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _ResaleTicketCard extends ConsumerWidget {
  final Map<String, dynamic> ticket;
  final String? eventContextTitle;

  const _ResaleTicketCard({required this.ticket, this.eventContextTitle});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.dutyTheme;
    final event = ticket['event'];
    final price = double.tryParse(ticket['price']?.toString() ?? '0') ?? 0.0;
    final originalPrice =
        double.tryParse(ticket['original_price']?.toString() ?? '0') ?? 0.0;
    final seller = ticket['seller'];
    final eventTitle = event['title']?.toString() ?? 'Event';
    final isContextualView =
        eventContextTitle != null &&
        eventContextTitle!.trim().isNotEmpty &&
        eventContextTitle!.trim() == eventTitle.trim();
    final walletAsync = ref.watch(walletProvider);
    final paymentMethodsAsync = ref.watch(paymentMethodsProvider);
    final walletBalance = walletAsync.maybeWhen(
      data: (wallet) => double.tryParse('${wallet['balance'] ?? 0}') ?? 0.0,
      orElse: () => 0.0,
    );
    final hasSavedCards = paymentMethodsAsync.maybeWhen(
      data: (methods) => methods.isNotEmpty,
      orElse: () => false,
    );
    final hasWalletSnapshot = walletAsync.hasValue;
    final hasCardsSnapshot = paymentMethodsAsync.hasValue;
    final needsFundingSetup =
        hasWalletSnapshot &&
        hasCardsSnapshot &&
        walletBalance + 0.009 < price &&
        !hasSavedCards;

    final savingsPercent = originalPrice > price
        ? (((originalPrice - price) / originalPrice) * 100).round()
        : 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: palette.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Column(
            children: [
              Stack(
                children: [
                  // Event Image
                  GestureDetector(
                    onTap: () {
                      final eventId = event['id'];
                      if (eventId != null) {
                        context.push('/event-details/$eventId');
                      }
                    },
                    child: CachedNetworkImage(
                      imageUrl:
                          AppUrls.getEventThumbnailUrl(event['thumbnail']) ??
                          '',
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          const _ShimmerBox(height: 180),
                      errorWidget: (context, url, error) => Container(
                        height: 180,
                        color: palette.surfaceAlt,
                        child: Icon(
                          Icons.broken_image,
                          color: palette.textMuted,
                        ),
                      ),
                    ),
                  ),
                  // Badges Row
                  Positioned(
                    top: 16,
                    left: 16,
                    right: 16,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: palette.primary,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: palette.primaryGlow.withValues(
                                  alpha: 0.3,
                                ),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Text(
                            'RESALE',
                            style: GoogleFonts.manrope(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: palette.textPrimary,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            if (savingsPercent > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: palette.success,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '- $savingsPercent%',
                                  style: GoogleFonts.manrope(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: palette.background,
                                  ),
                                ),
                              ),
                            const SizedBox(width: 8),
                            _IconButton(
                              icon: Icons.share_rounded,
                              onTap: () {
                                final eventTitle = event['title'] ?? 'Event';
                                final url =
                                    'https://duty.do/marketplace/${ticket['id']}';
                                SharePlus.instance.share(
                                  ShareParams(
                                    text:
                                        '¡Mira este ticket para $eventTitle en Duty! Solo por \$$price\n$url',
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 8),
                            Consumer(
                              builder: (context, ref, child) {
                                final favorites = ref.watch(favoritesProvider);
                                final ticketId = ticket['id'].toString();
                                final isFav = favorites.contains(ticketId);
                                return _IconButton(
                                  icon: isFav
                                      ? Icons.favorite_rounded
                                      : Icons.favorite_border_rounded,
                                  iconColor: isFav
                                      ? palette.danger
                                      : palette.textPrimary,
                                  onTap: () => ref
                                      .read(favoritesProvider.notifier)
                                      .toggleFavorite(ticketId),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Trust Badge
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: palette.surfaceMuted.withValues(alpha: 0.86),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: palette.border),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.verified_user_rounded,
                            color: palette.info,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Verified',
                            style: GoogleFonts.manrope(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: palette.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Urgency Timer (New)
                  if (_isImminent(event['date']))
                    Positioned(
                      bottom: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: palette.danger.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: palette.danger.withValues(alpha: 0.3),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.timer_outlined,
                              color: Colors.white,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'STARTING SOON',
                              style: GoogleFonts.manrope(
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  // Sold Out Overlay
                  if (ticket['status'] == 'sold' ||
                      (ticket['is_sold'] ?? false))
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: palette.shadow.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: palette.danger,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: palette.danger.withValues(alpha: 0.4),
                                  blurRadius: 20,
                                ),
                              ],
                            ),
                            child: Text(
                              'SOLD OUT',
                              style: GoogleFonts.manrope(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: palette.textPrimary,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Security Badge
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: palette.info.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: palette.info.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.verified_user_rounded,
                            size: 10,
                            color: palette.info,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Secure & Verified Transaction',
                            style: GoogleFonts.manrope(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: palette.info,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        final eventId = event['id'];
                        if (eventId != null) {
                          context.push('/event-details/$eventId');
                        }
                      },
                      child: Text(
                        eventTitle,
                        style: GoogleFonts.manrope(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: palette.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    if (isContextualView) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: palette.warning.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: palette.warning.withValues(alpha: 0.18),
                          ),
                        ),
                        child: Text(
                          'Taquilla agotada · viendo fallback de este evento',
                          style: GoogleFonts.outfit(
                            color: palette.warning,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 12,
                          color: palette.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          event['date'] ?? '',
                          style: GoogleFonts.manrope(
                            fontSize: 13,
                            color: palette.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    if (event['organizer'] != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.business_center_rounded,
                            size: 12,
                            color: palette.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            event?['organizer']?['name'] ??
                                event?['organizer']?.toString() ??
                                'Organizer',
                            style: GoogleFonts.manrope(
                              fontSize: 12,
                              color: palette.primary.withValues(alpha: 0.9),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 20),
                    // Seller & Price Row
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () async {
                            final sId = await _resolveSellerId(ref);
                            if (sId != null && context.mounted) {
                              ScaffoldMessenger.of(
                                context,
                              ).hideCurrentSnackBar();
                              context.push('/user-profile/$sId');
                            }
                          },
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor: palette.surfaceMuted,
                            backgroundImage:
                                AppUrls.getAvatarUrl(seller?['photo']) != null
                                ? CachedNetworkImageProvider(
                                    AppUrls.getAvatarUrl(seller?['photo'])!,
                                  )
                                : null,
                            child: seller?['photo'] == null
                                ? Icon(
                                    Icons.person,
                                    size: 18,
                                    color: palette.textSecondary,
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  final sId = await _resolveSellerId(ref);
                                  if (sId != null && context.mounted) {
                                    ScaffoldMessenger.of(
                                      context,
                                    ).hideCurrentSnackBar();
                                    context.push('/user-profile/$sId');
                                  }
                                },
                                child: Text(
                                  seller?['name'] ?? 'User',
                                  style: GoogleFonts.manrope(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: palette.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.star_rounded,
                                    size: 12,
                                    color: palette.warning,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    '${seller?['avg_rating'] ?? seller?['rating'] ?? '4.8'} (${seller?['total_sales'] ?? seller?['sales_count'] ?? '12'} sales)',
                                    style: GoogleFonts.manrope(
                                      fontSize: 11,
                                      color: palette.textSecondary.withValues(
                                        alpha: 0.8,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (originalPrice > price)
                              Text(
                                '\$$originalPrice',
                                style: GoogleFonts.manrope(
                                  decoration: TextDecoration.lineThrough,
                                  color: palette.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            Text(
                              '\$$price',
                              style: GoogleFonts.manrope(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: palette.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    if (needsFundingSetup) ...[
                      Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: palette.warning.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: palette.warning.withValues(alpha: 0.18),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              color: palette.warning,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Tu wallet no alcanza y no tienes una tarjeta guardada para completar esta reventa.',
                                style: GoogleFonts.manrope(
                                  fontSize: 11.5,
                                  color: palette.textSecondary,
                                  height: 1.35,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    // Buttons Row
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _handleContactSeller(context, ref),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: palette.border),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.chat_bubble_outline_rounded,
                                  size: 18,
                                  color: palette.textPrimary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Chat',
                                  style: GoogleFonts.manrope(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: palette.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: () => needsFundingSetup
                                ? _showFundingGateDialog(
                                    context,
                                    ref,
                                    walletBalance: walletBalance,
                                    ticketPrice: price,
                                  )
                                : _handlePurchase(context, ref),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: needsFundingSetup
                                  ? palette.surfaceMuted
                                  : palette.primary,
                              foregroundColor: palette.textPrimary,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              needsFundingSetup
                                  ? 'Agregar fondos o tarjeta'
                                  : 'Buy Ticket',
                              style: GoogleFonts.manrope(
                                fontSize: needsFundingSetup ? 13 : 14,
                                fontWeight: FontWeight.w800,
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
      ),
    );
  }

  bool _isImminent(String? dateStr) {
    if (dateStr == null) return false;
    try {
      // Very basic check - if it contains 'Today' or is within next 24h
      // For now, simple string check as date format might vary
      final lower = dateStr.toLowerCase();
      return lower.contains('today') ||
          lower.contains('tomorrow') ||
          lower.contains('now');
    } catch (_) {
      return false;
    }
  }

  Future<int?> _resolveSellerId(WidgetRef ref) async {
    // 1. Try immediate extraction
    int? sId = _getSellerId();
    if (sId != null && sId > 0) return sId;

    // 2. Fallback: Resolve via username if available
    final seller = ticket['seller'];
    if (seller is Map && seller['username'] != null) {
      final username = seller['username'].toString();
      try {
        final userData = await ref
            .read(marketplaceProvider.notifier)
            .verifyRecipient(recipient: username);
        if (userData != null && userData['id'] != null) {
          return int.tryParse(userData['id'].toString());
        }
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  int? _getSellerId() {
    final seller = ticket['seller'];
    int? sellerId;

    // 1. Try to find ID in the seller object (if it's a map)
    if (seller is Map) {
      final dynamic preferredId =
          seller['id'] ?? seller['user_id'] ?? seller['userId'];
      if (preferredId != null) {
        sellerId = int.tryParse(preferredId.toString());
      }

      if (sellerId == null || sellerId <= 0) {
        for (var key in seller.keys) {
          if (key.toString().toLowerCase().contains('id')) {
            final val = int.tryParse(seller[key]?.toString() ?? '');
            if (val != null && val > 0) {
              sellerId = val;
              break;
            }
          }
        }
      }
    }

    // 2. Fallback: try ticket root
    if (sellerId == null || sellerId <= 0) {
      final dynamic rootId =
          ticket['seller_id'] ?? ticket['user_id'] ?? ticket['userId'];
      if (rootId != null) {
        sellerId = int.tryParse(rootId.toString());
      }
    }

    // 3. Last resort: if seller is just an ID
    if (sellerId == null || sellerId <= 0) {
      if (seller is int) sellerId = seller;
      if (seller is String) sellerId = int.tryParse(seller);
    }

    return sellerId;
  }

  Future<void> _handleContactSeller(BuildContext context, WidgetRef ref) async {
    // Show a small loading indicator if we need to resolve
    final immediateId = _getSellerId();
    if (immediateId == null || immediateId <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Resolving seller information...'),
          duration: Duration(seconds: 1),
        ),
      );
    }

    final sellerId = await _resolveSellerId(ref);

    if (sellerId == null || sellerId <= 0) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Seller information not available')),
        );
      }
      return;
    }

    final chat = await ref
        .read(chatActionProvider.notifier)
        .startChat(targetId: sellerId, targetType: 'user');

    if (chat != null && context.mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      context.push('/chat-room', extra: chat);
    } else if (context.mounted) {
      final error = ref.read(chatActionProvider.notifier).lastError;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Failed to start chat. Are you logged in?'),
        ),
      );
    }
  }

  String _moneyLabel(dynamic value) {
    final amount = double.tryParse(value?.toString() ?? '0') ?? 0;
    return '\$${amount.toStringAsFixed(2)}';
  }

  Future<void> _handlePurchase(BuildContext context, WidgetRef ref) async {
    final palette = context.dutyTheme;
    final messenger = ScaffoldMessenger.of(context);
    final rootNavigator = Navigator.of(context, rootNavigator: true);
    final bookingRepository = ref.read(bookingRepositoryProvider);

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          Center(child: CircularProgressIndicator(color: palette.primary)),
    );

    final savedCards = await bookingRepository.getPaymentMethods();
    final initialCardId = savedCards.isNotEmpty
        ? savedCards.first['stripe_payment_method_id']?.toString()
        : null;
    final preview = await ref
        .read(marketplaceProvider.notifier)
        .previewPurchase(
          bookingId: ticket['id'],
          applyWalletBalance: true,
          stripePaymentMethodId: initialCardId,
        );

    if (context.mounted) {
      rootNavigator.pop();
    }

    if (preview == null || !context.mounted) {
      final error =
          ref.read(marketplaceProvider.notifier).lastError ??
          'No pudimos preparar el resumen de esta reventa ahora mismo.';
      messenger.showSnackBar(
        SnackBar(content: Text(error), backgroundColor: palette.danger),
      );
      return;
    }

    var useWallet = true;
    var availableCards = List<Map<String, dynamic>>.from(savedCards);
    String? selectedCardId = initialCardId;
    Map<String, dynamic>? previewData = preview;
    bool loadingPreview = false;
    bool submitting = false;

    await showDialog(
      context: context,
      builder: (dialogContext) {
        Future<void> refreshPreview(StateSetter setState) async {
          setState(() => loadingPreview = true);
          final latest = await ref
              .read(marketplaceProvider.notifier)
              .previewPurchase(
                bookingId: ticket['id'],
                applyWalletBalance: useWallet,
                stripePaymentMethodId: selectedCardId,
              );
          if (!dialogContext.mounted) return;
          setState(() {
            previewData = latest;
            loadingPreview = false;
          });
        }

        Future<void> addCard(StateSetter setState) async {
          final clientSecret = await bookingRepository.createSetupIntent();
          if (!dialogContext.mounted) return;
          final success = await CardSetupSheet.show(
            context: dialogContext,
            clientSecret: clientSecret,
            title: 'Guardar tarjeta',
          );
          if (!success) return;
          final methods = await bookingRepository.getPaymentMethods();
          if (!dialogContext.mounted) return;
          setState(() {
            availableCards = List<Map<String, dynamic>>.from(methods);
            selectedCardId = availableCards.isNotEmpty
                ? availableCards.first['stripe_payment_method_id']?.toString()
                : null;
          });
          await refreshPreview(setState);
        }

        return StatefulBuilder(
          builder: (context, setState) {
            final paymentSummary = previewData?['payment_summary'] is Map
                ? Map<String, dynamic>.from(
                    previewData!['payment_summary'] as Map,
                  )
                : <String, dynamic>{};
            final canPurchase = previewData?['can_purchase'] == true;
            final walletBalance =
                (previewData?['wallet_balance'] as num?)?.toDouble() ?? 0;
            final requiresCard = paymentSummary['requires_card'] == true;
            final processingFee =
                (paymentSummary['processing_fee'] as num?)?.toDouble() ?? 0;
            final cardTotal =
                (paymentSummary['card_total_charge'] as num?)?.toDouble() ?? 0;

            return AlertDialog(
              backgroundColor: palette.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              title: Text(
                'Confirmar compra',
                style: GoogleFonts.manrope(
                  color: palette.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Puedes usar wallet y cubrir el remanente con tarjeta si hace falta. El resumen final siempre viene del servidor.',
                      style: GoogleFonts.manrope(
                        color: palette.textSecondary,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      value: useWallet,
                      activeThumbColor: palette.primary,
                      activeTrackColor: palette.primary.withValues(alpha: 0.35),
                      title: Text(
                        'Usar wallet',
                        style: GoogleFonts.manrope(color: palette.textPrimary),
                      ),
                      subtitle: Text(
                        'Disponible ${_moneyLabel(walletBalance)}',
                        style: GoogleFonts.manrope(
                          color: palette.textSecondary,
                        ),
                      ),
                      onChanged: loadingPreview
                          ? null
                          : (value) {
                              setState(() => useWallet = value);
                              refreshPreview(setState);
                            },
                    ),
                    if (requiresCard) ...[
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        initialValue: selectedCardId,
                        dropdownColor: palette.surfaceAlt,
                        style: GoogleFonts.manrope(color: palette.textPrimary),
                        decoration: InputDecoration(
                          labelText: 'Tarjeta para el remanente',
                          labelStyle: GoogleFonts.manrope(
                            color: palette.textSecondary,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: palette.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: palette.primary),
                          ),
                        ),
                        items: availableCards
                            .map(
                              (card) => DropdownMenuItem<String>(
                                value: card['stripe_payment_method_id']
                                    ?.toString(),
                                child: Text(
                                  '${(card['brand'] ?? 'card').toString().toUpperCase()} •••• ${card['last4'] ?? '****'}',
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: loadingPreview
                            ? null
                            : (value) {
                                setState(() => selectedCardId = value);
                                refreshPreview(setState);
                              },
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: loadingPreview
                              ? null
                              : () => addCard(setState),
                          icon: Icon(
                            Icons.add_card_rounded,
                            color: palette.textPrimary,
                          ),
                          label: Text(
                            'Agregar tarjeta',
                            style: GoogleFonts.manrope(
                              color: palette.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    _buildSummaryLine(
                      context,
                      'Precio de reventa',
                      _moneyLabel(paymentSummary['subtotal']),
                    ),
                    const SizedBox(height: 8),
                    _buildSummaryLine(
                      context,
                      'Wallet aplicado',
                      _moneyLabel(paymentSummary['wallet_amount']),
                    ),
                    const SizedBox(height: 8),
                    _buildSummaryLine(
                      context,
                      'Cargo a tarjeta',
                      _moneyLabel(paymentSummary['card_total_charge']),
                    ),
                    if (processingFee > 0.009) ...[
                      const SizedBox(height: 8),
                      _buildSummaryLine(
                        context,
                        'Processing fee',
                        _moneyLabel(processingFee),
                      ),
                    ],
                    const SizedBox(height: 8),
                    _buildSummaryLine(
                      context,
                      'Recibe el seller',
                      _moneyLabel(
                        previewData?['seller_summary']?['net_amount'],
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildSummaryLine(
                      context,
                      'Total a pagar',
                      _moneyLabel(paymentSummary['total_to_pay']),
                      isTotal: true,
                    ),
                    if (requiresCard && selectedCardId == null) ...[
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: palette.danger.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: palette.danger.withValues(alpha: 0.24),
                          ),
                        ),
                        child: Text(
                          'Necesitas seleccionar una tarjeta guardada para cubrir ${_moneyLabel(cardTotal)}.',
                          style: GoogleFonts.manrope(
                            color: palette.textPrimary,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                    if (loadingPreview) ...[
                      const SizedBox(height: 14),
                      Center(
                        child: CircularProgressIndicator(
                          color: palette.primary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: submitting ? null : () => Navigator.pop(context),
                  child: Text(
                    'Cancelar',
                    style: GoogleFonts.manrope(color: palette.textMuted),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        (!canPurchase || loadingPreview || submitting)
                        ? palette.surfaceMuted
                        : palette.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: (loadingPreview || submitting)
                      ? null
                      : () async {
                          if (requiresCard && selectedCardId == null) {
                            await addCard(setState);
                            return;
                          }

                          if (!canPurchase) {
                            final error =
                                ref
                                    .read(marketplaceProvider.notifier)
                                    .lastError ??
                                'No pudimos completar la compra de esta reventa.';
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text(error),
                                backgroundColor: palette.danger,
                              ),
                            );
                            return;
                          }

                          setState(() => submitting = true);
                          await ref
                              .read(marketplaceProvider.notifier)
                              .purchaseTicket(
                                bookingId: ticket['id'],
                                applyWalletBalance: useWallet,
                                stripePaymentMethodId: selectedCardId,
                              );
                          if (!context.mounted) return;
                          final state = ref.read(marketplaceProvider);
                          Navigator.pop(context);

                          if (state.hasError) {
                            final error =
                                ref
                                    .read(marketplaceProvider.notifier)
                                    .lastError ??
                                'No pudimos completar la compra de esta reventa.';
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text(error),
                                backgroundColor: palette.danger,
                              ),
                            );
                          } else {
                            messenger.showSnackBar(
                              SnackBar(
                                content: const Text(
                                  'Ticket purchased successfully!',
                                ),
                                backgroundColor: palette.success,
                              ),
                            );
                          }
                        },
                  child: Text(
                    requiresCard && selectedCardId == null
                        ? 'Agregar tarjeta'
                        : 'Confirmar compra',
                    style: GoogleFonts.manrope(
                      color: palette.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showFundingGateDialog(
    BuildContext context,
    WidgetRef ref, {
    required double walletBalance,
    required double ticketPrice,
  }) async {
    final palette = context.dutyTheme;
    final bookingRepository = ref.read(bookingRepositoryProvider);

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: palette.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(
            'Completa tu método de pago',
            style: GoogleFonts.manrope(
              color: palette.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Esta reventa cuesta ${_moneyLabel(ticketPrice)} y tu wallet disponible es ${_moneyLabel(walletBalance)}. Para comprarla ahora mismo necesitas agregar fondos o guardar una tarjeta para cubrir el remanente.',
            style: GoogleFonts.manrope(
              color: palette.textSecondary,
              height: 1.45,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Ahora no',
                style: GoogleFonts.manrope(color: palette.textMuted),
              ),
            ),
            TextButton.icon(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                if (!context.mounted) return;
                final clientSecret = await bookingRepository
                    .createSetupIntent();
                if (!context.mounted) return;
                final success = await CardSetupSheet.show(
                  context: context,
                  clientSecret: clientSecret,
                  title: 'Guardar tarjeta',
                );
                if (success) {
                  ref.invalidate(paymentMethodsProvider);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Tarjeta guardada. Ya puedes volver a comprar esta reventa.',
                      ),
                      backgroundColor: palette.success,
                    ),
                  );
                }
              },
              icon: Icon(Icons.add_card_rounded, color: palette.textPrimary),
              label: Text(
                'Guardar tarjeta',
                style: GoogleFonts.manrope(color: palette.textPrimary),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                if (context.mounted) {
                  context.push('/wallet');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: palette.primary,
                foregroundColor: palette.textPrimary,
              ),
              child: Text(
                'Agregar fondos',
                style: GoogleFonts.manrope(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSummaryLine(
    BuildContext context,
    String label,
    String value, {
    bool isTotal = false,
  }) {
    final palette = context.dutyTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.manrope(
            color: isTotal ? palette.textPrimary : palette.textSecondary,
            fontSize: isTotal ? 15 : 13,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.manrope(
            color: isTotal ? palette.primary : palette.textPrimary,
            fontSize: isTotal ? 18 : 14,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;

  const _IconButton({required this.icon, required this.onTap, this.iconColor});

  @override
  Widget build(BuildContext context) {
    final palette = context.dutyTheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: palette.surfaceMuted.withValues(alpha: 0.82),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: palette.border),
        ),
        child: Icon(icon, size: 16, color: iconColor ?? palette.textPrimary),
      ),
    );
  }
}

class _ShimmerTicketCard extends StatelessWidget {
  const _ShimmerTicketCard();

  @override
  Widget build(BuildContext context) {
    final palette = context.dutyTheme;
    return Shimmer.fromColors(
      baseColor: palette.surfaceAlt,
      highlightColor: palette.surfaceMuted,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        height: 400,
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(28),
        ),
      ),
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  final double height;

  const _ShimmerBox({required this.height});

  @override
  Widget build(BuildContext context) {
    final palette = context.dutyTheme;
    return Shimmer.fromColors(
      baseColor: palette.surfaceAlt,
      highlightColor: palette.surfaceMuted,
      child: Container(
        height: height,
        width: double.infinity,
        color: palette.surface,
      ),
    );
  }
}
