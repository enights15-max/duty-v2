import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/marketplace_provider.dart';

class TransferOutboxPage extends ConsumerWidget {
  const TransferOutboxPage({super.key});

  static const Color kPrimaryColor = Color(0xFF8655F6);
  static const Color kDarkBackground = Color(0xFF0D0812);
  static const Color kCardColor = Color(0xFF151022);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final outboxAsync = ref.watch(outboxTransfersProvider);

    return Scaffold(
      backgroundColor: kDarkBackground,
      appBar: AppBar(
        backgroundColor: kDarkBackground,
        title: Text(
          'Transfer Outbox',
          style: GoogleFonts.manrope(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: outboxAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: kPrimaryColor),
        ),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.redAccent,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to load your requests',
                style: GoogleFonts.manrope(color: Colors.white54),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => ref.invalidate(outboxTransfersProvider),
                style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
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
                    color: Colors.white.withValues(alpha: 0.15),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No outgoing transfer activity',
                    style: GoogleFonts.manrope(
                      color: Colors.white54,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Requests you send and tickets you offer will appear here.',
                    style: GoogleFonts.manrope(
                      color: Colors.white24,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(outboxTransfersProvider),
            color: kPrimaryColor,
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
  static const Color kPrimaryColor = Color(0xFF8655F6);
  static const Color kCardColor = Color(0xFF151022);

  bool _isProcessing = false;

  Future<void> _handleCancel() async {
    setState(() => _isProcessing = true);

    await ref
        .read(marketplaceProvider.notifier)
        .cancelTransfer(transferId: widget.transfer['id']);

    final state = ref.read(marketplaceProvider);
    if (!mounted) return;

    if (state.hasError) {
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to cancel transfer request'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Transfer request cancelled.'),
        backgroundColor: Colors.blueGrey,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          color: kCardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _statusColor(status).withValues(alpha: 0.3),
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
                      color: Colors.white,
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
                color: Colors.white60,
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
              const LinearProgressIndicator(color: kPrimaryColor),
            ] else if (transfer['can_cancel'] == true) ...[
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  onPressed: _handleCancel,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white24),
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

  Color _statusColor(String status) {
    switch (status) {
      case 'accepted':
        return Colors.greenAccent;
      case 'rejected':
        return Colors.orangeAccent;
      case 'cancelled':
        return Colors.blueGrey;
      default:
        return kPrimaryColor;
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
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.white38),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: GoogleFonts.manrope(
            color: Colors.white38,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.manrope(
              color: Colors.white70,
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
    final color = switch (status) {
      'accepted' => Colors.greenAccent,
      'rejected' => Colors.orangeAccent,
      'cancelled' => Colors.blueGrey,
      _ => const Color(0xFF8655F6),
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
