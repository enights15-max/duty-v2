import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/providers/profile_state_provider.dart';
import '../../../../core/theme/colors.dart';
import '../../../profile/domain/models/profile_model.dart';
import '../../../profile/presentation/providers/marketplace_provider.dart';
import '../../../profile/presentation/providers/review_prompt_provider.dart';
import '../../../wallet/presentation/providers/wallet_provider.dart';
import '../../data/models/professional_dashboard_model.dart';
import '../providers/professional_event_provider.dart';

class ProfessionalStatsPage extends ConsumerStatefulWidget {
  const ProfessionalStatsPage({super.key});

  @override
  ConsumerState<ProfessionalStatsPage> createState() =>
      _ProfessionalStatsPageState();
}

class _ProfessionalStatsPageState extends ConsumerState<ProfessionalStatsPage> {
  String _selectedRange = '30d';

  @override
  Widget build(BuildContext context) {
    final palette = context.dutyTheme;
    final profile = ref.watch(activeProfileProvider);
    final dashboardAsync = ref.watch(
      professionalDashboardRangeProvider(_selectedRange),
    );
    final walletAsync = ref.watch(walletProvider);
    final transferInboxCount = ref.watch(pendingTransfersCountProvider);
    final pendingReviewCount = ref.watch(pendingReviewTargetsCountProvider);

    if (profile == null) {
      return const Scaffold(
        body: Center(child: Text('No professional profile active')),
      );
    }

    final accent = _profileColor(profile.type);

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        backgroundColor: palette.background,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: Text(
          'Estadísticas',
          style: GoogleFonts.outfit(
            color: palette.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: dashboardAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'No pudimos cargar las estadísticas ahora mismo.',
              textAlign: TextAlign.center,
              style: GoogleFonts.splineSans(color: palette.textSecondary),
            ),
          ),
        ),
        data: (dashboard) {
          final balance = walletAsync.maybeWhen(
            data: (wallet) => double.tryParse('${wallet['balance'] ?? 0}') ?? 0,
            orElse: () => dashboard.balance,
          );
          final upcomingThisWeek = _upcomingThisWeekCount(dashboard);
          final ticketsPerEvent = dashboard.eventCount == 0
              ? 0.0
              : dashboard.ticketSales / dashboard.eventCount;
          final actionLoad = transferInboxCount + pendingReviewCount;

          return ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
            children: [
              _buildRangeSelector(),
              const SizedBox(height: 16),
              _buildHero(
                profile: profile,
                accent: accent,
                balance: balance,
                dashboard: dashboard,
                actionLoad: actionLoad,
              ),
              const SizedBox(height: 20),
              _buildMetricGrid(
                accent: accent,
                dashboard: dashboard,
                upcomingThisWeek: upcomingThisWeek,
                ticketsPerEvent: ticketsPerEvent,
              ),
              const SizedBox(height: 20),
              _buildTrendStrip(accent: accent, dashboard: dashboard),
              const SizedBox(height: 20),
              _buildSignalsPanel(
                accent: accent,
                dashboard: dashboard,
                transferInboxCount: transferInboxCount,
                pendingReviewCount: pendingReviewCount,
                upcomingThisWeek: upcomingThisWeek,
              ),
              const SizedBox(height: 20),
              _buildBreakdownPanel(
                accent: accent,
                dashboard: dashboard,
                ticketsPerEvent: ticketsPerEvent,
                actionLoad: actionLoad,
              ),
              const SizedBox(height: 20),
              _buildActionsRow(context, accent),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRangeSelector() {
    final palette = context.dutyTheme;
    final options = const [
      ('7d', '7 días'),
      ('30d', '30 días'),
      ('all', 'Todo'),
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: options.map((option) {
        final isSelected = _selectedRange == option.$1;
        return GestureDetector(
          onTap: () => setState(() => _selectedRange = option.$1),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? palette.primary.withValues(alpha: 0.18)
                  : palette.surfaceAlt,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: isSelected ? palette.primary : palette.border,
              ),
            ),
            child: Text(
              option.$2,
              style: GoogleFonts.splineSans(
                color: palette.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildHero({
    required AppProfile profile,
    required Color accent,
    required double balance,
    required ProfessionalDashboardModel dashboard,
    required int actionLoad,
  }) {
    final palette = context.dutyTheme;
    final label = switch (profile.type) {
      ProfileType.artist => 'Artist performance',
      ProfileType.venue => 'Venue operations',
      ProfileType.organizer => 'Organizer performance',
      _ => 'Professional performance',
    };

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accent.withValues(alpha: 0.28),
            palette.surface,
            palette.shadow.withValues(alpha: 0.40),
          ],
        ),
        border: Border.all(color: accent.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.16),
            blurRadius: 30,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: GoogleFonts.splineSans(
              color: palette.textMuted,
              fontSize: 11,
              letterSpacing: 1.8,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '\$${balance.toStringAsFixed(2)}',
            style: GoogleFonts.outfit(
              color: palette.textPrimary,
              fontSize: 34,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Balance disponible con ${dashboard.ticketSales} tickets vendidos y ${dashboard.reviewCount} reviews publicadas.',
            style: GoogleFonts.splineSans(
              color: palette.textSecondary,
              fontSize: 14,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _heroChip(
                accent: accent,
                icon: Icons.event_available_rounded,
                label: '${dashboard.eventCount} activos',
              ),
              const SizedBox(width: 10),
              _heroChip(
                accent: accent,
                icon: Icons.bolt_rounded,
                label: '$actionLoad en cola',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroChip({
    required Color accent,
    required IconData icon,
    required String label,
  }) {
    final palette = context.dutyTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: palette.surfaceAlt,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: palette.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: accent),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.splineSans(
              color: palette.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricGrid({
    required Color accent,
    required ProfessionalDashboardModel dashboard,
    required int upcomingThisWeek,
    required double ticketsPerEvent,
  }) {
    final palette = context.dutyTheme;
    final items = [
      _StatBoxData(
        label: 'Eventos',
        value: '${dashboard.eventCount}',
        tone: accent,
      ),
      _StatBoxData(
        label: 'Tickets',
        value: '${dashboard.ticketSales}',
        tone: palette.warning,
      ),
      _StatBoxData(
        label: 'Gross',
        value: '\$${dashboard.grossSales.toStringAsFixed(0)}',
        tone: palette.success,
      ),
      _StatBoxData(
        label: 'Net',
        value: '\$${dashboard.netSales.toStringAsFixed(0)}',
        tone: accent,
      ),
      _StatBoxData(
        label: 'Rating',
        value: dashboard.averageRating.toStringAsFixed(1),
        tone: kWarmGold,
      ),
      _StatBoxData(
        label: 'Próximos 7 días',
        value: '$upcomingThisWeek',
        tone: palette.info,
      ),
      _StatBoxData(
        label: 'Ledger in',
        value: '\$${dashboard.ledgerInflow.toStringAsFixed(0)}',
        tone: palette.success,
      ),
      _StatBoxData(
        label: 'Ledger out',
        value: '\$${dashboard.ledgerOutflow.toStringAsFixed(0)}',
        tone: palette.danger,
      ),
      _StatBoxData(
        label: 'Reviews',
        value: '${dashboard.reviewCount}',
        tone: kDustRose,
      ),
      _StatBoxData(
        label: 'Tickets / evento',
        value: ticketsPerEvent.toStringAsFixed(1),
        tone: palette.info,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 1.35,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: palette.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: palette.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: item.tone,
                  shape: BoxShape.circle,
                ),
              ),
              const Spacer(),
              Text(
                item.value,
                style: GoogleFonts.outfit(
                  color: palette.textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                item.label,
                style: GoogleFonts.splineSans(
                  color: palette.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTrendStrip({
    required Color accent,
    required ProfessionalDashboardModel dashboard,
  }) {
    final items = [
      _trendItem(
        label: 'Tickets',
        comparison: dashboard.comparisons['ticket_sales'],
        accent: context.dutyTheme.warning,
      ),
      _trendItem(
        label: 'Gross',
        comparison: dashboard.comparisons['gross_sales'],
        accent: context.dutyTheme.success,
        currency: true,
      ),
      _trendItem(
        label: 'Net',
        comparison: dashboard.comparisons['net_sales'],
        accent: accent,
        currency: true,
      ),
    ].whereType<Widget>().toList();

    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return _SectionShell(
      title: 'Comparativa',
      child: Column(children: items),
    );
  }

  Widget? _trendItem({
    required String label,
    required ProfessionalMetricComparison? comparison,
    required Color accent,
    bool currency = false,
  }) {
    final palette = context.dutyTheme;
    if (comparison == null) {
      return null;
    }

    final delta = comparison.delta;
    final percent = comparison.deltaPercent;
    final hasDelta = delta != null;
    final isPositive = (delta ?? 0) >= 0;
    final deltaColor = hasDelta
        ? (isPositive ? palette.success : palette.danger)
        : palette.textMuted;

    final deltaText = !hasDelta
        ? 'Sin comparación previa'
        : percent == null
        ? '${isPositive ? '+' : ''}${_formatValue(delta, currency)}'
        : '${isPositive ? '+' : ''}${percent.toStringAsFixed(1)}%';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.splineSans(
                    color: palette.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Actual ${_formatValue(comparison.current, currency)}'
                  '${comparison.previous != null ? ' · Antes ${_formatValue(comparison.previous!, currency)}' : ''}',
                  style: GoogleFonts.splineSans(
                    color: palette.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: deltaColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: deltaColor.withValues(alpha: 0.3)),
            ),
            child: Text(
              deltaText,
              style: GoogleFonts.splineSans(
                color: deltaColor,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignalsPanel({
    required Color accent,
    required ProfessionalDashboardModel dashboard,
    required int transferInboxCount,
    required int pendingReviewCount,
    required int upcomingThisWeek,
  }) {
    final ratingScore = (dashboard.averageRating / 5).clamp(0, 1).toDouble();
    final actionScore = (1 - ((transferInboxCount + pendingReviewCount) / 12))
        .clamp(0, 1)
        .toDouble();
    final scheduleScore = dashboard.eventCount == 0
        ? 0.0
        : (upcomingThisWeek / math.max(dashboard.eventCount, 1))
              .clamp(0, 1)
              .toDouble();

    return _SectionShell(
      title: 'Señales clave',
      child: Column(
        children: [
          _signalRow(
            label: 'Reputación',
            value: '${dashboard.averageRating.toStringAsFixed(1)} / 5',
            progress: ratingScore,
            color: kWarmGold,
          ),
          const SizedBox(height: 14),
          _signalRow(
            label: 'Carga operativa',
            value:
                '${transferInboxCount + pendingReviewCount} acciones abiertas',
            progress: actionScore,
            color: accent,
          ),
          const SizedBox(height: 14),
          _signalRow(
            label: 'Agenda inmediata',
            value: '$upcomingThisWeek eventos en 7 días',
            progress: scheduleScore,
            color: context.dutyTheme.info,
          ),
        ],
      ),
    );
  }

  Widget _signalRow({
    required String label,
    required String value,
    required double progress,
    required Color color,
  }) {
    final palette = context.dutyTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: GoogleFonts.splineSans(
                color: palette.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
            const Spacer(),
            Text(
              value,
              style: GoogleFonts.splineSans(
                color: palette.textMuted,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            backgroundColor: palette.surfaceMuted,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildBreakdownPanel({
    required Color accent,
    required ProfessionalDashboardModel dashboard,
    required double ticketsPerEvent,
    required int actionLoad,
  }) {
    final notes = <String>[
      if (_selectedRange != 'all')
        'Filtro activo: ${_selectedRange == '7d' ? 'últimos 7 días' : 'últimos 30 días'}.',
      if (ticketsPerEvent > 0)
        'Promedio actual: ${ticketsPerEvent.toStringAsFixed(1)} tickets por evento.',
      if (actionLoad > 0)
        'Hay $actionLoad acciones abiertas en transferencias o reviews.'
      else
        'No hay fricción operativa abierta ahora mismo.',
      if (dashboard.ledgerEntries > 0)
        'El ledger registró ${dashboard.ledgerEntries} movimientos en este rango.'
      else
        'Todavía no hay movimientos de ledger en este rango.',
      if (dashboard.averageRating >= 4.5)
        'Tu reputación está en una zona muy fuerte para conversiones.'
      else if (dashboard.reviewCount == 0)
        'Todavía no tienes reviews publicadas. Conviene empujar feedback post-evento.'
      else
        'Hay espacio para subir reputación con mejor cierre post-evento.',
    ];

    return _SectionShell(
      title: 'Lectura rápida',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: notes
            .map(
              (note) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: accent,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        note,
                        style: GoogleFonts.splineSans(
                          color: context.dutyTheme.textSecondary,
                          fontSize: 13,
                          height: 1.45,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildActionsRow(BuildContext context, Color accent) {
    final palette = context.dutyTheme;
    return Row(
      children: [
        Expanded(
          child: FilledButton.tonalIcon(
            onPressed: () => context.push('/professional/events'),
            icon: const Icon(Icons.event_note_rounded),
            label: const Text('Gestionar eventos'),
            style: FilledButton.styleFrom(
              backgroundColor: accent.withValues(alpha: 0.18),
              foregroundColor: palette.textPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => context.push('/pending-transfers'),
            icon: const Icon(Icons.compare_arrows_rounded),
            label: const Text('Transfer Inbox'),
            style: OutlinedButton.styleFrom(
              foregroundColor: palette.textPrimary,
              side: BorderSide(color: palette.borderStrong),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
        ),
      ],
    );
  }

  int _upcomingThisWeekCount(ProfessionalDashboardModel dashboard) {
    final now = DateTime.now();
    final limit = now.add(const Duration(days: 7));
    return dashboard.upcomingEvents.where((event) {
      final rawDate = event.startDate;
      if (rawDate == null || rawDate.isEmpty) {
        return false;
      }

      final eventDate = DateTime.tryParse(rawDate);
      if (eventDate == null) {
        return false;
      }

      return !eventDate.isBefore(now.subtract(const Duration(days: 1))) &&
          !eventDate.isAfter(limit);
    }).length;
  }

  String _formatValue(double value, bool currency) {
    if (currency) {
      return '\$${value.toStringAsFixed(2)}';
    }

    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }

    return value.toStringAsFixed(1);
  }

  Color _profileColor(ProfileType type) {
    switch (type) {
      case ProfileType.artist:
        return kDustRose;
      case ProfileType.venue:
        return kInfoColor;
      case ProfileType.organizer:
        return kPrimaryColor;
      default:
        return kPrimaryColor;
    }
  }
}

class _SectionShell extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionShell({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final palette = context.dutyTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(24),
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
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _StatBoxData {
  final String label;
  final String value;
  final Color tone;

  const _StatBoxData({
    required this.label,
    required this.value,
    required this.tone,
  });
}
