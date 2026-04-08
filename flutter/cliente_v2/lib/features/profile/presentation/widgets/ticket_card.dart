import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/colors.dart';
import '../../data/models/booking_model.dart';

class TicketCard extends StatelessWidget {
  final BookingModel booking;
  final VoidCallback onTap;
  final bool isPast;

  const TicketCard({
    super.key,
    required this.booking,
    required this.onTap,
    this.isPast = false,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.dutyTheme;
    // Parse date if needed or use from model
    final DateTime? eventDate = booking.eventDate != null
        ? DateTime.tryParse(booking.eventDate!)
        : null;

    final bool isToday =
        eventDate != null &&
        eventDate.year == DateTime.now().year &&
        eventDate.month == DateTime.now().month &&
        eventDate.day == DateTime.now().day;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        height: 480, // Aspect ratio approx 4/5 logic or fixed height
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: palette.border),
          boxShadow: [
            BoxShadow(
              color: palette.primaryGlow.withValues(alpha: 0.16),
              blurRadius: 25,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Background Image
              if (booking.eventImage != null)
                Positioned.fill(
                  child: CachedNetworkImage(
                    imageUrl: booking.eventImage!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        Container(color: palette.surfaceAlt),
                    errorWidget: (context, url, error) => Container(
                      color: palette.surfaceAlt,
                      child: Center(
                        child: Icon(
                          Icons.event,
                          size: 50,
                          color: palette.textMuted,
                        ),
                      ),
                    ),
                  ),
                )
              else
                Container(color: palette.surfaceAlt),

              // Gradient Overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        palette.shadow.withValues(alpha: 0.1),
                        Colors.transparent,
                        palette.shadow.withValues(alpha: 0.8),
                        palette.shadow,
                      ],
                      stops: const [0.0, 0.4, 0.8, 1.0],
                    ),
                  ),
                ),
              ),

              // "Live Today" Badge
              if (isToday && !isPast)
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: palette.primary,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: palette.primaryGlow.withValues(alpha: 0.5),
                          blurRadius: 15,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'LIVE TODAY',
                          style: GoogleFonts.outfit(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Content
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Event Type / Organizer
                      Text(
                        booking.organizerName != null
                            ? '${booking.organizerName!.toUpperCase()} • ${booking.status.toUpperCase()}'
                            : 'EVENT • ${booking.status.toUpperCase()}',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isPast ? palette.textMuted : palette.primary,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Title
                      Text(
                        booking.eventTitle,
                        style: GoogleFonts.outfit(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: palette.textPrimary,
                          height: 1.1,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 16),

                      // Date & Time
                      Row(
                        children: [
                          _buildInfoChip(
                            context,
                            Icons.calendar_today_outlined,
                            eventDate != null
                                ? (booking.bookingId.length > 4
                                      ? '${DateFormat('MMM dd, yyyy').format(eventDate)} • #${booking.bookingId.substring(booking.bookingId.length - 4)}'
                                      : '${DateFormat('MMM dd, yyyy').format(eventDate)} • #${booking.bookingId}')
                                : 'TBA',
                          ),
                          const SizedBox(width: 16),
                          if (eventDate != null)
                            _buildInfoChip(
                              context,
                              Icons.access_time,
                              DateFormat('h:mm a').format(eventDate),
                            ),
                        ],
                      ),

                      if (!isPast) ...[
                        const SizedBox(height: 20),
                        Divider(color: palette.border),
                        const SizedBox(height: 16),

                        // Footer / Button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  color: palette.textMuted,
                                  size: 18,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  booking.venueName?.isNotEmpty == true
                                      ? booking.venueName!
                                      : 'Location TBA',
                                  style: GoogleFonts.outfit(
                                    fontSize: 12,
                                    color: palette.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: palette.primarySurface,
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(color: palette.borderStrong),
                              ),
                              child: Text(
                                'VIEW QR',
                                style: GoogleFonts.outfit(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: palette.textPrimary,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ),
                          ],
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

  Widget _buildInfoChip(BuildContext context, IconData icon, String label) {
    final palette = context.dutyTheme;
    return Row(
      children: [
        Icon(icon, size: 16, color: palette.textSecondary),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 14,
            color: palette.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
