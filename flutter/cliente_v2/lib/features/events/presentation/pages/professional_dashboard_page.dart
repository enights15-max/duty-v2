import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/profile_state_provider.dart';
import '../../../../core/theme/colors.dart';
import '../../data/models/professional_collaboration_summary_model.dart';
import '../../data/models/professional_dashboard_model.dart';
import '../../data/models/professional_event_summary_model.dart';
import '../providers/professional_event_provider.dart';
import '../../../profile/domain/models/profile_model.dart';
import '../../../profile/presentation/providers/marketplace_provider.dart';
import '../../../profile/presentation/providers/review_prompt_provider.dart';
import '../../../wallet/presentation/providers/wallet_provider.dart';

class ProfessionalDashboardPage extends ConsumerStatefulWidget {
  const ProfessionalDashboardPage({super.key});

  @override
  ConsumerState<ProfessionalDashboardPage> createState() =>
      _ProfessionalDashboardPageState();
}

class _ProfessionalDashboardPageState
    extends ConsumerState<ProfessionalDashboardPage> {
  final Set<int> _claimingEventIds = <int>{};
  final Set<int> _claimingCollaborationIds = <int>{};

  DutyThemeTokens get _palette => context.dutyTheme;

  Future<void> _claimTreasury(ProfessionalEventSummaryModel event) async {
    final treasury = event.treasurySummary;
    if (treasury == null ||
        !event.canClaimTreasuryNow ||
        _claimingEventIds.contains(event.id)) {
      return;
    }

    setState(() => _claimingEventIds.add(event.id));

    try {
      final payload = await ref
          .read(professionalEventRepositoryProvider)
          .claimTreasury(event.id);
      final claimedAmount =
          double.tryParse(
            payload['claim']?['claimed_amount']?.toString() ?? '0',
          ) ??
          0;
      final message =
          payload['message']?.toString() ??
          'Los fondos del evento ya fueron liberados a tu wallet.';

      ref.invalidate(professionalDashboardProvider);
      ref.invalidate(professionalEventInventoryProvider(event.id));

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            claimedAmount > 0
                ? '$message (${event.claimableAmountLabel ?? 'RD\$${claimedAmount.toStringAsFixed(2)}'})'
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
          content: Text('No pudimos reclamar los fondos del evento.\n$error'),
          backgroundColor: _palette.danger,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _claimingEventIds.remove(event.id));
      }
    }
  }

  Future<void> _claimCollaboration(ProfessionalCollaborationItem item) async {
    if (!item.canClaimNow || _claimingCollaborationIds.contains(item.id)) {
      return;
    }

    setState(() => _claimingCollaborationIds.add(item.id));

    try {
      final payload = await ref
          .read(professionalEventRepositoryProvider)
          .claimCollaboration(item.id);
      final claimedAmount =
          double.tryParse(
            payload['claim']?['claimed_amount']?.toString() ?? '0',
          ) ??
          0;

      ref.invalidate(professionalDashboardProvider);
      ref.invalidate(professionalEventInventoryProvider(item.eventId));

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            claimedAmount > 0
                ? 'Colaboración acreditada a tu wallet (${item.claimableAmountLabel ?? 'RD\$${claimedAmount.toStringAsFixed(2)}'}).'
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
        setState(() => _claimingCollaborationIds.remove(item.id));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = _palette;
    final activeProfile = ref.watch(activeProfileProvider);
    final walletAsync = ref.watch(walletProvider);
    final dashboardAsync = ref.watch(professionalDashboardProvider);
    final transferInboxCount = ref.watch(pendingTransfersCountProvider);
    final pendingReviewCount = ref.watch(pendingReviewTargetsCountProvider);

    if (activeProfile == null) {
      return const Scaffold(
        body: Center(child: Text('No professional profile active')),
      );
    }

    return Scaffold(
      backgroundColor: palette.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(context, activeProfile),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatsGrid(activeProfile, walletAsync, dashboardAsync),
                  const SizedBox(height: 32),
                  _buildQuickActions(context, activeProfile),
                  const SizedBox(height: 32),
                  _buildDashboardInsights(activeProfile, dashboardAsync),
                  const SizedBox(height: 24),
                  _buildInventoryOverview(activeProfile, dashboardAsync),
                  const SizedBox(height: 24),
                  _buildInventoryWatch(context, dashboardAsync),
                  const SizedBox(height: 24),
                  _buildCollaborationSummary(dashboardAsync),
                  const SizedBox(height: 24),
                  _buildActionCenter(
                    context,
                    activeProfile,
                    dashboardAsync,
                    transferInboxCount,
                    pendingReviewCount,
                  ),
                  const SizedBox(height: 24),
                  _buildRecentActivity(
                    context,
                    activeProfile,
                    dashboardAsync,
                    transferInboxCount,
                    pendingReviewCount,
                  ),
                  const SizedBox(height: 24),
                  _buildUpcomingSection(context, dashboardAsync),
                  const SizedBox(height: 100), // Space for navbar
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, AppProfile profile) {
    final palette = _palette;
    return SliverAppBar(
      expandedHeight: 120,
      backgroundColor: Colors.transparent,
      elevation: 0,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
        title: Text(
          'Dashboard ${profile.type.name.capitalize()}',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: palette.textPrimary,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                _getProfileColor(profile.type).withValues(alpha: 0.2),
                palette.background,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid(
    AppProfile profile,
    AsyncValue<Map<String, dynamic>> walletAsync,
    AsyncValue<ProfessionalDashboardModel> dashboardAsync,
  ) {
    final palette = _palette;
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          title: 'Balance',
          value: walletAsync.when(
            data: (w) => '\$${w['balance'] ?? '0'}',
            loading: () => '...',
            error: (error, stackTrace) => '--',
          ),
          icon: Icons.account_balance_wallet_rounded,
          color: palette.success,
        ),
        _buildStatCard(
          title: profile.type == ProfileType.artist ? 'Toques' : 'Eventos',
          value: _watchMetric('events', refValue: dashboardAsync),
          icon: profile.type == ProfileType.artist
              ? Icons.music_note
              : Icons.event,
          color: palette.primary,
        ),
        _buildStatCard(
          title: 'Tickets',
          value: _watchMetric('tickets', refValue: dashboardAsync),
          icon: Icons.confirmation_number_rounded,
          color: palette.warning,
        ),
        _buildStatCard(
          title: 'Rating',
          value: _watchMetric('rating', refValue: dashboardAsync),
          icon: Icons.star_rounded,
          color: kWarmGold,
        ),
      ],
    );
  }

  String _watchMetric(
    String kind, {
    AsyncValue<ProfessionalDashboardModel>? refValue,
  }) {
    final dashboardAsync = refValue;
    if (dashboardAsync == null) {
      return '--';
    }

    return dashboardAsync.when(
      data: (dashboard) {
        switch (kind) {
          case 'events':
            return '${dashboard.eventCount}';
          case 'tickets':
            return '${dashboard.ticketSales}';
          case 'rating':
            return dashboard.averageRating.toStringAsFixed(1);
          default:
            return '--';
        }
      },
      loading: () => '...',
      error: (error, stackTrace) => '--',
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
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
          Icon(icon, color: color, size: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: GoogleFonts.splineSans(
                  color: palette.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              Text(
                title,
                style: GoogleFonts.splineSans(
                  color: palette.textMuted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, AppProfile profile) {
    final palette = _palette;
    final actions = <_QuickAction>[
      if (profile.type == ProfileType.organizer ||
          profile.type == ProfileType.venue)
        _QuickAction(
          icon: Icons.add_rounded,
          label: 'Crear',
          color: palette.primary,
          onTap: () => context.push('/professional/events/create'),
        ),
      if (profile.type == ProfileType.organizer ||
          profile.type == ProfileType.venue)
        _QuickAction(
          icon: Icons.event_note_rounded,
          label: 'Eventos',
          color: _getProfileColor(profile.type),
          onTap: () => context.push('/professional/events'),
        ),
      _QuickAction(
        icon: Icons.account_balance_wallet_rounded,
        label: 'Wallet',
        color: palette.success,
        onTap: () => context.go('/wallet'),
      ),
      _QuickAction(
        icon: Icons.qr_code_scanner_rounded,
        label: 'Escanear',
        color: palette.info,
        onTap: () => context.push('/scanner'),
      ),
      _QuickAction(
        icon: Icons.edit_rounded,
        label: 'Perfil',
        color: palette.primaryGlow,
        onTap: () => context.push('/identity-request', extra: profile),
      ),
      _QuickAction(
        icon: Icons.insights_rounded,
        label: 'Métricas',
        color: palette.warning,
        onTap: () => context.push('/professional/stats'),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Acciones Rápidas',
          style: GoogleFonts.outfit(
            color: palette.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = constraints.maxWidth >= 720 ? 4 : 3;

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: actions.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: 18,
                crossAxisSpacing: 14,
                childAspectRatio: crossAxisCount == 4 ? 0.78 : 0.82,
              ),
              itemBuilder: (context, index) {
                final action = actions[index];

                return GestureDetector(
                  onTap: action.onTap,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AspectRatio(
                        aspectRatio: 1,
                        child: Container(
                          decoration: BoxDecoration(
                            color: action.color.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(26),
                            border: Border.all(
                              color: action.color.withValues(alpha: 0.45),
                              width: 1.4,
                            ),
                          ),
                          child: Center(
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: action.color.withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Icon(
                                action.icon,
                                color: action.color,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        action.label.toUpperCase(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          color: palette.textPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          height: 1.15,
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildDashboardInsights(
    AppProfile profile,
    AsyncValue<ProfessionalDashboardModel> dashboardAsync,
  ) {
    final palette = _palette;
    return dashboardAsync.when(
      data: (dashboard) {
        final reviewLabel = dashboard.reviewCount == 1
            ? '1 review publicada'
            : '${dashboard.reviewCount} reviews publicadas';
        final sceneLabel = profile.type == ProfileType.artist
            ? 'Tu perfil ya aparece en ${dashboard.eventCount} presentaciones del circuito.'
            : 'Tu operación ya tiene ${dashboard.ticketSales} tickets vendidos registrados.';

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: _getProfileColor(profile.type).withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _getProfileColor(profile.type).withValues(alpha: 0.25),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Resumen operativo',
                style: GoogleFonts.outfit(
                  color: palette.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                sceneLabel,
                style: GoogleFonts.splineSans(
                  color: palette.textSecondary,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Rating ${dashboard.averageRating.toStringAsFixed(1)} · $reviewLabel',
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
      loading: () => const SizedBox.shrink(),
      error: (error, stackTrace) => const SizedBox.shrink(),
    );
  }

  Widget _buildInventoryOverview(
    AppProfile profile,
    AsyncValue<ProfessionalDashboardModel> dashboardAsync,
  ) {
    final palette = _palette;
    return dashboardAsync.when(
      data: (dashboard) {
        final cards = <_InventoryMetricCard>[
          _InventoryMetricCard(
            title: 'Disponibles',
            value: '${dashboard.ticketsAvailable}',
            subtitle: 'Boletas oficiales activas',
            icon: Icons.inventory_2_outlined,
            color: palette.success,
          ),
          _InventoryMetricCard(
            title: 'Sell-through',
            value: dashboard.sellThroughPercent == null
                ? '--'
                : '${dashboard.sellThroughPercent!.toStringAsFixed(1)}%',
            subtitle: 'Preventa sobre inventario trazable',
            icon: Icons.show_chart_rounded,
            color: palette.warning,
          ),
          _InventoryMetricCard(
            title: 'Low stock',
            value: '${dashboard.lowStockEvents}',
            subtitle: 'Eventos con últimas entradas',
            icon: Icons.local_fire_department_rounded,
            color: palette.warning,
          ),
          _InventoryMetricCard(
            title: 'Sold out',
            value: '${dashboard.soldOutEvents}',
            subtitle: dashboard.marketplaceFallbackEvents > 0
                ? '${dashboard.marketplaceFallbackEvents} con fallback a blackmarket'
                : 'Eventos agotados totalmente',
            icon: Icons.sell_rounded,
            color: _getProfileColor(profile.type),
          ),
        ];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Preventa e inventario',
              style: GoogleFonts.outfit(
                color: palette.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: cards.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                mainAxisExtent: 168,
              ),
              itemBuilder: (context, index) =>
                  _buildInventoryMetricCard(cards[index]),
            ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (error, stackTrace) => const SizedBox.shrink(),
    );
  }

  Widget _buildInventoryMetricCard(_InventoryMetricCard card) {
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
              color: card.color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(card.icon, color: card.color, size: 20),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                card.value,
                style: GoogleFonts.outfit(
                  color: palette.textPrimary,
                  fontSize: 24,
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
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                card.subtitle,
                style: GoogleFonts.splineSans(
                  color: palette.textMuted,
                  fontSize: 11,
                  height: 1.35,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryWatch(
    BuildContext context,
    AsyncValue<ProfessionalDashboardModel> dashboardAsync,
  ) {
    final palette = _palette;
    return dashboardAsync.when(
      data: (dashboard) {
        if (dashboard.inventoryWatch.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Inventario en vivo',
                  style: GoogleFonts.outfit(
                    color: palette.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () => context.push('/professional/events'),
                  child: const Text('Ver todos'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Column(
              children: dashboard.inventoryWatch
                  .map(
                    (event) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildInventoryWatchCard(context, event),
                    ),
                  )
                  .toList(),
            ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (error, stackTrace) => const SizedBox.shrink(),
    );
  }

  Widget _buildInventoryWatchCard(
    BuildContext context,
    ProfessionalEventSummaryModel event,
  ) {
    final palette = _palette;
    final inventory = event.inventory;
    final latestCollaborationActivity =
        event.collaborationSummary?.latestActivity;
    final sellThrough = inventory?.primarySellThroughPercent == null
        ? '--'
        : '${inventory!.primarySellThroughPercent!.toStringAsFixed(1)}%';
    final availableLabel = inventory?.primaryAvailableTickets == null
        ? 'Disponibilidad dinámica'
        : '${inventory!.primaryAvailableTickets} disponibles';

    return GestureDetector(
      onTap: () => context.push('/professional/events/${event.id}/inventory'),
      child: Container(
        width: double.infinity,
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
                        event.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.outfit(
                          color: palette.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatEventDate(event.startDate, event.startTime),
                        style: GoogleFonts.splineSans(
                          color: palette.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      if (event.managementLabel != null ||
                          event.shouldShowHostingVenueContext) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            if (event.managementLabel != null)
                              _buildInventoryMetaPill(
                                event.managementLabel!,
                                palette.textSecondary,
                              ),
                            if (event.shouldShowHostingVenueContext &&
                                event.hostingVenueLabel != null)
                              _buildInventoryMetaPill(
                                event.hostingVenueLabel!,
                                palette.info,
                              ),
                          ],
                        ),
                      ],
                      if (event.treasurySummary != null &&
                          (event.canClaimTreasuryNow ||
                              (event.treasurySummary!.availableForSettlement >
                                      0 &&
                                  event.treasurySummary!.status !=
                                      'collecting'))) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildInventoryMetaPill(
                              event.treasurySummary!.statusLabel,
                              event.canClaimTreasuryNow
                                  ? palette.success
                                  : palette.warning,
                            ),
                            if (event.claimableAmountLabel != null)
                              _buildInventoryMetaPill(
                                'Reclamable ${event.claimableAmountLabel!}',
                                palette.success,
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                if (inventory != null) _buildInventoryStatusChip(inventory),
              ],
            ),
            if (inventory != null) ...[
              const SizedBox(height: 14),
              Row(
                children: [
                  _buildInventoryFact(
                    label: 'Vendidas',
                    value: '${inventory.primaryTicketsSold}',
                  ),
                  const SizedBox(width: 18),
                  _buildInventoryFact(
                    label: 'Disponibles',
                    value: availableLabel,
                  ),
                  const SizedBox(width: 18),
                  _buildInventoryFact(
                    label: 'Sell-through',
                    value: sellThrough,
                  ),
                ],
              ),
            ],
            if (event.treasurySummary != null) ...[
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  OutlinedButton(
                    onPressed: () => context.push(
                      '/professional/events/${event.id}/inventory',
                    ),
                    child: Text(
                      event.canClaimTreasuryNow
                          ? 'Abrir liquidación'
                          : 'Ver inventario',
                    ),
                  ),
                  if (event.collaborationSummary != null)
                    OutlinedButton(
                      onPressed: () => context.push(
                        '/professional/events/${event.id}/collaborators',
                      ),
                      child: const Text('Colaboradores'),
                    ),
                  if (event.canClaimTreasuryNow)
                    FilledButton(
                      onPressed: _claimingEventIds.contains(event.id)
                          ? null
                          : () => _claimTreasury(event),
                      style: FilledButton.styleFrom(
                        backgroundColor: palette.success,
                        foregroundColor: palette.onPrimary,
                      ),
                      child: Text(
                        _claimingEventIds.contains(event.id)
                            ? 'Reclamando...'
                            : 'Reclamar',
                      ),
                    ),
                ],
              ),
            ],
            if (latestCollaborationActivity != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: palette.surfaceAlt.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: palette.border),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      latestCollaborationActivity.isAutomatic
                          ? Icons.bolt_rounded
                          : Icons.history_rounded,
                      color: latestCollaborationActivity.isAutomatic
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
                            latestCollaborationActivity.title,
                            style: GoogleFonts.outfit(
                              color: palette.textPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            latestCollaborationActivity.subtitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.splineSans(
                              color: palette.textMuted,
                              fontSize: 11,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (latestCollaborationActivity.amountLabel != null) ...[
                      const SizedBox(width: 10),
                      _buildInventoryMetaPill(
                        latestCollaborationActivity.amountLabel!,
                        latestCollaborationActivity.isAutomatic
                            ? palette.info
                            : palette.success,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInventoryStatusChip(
    ProfessionalEventInventorySummary inventory,
  ) {
    final palette = _palette;
    final Color color = switch (inventory.availabilityState) {
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
        border: Border.all(color: color.withValues(alpha: 0.35)),
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

  Widget _buildInventoryFact({required String label, required String value}) {
    final palette = _palette;
    return Expanded(
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
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.outfit(
              color: palette.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryMetaPill(String label, Color color) {
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

  Widget _buildCollaborationSummary(
    AsyncValue<ProfessionalDashboardModel> dashboardAsync,
  ) {
    final palette = _palette;
    return dashboardAsync.when(
      data: (dashboard) {
        final summary = dashboard.collaborationSummary;
        if (summary == null ||
            (summary.items.isEmpty &&
                summary.claimableAmount <= 0 &&
                summary.pendingAmount <= 0 &&
                summary.claimedAmount <= 0)) {
          return const SizedBox.shrink();
        }

        final highlightedItems = summary.items.take(3).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Colaboraciones',
                    style: GoogleFonts.outfit(
                      color: palette.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => context.push('/professional/collaborations'),
                  child: const Text('Ver todo'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Aquí ves lo que ya puedes reclamar por participaciones en eventos y lo que todavía sigue en retención.',
              style: GoogleFonts.splineSans(
                color: palette.textSecondary,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _buildInventoryFactCard(
                  'Reclamable',
                  'RD\$${summary.claimableAmount.toStringAsFixed(2)}',
                  palette.success,
                ),
                _buildInventoryFactCard(
                  'Pendiente',
                  'RD\$${summary.pendingAmount.toStringAsFixed(2)}',
                  palette.warning,
                ),
                _buildInventoryFactCard(
                  'Ya acreditado',
                  'RD\$${summary.claimedAmount.toStringAsFixed(2)}',
                  palette.info,
                ),
                if (summary.autoReleasedAmount > 0)
                  _buildInventoryFactCard(
                    'Auto-acreditado',
                    'RD\$${summary.autoReleasedAmount.toStringAsFixed(2)}',
                    palette.info,
                  ),
              ],
            ),
            if (highlightedItems.isNotEmpty) ...[
              const SizedBox(height: 14),
              ...highlightedItems.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildCollaborationItemCard(item),
                ),
              ),
            ],
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (error, stackTrace) => const SizedBox.shrink(),
    );
  }

  Widget _buildInventoryFactCard(String label, String value, Color color) {
    final palette = _palette;
    return Container(
      constraints: const BoxConstraints(minWidth: 120),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(18),
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
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollaborationItemCard(ProfessionalCollaborationItem item) {
    final palette = _palette;
    final canClaim = item.canClaimNow;
    final isClaiming = _claimingCollaborationIds.contains(item.id);
    final showAutoReleaseBadge =
        item.isAutoReleaseMode &&
        (item.status == 'pending_event_completion' ||
            item.status == 'pending_release');

    return Container(
      width: double.infinity,
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
                    if (showAutoReleaseBadge) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildInventoryMetaPill(
                            'Auto release activo',
                            palette.info,
                          ),
                          if (item.status == 'claimed' &&
                              item.amountClaimed > 0)
                            _buildInventoryMetaPill(
                              'Auto-acreditado ${item.amountClaimedLabel}',
                              palette.info,
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 10),
              _buildInventoryMetaPill(
                item.statusLabel,
                canClaim ? palette.success : palette.textSecondary,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _buildInventoryFact(
                label: 'Split',
                value: '${item.splitValue.toStringAsFixed(2)}%',
              ),
              const SizedBox(width: 18),
              _buildInventoryFact(
                label: 'Reservado',
                value: item.amountReservedLabel,
              ),
              const SizedBox(width: 18),
              _buildInventoryFact(
                label: 'Reclamable',
                value: item.claimableAmountLabel ?? 'RD\$0.00',
              ),
            ],
          ),
          if (canClaim) ...[
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: isClaiming ? null : () => _claimCollaboration(item),
                style: FilledButton.styleFrom(
                  backgroundColor: palette.success,
                  foregroundColor: palette.onPrimary,
                ),
                icon: isClaiming
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.account_balance_wallet_rounded),
                label: Text(isClaiming ? 'Reclamando...' : 'Reclamar'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionCenter(
    BuildContext context,
    AppProfile profile,
    AsyncValue<ProfessionalDashboardModel> dashboardAsync,
    int transferInboxCount,
    int pendingReviewCount,
  ) {
    final palette = _palette;
    final items = <_ActionCenterItem>[
      _ActionCenterItem(
        title: 'Aprobaciones',
        value: '$transferInboxCount',
        subtitle: transferInboxCount == 1
            ? '1 solicitud esperando respuesta'
            : '$transferInboxCount solicitudes esperando respuesta',
        icon: Icons.assignment_turned_in_outlined,
        color: palette.warning,
        highlight: transferInboxCount > 0,
        onTap: () => context.push('/pending-transfers'),
      ),
      _ActionCenterItem(
        title: 'Reviews',
        value: '$pendingReviewCount',
        subtitle: pendingReviewCount == 1
            ? '1 review pendiente'
            : '$pendingReviewCount reviews pendientes',
        icon: Icons.rate_review_outlined,
        color: palette.info,
        highlight: pendingReviewCount > 0,
        onTap: () => context.push('/reviews/pending'),
      ),
      _ActionCenterItem(
        title: 'Esta semana',
        value: _upcomingThisWeekCount(dashboardAsync).toString(),
        subtitle: profile.type == ProfileType.artist
            ? 'Presentaciones en los próximos 7 días'
            : 'Eventos en los próximos 7 días',
        icon: Icons.upcoming_rounded,
        color: _getProfileColor(profile.type),
        onTap: () => context.push('/professional/events'),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Centro operativo',
          style: GoogleFonts.outfit(
            color: palette.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: MediaQuery.of(context).size.width >= 720 ? 4 : 3,
            mainAxisSpacing: 18,
            crossAxisSpacing: 14,
            childAspectRatio: MediaQuery.of(context).size.width >= 720
                ? 0.78
                : 0.82,
          ),
          itemBuilder: (context, index) {
            final item = items[index];
            return _buildActionCenterCard(item);
          },
        ),
      ],
    );
  }

  Widget _buildActionCenterCard(_ActionCenterItem item) {
    final palette = _palette;
    return GestureDetector(
      onTap: item.onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              decoration: BoxDecoration(
                color: item.color.withValues(
                  alpha: item.highlight ? 0.14 : 0.10,
                ),
                borderRadius: BorderRadius.circular(26),
                border: Border.all(
                  color: item.color.withValues(
                    alpha: item.highlight ? 0.52 : 0.36,
                  ),
                  width: 1.4,
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: item.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Icon(item.icon, color: item.color, size: 24),
                    ),
                  ),
                  Positioned(
                    right: 10,
                    top: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: palette.background.withValues(alpha: 0.45),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: item.color.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Text(
                        item.value,
                        style: GoogleFonts.outfit(
                          color: palette.textPrimary,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  if (item.highlight)
                    Positioned(
                      left: 12,
                      top: 12,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: item.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            item.title.toUpperCase(),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              color: palette.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              height: 1.15,
            ),
          ),
        ],
      ),
    );
  }

  int _upcomingThisWeekCount(
    AsyncValue<ProfessionalDashboardModel> dashboardAsync,
  ) {
    return dashboardAsync.maybeWhen(
      data: (dashboard) {
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
      },
      orElse: () => 0,
    );
  }

  Widget _buildRecentActivity(
    BuildContext context,
    AppProfile profile,
    AsyncValue<ProfessionalDashboardModel> dashboardAsync,
    int transferInboxCount,
    int pendingReviewCount,
  ) {
    final palette = _palette;
    final items = <_RecentActivityItem>[
      if (transferInboxCount > 0)
        _RecentActivityItem(
          title: transferInboxCount == 1
              ? 'Tienes 1 transferencia esperando aprobación'
              : 'Tienes $transferInboxCount transferencias esperando aprobación',
          subtitle:
              'Abre tu inbox y decide si aceptas, rechazas o das seguimiento.',
          icon: Icons.compare_arrows_rounded,
          color: palette.warning,
          onTap: () => context.push('/pending-transfers'),
        ),
      if (pendingReviewCount > 0)
        _RecentActivityItem(
          title: pendingReviewCount == 1
              ? 'Hay 1 review pendiente por completar'
              : 'Hay $pendingReviewCount reviews pendientes por completar',
          subtitle:
              'Tus asistentes todavía tienen acciones abiertas después del evento.',
          icon: Icons.rate_review_outlined,
          color: palette.info,
          onTap: () => context.push('/reviews/pending'),
        ),
      ...dashboardAsync.maybeWhen(
        data: (dashboard) {
          if (dashboard.upcomingEvents.isEmpty) {
            return <_RecentActivityItem>[];
          }

          final nextEvent = dashboard.upcomingEvents.first;
          final eventDate = _formatEventDate(
            nextEvent.startDate,
            nextEvent.startTime,
          );

          return [
            _RecentActivityItem(
              title: profile.type == ProfileType.artist
                  ? 'Próxima presentación: ${nextEvent.title}'
                  : 'Próximo evento: ${nextEvent.title}',
              subtitle: eventDate.isEmpty
                  ? 'Ya aparece en tu agenda profesional.'
                  : 'Programado para $eventDate.',
              icon: Icons.event_available_rounded,
              color: _getProfileColor(profile.type),
              onTap: () =>
                  context.push('/professional/events/${nextEvent.id}/edit'),
            ),
          ];
        },
        orElse: () => <_RecentActivityItem>[],
      ),
    ];

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
        const SizedBox(height: 16),
        if (items.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: palette.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: palette.border),
            ),
            child: Text(
              'Todo está al día. Cuando tengas actividad nueva en transferencias, reviews o agenda, aparecerá aquí.',
              style: GoogleFonts.splineSans(
                color: palette.textSecondary,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          )
        else
          Column(
            children: items
                .map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildRecentActivityCard(item),
                  ),
                )
                .toList(),
          ),
      ],
    );
  }

  Widget _buildRecentActivityCard(_RecentActivityItem item) {
    final palette = _palette;
    return GestureDetector(
      onTap: item.onTap,
      child: Container(
        width: double.infinity,
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
                color: item.color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(item.icon, color: item.color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: GoogleFonts.splineSans(
                      color: palette.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.subtitle,
                    style: GoogleFonts.splineSans(
                      color: palette.textSecondary,
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Icon(Icons.chevron_right_rounded, color: palette.textMuted),
          ],
        ),
      ),
    );
  }

  String _formatEventDate(String? startDate, String? startTime) {
    final date = (startDate ?? '').trim();
    final time = (startTime ?? '').trim();

    if (date.isEmpty && time.isEmpty) {
      return '';
    }

    if (date.isEmpty) {
      return time;
    }

    if (time.isEmpty) {
      return date;
    }

    return '$date · $time';
  }

  Widget _buildUpcomingSection(
    BuildContext context,
    AsyncValue<ProfessionalDashboardModel> dashboardAsync,
  ) {
    final palette = _palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Próximos Eventos',
              style: GoogleFonts.outfit(
                color: palette.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () => context.push('/professional/events'),
              child: const Text('Ver todos'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        dashboardAsync.when(
          data: (dashboard) {
            if (dashboard.upcomingEvents.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: palette.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: palette.border),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.event_note_rounded,
                      color: palette.textMuted.withValues(alpha: 0.45),
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No hay eventos activos',
                      style: GoogleFonts.splineSans(
                        color: palette.textSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Los eventos que gestiones o donde participes aparecerán aquí.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.splineSans(
                        color: palette.textMuted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: dashboard.upcomingEvents
                  .map(
                    (event) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildUpcomingEventCard(context, event),
                    ),
                  )
                  .toList(),
            );
          },
          loading: () => Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: palette.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: palette.border),
            ),
            child: const Center(child: CircularProgressIndicator()),
          ),
          error: (error, _) => Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: palette.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: palette.border),
            ),
            child: Text(
              'No pudimos cargar tus próximos eventos.',
              style: GoogleFonts.splineSans(color: palette.textSecondary),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUpcomingEventCard(
    BuildContext context,
    ProfessionalEventSummaryModel event,
  ) {
    final palette = _palette;
    final imageUrl = event.thumbnailUrl;
    final venueLabel = [
      if ((event.venueName ?? '').trim().isNotEmpty) event.venueName,
      if ((event.venueCity ?? '').trim().isNotEmpty) event.venueCity,
    ].whereType<String>().join(' · ');

    return GestureDetector(
      onTap: () => context.push('/professional/events/${event.id}/edit'),
      child: Container(
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: palette.border),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(20),
              ),
              child: SizedBox(
                width: 88,
                height: 88,
                child: imageUrl != null && imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _upcomingImageFallback(),
                      )
                    : _upcomingImageFallback(),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
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
                      '${event.startDate ?? '--'} · ${event.startTime ?? '--'}',
                      style: GoogleFonts.splineSans(
                        color: palette.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    if (venueLabel.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        venueLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.splineSans(
                          color: palette.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 14),
              child: Icon(
                Icons.chevron_right_rounded,
                color: palette.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _upcomingImageFallback() {
    final palette = _palette;
    return Container(
      color: palette.surfaceAlt.withValues(alpha: 0.9),
      child: Center(
        child: Icon(
          Icons.event,
          color: palette.textMuted.withValues(alpha: 0.45),
        ),
      ),
    );
  }

  Color _getProfileColor(ProfileType type) {
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

class _QuickAction {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}

class _InventoryMetricCard {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _InventoryMetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}

class _ActionCenterItem {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool highlight;

  const _ActionCenterItem({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
    this.highlight = false,
  });
}

class _RecentActivityItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _RecentActivityItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
