import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/colors.dart';
import '../../../events/presentation/providers/home_provider.dart';
import '../providers/marketplace_provider.dart';

class MarketplacePage extends ConsumerWidget {
  const MarketplacePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ticketsAsync = ref.watch(marketplaceTicketsProvider);
    final filters = ref.watch(marketplaceFiltersProvider);

    return Scaffold(
      backgroundColor: kBackgroundDark,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: kBackgroundDark,
            floating: true,
            pinned: true,
            elevation: 0,
            title: Text(
              'Marketplace',
              style: GoogleFonts.manrope(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            actions: [
              IconButton(
                onPressed: () {
                  ref.read(marketplaceFiltersProvider.notifier).state =
                      MarketplaceFilterState();
                  ref.invalidate(marketplaceTicketsProvider);
                },
                icon: const Icon(Icons.refresh, color: Colors.white70),
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
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        child: TextField(
                          style: const TextStyle(color: Colors.white),
                          onChanged: (value) {
                            ref
                                .read(marketplaceFiltersProvider.notifier)
                                .state = filters.copyWith(
                              search: value,
                            );
                          },
                          decoration: InputDecoration(
                            hintText: 'Search events...',
                            hintStyle: GoogleFonts.manrope(
                              color: Colors.white38,
                              fontSize: 14,
                            ),
                            prefixIcon: const Icon(
                              Icons.search,
                              color: Colors.white38,
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
                              ? kPrimaryColor
                              : Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        child: Icon(
                          Icons.tune,
                          color: filters.hasFilters
                              ? Colors.white
                              : Colors.white70,
                        ),
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
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            filters.hasFilters
                                ? Icons.search_off
                                : Icons.confirmation_num_outlined,
                            size: 64,
                            color: Colors.white.withOpacity(0.1),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            filters.hasFilters
                                ? 'No results found for your filters'
                                : 'No tickets for sale yet',
                            style: GoogleFonts.manrope(
                              color: Colors.white54,
                              fontSize: 16,
                            ),
                          ),
                          if (filters.hasFilters)
                            TextButton(
                              onPressed: () {
                                ref
                                        .read(
                                          marketplaceFiltersProvider.notifier,
                                        )
                                        .state =
                                    MarketplaceFilterState();
                              },
                              child: const Text(
                                'Clear all filters',
                                style: TextStyle(color: kPrimaryColor),
                              ),
                            ),
                        ],
                      ),
                    ),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.all(20),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final ticket = tickets[index];
                        return _ResaleTicketCard(ticket: ticket);
                      }, childCount: tickets.length),
                    ),
                  ),
            loading: () => const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(color: kPrimaryColor),
              ),
            ),
            error: (err, stack) => SliverFillRemaining(
              child: Center(
                child: Text(
                  'Error loading marketplace: $err',
                  style: const TextStyle(color: Colors.redAccent),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _MarketplaceFilterPanel(),
    );
  }
}

class _MarketplaceFilterPanel extends ConsumerStatefulWidget {
  const _MarketplaceFilterPanel();

  @override
  ConsumerState<_MarketplaceFilterPanel> createState() =>
      _MarketplaceFilterPanelState();
}

class _MarketplaceFilterPanelState
    extends ConsumerState<_MarketplaceFilterPanel> {
  int? selectedCategoryId;
  RangeValues priceRange = const RangeValues(0, 1000);

  @override
  void initState() {
    super.initState();
    final filters = ref.read(marketplaceFiltersProvider);
    selectedCategoryId = filters.categoryId;
    priceRange = RangeValues(filters.minPrice ?? 0, filters.maxPrice ?? 1000);
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF151022),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
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
                  color: Colors.white,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Category',
            style: GoogleFonts.manrope(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
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
            loading: () => const LinearProgressIndicator(color: kPrimaryColor),
            error: (_, __) => const Text('Error loading categories'),
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
                  color: Colors.white70,
                ),
              ),
              Text(
                '\$${priceRange.start.round()} - \$${priceRange.end.round()}',
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  color: kPrimaryColor,
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
            activeColor: kPrimaryColor,
            inactiveColor: Colors.white10,
            onChanged: (values) => setState(() => priceRange = values),
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
                  child: const Text(
                    'Reset',
                    style: TextStyle(color: Colors.white54),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    foregroundColor: Colors.white,
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
                      clearCategory: selectedCategoryId == null,
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? kPrimaryColor : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? kPrimaryColor : Colors.white.withOpacity(0.1),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.manrope(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.white : Colors.white70,
          ),
        ),
      ),
    );
  }
}

class _ResaleTicketCard extends ConsumerWidget {
  final Map<String, dynamic> ticket;

  const _ResaleTicketCard({required this.ticket});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final event = ticket['event'];
    final price = double.tryParse(ticket['price']?.toString() ?? '0') ?? 0.0;
    final originalPrice =
        double.tryParse(ticket['original_price']?.toString() ?? '0') ?? 0.0;
    final seller = ticket['seller'];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          children: [
            Stack(
              children: [
                // Event Image
                CachedNetworkImage(
                  imageUrl: event['thumbnail'] ?? '',
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: 150,
                    color: Colors.white10,
                    child: const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white24,
                        ),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 150,
                    color: Colors.white10,
                    child: const Icon(
                      Icons.broken_image,
                      color: Colors.white24,
                    ),
                  ),
                ),
                // Badge
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: kPrimaryColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'RESALE',
                      style: GoogleFonts.manrope(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event['title'] ?? 'Event',
                    style: GoogleFonts.manrope(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    event['date'] ?? '',
                    style: GoogleFonts.manrope(
                      fontSize: 13,
                      color: Colors.white54,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.white12,
                        backgroundImage: seller['photo'] != null
                            ? NetworkImage(seller['photo'])
                            : null,
                        child: seller['photo'] == null
                            ? const Icon(
                                Icons.person,
                                size: 14,
                                color: Colors.white70,
                              )
                            : null,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Sold by ${seller['name']}',
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                      const Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (originalPrice > price)
                            Text(
                              '\$$originalPrice',
                              style: const TextStyle(
                                decoration: TextDecoration.lineThrough,
                                color: Colors.white24,
                                fontSize: 12,
                              ),
                            ),
                          Text(
                            '\$$price',
                            style: GoogleFonts.manrope(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: kPrimaryColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _handlePurchase(context, ref),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text('Buy Ticket'),
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

  void _handlePurchase(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF151022),
        title: const Text(
          'Confirm Purchase',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to buy this ticket for \$${ticket['price']} using your wallet balance?',
          style: const TextStyle(color: Colors.white70),
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
            style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
            onPressed: () async {
              Navigator.pop(context);

              await ref
                  .read(marketplaceProvider.notifier)
                  .purchaseTicket(bookingId: ticket['id']);

              final state = ref.read(marketplaceProvider);
              if (state.hasError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Purchase failed: ${state.error}'),
                    backgroundColor: Colors.red,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Ticket purchased successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}
