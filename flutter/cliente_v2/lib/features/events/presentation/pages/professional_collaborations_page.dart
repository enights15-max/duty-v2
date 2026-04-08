import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/colors.dart';
import '../../data/models/professional_collaboration_summary_model.dart';
import '../providers/professional_event_provider.dart';

enum _CollaborationFilter { all, claimable, pending, claimed }

class ProfessionalCollaborationsPage extends ConsumerStatefulWidget {
  const ProfessionalCollaborationsPage({super.key});

  @override
  ConsumerState<ProfessionalCollaborationsPage> createState() =>
      _ProfessionalCollaborationsPageState();
}

class _ProfessionalCollaborationsPageState
    extends ConsumerState<ProfessionalCollaborationsPage> {
  _CollaborationFilter _filter = _CollaborationFilter.all;
  final Set<int> _claimingIds = <int>{};
  final Set<int> _updatingModeIds = <int>{};

  DutyThemeTokens get _palette => context.dutyTheme;

  Future<void> _refresh() async {
    ref.invalidate(professionalCollaborationsProvider);
    ref.invalidate(professionalDashboardProvider);
    await ref.read(professionalCollaborationsProvider.future);
  }

  Future<void> _claim(ProfessionalCollaborationItem item) async {
    if (!item.canClaimNow || _claimingIds.contains(item.id)) {
      return;
    }

    setState(() => _claimingIds.add(item.id));

    try {
      final payload = await ref
          .read(professionalEventRepositoryProvider)
          .claimCollaboration(item.id);
      final claimedAmount =
          double.tryParse(
            payload['claim']?['claimed_amount']?.toString() ?? '0',
          ) ??
          0;

      ref.invalidate(professionalCollaborationsProvider);
      ref.invalidate(professionalDashboardProvider);
      ref.invalidate(professionalEventInventoryProvider(item.eventId));

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            claimedAmount > 0
                ? 'Colaboración acreditada (${_formatCurrency(claimedAmount)}).'
                : 'Colaboración acreditada a tu wallet.',
          ),
          backgroundColor: _palette.success,
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No pudimos reclamar esta colaboración.\n$error'),
          backgroundColor: _palette.danger,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _claimingIds.remove(item.id));
      }
    }
  }

  Future<void> _updateMode(
    ProfessionalCollaborationItem item, {
    required bool autoRelease,
  }) async {
    if (_updatingModeIds.contains(item.id)) {
      return;
    }

    setState(() => _updatingModeIds.add(item.id));

    try {
      final payload = await ref
          .read(professionalEventRepositoryProvider)
          .updateCollaborationMode(item.id, autoRelease: autoRelease);

      ref.invalidate(professionalCollaborationsProvider);
      ref.invalidate(professionalDashboardProvider);
      ref.invalidate(professionalEventInventoryProvider(item.eventId));

      if (!mounted) {
        return;
      }

      final message = payload['message']?.toString();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message ??
                (autoRelease
                    ? 'La colaboración quedó en auto release.'
                    : 'La colaboración quedó en reclamo manual.'),
          ),
          backgroundColor: _palette.success,
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No pudimos cambiar el modo de esta colaboración.\n$error',
          ),
          backgroundColor: _palette.danger,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _updatingModeIds.remove(item.id));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = _palette;
    final asyncSummary = ref.watch(professionalCollaborationsProvider);

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Colaboraciones',
          style: GoogleFonts.outfit(
            color: palette.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: asyncSummary.when(
        data: (summary) {
          final items = _applyFilter(summary.items);

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              children: [
                _buildHero(summary),
                if (summary.hasRewardsActivity) ...[
                  const SizedBox(height: 18),
                  _buildRewardsPerformance(summary),
                ],
                const SizedBox(height: 18),
                _buildFilterBar(),
                const SizedBox(height: 18),
                if (items.isEmpty)
                  _buildEmptyState()
                else
                  ...items.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildItemCard(item),
                    ),
                  ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'No pudimos cargar tus colaboraciones.\n\n$error',
              textAlign: TextAlign.center,
              style: GoogleFonts.splineSans(
                color: palette.textSecondary,
                height: 1.45,
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<ProfessionalCollaborationItem> _applyFilter(
    List<ProfessionalCollaborationItem> items,
  ) {
    switch (_filter) {
      case _CollaborationFilter.claimable:
        return items.where((item) => item.status == 'claimable').toList();
      case _CollaborationFilter.pending:
        return items
            .where(
              (item) =>
                  item.status == 'pending_event_completion' ||
                  item.status == 'pending_release',
            )
            .toList();
      case _CollaborationFilter.claimed:
        return items.where((item) => item.status == 'claimed').toList();
      case _CollaborationFilter.all:
        return items;
    }
  }

  Widget _buildHero(ProfessionalCollaborationSummary summary) {
    final palette = _palette;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [
            palette.primaryGlow.withValues(alpha: 0.26),
            palette.heroGradientStart,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: palette.primary.withValues(alpha: 0.28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ganancias por colaboraciones',
            style: GoogleFonts.outfit(
              color: palette.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Aquí ves lo que ya está listo para reclamar, lo que sigue retenido por el ciclo del evento y lo que ya se acreditó a tu wallet.',
            style: GoogleFonts.splineSans(
              color: palette.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _heroFact(
                'Reclamable',
                _formatCurrency(summary.claimableAmount),
                palette.success,
              ),
              _heroFact(
                'Pendiente',
                _formatCurrency(summary.pendingAmount),
                palette.warning,
              ),
              _heroFact(
                'Acreditado',
                _formatCurrency(summary.claimedAmount),
                palette.info,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRewardsPerformance(ProfessionalCollaborationSummary summary) {
    final palette = _palette;
    final performance = summary.rewardsPerformance;
    if (performance == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.stars_rounded,
                color: palette.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Actividad de Beneficios',
                style: GoogleFonts.outfit(
                  color: palette.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Rendimiento de los perks y rewards generados por tus promociones.',
            style: GoogleFonts.splineSans(
              color: palette.textSecondary,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _rewardStatCard(
                  'Perks Generados',
                  performance.totalIssued.toString(),
                  palette.primary,
                  Icons.confirmation_number_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _rewardStatCard(
                  'Perks Reclamados',
                  performance.totalClaimed.toString(),
                  palette.success,
                  Icons.check_circle_outline_rounded,
                ),
              ),
            ],
          ),
          if (performance.totalIssued > 0) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: palette.surfaceAlt,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Text(
                    'Conversión:',
                    style: GoogleFonts.splineSans(
                      color: palette.textMuted,
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${((performance.totalClaimed / performance.totalIssued) * 100).toStringAsFixed(1)}%',
                    style: GoogleFonts.outfit(
                      color: palette.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _rewardStatCard(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    final palette = _palette;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.outfit(
              color: palette.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.splineSans(
              color: palette.textSecondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _filterChip('Todas', _CollaborationFilter.all),
        _filterChip('Reclamable', _CollaborationFilter.claimable),
        _filterChip('Pendiente', _CollaborationFilter.pending),
        _filterChip('Reclamado', _CollaborationFilter.claimed),
      ],
    );
  }

  Widget _filterChip(String label, _CollaborationFilter value) {
    final palette = _palette;
    final selected = _filter == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => setState(() => _filter = value),
      labelStyle: GoogleFonts.outfit(
        color: selected ? palette.onPrimary : palette.textSecondary,
        fontWeight: FontWeight.w700,
      ),
      selectedColor: palette.primary,
      backgroundColor: palette.surfaceAlt,
      side: BorderSide(color: selected ? palette.primary : palette.border),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
    );
  }

  Widget _buildEmptyState() {
    final text = switch (_filter) {
      _CollaborationFilter.claimable =>
        'Todavía no tienes colaboraciones listas para reclamar.',
      _CollaborationFilter.pending =>
        'No hay colaboraciones pendientes en este momento.',
      _CollaborationFilter.claimed =>
        'Todavía no has reclamado ganancias por colaboraciones.',
      _ => 'Todavía no tienes colaboraciones registradas.',
    };

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: _palette.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _palette.border),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: GoogleFonts.splineSans(
          color: _palette.textSecondary,
          height: 1.45,
        ),
      ),
    );
  }

  Widget _buildItemCard(ProfessionalCollaborationItem item) {
    final palette = _palette;
    final canClaim = item.canClaimNow;
    final isClaiming = _claimingIds.contains(item.id);
    final isUpdatingMode = _updatingModeIds.contains(item.id);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: (canClaim ? palette.success : palette.borderStrong).withValues(
            alpha: 0.18,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.eventTitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(
                        color: palette.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${item.roleLabel} · ${item.displayName ?? 'Colaborador'}',
                      style: GoogleFonts.splineSans(
                        color: palette.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              _statusPill(
                item.statusLabel,
                canClaim ? palette.success : palette.textSecondary,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _metaFact('Split', '${item.splitValue.toStringAsFixed(2)}%'),
              _metaFact('Reservado', item.amountReservedLabel),
              _metaFact(
                'Reclamable',
                item.claimableAmountLabel ?? 'No disponible',
              ),
              _metaFact('Modo', item.payoutModeLabel),
            ],
          ),
          if (item.latestModeChange != null) ...[
            const SizedBox(height: 10),
            Text(
              _latestModeChangeLabel(item),
              style: GoogleFonts.splineSans(
                color: palette.textMuted,
                fontSize: 11,
                height: 1.4,
              ),
            ),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isUpdatingMode
                      ? null
                      : () => _updateMode(
                          item,
                          autoRelease: !item.isAutoReleaseMode,
                        ),
                  icon: Icon(
                    item.isAutoReleaseMode
                        ? Icons.pause_circle_outline_rounded
                        : Icons.bolt_rounded,
                  ),
                  label: Text(
                    isUpdatingMode
                        ? 'Actualizando...'
                        : item.isAutoReleaseMode
                        ? 'Cambiar a manual'
                        : 'Cambiar a auto release',
                  ),
                ),
              ),
            ],
          ),
          if (item.modeHistory.isNotEmpty) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => _showModeHistory(item),
                icon: const Icon(Icons.history_rounded, size: 16),
                label: Text('Historial (${item.modeHistory.length})'),
              ),
            ),
          ],
          const SizedBox(height: 10),
          Text(
            item.isAutoReleaseMode
                ? 'Si esta colaboración queda reclamable, el sistema la acreditará automáticamente al wallet de este perfil.'
                : 'Esta colaboración quedará visible para reclamo manual cuando el evento salga de retención.',
            style: GoogleFonts.splineSans(
              color: palette.textMuted,
              fontSize: 11,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () =>
                      context.push('/event-details/${item.eventId}'),
                  child: const Text('Ver evento'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  onPressed: canClaim && !isClaiming
                      ? () => _claim(item)
                      : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: palette.success,
                    foregroundColor: palette.onPrimary,
                    disabledBackgroundColor: palette.surfaceMuted,
                    disabledForegroundColor: palette.textMuted,
                  ),
                  child: Text(isClaiming ? 'Reclamando...' : 'Reclamar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroFact(String label, String value, Color color) {
    final palette = _palette;
    return Container(
      constraints: const BoxConstraints(minWidth: 120),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: palette.surfaceAlt.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.splineSans(
              color: palette.textMuted,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.outfit(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _metaFact(String label, String value) {
    final palette = _palette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: palette.surfaceAlt.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.splineSans(
              color: palette.textMuted,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.outfit(
              color: palette.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusPill(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Text(
        label,
        style: GoogleFonts.splineSans(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatCurrency(double value) => 'RD\$${value.toStringAsFixed(2)}';

  String _latestModeChangeLabel(ProfessionalCollaborationItem item) {
    final latest = item.latestModeChange;
    if (latest == null) {
      return '';
    }

    final changedAt = latest.changedAt;
    final dateLabel = changedAt == null
        ? 'sin fecha'
        : DateFormat('dd MMM · h:mm a').format(changedAt);

    return 'Último cambio: ${latest.previousModeLabel} -> ${latest.nextModeLabel} · $dateLabel';
  }

  void _showModeHistory(ProfessionalCollaborationItem item) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: _palette.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Historial de modo',
                  style: GoogleFonts.outfit(
                    color: _palette.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${item.eventTitle} · ${item.displayName ?? item.roleLabel}',
                  style: GoogleFonts.splineSans(
                    color: _palette.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                ...item.modeHistory.map(
                  (history) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: _palette.surfaceAlt,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _palette.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${history.previousModeLabel} -> ${history.nextModeLabel}',
                            style: GoogleFonts.outfit(
                              color: _palette.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            history.changedAt == null
                                ? 'Fecha no disponible'
                                : DateFormat(
                                    'dd MMM yyyy · h:mm a',
                                  ).format(history.changedAt!),
                            style: GoogleFonts.splineSans(
                              color: _palette.textMuted,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            history.actorIdentityId == item.identityId
                                ? 'Actualizado por este perfil'
                                : 'Actualizado desde ${history.actorIdentityType ?? 'perfil profesional'}',
                            style: GoogleFonts.splineSans(
                              color: _palette.textMuted,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
