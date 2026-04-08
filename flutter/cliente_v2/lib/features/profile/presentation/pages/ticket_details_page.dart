import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../core/theme/colors.dart';
import '../../data/models/booking_model.dart';
import '../providers/marketplace_provider.dart';

import '../../data/models/reward_instance_model.dart';

class TicketDetailsPage extends ConsumerWidget {
  final BookingModel booking;

  const TicketDetailsPage({super.key, required this.booking});
  void _handleTransfer(BuildContext context, WidgetRef ref) {
    if (booking.transferStatus == 'transfer_pending') {
      final palette = context.dutyTheme;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('This ticket already has a pending transfer request.'),
          backgroundColor: palette.warning,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: context.dutyTheme.surface,
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

  void _handleTransfer(BuildContext context, WidgetRef ref) {
    final recipientController = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: context.dutyTheme.surface,
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
    final palette = context.dutyTheme;
    final qrData = await ref
        .read(marketplaceProvider.notifier)
        .getTransferTicketQr(bookingId: booking.id);

    if (!context.mounted) return;

    if (qrData == null || qrData['qr_value'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('We could not generate a transfer QR for this ticket.'),
          backgroundColor: palette.danger,
        ),
      );
      return;
    }

    final qrValue = qrData['qr_value'].toString();

    await showModalBottomSheet(
      context: context,
      backgroundColor: palette.surface,
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
              'Transfer Ticket',
              style: GoogleFonts.manrope(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: palette.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Let someone scan this QR from the main scanner in Duty to request your ticket. You still approve the transfer before it moves.',
              style: GoogleFonts.manrope(
                color: palette.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: recipientController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Email or Username',
                hintStyle: const TextStyle(color: Colors.white24),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: palette.warning.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: palette.warning, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Only show this to the person you want to let request the ticket. They still need your approval from the transfer inbox.',
                      style: GoogleFonts.manrope(
                        color: palette.warning,
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
                  foregroundColor: palette.textPrimary,
                  side: BorderSide(color: palette.border),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: qrValue));
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Transfer QR copied to clipboard.'),
                      backgroundColor: palette.success,
                    ),
                  );
                },
                child: const Text('Send Transfer'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSell(BuildContext context, WidgetRef ref) {
    final palette = context.dutyTheme;
    final priceController = TextEditingController(
      text: booking.listingPrice > 0 ? booking.listingPrice.toString() : '',
    );

    showModalBottomSheet(
      context: context,
      backgroundColor: palette.surface,
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
                color: palette.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Set your price and list your ticket for other fans to buy.',
              style: GoogleFonts.manrope(color: palette.textSecondary),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              style: TextStyle(color: palette.textPrimary),
              decoration: InputDecoration(
                prefixText: '\$ ',
                prefixStyle: TextStyle(color: palette.textPrimary),
                hintText: 'Listing Price',
                hintStyle: TextStyle(color: palette.textMuted),
                filled: true,
                fillColor: palette.surfaceAlt,
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
                        foregroundColor: palette.danger,
                        side: BorderSide(color: palette.danger),
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
                        if (!state.hasError) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Ticket unlisted from marketplace.',
                              ),
                              backgroundColor: palette.info,
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
                      backgroundColor: palette.primary,
                      foregroundColor: palette.textPrimary,
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
                      if (state.hasError) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: ${state.error}'),
                            backgroundColor: palette.danger,
                          ),
                        );
                      } else {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Ticket listed successfully!'),
                            backgroundColor: palette.success,
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
    final palette = context.dutyTheme;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: palette.primary),
            const SizedBox(height: 16),
            Text(
              'Adding to Apple Wallet...',
              style: TextStyle(
                color: palette.textPrimary,
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
          backgroundColor: palette.surface,
          title: Row(
            children: [
              Icon(Icons.check_circle, color: palette.success),
              SizedBox(width: 8),
              Text('Success', style: TextStyle(color: palette.textPrimary)),
            ],
          ),
          content: Text(
            'Ticket successfully added to your Apple Wallet.',
            style: TextStyle(color: palette.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK', style: TextStyle(color: palette.primary)),
            ),
          ],
        ),
      );
    }
  }

  void _showComingSoonDialog(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1528),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Coming Soon',
          style: GoogleFonts.manrope(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          '$feature functionality will be available in the next update. Stay tuned!',
          style: GoogleFonts.manrope(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Understood',
              style: GoogleFonts.manrope(
                color: kPrimaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.dutyTheme;
    final pendingPrompts =
        ref.watch(pendingReviewPromptsProvider).valueOrNull ??
        const <ReviewPromptModel>[];
    ReviewPromptModel? pendingPrompt;
    for (final item in pendingPrompts) {
      if (item.bookingId == booking.id) {
        pendingPrompt = item;
        break;
      }
    }

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close_rounded, color: palette.textPrimary),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
        title: Text(
          'Mobile Ticket',
          style: GoogleFonts.manrope(
            color: palette.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded, color: Colors.white),
            onPressed: _handleShare,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildPhysicalTicket(context),
            const SizedBox(height: 32),
            if (booking.rewards.isNotEmpty) ...[
              _buildRewardsSection(context),
              const SizedBox(height: 32),
            ],
            if (pendingPrompt != null && booking.isPastEvent) ...[
              _buildReviewPromptCard(context, pendingPrompt.targets.length),
              const SizedBox(height: 20),
            ],
            _buildActionButtons(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewPromptCard(BuildContext context, int pendingTargetsCount) {
    final palette = context.dutyTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [palette.primaryDeep, palette.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: palette.onPrimary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.rate_review_rounded,
                  color: palette.textPrimary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Tienes $pendingTargetsCount review${pendingTargetsCount == 1 ? '' : 's'} pendiente${pendingTargetsCount == 1 ? '' : 's'}',
                  style: GoogleFonts.manrope(
                    color: palette.textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Comparte tu experiencia del evento, el organizador y los artistas desde tu inbox de reviews.',
            style: GoogleFonts.manrope(
              color: palette.onPrimary.withValues(alpha: 0.82),
              fontSize: 13,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: palette.onPrimary,
                foregroundColor: palette.primaryDeep,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () => context.push('/reviews/pending'),
              icon: const Icon(Icons.arrow_forward_rounded),
              label: Text(
                'Calificar ahora',
                style: GoogleFonts.manrope(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardsSection(BuildContext context) {
    final palette = context.dutyTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.stars_rounded, color: palette.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              'REWARDS & PERKS',
              style: GoogleFonts.manrope(
                color: palette.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...booking.rewards.map((reward) => _buildRewardItem(context, reward)),
      ],
    );
  }

  Widget _buildRewardItem(BuildContext context, RewardInstanceModel reward) {
    final palette = context.dutyTheme;
    final bool isClaimed = reward.isClaimed;
    final bool isActivated = reward.isActivated;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: palette.surfaceAlt,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: palette.border.withValues(alpha: 0.5)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: (isClaimed ? Colors.grey : palette.primary).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _getRewardIcon(reward.rewardType),
            color: isClaimed ? palette.textMuted : palette.primary,
          ),
        ),
        title: Text(
          reward.title,
          style: GoogleFonts.manrope(
            color: isClaimed ? palette.textMuted : palette.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 15,
            decoration: isClaimed ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isClaimed
                  ? 'Already claimed'
                  : (isActivated ? 'Ready to claim' : 'Requires ticket entry scan'),
              style: GoogleFonts.manrope(
                color: isClaimed
                    ? palette.textMuted
                    : (isActivated ? palette.success : palette.textSecondary),
                fontSize: 12,
              ),
            ),
            if (reward.sponsorName != null && !isClaimed) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    'Powered by ',
                    style: GoogleFonts.manrope(
                      color: palette.textSecondary,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    reward.sponsorName!,
                    style: GoogleFonts.manrope(
                      color: palette.primary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        trailing: Icon(
          isClaimed ? Icons.check_circle_outline : Icons.qr_code_2_rounded,
          color: isClaimed ? palette.textMuted : (isActivated ? palette.primary : palette.border),
        ),
        onTap: isClaimed ? null : () => _showRewardQrSheet(context, reward),
      ),
    );
  }

  IconData _getRewardIcon(String type) {
    switch (type) {
      case 'drink':
        return Icons.local_bar_rounded;
      case 'merch':
        return Icons.checkroom_rounded;
      case 'perk_access':
        return Icons.verified_user_rounded;
      case 'voucher':
        return Icons.confirmation_number_rounded;
      default:
        return Icons.card_giftcard_rounded;
    }
  }

  void _showRewardQrSheet(BuildContext context, RewardInstanceModel reward) {
    final palette = context.dutyTheme;
    final bool isActivated = reward.isActivated;

    showModalBottomSheet(
      context: context,
      backgroundColor: palette.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: palette.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              reward.title,
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: palette.textPrimary,
              ),
            ),
            if (reward.sponsorName != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: palette.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (reward.sponsorLogoUrl != null) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: CachedNetworkImage(
                          imageUrl: reward.sponsorLogoUrl!,
                          width: 16,
                          height: 16,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      'POWERED BY ${reward.sponsorName!.toUpperCase()}',
                      style: GoogleFonts.manrope(
                        color: palette.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              isActivated
                  ? 'Show this code to the staff member to redeem'
                  : 'This reward will be activated automatically when your ticket is scanned at the entrance.',
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(
                color: palette.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 32),
            if (isActivated && reward.claimQrPayload != null)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: palette.primary.withValues(alpha: 0.1),
                      blurRadius: 20,
                      spreadRadius: 5,
                    )
                  ],
                ),
                child: QrImageView(
                  data: reward.claimQrPayload!,
                  version: QrVersions.auto,
                  size: 220,
                ),
              )
            else
              Container(
                height: 260,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: palette.surfaceAlt,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: palette.border),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.lock_clock_rounded,
                      size: 64,
                      color: palette.textMuted,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Locked until arrival',
                      style: GoogleFonts.manrope(
                        color: palette.textMuted,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 32),
            if (reward.claimCode != null) ...[
              Text(
                'CLAIM CODE',
                style: GoogleFonts.manrope(
                  color: palette.textMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                reward.claimCode!,
                style: GoogleFonts.spaceMono(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: palette.textPrimary,
                ),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Close',
                  style: GoogleFonts.manrope(
                    color: palette.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhysicalTicket(BuildContext context) {
    final palette = context.dutyTheme;
    return PhysicalModel(
      color: Colors.transparent,
      elevation: 8,
      shadowColor: palette.primaryGlow.withValues(alpha: 0.3),
      borderRadius: BorderRadius.circular(24),
      child: Column(
        children: [
          // Top Part (Event Image & Info)
          Container(
            decoration: BoxDecoration(
              color: palette.onPrimary,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Event Image
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  child: CachedNetworkImage(
                    imageUrl:
                        booking.eventImage ??
                        'https://via.placeholder.com/800x400',
                    height: 260,
                    width: double.infinity,
                    fit: BoxFit.fill,
                    errorWidget: (_, __, ___) => Container(
                      height: 180,
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(Icons.image_not_supported),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.eventTitle,
                        style: GoogleFonts.manrope(
                          color: palette.background,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            booking.eventDate ?? 'Date TBD',
                            style: GoogleFonts.manrope(
                              color: palette.background,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Icon(
                            Icons.location_on_rounded,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Venue TBD', // Placeholder as venue is not in model
                              style: GoogleFonts.manrope(
                                color: palette.background,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Icon(
                            Icons.business_rounded,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Organized by: ${booking.organizerName ?? "Staff"}',
                              style: GoogleFonts.manrope(
                                color: palette.background,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
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

          // Perforation
          _buildPerforationLine(context),

          // Bottom Part (QR Code)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: palette.onPrimary,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            child: Column(
              children: [
                // Fee Breakdown
                Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Column(
                    children: [
                      _buildBreakdownRow(
                        context,
                        'Ticket Price',
                        '\$${booking.price.toStringAsFixed(2)}',
                        isDark: true,
                      ),
                      const SizedBox(height: 8),
                      _buildBreakdownRow(
                        context,
                        'Processing Fee',
                        '\$${booking.tax.toStringAsFixed(2)}',
                        isDark: true,
                      ),
                      if (booking.discount > 0) ...[
                        const SizedBox(height: 8),
                        _buildBreakdownRow(
                          context,
                          'Discount',
                          '-\$${booking.discount.toStringAsFixed(2)}',
                          isDark: true,
                        ),
                      ],
                      Divider(color: palette.border, height: 24),
                      _buildBreakdownRow(
                        context,
                        'Total Paid',
                        '\$${booking.total.toStringAsFixed(2)}',
                        isDark: true,
                        isTotal: true,
                      ),
                    ],
                  ),
                ),
                QrImageView(
                  data: booking.bookingId,
                  version: QrVersions.auto,
                  size: 200.0,
                  foregroundColor: Colors.black,
                ),
                const SizedBox(height: 16),
                Text(
                  'SCAN THIS CODE AT THE GATE',
                  style: GoogleFonts.manrope(
                    color: Colors.grey[500],
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                Text(
                  booking.bookingId,
                  style: GoogleFonts.spaceMono(
                    color: palette.background,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownRow(
    BuildContext context,
    String label,
    String value, {
    bool isTotal = false,
    bool isDark = false,
  }) {
    final palette = context.dutyTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.manrope(
            color: isDark
                ? (isTotal ? palette.background : palette.textSecondary)
                : palette.textSecondary,
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.manrope(
            color: isTotal
                ? palette.primary
                : (isDark ? palette.background : palette.textPrimary),
            fontSize: isTotal ? 20 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildPerforationLine(BuildContext context) {
    final palette = context.dutyTheme;
    return Container(
      color: palette.onPrimary,
      child: Stack(
        children: [
          SizedBox(
            height: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                20,
                (index) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Container(height: 1, color: palette.border),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: -10,
            top: -10,
            bottom: -10,
            child: Container(
              width: 20,
              decoration: BoxDecoration(
                color: palette.background,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: -10,
            top: -10,
            bottom: -10,
            child: Container(
              width: 20,
              decoration: BoxDecoration(
                color: palette.background,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoColumn(
    String label,
    String value, {
    bool isRightAligned = false,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: isRightAligned
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.manrope(
              color: Colors.grey[500],
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.manrope(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref) {
    final palette = context.dutyTheme;

    return Column(
      children: [
        if (!booking.isPastEvent) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: palette.primary,
                foregroundColor: palette.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            onPressed: () => _handleViewInvoice(context),
            icon: const Icon(Icons.receipt_long_rounded),
            label: Text(
              'View Invoice',
              style: GoogleFonts.manrope(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: palette.surfaceAlt,
                foregroundColor: palette.textPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () => _handleAddToWallet(context),
              icon: const Icon(Icons.wallet_rounded),
              label: Text(
                'Add to Apple Wallet',
                style: GoogleFonts.manrope(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
        // Only show action buttons for active (non-past) events
        if (booking.isPastEvent) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: palette.surfaceAlt,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: palette.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, color: palette.textMuted, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Past Event — View Only',
                  style: GoogleFonts.manrope(
                    color: palette.textMuted,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: palette.textPrimary,
                    side: BorderSide(color: palette.border),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () => _handleTransfer(context, ref),
                  child: Text(
                    'Transfer',
                    style: GoogleFonts.manrope(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: palette.textPrimary,
                    side: BorderSide(color: palette.border),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () => _handleSell(context, ref),
                  child: Text(
                    'Sell',
                    style: GoogleFonts.manrope(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

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
    final palette = context.dutyTheme;

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
              color: palette.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Send ${booking.eventTitle} by scanning the receiver code, or fall back to email and username if needed.',
            style: GoogleFonts.manrope(color: palette.textSecondary),
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
    final palette = context.dutyTheme;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: palette.surfaceAlt,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: palette.border),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: () => _handleAddToWallet(context),
            icon: const Icon(Icons.wallet_rounded),
            label: Text(
              'Add to Apple Wallet',
              style: GoogleFonts.manrope(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: palette.primarySurface,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(icon, color: palette.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.manrope(
                      color: palette.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: GoogleFonts.manrope(
                      color: palette.textSecondary,
                      fontSize: 13,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Icon(Icons.chevron_right_rounded, color: palette.textMuted),
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
    final palette = context.dutyTheme;

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
          SnackBar(
            content: const Text('Transfer request sent! Waiting for approval.'),
            backgroundColor: palette.success,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.dutyTheme;

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
              color: palette.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _recipientInfo == null
                ? 'Enter the email or username of the recipient.'
                : 'Confirm the recipient below.',
            style: GoogleFonts.manrope(color: palette.textSecondary),
          ),
          const SizedBox(height: 24),

          // Step 1: Input + Verify
          if (_recipientInfo == null) ...[
            TextField(
              controller: widget.recipientController,
              style: TextStyle(color: palette.textPrimary),
              decoration: InputDecoration(
                hintText: 'Email or Username',
                hintStyle: TextStyle(color: palette.textMuted),
                filled: true,
                fillColor: palette.surfaceAlt,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: Icon(Icons.person_search, color: palette.textMuted),
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
                  color: palette.danger.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: palette.danger.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: palette.danger, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: GoogleFonts.manrope(
                          color: palette.danger,
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
                  backgroundColor: palette.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: _isVerifying ? null : _verifyRecipient,
                child: _isVerifying
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: palette.onPrimary,
                        ),
                      )
                    : Text(
                        'Verify Recipient',
                        style: GoogleFonts.manrope(
                          fontWeight: FontWeight.w600,
                          color: palette.onPrimary,
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
                color: palette.surfaceAlt,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: palette.primary.withValues(alpha: 0.28),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: palette.primarySurface,
                    child: Text(
                      (_recipientInfo!['name'] ?? 'U')
                          .toString()
                          .substring(0, 1)
                          .toUpperCase(),
                      style: GoogleFonts.manrope(
                        color: palette.primary,
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
                            color: palette.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        if (_recipientInfo!['username'] != null)
                          Text(
                            '@${_recipientInfo!['username']}',
                            style: GoogleFonts.manrope(
                              color: palette.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        Text(
                          _recipientInfo!['email'] ?? '',
                          style: GoogleFonts.manrope(
                            color: palette.textMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.check_circle, color: palette.success, size: 28),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: palette.warning.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: palette.warning.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: palette.warning, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'The recipient must accept the transfer before the ticket is moved.',
                      style: GoogleFonts.manrope(
                        color: palette.warning,
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
                      foregroundColor: palette.textPrimary,
                      side: BorderSide(color: palette.border),
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
                      backgroundColor: palette.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: _isSending ? null : _sendTransfer,
                    child: _isSending
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: palette.onPrimary,
                            ),
                          )
                        : Text(
                            'Send Transfer Request',
                            style: GoogleFonts.manrope(
                              fontWeight: FontWeight.w600,
                              color: palette.onPrimary,
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
