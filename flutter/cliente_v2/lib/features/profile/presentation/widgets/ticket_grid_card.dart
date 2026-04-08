import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/colors.dart';
import '../../data/models/booking_model.dart';

class TicketGridCard extends StatelessWidget {
  final BookingModel booking;
  final VoidCallback onTap;
  final bool isPast;

  const TicketGridCard({
    super.key,
    required this.booking,
    required this.onTap,
    this.isPast = false,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.dutyTheme;
    String formattedDate = 'TBA';
    if (booking.eventDate != null) {
      try {
        DateTime? date = DateTime.tryParse(booking.eventDate!);
        if (date == null) {
          final formattedStr = booking.eventDate!
              .replaceAll('pm', 'PM')
              .replaceAll('am', 'AM');
          date = DateFormat('EEE, MMM dd, yyyy hh:mma').parse(formattedStr);
        }
        formattedDate = DateFormat('MMM dd, yyyy').format(date);
      } catch (e) {
        formattedDate = booking.eventDate!;
      }
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: palette.border, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            Expanded(
              flex: 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  booking.eventImage != null
                      ? CachedNetworkImage(
                          imageUrl: booking.eventImage!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              Container(color: palette.surfaceAlt),
                          errorWidget: (context, url, error) {
                            return Container(
                              color: palette.surfaceAlt,
                              child: Icon(
                                Icons.image_not_supported,
                                color: palette.textMuted,
                              ),
                            );
                          },
                        )
                      : Container(
                          color: palette.surfaceAlt,
                          child: Icon(Icons.event, color: palette.textMuted),
                        ),
                  if (isPast)
                    Container(
                      color: palette.shadow.withValues(alpha: 0.6),
                      child: Center(
                        child: Text(
                          'PAST',
                          style: GoogleFonts.manrope(
                            color: palette.textPrimary,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ),
                  if (booking.isListed && !isPast)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: palette.warning,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: palette.warning.withValues(alpha: 0.5),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Text(
                          'LISTED',
                          style: GoogleFonts.manrope(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                  if (showReviewPrompt && isPast)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: palette.danger,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: palette.danger.withValues(alpha: 0.35),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Text(
                          'REVIEW',
                          style: GoogleFonts.manrope(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Details Section
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.bookingId.length > 4
                          ? '$formattedDate • #${booking.bookingId.substring(booking.bookingId.length - 4)}'
                          : '$formattedDate • #${booking.bookingId}',
                      style: GoogleFonts.manrope(
                        color: palette.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      booking.eventTitle,
                      style: GoogleFonts.manrope(
                        color: palette.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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
