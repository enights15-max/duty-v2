import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/colors.dart';
import '../../../profile/domain/models/profile_model.dart';
import '../../../../core/providers/profile_state_provider.dart';
import '../../data/models/professional_event_inventory_detail_model.dart';
import '../../data/models/professional_event_summary_model.dart';
import '../providers/professional_event_provider.dart';

class ProfessionalEventInventoryPage extends ConsumerStatefulWidget {
  final int eventId;

  const ProfessionalEventInventoryPage({super.key, required this.eventId});

  @override
  ConsumerState<ProfessionalEventInventoryPage> createState() =>
      _ProfessionalEventInventoryPageState();
}

class _ProfessionalEventInventoryPageState
    extends ConsumerState<ProfessionalEventInventoryPage> {
  bool _isClaiming = false;

  int get eventId => widget.eventId;
  DutyThemeTokens get _palette => context.dutyTheme;

  Future<void> _refreshInventory() async {
    ref.invalidate(professionalEventInventoryProvider(eventId));
    await ref.read(professionalEventInventoryProvider(eventId).future);
  }

  Future<void> _claimTreasury(
    ProfessionalEventInventoryDetailModel detail,
  ) async {
    final treasury = detail.event.treasurySummary;
    if (_isClaiming || treasury == null || !treasury.canReleaseNow) {
      return;
    }

    setState(() => _isClaiming = true);

    try {
      final payload = await ref
          .read(professionalEventRepositoryProvider)
          .claimTreasury(eventId);
      final claimedAmount =
          double.tryParse(
            payload['claim']?['claimed_amount']?.toString() ?? '0',
          ) ??
          0;
      final message =
          payload['message']?.toString() ??
          'Los fondos del evento ya fueron liberados a tu wallet.';

      ref.invalidate(professionalDashboardProvider);
      ref.invalidate(professionalEventInventoryProvider(eventId));

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            claimedAmount > 0
                ? '$message (${_formatCurrency(claimedAmount)})'
                : message,
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
          content: Text('No pudimos reclamar los fondos ahora mismo.\n$error'),
          backgroundColor: _palette.danger,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isClaiming = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = _palette;
    final inventoryAsync = ref.watch(
      professionalEventInventoryProvider(eventId),
    );
    final activeProfile = ref.watch(activeProfileProvider);
    final accent = _profileAccent(activeProfile?.type);

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Inventario',
          style: GoogleFonts.outfit(
            color: palette.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Gestionar tickets',
            onPressed: () =>
                context.push('/professional/events/$eventId/tickets'),
            icon: const Icon(Icons.local_activity_rounded),
          ),
          IconButton(
            tooltip: 'Editar evento',
            onPressed: () => context.push('/professional/events/$eventId/edit'),
            icon: const Icon(Icons.edit_rounded),
          ),
        ],
      ),
      body: inventoryAsync.when(
        data: (detail) => RefreshIndicator(
          onRefresh: _refreshInventory,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              _buildHero(detail, accent),
              const SizedBox(height: 24),
              _buildTreasuryCard(detail, accent),
              const SizedBox(height: 24),
              _buildCollaborationCard(detail, accent),
              const SizedBox(height: 24),
              _buildSummaryGrid(detail, accent),
              const SizedBox(height: 24),
              _buildCirculationGrid(detail, accent),
              const SizedBox(height: 24),
              _buildTicketBreakdown(context, detail, accent),
              const SizedBox(height: 24),
              _buildRecentActivity(detail, accent),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: palette.danger.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: palette.danger.withValues(alpha: 0.28),
                ),
              ),
              child: Text(
                'No pudimos cargar el detalle de inventario ahora mismo.\n\n$error',
                textAlign: TextAlign.center,
                style: GoogleFonts.splineSans(
                  color: palette.textSecondary,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHero(
    ProfessionalEventInventoryDetailModel detail,
    Color accent,
  ) {
    final palette = _palette;
    final event = detail.event;
    final inventory = detail.inventory;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [accent.withValues(alpha: 0.18), palette.heroGradientStart],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: accent.withValues(alpha: 0.30)),
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
                      event.title,
                      style: GoogleFonts.outfit(
                        color: palette.textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _eventMetaLine(event),
                      style: GoogleFonts.splineSans(
                        color: palette.textSecondary,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                    if (event.managementLabel != null ||
                        event.shouldShowHostingVenueContext) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (event.managementLabel != null)
                            _buildContextPill(
                              event.managementLabel!,
                              palette.textSecondary,
                            ),
                          if (event.shouldShowHostingVenueContext &&
                              event.hostingVenueLabel != null)
                            _buildContextPill(
                              event.hostingVenueLabel!,
                              palette.info,
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _buildStatusChip(inventory),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _buildHeroFact(
                label: 'Disponibles',
                value:
                    inventory.primaryAvailableTickets?.toString() ?? 'Dinámico',
              ),
              _buildHeroFact(
                label: 'Vendidas',
                value: '${inventory.primaryTicketsSold}',
              ),
              _buildHeroFact(
                label: 'Sell-through',
                value: inventory.primarySellThroughPercent == null
                    ? '--'
                    : '${inventory.primarySellThroughPercent!.toStringAsFixed(1)}%',
              ),
              _buildHeroFact(
                label: 'Blackmarket',
                value: '${inventory.marketplaceAvailableCount}',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTreasuryCard(
    ProfessionalEventInventoryDetailModel detail,
    Color accent,
  ) {
    final palette = _palette;
    final treasury = detail.event.treasurySummary;

    if (treasury == null) {
      return const SizedBox.shrink();
    }

    final statusColor = switch (treasury.status) {
      'eligible_for_payout' => palette.success,
      'settlement_hold' => palette.warning,
      'awaiting_settlement' => kWarmGold,
      'settled' => palette.info,
      _ => accent,
    };

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: statusColor.withValues(alpha: 0.22)),
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
                      'Tesorería del evento',
                      style: GoogleFonts.outfit(
                        color: palette.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      treasury.statusHelper,
                      style: GoogleFonts.splineSans(
                        color: palette.textSecondary,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _buildContextPill(treasury.statusLabel, statusColor),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _buildHeroFact(
                label: 'Reclamable',
                value: _formatCurrency(treasury.claimableAmount),
              ),
              _buildHeroFact(
                label: 'Disponible para liquidar',
                value: _formatCurrency(treasury.availableForSettlement),
              ),
              _buildHeroFact(
                label: 'Ya liberado',
                value: _formatCurrency(treasury.releasedToWallet),
              ),
              _buildHeroFact(
                label: 'Fees Duty',
                value: _formatCurrency(treasury.platformFeeTotal),
              ),
            ],
          ),
          if (treasury.remainingHoldHours != null ||
              treasury.requiresAdminApproval) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: palette.surfaceAlt.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: palette.border),
              ),
              child: Text(
                [
                  if (treasury.remainingHoldHours != null)
                    'Quedan aproximadamente ${treasury.remainingHoldHours} horas dentro del período de retención.',
                  if (treasury.requiresAdminApproval)
                    'Este evento requiere aprobación administrativa antes de liberar fondos.',
                ].join(' '),
                style: GoogleFonts.splineSans(
                  color: palette.textSecondary,
                  height: 1.45,
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: treasury.canReleaseNow && !_isClaiming
                      ? () => _claimTreasury(detail)
                      : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: palette.success,
                    foregroundColor: palette.onPrimary,
                    disabledBackgroundColor: palette.surfaceMuted,
                    disabledForegroundColor: palette.textMuted,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  icon: _isClaiming
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.account_balance_wallet_rounded),
                  label: Text(
                    _isClaiming ? 'Reclamando...' : 'Reclamar fondos',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroFact({required String label, required String value}) {
    final palette = _palette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: palette.surfaceAlt.withValues(alpha: 0.9),
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

  Widget _buildContextPill(String label, Color color) {
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

  Widget _buildSummaryGrid(
    ProfessionalEventInventoryDetailModel detail,
    Color accent,
  ) {
    final palette = _palette;
    final inventory = detail.inventory;
    final cards = [
      _MetricCard(
        title: 'Boletas oficiales',
        value: inventory.primaryTotalInventory?.toString() ?? 'Abierto',
        subtitle: inventory.primaryTotalInventory == null
            ? 'El inventario principal es dinámico'
            : 'Inventario total trazable del evento',
        icon: Icons.inventory_2_outlined,
        color: palette.success,
      ),
      _MetricCard(
        title: 'Low stock',
        value: inventory.lowStock ? 'Sí' : 'No',
        subtitle: inventory.lowStock
            ? 'Conviene revisar pricing y comunicación'
            : 'Sin alerta de últimas entradas',
        icon: Icons.local_fire_department_rounded,
        color: palette.warning,
      ),
      _MetricCard(
        title: 'Estado',
        value: inventory.demandLabel,
        subtitle: inventory.showMarketplaceFallback
            ? 'La taquilla ya agotó y hay fallback a reventa'
            : 'Lectura en vivo de disponibilidad principal',
        icon: Icons.insights_rounded,
        color: accent,
      ),
      _MetricCard(
        title: 'Blackmarket',
        value: '${inventory.marketplaceAvailableCount}',
        subtitle: inventory.marketplaceAvailableCount > 0
            ? 'Entradas revendidas activas para este evento'
            : 'Sin fallback de reventa ahora mismo',
        icon: Icons.storefront_rounded,
        color: palette.info,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Resumen de preventa',
          style: GoogleFonts.outfit(
            color: palette.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 14),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cards.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 0.95,
          ),
          itemBuilder: (context, index) => _buildMetricCard(cards[index]),
        ),
      ],
    );
  }

  Widget _buildCollaborationCard(
    ProfessionalEventInventoryDetailModel detail,
    Color accent,
  ) {
    final palette = _palette;
    final collaboration =
        detail.collaboration ?? detail.event.collaborationSummary;
    if (collaboration == null) {
      return const SizedBox.shrink();
    }

    final previewItems = collaboration.splits.take(3).toList();
    final activityItems = collaboration.activity.take(4).toList();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: accent.withValues(alpha: 0.20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Economía compartida',
            style: GoogleFonts.outfit(
              color: palette.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Aquí ves cuánto del neto del evento está reservado para colaboradores y qué participaciones ya están listas para reclamar.',
            style: GoogleFonts.splineSans(
              color: palette.textSecondary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _buildHeroFact(
                label: 'Pool distribuible',
                value: _formatCurrency(collaboration.distributableAmount),
              ),
              _buildHeroFact(
                label: 'Reservado a colaboradores',
                value: _formatCurrency(collaboration.reservedForCollaborators),
              ),
              _buildHeroFact(
                label: 'Listos para reclamar',
                value: '${collaboration.claimableCount}',
              ),
              _buildHeroFact(
                label: 'Sugeridos',
                value: '${collaboration.suggestions.length}',
              ),
            ],
          ),
          if (previewItems.isNotEmpty) ...[
            const SizedBox(height: 16),
            ...previewItems.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: palette.surfaceAlt,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: palette.border),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.displayName ?? item.roleLabel,
                              style: GoogleFonts.outfit(
                                color: palette.textPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${item.roleLabel} · ${item.splitValue.toStringAsFixed(2)}% del neto',
                              style: GoogleFonts.splineSans(
                                color: palette.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      _buildContextPill(
                        item.statusLabel,
                        item.canClaimNow
                            ? palette.success
                            : palette.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
          if (collaboration.suggestions.isNotEmpty) ...[
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: palette.surfaceAlt,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: palette.border),
              ),
              child: Text(
                'Sugerencias detectadas: ${collaboration.suggestions.map((item) => item.displayName).join(', ')}.',
                style: GoogleFonts.splineSans(
                  color: palette.textSecondary,
                  height: 1.4,
                ),
              ),
            ),
          ],
          if (activityItems.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Actividad reciente',
              style: GoogleFonts.outfit(
                color: palette.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            ...activityItems.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: palette.surfaceAlt,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: palette.border),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        item.isAutomatic
                            ? Icons.bolt_rounded
                            : Icons.history_rounded,
                        color: item.isAutomatic
                            ? palette.info
                            : palette.textMuted,
                        size: 16,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: GoogleFonts.outfit(
                                color: palette.textPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.subtitle,
                              style: GoogleFonts.splineSans(
                                color: palette.textSecondary,
                                fontSize: 12,
                                height: 1.4,
                              ),
                            ),
                            if (item.occurredAt != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                DateFormat(
                                  'dd MMM yyyy · h:mm a',
                                ).format(item.occurredAt!),
                                style: GoogleFonts.splineSans(
                                  color: palette.textMuted,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (item.amountLabel != null) ...[
                        const SizedBox(width: 10),
                        _buildContextPill(
                          item.amountLabel!,
                          item.isAutomatic ? palette.info : palette.success,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              OutlinedButton.icon(
                onPressed: () =>
                    context.push('/professional/events/$eventId/collaborators'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: palette.textPrimary,
                  side: BorderSide(color: accent.withValues(alpha: 0.28)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                icon: const Icon(Icons.group_add_rounded),
                label: const Text('Gestionar colaboradores'),
              ),
              OutlinedButton.icon(
                onPressed: () => context.push('/professional/collaborations'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: palette.textPrimary,
                  side: BorderSide(color: accent.withValues(alpha: 0.18)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                icon: const Icon(Icons.account_balance_wallet_outlined),
                label: const Text('Ver ganancias'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCirculationGrid(
    ProfessionalEventInventoryDetailModel detail,
    Color accent,
  ) {
    final palette = _palette;
    final circulation = detail.circulation;
    final cards = [
      _MetricCard(
        title: 'Boletas movidas',
        value: '${circulation.ticketsMovedCount}',
        subtitle: 'Entradas que ya pasaron por regalo, reventa o scan.',
        icon: Icons.compare_arrows_rounded,
        color: accent,
      ),
      _MetricCard(
        title: 'Reventas',
        value: '${circulation.resaleCount}',
        subtitle: circulation.maxResalePrice == null
            ? 'Todavía no hay compras en blackmarket cerradas.'
            : 'Pico RD\$${circulation.maxResalePrice!.toStringAsFixed(2)}',
        icon: Icons.trending_up_rounded,
        color: palette.info,
      ),
      _MetricCard(
        title: 'Regalos',
        value:
            '${circulation.giftTransferCompletedCount}/${circulation.giftTransferPendingCount + circulation.giftTransferCompletedCount}',
        subtitle:
            '${circulation.giftTransferPendingCount} pendientes · ${circulation.giftTransferCompletedCount} completados',
        icon: Icons.card_giftcard_rounded,
        color: kDustRose,
      ),
      _MetricCard(
        title: 'Promo bloqueada',
        value: '${circulation.promoResaleLockedCount}',
        subtitle: 'Boletas emitidas con restricción de reventa promocional.',
        icon: Icons.lock_outline_rounded,
        color: palette.warning,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Circulación de boletas',
          style: GoogleFonts.outfit(
            color: palette.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Aquí empezamos a ver qué tanto se mueven las boletas entre compra primaria, regalos, reventa y acceso final.',
          style: GoogleFonts.splineSans(
            color: palette.textSecondary,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 14),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cards.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            mainAxisExtent: 168,
          ),
          itemBuilder: (context, index) => _buildMetricCard(cards[index]),
        ),
        if (circulation.averageResalePrice != null ||
            circulation.journeyEventCount > 0) ...[
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: palette.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: palette.border),
            ),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _buildHeroFact(
                  label: 'Eventos de journey',
                  value: '${circulation.journeyEventCount}',
                ),
                _buildHeroFact(
                  label: 'Listados',
                  value: '${circulation.listingCount}',
                ),
                _buildHeroFact(
                  label: 'Promedio reventa',
                  value: circulation.averageResalePrice == null
                      ? '--'
                      : 'RD\$${circulation.averageResalePrice!.toStringAsFixed(2)}',
                ),
                _buildHeroFact(
                  label: 'Escaneadas',
                  value: '${circulation.scanCount}',
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMetricCard(_MetricCard card) {
    final palette = _palette;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: card.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(card.icon, color: card.color, size: 20),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                card.value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.outfit(
                  color: palette.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                card.title,
                style: GoogleFonts.splineSans(
                  color: palette.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                card.subtitle,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.splineSans(
                  color: palette.textMuted,
                  fontSize: 11,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTicketBreakdown(
    BuildContext context,
    ProfessionalEventInventoryDetailModel detail,
    Color accent,
  ) {
    final palette = _palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Detalle por ticket',
          style: GoogleFonts.outfit(
            color: palette.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: () =>
                context.push('/professional/events/$eventId/tickets'),
            style: OutlinedButton.styleFrom(
              foregroundColor: palette.textPrimary,
              side: BorderSide(color: accent.withValues(alpha: 0.28)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            icon: const Icon(Icons.tune_rounded),
            label: const Text('Gestionar tickets'),
          ),
        ),
        const SizedBox(height: 12),
        if (detail.ticketBreakdown.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: palette.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: palette.border),
            ),
            child: Text(
              'Este evento todavía no tiene ticket breakdown trazable desde mobile.',
              style: GoogleFonts.splineSans(color: palette.textSecondary),
            ),
          )
        else
          ...detail.ticketBreakdown.map(
            (row) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildTicketRow(row, accent),
            ),
          ),
      ],
    );
  }

  Widget _buildTicketRow(ProfessionalTicketInventoryRow row, Color accent) {
    final palette = _palette;
    final limitedLabel = row.inventoryLimited
        ? (row.available?.toString() ?? '0')
        : 'Abierto';
    final sellThrough = row.sellThroughPercent == null
        ? '--'
        : '${row.sellThroughPercent!.toStringAsFixed(1)}%';

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
                      row.label,
                      style: GoogleFonts.outfit(
                        color: palette.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'RD\$${row.unitPrice.toStringAsFixed(2)} · ${row.pricingType}',
                      style: GoogleFonts.splineSans(
                        color: palette.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: accent.withValues(alpha: 0.28)),
                ),
                child: Text(
                  row.inventoryLimited ? 'Limitado' : 'Abierto',
                  style: GoogleFonts.outfit(
                    color: accent,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _buildTinyFact('Disponibles', limitedLabel),
              _buildTinyFact('Vendidas', '${row.sold}'),
              _buildTinyFact('Reservadas', '${row.reserved}'),
              _buildTinyFact('Sell-through', sellThrough),
              if (row.maxPerUser != null)
                _buildTinyFact('Límite por usuario', '${row.maxPerUser}'),
              if (row.reservationEnabled) _buildTinyFact('Reservas', 'Sí'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTinyFact(String label, String value) {
    final palette = _palette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: palette.surfaceAlt.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: palette.border),
      ),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$label: ',
              style: GoogleFonts.splineSans(
                color: palette.textMuted,
                fontSize: 11,
              ),
            ),
            TextSpan(
              text: value,
              style: GoogleFonts.outfit(
                color: palette.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity(
    ProfessionalEventInventoryDetailModel detail,
    Color accent,
  ) {
    final palette = _palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Actividad reciente',
          style: GoogleFonts.outfit(
            color: palette.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        if (detail.recentActivity.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: palette.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: palette.border),
            ),
            child: Text(
              'Todavía no hay compras ni reservas recientes para este evento.',
              style: GoogleFonts.splineSans(color: palette.textSecondary),
            ),
          )
        else
          ...detail.recentActivity.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: palette.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: palette.border),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color:
                            (item.type == 'sale'
                                    ? palette.success
                                    : palette.info)
                                .withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        item.type == 'sale'
                            ? Icons.shopping_bag_rounded
                            : Icons.lock_clock_rounded,
                        color: item.type == 'sale'
                            ? palette.success
                            : palette.info,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: GoogleFonts.outfit(
                              color: palette.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.subtitle,
                            style: GoogleFonts.splineSans(
                              color: palette.textSecondary,
                              fontSize: 13,
                              height: 1.35,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text(
                                'RD\$${item.amount.toStringAsFixed(2)}',
                                style: GoogleFonts.outfit(
                                  color: palette.textPrimary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                item.occurredAt == null
                                    ? 'Ahora'
                                    : DateFormat(
                                        'dd MMM · h:mm a',
                                      ).format(item.occurredAt!.toLocal()),
                                style: GoogleFonts.splineSans(
                                  color: palette.textMuted,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStatusChip(ProfessionalEventInventorySummary inventory) {
    final palette = _palette;
    final color = switch (inventory.availabilityState) {
      'sold_out_marketplace' => palette.warning,
      'sold_out' => palette.danger,
      'low_stock' => kWarmGold,
      _ => palette.success,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.32)),
      ),
      child: Text(
        inventory.demandLabel,
        style: GoogleFonts.outfit(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
      ),
    );
  }

  String _eventMetaLine(ProfessionalEventSummaryModel event) {
    final parts = <String>[];
    final startDate = event.startDate;
    if (startDate != null && startDate.isNotEmpty) {
      final parsed = DateTime.tryParse(startDate);
      parts.add(
        parsed == null
            ? startDate
            : DateFormat('dd MMM yyyy').format(parsed.toLocal()),
      );
    }
    if (event.startTime != null && event.startTime!.isNotEmpty) {
      parts.add(event.startTime!);
    }
    if (event.venueName != null && event.venueName!.isNotEmpty) {
      parts.add(event.venueName!);
    }
    if (event.venueCity != null && event.venueCity!.isNotEmpty) {
      parts.add(event.venueCity!);
    }
    return parts.join(' · ');
  }

  Color _profileAccent(ProfileType? type) {
    switch (type) {
      case ProfileType.artist:
        return kDustRose;
      case ProfileType.venue:
        return kInfoColor;
      case ProfileType.organizer:
        return kPrimaryColor;
      case ProfileType.personal:
      case null:
        return kPrimaryColor;
    }
  }
}

String _formatCurrency(double amount) => 'RD\$${amount.toStringAsFixed(2)}';

class _MetricCard {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}
