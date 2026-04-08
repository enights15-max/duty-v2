import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/colors.dart';
import '../../data/models/loyalty_models.dart';
import '../providers/loyalty_provider.dart';

class LoyaltyPage extends ConsumerWidget {
  const LoyaltyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.dutyTheme;
    ref.listen<LoyaltyRedeemState>(loyaltyRedeemProvider, (previous, next) {
      final messenger = ScaffoldMessenger.maybeOf(context);
      if (messenger == null) {
        return;
      }

      if (next.error != null && next.error != previous?.error) {
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(next.error!),
              backgroundColor: palette.danger,
            ),
          );
      }
    });

    final summaryAsync = ref.watch(loyaltySummaryProvider);
    final historyAsync = ref.watch(loyaltyHistoryProvider);
    final rewardsAsync = ref.watch(loyaltyRewardsProvider);
    final redemptionsAsync = ref.watch(loyaltyRedemptionsProvider);
    final redeemState = ref.watch(loyaltyRedeemProvider);

    final summary = summaryAsync.valueOrNull;
    final rewards = rewardsAsync.valueOrNull ?? const <LoyaltyRewardModel>[];
    final history =
        historyAsync.valueOrNull ?? const <LoyaltyHistoryItemModel>[];
    final redemptions =
        redemptionsAsync.valueOrNull ?? const <LoyaltyRedemptionModel>[];

    final isInitialLoading =
        summary == null &&
        rewards.isEmpty &&
        history.isEmpty &&
        redemptions.isEmpty &&
        (summaryAsync.isLoading ||
            rewardsAsync.isLoading ||
            historyAsync.isLoading ||
            redemptionsAsync.isLoading);

    return Scaffold(
      backgroundColor: palette.background,
      body: Stack(
        children: [
          const _LoyaltyBackground(),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 6),
                  child: Row(
                    children: [
                      _GlassCircleButton(
                        icon: Icons.arrow_back_rounded,
                        onTap: () {
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            context.go('/profile');
                          }
                        },
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Duty Rewards',
                              style: GoogleFonts.splineSans(
                                color: palette.textPrimary,
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'Puntos, bonos internos y perks canjeables dentro de Duty.',
                              style: GoogleFonts.splineSans(
                                color: palette.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _GlassCircleButton(
                        icon: Icons.refresh_rounded,
                        onTap: () => _refresh(ref),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: isInitialLoading
                      ? const Center(child: CircularProgressIndicator())
                      : RefreshIndicator(
                          onRefresh: () => _refresh(ref),
                          color: palette.primary,
                          backgroundColor: palette.surface,
                          child: ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                            children: [
                              _SummaryHero(
                                summary: summary,
                                rewards: rewards,
                                isLoading: summaryAsync.isLoading,
                                hasError: summaryAsync.hasError,
                              ),
                              const SizedBox(height: 18),
                              _StatStrip(summary: summary),
                              const SizedBox(height: 18),
                              const _EarnWaysCard(),
                              const SizedBox(height: 22),
                              const _SectionHeader(
                                eyebrow: 'CATALOGO ACTIVO',
                                title: 'Recompensas que puedes desbloquear',
                                subtitle:
                                    'Canjea puntos por bono interno o perks consumibles sin mezclarlo con tu wallet real.',
                              ),
                              const SizedBox(height: 12),
                              _RewardsShelf(
                                rewards: rewards,
                                currentPoints: summary?.currentPoints ?? 0,
                                isLoading: rewardsAsync.isLoading,
                                hasError: rewardsAsync.hasError,
                                redeemState: redeemState,
                                onRedeem: (reward) async {
                                  final result = await ref
                                      .read(loyaltyRedeemProvider.notifier)
                                      .redeem(reward);
                                  if (!context.mounted) {
                                    return;
                                  }
                                  final redemption = result.redemption;
                                  final code = redemption?.claimCode;
                                  final details =
                                      code != null && code.isNotEmpty
                                      ? '${result.message} Codigo: $code'
                                      : redemption?.bonusAmount != null &&
                                            (redemption?.bonusAmount ?? 0) > 0
                                      ? '${result.message} Bono: RD\$${(redemption?.bonusAmount ?? 0).toStringAsFixed(2)}'
                                      : result.message;
                                  ScaffoldMessenger.of(context)
                                    ..hideCurrentSnackBar()
                                    ..showSnackBar(
                                      SnackBar(
                                        content: Text(details),
                                        backgroundColor: palette.success,
                                      ),
                                    );
                                },
                              ),
                              const SizedBox(height: 24),
                              const _SectionHeader(
                                eyebrow: 'ACTIVIDAD',
                                title: 'Como se mueven tus puntos',
                                subtitle:
                                    'Cada compra o interaccion premiada deja rastro para auditar saldo y canjes.',
                              ),
                              const SizedBox(height: 12),
                              _HistoryPanel(
                                items: history,
                                isLoading: historyAsync.isLoading,
                                hasError: historyAsync.hasError,
                              ),
                              const SizedBox(height: 24),
                              const _SectionHeader(
                                eyebrow: 'CANJES',
                                title: 'Historial de recompensas reclamadas',
                                subtitle:
                                    'Las recompensas de bono interno quedan listas para checkout mixto dentro de Duty.',
                              ),
                              const SizedBox(height: 12),
                              _RedemptionsPanel(
                                items: redemptions,
                                isLoading: redemptionsAsync.isLoading,
                                hasError: redemptionsAsync.hasError,
                              ),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _refresh(WidgetRef ref) async {
    await Future.wait([
      ref.refresh(loyaltySummaryProvider.future),
      ref.refresh(loyaltyHistoryProvider.future),
      ref.refresh(loyaltyRewardsProvider.future),
      ref.refresh(loyaltyRedemptionsProvider.future),
    ]);
  }
}

class _LoyaltyBackground extends StatelessWidget {
  const _LoyaltyBackground();

  @override
  Widget build(BuildContext context) {
    final palette = context.dutyTheme;
    return Stack(
      children: [
        Positioned(
          top: -140,
          right: -50,
          child: _BlurOrb(size: 260, color: kWarmGold.withValues(alpha: 0.18)),
        ),
        Positioned(
          top: 120,
          left: -80,
          child: _BlurOrb(
            size: 220,
            color: palette.success.withValues(alpha: 0.16),
          ),
        ),
        Positioned(
          bottom: -120,
          right: -40,
          child: _BlurOrb(
            size: 260,
            color: palette.primaryGlow.withValues(alpha: 0.2),
          ),
        ),
      ],
    );
  }
}

class _BlurOrb extends StatelessWidget {
  final double size;
  final Color color;

  const _BlurOrb({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
        ),
      ),
    );
  }
}

class _GlassCircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _GlassCircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final palette = context.dutyTheme;
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Ink(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: palette.surfaceAlt.withValues(alpha: 0.88),
          border: Border.all(color: palette.border),
        ),
        child: Icon(icon, color: palette.textPrimary),
      ),
    );
  }
}

class _SummaryHero extends StatelessWidget {
  final LoyaltySummaryModel? summary;
  final List<LoyaltyRewardModel> rewards;
  final bool isLoading;
  final bool hasError;

  const _SummaryHero({
    required this.summary,
    required this.rewards,
    required this.isLoading,
    required this.hasError,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.dutyTheme;
    final currentPoints = summary?.currentPoints ?? 0;
    final nextReward = rewards
        .where((reward) => reward.pointsCost > currentPoints)
        .fold<LoyaltyRewardModel?>(null, (current, reward) {
          if (current == null || reward.pointsCost < current.pointsCost) {
            return reward;
          }
          return current;
        });

    final gap = nextReward != null ? nextReward.pointsCost - currentPoints : 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: [
            palette.heroGradientStart,
            palette.backgroundAlt,
            palette.primarySurface,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: palette.border),
        boxShadow: [
          BoxShadow(
            color: palette.primaryGlow.withValues(alpha: 0.16),
            blurRadius: 40,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: kWarmGold.withValues(alpha: 0.14),
                ),
                child: Text(
                  'Saldo loyalty',
                  style: GoogleFonts.splineSans(
                    color: kWarmGold,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
              const Spacer(),
              if (isLoading)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            _points(summary?.currentPoints ?? 0),
            style: GoogleFonts.splineSans(
              color: palette.textPrimary,
              fontSize: 46,
              fontWeight: FontWeight.w700,
              height: 0.96,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            hasError
                ? 'No se pudo leer el resumen en este momento.'
                : nextReward != null
                ? 'Te faltan ${_points(gap)} para desbloquear ${nextReward.title}.'
                : 'Ya puedes reclamar cualquier recompensa activa del catalogo.',
            style: GoogleFonts.splineSans(
              color: palette.textSecondary,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _MiniMetric(
                label: 'Disponibles ahora',
                value: '${summary?.availableRewards ?? 0} rewards',
                accent: kWarmGold,
              ),
              const _MiniMetric(
                label: 'Uso recomendado',
                value: 'Checkout mixto',
                accent: kSuccessColor,
              ),
              const _MiniMetric(
                label: 'Acreditacion',
                value: 'Bono interno',
                accent: kInfoColor,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniMetric extends StatelessWidget {
  final String label;
  final String value;
  final Color accent;

  const _MiniMetric({
    required this.label,
    required this.value,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.dutyTheme;
    return Container(
      width: 148,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: palette.surface.withValues(alpha: 0.58),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accent,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.splineSans(
                    color: palette.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.splineSans(
              color: palette.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatStrip extends StatelessWidget {
  final LoyaltySummaryModel? summary;

  const _StatStrip({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'Lifetime',
            value: _points(summary?.lifetimePoints ?? 0),
            icon: Icons.ssid_chart_rounded,
            accent: kInfoColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            label: 'Canjeados',
            value: _points(summary?.redeemedPoints ?? 0),
            icon: Icons.redeem_rounded,
            accent: kDustRose,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            label: 'Listos',
            value: '${summary?.availableRewards ?? 0}',
            icon: Icons.local_offer_rounded,
            accent: kWarmGold,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color accent;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.dutyTheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: palette.surfaceAlt,
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: accent, size: 18),
          const SizedBox(height: 20),
          Text(
            value,
            style: GoogleFonts.splineSans(
              color: palette.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.splineSans(
              color: palette.textMuted,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _EarnWaysCard extends StatelessWidget {
  const _EarnWaysCard();

  @override
  Widget build(BuildContext context) {
    final palette = context.dutyTheme;
    const items = [
      (
        icon: Icons.confirmation_number_rounded,
        title: 'Compra directa',
        subtitle: 'Puntos por compra de boletas al organizer.',
      ),
      (
        icon: Icons.storefront_rounded,
        title: 'Blackmarket',
        subtitle: 'Tambien suma cuando compras en reventa interna.',
      ),
      (
        icon: Icons.rate_review_rounded,
        title: 'Reviews sanas',
        subtitle: 'Solo reviews publicadas generan puntos.',
      ),
      (
        icon: Icons.people_alt_rounded,
        title: 'Interaccion social',
        subtitle: 'Follow aceptado tambien cuenta dentro del programa.',
      ),
    ];

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
          Text(
            'Como se gana hoy',
            style: GoogleFonts.splineSans(
              color: palette.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'El programa esta separado del wallet real: primero acumulas puntos, luego los conviertes en bono o perks.',
            style: GoogleFonts.splineSans(
              color: palette.textSecondary,
              fontSize: 13,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: palette.surfaceAlt,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(item.icon, color: kWarmGold),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: GoogleFonts.splineSans(
                            color: palette.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.subtitle,
                          style: GoogleFonts.splineSans(
                            color: palette.textSecondary,
                            fontSize: 12,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String subtitle;

  const _SectionHeader({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.dutyTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow,
          style: GoogleFonts.splineSans(
            color: kWarmGold,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.8,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          style: GoogleFonts.splineSans(
            color: palette.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: GoogleFonts.splineSans(
            color: palette.textSecondary,
            fontSize: 13,
            height: 1.45,
          ),
        ),
      ],
    );
  }
}

class _RewardsShelf extends StatelessWidget {
  final List<LoyaltyRewardModel> rewards;
  final int currentPoints;
  final bool isLoading;
  final bool hasError;
  final LoyaltyRedeemState redeemState;
  final Future<void> Function(LoyaltyRewardModel reward) onRedeem;

  const _RewardsShelf({
    required this.rewards,
    required this.currentPoints,
    required this.isLoading,
    required this.hasError,
    required this.redeemState,
    required this.onRedeem,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.dutyTheme;
    if (isLoading && rewards.isEmpty) {
      return SizedBox(
        height: 310,
        child: Center(child: CircularProgressIndicator(color: palette.primary)),
      );
    }

    if (hasError && rewards.isEmpty) {
      return const _EmptyStateCard(
        title: 'No se pudo cargar el catalogo',
        subtitle: 'Haz refresh para intentar de nuevo.',
      );
    }

    if (rewards.isEmpty) {
      return const _EmptyStateCard(
        title: 'No hay recompensas activas',
        subtitle: 'Cuando el catalogo este listo, aparecera aqui.',
      );
    }

    return SizedBox(
      height: 310,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: rewards.length,
        separatorBuilder: (_, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final reward = rewards[index];
          final canRedeem = currentPoints >= reward.pointsCost;
          final isRedeeming =
              redeemState.isLoading && redeemState.rewardId == reward.id;

          return Container(
            width: 254,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: LinearGradient(
                colors: reward.isFeatured
                    ? [kWarmGold, kEditorialBlush]
                    : [palette.surface, palette.surfaceAlt],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: reward.isFeatured
                    ? kWarmGold.withValues(alpha: 0.25)
                    : palette.border,
              ),
              boxShadow: [
                BoxShadow(
                  color: (reward.isFeatured ? kWarmGold : palette.primaryGlow)
                      .withValues(alpha: 0.18),
                  blurRadius: 28,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        color: reward.isFeatured
                            ? palette.textPrimary.withValues(alpha: 0.08)
                            : palette.surfaceMuted,
                      ),
                      child: Text(
                        reward.rewardTypeLabel,
                        style: GoogleFonts.splineSans(
                          color: reward.isFeatured
                              ? kGraphiteWine
                              : palette.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Icon(switch (reward.rewardType) {
                      'bonus_credit' => Icons.bolt_rounded,
                      'event_coupon' => Icons.confirmation_number_rounded,
                      _ => Icons.card_giftcard_rounded,
                    }, color: reward.isFeatured ? kGraphiteWine : kWarmGold),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  reward.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.splineSans(
                    color: reward.isFeatured
                        ? kGraphiteWine
                        : palette.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  reward.description?.trim().isNotEmpty == true
                      ? reward.description!
                      : 'Canjea esta recompensa dentro del ecosistema Duty.',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.splineSans(
                    color: reward.isFeatured
                        ? kGraphiteWine.withValues(alpha: 0.78)
                        : palette.textSecondary,
                    fontSize: 13,
                    height: 1,
                  ),
                ),
                const Spacer(),
                Text(
                  '${_points(reward.pointsCost)} pts',
                  style: GoogleFonts.splineSans(
                    color: reward.isFeatured
                        ? kGraphiteWine
                        : palette.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (reward.rewardType == 'bonus_credit' &&
                    reward.bonusAmount > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Acredita RD\$${reward.bonusAmount.toStringAsFixed(2)} al bono interno',
                          style: GoogleFonts.splineSans(
                            color: reward.isFeatured
                                ? kGraphiteWine.withValues(alpha: 0.78)
                                : palette.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        if (reward.bonusExpiresInDays != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              'Expira ${reward.bonusExpiresInDays} dias despues del canje',
                              style: GoogleFonts.splineSans(
                                color: reward.isFeatured
                                    ? kGraphiteWine.withValues(alpha: 0.72)
                                    : palette.textMuted,
                                fontSize: 11,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                if (reward.rewardType == 'event_coupon')
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      _eventCouponDescription(reward),
                      style: GoogleFonts.splineSans(
                        color: reward.isFeatured
                            ? kGraphiteWine.withValues(alpha: 0.78)
                            : palette.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                const SizedBox(height: 0),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: (!canRedeem || isRedeeming)
                        ? null
                        : () => onRedeem(reward),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: reward.isFeatured
                          ? kGraphiteWine
                          : palette.primary,
                      foregroundColor: reward.isFeatured
                          ? palette.onPrimary
                          : palette.onPrimary,
                      disabledBackgroundColor: palette.surfaceMuted,
                      disabledForegroundColor: palette.textMuted,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: isRedeeming
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            canRedeem
                                ? 'Canjear ahora'
                                : 'Te faltan ${_points(reward.pointsCost - currentPoints)}',
                            style: GoogleFonts.splineSans(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _HistoryPanel extends StatelessWidget {
  final List<LoyaltyHistoryItemModel> items;
  final bool isLoading;
  final bool hasError;

  const _HistoryPanel({
    required this.items,
    required this.isLoading,
    required this.hasError,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.dutyTheme;
    if (isLoading && items.isEmpty) {
      return const _PanelLoader();
    }
    if (hasError && items.isEmpty) {
      return const _EmptyStateCard(
        title: 'No se pudo cargar la actividad',
        subtitle:
            'El resumen puede estar bien aunque este bloque falle temporalmente.',
      );
    }
    if (items.isEmpty) {
      return const _EmptyStateCard(
        title: 'Todavia no hay actividad',
        subtitle:
            'Tus puntos apareceran aqui a medida que compres o generes interacciones premiadas.',
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: palette.surface,
        border: Border.all(color: palette.border),
      ),
      child: Column(
        children: items
            .take(8)
            .map((item) => _HistoryItemTile(item: item))
            .toList(),
      ),
    );
  }
}

class _HistoryItemTile extends StatelessWidget {
  final LoyaltyHistoryItemModel item;

  const _HistoryItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final palette = context.dutyTheme;
    final accent = item.isCredit ? palette.success : kDustRose;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: accent.withValues(alpha: 0.12),
            ),
            child: Icon(
              item.isCredit
                  ? Icons.north_east_rounded
                  : Icons.south_east_rounded,
              color: accent,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: GoogleFonts.splineSans(
                    color: palette.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if ((item.subtitle ?? '').isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    item.subtitle!,
                    style: GoogleFonts.splineSans(
                      color: palette.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
                if (item.createdAt != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    DateFormat(
                      'd MMM, h:mm a',
                    ).format(item.createdAt!.toLocal()),
                    style: GoogleFonts.splineSans(
                      color: palette.textMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${item.isCredit ? '+' : '-'}${_points(item.points)}',
                style: GoogleFonts.splineSans(
                  color: accent,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Saldo ${_points(item.balanceAfter)}',
                style: GoogleFonts.splineSans(
                  color: palette.textMuted,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RedemptionsPanel extends StatelessWidget {
  final List<LoyaltyRedemptionModel> items;
  final bool isLoading;
  final bool hasError;

  const _RedemptionsPanel({
    required this.items,
    required this.isLoading,
    required this.hasError,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.dutyTheme;
    if (isLoading && items.isEmpty) {
      return const _PanelLoader();
    }
    if (hasError && items.isEmpty) {
      return const _EmptyStateCard(
        title: 'No se pudo leer el historial de canjes',
        subtitle: 'Haz refresh para sincronizar el panel.',
      );
    }
    if (items.isEmpty) {
      return const _EmptyStateCard(
        title: 'Aun no has reclamado recompensas',
        subtitle:
            'Cuando canjees puntos, aqui veras estado y fecha de cumplimiento.',
      );
    }

    return Column(
      children: items.take(5).map((item) {
        final accent = item.isCompleted ? palette.success : kWarmGold;
        final code = item.claimCode;
        final instructions = item.instructions;
        final expiry = item.expiresAt;
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            color: palette.surface,
            border: Border.all(color: palette.border),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accent.withValues(alpha: 0.14),
                ),
                child: Icon(Icons.local_activity_rounded, color: accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: GoogleFonts.splineSans(
                        color: palette.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${item.statusLabel} - ${_points(item.pointsCost)} pts',
                      style: GoogleFonts.splineSans(
                        color: palette.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    if (code != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          color: accent.withValues(alpha: 0.14),
                        ),
                        child: Text(
                          code,
                          style: GoogleFonts.jetBrainsMono(
                            color: accent,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                    if (item.rewardType == 'bonus_credit' &&
                        item.bonusAmount > 0) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Bono acreditado: RD\$${item.bonusAmount.toStringAsFixed(2)}',
                        style: GoogleFonts.splineSans(
                          color: palette.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                    if (instructions != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        instructions,
                        style: GoogleFonts.splineSans(
                          color: palette.textSecondary,
                          fontSize: 12,
                          height: 1.35,
                        ),
                      ),
                    ],
                    if (expiry != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Expira ${DateFormat('d MMM yyyy').format(expiry.toLocal())}',
                        style: GoogleFonts.splineSans(
                          color: palette.textMuted,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Text(
                DateFormat('d MMM').format(
                  (item.fulfilledAt ?? item.createdAt ?? DateTime.now())
                      .toLocal(),
                ),
                style: GoogleFonts.splineSans(
                  color: palette.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

String _eventCouponDescription(LoyaltyRewardModel reward) {
  final couponValue = _toDouble(reward.meta['coupon_value']);
  final couponType = reward.meta['coupon_type']?.toString() ?? 'fixed';

  if (couponValue <= 0) {
    return 'Genera un codigo de descuento usable en checkout.';
  }

  if (couponType == 'percentage' || couponType == 'percent') {
    return 'Genera un codigo de ${couponValue.toStringAsFixed(0)}% para checkout.';
  }

  return 'Genera un codigo por RD\$${couponValue.toStringAsFixed(2)} para checkout.';
}

double _toDouble(dynamic value) {
  if (value is double) return value;
  if (value is int) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

class _PanelLoader extends StatelessWidget {
  const _PanelLoader();

  @override
  Widget build(BuildContext context) {
    final palette = context.dutyTheme;
    return Container(
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: palette.surface,
      ),
      child: Center(child: CircularProgressIndicator(color: palette.primary)),
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  final String title;
  final String subtitle;

  const _EmptyStateCard({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final palette = context.dutyTheme;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: palette.surface,
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
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: GoogleFonts.splineSans(
              color: palette.textSecondary,
              fontSize: 13,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

String _points(int value) => NumberFormat.decimalPattern().format(value);
