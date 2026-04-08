import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../events/data/models/event_detail_model.dart';
import '../../../events/presentation/providers/event_details_provider.dart';
import '../../../profile/data/models/booking_model.dart';
import '../../../profile/presentation/providers/marketplace_provider.dart';
import '../../domain/duty_scan_parser.dart';

enum ScannerMode { event, transfer }

class ScannerPage extends ConsumerStatefulWidget {
  const ScannerPage({
    super.key,
    this.initialMode = ScannerMode.event,
    this.transferBooking,
  });

  final ScannerMode initialMode;
  final BookingModel? transferBooking;

  @override
  ConsumerState<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends ConsumerState<ScannerPage> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
    formats: const [BarcodeFormat.qrCode],
    autoZoom: true,
  );

  bool _isResolving = false;
  String? _statusMessage;
  late ScannerMode _mode;

  BookingModel? get _transferBooking => widget.transferBooking;

  @override
  void initState() {
    super.initState();
    _mode = widget.initialMode;
  }

  Future<void> _handleBarcode(BarcodeCapture capture) async {
    if (_isResolving) return;

    String? rawValue;
    for (final barcode in capture.barcodes) {
      final candidate = barcode.rawValue?.trim();
      if (candidate != null && candidate.isNotEmpty) {
        rawValue = candidate;
        break;
      }
    }

    if (rawValue == null) {
      return;
    }

    final result = DutyScanParser.parse(rawValue);

    switch (_mode) {
      case ScannerMode.event:
        switch (result.type) {
          case DutyScanType.event:
            await _openEventFlow(result.eventId!);
          case DutyScanType.transferRecipient:
            await _showUnsupportedCode(
              title: 'That code is for ticket transfer',
              message:
                  'Switch to Transfer mode from a ticket when you want to send a ticket to someone.',
            );
          case DutyScanType.transferTicket:
            await _showUnsupportedCode(
              title: 'That code is for ticket requests',
              message:
                  'Switch to Transfer mode if you want to request this ticket from the owner.',
            );
          case DutyScanType.unsupported:
            await _showUnsupportedCode();
        }
      case ScannerMode.transfer:
        switch (result.type) {
          case DutyScanType.transferRecipient:
            if (_transferBooking == null) {
              await _showTransferNeedsTicket();
              return;
            }
            await _openTransferFlow(result.recipientId!);
          case DutyScanType.transferTicket:
            await _openTransferTicketRequestFlow(result.transferToken!);
          case DutyScanType.event:
            await _showUnsupportedCode(
              title: 'That is an event QR',
              message:
                  'Switch back to Event mode if you want to open this event. Transfer mode is for receiver codes and transfer ticket requests.',
            );
          case DutyScanType.unsupported:
            await _showUnsupportedCode(
              title: 'That code is not a Duty transfer QR',
              message:
                  'Transfer mode scans either a receiver code or a transfer-ticket QR from another Duty user.',
            );
        }
    }
  }

  Future<void> _openEventFlow(int eventId) async {
    setState(() {
      _isResolving = true;
      _statusMessage = 'Opening event...';
    });

    await HapticFeedback.mediumImpact();
    await _controller.stop();

    if (!mounted) return;
    final router = GoRouter.of(context);

    try {
      final event = await ref.read(eventDetailsProvider(eventId).future);
      final targetRoute = _shouldGoStraightToCheckout(event)
          ? _ScannerTarget.checkout(event)
          : _ScannerTarget.eventDetails(eventId);

      if (!mounted) return;

      router.pop();
      switch (targetRoute.type) {
        case _ScannerTargetType.checkout:
          router.push('/checkout', extra: targetRoute.event);
        case _ScannerTargetType.eventDetails:
          router.push('/event-details/${targetRoute.eventId}');
      }
    } catch (_) {
      if (!mounted) return;
      router.pop();
      router.push('/event-details/$eventId');
    }
  }

  bool _shouldGoStraightToCheckout(EventDetailModel event) {
    final targetDate =
        DateTime.tryParse('${event.date} ${event.time}') ?? DateTime.now();
    final isPastEvent = targetDate.isBefore(DateTime.now());
    final hasPurchasableTickets = event.tickets.any(
      (ticket) => ticket.available,
    );

    return !isPastEvent && hasPurchasableTickets;
  }

  Future<void> _openTransferFlow(int recipientId) async {
    final booking = _transferBooking;
    if (booking == null) {
      await _showTransferNeedsTicket();
      return;
    }

    setState(() {
      _isResolving = true;
      _statusMessage = 'Checking recipient...';
    });

    await HapticFeedback.mediumImpact();
    await _controller.stop();

    final recipient = await ref
        .read(marketplaceProvider.notifier)
        .verifyRecipient(recipientId: recipientId);

    if (!mounted) return;

    if (recipient == null) {
      await _showUnsupportedCode(
        title: 'We could not find that Duty user',
        message:
            'Ask the receiver to refresh their code and try again, or transfer the ticket manually.',
      );
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF151022),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => _TransferRecipientConfirmSheet(
        booking: booking,
        recipientInfo: recipient,
        onConfirm: () async {
          await ref
              .read(marketplaceProvider.notifier)
              .transferTicket(bookingId: booking.id, recipientId: recipientId);

          final state = ref.read(marketplaceProvider);
          if (state.hasError) {
            throw state.error ?? Exception('Transfer failed');
          }
        },
      ),
    );

    if (!mounted) return;

    setState(() {
      _isResolving = false;
      _statusMessage = null;
    });

    if (_mode == ScannerMode.transfer) {
      await _controller.start();
    }
  }

  Future<void> _openTransferTicketRequestFlow(String transferToken) async {
    setState(() {
      _isResolving = true;
      _statusMessage = 'Preparing ticket request...';
    });

    await HapticFeedback.mediumImpact();
    await _controller.stop();

    if (!mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF151022),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) =>
          _TransferTicketRequestSheet(transferToken: transferToken),
    );

    if (!mounted) return;

    setState(() {
      _isResolving = false;
      _statusMessage = null;
    });
    await _controller.start();
  }

  Future<void> _showTransferNeedsTicket() async {
    await HapticFeedback.mediumImpact();
    await _controller.stop();

    if (!mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF151022),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              Text(
                'Transfer mode starts from a ticket',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Open one of your tickets, tap Transfer, and then scan the receiver code. From here you can still show your own code if someone wants to send you a ticket.',
                style: GoogleFonts.inter(
                  color: Colors.white70,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white24),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    this.context.go('/my-tickets');
                  },
                  child: Text(
                    'Open My Tickets',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8F0DF2),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    this.context.push('/scanner/my-code');
                  },
                  child: Text(
                    'Show My Receive Code',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (!mounted) return;
    setState(() {
      _isResolving = false;
      _statusMessage = null;
    });
    await _controller.start();
  }

  Future<void> _showUnsupportedCode({
    String title = 'That code is not a Duty event QR yet',
    String message =
        'For this first scanner cut we only open event codes. Transfer and other QR types will come next.',
  }) async {
    setState(() {
      _isResolving = true;
      _statusMessage = message;
    });

    await HapticFeedback.heavyImpact();
    await _controller.stop();

    if (!mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF151022),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.qr_code_2_rounded,
                  color: Colors.white70,
                  size: 30,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                title,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  height: 1.05,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                message,
                style: GoogleFonts.inter(
                  color: Colors.white60,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8F0DF2),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Scan another code',
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (!mounted) return;

    setState(() {
      _isResolving = false;
      _statusMessage = null;
    });
    await _controller.start();
  }

  String get _heroTitle {
    switch (_mode) {
      case ScannerMode.event:
        return 'Scan an event QR to jump straight into Duty.';
      case ScannerMode.transfer:
        return _transferBooking == null
            ? 'Scan a ticket QR or a receive code.'
            : 'Scan a receive code to transfer this ticket.';
    }
  }

  String get _heroDescription {
    switch (_mode) {
      case ScannerMode.event:
        return 'Scan a Duty event code and we will take you straight to the event or purchase flow.';
      case ScannerMode.transfer:
        return _transferBooking == null
            ? 'Use Transfer mode to request a ticket from someone else, or open one of your tickets first if you want to send it.'
            : 'Point the camera at the receiver QR from another Duty user to send ${_transferBooking!.eventTitle}.';
    }
  }

  String get _defaultStatusCopy {
    switch (_mode) {
      case ScannerMode.event:
        return 'Point your camera at a Duty event QR and we will take you straight to the purchase flow.';
      case ScannerMode.transfer:
        return _transferBooking == null
            ? 'You can scan a transfer-ticket QR to request it from the owner, or show My Code if someone is sending one to you.'
            : 'Scanning the receiver code will verify the recipient first, then you can confirm the transfer request.';
    }
  }

  Future<void> _selectMode(ScannerMode mode) async {
    if (mode == _mode) {
      return;
    }

    setState(() {
      _mode = mode;
      _statusMessage = null;
      _isResolving = false;
    });
  }

  @override
  void dispose() {
    unawaited(_controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF09070F),
      body: Stack(
        children: [
          Positioned.fill(
            child: MobileScanner(
              controller: _controller,
              fit: BoxFit.cover,
              onDetect: _handleBarcode,
              errorBuilder: (context, error) => _ScannerErrorView(
                message:
                    error.errorDetails?.message ??
                    'Camera access is required to scan Duty event QR codes.',
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              ignoring: true,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.62),
                      Colors.black.withValues(alpha: 0.18),
                      Colors.black.withValues(alpha: 0.55),
                    ],
                    stops: const [0.0, 0.4, 1.0],
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _GlassActionButton(
                        icon: Icons.arrow_back_ios_new_rounded,
                        onTap: () => context.pop(),
                      ),
                      const Spacer(),
                      ValueListenableBuilder<MobileScannerState>(
                        valueListenable: _controller,
                        builder: (context, state, _) {
                          final isTorchOn = state.torchState == TorchState.on;
                          return _GlassActionButton(
                            icon: isTorchOn
                                ? Icons.flash_on_rounded
                                : Icons.flash_off_rounded,
                            onTap: () => _controller.toggleTorch(),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                    child: Text(
                      'SCANNER',
                      style: GoogleFonts.outfit(
                        color: const Color(0xFFE9B4FF),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    _heroTitle,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _heroDescription,
                    style: GoogleFonts.inter(
                      color: Colors.white70,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  const Spacer(),
                  Center(
                    child: SizedBox(
                      width: 280,
                      height: 280,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(32),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.08),
                                ),
                              ),
                            ),
                          ),
                          const Positioned(
                            top: 0,
                            left: 0,
                            child: _CornerFrame(
                              alignment: _CornerAlignment.topLeft,
                            ),
                          ),
                          const Positioned(
                            top: 0,
                            right: 0,
                            child: _CornerFrame(
                              alignment: _CornerAlignment.topRight,
                            ),
                          ),
                          const Positioned(
                            bottom: 0,
                            left: 0,
                            child: _CornerFrame(
                              alignment: _CornerAlignment.bottomLeft,
                            ),
                          ),
                          const Positioned(
                            bottom: 0,
                            right: 0,
                            child: _CornerFrame(
                              alignment: _CornerAlignment.bottomRight,
                            ),
                          ),
                          Positioned.fill(
                            child: Center(
                              child: Container(
                                width: 180,
                                height: 2,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      Color(0xFFA855F7),
                                      Color(0xFFE879F9),
                                      Colors.transparent,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(999),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFFA855F7,
                                      ).withValues(alpha: 0.45),
                                      blurRadius: 14,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFF151022).withValues(alpha: 0.86),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _ScannerModeChip(
                                label: 'Event',
                                icon: Icons.local_activity_outlined,
                                active: _mode == ScannerMode.event,
                                onTap: () => _selectMode(ScannerMode.event),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _ScannerModeChip(
                                label: 'Transfer',
                                icon: Icons.swap_horiz_rounded,
                                active: _mode == ScannerMode.transfer,
                                onTap: () => _selectMode(ScannerMode.transfer),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _ScannerModeChip(
                                label: 'My Code',
                                icon: Icons.qr_code_2_rounded,
                                active: false,
                                onTap: () => context.push('/scanner/my-code'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            const Icon(
                              Icons.bolt_rounded,
                              color: Color(0xFFE9B4FF),
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _statusMessage ?? _defaultStatusCopy,
                                style: GoogleFonts.inter(
                                  color: Colors.white70,
                                  fontSize: 13,
                                  height: 1.45,
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
          if (_isResolving)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.38),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 18,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF181227),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.6,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFFA855F7),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          _statusMessage ?? 'Opening Duty...',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

enum _ScannerTargetType { checkout, eventDetails }

class _ScannerTarget {
  const _ScannerTarget.checkout(this.event)
    : type = _ScannerTargetType.checkout,
      eventId = null;

  const _ScannerTarget.eventDetails(this.eventId)
    : type = _ScannerTargetType.eventDetails,
      event = null;

  final _ScannerTargetType type;
  final EventDetailModel? event;
  final int? eventId;
}

class _TransferTicketRequestSheet extends ConsumerStatefulWidget {
  const _TransferTicketRequestSheet({required this.transferToken});

  final String transferToken;

  @override
  ConsumerState<_TransferTicketRequestSheet> createState() =>
      _TransferTicketRequestSheetState();
}

class _TransferTicketRequestSheetState
    extends ConsumerState<_TransferTicketRequestSheet> {
  bool _isSubmitting = false;
  String? _errorMessage;

  Future<void> _submit() async {
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final result = await ref
        .read(marketplaceProvider.notifier)
        .requestTransferFromScan(transferToken: widget.transferToken);

    if (!mounted) return;

    final providerState = ref.read(marketplaceProvider);
    if (providerState.hasError || result == null) {
      setState(() {
        _isSubmitting = false;
        _errorMessage =
            providerState.error?.toString() ??
            'We could not send the ticket request. Please try again.';
      });
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    Navigator.of(context).pop();
    messenger.showSnackBar(
      const SnackBar(
        content: Text(
          'Transfer request sent to the owner. Waiting for approval.',
        ),
        backgroundColor: Colors.green,
      ),
    );
    router.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Request this ticket',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'We found a Duty transfer ticket QR. Send a request and the current owner will be able to approve or reject it from their transfer inbox.',
            style: GoogleFonts.inter(
              color: Colors.white70,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFF8F0DF2).withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(
                    Icons.swap_horizontal_circle_rounded,
                    color: Color(0xFFE9B4FF),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'The owner keeps the ticket until they approve. If they accept, it moves to your account automatically.',
                    style: GoogleFonts.inter(
                      color: Colors.white70,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.red.withValues(alpha: 0.24)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.redAccent,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: GoogleFonts.inter(
                        color: Colors.redAccent,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white24),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: _isSubmitting
                      ? null
                      : () => Navigator.of(context).pop(),
                  child: Text(
                    'Not now',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8F0DF2),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Send Request',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TransferRecipientConfirmSheet extends ConsumerStatefulWidget {
  const _TransferRecipientConfirmSheet({
    required this.booking,
    required this.recipientInfo,
    required this.onConfirm,
  });

  final BookingModel booking;
  final Map<String, dynamic> recipientInfo;
  final Future<void> Function() onConfirm;

  @override
  ConsumerState<_TransferRecipientConfirmSheet> createState() =>
      _TransferRecipientConfirmSheetState();
}

class _TransferRecipientConfirmSheetState
    extends ConsumerState<_TransferRecipientConfirmSheet> {
  bool _isSubmitting = false;
  String? _errorMessage;

  Future<void> _submit() async {
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      await widget.onConfirm();
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      final router = GoRouter.of(context);
      Navigator.of(context).pop();
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Transfer request sent. Waiting for approval.'),
          backgroundColor: Colors.green,
        ),
      );
      router.pop();
    } catch (_) {
      final providerState = ref.read(marketplaceProvider);
      setState(() {
        _isSubmitting = false;
        _errorMessage =
            providerState.error?.toString() ??
            'Transfer failed. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final recipientName =
        widget.recipientInfo['name']?.toString().trim().isNotEmpty == true
        ? widget.recipientInfo['name'].toString().trim()
        : 'Duty user';
    final recipientUsername = widget.recipientInfo['username']
        ?.toString()
        .trim();
    final recipientEmail = widget.recipientInfo['email']?.toString().trim();

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Send transfer request',
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'We found the receiver. Confirm before we send the request for ${widget.booking.eventTitle}.',
            style: GoogleFonts.inter(
              color: Colors.white70,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: const Color(
                    0xFF8F0DF2,
                  ).withValues(alpha: 0.18),
                  child: Text(
                    recipientName.substring(0, 1).toUpperCase(),
                    style: GoogleFonts.outfit(
                      color: const Color(0xFFE9B4FF),
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recipientName,
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (recipientUsername != null &&
                          recipientUsername.isNotEmpty)
                        Text(
                          '@$recipientUsername',
                          style: GoogleFonts.inter(
                            color: Colors.white60,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      if (recipientEmail != null && recipientEmail.isNotEmpty)
                        Text(
                          recipientEmail,
                          style: GoogleFonts.inter(
                            color: Colors.white38,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.verified_rounded,
                  color: Color(0xFF54E0A6),
                  size: 24,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.amber.withValues(alpha: 0.16)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline, color: Colors.amber, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'The receiver still needs to accept the transfer. The ticket stays with you until they do.',
                    style: GoogleFonts.inter(
                      color: Colors.amber,
                      fontSize: 13,
                      height: 1.45,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.red.withValues(alpha: 0.18)),
              ),
              child: Text(
                _errorMessage!,
                style: GoogleFonts.inter(
                  color: Colors.redAccent,
                  fontSize: 13,
                  height: 1.45,
                ),
              ),
            ),
          ],
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white24),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: _isSubmitting
                      ? null
                      : () => Navigator.of(context).pop(),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8F0DF2),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting
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
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScannerErrorView extends StatelessWidget {
  const _ScannerErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF09070F),
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF151022),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Icon(
                  Icons.camera_alt_outlined,
                  color: Colors.white70,
                  size: 30,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Camera access is needed',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: Colors.white60,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassActionButton extends StatelessWidget {
  const _GlassActionButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}

class _ScannerModeChip extends StatelessWidget {
  const _ScannerModeChip({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: active
              ? Colors.purpleAccent.withValues(alpha: 0.14)
              : Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: active
                ? Colors.purpleAccent.withValues(alpha: 0.28)
                : Colors.white.withValues(alpha: 0.06),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: active ? const Color(0xFFE9B4FF) : Colors.white54,
              size: 20,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _CornerAlignment { topLeft, topRight, bottomLeft, bottomRight }

class _CornerFrame extends StatelessWidget {
  const _CornerFrame({required this.alignment});

  final _CornerAlignment alignment;

  @override
  Widget build(BuildContext context) {
    final isTop =
        alignment == _CornerAlignment.topLeft ||
        alignment == _CornerAlignment.topRight;
    final isLeft =
        alignment == _CornerAlignment.topLeft ||
        alignment == _CornerAlignment.bottomLeft;

    return SizedBox(
      width: 56,
      height: 56,
      child: CustomPaint(
        painter: _CornerFramePainter(isTop: isTop, isLeft: isLeft),
      ),
    );
  }
}

class _CornerFramePainter extends CustomPainter {
  const _CornerFramePainter({required this.isTop, required this.isLeft});

  final bool isTop;
  final bool isLeft;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFA855F7)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();

    if (isTop && isLeft) {
      path
        ..moveTo(size.width, 0)
        ..lineTo(12, 0)
        ..quadraticBezierTo(0, 0, 0, 12)
        ..lineTo(0, size.height);
    } else if (isTop && !isLeft) {
      path
        ..moveTo(0, 0)
        ..lineTo(size.width - 12, 0)
        ..quadraticBezierTo(size.width, 0, size.width, 12)
        ..lineTo(size.width, size.height);
    } else if (!isTop && isLeft) {
      path
        ..moveTo(0, 0)
        ..lineTo(0, size.height - 12)
        ..quadraticBezierTo(0, size.height, 12, size.height)
        ..lineTo(size.width, size.height);
    } else {
      path
        ..moveTo(size.width, 0)
        ..lineTo(size.width, size.height - 12)
        ..quadraticBezierTo(
          size.width,
          size.height,
          size.width - 12,
          size.height,
        )
        ..lineTo(0, size.height);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CornerFramePainter oldDelegate) {
    return oldDelegate.isTop != isTop || oldDelegate.isLeft != isLeft;
  }
}
