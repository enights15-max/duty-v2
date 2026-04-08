import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/colors.dart';
import '../providers/profile_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../widgets/ticket_card.dart';
import '../widgets/ticket_grid_card.dart';
import '../../data/models/booking_model.dart';

class MyTicketsPage extends ConsumerStatefulWidget {
  const MyTicketsPage({super.key});

  @override
  ConsumerState<MyTicketsPage> createState() => _MyTicketsPageState();
}

class _MyTicketsPageState extends ConsumerState<MyTicketsPage> {
  bool _isSearching = false;
  bool _isGridView = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.dutyTheme;
    final bookingsAsync = ref.watch(myBookingsProvider);
    final reviewPromptsAsync = ref.watch(pendingReviewPromptsProvider);
    final double bottomContentInset =
        MediaQuery.of(context).padding.bottom + 132;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: palette.background,
        body: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    if (context.canPop() && !_isSearching)
                      Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: IconButton(
                          icon: Icon(
                            Icons.arrow_back,
                            color: palette.textPrimary,
                          ),
                          onPressed: () => context.pop(),
                          style: IconButton.styleFrom(
                            backgroundColor: palette.surfaceAlt,
                            padding: const EdgeInsets.all(8),
                          ),
                        ),
                      ),

                    if (_isSearching)
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          autofocus: true,
                          style: GoogleFonts.outfit(color: palette.textPrimary),
                          decoration: InputDecoration(
                            hintText: 'Search tickets...',
                            hintStyle: GoogleFonts.outfit(
                              color: palette.textMuted,
                            ),
                            border: InputBorder.none,
                            icon: Icon(Icons.search, color: palette.textMuted),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value.toLowerCase();
                            });
                          },
                        ),
                      )
                    else
                      Expanded(
                        child: Text(
                          'My Tickets',
                          style: GoogleFonts.outfit(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: palette.textPrimary,
                          ),
                        ),
                      ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _isGridView = !_isGridView;
                        });
                      },
                      icon: Icon(
                        _isGridView
                            ? Icons.view_list_rounded
                            : Icons.grid_view_rounded,
                        color: palette.textPrimary,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: palette.surfaceAlt,
                        padding: const EdgeInsets.all(12),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          if (_isSearching) {
                            // Clear search if closing
                            _isSearching = false;
                            _searchQuery = '';
                            _searchController.clear();
                          } else {
                            _isSearching = true;
                          }
                        });
                      },
                      icon: Icon(
                        _isSearching ? Icons.close : Icons.search,
                        color: palette.textPrimary,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: palette.surfaceAlt,
                        padding: const EdgeInsets.all(12),
                      ),
                    ),
                  ],
                ),
              ),

              // Segmented Control (Tabs)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: TabBar(
                  dividerColor: Colors.transparent,
                  indicatorColor: palette.primary,
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: palette.textPrimary,
                  unselectedLabelColor: palette.textMuted,
                  labelStyle: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  tabs: const [
                    Tab(text: 'Upcoming'),
                    Tab(text: 'Past'),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Ticket List
              Expanded(
                child: TabBarView(
                  children: [
                    _buildTicketList(
                      bookingsAsync,
                      reviewPromptsAsync: reviewPromptsAsync,
                      isPast: false,
                      bottomContentInset: bottomContentInset,
                    ),
                    _buildTicketList(
                      bookingsAsync,
                      reviewPromptsAsync: reviewPromptsAsync,
                      isListed: true,
                      bottomContentInset: bottomContentInset,
                    ),
                    _buildTicketList(
                      bookingsAsync,
                      reviewPromptsAsync: reviewPromptsAsync,
                      isPast: true,
                      bottomContentInset: bottomContentInset,
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

  Widget _buildTicketList(
    AsyncValue<List<BookingModel>> bookingsAsync, {
    required AsyncValue<List<ReviewPromptModel>> reviewPromptsAsync,
    bool isPast = false,
    bool isListed = false,
    required double bottomContentInset,
  }) {
    return bookingsAsync.when(
      data: (bookings) {
        final now = DateTime.now();

        // 1. Filter by Search Query
        final searchFiltered = bookings.where((b) {
          if (_searchQuery.isEmpty) return true;
          final title = b.eventTitle.toLowerCase();
          final id = b.bookingId.toLowerCase();
          return title.contains(_searchQuery) || id.contains(_searchQuery);
        }).toList();

        // Helper to parse dates which may arrive in different formats
        DateTime? _parseDate(String? dateStr) {
          if (dateStr == null) return null;
          // Try standard ISO parsing first
          DateTime? date = DateTime.tryParse(dateStr);
          if (date != null) return date;

          // Try custom format like 'Sat, Jan 03, 2026 08:00pm'
          try {
            final formattedStr = dateStr
                .replaceAll('pm', 'PM')
                .replaceAll('am', 'AM');
            return DateFormat('EEE, MMM dd, yyyy hh:mma').parse(formattedStr);
          } catch (e) {
            return null;
          }
        }

        // 2. Filter by Date (Upcoming vs Past)
        List<BookingModel> displayList;
        final baseList = _isSearching && _searchQuery.isNotEmpty
            ? searchFiltered
            : bookings;

        if (isPast) {
          displayList = baseList.where((b) {
            final date = _parseDate(b.eventDate);
            if (date == null) return false;
            return date.isBefore(now) && !isSameDay(date, now);
          }).toList();
        } else {
          displayList = baseList.where((b) {
            final date = _parseDate(b.eventDate);
            if (date == null)
              return true; // Default to upcoming if parsing fails but date exists
            return date.isAfter(now) || isSameDay(date, now);
          }).toList();
        }

        // Sort
        displayList.sort((a, b) {
          if (isPast) {
            final d1 = _parseDate(a.eventDate);
            final d2 = _parseDate(b.eventDate);

            if (d1 == null && d2 == null) return 0;
            if (d1 == null) return 1;
            if (d2 == null) return -1;

            return d2.compareTo(d1); // Most recent first for past events
          } else {
            // Sort upcoming by order of purchase (newest purchased first)
            return b.id.compareTo(a.id);
          }
        });

        if (displayList.isEmpty) {
          return _buildEmptyState(isPast);
        }

        return RefreshIndicator(
          onRefresh: () => ref.refresh(myBookingsProvider.future),
          color: const Color(0xFF8655F6),
          backgroundColor: const Color(0xFF151022),
          child: _isGridView
              ? GridView.builder(
                  padding: EdgeInsets.fromLTRB(24, 8, 24, bottomContentInset),
                  physics: const AlwaysScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: displayList.length,
                  itemBuilder: (context, index) {
                    final booking = displayList[index];
                    return TicketGridCard(
                      booking: booking,
                      isPast: isPast,
                      onTap: () => context.push(
                        '/ticket-details/${booking.bookingId}',
                        extra: booking,
                      ),
                    );
                  },
                )
              : ListView.builder(
                  padding: EdgeInsets.fromLTRB(24, 8, 24, bottomContentInset),
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: displayList.length,
                  itemBuilder: (context, index) {
                    final booking = displayList[index];
                    return TicketCard(
                      booking: booking,
                      isPast: isPast,
                      onTap: () => context.push(
                        '/ticket-details/${booking.bookingId}',
                        extra: booking,
                      ),
                    );
                  },
                );
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(myBookingsProvider);
            ref.invalidate(pendingReviewPromptsProvider);
            await ref.read(myBookingsProvider.future);
            await ref.read(pendingReviewPromptsProvider.future);
          },
          color: context.dutyTheme.primary,
          backgroundColor: context.dutyTheme.surface,
          child: content,
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => _buildErrorState(err),
    );
  }

  Widget _buildEmptyState({bool isPast = false, bool isListed = false}) {
    final palette = context.dutyTheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _isSearching
                ? Icons.search_off
                : Icons.confirmation_number_outlined,
            size: 64,
            color: palette.textMuted.withValues(alpha: 0.35),
          ),
          const SizedBox(height: 16),
          Text(
            _isSearching
                ? 'No tickets found for "$_searchQuery"'
                : (isPast ? 'No past tickets' : 'No upcoming tickets'),
            style: GoogleFonts.outfit(
              fontSize: 16,
              color: palette.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object err) {
    final palette = context.dutyTheme;
    final isAuthError =
        err.toString().contains('Unauthorized') ||
        err.toString().contains('Unauthenticated');

    if (isAuthError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_clock, color: palette.textMuted, size: 64),
            const SizedBox(height: 16),
            Text(
              'Session Expired',
              style: GoogleFonts.outfit(
                color: palette.textPrimary,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your session has expired. Please login again.',
              style: GoogleFonts.outfit(color: palette.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () async {
                final authController = ref.read(
                  authControllerProvider.notifier,
                );
                await authController.logout();
                if (context.mounted) {
                  context.go('/login');
                }
              },
              icon: const Icon(Icons.login, size: 18),
              label: const Text('Login Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: palette.primary,
                foregroundColor: palette.textPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Center(
      child: Text(
        'Error loading tickets: $err',
        style: GoogleFonts.outfit(color: palette.textPrimary),
        textAlign: TextAlign.center,
      ),
    );
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}
