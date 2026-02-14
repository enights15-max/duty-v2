import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../data/models/booking_model.dart';

class TicketDetailsPage extends StatelessWidget {
  final BookingModel booking;

  const TicketDetailsPage({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle de Entrada')),
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Event Image Header
                  if (booking.eventImage != null)
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      child: Image.network(
                        booking.eventImage!,
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),

                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Text(
                          booking.eventTitle,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          booking.eventDate ?? '',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const Divider(height: 40),

                        // QR Code Section
                        Text(
                          'Escanea este código a la entrada',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 16),
                        QrImageView(
                          data: booking
                              .bookingId, // Encoding Booking ID or unique ticket hash
                          version: QrVersions.auto,
                          size: 200.0,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'ID: ${booking.bookingId}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),

                        const Divider(height: 40),

                        // Ticket Info
                        _buildInfoRow('Entradas', '${booking.quantity}'),
                        const SizedBox(height: 8),
                        _buildInfoRow('Total Pagado', '\$${booking.total}'),
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          'Estado',
                          booking.paymentStatus.toUpperCase(),
                        ),
                      ],
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

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
