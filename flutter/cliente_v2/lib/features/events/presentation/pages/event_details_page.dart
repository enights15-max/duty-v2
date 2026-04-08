import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
<<<<<<< Updated upstream
import 'package:google_fonts/google_fonts.dart';
import 'dart:async'; // For Countdown
import 'package:flutter_html/flutter_html.dart' hide Marker;
=======
import 'dart:async'; // For Countdown
import 'package:dio/dio.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:flutter_html/flutter_html.dart' hide Marker;
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../../data/models/event_detail_model.dart';
>>>>>>> Stashed changes
import '../providers/event_details_provider.dart';

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

  String _slugifyTitle(String value) {
    final normalized = value
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'-{2,}'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
    return normalized.isEmpty ? 'event' : normalized;
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
            content: Text('Log in to mark events as interested and shape your scene.'),
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
            content: Text('We could not update your interested state right now.'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _wishlistBusy = false);
      }
    }
  }

  // Mock data for things not in API yet
  final List<Map<String, String>> lineup = [
    {'name': 'ZEDD', 'image': 'https://i.pravatar.cc/150?img=11'},
    {'name': 'ANNA', 'image': 'https://i.pravatar.cc/150?img=5'},
    {'name': 'KAYLA', 'image': 'https://i.pravatar.cc/150?img=9'},
    {'name': 'MARK', 'image': 'https://i.pravatar.cc/150?img=3'},
  ];

  @override
  Widget build(BuildContext context) {
    final eventAsync = ref.watch(eventDetailsProvider(widget.eventId));

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A), // Dark Background
      body: eventAsync.when(
        data: (event) {
<<<<<<< Updated upstream
          // debugPrint('EVENT DETAILS LOG: $event');
=======
          final isWishlisted = _isWishlistedOverride ?? event.isWishlisted;
          final wishlistCount = _wishlistCountOverride ?? event.wishlistCount;
          final socialInterestedCount =
              event.social == null
                  ? null
                  : (wishlistCount > event.social!.interestedCount
                      ? wishlistCount
                      : event.social!.interestedCount);
          final targetDate =
              DateTime.tryParse('${event.date} ${event.time}') ??
              DateTime.now().add(const Duration(days: 7));
          final isPastEvent = targetDate.isBefore(DateTime.now());
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

          // Event data is already shaped by provider; keep UI render pure.
>>>>>>> Stashed changes
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
                                    const Color(0xFF0F0F1A).withOpacity(0.2),
                                    const Color(0xFF0F0F1A).withOpacity(0.8),
                                    const Color(0xFF0F0F1A),
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
                                // "Sold Out" or Status Tag
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.purpleAccent.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.purpleAccent.withOpacity(
                                        0.5,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    'SELLING FAST',
                                    style: GoogleFonts.outfit(
                                      color: Colors.purpleAccent,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  event.title,
                                  style: GoogleFonts.outfit(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    height: 1.1,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.calendar_today,
                                      color: Colors.white70,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${event.date} • ${event.time}',
                                      style: GoogleFonts.inter(
                                        color: Colors.white70,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
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

                    // --- Countdown Timer ---
                    Padding(
<<<<<<< Updated upstream
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 20,
                      ),
                      child: _CountdownTimer(
                        targetDate:
                            DateTime.tryParse('${event.date} ${event.time}') ??
                            DateTime.now().add(const Duration(days: 7)),
                      ),
                    ),

=======
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
                                  event.organizerModel?.supportsContact ??
                                  true,
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (event.social?.hasAnyData == true) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          'THE CROWD',
                          style: GoogleFonts.outfit(
                            color: Colors.purpleAccent,
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

>>>>>>> Stashed changes
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
                              color: Colors.purpleAccent,
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
                                color: Colors.white70,
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
                                color: Colors.purpleAccent,
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

<<<<<<< Updated upstream
                    // --- Lineup Section ---
=======
                    // --- Organizer Section ---
                    if (event.organizerModel != null) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          'Organizer',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
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
                              color: const Color(0xFF1E1E2C),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.05),
                              ),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundImage:
                                      event.organizerModel!.photo != null
                                      ? CachedNetworkImageProvider(
                                          AppUrls.getAvatarUrl(
                                                event.organizerModel!.photo!,
                                                isOrganizer: true,
                                              ) ??
                                              '',
                                        )
                                      : null,
                                  onBackgroundImageError: event.organizerModel!.photo != null
                                      ? (_, _) {}
                                      : null,
                                  child: event.organizerModel!.photo == null
                                      ? const Icon(
                                          Icons.person,
                                          color: Colors.white,
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
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        'View Profile',
                                        style: GoogleFonts.inter(
                                          color: const Color(0xFF8655F6),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                  color: Colors.white24,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],

                    // --- Venue Section ---
>>>>>>> Stashed changes
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Lineup',
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'View All',
                            style: GoogleFonts.outfit(
                              color: Colors.purpleAccent,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        itemCount: lineup.length,
                        itemBuilder: (context, index) {
                          final artist = lineup[index];
                          return Container(
                            margin: const EdgeInsets.only(right: 20),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: index == 0
                                          ? Colors.purpleAccent
                                          : Colors.transparent,
                                      width: 2,
                                    ),
                                  ),
                                  child: CircleAvatar(
                                    radius: 30,
                                    backgroundImage: NetworkImage(
                                      artist['image']!,
                                    ),
                                    onBackgroundImageError: (_, __) {},
                                    child: const Icon(
                                      Icons.person,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  artist['name']!,
                                  style: GoogleFonts.outfit(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 32),

                    // --- Venue Section ---
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        'The Venue',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (event.latitude != null && event.longitude != null)
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 24),
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: GoogleMap(
                            initialCameraPosition: CameraPosition(
                              target: LatLng(event.latitude!, event.longitude!),
                              zoom: 15,
                            ),
                            markers: {
                              Marker(
                                markerId: const MarkerId('venue'),
                                position: LatLng(
                                  event.latitude!,
                                  event.longitude!,
                                ),
                                infoWindow: InfoWindow(title: event.address),
                              ),
                            },
                            liteModeEnabled:
                                true, // Better performance for lists/scroll views
                            mapToolbarEnabled: true,
                            zoomControlsEnabled: false,
                          ),
                        ),
                      )
                    else
                      Container(
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
                              color: Colors.black.withOpacity(0.3),
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
                                      Colors.black.withOpacity(0.9),
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
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            'Location',
                                            style: GoogleFonts.inter(
                                              color: Colors.white70,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF6200EE),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.map,
                                        color: Colors.white,
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
                          icon: Icons.arrow_back_ios_new,
                          onTap: () => context.pop(),
                        ),
                        Row(
                          children: [
                            _buildGlassIcon(
                              icon: Icons.share,
                              onTap: () => _shareEvent(event),
                            ),
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
                                  ? Colors.purpleAccent
                                  : Colors.white,
                              backgroundColor: isWishlisted
                                  ? Colors.purpleAccent.withValues(alpha: 0.18)
                                  : Colors.white.withValues(alpha: 0.1),
                              borderColor: isWishlisted
                                  ? Colors.purpleAccent.withValues(alpha: 0.45)
                                  : Colors.white.withValues(alpha: 0.1),
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
                    color: const Color(
                      0xFF0F0F1A,
                    ).withOpacity(0.95), // Glassy dark
                    border: Border(
                      top: BorderSide(color: Colors.white.withOpacity(0.1)),
                    ),
                  ),
                  child: SafeArea(
                    top: false,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
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
                            const SizedBox(height: 4),
                            Text(
                              '\$${event.tickets.isNotEmpty ? event.tickets.first.price : '89.00'}',
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
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
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildImageSlider(dynamic event) {
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
        color: const Color(0xFF2A1B3D),
        child: const Center(
          child: Icon(
            Icons.image_not_supported,
            size: 50,
            color: Colors.white54,
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
            return Image.network(
              imagesToShow[index],
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: const Color(0xFF2A1B3D),
                child: const Center(
                  child: Icon(
                    Icons.broken_image,
                    size: 50,
                    color: Colors.white54,
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
                        ? Colors.purpleAccent
                        : Colors.white.withOpacity(0.5),
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
<<<<<<< Updated upstream
          color: Colors.white.withOpacity(0.1),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.1)),
=======
          color: backgroundColor ?? Colors.white.withValues(alpha: 0.1),
          shape: BoxShape.circle,
          border: Border.all(
            color: borderColor ?? Colors.white.withValues(alpha: 0.1),
          ),
>>>>>>> Stashed changes
        ),
        child: Icon(icon, color: iconColor ?? Colors.white, size: 20),
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
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2C),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.purpleAccent.withOpacity(0.3)),
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
    return Container(height: 30, width: 1, color: Colors.white24);
  }

  Widget _buildTimeItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(
            color: Colors.purpleAccent,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}
<<<<<<< Updated upstream
=======

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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
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
    final subtitle = count == 1 ? '1 person interested' : '$count people interested';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: isWishlisted
              ? Colors.purpleAccent.withValues(alpha: 0.1)
              : const Color(0xFF1E1E2C),
          border: Border.all(
            color: isWishlisted
                ? Colors.purpleAccent.withValues(alpha: 0.5)
                : Colors.white24,
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
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Icon(
                    isWishlisted ? Icons.favorite : Icons.favorite_border,
                    color: isWishlisted ? Colors.purpleAccent : Colors.white,
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
                    color: isWishlisted ? Colors.purpleAccent : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(color: Colors.white54, fontSize: 10),
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
          content: Text('Direct contact is not available for this organizer yet.'),
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
    final isEnabled = widget.organizerId != null && widget.supportsContact;

    return GestureDetector(
      onTap: isEnabled ? _openContactSheet : null,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: isEnabled
              ? const Color(0xFF1E1E2C)
              : const Color(0xFF1E1E2C).withValues(alpha: 0.55),
          border: Border.all(
            color: isEnabled ? Colors.white24 : Colors.white10,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              color: isEnabled ? Colors.white : Colors.white38,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Contact\nOrganizer',
              style: GoogleFonts.outfit(
                color: isEnabled ? Colors.white : Colors.white38,
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
    final fullName = [firstName, lastName]
        .where((value) => value.isNotEmpty)
        .join(' ')
        .trim();

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
          backgroundColor: Colors.redAccent,
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
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.redAccent,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Something went wrong while sending your message.'),
          backgroundColor: Colors.redAccent,
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
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF12101E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
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
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Contact ${widget.organizerName}',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Send a direct question about this event. The organizer will receive it by email.',
                      style: GoogleFonts.inter(
                        color: Colors.white60,
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
                          backgroundColor: const Color(0xFF8F0DF2),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: const Color(
                            0xFF8F0DF2,
                          ).withValues(alpha: 0.45),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _isSending
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            color: Colors.white,
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
          style: GoogleFonts.inter(color: Colors.white, fontSize: 15),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF1B1830),
            hintStyle: GoogleFonts.inter(color: Colors.white30),
            errorStyle: GoogleFonts.inter(color: Colors.redAccent.shade100),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: Colors.white12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: Color(0xFF8F0DF2), width: 1.4),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: Colors.redAccent),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: const BorderSide(color: Colors.redAccent),
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
              color: Colors.purpleAccent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.purpleAccent.withValues(alpha: 0.35),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.favorite,
                  color: Colors.purpleAccent,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'You are interested in this event',
                  style: GoogleFonts.inter(
                    color: Colors.white,
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
        /*
        if (interestedCount > 0) ...[
          const SizedBox(height: 14),
          _SocialPeopleStrip(
            title: social.followedInterestedPeople.isNotEmpty
                ? 'People you follow are into this'
                : 'People interested',
            totalCount: interestedCount,
            visibleCount: visibleInterestedCount,
            people: highlightedInterested,
          ),
        ],
        if (social.attendingCount > 0) ...[
          const SizedBox(height: 14),
          _SocialPeopleStrip(
            title: 'People going',
            totalCount: social.attendingCount,
            visibleCount: social.visibleAttendingCount,
            people: social.attendingPeople,
          ),
        ],
        */
      ],
    );
  }
}

class _EventLineupSection extends StatelessWidget {
  const _EventLineupSection({required this.lineup});

  final List<EventLineupModel> lineup;

  @override
  Widget build(BuildContext context) {
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
            color: const Color(0xFFA855F7),
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Who is playing',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w700,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Discover the artists behind this date and jump into their profiles when available.',
          style: GoogleFonts.inter(
            color: Colors.white60,
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
    final card = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [
            const Color(0xFF20122C),
            const Color(0xFF3B1D68).withValues(alpha: 0.95),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: const Color(0xFFA855F7).withValues(alpha: 0.32),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFA855F7).withValues(alpha: 0.16),
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
              color: Colors.white.withValues(alpha: 0.08),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: const Icon(
              Icons.graphic_eq_rounded,
              color: Color(0xFFFFC857),
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
                    color: const Color(0xFFFFC857).withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    item.badgeLabel,
                    style: GoogleFonts.outfit(
                      color: const Color(0xFFFFC857),
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
                    color: Colors.white,
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
                    color: Colors.white60,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (item.hasProfile)
            const Padding(
              padding: EdgeInsets.only(left: 12),
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white38,
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
    final chip = Container(
      constraints: const BoxConstraints(minWidth: 152, maxWidth: 260),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF171727),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFA855F7).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              item.sourceType == 'artist'
                  ? Icons.headphones_rounded
                  : Icons.mic_external_on_rounded,
              color: const Color(0xFFA855F7),
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
                    color: Colors.white,
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
                    color: Colors.white54,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (item.hasProfile)
            const Icon(
              Icons.north_east_rounded,
              color: Colors.white30,
              size: 18,
            ),
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF171625),
            const Color(0xFF211A35).withValues(alpha: 0.95),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
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
              color: Colors.white.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Icon(icon, color: const Color(0xFFA855F7)),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$value',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: GoogleFonts.inter(color: Colors.white60, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SocialPeopleStrip extends StatelessWidget {
  const _SocialPeopleStrip({
    required this.title,
    required this.totalCount,
    required this.visibleCount,
    required this.people,
  });

  final String title;
  final int totalCount;
  final int visibleCount;
  final List<EventSocialPersonModel> people;

  @override
  Widget build(BuildContext context) {
    final hiddenCount = totalCount - people.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF171625),
            const Color(0xFF1B1830).withValues(alpha: 0.96),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (totalCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.purpleAccent.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: Colors.purpleAccent.withValues(alpha: 0.28),
                    ),
                  ),
                  child: Text(
                    '$totalCount in the scene',
                    style: GoogleFonts.outfit(
                      color: Colors.purpleAccent,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            totalCount > visibleCount
                ? '$visibleCount visible now. Some profiles keep this private.'
                : '$totalCount visible right now. Tap any profile to explore the crowd.',
            style: GoogleFonts.inter(
              color: Colors.white60,
              fontSize: 12,
              height: 1.35,
            ),
          ),
          if (people.isNotEmpty) ...[
            const SizedBox(height: 14),
            SizedBox(
              height: 140,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: people.length,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final person = people[index];
                  final imageUrl = AppUrls.getAvatarUrl(person.photo);

                  return InkWell(
                    borderRadius: BorderRadius.circular(22),
                    onTap: person.id > 0
                        ? () => context.push('/user-profile/${person.id}')
                        : null,
                    child: Container(
                      width: 112,
                      padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1F1A32),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: person.isFollowing
                              ? Colors.purpleAccent.withValues(alpha: 0.36)
                              : Colors.white.withValues(alpha: 0.08),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: person.isFollowing
                                ? Colors.purpleAccent.withValues(alpha: 0.10)
                                : Colors.black.withValues(alpha: 0.10),
                            blurRadius: 14,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: person.isFollowing
                                      ? const LinearGradient(
                                          colors: [
                                            Color(0xFFA855F7),
                                            Color(0xFFE879F9),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        )
                                      : null,
                                  border: person.isFollowing
                                      ? null
                                      : Border.all(
                                          color: Colors.white12,
                                        ),
                                ),
                                child: CircleAvatar(
                                  radius: 24,
                                  backgroundColor: Colors.white10,
                                  backgroundImage: imageUrl != null
                                      ? CachedNetworkImageProvider(imageUrl)
                                      : null,
                                  child: imageUrl == null
                                      ? const Icon(
                                          Icons.person,
                                          color: Colors.white54,
                                        )
                                      : null,
                                ),
                              ),
                              if (person.isFollowing)
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: Container(
                                    width: 18,
                                    height: 18,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFA855F7),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: const Color(0xFF1F1A32),
                                        width: 2,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.favorite,
                                      size: 9,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            person.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            person.isFollowing
                                ? 'You follow'
                                : (person.username?.isNotEmpty == true
                                      ? '@${person.username}'
                                      : 'Open profile'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              color: person.isFollowing
                                  ? Colors.purpleAccent
                                  : Colors.white54,
                              fontSize: 10,
                              fontWeight: person.isFollowing
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            if (hiddenCount > 0) ...[
              const SizedBox(height: 12),
              Text(
                'And $hiddenCount more people in the scene.',
                style: GoogleFonts.inter(
                  color: Colors.white54,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}
>>>>>>> Stashed changes
