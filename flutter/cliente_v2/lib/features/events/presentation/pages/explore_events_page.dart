import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/cupertino.dart';
import '../../../../core/widgets/cached_image.dart';
import '../providers/home_provider.dart';
import '../../data/models/event_model.dart';

final isExploreGridViewProvider = StateProvider<bool>((ref) => true);
final exploreSearchQueryProvider = StateProvider<String>((ref) => '');
final explorePriceFilterProvider = StateProvider<String>((ref) => 'All'); // All, Free, Paid

final filteredExploreEventsProvider = Provider<AsyncValue<List<EventModel>>>((ref) {
  final eventsAsync = ref.watch(homeEventsProvider);
  final query = ref.watch(exploreSearchQueryProvider).toLowerCase().trim();
  final priceFilter = ref.watch(explorePriceFilterProvider);

  return eventsAsync.whenData((events) {
    return events.where((event) {
      // Search matching
      final matchTitle = event.title.toLowerCase().contains(query);
      final matchOrg = event.organizer?.toLowerCase().contains(query) ?? false;
      final matchVenue = event.address?.toLowerCase().contains(query) ?? false;
      final matchesSearch = query.isEmpty || matchTitle || matchOrg || matchVenue;
      if (!matchesSearch) return false;

      // Price matching
      final startPriceStr = event.startPrice?.toString().toLowerCase() ?? 'free';
      final isFree = startPriceStr == 'free' || startPriceStr == '0' || startPriceStr == '0.0' || startPriceStr == '0.00';
      if (priceFilter == 'Free' && !isFree) return false;
      if (priceFilter == 'Paid' && isFree) return false;

      return true;
    }).toList();
  });
});

class ExploreEventsPage extends ConsumerWidget {
  const ExploreEventsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredEventsAsyncValue = ref.watch(filteredExploreEventsProvider);
    final isGrid = ref.watch(isExploreGridViewProvider);
    final currentPriceFilter = ref.watch(explorePriceFilterProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F1A),
        elevation: 0,
        title: Text(
          'EXPLORE EVENTS',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.grid_view_rounded,
              color: isGrid ? const Color(0xFF6200EE) : Colors.grey,
            ),
            onPressed: () => ref.read(isExploreGridViewProvider.notifier).state = true,
          ),
          IconButton(
            icon: Icon(
              Icons.view_list_rounded,
              color: !isGrid ? const Color(0xFF6200EE) : Colors.grey,
            ),
            onPressed: () => ref.read(isExploreGridViewProvider.notifier).state = false,
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
                      style: GoogleFonts.outfit(color: Colors.white70, fontSize: 16),
                    ),
                  );
                }

                if (isGrid) {
                  return GridView.builder(
                    padding: const EdgeInsets.all(24),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.7,
                    ),
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      return _buildEventGridCard(context, events[index]);
                    },
                  );
                } else {
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      return _buildEventListCard(context, events[index]);
                    },
                  );
                }
              },
              loading: () => const Center(
                child: CircularProgressIndicator(color: Color(0xFF6200EE)),
              ),
              error: (error, _) => Center(
                child: Text(
                  'Failed to load events',
                  style: GoogleFonts.outfit(color: Colors.redAccent, fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters(BuildContext context, WidgetRef ref, String currentFilter) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
      child: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E2C),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: Row(
              children: [
                const Icon(CupertinoIcons.search, color: Colors.grey, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    onChanged: (val) => ref.read(exploreSearchQueryProvider.notifier).state = val,
                    style: GoogleFonts.outfit(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Search events, organizers, or venues...',
                      hintStyle: GoogleFonts.outfit(color: Colors.grey, fontSize: 14),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Filters
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
    final isSelected = label == currentFilter;
    return GestureDetector(
      onTap: () => ref.read(explorePriceFilterProvider.notifier).state = label,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6200EE) : const Color(0xFF1E1E2C),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF6200EE) : Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            color: isSelected ? Colors.white : Colors.white70,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildEventGridCard(BuildContext context, EventModel event) {
    final String startPrice = event.startPrice?.toString() ?? 'Free';
    final bool isFree = startPrice.toLowerCase() == 'free' || startPrice == '0';
    final String priceStr = isFree ? 'FREE' : '\$$startPrice';

    final String dateStr = event.date ?? 'TBA'; // Only use date without time

    return GestureDetector(
      onTap: () => context.push('/event-details/${event.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E2C),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedImage(
                    imageUrl: event.thumbnail,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        priceStr,
                        style: GoogleFonts.outfit(
                          color: Colors.greenAccent, // highlighted in green
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      event.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                    if (event.organizer != null && event.organizer!.isNotEmpty)
                      Row(
                        children: [
                          const Icon(Icons.person, color: Colors.grey, size: 12),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              event.organizer!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.outfit(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                    if (event.address != null && event.address!.isNotEmpty)
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: Colors.grey, size: 12),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              event.address!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.outfit(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                    Text(
                      dateStr,
                      style: GoogleFonts.outfit(
                        color: const Color(0xFF6200EE),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
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

  Widget _buildEventListCard(BuildContext context, EventModel event) {
    final String startPrice = event.startPrice?.toString() ?? 'Free';
    final bool isFree = startPrice.toLowerCase() == 'free' || startPrice == '0';
    final String priceStr = isFree ? 'FREE' : '\$$startPrice';

    final String dateStr = event.date ?? 'TBA'; // Only use date without time

    return GestureDetector(
      onTap: () => context.push('/event-details/${event.id}'),
      child: Container(
        height: 140, // Increased height to fit organizers and venues
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E2C),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            SizedBox(
              width: 120, // Slightly wider image
              height: 140,
              child: CachedImage(
                imageUrl: event.thumbnail,
                fit: BoxFit.cover,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      event.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                    if (event.organizer != null && event.organizer!.isNotEmpty)
                      Row(
                        children: [
                          const Icon(Icons.person, color: Colors.grey, size: 12),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              event.organizer!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.outfit(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    if (event.address != null && event.address!.isNotEmpty)
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: Colors.grey, size: 12),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              event.address!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.outfit(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          dateStr,
                          style: GoogleFonts.outfit(
                            color: const Color(0xFF6200EE),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          priceStr,
                          style: GoogleFonts.outfit(
                            color: Colors.greenAccent, // highlighted in green
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
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
}

