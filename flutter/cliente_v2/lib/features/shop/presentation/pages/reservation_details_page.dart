import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/colors.dart';
import '../../data/models/reservation_model.dart';
import '../providers/reservation_provider.dart';

class ReservationDetailsPage extends ConsumerStatefulWidget {
  final int reservationId;

  const ReservationDetailsPage({super.key, required this.reservationId});

  @override
  ConsumerState<ReservationDetailsPage> createState() =>
      _ReservationDetailsPageState();
}

class _ReservationDetailsPageState
    extends ConsumerState<ReservationDetailsPage> {
  static const _bg = kBackgroundDark;
  late final TextEditingController _amountController;
  Timer? _previewDebounce;
  Map<String, dynamic>? _paymentPreview;
  int _previewRequestKey = 0;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(reservationFlowProvider.notifier).bootstrap();
    });
  }

  @override
  void dispose() {
    _previewDebounce?.cancel();
    _amountController.dispose();
    super.dispose();
  }

  void _schedulePreview(ReservationModel reservation) {
    _previewDebounce?.cancel();
    _previewDebounce = Timer(
      const Duration(milliseconds: 250),
      () => _refreshPreview(reservation),
    );
  }

  Future<void> _refreshPreview(ReservationModel reservation) async {
    if (!reservation.isActive || reservation.remainingBalance <= 0) {
      if (mounted) {
        setState(() => _paymentPreview = null);
      }
      return;
    }

    final requestKey = ++_previewRequestKey;
    final preview = await ref
        .read(reservationFlowProvider.notifier)
        .previewReservationPayment(
          reservationId: reservation.id,
          paymentAmount: _currentAmount(reservation),
        );

    if (!mounted || requestKey != _previewRequestKey) {
      return;
    }

    setState(() {
      _paymentPreview = preview;
    });
  }

  Future<void> _submitInstallment(ReservationModel reservation) async {
    final palette = context.dutyTheme;
    final amount = _currentAmount(reservation);
    try {
      await ref
          .read(reservationFlowProvider.notifier)
          .payReservation(reservationId: reservation.id, paymentAmount: amount);
      ref.invalidate(reservationsProvider);
      ref.invalidate(reservationDetailsProvider(widget.reservationId));
      await ref.read(reservationDetailsProvider(widget.reservationId).future);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Abono aplicado correctamente.'),
          backgroundColor: palette.success,
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
          backgroundColor: palette.danger,
        ),
      );
    }
  }

  double _currentAmount(ReservationModel reservation) {
    final raw = double.tryParse(_amountController.text.trim()) ?? 0;
    final configuredMinimum = reservation.minimumInstallmentAmount ?? 0.0;
    final clampedMin =
        configuredMinimum > 0 &&
            configuredMinimum < reservation.remainingBalance
        ? configuredMinimum
        : (reservation.remainingBalance > 0
              ? reservation.remainingBalance
              : 0.01);
    if (raw < clampedMin) return clampedMin;
    if (raw > reservation.remainingBalance) return reservation.remainingBalance;
    return raw;
  }

  void _primeAmount(ReservationModel reservation) {
    if (_amountController.text.isNotEmpty || !reservation.isActive) {
      return;
    }
    final configuredMinimum = reservation.minimumInstallmentAmount ?? 0.0;
    final minInstallment =
        configuredMinimum > 0 &&
            configuredMinimum < reservation.remainingBalance
        ? configuredMinimum
        : reservation.remainingBalance;
    _amountController.text = minInstallment.toStringAsFixed(2);
    _schedulePreview(reservation);
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.dutyTheme;
    final reservationAsync = ref.watch(
      reservationDetailsProvider(widget.reservationId),
    );
    final flowState = ref.watch(reservationFlowProvider);

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Detalle de reserva',
          style: GoogleFonts.splineSans(
            color: palette.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: reservationAsync.when(
        data: (reservation) {
          _primeAmount(reservation);
          final amount = reservation.isActive
              ? _currentAmount(reservation)
              : 0.0;
          final breakdown = ref
              .read(reservationFlowProvider.notifier)
              .calculateBreakdown(amount);
          final paymentSummary = _paymentPreview?['payment_summary'] is Map
              ? Map<String, dynamic>.from(
                  _paymentPreview!['payment_summary'] as Map,
                )
              : null;

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HeaderCard(reservation: reservation),
                const SizedBox(height: 16),
                _Panel(
                  title: 'Resumen financiero',
                  child: Column(
                    children: [
                      _DataRow(
                        label: 'Total reserva',
                        value:
                            'DOP ${reservation.totalAmount.toStringAsFixed(2)}',
                      ),
                      _DataRow(
                        label: 'Pagado',
                        value:
                            'DOP ${reservation.amountPaid.toStringAsFixed(2)}',
                      ),
                      _DataRow(
                        label: 'Pendiente',
                        value:
                            'DOP ${reservation.remainingBalance.toStringAsFixed(2)}',
                      ),
                      _DataRow(
                        label: 'Fecha limite',
                        value: _formatDate(
                          reservation.finalDueDate ?? reservation.expiresAt,
                        ),
                      ),
                      if (reservation.bookingOrderNumber != null)
                        _DataRow(
                          label: 'Orden final',
                          value: reservation.bookingOrderNumber!,
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _Panel(
                  title: 'Historial de pagos',
                  child: reservation.payments.isEmpty
                      ? Text(
                          'Aun no hay movimientos registrados.',
                          style: GoogleFonts.splineSans(
                            color: palette.textMuted,
                          ),
                        )
                      : Column(
                          children: reservation.payments.map((payment) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: palette.surface.withValues(alpha: 0.72),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: _sourceColor(
                                        payment.sourceType,
                                      ).withValues(alpha: 0.16),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      _sourceIcon(payment.sourceType),
                                      color: _sourceColor(payment.sourceType),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          payment.sourceType.toUpperCase(),
                                          style: GoogleFonts.splineSans(
                                            color: palette.textPrimary,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        Text(
                                          payment.paidAt != null
                                              ? _formatDateTime(payment.paidAt)
                                              : payment.paymentGroup,
                                          style: GoogleFonts.splineSans(
                                            color: palette.textMuted,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        'DOP ${payment.amount.toStringAsFixed(2)}',
                                        style: GoogleFonts.splineSans(
                                          color: palette.textPrimary,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      if (payment.feeAmount > 0)
                                        Text(
                                          'Fee DOP ${payment.feeAmount.toStringAsFixed(2)}',
                                          style: GoogleFonts.splineSans(
                                            color: palette.textSecondary,
                                            fontSize: 11,
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                ),
                if (reservation.bookings.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _Panel(
                    title: 'Tickets emitidos',
                    child: Column(
                      children: reservation.bookings.map((booking) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: palette.success.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.confirmation_number_rounded,
                                color: palette.success,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      booking.bookingId ?? 'Ticket emitido',
                                      style: GoogleFonts.splineSans(
                                        color: palette.textPrimary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      booking.orderNumber ?? 'Orden compartida',
                                      style: GoogleFonts.splineSans(
                                        color: palette.textMuted,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                'DOP ${(booking.price + booking.tax).toStringAsFixed(2)}',
                                style: GoogleFonts.splineSans(
                                  color: palette.textPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
                if (reservation.isActive &&
                    reservation.remainingBalance > 0) ...[
                  const SizedBox(height: 16),
                  _Panel(
                    title: 'Pagar abono',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: _amountController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          style: GoogleFonts.splineSans(
                            color: palette.textPrimary,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Monto del abono',
                            labelStyle: GoogleFonts.splineSans(
                              color: palette.textSecondary,
                            ),
                            filled: true,
                            fillColor: palette.surface.withValues(alpha: 0.72),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide(color: palette.border),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: BorderSide(color: palette.primary),
                            ),
                          ),
                          onChanged: (_) {
                            setState(() {});
                            _schedulePreview(reservation);
                          },
                        ),
                        const SizedBox(height: 14),
                        _DataRow(
                          label: 'Remanente actual',
                          value:
                              'DOP ${reservation.remainingBalance.toStringAsFixed(2)}',
                        ),
                        const SizedBox(height: 8),
                        _DataRow(
                          label: 'Bono aplicado',
                          value:
                              'DOP ${_summaryAmount(paymentSummary, 'bonus_amount', breakdown.bonusApplied).toStringAsFixed(2)}',
                        ),
                        _DataRow(
                          label: 'Wallet aplicado',
                          value:
                              'DOP ${_summaryAmount(paymentSummary, 'wallet_amount', breakdown.walletApplied).toStringAsFixed(2)}',
                        ),
                        _DataRow(
                          label: 'Tarjeta requerida',
                          value:
                              'DOP ${_summaryAmount(paymentSummary, 'card_total_charge', breakdown.cardAmount).toStringAsFixed(2)}',
                        ),
                        if (_summaryAmount(
                              paymentSummary,
                              'processing_fee',
                              0,
                            ) >
                            0.009)
                          _DataRow(
                            label: 'Processing fee',
                            value:
                                'DOP ${_summaryAmount(paymentSummary, 'processing_fee', 0).toStringAsFixed(2)}',
                          ),
                        _DataRow(
                          label: 'Total a cobrar ahora',
                          value:
                              'DOP ${_summaryAmount(paymentSummary, 'total_to_charge', amount).toStringAsFixed(2)}',
                        ),
                        const SizedBox(height: 10),
                        SwitchListTile.adaptive(
                          value: flowState.applyBonusBalance,
                          title: Text(
                            'Usar bono',
                            style: GoogleFonts.splineSans(
                              color: palette.textPrimary,
                            ),
                          ),
                          subtitle: Text(
                            'Disponible DOP ${flowState.bonusBalance.toStringAsFixed(2)}',
                            style: GoogleFonts.splineSans(
                              color: palette.textMuted,
                            ),
                          ),
                          onChanged: (value) {
                            ref
                                .read(reservationFlowProvider.notifier)
                                .toggleBonusBalance(value);
                            _schedulePreview(reservation);
                          },
                        ),
                        SwitchListTile.adaptive(
                          value: flowState.applyWalletBalance,
                          title: Text(
                            'Usar wallet',
                            style: GoogleFonts.splineSans(
                              color: palette.textPrimary,
                            ),
                          ),
                          subtitle: Text(
                            'Disponible DOP ${flowState.walletBalance.toStringAsFixed(2)}',
                            style: GoogleFonts.splineSans(
                              color: palette.textMuted,
                            ),
                          ),
                          onChanged: (value) {
                            ref
                                .read(reservationFlowProvider.notifier)
                                .toggleWalletBalance(value);
                            _schedulePreview(reservation);
                          },
                        ),
                        if (breakdown.requiresCard) ...[
                          DropdownButtonFormField<String>(
                            initialValue: flowState.selectedCardId,
                            dropdownColor: palette.surfaceAlt,
                            style: GoogleFonts.splineSans(
                              color: palette.textPrimary,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Tarjeta',
                              labelStyle: GoogleFonts.splineSans(
                                color: palette.textSecondary,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: BorderSide(color: palette.border),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: BorderSide(color: palette.primary),
                              ),
                            ),
                            items: flowState.savedCards
                                .map(
                                  (card) => DropdownMenuItem<String>(
                                    value: card.id,
                                    child: Text(
                                      '${card.brand.toUpperCase()} •••• ${card.last4}',
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                ref
                                    .read(reservationFlowProvider.notifier)
                                    .selectCard(value);
                                _schedulePreview(reservation);
                              }
                            },
                          ),
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton.icon(
                              onPressed: () async {
                                await ref
                                    .read(reservationFlowProvider.notifier)
                                    .addNewCard(context);
                                _schedulePreview(reservation);
                              },
                              icon: Icon(
                                Icons.add_card_rounded,
                                color: palette.textPrimary,
                              ),
                              label: Text(
                                'Agregar tarjeta',
                                style: GoogleFonts.splineSans(
                                  color: palette.textPrimary,
                                ),
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: flowState.isLoading
                                ? null
                                : () => _submitInstallment(reservation),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: palette.primary,
                              foregroundColor: palette.onPrimary,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            child: flowState.isLoading
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: palette.onPrimary,
                                    ),
                                  )
                                : Text(
                                    'Aplicar abono',
                                    style: GoogleFonts.splineSans(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'No se pudo cargar la reserva.\n$error',
              textAlign: TextAlign.center,
              style: GoogleFonts.splineSans(color: palette.textMuted),
            ),
          ),
        ),
      ),
    );
  }

  static IconData _sourceIcon(String source) {
    switch (source) {
      case 'wallet':
        return Icons.account_balance_wallet_rounded;
      case 'bonus_wallet':
        return Icons.redeem_rounded;
      case 'card':
        return Icons.credit_card_rounded;
      default:
        return Icons.receipt_long_rounded;
    }
  }

  static Color _sourceColor(String source) {
    switch (source) {
      case 'wallet':
        return kInfoColor;
      case 'bonus_wallet':
        return kWarningColor;
      case 'card':
        return kPrimaryColor;
      default:
        return kTextMuted;
    }
  }

  static String _formatDate(DateTime? value) {
    if (value == null) return 'No definida';
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '$day/$month/${value.year}';
  }

  static String _formatDateTime(DateTime? value) {
    if (value == null) return 'Sin fecha';
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '${_formatDate(value)} $hour:$minute';
  }

  static double _summaryAmount(
    Map<String, dynamic>? summary,
    String key,
    double fallback,
  ) {
    final value = summary?[key];
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value) ?? fallback;
    }
    return fallback;
  }
}

class _HeaderCard extends StatelessWidget {
  final ReservationModel reservation;

  const _HeaderCard({required this.reservation});

  @override
  Widget build(BuildContext context) {
    final palette = context.dutyTheme;
    final accent = reservation.isCompleted ? palette.success : palette.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [accent.withValues(alpha: 0.24), palette.surfaceAlt],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            reservation.isCompleted ? 'Ticket emitido' : 'Reserva activa',
            style: GoogleFonts.splineSans(
              color: accent,
              fontWeight: FontWeight.w700,
              fontSize: 12,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            reservation.ticketTitle ?? reservation.reservationCode,
            style: GoogleFonts.splineSans(
              color: palette.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            reservation.reservationCode,
            style: GoogleFonts.splineSans(color: palette.textMuted),
          ),
        ],
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  final String title;
  final Widget child;

  const _Panel({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final palette = context.dutyTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: palette.surfaceAlt,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.splineSans(
              color: palette.textPrimary,
              fontSize: 18,
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

class _DataRow extends StatelessWidget {
  final String label;
  final String value;

  const _DataRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final palette = context.dutyTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.splineSans(color: palette.textMuted)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: GoogleFonts.splineSans(
                color: palette.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
