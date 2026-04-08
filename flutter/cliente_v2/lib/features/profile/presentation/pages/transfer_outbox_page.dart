import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/providers/profile_state_provider.dart';
import '../../../../core/theme/colors.dart';
import '../providers/marketplace_provider.dart';

class TransferOutboxPage extends ConsumerWidget {
  const TransferOutboxPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.dutyTheme;
    final outboxAsync = ref.watch(outboxTransfersProvider);
    final landingRoute = ref.watch(activeProfileLandingRouteProvider);

    void handleExit() {
      final navigator = Navigator.of(context);
      if (navigator.canPop()) {
        context.pop();
        return;
      }
      context.go(landingRoute);
    }

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        backgroundColor: palette.background,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: palette.textPrimary),
          onPressed: handleExit,
          tooltip: 'Volver',
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.home_rounded, color: palette.textPrimary),
            onPressed: () => context.go(landingRoute),
            tooltip: 'Ir al inicio',
          ),
        ],
        title: Text(
          'Transfer Outbox',
          style: GoogleFonts.manrope(
            fontWeight: FontWeight.bold,
            color: palette.textPrimary,
          ),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: palette.textPrimary),
        elevation: 0,
      ),
      body: outboxAsync.when(
        loading: () =>
            Center(child: CircularProgressIndicator(color: palette.primary)),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: palette.danger, size: 48),
              const SizedBox(height: 16),
              Text(
                'Failed to load your requests',
                style: GoogleFonts.manrope(color: palette.textSecondary),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => ref.invalidate(outboxTransfersProvider),
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
                    Icons.outbox_rounded,
                    size: 64,
                    color: palette.textMuted.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No outgoing transfer activity',
                    style: GoogleFonts.manrope(
                      color: palette.textSecondary,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Requests you send and tickets you offer will appear here.',
                    style: GoogleFonts.manrope(
                      color: palette.textMuted,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  OutlinedButton.icon(
                    onPressed: () => context.go(landingRoute),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: palette.textPrimary,
                      side: BorderSide(color: palette.border),
                    ),
                    icon: const Icon(Icons.home_rounded),
                    label: const Text('Ir al inicio'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(outboxTransfersProvider),
            color: palette.primary,
            backgroundColor: palette.surface,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: transfers.length,
              itemBuilder: (context, index) {
                final transfer = transfers[index];
                return _TransferOutboxCard(transfer: transfer);
              },
            ),
          );
        },
      ),
    );
  }
}

class _TransferOutboxCard extends ConsumerStatefulWidget {
  const _TransferOutboxCard({required this.transfer});

  final dynamic transfer;

  @override
  ConsumerState<_TransferOutboxCard> createState() =>
      _TransferOutboxCardState();
}

class _TransferOutboxCardState extends ConsumerState<_TransferOutboxCard> {
  bool _isProcessing = false;

  Future<void> _handleCancel() async {
    final palette = context.dutyTheme;
    setState(() => _isProcessing = true);

    await ref
        .read(marketplaceProvider.notifier)
        .cancelTransfer(transferId: widget.transfer['id']);

    final state = ref.read(marketplaceProvider);
    if (!mounted) return;

    if (state.hasError) {
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to cancel transfer request'),
          backgroundColor: palette.danger,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Transfer request cancelled.'),
        backgroundColor: palette.info,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.dutyTheme;
    final transfer = widget.transfer as Map<String, dynamic>;
    final event = transfer['event'] as Map<String, dynamic>? ?? {};
    final receiver = transfer['receiver'] as Map<String, dynamic>? ?? {};
    final status = (transfer['status'] ?? 'pending').toString();
    final flow = (transfer['flow'] ?? 'owner_offer').toString();
    final title = transfer['message_title']?.toString() ?? 'Transfer pending';
    final body =
        transfer['message_body']?.toString() ??
        'Open this request to see the latest transfer status.';
    final counterpartyName =
        (receiver['name']?.toString().trim().isNotEmpty ?? false)
        ? receiver['name'].toString().trim()
        : (receiver['username']?.toString().trim().isNotEmpty ?? false)
        ? '@${receiver['username']}'
        : 'Duty user';

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => context.push('/transfer-requests/${transfer['id']}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _statusColor(status, palette).withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.manrope(
                      color: palette.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                _StatusChip(status: status),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              body,
              style: GoogleFonts.manrope(
                color: palette.textSecondary,
                fontSize: 13,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 14),
            _MiniMetaLine(
              icon: flow == 'receiver_request'
                  ? Icons.person_search_rounded
                  : Icons.send_to_mobile_rounded,
              label: flow == 'receiver_request' ? 'Requested from' : 'Sent to',
              value: counterpartyName,
            ),
            const SizedBox(height: 8),
            _MiniMetaLine(
              icon: Icons.local_activity_outlined,
              label: 'Event',
              value: event['title']?.toString() ?? 'Unknown Event',
            ),
            if (event['date']?.toString().isNotEmpty ?? false) ...[
              const SizedBox(height: 8),
              _MiniMetaLine(
                icon: Icons.calendar_today_outlined,
                label: 'Date',
                value: event['date'].toString(),
              ),
            ],
            if (_isProcessing) ...[
              const SizedBox(height: 16),
              LinearProgressIndicator(color: palette.primary),
            ] else if (transfer['can_cancel'] == true) ...[
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  onPressed: _handleCancel,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: palette.textPrimary,
                    side: BorderSide(color: palette.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.close_rounded),
                  label: const Text('Cancel request'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status, DutyThemeTokens palette) {
    switch (status) {
      case 'accepted':
        return palette.success;
      case 'rejected':
        return palette.warning;
      case 'cancelled':
        return palette.info;
      default:
        return palette.primary;
    }
  }
}

class _MiniMetaLine extends StatelessWidget {
  const _MiniMetaLine({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final palette = context.dutyTheme;
    return Row(
      children: [
        Icon(icon, size: 16, color: palette.textMuted),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: GoogleFonts.manrope(
            color: palette.textMuted,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.manrope(
              color: palette.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final palette = context.dutyTheme;
    final color = switch (status) {
      'accepted' => palette.success,
      'rejected' => palette.warning,
      'cancelled' => palette.info,
      _ => palette.primary,
    };
    final label = switch (status) {
      'accepted' => 'Accepted',
      'rejected' => 'Rejected',
      'cancelled' => 'Cancelled',
      _ => 'Pending',
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: GoogleFonts.manrope(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
