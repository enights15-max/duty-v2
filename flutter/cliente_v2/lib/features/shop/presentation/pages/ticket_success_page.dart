import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/providers/profile_state_provider.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../profile/data/models/booking_model.dart';
import '../../../profile/presentation/providers/profile_provider.dart';

class TicketSuccessPage extends StatelessWidget {
  final String bookingId;
  final String eventTitle;
  // final String eventDate; // Add more details as needed

  const TicketSuccessPage({
    super.key,
    required this.bookingId,
    required this.eventTitle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.dutyTheme;
    final successData = _TicketSuccessData.fromPayload(
      rawBookingInfo,
      fallbackBookingId: bookingId,
      fallbackEventTitle: eventTitle,
    );
    final landingRoute = ref.watch(activeProfileLandingRouteProvider);
    final hasGiftTransfers = successData.giftTickets > 0;
    final canOpenSingleTicket =
        successData.keptTickets == 1 &&
        successData.totalTickets == 1 &&
        successData.bookingModel != null;

    return Scaffold(
      backgroundColor: palette.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 124,
                  height: 124,
                  decoration: BoxDecoration(
                    color: palette.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: palette.primaryGlow.withValues(alpha: 0.18),
                        blurRadius: 36,
                        spreadRadius: 6,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.check_circle_rounded,
                    size: 78,
                    color: palette.primary,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Text(
                hasGiftTransfers
                    ? 'Compra y envíos listos'
                    : 'Compra completada',
                style: GoogleFonts.outfit(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: palette.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 14),
              Text(
                successData.summaryMessage,
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  color: palette.textSecondary,
                  height: 1.55,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              _EventSummaryCard(
                title: successData.eventTitle,
                bookingId: successData.bookingId,
                statusLabel: hasGiftTransfers
                    ? 'Compra confirmada'
                    : 'Pago completado',
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'Compradas',
                      value: successData.totalTickets.toString(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      label: 'Contigo',
                      value: successData.keptTickets.toString(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      label: 'Enviadas',
                      value: successData.giftTickets.toString(),
                      highlight: hasGiftTransfers,
                    ),
                  ),
                ],
              ),
              if (hasGiftTransfers) ...[
                const SizedBox(height: 18),
                _InfoCard(
                  icon: Icons.send_rounded,
                  title: 'Transferencias pendientes',
                  body:
                      'Los tickets enviados salen desde tu compra, pero cada persona debe aceptar la transferencia para recibir formalmente su boleta.',
                ),
              ],
              if (successData.recipients.isNotEmpty) ...[
                const SizedBox(height: 18),
                _SectionCard(
                  title: 'Boletas enviadas',
                  child: Column(
                    children: successData.recipients
                        .map((recipient) => _RecipientRow(recipient: recipient))
                        .toList(),
                  ),
                ),
              ],
              if (successData.paymentSummary.hasAnyValue) ...[
                const SizedBox(height: 18),
                _SectionCard(
                  title: 'Cómo se cubrió el pago',
                  child: Column(
                    children: [
                      if (successData.paymentSummary.bonusAmount > 0)
                        _DetailRow(
                          label: 'Bono Duty',
                          value: _formatCurrency(
                            successData.paymentSummary.bonusAmount,
                          ),
                        ),
                      if (successData.paymentSummary.walletAmount > 0)
                        _DetailRow(
                          label: 'Duty Wallet',
                          value: _formatCurrency(
                            successData.paymentSummary.walletAmount,
                          ),
                        ),
                      if (successData.paymentSummary.cardAmount > 0)
                        _DetailRow(
                          label: 'Tarjeta',
                          value: _formatCurrency(
                            successData.paymentSummary.cardAmount,
                          ),
                        ),
                      const Divider(color: Colors.white10, height: 24),
                      _DetailRow(
                        label: 'Total',
                        value: _formatCurrency(
                          successData.paymentSummary.total,
                        ),
                        emphasize: true,
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 26),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    ref.invalidate(myBookingsProvider);

                    if (canOpenSingleTicket &&
                        successData.bookingModel != null) {
                      context.go(
                        '/ticket-details/${successData.bookingModel!.bookingId}',
                        extra: successData.bookingModel,
                      );
                      return;
                    }

                    context.go('/my-tickets');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: palette.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    canOpenSingleTicket ? 'Ver mi boleta' : 'Ver mis boletas',
                    style: GoogleFonts.outfit(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: palette.onPrimary,
                    ),
                  ),
                ),
              ),
              if (hasGiftTransfers) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: () => context.push('/transfer-outbox'),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: palette.primary.withValues(alpha: 0.6),
                      ),
                      foregroundColor: palette.textPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: Text(
                      'Ver envíos pendientes',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: palette.textPrimary,
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => context.go(landingRoute),
                child: Text(
                  'Ir al inicio',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: palette.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _formatCurrency(double amount) {
    return 'RD\$${amount.toStringAsFixed(2)}';
  }
}

class _TicketSuccessData {
  final String bookingId;
  final String eventTitle;
  final int totalTickets;
  final int keptTickets;
  final int giftTickets;
  final List<_RecipientSummary> recipients;
  final _PaymentSummary paymentSummary;
  final BookingModel? bookingModel;

  const _TicketSuccessData({
    required this.bookingId,
    required this.eventTitle,
    required this.totalTickets,
    required this.keptTickets,
    required this.giftTickets,
    required this.recipients,
    required this.paymentSummary,
    required this.bookingModel,
  });

  factory _TicketSuccessData.fromPayload(
    Map<String, dynamic>? payload, {
    required String fallbackBookingId,
    required String fallbackEventTitle,
  }) {
    final safePayload = payload ?? const <String, dynamic>{};
    final bookingPayload = safePayload['booking_info'] is Map<String, dynamic>
        ? Map<String, dynamic>.from(
            safePayload['booking_info'] as Map<String, dynamic>,
          )
        : Map<String, dynamic>.from(safePayload);
    final successSummary =
        safePayload['success_summary'] is Map<String, dynamic>
        ? Map<String, dynamic>.from(
            safePayload['success_summary'] as Map<String, dynamic>,
          )
        : const <String, dynamic>{};
    final paymentSummary =
        safePayload['payment_summary'] is Map<String, dynamic>
        ? _PaymentSummary.fromJson(
            Map<String, dynamic>.from(
              safePayload['payment_summary'] as Map<String, dynamic>,
            ),
          )
        : const _PaymentSummary();

    BookingModel? bookingModel;
    try {
      if (bookingPayload.isNotEmpty) {
        bookingPayload.putIfAbsent('event_title', () => fallbackEventTitle);
        bookingModel = BookingModel.fromJson(bookingPayload);
      }
    } catch (error) {
      appLog('TicketSuccessPage: error parsing booking payload: $error');
    }

    final recipients = <_RecipientSummary>[];
    if (successSummary['gift_recipients'] is List) {
      for (final item in successSummary['gift_recipients'] as List) {
        if (item is Map<String, dynamic>) {
          recipients.add(_RecipientSummary.fromJson(item));
        } else if (item is Map) {
          recipients.add(
            _RecipientSummary.fromJson(Map<String, dynamic>.from(item)),
          );
        }
      }
    }

    final totalTickets = _readInt(
      successSummary['total_tickets'] ?? bookingPayload['quantity'] ?? 1,
      fallback: 1,
    );
    final giftTickets = _readInt(
      successSummary['gift_tickets'] ??
          safePayload['gift_transfers_created'] ??
          0,
    );
    final keptTickets = _readInt(
      successSummary['kept_tickets'] ?? (totalTickets - giftTickets),
      fallback: totalTickets - giftTickets,
    );

    return _TicketSuccessData(
      bookingId: bookingPayload['booking_id']?.toString() ?? fallbackBookingId,
      eventTitle:
          bookingPayload['event_title']?.toString() ?? fallbackEventTitle,
      totalTickets: totalTickets,
      keptTickets: keptTickets < 0 ? 0 : keptTickets,
      giftTickets: giftTickets < 0 ? 0 : giftTickets,
      recipients: recipients,
      paymentSummary: paymentSummary,
      bookingModel: bookingModel,
    );
  }

  String get summaryMessage {
    final purchasedLabel = totalTickets == 1
        ? '1 boleta'
        : '$totalTickets boletas';
    final keptLabel = keptTickets == 1
        ? '1 quedó contigo'
        : '$keptTickets quedaron contigo';

    if (giftTickets <= 0) {
      return 'La compra de $purchasedLabel para "$eventTitle" quedó confirmada. Tu boleta ya está disponible en la app.';
    }

    final sentLabel = giftTickets == 1
        ? '1 se envió como transferencia pendiente'
        : '$giftTickets se enviaron como transferencias pendientes';

    if (recipients.isEmpty) {
      return 'Compraste $purchasedLabel para "$eventTitle". $keptLabel y $sentLabel.';
    }

    final highlightedRecipients = recipients
        .take(2)
        .map((recipient) {
          final username = recipient.username;
          if (username != null && username.isNotEmpty) {
            return '@$username';
          }
          return recipient.name;
        })
        .join(', ');

    final extraRecipients = recipients.length > 2
        ? ' y ${recipients.length - 2} más'
        : '';

    return 'Compraste $purchasedLabel para "$eventTitle". $keptLabel y $sentLabel a $highlightedRecipients$extraRecipients.';
  }

  static int _readInt(dynamic value, {int fallback = 0}) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    if (value is String) {
      return int.tryParse(value.trim()) ?? fallback;
    }
    return fallback;
  }
}

class _PaymentSummary {
  final double bonusAmount;
  final double walletAmount;
  final double cardAmount;
  final double total;

  const _PaymentSummary({
    this.bonusAmount = 0,
    this.walletAmount = 0,
    this.cardAmount = 0,
    this.total = 0,
  });

  bool get hasAnyValue => bonusAmount > 0 || walletAmount > 0 || cardAmount > 0;

  factory _PaymentSummary.fromJson(Map<String, dynamic> json) {
    double read(dynamic value) {
      if (value is num) {
        return value.toDouble();
      }
      if (value is String) {
        return double.tryParse(value.trim()) ?? 0;
      }
      return 0;
    }

    return _PaymentSummary(
      bonusAmount: read(json['bonus_amount']),
      walletAmount: read(json['wallet_amount']),
      cardAmount: read(json['card_amount']),
      total: read(json['total_to_charge']),
    );
  }
}

class _RecipientSummary {
  final String name;
  final String? username;
  final String? photoUrl;
  final int ticketCount;

  const _RecipientSummary({
    required this.name,
    this.username,
    this.photoUrl,
    required this.ticketCount,
  });

  factory _RecipientSummary.fromJson(Map<String, dynamic> json) {
    int readInt(dynamic value) {
      if (value is int) {
        return value;
      }
      if (value is num) {
        return value.toInt();
      }
      if (value is String) {
        return int.tryParse(value.trim()) ?? 0;
      }
      return 0;
    }

    return _RecipientSummary(
      name: json['name']?.toString() ?? 'Usuario Duty',
      username: json['username']?.toString(),
      photoUrl: json['photo_url']?.toString(),
      ticketCount: readInt(json['ticket_count']),
    );
  }
}

class _EventSummaryCard extends StatelessWidget {
  final String title;
  final String bookingId;
  final String statusLabel;

  const _EventSummaryCard({
    required this.title,
    required this.bookingId,
    required this.statusLabel,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.dutyTheme;
    return Container(
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
            title,
            style: GoogleFonts.outfit(
              color: palette.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          Divider(color: palette.border, height: 1),
          const SizedBox(height: 14),
          _DetailRow(label: 'Referencia', value: '#$bookingId'),
          const SizedBox(height: 10),
          _DetailRow(label: 'Estado', value: statusLabel),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final palette = context.dutyTheme;
    return Container(
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
            title,
            style: GoogleFonts.outfit(
              color: palette.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.dutyTheme;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: palette.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: palette.primary.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: palette.primary.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: palette.primaryGlow),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    color: palette.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  body,
                  style: GoogleFonts.outfit(
                    color: palette.textSecondary,
                    fontSize: 14,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const _StatCard({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.dutyTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: highlight
            ? palette.primary.withValues(alpha: 0.12)
            : palette.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: highlight
              ? palette.primary.withValues(alpha: 0.38)
              : palette.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: GoogleFonts.outfit(
              color: palette.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: GoogleFonts.outfit(
              color: palette.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecipientRow extends StatelessWidget {
  final _RecipientSummary recipient;

  const _RecipientRow({required this.recipient});

  @override
  Widget build(BuildContext context) {
    final palette = context.dutyTheme;
    final username = recipient.username;
    final initials = recipient.name.isNotEmpty
        ? recipient.name
              .trim()
              .split(RegExp(r'\s+'))
              .take(2)
              .map((part) => part.isEmpty ? '' : part[0].toUpperCase())
              .join()
        : 'DU';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: palette.surfaceAlt,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          if (recipient.photoUrl != null && recipient.photoUrl!.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: CachedNetworkImage(
                imageUrl: recipient.photoUrl!,
                width: 44,
                height: 44,
                fit: BoxFit.cover,
                errorWidget: (_, _, _) => _InitialsAvatar(initials: initials),
              ),
            )
          else
            _InitialsAvatar(initials: initials),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  recipient.name,
                  style: GoogleFonts.outfit(
                    color: palette.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  username == null || username.isEmpty
                      ? '${recipient.ticketCount} boleta${recipient.ticketCount == 1 ? '' : 's'}'
                      : '@$username · ${recipient.ticketCount} boleta${recipient.ticketCount == 1 ? '' : 's'}',
                  style: GoogleFonts.outfit(
                    color: palette.textSecondary,
                    fontSize: 13,
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
}

class _InitialsAvatar extends StatelessWidget {
  final String initials;

  const _InitialsAvatar({required this.initials});

  @override
  Widget build(BuildContext context) {
    final palette = context.dutyTheme;
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: palette.primary.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(18),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: GoogleFonts.outfit(
          color: palette.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool emphasize;

  const _DetailRow({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.dutyTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: emphasize ? palette.textPrimary : palette.textSecondary,
              fontWeight: emphasize ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 15,
            fontWeight: emphasize ? FontWeight.w800 : FontWeight.w700,
            color: palette.textPrimary,
          ),
        ),
      ],
    );
  }
}
