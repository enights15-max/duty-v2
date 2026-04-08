import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../events/data/models/event_detail_model.dart';
import '../providers/reservation_provider.dart';

class ReservationCreatePage extends ConsumerStatefulWidget {
  final EventDetailModel event;

  const ReservationCreatePage({super.key, required this.event});

  @override
  ConsumerState<ReservationCreatePage> createState() =>
      _ReservationCreatePageState();
}

class _ReservationCreatePageState extends ConsumerState<ReservationCreatePage> {
  static const _bg = kBackgroundDark;
  static const _accent = kPrimaryColor;
  static const _accentSoft = kWarningColor;

  late final TextEditingController _amountController;
  int? _selectedTicketId;
  int _quantity = 1;
  Timer? _previewDebounce;
  Map<String, dynamic>? _paymentPreview;
  int _previewRequestKey = 0;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(reservationFlowProvider.notifier).bootstrap();
      final eligible = _eligibleTickets;
      if (eligible.isNotEmpty) {
        setState(() {
          _selectedTicketId = eligible.first.id;
        });
        _resetAmountToDeposit();
        _schedulePreview();
      }
    });
  }

  @override
  void dispose() {
    _previewDebounce?.cancel();
    _amountController.dispose();
    super.dispose();
  }

  List<TicketModel> get _eligibleTickets => widget.event.tickets
      .where(
        (ticket) =>
            ticket.available &&
            ticket.pricingType == 'normal' &&
            ticket.reservationEnabled,
      )
      .toList();

  TicketModel? get _selectedTicket {
    if (_selectedTicketId == null) {
      return _eligibleTickets.isEmpty ? null : _eligibleTickets.first;
    }
    for (final ticket in _eligibleTickets) {
      if (ticket.id == _selectedTicketId) {
        return ticket;
      }
    }
    return _eligibleTickets.isEmpty ? null : _eligibleTickets.first;
  }

  double _estimatedTotal(TicketModel ticket) => ticket.price * _quantity;

  double _requiredDeposit(TicketModel ticket) {
    final total = _estimatedTotal(ticket);
    final rawValue = ticket.reservationDepositValue ?? 0;
    if (ticket.reservationDepositType == 'percentage') {
      return ((total * rawValue) / 100).clamp(0, total);
    }
    return rawValue.clamp(0, total);
  }

  void _resetAmountToDeposit() {
    final ticket = _selectedTicket;
    if (ticket == null) {
      _amountController.text = '';
      return;
    }
    _amountController.text = _requiredDeposit(ticket).toStringAsFixed(2);
  }

  void _schedulePreview() {
    _previewDebounce?.cancel();
    _previewDebounce = Timer(
      const Duration(milliseconds: 250),
      _refreshPreview,
    );
  }

  Future<void> _refreshPreview() async {
    final ticket = _selectedTicket;
    if (ticket == null) {
      if (mounted) {
        setState(() => _paymentPreview = null);
      }
      return;
    }

    final requestKey = ++_previewRequestKey;
    final preview = await ref
        .read(reservationFlowProvider.notifier)
        .previewReservation(
          ticketId: ticket.id,
          quantity: _quantity,
          paymentAmount: _enteredAmount(ticket),
          eventDate: widget.event.date,
        );

    if (!mounted || requestKey != _previewRequestKey) {
      return;
    }

    setState(() {
      _paymentPreview = preview;
    });
  }

  double _enteredAmount(TicketModel ticket) {
    final value = double.tryParse(_amountController.text.trim()) ?? 0;
    final min = _requiredDeposit(ticket);
    final max = _estimatedTotal(ticket);
    if (value < min) return min;
    if (value > max) return max;
    return value;
  }

  Future<void> _submitReservation() async {
    final ticket = _selectedTicket;
    if (ticket == null) {
      return;
    }

    final amount = _enteredAmount(ticket);
    final currentUser = ref.read(currentUserProvider);

    try {
      final reservation = await ref
          .read(reservationFlowProvider.notifier)
          .createReservation(
            ticketId: ticket.id,
            quantity: _quantity,
            paymentAmount: amount,
            eventDate: widget.event.date,
            currentUser: currentUser,
          );

      ref.invalidate(reservationsProvider);
      ref.invalidate(reservationDetailsProvider(reservation.id));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            reservation.isCompleted
                ? 'Reserva completada y convertida en ticket.'
                : 'Reserva creada correctamente.',
          ),
        ),
      );
      context.go('/reservations/${reservation.id}');
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.dutyTheme;
    final flowState = ref.watch(reservationFlowProvider);
    final ticket = _selectedTicket;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Reserva y abonos',
          style: GoogleFonts.splineSans(
            fontWeight: FontWeight.w700,
            color: palette.textPrimary,
          ),
        ),
      ),
      body: _eligibleTickets.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Este evento aun no tiene tickets elegibles para reservas.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.splineSans(
                    color: palette.textSecondary,
                    fontSize: 16,
                  ),
                ),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HeroCard(event: widget.event),
                  const SizedBox(height: 16),
                  _SectionShell(
                    title: 'Ticket elegible',
                    subtitle: 'Selecciona el ticket que quieres apartar.',
                    child: Column(
                      children: _eligibleTickets.map((item) {
                        final selected = item.id == ticket?.id;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: selected
                                ? _accent.withValues(alpha: 0.12)
                                : palette.surface.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: selected ? _accentSoft : palette.border,
                            ),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(18),
                            onTap: () {
                              setState(() {
                                _selectedTicketId = item.id;
                                _quantity = 1;
                              });
                              _resetAmountToDeposit();
                              _schedulePreview();
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Icon(
                                    selected
                                        ? Icons.radio_button_checked
                                        : Icons.radio_button_off,
                                    color: selected
                                        ? _accent
                                        : palette.textMuted,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.title,
                                          style: GoogleFonts.splineSans(
                                            color: palette.textPrimary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Precio DOP ${item.price.toStringAsFixed(2)} • Deposito ${_formatDepositLabel(item)}',
                                          style: GoogleFonts.splineSans(
                                            color: palette.textSecondary,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  if (ticket != null) ...[
                    const SizedBox(height: 16),
                    _SectionShell(
                      title: 'Cantidad y deposito',
                      subtitle:
                          'Tu reserva retiene cupo ahora y te deja completar el resto mas adelante.',
                      child: Column(
                        children: [
                          Row(
                            children: [
                              _MetricPill(
                                label: 'Cantidad',
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _MiniCounterButton(
                                      icon: Icons.remove,
                                      onTap: _quantity > 1
                                          ? () {
                                              setState(() => _quantity -= 1);
                                              _resetAmountToDeposit();
                                              _schedulePreview();
                                            }
                                          : null,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                      ),
                                      child: Text(
                                        '$_quantity',
                                        style: GoogleFonts.splineSans(
                                          color: palette.textPrimary,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    _MiniCounterButton(
                                      icon: Icons.add,
                                      onTap: () {
                                        setState(() => _quantity += 1);
                                        _resetAmountToDeposit();
                                        _schedulePreview();
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _MetricPill(
                                  label: 'Saldo total',
                                  child: Text(
                                    'DOP ${_estimatedTotal(ticket).toStringAsFixed(2)}',
                                    style: GoogleFonts.splineSans(
                                      color: palette.textPrimary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _amountController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            style: GoogleFonts.splineSans(
                              color: palette.textPrimary,
                            ),
                            decoration: _inputDecoration(
                              label: 'Pago inicial',
                              hint:
                                  'Minimo DOP ${_requiredDeposit(ticket).toStringAsFixed(2)}',
                            ),
                            onChanged: (_) {
                              setState(() {});
                              _schedulePreview();
                            },
                          ),
                          const SizedBox(height: 12),
                          _SummaryStrip(
                            label: 'Minimo requerido',
                            value:
                                'DOP ${_requiredDeposit(ticket).toStringAsFixed(2)}',
                          ),
                          if (ticket.reservationFinalDueDate != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: _SummaryStrip(
                                label: 'Fecha limite',
                                value: _formatDate(
                                  ticket.reservationFinalDueDate,
                                ),
                              ),
                            ),
                          if (ticket.nextPrice != null &&
                              ticket.nextPriceEffectiveFrom != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: _SummaryStrip(
                                label: 'Proximo aumento',
                                value:
                                    'DOP ${ticket.nextPrice!.toStringAsFixed(2)} el ${_formatDate(ticket.nextPriceEffectiveFrom)}',
                              ),
                            ),
                          if (ticket.reservationMinimumInstallmentAmount !=
                              null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: _SummaryStrip(
                                label: 'Abono minimo futuro',
                                value:
                                    'DOP ${ticket.reservationMinimumInstallmentAmount!.toStringAsFixed(2)}',
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _FundingSection(
                      amount: _enteredAmount(ticket),
                      state: flowState,
                      paymentSummary: _paymentPreview?['payment_summary'] is Map
                          ? Map<String, dynamic>.from(
                              _paymentPreview!['payment_summary'] as Map,
                            )
                          : null,
                      breakdown: ref
                          .read(reservationFlowProvider.notifier)
                          .calculateBreakdown(_enteredAmount(ticket)),
                      onToggleWallet: (value) => ref
                          .read(reservationFlowProvider.notifier)
                          .toggleWalletBalance(value),
                      onToggleBonus: (value) => ref
                          .read(reservationFlowProvider.notifier)
                          .toggleBonusBalance(value),
                      onSelectCard: (value) {
                        if (value != null) {
                          ref
                              .read(reservationFlowProvider.notifier)
                              .selectCard(value);
                          _schedulePreview();
                        }
                      },
                      onToggleWalletChanged: _schedulePreview,
                      onToggleBonusChanged: _schedulePreview,
                      onAddCard: () async {
                        await ref
                            .read(reservationFlowProvider.notifier)
                            .addNewCard(context);
                        _schedulePreview();
                      },
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: flowState.isLoading
                            ? null
                            : _submitReservation,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _accent,
                          foregroundColor: palette.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
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
                                'Crear reserva',
                                style: GoogleFonts.splineSans(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  String _formatDepositLabel(TicketModel ticket) {
    final value = ticket.reservationDepositValue ?? 0;
    if (ticket.reservationDepositType == 'percentage') {
      return '${value.toStringAsFixed(0)}%';
    }
    return 'DOP ${value.toStringAsFixed(2)}';
  }

  static String _formatDate(DateTime? value) {
    if (value == null) return 'No definida';
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '$day/$month/${value.year}';
  }

  InputDecoration _inputDecoration({required String label, String? hint}) {
    final palette = context.dutyTheme;
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: GoogleFonts.splineSans(color: palette.textSecondary),
      hintStyle: GoogleFonts.splineSans(color: palette.textMuted),
      filled: true,
      fillColor: palette.surface.withValues(alpha: 0.72),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: palette.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: palette.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: _accentSoft),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  final EventDetailModel event;

  const _HeroCard({required this.event});

  @override
  Widget build(BuildContext context) {
    final palette = context.dutyTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [palette.primary.withValues(alpha: 0.24), palette.surfaceAlt],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Preventa flexible',
            style: GoogleFonts.splineSans(
              color: palette.warning,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            event.title,
            style: GoogleFonts.splineSans(
              color: palette.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Aparta tu cupo hoy y completa el pago mas adelante usando bono, wallet, tarjeta o combinando las tres.',
            style: GoogleFonts.splineSans(
              color: palette.textMuted,
              fontSize: 13,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionShell extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _SectionShell({
    required this.title,
    required this.subtitle,
    required this.child,
  });

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
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.splineSans(
              color: palette.textMuted,
              fontSize: 12,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _MetricPill extends StatelessWidget {
  final String label;
  final Widget child;

  const _MetricPill({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    final palette = context.dutyTheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: palette.surface.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.splineSans(
              color: palette.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _MiniCounterButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _MiniCounterButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    final palette = context.dutyTheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Ink(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: onTap == null
              ? palette.surface.withValues(alpha: 0.6)
              : palette.primary.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: onTap == null ? palette.textMuted : palette.textPrimary,
          size: 18,
        ),
      ),
    );
  }
}

class _SummaryStrip extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryStrip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final palette = context.dutyTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: palette.surface.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.splineSans(
              color: palette.textSecondary,
              fontSize: 12,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.splineSans(
              color: palette.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _FundingSection extends StatelessWidget {
  final double amount;
  final ReservationFlowState state;
  final Map<String, dynamic>? paymentSummary;
  final ReservationFundingBreakdown breakdown;
  final ValueChanged<bool> onToggleWallet;
  final ValueChanged<bool> onToggleBonus;
  final VoidCallback onToggleWalletChanged;
  final VoidCallback onToggleBonusChanged;
  final ValueChanged<String?> onSelectCard;
  final VoidCallback onAddCard;

  const _FundingSection({
    required this.amount,
    required this.state,
    required this.paymentSummary,
    required this.breakdown,
    required this.onToggleWallet,
    required this.onToggleBonus,
    required this.onToggleWalletChanged,
    required this.onToggleBonusChanged,
    required this.onSelectCard,
    required this.onAddCard,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.dutyTheme;
    return _SectionShell(
      title: 'Como se cubre el pago inicial',
      subtitle:
          'Duty usa primero bono, luego wallet y solo manda a tarjeta el remanente.',
      child: Column(
        children: [
          SwitchListTile.adaptive(
            value: state.applyBonusBalance,
            title: Text(
              'Usar bono interno',
              style: GoogleFonts.splineSans(color: palette.textPrimary),
            ),
            subtitle: Text(
              'Disponible: DOP ${state.bonusBalance.toStringAsFixed(2)}',
              style: GoogleFonts.splineSans(color: palette.textMuted),
            ),
            onChanged: (value) {
              onToggleBonus(value);
              onToggleBonusChanged();
            },
          ),
          SwitchListTile.adaptive(
            value: state.applyWalletBalance,
            title: Text(
              'Usar wallet',
              style: GoogleFonts.splineSans(color: palette.textPrimary),
            ),
            subtitle: Text(
              'Disponible: DOP ${state.walletBalance.toStringAsFixed(2)}',
              style: GoogleFonts.splineSans(color: palette.textMuted),
            ),
            onChanged: (value) {
              onToggleWallet(value);
              onToggleWalletChanged();
            },
          ),
          if (breakdown.requiresCard) ...[
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              initialValue: state.selectedCardId,
              dropdownColor: palette.surfaceAlt,
              style: GoogleFonts.splineSans(color: palette.textPrimary),
              decoration: InputDecoration(
                labelText: 'Tarjeta para remanente',
                labelStyle: GoogleFonts.splineSans(
                  color: palette.textSecondary,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide(color: palette.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide(color: palette.warning),
                ),
              ),
              items: state.savedCards
                  .map(
                    (card) => DropdownMenuItem<String>(
                      value: card.id,
                      child: Text(
                        '${card.brand.toUpperCase()} •••• ${card.last4}',
                      ),
                    ),
                  )
                  .toList(),
              onChanged: onSelectCard,
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: onAddCard,
                icon: Icon(Icons.add_card_rounded, color: palette.textPrimary),
                label: Text(
                  'Agregar tarjeta',
                  style: GoogleFonts.splineSans(color: palette.textPrimary),
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          _SummaryStrip(
            label: 'Monto evaluado',
            value:
                'DOP ${_summaryAmount(paymentSummary, 'subtotal', amount).toStringAsFixed(2)}',
          ),
          const SizedBox(height: 8),
          _SummaryStrip(
            label: 'Bono aplicado',
            value:
                'DOP ${_summaryAmount(paymentSummary, 'bonus_amount', breakdown.bonusApplied).toStringAsFixed(2)}',
          ),
          const SizedBox(height: 8),
          _SummaryStrip(
            label: 'Wallet aplicado',
            value:
                'DOP ${_summaryAmount(paymentSummary, 'wallet_amount', breakdown.walletApplied).toStringAsFixed(2)}',
          ),
          const SizedBox(height: 8),
          _SummaryStrip(
            label: 'Tarjeta necesaria',
            value:
                'DOP ${_summaryAmount(paymentSummary, 'card_total_charge', breakdown.cardAmount).toStringAsFixed(2)}',
          ),
          if (_summaryAmount(paymentSummary, 'processing_fee', 0) > 0.009) ...[
            const SizedBox(height: 8),
            _SummaryStrip(
              label: 'Processing fee',
              value:
                  'DOP ${_summaryAmount(paymentSummary, 'processing_fee', 0).toStringAsFixed(2)}',
            ),
          ],
          const SizedBox(height: 8),
          _SummaryStrip(
            label: 'Total a cobrar ahora',
            value:
                'DOP ${_summaryAmount(paymentSummary, 'total_to_charge', amount).toStringAsFixed(2)}',
          ),
        ],
      ),
    );
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
