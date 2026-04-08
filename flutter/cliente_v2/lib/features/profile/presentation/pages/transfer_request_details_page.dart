import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_urls.dart';
import '../../../../core/theme/colors.dart';
import '../providers/marketplace_provider.dart';

class TransferRequestDetailsPage extends ConsumerStatefulWidget {
  const TransferRequestDetailsPage({super.key, required this.transferId});

  final int transferId;

  @override
  ConsumerState<TransferRequestDetailsPage> createState() =>
      _TransferRequestDetailsPageState();
}

class _TransferRequestDetailsPageState
    extends ConsumerState<TransferRequestDetailsPage> {
  bool _isProcessing = false;

  Future<void> _runAction(
    Future<void> Function() action, {
    required String successMessage,
    required Color successColor,
  }) async {
    final palette = context.dutyTheme;
    setState(() => _isProcessing = true);
    await action();
    final state = ref.read(marketplaceProvider);
    if (!mounted) return;

    if (state.hasError) {
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.error.toString()),
          backgroundColor: palette.danger,
        ),
      );
      return;
    }

    ref.invalidate(transferDetailsProvider(widget.transferId));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(successMessage), backgroundColor: successColor),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.dutyTheme;
    final transferAsync = ref.watch(transferDetailsProvider(widget.transferId));

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        backgroundColor: palette.background,
        elevation: 0,
        iconTheme: IconThemeData(color: palette.textPrimary),
        title: Text(
          'Transfer Request',
          style: GoogleFonts.manrope(
            color: palette.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: transferAsync.when(
        loading: () =>
            Center(child: CircularProgressIndicator(color: palette.primary)),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, color: palette.danger, size: 48),
                const SizedBox(height: 16),
                Text(
                  'We could not load this transfer request.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.manrope(color: palette.textSecondary),
                ),
              ],
            ),
          ),
        ),
        data: (transfer) {
          if (transfer == null) {
            return Center(
              child: Text(
                'Transfer not found.',
                style: GoogleFonts.manrope(color: palette.textSecondary),
              ),
            );
          }

          final event = transfer['event'] as Map<String, dynamic>? ?? {};
          final sender = transfer['sender'] as Map<String, dynamic>? ?? {};
          final receiver = transfer['receiver'] as Map<String, dynamic>? ?? {};
          final flow = (transfer['flow'] ?? 'owner_offer').toString();
          final thumbnail = AppUrls.getEventThumbnailUrl(
            event['thumbnail']?.toString(),
          );
          final canAccept = transfer['can_accept'] == true;
          final canReject = transfer['can_reject'] == true;
          final canCancel = transfer['can_cancel'] == true;
          final isReceiverRequest = flow == 'receiver_request';
          final headline =
              transfer['message_title']?.toString() ?? 'Transfer Request';
          final summary =
              transfer['message_body']?.toString() ??
              'Review this ticket transfer request.';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (thumbnail != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: CachedNetworkImage(
                      imageUrl: thumbnail,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  )
                else
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: palette.surface,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.local_activity_rounded,
                        color: palette.textMuted,
                        size: 48,
                      ),
                    ),
                  ),
                const SizedBox(height: 18),
                Text(
                  headline,
                  style: GoogleFonts.outfit(
                    color: palette.textPrimary,
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  summary,
                  style: GoogleFonts.inter(
                    color: palette.textSecondary,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: palette.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: palette.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event['title']?.toString() ?? 'Unknown Event',
                        style: GoogleFonts.manrope(
                          color: palette.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        event['date']?.toString() ?? 'Date pending',
                        style: GoogleFonts.manrope(
                          color: palette.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 18),
                      _ActorSummaryRow(
                        label: isReceiverRequest ? 'Requester' : 'Sender',
                        actor: sender,
                      ),
                      const SizedBox(height: 12),
                      _ActorSummaryRow(
                        label: isReceiverRequest ? 'Ticket owner' : 'Receiver',
                        actor: receiver,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: palette.surfaceAlt,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: palette.border),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: palette.primary,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          isReceiverRequest
                              ? 'Approving this request moves the ticket to the requester immediately.'
                              : 'Approving this transfer moves the ticket into your account immediately.',
                          style: GoogleFonts.inter(
                            color: palette.textSecondary,
                            fontSize: 13,
                            height: 1.45,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                if (_isProcessing)
                  Center(
                    child: CircularProgressIndicator(color: palette.primary),
                  )
                else ...[
                  if (canAccept || canReject)
                    Row(
                      children: [
                        if (canReject)
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: palette.danger,
                                side: BorderSide(
                                  color: palette.danger.withValues(alpha: 0.5),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 15,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              onPressed: () => _runAction(
                                () => ref
                                    .read(marketplaceProvider.notifier)
                                    .rejectTransfer(
                                      transferId: widget.transferId,
                                    ),
                                successMessage: 'Transfer request rejected.',
                                successColor: palette.warning,
                              ),
                              child: Text(
                                'Reject',
                                style: GoogleFonts.manrope(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        if (canReject && canAccept) const SizedBox(width: 12),
                        if (canAccept)
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: palette.primary,
                                foregroundColor: palette.textPrimary,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 15,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              onPressed: () => _runAction(
                                () => ref
                                    .read(marketplaceProvider.notifier)
                                    .acceptTransfer(
                                      transferId: widget.transferId,
                                    ),
                                successMessage: isReceiverRequest
                                    ? 'Transfer approved. The ticket has been sent.'
                                    : 'Transfer accepted! The ticket is now yours.',
                                successColor: palette.success,
                              ),
                              child: Text(
                                isReceiverRequest
                                    ? 'Approve Request'
                                    : 'Accept Ticket',
                                style: GoogleFonts.manrope(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  if (canCancel) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: palette.textPrimary,
                          side: BorderSide(color: palette.border),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () => _runAction(
                          () => ref
                              .read(marketplaceProvider.notifier)
                              .cancelTransfer(transferId: widget.transferId),
                          successMessage: 'Transfer request cancelled.',
                          successColor: palette.info,
                        ),
                        child: Text(
                          'Cancel Request',
                          style: GoogleFonts.manrope(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ActorSummaryRow extends StatelessWidget {
  const _ActorSummaryRow({required this.label, required this.actor});

  final String label;
  final Map<String, dynamic> actor;

  @override
  Widget build(BuildContext context) {
    final palette = context.dutyTheme;
    final name = actor['name']?.toString().trim();
    final username = actor['username']?.toString().trim();
    final source = name?.isNotEmpty == true ? name! : 'U';
    final initial = source.substring(0, 1).toUpperCase();

    return Row(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: palette.primarySurface,
          child: Text(
            initial,
            style: GoogleFonts.manrope(
              color: palette.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.manrope(
                  color: palette.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                name?.isNotEmpty == true ? name! : 'Duty user',
                style: GoogleFonts.manrope(
                  color: palette.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (username?.isNotEmpty == true)
                Text(
                  '@$username',
                  style: GoogleFonts.manrope(
                    color: palette.textSecondary,
                    fontSize: 12,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
