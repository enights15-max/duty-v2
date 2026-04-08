import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/providers/profile_state_provider.dart';
import '../../../../core/theme/colors.dart';
import '../../../profile/domain/models/profile_model.dart';
import '../../data/models/professional_event_summary_model.dart';
import '../providers/professional_event_provider.dart';

class ProfessionalEventsManagePage extends ConsumerStatefulWidget {
  const ProfessionalEventsManagePage({super.key});

  @override
  ConsumerState<ProfessionalEventsManagePage> createState() =>
      _ProfessionalEventsManagePageState();
}

class _ProfessionalEventsManagePageState
    extends ConsumerState<ProfessionalEventsManagePage> {
  bool _isLoading = true;
  List<ProfessionalEventSummaryModel> _events = const [];
  String? _error;
  final Set<int> _claimingEventIds = <int>{};

  AppProfile? get _activeProfile => ref.read(activeProfileProvider);
  DutyThemeTokens get _palette => context.dutyTheme;

  bool get _canManageEvents {
    final profile = _activeProfile;
    if (profile == null || !profile.isActive) {
      return false;
    }

    return profile.type == ProfileType.organizer ||
        profile.type == ProfileType.venue ||
        profile.type == ProfileType.artist;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadEvents();
    });
  }

  Future<void> _loadEvents() async {
    if (!_canManageEvents) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _events = const [];
        _error = null;
      });
      return;
    }

    if (mounted) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final events = await ref
          .read(professionalEventRepositoryProvider)
          .getEvents();
      if (!mounted) return;
      setState(() {
        _events = events;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = error.toString();
      });
    }
  }

  Future<void> _claimTreasuryForEvent(
    ProfessionalEventSummaryModel event,
  ) async {
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
      await _loadEvents();

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
          content: Text(
            'No pudimos reclamar los fondos de este evento.\n$error',
          ),
          backgroundColor: _palette.danger,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _claimingEventIds.remove(event.id));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = _palette;
    final activeProfile = ref.watch(activeProfileProvider);

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: Text(
          'Mis eventos',
          style: GoogleFonts.splineSans(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            tooltip: 'Recargar',
            onPressed: _isLoading ? null : _loadEvents,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      floatingActionButton: _canManageEvents
          ? FloatingActionButton.extended(
              onPressed: () => context.push('/professional/events/create'),
              backgroundColor: palette.primary,
              foregroundColor: palette.onPrimary,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Crear'),
            )
          : null,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : !_canManageEvents
          ? _buildBlockedState(activeProfile)
          : RefreshIndicator(
              onRefresh: _loadEvents,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                children: [
                  _buildIntroCard(activeProfile!),
                  const SizedBox(height: 16),
                  if (_error != null) _buildErrorCard(),
                  if (_events.isEmpty && _error == null) _buildEmptyState(),
                  ..._events.map(_buildEventCard),
                ],
              ),
            ),
    );
  }

  Widget _buildBlockedState(AppProfile? activeProfile) {
    final palette = _palette;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: palette.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: palette.border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.lock_outline_rounded,
                size: 48,
                color: palette.textSecondary,
              ),
              const SizedBox(height: 12),
              Text(
                'Acceso profesional requerido',
                style: GoogleFonts.splineSans(
                  color: palette.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                activeProfile == null
                    ? 'Activa una identidad aprobada de organizador o venue desde el centro de cuentas.'
                    : 'Tu perfil activo actual no puede administrar eventos desde esta herramienta.',
                textAlign: TextAlign.center,
                style: GoogleFonts.splineSans(color: palette.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIntroCard(AppProfile activeProfile) {
    final palette = _palette;
    final isVenue = activeProfile.type == ProfileType.venue;
    final isArtist = activeProfile.type == ProfileType.artist;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: [
            palette.primaryGlow.withValues(alpha: 0.18),
            palette.heroGradientStart,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: palette.primary.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            activeProfile.name,
            style: GoogleFonts.splineSans(
              color: palette.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isVenue
                ? 'Gestiona la agenda de tu venue, revisa eventos asociados y entra al editor móvil cuando el formato actual sea compatible.'
                : isArtist
                    ? 'Revisa los eventos donde participas, gestiona tu inventario y entra al editor móvil cuando sea compatible.'
                    : 'Administra tus eventos publicados y entra al editor móvil cuando el formato actual sea compatible.',
            style: GoogleFonts.splineSans(
              color: palette.textSecondary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard() {
    final palette = _palette;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: palette.danger.withValues(alpha: 0.12),
        border: Border.all(color: palette.danger.withValues(alpha: 0.3)),
      ),
      child: Text(
        'No se pudo cargar el listado de eventos.',
        style: GoogleFonts.splineSans(color: palette.textPrimary),
      ),
    );
  }

  Widget _buildEmptyState() {
    final palette = _palette;
    final isVenue = _activeProfile?.type == ProfileType.venue;
    final isArtist = _activeProfile?.type == ProfileType.artist;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: palette.surface,
        border: Border.all(color: palette.border),
      ),
      child: Column(
        children: [
          Icon(Icons.event_busy_outlined, color: palette.textMuted, size: 42),
          const SizedBox(height: 10),
          Text(
            isVenue
                ? 'Todavía no hay eventos asociados a este venue.'
                : isArtist
                    ? 'Todavía no hay eventos donde participes como artista.'
                    : 'Todavía no hay eventos asociados a este perfil.',
            textAlign: TextAlign.center,
            style: GoogleFonts.splineSans(color: palette.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(ProfessionalEventSummaryModel event) {
    final palette = _palette;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: palette.surface,
        border: Border.all(color: palette.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildThumbnail(event.thumbnailUrl),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildTag(event.statusLabel, palette.primary),
                    _buildTag(
                      event.mobileAuthoringSupported
                          ? 'Editable móvil'
                          : 'Solo lectura',
                      event.mobileAuthoringSupported
                          ? palette.success
                          : palette.warning,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  event.title,
                  style: GoogleFonts.splineSans(
                    color: palette.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _eventMeta(event),
                  style: GoogleFonts.splineSans(
                    color: palette.textSecondary,
                    fontSize: 12,
                  ),
                ),
                if (event.managementLabel != null ||
                    event.shouldShowHostingVenueContext) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (event.managementLabel != null)
                        _buildMetaPill(
                          event.managementLabel!,
                          palette.textSecondary,
                        ),
                      if (event.shouldShowHostingVenueContext &&
                          event.hostingVenueLabel != null)
                        _buildMetaPill(event.hostingVenueLabel!, palette.info),
                    ],
                  ),
                ],
                if (event.treasurySummary != null &&
                    (event.canClaimTreasuryNow ||
                        (event.treasurySummary!.availableForSettlement > 0 &&
                            event.treasurySummary!.status !=
                                'collecting'))) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildMetaPill(
                        event.treasurySummary!.statusLabel,
                        event.canClaimTreasuryNow
                            ? palette.success
                            : palette.warning,
                      ),
                      if (event.claimableAmountLabel != null)
                        _buildMetaPill(
                          'Disponible ${event.claimableAmountLabel!}',
                          palette.success,
                        ),
                    ],
                  ),
                ],
                if (!event.mobileAuthoringSupported &&
                    event.mobileAuthoringReason != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    event.mobileAuthoringReason!,
                    style: GoogleFonts.splineSans(
                      color: palette.textMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
                if (event.reviewNotes != null &&
                    event.reviewNotes!.trim().isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: palette.surfaceAlt,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: palette.border),
                    ),
                    child: Text(
                      event.reviewNotes!.trim(),
                      style: GoogleFonts.splineSans(
                        color: palette.textSecondary,
                        fontSize: 11,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    OutlinedButton(
                      onPressed: () =>
                          context.push('/event-details/${event.id}'),
                      child: const Text('Ver evento'),
                    ),
                    OutlinedButton(
                      onPressed: () => context.push(
                        '/professional/events/${event.id}/inventory',
                      ),
                      child: Text(
                        event.canClaimTreasuryNow
                            ? 'Liquidación'
                            : 'Inventario',
                      ),
                    ),
                    if (event.canClaimTreasuryNow)
                      FilledButton(
                        onPressed: _claimingEventIds.contains(event.id)
                            ? null
                            : () => _claimTreasuryForEvent(event),
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
                    FilledButton(
                      onPressed: event.mobileAuthoringSupported
                          ? () => context.push(
                              '/professional/events/${event.id}/edit',
                            )
                          : null,
                      style: FilledButton.styleFrom(
                        backgroundColor: palette.primary,
                        foregroundColor: palette.onPrimary,
                      ),
                      child: const Text('Editar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThumbnail(String? url) {
    final palette = _palette;
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 82,
        height: 82,
        color: palette.surfaceAlt,
        child: url == null || url.isEmpty
            ? Icon(Icons.image_not_supported_outlined, color: palette.textMuted)
            : Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Icon(Icons.broken_image_outlined, color: palette.textMuted),
              ),
      ),
    );
  }

  Widget _buildTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: color.withValues(alpha: 0.16),
      ),
      child: Text(
        label,
        style: GoogleFonts.splineSans(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildMetaPill(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: color.withValues(alpha: 0.08),
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

  String _eventMeta(ProfessionalEventSummaryModel event) {
    final dateBits = <String>[
      if (event.startDate != null && event.startDate!.isNotEmpty)
        event.startDate!,
      if (event.startTime != null && event.startTime!.isNotEmpty)
        event.startTime!,
    ];
    final placeBits = <String>[
      if (event.venueName != null && event.venueName!.isNotEmpty)
        event.venueName!,
      if (event.venueCity != null && event.venueCity!.isNotEmpty)
        event.venueCity!,
    ];

    return [
      if (dateBits.isNotEmpty) dateBits.join(' · '),
      if (placeBits.isNotEmpty) placeBits.join(' · '),
    ].join('\n');
  }
}
