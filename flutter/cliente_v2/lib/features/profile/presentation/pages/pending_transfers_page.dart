import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/colors.dart';
import '../providers/marketplace_provider.dart';

class PendingTransfersPage extends ConsumerWidget {
  const PendingTransfersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.dutyTheme;
    final pendingAsync = ref.watch(pendingTransfersProvider);

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        backgroundColor: palette.background,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: palette.textPrimary),
        title: Text(
          'Transfer Inbox',
          style: GoogleFonts.manrope(
            fontWeight: FontWeight.bold,
            color: palette.textPrimary,
          ),
        ),
      ),
      body: pendingAsync.when(
        loading: () =>
            Center(child: CircularProgressIndicator(color: palette.primary)),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: palette.danger, size: 48),
              const SizedBox(height: 16),
              Text(
                'Failed to load transfers',
                style: GoogleFonts.manrope(color: palette.textSecondary),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => ref.invalidate(pendingTransfersProvider),
                style: ElevatedButton.styleFrom(
                  backgroundColor: palette.primary,
                  foregroundColor: palette.textPrimary,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (transfers) {
          if (transfers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.swap_horiz_rounded,
                    size: 64,
                    color: palette.textMuted.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No pending transfers',
                    style: GoogleFonts.manrope(
                      color: palette.textSecondary,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Approvals and incoming transfer requests will appear here.',
                    style: GoogleFonts.manrope(
                      color: palette.textMuted,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(pendingTransfersProvider),
            color: palette.primary,
            backgroundColor: palette.surface,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: transfers.length,
              itemBuilder: (context, index) {
                final transfer = transfers[index];
                return _TransferRequestCard(transfer: transfer);
              },
            ),
          );
        },
      ),
    );
  }
}

class _TransferRequestCard extends ConsumerStatefulWidget {
  final dynamic transfer;

  const _TransferRequestCard({required this.transfer});

  @override
  ConsumerState<_TransferRequestCard> createState() =>
      _TransferRequestCardState();
}

class _TransferRequestCardState extends ConsumerState<_TransferRequestCard> {
  bool _isProcessing = false;

  Future<void> _handleAccept() async {
    final palette = context.dutyTheme;
    setState(() => _isProcessing = true);

    await ref
        .read(marketplaceProvider.notifier)
        .acceptTransfer(transferId: widget.transfer['id']);

    final state = ref.read(marketplaceProvider);
    if (!mounted) return;

    if (state.hasError) {
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to accept transfer'),
          backgroundColor: palette.danger,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Transfer accepted! The ticket is now yours.'),
        backgroundColor: palette.success,
      ),
    );
  }

  Future<void> _handleReject() async {
    final palette = context.dutyTheme;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: palette.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Reject Transfer?',
          style: GoogleFonts.manrope(
            color: palette.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'The ticket will remain with the sender.',
          style: GoogleFonts.manrope(color: palette.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.manrope(color: palette.textMuted),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Reject',
              style: GoogleFonts.manrope(color: palette.danger),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isProcessing = true);

    await ref
        .read(marketplaceProvider.notifier)
        .rejectTransfer(transferId: widget.transfer['id']);

    final state = ref.read(marketplaceProvider);
    if (!mounted) return;

    if (state.hasError) {
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to reject transfer'),
          backgroundColor: palette.danger,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Transfer rejected.'),
        backgroundColor: palette.warning,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.dutyTheme;
    final sender = widget.transfer['sender'] ?? {};
    final event = widget.transfer['event'] ?? {};
    final flow = widget.transfer['flow']?.toString() ?? 'owner_offer';
    final messageTitle =
        widget.transfer['message_title']?.toString() ??
        (flow == 'receiver_request' ? 'Ticket request' : 'Incoming transfer');
    final messageBody =
        widget.transfer['message_body']?.toString() ??
        'Open this request to review the ticket details.';
    final senderName = (sender['name']?.toString().trim().isNotEmpty ?? false)
        ? sender['name'].toString().trim()
        : 'Unknown';
    final senderUsername = sender['username'];
    final eventTitle = event['title'] ?? 'Unknown Event';
    final eventDate = event['date'];

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => context.push('/transfer-requests/${widget.transfer['id']}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: palette.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: palette.primarySurface,
                  child: Text(
                    senderName.substring(0, 1).toUpperCase(),
                    style: GoogleFonts.manrope(
                      color: palette.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        senderName,
                        style: GoogleFonts.manrope(
                          color: palette.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      if (senderUsername != null)
                        Text(
                          '@$senderUsername',
                          style: GoogleFonts.manrope(
                            color: palette.textMuted,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: palette.warning.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Pending',
                    style: GoogleFonts.manrope(
                      color: palette.warning,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              messageTitle,
              style: GoogleFonts.manrope(
                color: palette.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              messageBody,
              style: GoogleFonts.manrope(
                color: palette.textSecondary,
                fontSize: 13,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: palette.surfaceAlt,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.confirmation_num,
                    color: palette.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          eventTitle,
                          style: GoogleFonts.manrope(
                            color: palette.textPrimary,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (eventDate != null)
                          Text(
                            eventDate,
                            style: GoogleFonts.manrope(
                              color: palette.textMuted,
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (_isProcessing)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: CircularProgressIndicator(
                    color: palette.primary,
                    strokeWidth: 2,
                  ),
                ),
              )
            else
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: palette.textPrimary,
                        side: BorderSide(color: palette.border),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => context.push(
                        '/transfer-requests/${widget.transfer['id']}',
                      ),
                      child: Text(
                        'Open Request',
                        style: GoogleFonts.manrope(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: palette.danger,
                            side: BorderSide(
                              color: palette.danger.withValues(alpha: 0.5),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _handleReject,
                          child: Text(
                            'Reject',
                            style: GoogleFonts.manrope(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: palette.primary,
                            foregroundColor: palette.textPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _handleAccept,
                          child: Text(
                            'Accept Ticket',
                            style: GoogleFonts.manrope(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
