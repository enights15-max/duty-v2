import 'package:flutter/material.dart';
<<<<<<< Updated upstream
=======
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
>>>>>>> Stashed changes
import 'package:qr_flutter/qr_flutter.dart';
import '../../data/models/booking_model.dart';

class TicketDetailsPage extends StatelessWidget {
  final BookingModel booking;

  const TicketDetailsPage({super.key, required this.booking});

<<<<<<< Updated upstream
=======
  static const Color kPrimaryColor = Color(0xFF8655F6);
  static const Color kDarkBackground = Color(0xFF151022);

  void _handleTransfer(BuildContext context, WidgetRef ref) {
    if (booking.transferStatus == 'transfer_pending') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This ticket already has a pending transfer request.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF151022),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _TransferOptionsSheet(
        booking: booking,
        onManualTransfer: () => _showManualTransferSheet(context),
        onShowTransferQr: () => _showTransferQrSheet(context, ref),
      ),
    );
  }

  void _showManualTransferSheet(BuildContext context) {
    final recipientController = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF151022),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _TransferBottomSheet(
        booking: booking,
        recipientController: recipientController,
      ),
    );
  }

  Future<void> _showTransferQrSheet(BuildContext context, WidgetRef ref) async {
    final qrData = await ref
        .read(marketplaceProvider.notifier)
        .getTransferTicketQr(bookingId: booking.id);

    if (!context.mounted) return;

    if (qrData == null || qrData['qr_value'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('We could not generate a transfer QR for this ticket.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final qrValue = qrData['qr_value'].toString();

    await showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF151022),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Show Ticket Transfer QR',
              style: GoogleFonts.manrope(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Let someone scan this QR from the main scanner in Duty to request your ticket. You still approve the transfer before it moves.',
              style: GoogleFonts.manrope(color: Colors.white54, height: 1.5),
            ),
            const SizedBox(height: 24),
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: QrImageView(
                  data: qrValue,
                  version: QrVersions.auto,
                  size: 240,
                  backgroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline, color: Colors.amber, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Only show this to the person you want to let request the ticket. They still need your approval from the transfer inbox.',
                      style: GoogleFonts.manrope(
                        color: Colors.amber,
                        fontSize: 12,
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white24),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: qrValue));
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Transfer QR copied to clipboard.'),
                    ),
                  );
                },
                icon: const Icon(Icons.copy_rounded),
                label: const Text('Copy QR value'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSell(BuildContext context, WidgetRef ref) {
    final priceController = TextEditingController(
      text: booking.listingPrice > 0 ? booking.listingPrice.toString() : '',
    );

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF151022),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          left: 24,
          right: 24,
          top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              booking.isListed ? 'Update Listing' : 'List on Marketplace',
              style: GoogleFonts.manrope(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Set your price and list your ticket for other fans to buy.',
              style: GoogleFonts.manrope(color: Colors.white54),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                prefixText: '\$ ',
                prefixStyle: const TextStyle(color: Colors.white),
                hintText: 'Listing Price',
                hintStyle: const TextStyle(color: Colors.white24),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                if (booking.isListed) ...[
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                        side: const BorderSide(color: Colors.redAccent),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () async {
                        await ref
                            .read(marketplaceProvider.notifier)
                            .listTicket(
                              bookingId: booking.id,
                              price: 0,
                              isListed: false,
                            );
                        final state = ref.read(marketplaceProvider);
                        if (!context.mounted) return;
                        if (!state.hasError) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Ticket unlisted from marketplace.',
                              ),
                              backgroundColor: Colors.blueGrey,
                            ),
                          );
                        }
                      },
                      child: const Text('Unlist'),
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () async {
                      final price = double.tryParse(priceController.text);
                      if (price == null) return;

                      await ref
                          .read(marketplaceProvider.notifier)
                          .listTicket(
                            bookingId: booking.id,
                            price: price,
                            isListed: true,
                          );

                      final state = ref.read(marketplaceProvider);
                      if (!context.mounted) return;
                      if (state.hasError) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: ${state.error}'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      } else {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Ticket listed successfully!'),
                            backgroundColor: Colors.blueAccent,
                          ),
                        );
                      }
                    },
                    child: Text(
                      booking.isListed ? 'Update' : 'Confirm Listing',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _handleAddToWallet(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: kPrimaryColor),
            SizedBox(height: 16),
            Text(
              'Adding to Apple Wallet...',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );

    await Future.delayed(const Duration(seconds: 2));
    if (context.mounted) {
      Navigator.pop(context);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF151022),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text('Success', style: TextStyle(color: Colors.white)),
            ],
          ),
          content: const Text(
            'Ticket successfully added to your Apple Wallet.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK', style: TextStyle(color: kPrimaryColor)),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _handleViewInvoice(BuildContext context) async {
    final urlString = booking.invoiceUrl;
    if (urlString == null || urlString.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invoice not available for this booking.'),
        ),
      );
      return;
    }

    context.push('/invoice-details', extra: urlString);
  }

>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
=======

class _TransferOptionsSheet extends StatelessWidget {
  const _TransferOptionsSheet({
    required this.booking,
    required this.onManualTransfer,
    required this.onShowTransferQr,
  });

  final BookingModel booking;
  final VoidCallback onManualTransfer;
  final VoidCallback onShowTransferQr;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Transfer Ticket',
            style: GoogleFonts.manrope(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Send ${booking.eventTitle} by scanning the receiver code, or fall back to email and username if needed.',
            style: GoogleFonts.manrope(color: Colors.white54),
          ),
          const SizedBox(height: 24),
          _TransferActionTile(
            icon: Icons.qr_code_scanner_rounded,
            title: 'Scan receiver code',
            subtitle: 'Fastest option. Scan the QR from another Duty user.',
            onTap: () {
              Navigator.of(context).pop();
              context.push('/scanner?mode=transfer', extra: booking);
            },
          ),
          const SizedBox(height: 14),
          _TransferActionTile(
            icon: Icons.qr_code_2_rounded,
            title: 'Show transfer QR',
            subtitle: 'Let someone scan this ticket and request it from you.',
            onTap: () {
              Navigator.of(context).pop();
              onShowTransferQr();
            },
          ),
          const SizedBox(height: 14),
          _TransferActionTile(
            icon: Icons.person_search_outlined,
            title: 'Enter username or email',
            subtitle:
                'Use the manual flow if the receiver cannot show their code.',
            onTap: () {
              Navigator.of(context).pop();
              onManualTransfer();
            },
          ),
          const SizedBox(height: 14),
          _TransferActionTile(
            icon: Icons.account_circle_outlined,
            title: 'Open my receive code',
            subtitle:
                'Let someone else scan your code if they are sending you a ticket.',
            onTap: () {
              Navigator.of(context).pop();
              context.push('/scanner/my-code');
            },
          ),
        ],
      ),
    );
  }
}

class _TransferActionTile extends StatelessWidget {
  const _TransferActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFF8655F6).withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(icon, color: const Color(0xFFE9B4FF)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.manrope(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: GoogleFonts.manrope(
                      color: Colors.white54,
                      fontSize: 13,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            const Icon(Icons.chevron_right_rounded, color: Colors.white38),
          ],
        ),
      ),
    );
  }
}

/// Two-step transfer bottom sheet: verify recipient → confirm → send request.
class _TransferBottomSheet extends ConsumerStatefulWidget {
  final BookingModel booking;
  final TextEditingController recipientController;

  const _TransferBottomSheet({
    required this.booking,
    required this.recipientController,
  });

  @override
  ConsumerState<_TransferBottomSheet> createState() =>
      _TransferBottomSheetState();
}

class _TransferBottomSheetState extends ConsumerState<_TransferBottomSheet> {
  static const Color kPrimaryColor = Color(0xFF8655F6);

  Map<String, dynamic>? _recipientInfo;
  bool _isVerifying = false;
  bool _isSending = false;
  String? _errorMessage;

  Future<void> _verifyRecipient() async {
    if (widget.recipientController.text.isEmpty) return;

    setState(() {
      _isVerifying = true;
      _errorMessage = null;
      _recipientInfo = null;
    });

    final result = await ref
        .read(marketplaceProvider.notifier)
        .verifyRecipient(recipient: widget.recipientController.text);

    setState(() {
      _isVerifying = false;
      if (result != null) {
        _recipientInfo = result;
      } else {
        _errorMessage = 'User not found. Check the email or username.';
      }
    });
  }

  Future<void> _sendTransfer() async {
    setState(() => _isSending = true);

    await ref
        .read(marketplaceProvider.notifier)
        .transferTicket(
          bookingId: widget.booking.id,
          recipient: widget.recipientController.text,
        );

    final state = ref.read(marketplaceProvider);
    if (state.hasError) {
      setState(() {
        _isSending = false;
        _errorMessage = 'Transfer failed. Please try again.';
      });
    } else {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transfer request sent! Waiting for approval.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Transfer Ticket',
            style: GoogleFonts.manrope(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _recipientInfo == null
                ? 'Enter the email or username of the recipient.'
                : 'Confirm the recipient below.',
            style: GoogleFonts.manrope(color: Colors.white54),
          ),
          const SizedBox(height: 24),

          // Step 1: Input + Verify
          if (_recipientInfo == null) ...[
            TextField(
              controller: widget.recipientController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Email or Username',
                hintStyle: const TextStyle(color: Colors.white24),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(
                  Icons.person_search,
                  color: Colors.white38,
                ),
              ),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.redAccent,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: GoogleFonts.manrope(
                          color: Colors.redAccent,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: _isVerifying ? null : _verifyRecipient,
                child: _isVerifying
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Verify Recipient',
                        style: GoogleFonts.manrope(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],

          // Step 2: Confirmed recipient → Send
          if (_recipientInfo != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: kPrimaryColor.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: kPrimaryColor.withValues(alpha: 0.2),
                    child: Text(
                      (_recipientInfo!['name'] ?? 'U')
                          .toString()
                          .substring(0, 1)
                          .toUpperCase(),
                      style: GoogleFonts.manrope(
                        color: kPrimaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _recipientInfo!['name'] ?? 'Unknown',
                          style: GoogleFonts.manrope(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        if (_recipientInfo!['username'] != null)
                          Text(
                            '@${_recipientInfo!['username']}',
                            style: GoogleFonts.manrope(
                              color: Colors.white54,
                              fontSize: 13,
                            ),
                          ),
                        Text(
                          _recipientInfo!['email'] ?? '',
                          style: GoogleFonts.manrope(
                            color: Colors.white38,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.check_circle, color: Colors.greenAccent, size: 28),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.amber, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'The recipient must accept the transfer before the ticket is moved.',
                      style: GoogleFonts.manrope(
                        color: Colors.amber,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white24),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        _recipientInfo = null;
                        _errorMessage = null;
                      });
                    },
                    child: Text(
                      'Change',
                      style: GoogleFonts.manrope(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: _isSending ? null : _sendTransfer,
                    child: _isSending
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'Send Transfer Request',
                            style: GoogleFonts.manrope(
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
>>>>>>> Stashed changes
