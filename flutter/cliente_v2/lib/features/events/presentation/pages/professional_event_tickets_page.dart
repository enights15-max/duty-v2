import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/colors.dart';
import '../../data/models/professional_event_ticket_model.dart';
import '../providers/professional_event_provider.dart';

class ProfessionalEventTicketsPage extends ConsumerStatefulWidget {
  final int eventId;

  const ProfessionalEventTicketsPage({super.key, required this.eventId});

  @override
  ConsumerState<ProfessionalEventTicketsPage> createState() =>
      _ProfessionalEventTicketsPageState();
}

class _ProfessionalEventTicketsPageState
    extends ConsumerState<ProfessionalEventTicketsPage> {
  bool _mutating = false;
  DutyThemeTokens get _palette => context.dutyTheme;

  Future<void> _refreshAll() async {
    ref.invalidate(professionalEventTicketsProvider(widget.eventId));
    ref.invalidate(professionalEventInventoryProvider(widget.eventId));
    ref.invalidate(professionalDashboardProvider);
    ref.invalidate(professionalDashboardRangeProvider);
    await ref.read(professionalEventTicketsProvider(widget.eventId).future);
  }

  Future<void> _openEditor({
    required ProfessionalEventTicketsPayload payload,
    ProfessionalManagedTicket? ticket,
  }) async {
    final draft = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _TicketEditorSheet(
            eventTitle: payload.event.title,
            ticket: ticket,
            siblingTickets: payload.tickets
                .where((t) => t.id != (ticket?.id ?? -1))
                .toList(),
          ),
    );

    if (!mounted || draft == null) {
      return;
    }

    setState(() => _mutating = true);
    try {
      final repository = ref.read(professionalEventRepositoryProvider);
      if (ticket == null) {
        await repository.createTicket(widget.eventId, draft);
      } else {
        await repository.updateTicket(widget.eventId, ticket.id, draft);
      }

      await _refreshAll();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ticket == null
                ? 'Ticket creado correctamente.'
                : 'Ticket actualizado correctamente.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_humanizeError(error))));
    } finally {
      if (mounted) {
        setState(() => _mutating = false);
      }
    }
  }

  Future<void> _duplicateTicket(ProfessionalManagedTicket ticket) async {
    setState(() => _mutating = true);
    try {
      await ref
          .read(professionalEventRepositoryProvider)
          .duplicateTicket(widget.eventId, ticket.id);
      await _refreshAll();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ticket duplicado y dejado en pausa.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_humanizeError(error))));
    } finally {
      if (mounted) {
        setState(() => _mutating = false);
      }
    }
  }

  Future<void> _updateStatus(
    ProfessionalManagedTicket ticket,
    String status,
  ) async {
    if (status == 'archived') {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: context.dutyTheme.surface,
          title: Text(
            'Archivar ticket',
            style: GoogleFonts.outfit(color: context.dutyTheme.textPrimary),
          ),
          content: Text(
            'El ticket dejará de estar disponible para la venta desde la app. Si ya tuvo ventas o reservas seguirá existiendo en historial.',
            style: GoogleFonts.splineSans(
              color: context.dutyTheme.textSecondary,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Archivar'),
            ),
          ],
        ),
      );

      if (confirmed != true) {
        return;
      }
    }

    setState(() => _mutating = true);
    try {
      await ref
          .read(professionalEventRepositoryProvider)
          .updateTicketStatus(widget.eventId, ticket.id, status);
      await _refreshAll();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Estado actualizado a ${_statusLabel(status)}.'),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_humanizeError(error))));
    } finally {
      if (mounted) {
        setState(() => _mutating = false);
      }
    }
  }

  Future<void> _issueManualTicket(ProfessionalManagedTicket ticket) async {
    final draft = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ManualIssueSheet(ticket: ticket),
    );

    if (!mounted || draft == null) {
      return;
    }

    setState(() => _mutating = true);
    try {
      final repository = ref.read(professionalEventRepositoryProvider);
      await repository.issueManualTicket(widget.eventId, ticket.id, draft);
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tickets emitidos exitosamente al invitado.')),
      );
      await _refreshAll();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_humanizeError(error))));
    } finally {
      if (mounted) {
        setState(() => _mutating = false);
      }
    }
  }

  String _humanizeError(Object error) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map) {
        final message = data['message']?.toString();
        final errors = data['errors'];
        if (errors is Map && errors.isNotEmpty) {
          final first = errors.values.first;
          if (first is List && first.isNotEmpty) {
            return first.first.toString();
          }
        }
        if (message != null && message.trim().isNotEmpty) {
          return message;
        }
      }
      if (error.type == DioExceptionType.connectionError ||
          error.type == DioExceptionType.connectionTimeout) {
        return 'No pudimos guardar el ticket por un problema de conexión.';
      }
    }

    return 'No pudimos actualizar el ticket ahora mismo.';
  }

  @override
  Widget build(BuildContext context) {
    final palette = _palette;
    final asyncPayload = ref.watch(
      professionalEventTicketsProvider(widget.eventId),
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
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: Text(
          'Gestionar tickets',
          style: GoogleFonts.outfit(
            color: palette.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Stack(
        children: [
          asyncPayload.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'No pudimos cargar los tickets de este evento.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        color: palette.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _humanizeError(error),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.splineSans(
                        color: palette.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            data: (payload) => RefreshIndicator(
              onRefresh: _refreshAll,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                children: [
                  _buildHero(payload),
                  const SizedBox(height: 18),
                  _buildLaunchRow(payload),
                  const SizedBox(height: 20),
                  if (payload.tickets.isEmpty)
                    _buildEmptyState(payload)
                  else
                    ...payload.tickets.map(
                      (ticket) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _buildTicketCard(payload, ticket),
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (_mutating)
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  color: palette.shadow.withValues(alpha: 0.18),
                  child: const Center(child: CircularProgressIndicator()),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: asyncPayload.value == null
          ? null
          : FloatingActionButton.extended(
              backgroundColor: palette.primary,
              foregroundColor: palette.onPrimary,
              onPressed: _mutating
                  ? null
                  : () => _openEditor(payload: asyncPayload.requireValue),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Agregar ticket'),
            ),
    );
  }

  Widget _buildHero(ProfessionalEventTicketsPayload payload) {
    final palette = _palette;
    final event = payload.event;
    final activeCount = payload.tickets
        .where((ticket) => ticket.saleStatus == 'active')
        .length;
    final archivedCount = payload.tickets
        .where((ticket) => ticket.saleStatus == 'archived')
        .length;

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
            payload.event.title,
            style: GoogleFonts.outfit(
              color: palette.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Administra precios, inventario, reservas y estados de venta desde móvil para este ${event.eventType == 'venue' ? 'evento presencial' : 'evento'}.',
            style: GoogleFonts.splineSans(
              color: palette.textSecondary,
              height: 1.5,
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
                  _heroMetaPill(event.managementLabel!, palette.textSecondary),
                if (event.shouldShowHostingVenueContext &&
                    (event.hostingVenueName?.trim().isNotEmpty ?? false))
                  _heroMetaPill(
                    'Venue anfitrión: ${event.hostingVenueName!.trim()}',
                    palette.info,
                  ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _heroFact('Tickets', '${payload.tickets.length}'),
              _heroFact('Activos', '$activeCount'),
              _heroFact('Archivados', '$archivedCount'),
              _heroFact(
                'Revisión',
                _reviewStatusLabel(payload.event.reviewStatus),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroFact(String label, String value) {
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

  Widget _heroMetaPill(String label, Color color) {
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

  Widget _buildLaunchRow(ProfessionalEventTicketsPayload payload) {
    final palette = _palette;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: palette.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Usa esta bandeja para crear tickets simples, escalones de precio, variaciones y reservas sin tocar la ficha principal del evento.',
              style: GoogleFonts.splineSans(
                color: palette.textSecondary,
                height: 1.45,
              ),
            ),
          ),
          const SizedBox(width: 12),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: palette.textPrimary,
              side: BorderSide(color: palette.borderStrong),
            ),
            onPressed: _mutating
                ? null
                : () => context.push(
                    '/professional/events/${widget.eventId}/collaborators',
                  ),
            icon: const Icon(Icons.groups_rounded),
            label: const Text('Splits'),
          ),
          const SizedBox(width: 10),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: palette.primarySurface,
              foregroundColor: palette.textPrimary,
              side: BorderSide(color: palette.primary.withValues(alpha: 0.30)),
            ),
            onPressed: _mutating ? null : () => _openEditor(payload: payload),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Nuevo'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ProfessionalEventTicketsPayload payload) {
    final palette = _palette;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: palette.primarySurface,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Icon(
              Icons.local_activity_rounded,
              color: palette.primary,
              size: 34,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Todavía no hay tickets configurados',
            style: GoogleFonts.outfit(
              color: palette.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Agrega el primer ticket para abrir la preventa desde móvil. Puedes empezar con uno simple y luego duplicarlo o convertirlo en escalones.',
            textAlign: TextAlign.center,
            style: GoogleFonts.splineSans(
              color: palette.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: _mutating ? null : () => _openEditor(payload: payload),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Crear primer ticket'),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketCard(
    ProfessionalEventTicketsPayload payload,
    ProfessionalManagedTicket ticket,
  ) {
    final palette = _palette;
    final analytics = ticket.analytics;
    final priceLine = ticket.pricingType == 'variation'
        ? '${ticket.variations.length} variaciones'
        : 'RD\$${ticket.currentPrice.toStringAsFixed(2)}';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: _statusColor(ticket.saleStatus).withValues(alpha: 0.32),
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
                      ticket.title,
                      style: GoogleFonts.outfit(
                        color: palette.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$priceLine · ${_pricingTypeLabel(ticket.pricingType)}',
                      style: GoogleFonts.splineSans(
                        color: palette.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _statusChip(ticket.saleStatus),
                  if (ticket.isGated)
                    _gateChip(ticket, payload.tickets),
                ],
              ),
              PopupMenuButton<String>(
                color: palette.surfaceAlt,
                iconColor: palette.textSecondary,
                onSelected: (value) async {
                  switch (value) {
                    case 'edit':
                      await _openEditor(payload: payload, ticket: ticket);
                      break;
                    case 'manual_issue':
                      await _issueManualTicket(ticket);
                      break;
                    case 'duplicate':
                      await _duplicateTicket(ticket);
                      break;
                    case 'active':
                    case 'paused':
                    case 'hidden':
                    case 'archived':
                      await _updateStatus(ticket, value);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  if (ticket.mobileEditingSupported)
                    const PopupMenuItem(value: 'edit', child: Text('Editar')),
                  const PopupMenuItem(
                    value: 'manual_issue',
                    child: Text('Añadir a Guestlist'),
                  ),
                  const PopupMenuItem(
                    value: 'duplicate',
                    child: Text('Duplicar'),
                  ),
                  if (ticket.saleStatus != 'active')
                    const PopupMenuItem(
                      value: 'active',
                      child: Text('Activar venta'),
                    ),
                  if (ticket.saleStatus != 'paused')
                    const PopupMenuItem(
                      value: 'paused',
                      child: Text('Pausar venta'),
                    ),
                  if (ticket.saleStatus != 'hidden')
                    const PopupMenuItem(
                      value: 'hidden',
                      child: Text('Ocultar'),
                    ),
                  if (ticket.saleStatus != 'archived')
                    const PopupMenuItem(
                      value: 'archived',
                      child: Text('Archivar'),
                    ),
                ],
              ),
            ],
          ),
          if ((ticket.description ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              ticket.description!.trim(),
              style: GoogleFonts.splineSans(
                color: palette.textSecondary,
                height: 1.5,
              ),
            ),
          ],
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _factChip(
                'Disponibles',
                analytics.available?.toString() ?? 'Abierto',
              ),
              _factChip('Vendidas', '${analytics.sold}'),
              _factChip('Reservadas', '${analytics.reserved}'),
              _factChip(
                'Sell-through',
                analytics.sellThroughPercent == null
                    ? '--'
                    : '${analytics.sellThroughPercent!.toStringAsFixed(1)}%',
              ),
              if (ticket.maxBuyTicket != null)
                _factChip('Límite x usuario', '${ticket.maxBuyTicket}'),
              if (ticket.reservationEnabled) _factChip('Reservas', 'Sí'),
              if (ticket.priceSchedules.isNotEmpty)
                _factChip('Escalones', '${ticket.priceSchedules.length}'),
              if (ticket.variations.isNotEmpty)
                _factChip('Variaciones', '${ticket.variations.length}'),
            ],
          ),
          if (ticket.nextSchedule != null) ...[
            const SizedBox(height: 14),
            _softBanner(
              icon: Icons.schedule_rounded,
              color: palette.info,
              text:
                  'Próximo cambio: ${ticket.nextSchedule!.label ?? 'Price update'} · RD\$${ticket.nextSchedule!.price.toStringAsFixed(2)} · ${_formatDateTime(ticket.nextSchedule!.effectiveFrom)}',
            ),
          ],
          if (!ticket.mobileEditingSupported &&
              (ticket.mobileEditingReason ?? '').isNotEmpty) ...[
            const SizedBox(height: 14),
            _softBanner(
              icon: Icons.info_outline_rounded,
              color: palette.warning,
              text: ticket.mobileEditingReason!,
            ),
          ],
          if (ticket.variations.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              'Variaciones',
              style: GoogleFonts.outfit(
                color: palette.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            ...ticket.variations
                .take(3)
                .map(
                  (variation) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: palette.surfaceAlt,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: palette.border),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  variation.name,
                                  style: GoogleFonts.outfit(
                                    color: palette.textPrimary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'RD\$${variation.price.toStringAsFixed(2)} · vendidas ${variation.sold}',
                                  style: GoogleFonts.splineSans(
                                    color: palette.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            variation.ticketAvailable?.toString() ?? 'Abierto',
                            style: GoogleFonts.outfit(
                              color: palette.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            if (ticket.variations.length > 3)
              Text(
                '+${ticket.variations.length - 3} variaciones más dentro del editor',
                style: GoogleFonts.splineSans(
                  color: palette.textMuted,
                  fontSize: 12,
                ),
              ),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: ticket.mobileEditingSupported && !_mutating
                      ? () => _openEditor(payload: payload, ticket: ticket)
                      : null,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: palette.borderStrong),
                    foregroundColor: palette.textPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.edit_rounded),
                  label: const Text('Editar'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _mutating ? null : () => _duplicateTicket(ticket),
                  style: FilledButton.styleFrom(
                    backgroundColor: palette.surfaceAlt,
                    foregroundColor: palette.textPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.copy_rounded),
                  label: const Text('Duplicar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _factChip(String label, String value) {
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

  Widget _softBanner({
    required IconData icon,
    required Color color,
    required String text,
  }) {
    final palette = _palette;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.20)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.splineSans(
                color: palette.textSecondary,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TicketEditorSheet extends StatefulWidget {
  final String eventTitle;
  final ProfessionalManagedTicket? ticket;
  final List<ProfessionalManagedTicket> siblingTickets;

  const _TicketEditorSheet({
    required this.eventTitle,
    this.ticket,
    this.siblingTickets = const [],
  });

  @override
  State<_TicketEditorSheet> createState() => _TicketEditorSheetState();
}

class _TicketEditorSheetState extends State<_TicketEditorSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late final TextEditingController _availableController;
  late final TextEditingController _maxController;
  late final TextEditingController _earlyBirdAmountController;
  late final TextEditingController _reservationDepositController;
  late final TextEditingController _reservationInstallmentController;

  late String _pricingType;
  late String _ticketAvailableType;
  late String _maxTicketBuyType;
  late String _saleStatus;
  late bool _reservationEnabled;
  late bool _earlyBirdEnabled;
  late String _discountType;
  late String _reservationDepositType;
  DateTime? _earlyBirdEndsAt;
  DateTime? _reservationDueDate;
  String? _inlineError;

  // Gate fields
  int? _gateTicketId;
  String _gateTrigger = 'sold_out';
  DateTime? _gateTriggerDate;

  late final List<_VariationDraft> _variations;
  late final List<_ScheduleDraft> _schedules;

  @override
  void initState() {
    super.initState();
    final ticket = widget.ticket;
    _titleController = TextEditingController(text: ticket?.title ?? '');
    _descriptionController = TextEditingController(
      text: ticket?.description ?? '',
    );
    _priceController = TextEditingController(
      text: ticket?.price?.toStringAsFixed(2) ?? '',
    );
    _availableController = TextEditingController(
      text: ticket?.ticketAvailable?.toString() ?? '',
    );
    _maxController = TextEditingController(
      text: ticket?.maxBuyTicket?.toString() ?? '',
    );
    _earlyBirdAmountController = TextEditingController(
      text: ticket?.earlyBirdDiscountAmount?.toStringAsFixed(2) ?? '',
    );
    _reservationDepositController = TextEditingController(
      text: ticket?.reservationDepositValue?.toStringAsFixed(2) ?? '',
    );
    _reservationInstallmentController = TextEditingController(
      text: ticket?.reservationMinInstallmentAmount?.toStringAsFixed(2) ?? '',
    );
    _pricingType = ticket?.pricingType ?? 'normal';
    _ticketAvailableType = ticket?.ticketAvailableType ?? 'limited';
    _maxTicketBuyType = ticket?.maxTicketBuyType ?? 'limited';
    _saleStatus = ticket?.saleStatus == 'archived'
        ? 'paused'
        : (ticket?.saleStatus ?? 'active');
    _reservationEnabled = ticket?.reservationEnabled ?? false;
    _earlyBirdEnabled = ticket?.earlyBirdDiscountType == 'enable';
    _discountType = ticket?.discountType ?? 'fixed';
    _reservationDepositType = ticket?.reservationDepositType ?? 'fixed';
    _earlyBirdEndsAt = _joinDateTime(
      ticket?.earlyBirdDiscountDate,
      ticket?.earlyBirdDiscountTime,
    );
    _reservationDueDate = ticket?.reservationFinalDueDate == null
        ? null
        : DateTime.tryParse(ticket!.reservationFinalDueDate!);
    _variations = (ticket?.variations ?? const [])
        .map((row) => _VariationDraft.fromTicket(row))
        .toList();
    _schedules = (ticket?.priceSchedules ?? const [])
        .map((row) => _ScheduleDraft.fromSchedule(row))
        .toList();

    if (_pricingType == 'variation' && _variations.isEmpty) {
      _variations.add(_VariationDraft());
    }

    // Gate fields
    _gateTicketId = ticket?.gateTicketId;
    _gateTrigger = ticket?.gateTrigger ?? 'sold_out';
    _gateTriggerDate = ticket?.gateTriggerDate == null
        ? null
        : DateTime.tryParse(ticket!.gateTriggerDate!);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _availableController.dispose();
    _maxController.dispose();
    _earlyBirdAmountController.dispose();
    _reservationDepositController.dispose();
    _reservationInstallmentController.dispose();
    for (final draft in _variations) {
      draft.dispose();
    }
    for (final draft in _schedules) {
      draft.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.dutyTheme;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: palette.backgroundAlt,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(
                        color: palette.textMuted.withValues(alpha: 0.45),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    widget.ticket == null ? 'Nuevo ticket' : 'Editar ticket',
                    style: GoogleFonts.outfit(
                      color: palette.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.eventTitle,
                    style: GoogleFonts.splineSans(
                      color: palette.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 18),
                  _sectionTitle('Base del ticket'),
                  const SizedBox(height: 12),
                  _textField(
                    controller: _titleController,
                    label: 'Nombre del ticket',
                    hint: 'General, VIP, Early entry...',
                    validator: (value) =>
                        (value == null || value.trim().isEmpty)
                        ? 'Escribe un nombre para el ticket.'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  _textField(
                    controller: _descriptionController,
                    label: 'Descripción breve',
                    hint: 'Qué incluye este ticket',
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  _dropdownField(
                    label: 'Tipo de pricing',
                    value: _pricingType,
                    items: const {
                      'free': 'Gratis',
                      'normal': 'Precio fijo',
                      'variation': 'Variaciones',
                    },
                    onChanged: (value) {
                      setState(() {
                        _pricingType = value;
                        if (_pricingType == 'variation' &&
                            _variations.isEmpty) {
                          _variations.add(_VariationDraft());
                        }
                        if (_pricingType == 'variation') {
                          _reservationEnabled = false;
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  _dropdownField(
                    label: 'Estado de venta',
                    value: _saleStatus,
                    items: const {
                      'active': 'Activo',
                      'paused': 'Pausado',
                      'hidden': 'Oculto',
                    },
                    onChanged: (value) => setState(() => _saleStatus = value),
                  ),
                  // --- Gate section ---
                  if (widget.siblingTickets.isNotEmpty) ...[
                    const SizedBox(height: 18),
                    _sectionTitle('Activación por fases (Gate)'),
                    const SizedBox(height: 8),
                    Text(
                      'Bloquea este ticket hasta que otro se agote o llegue una fecha.',
                      style: GoogleFonts.splineSans(
                        color: palette.textMuted,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _dropdownField(
                      label: 'Ticket puerta',
                      value: _gateTicketId?.toString() ?? 'none',
                      items: {
                        'none': 'Sin gate (venta inmediata)',
                        ...{
                          for (final sibling in widget.siblingTickets)
                            sibling.id.toString(): sibling.title,
                        },
                      },
                      onChanged: (value) => setState(() {
                        if (value == 'none') {
                          _gateTicketId = null;
                        } else {
                          _gateTicketId = int.tryParse(value);
                          if (_saleStatus == 'active') {
                            _saleStatus = 'paused';
                          }
                        }
                      }),
                    ),
                    if (_gateTicketId != null) ...[
                      const SizedBox(height: 12),
                      _dropdownField(
                        label: 'Condición de activación',
                        value: _gateTrigger,
                        items: const {
                          'sold_out': 'Cuando se agote el ticket puerta',
                          'date': 'En una fecha específica',
                          'manual': 'Solo manual',
                        },
                        onChanged: (value) =>
                            setState(() => _gateTrigger = value),
                      ),
                      if (_gateTrigger == 'date') ...[
                        const SizedBox(height: 12),
                        _dateTimeTile(
                          label: 'Fecha de activación',
                          value: _gateTriggerDate == null
                              ? 'Elegir fecha y hora'
                              : DateFormat('dd MMM yyyy · hh:mm a')
                                  .format(_gateTriggerDate!),
                          onTap: () async {
                            final next = await _pickDateTime(
                              context,
                              initial: _gateTriggerDate,
                            );
                            if (next != null) {
                              setState(() => _gateTriggerDate = next);
                            }
                          },
                        ),
                      ],
                    ],
                  ],
                  const SizedBox(height: 18),
                  _sectionTitle('Inventario y límite'),
                  const SizedBox(height: 12),
                  if (_pricingType != 'variation') ...[
                    _dropdownField(
                      label: 'Disponibilidad',
                      value: _ticketAvailableType,
                      items: const {
                        'limited': 'Inventario limitado',
                        'unlimited': 'Inventario abierto',
                      },
                      onChanged: (value) =>
                          setState(() => _ticketAvailableType = value),
                    ),
                    if (_ticketAvailableType == 'limited') ...[
                      const SizedBox(height: 12),
                      _textField(
                        controller: _availableController,
                        label: 'Boletas disponibles',
                        hint: '100',
                        keyboardType: TextInputType.number,
                        validator: (value) => _requirePositiveInt(
                          value,
                          'Define cuántas boletas quedan disponibles.',
                          allowZero: true,
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    _dropdownField(
                      label: 'Límite por usuario',
                      value: _maxTicketBuyType,
                      items: const {
                        'limited': 'Limitar por usuario',
                        'unlimited': 'Sin límite',
                      },
                      onChanged: (value) =>
                          setState(() => _maxTicketBuyType = value),
                    ),
                    if (_maxTicketBuyType == 'limited') ...[
                      const SizedBox(height: 12),
                      _textField(
                        controller: _maxController,
                        label: 'Máximo por usuario',
                        hint: '4',
                        keyboardType: TextInputType.number,
                        validator: (value) => _requirePositiveInt(
                          value,
                          'Define el límite por usuario.',
                        ),
                      ),
                    ],
                  ] else
                    _notice(
                      'Las variaciones manejan inventario y límite por usuario dentro de cada fila.',
                    ),
                  const SizedBox(height: 18),
                  _sectionTitle('Precio y venta'),
                  const SizedBox(height: 12),
                  if (_pricingType == 'normal')
                    _textField(
                      controller: _priceController,
                      label: 'Precio base',
                      hint: '500.00',
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (value) => _requireAmount(
                        value,
                        'Define el precio base.',
                        min: 0.01,
                      ),
                    ),
                  if (_pricingType == 'variation') ...[_variationSection()],
                  if (_pricingType == 'normal') ...[
                    const SizedBox(height: 16),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      value: _earlyBirdEnabled,
                      activeThumbColor: kPrimaryColor,
                      activeTrackColor: palette.primary.withValues(alpha: 0.45),
                      title: Text(
                        'Early bird',
                        style: GoogleFonts.outfit(
                          color: palette.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      subtitle: Text(
                        'Activa un descuento corto antes del cambio de precio.',
                        style: GoogleFonts.splineSans(
                          color: palette.textSecondary,
                        ),
                      ),
                      onChanged: (value) =>
                          setState(() => _earlyBirdEnabled = value),
                    ),
                    if (_earlyBirdEnabled) ...[
                      const SizedBox(height: 8),
                      _dropdownField(
                        label: 'Tipo de descuento',
                        value: _discountType,
                        items: const {
                          'fixed': 'Monto fijo',
                          'percentage': 'Porcentaje',
                        },
                        onChanged: (value) =>
                            setState(() => _discountType = value),
                      ),
                      const SizedBox(height: 12),
                      _textField(
                        controller: _earlyBirdAmountController,
                        label: _discountType == 'percentage'
                            ? 'Porcentaje'
                            : 'Monto de descuento',
                        hint: _discountType == 'percentage' ? '15' : '50.00',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: (value) => _requireAmount(
                          value,
                          'Define el descuento early bird.',
                          min: 0.01,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _dateTimeTile(
                        label: 'Early bird hasta',
                        value: _earlyBirdEndsAt == null
                            ? 'Elegir fecha y hora'
                            : DateFormat(
                                'dd MMM yyyy · hh:mm a',
                              ).format(_earlyBirdEndsAt!),
                        onTap: () async {
                          final next = await _pickDateTime(
                            context,
                            initial: _earlyBirdEndsAt,
                          );
                          if (next != null) {
                            setState(() => _earlyBirdEndsAt = next);
                          }
                        },
                      ),
                    ],
                    const SizedBox(height: 16),
                    _scheduleSection(),
                  ],
                  const SizedBox(height: 18),
                  _sectionTitle('Reservas'),
                  const SizedBox(height: 8),
                  if (_pricingType == 'variation')
                    _notice(
                      'Por ahora las reservas desde móvil están disponibles para tickets simples. Si necesitas una mezcla más avanzada por variación, sigue usando el panel web.',
                    )
                  else ...[
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      value: _reservationEnabled,
                      activeThumbColor: kPrimaryColor,
                      activeTrackColor: palette.primary.withValues(alpha: 0.45),
                      title: Text(
                        'Permitir reservas',
                        style: GoogleFonts.outfit(
                          color: palette.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      subtitle: Text(
                        'Permite apartar este ticket con depósito y fecha final de pago.',
                        style: GoogleFonts.splineSans(
                          color: palette.textSecondary,
                        ),
                      ),
                      onChanged: (value) =>
                          setState(() => _reservationEnabled = value),
                    ),
                    if (_reservationEnabled) ...[
                      const SizedBox(height: 12),
                      _dropdownField(
                        label: 'Depósito',
                        value: _reservationDepositType,
                        items: const {
                          'fixed': 'Monto fijo',
                          'percentage': 'Porcentaje',
                        },
                        onChanged: (value) =>
                            setState(() => _reservationDepositType = value),
                      ),
                      const SizedBox(height: 12),
                      _textField(
                        controller: _reservationDepositController,
                        label: _reservationDepositType == 'percentage'
                            ? 'Depósito %'
                            : 'Depósito',
                        hint: _reservationDepositType == 'percentage'
                            ? '20'
                            : '150.00',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: (value) => _requireAmount(
                          value,
                          'Define el depósito de reserva.',
                          min: 0.01,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _dateTile(
                        label: 'Fecha límite final',
                        value: _reservationDueDate == null
                            ? 'Elegir fecha'
                            : DateFormat(
                                'dd MMM yyyy',
                              ).format(_reservationDueDate!),
                        onTap: () async {
                          final next = await _pickDate(
                            context,
                            initial: _reservationDueDate,
                          );
                          if (next != null) {
                            setState(() => _reservationDueDate = next);
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      _textField(
                        controller: _reservationInstallmentController,
                        label: 'Mínimo por pago (opcional)',
                        hint: '100.00',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                    ],
                  ],
                  if ((_inlineError ?? '').isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: palette.danger.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: palette.danger.withValues(alpha: 0.24),
                        ),
                      ),
                      child: Text(
                        _inlineError!,
                        style: GoogleFonts.splineSans(
                          color: palette.textPrimary,
                          height: 1.45,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: palette.borderStrong),
                            foregroundColor: palette.textPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: const Text('Cancelar'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: _submit,
                          style: FilledButton.styleFrom(
                            backgroundColor: palette.primary,
                            foregroundColor: palette.onPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: Text(
                            widget.ticket == null
                                ? 'Crear ticket'
                                : 'Guardar cambios',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String label) {
    final palette = context.dutyTheme;
    return Text(
      label.toUpperCase(),
      style: GoogleFonts.outfit(
        color: palette.textSecondary,
        fontSize: 13,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _notice(String text) {
    final palette = context.dutyTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: palette.surfaceAlt.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.border),
      ),
      child: Text(
        text,
        style: GoogleFonts.splineSans(
          color: palette.textSecondary,
          height: 1.45,
        ),
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    final palette = context.dutyTheme;
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      style: GoogleFonts.splineSans(color: palette.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: palette.surfaceAlt,
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
          borderSide: BorderSide(color: palette.primary),
        ),
        labelStyle: GoogleFonts.splineSans(color: palette.textSecondary),
        hintStyle: GoogleFonts.splineSans(color: palette.textMuted),
      ),
    );
  }

  Widget _dropdownField({
    required String label,
    required String value,
    required Map<String, String> items,
    required ValueChanged<String> onChanged,
  }) {
    final palette = context.dutyTheme;
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: palette.surfaceAlt,
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
          borderSide: BorderSide(color: palette.primary),
        ),
        labelStyle: GoogleFonts.splineSans(color: palette.textSecondary),
      ),
      dropdownColor: palette.surface,
      style: GoogleFonts.splineSans(color: palette.textPrimary),
      items: items.entries
          .map(
            (entry) => DropdownMenuItem<String>(
              value: entry.key,
              child: Text(entry.value),
            ),
          )
          .toList(),
      onChanged: (next) {
        if (next != null) {
          onChanged(next);
        }
      },
    );
  }

  Widget _dateTile({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    final palette = context.dutyTheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: palette.surfaceAlt,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: palette.border),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_rounded,
              color: palette.textSecondary,
              size: 18,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.splineSans(
                      color: palette.textSecondary,
                      fontSize: 12,
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _dateTimeTile({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    final palette = context.dutyTheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: palette.surfaceAlt,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: palette.border),
        ),
        child: Row(
          children: [
            Icon(
              Icons.schedule_rounded,
              color: palette.textSecondary,
              size: 18,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.splineSans(
                      color: palette.textSecondary,
                      fontSize: 12,
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _variationSection() {
    final palette = context.dutyTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Variaciones',
          style: GoogleFonts.outfit(
            color: palette.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 10),
        ..._variations.asMap().entries.map((entry) {
          final index = entry.key;
          final variation = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: palette.surfaceAlt,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: palette.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Variación ${index + 1}',
                        style: GoogleFonts.outfit(
                          color: palette.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      if (_variations.length > 1)
                        IconButton(
                          onPressed: () {
                            setState(() {
                              variation.dispose();
                              _variations.removeAt(index);
                            });
                          },
                          icon: Icon(
                            Icons.delete_outline_rounded,
                            color: palette.textSecondary,
                          ),
                        ),
                    ],
                  ),
                  _textField(
                    controller: variation.nameController,
                    label: 'Nombre',
                    hint: 'VIP Standing',
                    validator: (value) =>
                        (value == null || value.trim().isEmpty)
                        ? 'Escribe el nombre de la variación.'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  _textField(
                    controller: variation.priceController,
                    label: 'Precio',
                    hint: '850.00',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (value) => _requireAmount(
                      value,
                      'Define el precio de la variación.',
                      min: 0,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _dropdownField(
                    label: 'Disponibilidad',
                    value: variation.ticketAvailableType,
                    items: const {
                      'limited': 'Inventario limitado',
                      'unlimited': 'Inventario abierto',
                    },
                    onChanged: (value) =>
                        setState(() => variation.ticketAvailableType = value),
                  ),
                  if (variation.ticketAvailableType == 'limited') ...[
                    const SizedBox(height: 12),
                    _textField(
                      controller: variation.availableController,
                      label: 'Boletas disponibles',
                      hint: '40',
                      keyboardType: TextInputType.number,
                      validator: (value) => _requirePositiveInt(
                        value,
                        'Define el inventario de la variación.',
                        allowZero: true,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  _dropdownField(
                    label: 'Límite por usuario',
                    value: variation.maxTicketBuyType,
                    items: const {
                      'limited': 'Limitar por usuario',
                      'unlimited': 'Sin límite',
                    },
                    onChanged: (value) =>
                        setState(() => variation.maxTicketBuyType = value),
                  ),
                  if (variation.maxTicketBuyType == 'limited') ...[
                    const SizedBox(height: 12),
                    _textField(
                      controller: variation.maxController,
                      label: 'Máximo por usuario',
                      hint: '2',
                      keyboardType: TextInputType.number,
                      validator: (value) => _requirePositiveInt(
                        value,
                        'Define el límite por usuario.',
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: () => setState(() => _variations.add(_VariationDraft())),
            style: OutlinedButton.styleFrom(
              foregroundColor: palette.textPrimary,
              side: BorderSide(color: palette.border),
            ),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Agregar variación'),
          ),
        ),
      ],
    );
  }

  Widget _scheduleSection() {
    final palette = context.dutyTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Escalones de precio',
          style: GoogleFonts.outfit(
            color: palette.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Úsalos para preventa, fases y cambios automáticos de precio.',
          style: GoogleFonts.splineSans(color: palette.textMuted, height: 1.45),
        ),
        const SizedBox(height: 12),
        if (_schedules.isEmpty)
          _notice(
            'Sin escalones aún. Si no agregas ninguno, el ticket usará solo el precio base.',
          )
        else
          ..._schedules.asMap().entries.map((entry) {
            final index = entry.key;
            final schedule = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: palette.surfaceAlt,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: palette.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Escalón ${index + 1}',
                          style: GoogleFonts.outfit(
                            color: palette.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Switch.adaptive(
                          value: schedule.isActive,
                          activeThumbColor: kPrimaryColor,
                          activeTrackColor: kPrimaryColor.withValues(
                            alpha: 0.45,
                          ),
                          onChanged: (value) =>
                              setState(() => schedule.isActive = value),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              schedule.dispose();
                              _schedules.removeAt(index);
                            });
                          },
                          icon: Icon(
                            Icons.delete_outline_rounded,
                            color: palette.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    _textField(
                      controller: schedule.labelController,
                      label: 'Label',
                      hint: 'Launch / Early bird / Door',
                    ),
                    const SizedBox(height: 12),
                    _dateTimeTile(
                      label: 'Desde',
                      value: schedule.effectiveFrom == null
                          ? 'Elegir fecha y hora'
                          : DateFormat(
                              'dd MMM yyyy · hh:mm a',
                            ).format(schedule.effectiveFrom!),
                      onTap: () async {
                        final next = await _pickDateTime(
                          context,
                          initial: schedule.effectiveFrom,
                        );
                        if (next != null) {
                          setState(() => schedule.effectiveFrom = next);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    _textField(
                      controller: schedule.priceController,
                      label: 'Precio',
                      hint: '650.00',
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (value) => _requireAmount(
                        value,
                        'Define el precio del escalón.',
                        min: 0.01,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: () => setState(() => _schedules.add(_ScheduleDraft())),
            style: OutlinedButton.styleFrom(
              foregroundColor: palette.textPrimary,
              side: BorderSide(color: palette.border),
            ),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Agregar escalón'),
          ),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() => _inlineError = null);

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_pricingType == 'variation' &&
        _variations.every(
          (variation) => variation.nameController.text.trim().isEmpty,
        )) {
      setState(() => _inlineError = 'Agrega al menos una variación válida.');
      return;
    }

    if (_earlyBirdEnabled && _earlyBirdEndsAt == null) {
      setState(() => _inlineError = 'Elige la fecha final del early bird.');
      return;
    }

    if (_reservationEnabled && _reservationDueDate == null) {
      setState(
        () => _inlineError = 'Elige la fecha límite final para reservas.',
      );
      return;
    }

    if (_schedules.any((schedule) => schedule.effectiveFrom == null)) {
      setState(
        () => _inlineError =
            'Cada escalón necesita una fecha y hora de activación.',
      );
      return;
    }

    Navigator.of(context).pop(_buildPayload());
  }

  Map<String, dynamic> _buildPayload() {
    final payload = <String, dynamic>{
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      'pricing_type': _pricingType,
      'sale_status': _saleStatus,
      'gate_ticket_id': _gateTicketId,
      'gate_trigger': _gateTicketId != null ? _gateTrigger : null,
      'gate_trigger_date': _gateTicketId != null && _gateTrigger == 'date' && _gateTriggerDate != null
          ? _gateTriggerDate!.toIso8601String()
          : null,
      'ticket_available_type': _pricingType == 'variation'
          ? 'limited'
          : _ticketAvailableType,
      'max_ticket_buy_type': _pricingType == 'variation'
          ? 'limited'
          : _maxTicketBuyType,
      'early_bird_discount_type': _earlyBirdEnabled ? 'enable' : 'disable',
      'discount_type': _discountType,
      'reservation_enabled': _pricingType == 'variation'
          ? false
          : _reservationEnabled,
    };

    if (_pricingType == 'normal') {
      payload['price'] = _parseAmount(_priceController.text);
    } else if (_pricingType == 'free') {
      payload['price'] = 0;
    } else {
      payload['variations'] = _variations
          .asMap()
          .entries
          .map((entry) => entry.value.toPayload(sortOrder: entry.key))
          .toList();
    }

    if (_pricingType != 'variation') {
      if (_ticketAvailableType == 'limited') {
        payload['ticket_available'] = int.parse(
          _availableController.text.trim(),
        );
      }
      if (_maxTicketBuyType == 'limited') {
        payload['max_buy_ticket'] = int.parse(_maxController.text.trim());
      }
    }

    if (_earlyBirdEnabled) {
      payload['early_bird_discount_amount'] = _parseAmount(
        _earlyBirdAmountController.text,
      );
      payload['early_bird_discount_date'] = DateFormat(
        'yyyy-MM-dd',
      ).format(_earlyBirdEndsAt!);
      payload['early_bird_discount_time'] = DateFormat(
        'HH:mm:ss',
      ).format(_earlyBirdEndsAt!);
    }

    if (_pricingType != 'variation' && _reservationEnabled) {
      payload['reservation_deposit_type'] = _reservationDepositType;
      payload['reservation_deposit_value'] = _parseAmount(
        _reservationDepositController.text,
      );
      payload['reservation_final_due_date'] = DateFormat(
        'yyyy-MM-dd',
      ).format(_reservationDueDate!);
      if (_reservationInstallmentController.text.trim().isNotEmpty) {
        payload['reservation_min_installment_amount'] = _parseAmount(
          _reservationInstallmentController.text,
        );
      }
    }

    if (_pricingType == 'normal' && _schedules.isNotEmpty) {
      payload['price_schedules'] = _schedules
          .map((schedule) => schedule.toPayload())
          .toList();
    }

    return payload;
  }
}

class _VariationDraft {
  final TextEditingController nameController;
  final TextEditingController priceController;
  final TextEditingController availableController;
  final TextEditingController maxController;
  String ticketAvailableType;
  String maxTicketBuyType;

  _VariationDraft({
    String? name,
    double? price,
    this.ticketAvailableType = 'limited',
    int? available,
    this.maxTicketBuyType = 'limited',
    int? maxBuyTicket,
  }) : nameController = TextEditingController(text: name ?? ''),
       priceController = TextEditingController(
         text: price == null ? '' : price.toStringAsFixed(2),
       ),
       availableController = TextEditingController(
         text: available?.toString() ?? '',
       ),
       maxController = TextEditingController(
         text: maxBuyTicket?.toString() ?? '',
       );

  factory _VariationDraft.fromTicket(ProfessionalManagedTicketVariation row) {
    return _VariationDraft(
      name: row.name,
      price: row.price,
      ticketAvailableType: row.ticketAvailableType,
      available: row.ticketAvailable,
      maxTicketBuyType: row.maxTicketBuyType,
      maxBuyTicket: row.maxBuyTicket,
    );
  }

  Map<String, dynamic> toPayload({required int sortOrder}) {
    final payload = <String, dynamic>{
      'name': nameController.text.trim(),
      'price': _parseAmount(priceController.text),
      'ticket_available_type': ticketAvailableType,
      'max_ticket_buy_type': maxTicketBuyType,
      'sort_order': sortOrder,
    };

    if (ticketAvailableType == 'limited') {
      payload['ticket_available'] = int.parse(availableController.text.trim());
    }
    if (maxTicketBuyType == 'limited') {
      payload['max_buy_ticket'] = int.parse(maxController.text.trim());
    }

    return payload;
  }

  void dispose() {
    nameController.dispose();
    priceController.dispose();
    availableController.dispose();
    maxController.dispose();
  }
}

class _ScheduleDraft {
  final TextEditingController labelController;
  final TextEditingController priceController;
  DateTime? effectiveFrom;
  bool isActive;
  int sortOrder;

  _ScheduleDraft({
    String? label,
    double? price,
    this.effectiveFrom,
    this.isActive = true,
    this.sortOrder = 0,
  }) : labelController = TextEditingController(text: label ?? ''),
       priceController = TextEditingController(
         text: price == null ? '' : price.toStringAsFixed(2),
       );

  factory _ScheduleDraft.fromSchedule(ProfessionalTicketSchedule row) {
    return _ScheduleDraft(
      label: row.label,
      price: row.price,
      effectiveFrom: row.effectiveFrom == null
          ? null
          : DateTime.tryParse(row.effectiveFrom!),
      isActive: row.isActive,
      sortOrder: row.sortOrder,
    );
  }

  Map<String, dynamic> toPayload() {
    return {
      'label': labelController.text.trim().isEmpty
          ? null
          : labelController.text.trim(),
      'effective_from': effectiveFrom!.toIso8601String(),
      'price': _parseAmount(priceController.text),
      'sort_order': sortOrder,
      'is_active': isActive,
    };
  }

  void dispose() {
    labelController.dispose();
    priceController.dispose();
  }
}

String _reviewStatusLabel(String? reviewStatus) {
  switch (reviewStatus) {
    case 'pending':
      return 'En revisión';
    case 'changes_requested':
      return 'Cambios';
    case 'rejected':
      return 'Rechazado';
    case 'approved':
      return 'Aprobado';
    default:
      return 'Activo';
  }
}

String _pricingTypeLabel(String pricingType) {
  switch (pricingType) {
    case 'free':
      return 'Gratis';
    case 'variation':
      return 'Variación';
    default:
      return 'Precio fijo';
  }
}

String _statusLabel(String status) {
  switch (status) {
    case 'paused':
      return 'pausa';
    case 'hidden':
      return 'oculto';
    case 'archived':
      return 'archivo';
    default:
      return 'activo';
  }
}

Color _statusColor(String status) {
  switch (status) {
    case 'paused':
      return kWarningColor;
    case 'hidden':
      return kInfoColor;
    case 'archived':
      return kDangerColor;
    default:
      return kSuccessColor;
  }
}

Widget _statusChip(String status) {
  final color = _statusColor(status);
  final label = switch (status) {
    'paused' => 'Pausado',
    'hidden' => 'Oculto',
    'archived' => 'Archivado',
    _ => 'Activo',
  };

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.14),
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: color.withValues(alpha: 0.28)),
    ),
    child: Text(
      label,
      style: GoogleFonts.outfit(
        color: color,
        fontSize: 11,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

Widget _gateChip(ProfessionalManagedTicket ticket, List<ProfessionalManagedTicket> siblingTickets) {
  final gateTicketLabel = siblingTickets
      .where((t) => t.id == ticket.gateTicketId)
      .map((t) => t.title)
      .firstOrNull ?? 'ticket desconocido';

  String triggerLabel = '';
  if (ticket.gateTrigger == 'sold_out') {
    triggerLabel = 'al agotar $gateTicketLabel';
  } else if (ticket.gateTrigger == 'date') {
    if (ticket.gateTriggerDate != null) {
      final date = DateTime.tryParse(ticket.gateTriggerDate!);
      triggerLabel = date != null
          ? 'el ${DateFormat('dd MMM · hh:mm a').format(date)}'
          : 'por fecha';
    } else {
      triggerLabel = 'por fecha';
    }
  } else {
    triggerLabel = 'manual';
  }

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: kSecondaryColor.withValues(alpha: 0.14),
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: kSecondaryColor.withValues(alpha: 0.28)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.lock_clock_rounded, color: kSecondaryColor, size: 12),
        const SizedBox(width: 4),
        Text(
          triggerLabel,
          style: GoogleFonts.outfit(
            color: kSecondaryColor,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}

String? _requirePositiveInt(
  String? value,
  String message, {
  bool allowZero = false,
}) {
  final normalized = value?.trim() ?? '';
  final parsed = int.tryParse(normalized);
  if (parsed == null) {
    return message;
  }
  if (allowZero ? parsed < 0 : parsed < 1) {
    return message;
  }
  return null;
}

String? _requireAmount(String? value, String message, {double min = 0}) {
  final parsed = _parseAmount(value);
  if (parsed == null || parsed < min) {
    return message;
  }
  return null;
}

double? _parseAmount(String? value) {
  final normalized = (value ?? '').trim().replaceAll(',', '.');
  return double.tryParse(normalized);
}

DateTime? _joinDateTime(String? date, String? time) {
  if ((date ?? '').isEmpty) return null;
  final raw = '${date ?? ''} ${time ?? '00:00:00'}'.trim();
  return DateTime.tryParse(raw.replaceFirst(' ', 'T'));
}

String _formatDateTime(String? iso) {
  if ((iso ?? '').isEmpty) return 'fecha pendiente';
  final parsed = DateTime.tryParse(iso!);
  if (parsed == null) return iso;
  return DateFormat('dd MMM yyyy · hh:mm a').format(parsed);
}

Future<DateTime?> _pickDate(BuildContext context, {DateTime? initial}) async {
  final now = DateTime.now();
  return showDatePicker(
    context: context,
    initialDate: initial ?? now,
    firstDate: DateTime(now.year - 1),
    lastDate: DateTime(now.year + 5),
  );
}

Future<DateTime?> _pickDateTime(
  BuildContext context, {
  DateTime? initial,
}) async {
  final now = DateTime.now();
  final date = await showDatePicker(
    context: context,
    initialDate: initial ?? now,
    firstDate: DateTime(now.year - 1),
    lastDate: DateTime(now.year + 5),
  );
  if (date == null || !context.mounted) {
    return null;
  }

  final time = await showTimePicker(
    context: context,
    initialTime: initial == null
        ? TimeOfDay.now()
        : TimeOfDay.fromDateTime(initial),
  );
  if (time == null) {
    return null;
  }

  return DateTime(date.year, date.month, date.day, time.hour, time.minute);
}

class _ManualIssueSheet extends StatefulWidget {
  final ProfessionalManagedTicket ticket;

  const _ManualIssueSheet({required this.ticket});

  @override
  State<_ManualIssueSheet> createState() => _ManualIssueSheetState();
}

class _ManualIssueSheetState extends State<_ManualIssueSheet> {
  final _email = TextEditingController();
  final _fname = TextEditingController();
  final _lname = TextEditingController();
  final _quantity = TextEditingController(text: '1');
  bool _submitting = false;

  void _submit() {
    final email = _email.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor, ingresa un correo electrónico válido.'),
          backgroundColor: context.dutyTheme.warning,
        ),
      );
      return;
    }
    
    final payload = {
      'email': email,
      'fname': _fname.text.trim(),
      'lname': _lname.text.trim(),
      'quantity': int.tryParse(_quantity.text) ?? 1,
    };
    
    Navigator.of(context).pop(payload);
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.dutyTheme;
    return Container(
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Añadir a Guestlist',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: palette.textPrimary,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(Icons.close, color: palette.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Genera boletas gratuitas de cortesía (\$0.00). Estas serán generadas inmediatamente y enviadas al correo especificado.',
            style: GoogleFonts.splineSans(
              color: palette.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _email,
            decoration: InputDecoration(
              labelText: 'Correo Electrónico *',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _fname,
                  decoration: InputDecoration(
                    labelText: 'Nombre',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _lname,
                  decoration: InputDecoration(
                    labelText: 'Apellido',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _quantity,
            decoration: InputDecoration(
              labelText: 'Cantidad de boletas',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 32),
          FilledButton(
            onPressed: _submitting ? null : _submit,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: palette.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: _submitting
               ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
               : const Text('Emitir Tickets', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
