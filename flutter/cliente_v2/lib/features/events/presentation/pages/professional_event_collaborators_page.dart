import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/colors.dart';
import '../../data/models/professional_collaboration_summary_model.dart';
import '../providers/professional_event_provider.dart';

class ProfessionalEventCollaboratorsPage extends ConsumerStatefulWidget {
  final int eventId;

  const ProfessionalEventCollaboratorsPage({super.key, required this.eventId});

  @override
  ConsumerState<ProfessionalEventCollaboratorsPage> createState() =>
      _ProfessionalEventCollaboratorsPageState();
}

class _ProfessionalEventCollaboratorsPageState
    extends ConsumerState<ProfessionalEventCollaboratorsPage> {
  final Map<String, _CollaboratorDraft> _drafts =
      <String, _CollaboratorDraft>{};
  bool _initialized = false;
  bool _saving = false;
  bool _hadConfiguredSplits = false;

  Future<void> _refresh() async {
    ref.invalidate(professionalEventCollaboratorsProvider(widget.eventId));
    ref.invalidate(professionalEventInventoryProvider(widget.eventId));
    ref.invalidate(professionalDashboardProvider);
    await ref.read(
      professionalEventCollaboratorsProvider(widget.eventId).future,
    );
  }

  void _bootstrap(ProfessionalEventCollaborationSummary summary) {
    if (_initialized) {
      return;
    }

    final Map<String, _CollaboratorDraft> seeded =
        <String, _CollaboratorDraft>{};

    for (final item in summary.splits) {
      final key = _draftKey(item.identityId, item.roleType);
      seeded[key] = _CollaboratorDraft(
        identityId: item.identityId,
        identityType: item.identityType,
        roleType: item.roleType,
        displayName: item.displayName ?? item.roleLabel,
        sourceLabel: 'Configurado',
        splitValue: item.splitValue,
        requiresClaim: item.autoRelease ? false : item.requiresClaim,
        autoRelease: item.autoRelease,
        reservedAmount: item.amountReserved,
        claimableAmount: item.claimableAmount,
        statusLabel: item.statusLabel,
        modeHistory: item.modeHistory,
      );
    }

    for (final suggestion in summary.suggestions) {
      final key = _draftKey(suggestion.identityId, suggestion.roleType);
      seeded.putIfAbsent(
        key,
        () => _CollaboratorDraft(
          identityId: suggestion.identityId,
          identityType: suggestion.identityType,
          roleType: suggestion.roleType,
          displayName: suggestion.displayName,
          sourceLabel: _sourceLabel(suggestion.source),
          splitValue: 0,
          requiresClaim: true,
          autoRelease: false,
          modeHistory: const [],
        ),
      );
    }

    setState(() {
      _drafts
        ..clear()
        ..addAll(seeded);
      _initialized = true;
      _hadConfiguredSplits = summary.splits.any((item) => item.splitValue > 0);
    });
  }

  Future<void> _save() async {
    final palette = context.dutyTheme;
    if (_saving) {
      return;
    }

    final total = _totalPercentage;
    if (total > 100.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('La suma de colaboradores no puede superar 100%.'),
          backgroundColor: palette.danger,
        ),
      );
      return;
    }

    final splits = _drafts.values
        .where((draft) => draft.splitValue > 0)
        .map(
          (draft) => <String, dynamic>{
            'identity_id': draft.identityId,
            'role_type': draft.roleType,
            'split_value': draft.splitValue,
            'requires_claim': draft.requiresClaim,
            'auto_release': draft.autoRelease,
          },
        )
        .toList();

    if (splits.isEmpty) {
      if (!_hadConfiguredSplits) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Asigna al menos un porcentaje antes de guardar colaboradores.',
            ),
            backgroundColor: palette.warning,
          ),
        );
        return;
      }

      final confirmClear = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: context.dutyTheme.surface,
          title: Text(
            'Quitar todos los colaboradores',
            style: GoogleFonts.outfit(color: context.dutyTheme.textPrimary),
          ),
          content: Text(
            'Esta acción cancelará todos los splits configurados para este evento. Puedes volver a agregarlos luego, pero queremos confirmar que no fue un guardado accidental en 0%.',
            style: GoogleFonts.splineSans(
              color: context.dutyTheme.textSecondary,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Volver'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Confirmar'),
            ),
          ],
        ),
      );

      if (confirmClear != true) {
        return;
      }
    }

    setState(() => _saving = true);

    try {
      final summary = await ref
          .read(professionalEventRepositoryProvider)
          .saveEventCollaborators(widget.eventId, splits);

      ref.invalidate(professionalEventCollaboratorsProvider(widget.eventId));
      ref.invalidate(professionalEventInventoryProvider(widget.eventId));
      ref.invalidate(professionalDashboardProvider);

      if (!mounted) {
        return;
      }

      setState(() {
        _drafts.clear();
        _initialized = false;
        _hadConfiguredSplits = splits.isNotEmpty;
      });
      _bootstrap(summary);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Colaboradores actualizados correctamente.'),
          backgroundColor: palette.success,
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No pudimos guardar los colaboradores.\n$error'),
          backgroundColor: palette.danger,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.dutyTheme;
    final asyncSummary = ref.watch(
      professionalEventCollaboratorsProvider(widget.eventId),
    );

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/professional/events/${widget.eventId}/inventory');
            }
          },
          icon: Icon(Icons.arrow_back_rounded, color: palette.textPrimary),
        ),
        title: Text(
          'Colaboradores',
          style: GoogleFonts.outfit(
            color: palette.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: Text(
              _saving ? 'Guardando...' : 'Guardar',
              style: GoogleFonts.outfit(
                color: _saving ? palette.textMuted : palette.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      body: asyncSummary.when(
        data: (summary) {
          _bootstrap(summary);

          final drafts = _orderedDrafts;

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              children: [
                _buildHeader(summary),
                const SizedBox(height: 18),
                _buildTotalCard(summary),
                const SizedBox(height: 18),
                if (drafts.isEmpty)
                  _buildEmptyState()
                else
                  ...drafts.map(
                    (draft) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildDraftCard(draft),
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
              'No pudimos cargar los colaboradores de este evento.\n\n$error',
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

  Widget _buildHeader(ProfessionalEventCollaborationSummary summary) {
    final palette = context.dutyTheme;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [
            palette.primaryGlow.withValues(alpha: 0.26),
            palette.surface,
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
            'Economía compartida',
            style: GoogleFonts.outfit(
              color: palette.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Define qué porcentaje del neto del evento se reserva para artistas, venues u otros perfiles profesionales. La suma total no puede pasar de 100%.',
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
                'Pool distribuible',
                'RD\$${summary.distributableAmount.toStringAsFixed(2)}',
              ),
              _heroFact(
                'Reservado',
                'RD\$${summary.reservedForCollaborators.toStringAsFixed(2)}',
              ),
              _heroFact('Listos para reclamar', '${summary.claimableCount}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTotalCard(ProfessionalEventCollaborationSummary summary) {
    final palette = context.dutyTheme;
    final total = _totalPercentage;
    final remaining = (100 - total).clamp(0, 100);
    final overLimit = total > 100.0;
    final collaboratorReservePreview =
        summary.distributableAmount *
        (total <= 0 ? 0 : (total.clamp(0, 100).toDouble() / 100));
    final ownerReservePreview =
        summary.distributableAmount - collaboratorReservePreview;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: overLimit ? palette.danger : palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Distribución actual',
            style: GoogleFonts.outfit(
              color: palette.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Asignado: ${total.toStringAsFixed(2)}% · Disponible: ${remaining.toStringAsFixed(2)}%',
            style: GoogleFonts.splineSans(
              color: overLimit ? palette.danger : palette.textSecondary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _metricChip(
                label: 'Owner restante',
                value:
                    '${remaining.toStringAsFixed(2)}% · ${_formatCurrency(ownerReservePreview)}',
                color: palette.textSecondary,
              ),
              _metricChip(
                label: 'Colaboradores estimado',
                value: _formatCurrency(collaboratorReservePreview),
                color: palette.primary,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Preview en vivo sobre el neto distribuible actual del evento. El cálculo final se volverá a sincronizar cuando cambie el treasury o el estado de liquidación.',
            style: GoogleFonts.splineSans(
              color: palette.textMuted,
              fontSize: 11,
              height: 1.4,
            ),
          ),
          if (overLimit) ...[
            const SizedBox(height: 8),
            Text(
              'Reduce los porcentajes antes de guardar. El backend bloqueará cualquier suma por encima de 100%.',
              style: GoogleFonts.splineSans(
                color: palette.danger.withValues(alpha: 0.88),
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final palette = context.dutyTheme;
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: palette.border),
      ),
      child: Text(
        'Todavía no detectamos colaboradores sugeridos ni splits configurados para este evento.',
        textAlign: TextAlign.center,
        style: GoogleFonts.splineSans(
          color: palette.textSecondary,
          height: 1.45,
        ),
      ),
    );
  }

  Widget _buildDraftCard(_CollaboratorDraft draft) {
    final palette = context.dutyTheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: palette.border),
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
                      draft.displayName,
                      style: GoogleFonts.outfit(
                        color: palette.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_roleLabel(draft.roleType)} · ${draft.sourceLabel}',
                      style: GoogleFonts.splineSans(
                        color: palette.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (draft.statusLabel != null)
                _statusPill(
                  draft.statusLabel!,
                  draft.claimableAmount > 0
                      ? palette.success
                      : palette.textSecondary,
                ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              SizedBox(
                width: 110,
                child: TextFormField(
                  key: ValueKey('split-${draft.identityId}-${draft.roleType}'),
                  initialValue: draft.splitValue <= 0
                      ? ''
                      : draft.splitValue.toStringAsFixed(2),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  style: GoogleFonts.outfit(color: palette.textPrimary),
                  decoration: InputDecoration(
                    labelText: '% del neto',
                    labelStyle: GoogleFonts.splineSans(
                      color: palette.textMuted,
                    ),
                    suffixText: '%',
                    suffixStyle: GoogleFonts.outfit(
                      color: palette.textSecondary,
                    ),
                    filled: true,
                    fillColor: palette.surfaceAlt,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: palette.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: palette.primary),
                    ),
                  ),
                  onChanged: (value) {
                    final parsed = double.tryParse(value.replaceAll(',', '.'));
                    setState(() {
                      draft.splitValue = parsed == null || parsed < 0
                          ? 0
                          : parsed;
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      draft.reservedAmount > 0
                          ? 'Reservado: RD\$${draft.reservedAmount.toStringAsFixed(2)}'
                          : 'Sin reserva calculada todavía',
                      style: GoogleFonts.splineSans(
                        color: palette.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      draft.claimableAmount > 0
                          ? 'Reclamable ahora: RD\$${draft.claimableAmount.toStringAsFixed(2)}'
                          : 'El reclamo aparecerá cuando el evento salga de retención.',
                      style: GoogleFonts.splineSans(
                        color: palette.textMuted,
                        fontSize: 11,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Modo de acreditación',
            style: GoogleFonts.outfit(
              color: palette.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _modeChip(
                label: 'Reclamo manual',
                selected: draft.requiresClaim && !draft.autoRelease,
                icon: Icons.wallet_rounded,
                onTap: () {
                  setState(() {
                    draft.requiresClaim = true;
                    draft.autoRelease = false;
                  });
                },
              ),
              _modeChip(
                label: 'Auto release',
                selected: draft.autoRelease,
                icon: Icons.bolt_rounded,
                onTap: () {
                  setState(() {
                    draft.autoRelease = true;
                    draft.requiresClaim = false;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            draft.autoRelease
                ? 'Cuando el evento salga de retención y el split quede liberado, este share podrá acreditarse automáticamente sin que el colaborador tenga que reclamarlo manualmente.'
                : 'El colaborador verá esta ganancia en su dashboard y deberá reclamarla para acreditarla a su wallet.',
            style: GoogleFonts.splineSans(
              color: palette.textMuted,
              fontSize: 11,
              height: 1.4,
            ),
          ),
          if (draft.modeHistory.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              _latestModeChangeLabel(draft),
              style: GoogleFonts.splineSans(
                color: palette.textSecondary,
                fontSize: 11,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => _showModeHistory(draft),
                icon: const Icon(Icons.history_rounded, size: 16),
                label: Text('Historial (${draft.modeHistory.length})'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _heroFact(String label, String value) {
    final palette = context.dutyTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: palette.surfaceAlt,
        borderRadius: BorderRadius.circular(16),
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
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricChip({
    required String label,
    required String value,
    required Color color,
  }) {
    final palette = context.dutyTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.18)),
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
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _modeChip({
    required String label,
    required bool selected,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final palette = context.dutyTheme;
    final color = selected ? palette.primary : palette.textMuted;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? palette.primary.withValues(alpha: 0.14)
              : palette.surfaceAlt,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected
                ? palette.primary.withValues(alpha: 0.34)
                : palette.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.outfit(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
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

  List<_CollaboratorDraft> get _orderedDrafts {
    final items = _drafts.values.toList();
    items.sort((a, b) {
      final aHasValue = a.splitValue > 0 ? 0 : 1;
      final bHasValue = b.splitValue > 0 ? 0 : 1;
      final compareByValue = aHasValue.compareTo(bHasValue);
      if (compareByValue != 0) {
        return compareByValue;
      }
      return a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase());
    });
    return items;
  }

  double get _totalPercentage =>
      _drafts.values.fold<double>(0, (sum, draft) => sum + draft.splitValue);

  String _formatCurrency(double value) => 'RD\$${value.toStringAsFixed(2)}';

  String _latestModeChangeLabel(_CollaboratorDraft draft) {
    final latest = draft.modeHistory.isEmpty ? null : draft.modeHistory.first;
    if (latest == null) {
      return '';
    }

    final changedAt = latest.changedAt;
    final dateLabel = changedAt == null
        ? 'sin fecha'
        : DateFormat('dd MMM · h:mm a').format(changedAt);

    return 'Último cambio: ${latest.previousModeLabel} -> ${latest.nextModeLabel} · $dateLabel';
  }

  void _showModeHistory(_CollaboratorDraft draft) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.dutyTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final palette = context.dutyTheme;
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
                    color: palette.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${draft.displayName} · ${_roleLabel(draft.roleType)}',
                  style: GoogleFonts.splineSans(
                    color: palette.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                ...draft.modeHistory.map(
                  (history) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: palette.surfaceAlt,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: palette.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${history.previousModeLabel} -> ${history.nextModeLabel}',
                            style: GoogleFonts.outfit(
                              color: palette.textPrimary,
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
                              color: palette.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            history.actorIdentityId == draft.identityId
                                ? 'Actualizado por este mismo perfil'
                                : 'Actualizado desde ${history.actorIdentityType ?? 'perfil profesional'}',
                            style: GoogleFonts.splineSans(
                              color: palette.textMuted,
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

  static String _draftKey(int identityId, String roleType) =>
      '$identityId::$roleType';

  static String _sourceLabel(String source) {
    switch (source) {
      case 'event_lineup':
        return 'Sugerido por lineup';
      case 'hosting_venue':
        return 'Venue anfitrión';
      default:
        return 'Sugerido';
    }
  }

  static String _roleLabel(String role) {
    switch (role) {
      case 'artist':
        return 'Artista';
      case 'venue':
        return 'Venue';
      case 'organizer':
        return 'Organizer';
      default:
        return role;
    }
  }
}

class _CollaboratorDraft {
  final int identityId;
  final String identityType;
  final String roleType;
  final String displayName;
  final String sourceLabel;
  double splitValue;
  bool requiresClaim;
  bool autoRelease;
  final double reservedAmount;
  final double claimableAmount;
  final String? statusLabel;
  final List<ProfessionalCollaborationModeAuditItem> modeHistory;

  _CollaboratorDraft({
    required this.identityId,
    required this.identityType,
    required this.roleType,
    required this.displayName,
    required this.sourceLabel,
    required this.splitValue,
    required this.requiresClaim,
    required this.autoRelease,
    this.reservedAmount = 0,
    this.claimableAmount = 0,
    this.statusLabel,
    required this.modeHistory,
  });
}
