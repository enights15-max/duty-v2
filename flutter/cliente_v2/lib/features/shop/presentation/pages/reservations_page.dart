import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/colors.dart';

import '../../data/models/reservation_model.dart';
import '../providers/reservation_provider.dart';

class ReservationsPage extends ConsumerWidget {
  const ReservationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.dutyTheme;
    final reservationsAsync = ref.watch(reservationsProvider);

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Reservas y abonos',
          style: GoogleFonts.splineSans(
            color: palette.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(reservationsProvider);
          await ref.read(reservationsProvider.future);
        },
        child: reservationsAsync.when(
          data: (reservations) {
            if (reservations.isEmpty) {
              return ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  const SizedBox(height: 80),
                  Icon(
                    Icons.event_available_outlined,
                    size: 48,
                    color: palette.textMuted.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Todavia no tienes reservas activas.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.splineSans(
                      color: palette.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Cuando apartes cupos en preventa apareceran aqui con su saldo pendiente y fecha limite.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.splineSans(
                      color: palette.textMuted,
                      height: 1.5,
                    ),
                  ),
                ],
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              itemCount: reservations.length,
              itemBuilder: (context, index) {
                final reservation = reservations[index];
                return _ReservationCard(reservation: reservation);
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const SizedBox(height: 80),
              Text(
                'No se pudieron cargar tus reservas.',
                textAlign: TextAlign.center,
                style: GoogleFonts.splineSans(
                  color: palette.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$error',
                textAlign: TextAlign.center,
                style: GoogleFonts.splineSans(color: palette.textMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReservationCard extends StatelessWidget {
  final ReservationModel reservation;

  const _ReservationCard({required this.reservation});

  @override
  Widget build(BuildContext context) {
    final palette = context.dutyTheme;
    final accent = reservation.isCompleted ? palette.success : palette.primary;

    return GestureDetector(
      onTap: () => context.push('/reservations/${reservation.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: palette.surfaceAlt,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: palette.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    reservation.ticketTitle ?? reservation.reservationCode,
                    style: GoogleFonts.splineSans(
                      color: palette.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    reservation.isCompleted ? 'COMPLETADA' : 'ACTIVA',
                    style: GoogleFonts.splineSans(
                      color: accent,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              reservation.reservationCode,
              style: GoogleFonts.splineSans(color: palette.textMuted),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _MetricColumn(
                    label: 'Pagado',
                    value: 'DOP ${reservation.amountPaid.toStringAsFixed(2)}',
                  ),
                ),
                Expanded(
                  child: _MetricColumn(
                    label: 'Pendiente',
                    value:
                        'DOP ${reservation.remainingBalance.toStringAsFixed(2)}',
                  ),
                ),
                Expanded(
                  child: _MetricColumn(
                    label: 'Vence',
                    value: _formatDate(
                      reservation.finalDueDate ?? reservation.expiresAt,
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

  static String _formatDate(DateTime? value) {
    if (value == null) return 'N/D';
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '$day/$month/${value.year}';
  }
}

class _MetricColumn extends StatelessWidget {
  final String label;
  final String value;

  const _MetricColumn({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final palette = context.dutyTheme;
    return Column(
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
        const SizedBox(height: 6),
        Text(
          value,
          style: GoogleFonts.splineSans(
            color: palette.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
