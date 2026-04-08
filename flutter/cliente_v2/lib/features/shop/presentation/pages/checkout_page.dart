import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:dio/dio.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_urls.dart';
import '../../../../core/theme/colors.dart';
import '../../../events/data/models/event_detail_model.dart';
import '../providers/checkout_provider.dart';
import 'package:duty_client/features/auth/presentation/providers/auth_provider.dart';
import '../../../profile/data/repositories/social_repository.dart';
import '../../../profile/presentation/providers/profile_provider.dart';

class CheckoutPage extends ConsumerStatefulWidget {
  final EventDetailModel event;

  const CheckoutPage({super.key, required this.event});

  @override
  ConsumerState<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends ConsumerState<CheckoutPage> {
  final TextEditingController _couponController = TextEditingController();
  final ScrollController _selectionScrollController = ScrollController();
  final GlobalKey _assignmentsSectionKey = GlobalKey();
  bool _isRecipientPromptOpen = false;

  @override
  void dispose() {
    _couponController.dispose();
    _selectionScrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(checkoutProvider.notifier)
        ..startCheckoutSession(
          widget.event.tickets.map((ticket) => ticket.id).toList(),
        )
        ..goToStep(CheckoutStep.selection);
    });
  }

  @override
  void didUpdateWidget(covariant CheckoutPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.event.id != widget.event.id) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) {
          return;
        }
        ref.read(checkoutProvider.notifier)
          ..startCheckoutSession(
            widget.event.tickets.map((ticket) => ticket.id).toList(),
          )
          ..goToStep(CheckoutStep.selection);
      });
    }
  }

  void _increment(TicketModel ticket) {
    final previousState = ref.read(checkoutProvider);
    final ticketId = ticket.id;
    final previousUnitCount = _buildSelectedUnits(previousState).length;
    final currentQty = previousState.selectedTickets[ticketId] ?? 0;

    if (ticket.hasPurchaseLimit && _currentUserId <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Inicia sesión para comprar entradas con límite por usuario.',
          ),
        ),
      );
      return;
    }

    final nextUnitIndex = currentQty + 1;

    ref
        .read(checkoutProvider.notifier)
        .updateQuantity(ticketId, nextUnitIndex, ticket.price);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) {
        return;
      }

      final updatedState = ref.read(checkoutProvider);
      final updatedUnits = _buildSelectedUnits(updatedState);
      if (updatedUnits.length <= previousUnitCount) {
        return;
      }

      final slotKey = '$ticketId:$nextUnitIndex';
      _SelectedTicketUnit? newUnit;
      for (final unit in updatedUnits) {
        if (unit.slotKey == slotKey) {
          newUnit = unit;
          break;
        }
      }

      if (newUnit == null) {
        return;
      }

      if (updatedState.recipientAssignments[newUnit.slotKey] != null) {
        return;
      }

      if (_unitNeedsAssignmentPrompt(newUnit)) {
        await _showExtraTicketPrompt(newUnit);
      }
    });
  }

  void _decrement(int ticketId) {
    final currentQty =
        ref.read(checkoutProvider).selectedTickets[ticketId] ?? 0;
    if (currentQty > 0) {
      ref
          .read(checkoutProvider.notifier)
          .updateQuantity(
            ticketId,
            currentQty - 1,
            widget.event.tickets.firstWhere((t) => t.id == ticketId).price,
          );
    }
  }

  double _calculateTotal() {
    double total = 0.0;
    final selectedTickets = ref.watch(checkoutProvider).selectedTickets;
    for (var ticket in widget.event.tickets) {
      int qty = selectedTickets[ticket.id] ?? 0;
      total += ticket.price * qty;
    }
    // Update provider total only if changed? ideally provider handles this,
    // but for now we calc UI side and push to provider before checkout
    // ref.read(checkoutProvider.notifier).setTotal(total); // triggering build loop if not careful
    return total;
  }

  int _calculateAge(DateTime birthDate) {
    DateTime currentDate = DateTime.now();
    int age = currentDate.year - birthDate.year;
    int month1 = currentDate.month;
    int month2 = birthDate.month;
    if (month2 > month1) {
      age--;
    } else if (month1 == month2) {
      int day1 = currentDate.day;
      int day2 = birthDate.day;
      if (day2 > day1) {
        age--;
      }
    }
    return age;
  }

  int get _currentUserId {
    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) {
      return 0;
    }
    return int.tryParse(currentUser['id']?.toString() ?? '') ?? 0;
  }

  List<_SelectedTicketUnit> _buildSelectedUnits(CheckoutState checkoutState) {
    final units = <_SelectedTicketUnit>[];
    var absoluteIndex = 0;

    for (final ticket in widget.event.tickets) {
      final quantity = checkoutState.selectedTickets[ticket.id] ?? 0;
      for (var unitIndex = 1; unitIndex <= quantity; unitIndex++) {
        units.add(
          _SelectedTicketUnit(
            slotKey: '${ticket.id}:$unitIndex',
            ticketId: ticket.id,
            ticketTitle: ticket.title,
            price: ticket.price,
            unitIndex: unitIndex,
            absoluteIndex: absoluteIndex,
          ),
        );
        absoluteIndex++;
      }
    }

    return units;
  }

  TicketModel? _ticketById(int ticketId) {
    for (final ticket in widget.event.tickets) {
      if (ticket.id == ticketId) {
        return ticket;
      }
    }
    return null;
  }

  bool _unitRequiresRecipient(_SelectedTicketUnit unit) {
    final ticket = _ticketById(unit.ticketId);
    if (ticket == null || !ticket.hasPurchaseLimit) {
      return false;
    }

    final remainingAllowance = ticket.remainingPurchaseAllowance;
    if (remainingAllowance == null) {
      return false;
    }

    return unit.unitIndex > remainingAllowance;
  }

  bool _unitCanStayWithBuyer(_SelectedTicketUnit unit) {
    return !_unitRequiresRecipient(unit);
  }

  bool _unitIsAssignmentVisible(_SelectedTicketUnit unit) {
    return true;
  }

  bool _unitNeedsAssignmentPrompt(_SelectedTicketUnit unit) {
    return unit.absoluteIndex > 0 || _unitRequiresRecipient(unit);
  }

  List<_SelectedTicketUnit> _buildAssignmentUnits(CheckoutState checkoutState) {
    return _buildSelectedUnits(
      checkoutState,
    ).where(_unitIsAssignmentVisible).toList(growable: false);
  }

  _SelectedTicketUnit? _firstUnitForTicket(
    CheckoutState checkoutState,
    int ticketId,
  ) {
    for (final unit in _buildSelectedUnits(checkoutState)) {
      if (unit.ticketId == ticketId) {
        return unit;
      }
    }
    return null;
  }

  int _assignedCountForTicket(CheckoutState checkoutState, int ticketId) {
    var assigned = 0;
    for (final unit in _buildSelectedUnits(checkoutState)) {
      if (unit.ticketId != ticketId) {
        continue;
      }
      if (checkoutState.recipientAssignments[unit.slotKey] != null) {
        assigned++;
      }
    }
    return assigned;
  }

  TicketRecipientAssignment? _firstAssignedRecipientForTicket(
    CheckoutState checkoutState,
    int ticketId,
  ) {
    for (final unit in _buildSelectedUnits(checkoutState)) {
      if (unit.ticketId != ticketId) {
        continue;
      }
      final assignment = checkoutState.recipientAssignments[unit.slotKey];
      if (assignment != null) {
        return assignment;
      }
    }
    return null;
  }

  bool _allSelectedUnitsAssignedAway(CheckoutState checkoutState) {
    final selectedUnits = _buildSelectedUnits(checkoutState);
    if (selectedUnits.isEmpty) {
      return false;
    }
    for (final unit in selectedUnits) {
      if (checkoutState.recipientAssignments[unit.slotKey] == null) {
        return false;
      }
    }
    return true;
  }

  String _formatRecipientLabel(TicketRecipientAssignment? assignment) {
    if (assignment == null) {
      return 'Asignada';
    }
    final username = assignment.username?.trim();
    if (username != null && username.isNotEmpty) {
      return '@$username';
    }
    return assignment.name;
  }

  int _extraTicketCount(CheckoutState checkoutState) {
    return _buildAssignmentUnits(checkoutState).length;
  }

  int _assignedExtraTicketCount(CheckoutState checkoutState) {
    return _buildAssignmentUnits(checkoutState)
        .where(
          (unit) => checkoutState.recipientAssignments[unit.slotKey] != null,
        )
        .length;
  }

  int _unassignedExtraTicketCount(CheckoutState checkoutState) {
    final extraCount = _extraTicketCount(checkoutState);
    final assignedCount = _assignedExtraTicketCount(checkoutState);
    return extraCount > assignedCount ? extraCount - assignedCount : 0;
  }

  int _requiredUnassignedTicketCount(CheckoutState checkoutState) {
    return _buildAssignmentUnits(checkoutState)
        .where((unit) => _unitRequiresRecipient(unit))
        .where(
          (unit) => checkoutState.recipientAssignments[unit.slotKey] == null,
        )
        .length;
  }

  _SelectedTicketUnit? _firstUnassignedExtraUnit(CheckoutState checkoutState) {
    final selectedUnits = _buildAssignmentUnits(checkoutState);
    for (final unit in selectedUnits) {
      if (checkoutState.recipientAssignments[unit.slotKey] == null) {
        return unit;
      }
    }
    return null;
  }

  Future<void> _scrollToAssignmentsSection() async {
    final assignmentsContext = _assignmentsSectionKey.currentContext;
    if (assignmentsContext != null) {
      await Scrollable.ensureVisible(
        assignmentsContext,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
        alignment: 0.08,
      );
      return;
    }

    if (_selectionScrollController.hasClients) {
      await _selectionScrollController.animateTo(
        _selectionScrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    }
  }

  Future<void> _showExtraTicketPrompt(_SelectedTicketUnit unit) async {
    if (!mounted || _isRecipientPromptOpen) {
      return;
    }

    _isRecipientPromptOpen = true;
    final action = await showModalBottomSheet<_ExtraTicketPromptAction>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _ExtraTicketPromptSheet(
        unit: unit,
        requiresRecipient: _unitRequiresRecipient(unit),
      ),
    );
    _isRecipientPromptOpen = false;

    if (!mounted || action == null) {
      return;
    }

    if (action == _ExtraTicketPromptAction.assign) {
      await _scrollToAssignmentsSection();
      if (!mounted) {
        return;
      }
      await _pickRecipientForUnit(unit);
    }
  }

  Future<void> _reviewAssignmentsBeforeCheckout() async {
    final checkoutState = ref.read(checkoutProvider);
    final assignmentTickets = _extraTicketCount(checkoutState);
    final unassignedCount = _unassignedExtraTicketCount(checkoutState);
    final requiredUnassignedCount = _requiredUnassignedTicketCount(
      checkoutState,
    );

    if (assignmentTickets <= 0 || unassignedCount <= 0) {
      return;
    }

    if (requiredUnassignedCount > 0) {
      final firstPending = _firstUnassignedExtraUnit(checkoutState);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              requiredUnassignedCount == 1
                  ? 'Ya alcanzaste tu límite personal para esta boleta. Elige a quién se enviará antes de pagar.'
                  : 'Algunas boletas ya no pueden quedarse contigo. Asigna esos destinatarios antes de pagar.',
            ),
          ),
        );
      }
      await _scrollToAssignmentsSection();
      if (!mounted || firstPending == null) {
        return;
      }
      await _pickRecipientForUnit(firstPending);
      return;
    }

    final action = await showModalBottomSheet<_AssignmentReviewAction>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _AssignmentReviewSheet(
        extraTicketCount: assignmentTickets,
        assignedCount: _assignedExtraTicketCount(checkoutState),
        unassignedCount: unassignedCount,
      ),
    );

    if (!mounted || action == null) {
      return;
    }

    if (action == _AssignmentReviewAction.assignNow) {
      await _scrollToAssignmentsSection();
      if (!mounted) {
        return;
      }
      final firstPending = _firstUnassignedExtraUnit(
        ref.read(checkoutProvider),
      );
      if (firstPending != null) {
        await _pickRecipientForUnit(firstPending);
      }
      return;
    }

    await _continueToPayment();
  }

  Future<void> _continueToPayment() async {
    final selectedTickets = ref.read(checkoutProvider).selectedTickets;
    int totalQty = 0;
    for (final qty in selectedTickets.values) {
      totalQty += qty;
    }

    if (totalQty <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least one ticket.')),
      );
      return;
    }
    // Enforce Age Restrictions (local check before continuing)
    final isAgeRestricted =
        widget.event.policies?.adultAgeRestrictions ?? false;
    if (isAgeRestricted) {
      final profileData = await ref.read(profileProvider.future);
      final user = profileData.containsKey('raw_user') == true
          ? profileData['raw_user']
          : profileData;

      final dobString = user['date_of_birth'];
      if (dobString == null || dobString.toString().isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Verification required: Please add your Date of Birth in your profile to purchase tickets for this event.',
              ),
            ),
          );
          context.push('/settings/edit-profile');
        }
        return;
      }

      try {
        final dob = DateTime.parse(dobString.toString());
        final age = _calculateAge(dob);
        if (age < 18) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'You must be 18 or older to purchase tickets for this event.',
                ),
              ),
            );
          }
          return;
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Invalid date of birth format. Please update your profile.',
              ),
            ),
          );
        }
        return;
      }
    }

    final total = _calculateTotal();
    ref.read(checkoutProvider.notifier).setTotal(total);
    ref.read(checkoutProvider.notifier).fetchWallet();
    ref.read(checkoutProvider.notifier).fetchBonusWallet();
    ref.read(checkoutProvider.notifier).fetchSavedCards();
    await _refreshPaymentPreview();
    ref.read(checkoutProvider.notifier).goToStep(CheckoutStep.payment);
  }

  String _resolveCheckoutPricingType() {
    final checkoutState = ref.read(checkoutProvider);
    final selectedTicketIds = checkoutState.selectedTickets.entries
        .where((entry) => entry.value > 0)
        .map((entry) => entry.key)
        .toList(growable: false);
    if (selectedTicketIds.isEmpty) {
      return 'normal';
    }

    final selectedPricingTypes = widget.event.tickets
        .where((ticket) => selectedTicketIds.contains(ticket.id))
        .map((ticket) => (ticket.pricingType ?? 'normal').toLowerCase())
        .toSet();

    if (selectedPricingTypes.isEmpty) {
      return 'normal';
    }

    if (selectedPricingTypes.length == 1) {
      return selectedPricingTypes.first;
    }

    return selectedPricingTypes.contains('normal')
        ? 'normal'
        : selectedPricingTypes.first;
  }

  Future<void> _refreshPaymentPreview() async {
    await ref
        .read(checkoutProvider.notifier)
        .previewCheckout(
          eventId: widget.event.id,
          pricingType: _resolveCheckoutPricingType(),
          eventGuestCheckoutStatus: 1,
          gateway: 'stripe',
        );
  }

  FundingBreakdown _resolvedFundingBreakdown(CheckoutState state) {
    final preview = state.paymentSummaryPreview;
    if (preview is Map<String, dynamic>) {
      return fundingBreakdownFromServerSummary(
        preview,
        fallbackSubtotal: state.totalAmount,
      );
    }

    return calculateFundingBreakdown(state, state.totalAmount);
  }

  Future<void> _pickRecipientForUnit(_SelectedTicketUnit unit) async {
    final currentUserId = _currentUserId;
    if (currentUserId <= 0) {
      return;
    }

    final currentAssignment = ref
        .read(checkoutProvider)
        .recipientAssignments[unit.slotKey];

    final result = await showModalBottomSheet<_RecipientPickerResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _RecipientPickerSheet(
        currentUserId: currentUserId,
        ticketLabel: unit.ticketTitle,
        currentAssignment: currentAssignment,
        allowKeepMine: _unitCanStayWithBuyer(unit),
      ),
    );

    if (result == null || !mounted) {
      return;
    }

    final notifier = ref.read(checkoutProvider.notifier);
    if (result.clearSelection) {
      notifier.clearRecipient(unit.slotKey);
      return;
    }

    if (result.assignment != null) {
      notifier.assignRecipient(unit.slotKey, result.assignment!);
    }
  }

  Widget _buildRecipientAssignmentsSection(CheckoutState checkoutState) {
    final palette = context.dutyTheme;
    final assignmentUnits = _buildAssignmentUnits(checkoutState);
    if (assignmentUnits.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      key: _assignmentsSectionKey,
      margin: const EdgeInsets.only(top: 28),
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
            'Destinatarios de boletas',
            style: GoogleFonts.splineSans(
              color: palette.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Cada boleta puede quedarse contigo o asignarse a una amistad o a cualquier usuario de Duty. Si alguna ya supera tu límite personal, aquí mismo te pediremos a quién se enviará antes de pagar.',
            style: GoogleFonts.splineSans(
              color: palette.textSecondary,
              fontSize: 13,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
          ...assignmentUnits.map((unit) {
            final assignment = checkoutState.recipientAssignments[unit.slotKey];
            final requiresRecipient = _unitRequiresRecipient(unit);
            final canStayWithBuyer = _unitCanStayWithBuyer(unit);

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _TicketRecipientCard(
                unit: unit,
                requiresRecipient: requiresRecipient,
                canStayWithBuyer: canStayWithBuyer,
                assignment: assignment,
                onTap: () => _pickRecipientForUnit(unit),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAssignmentsSummary(CheckoutState checkoutState) {
    final palette = context.dutyTheme;
    final assignmentUnits = _buildAssignmentUnits(checkoutState);
    final assignments = assignmentUnits
        .map((unit) => checkoutState.recipientAssignments[unit.slotKey])
        .whereType<TicketRecipientAssignment>()
        .toList();

    if (assignments.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.surfaceAlt,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ENTREGA DE BOLETAS',
            style: GoogleFonts.splineSans(
              color: palette.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${assignments.length} ticket(s) se enviarán como transferencia pendiente en cuanto se confirme el pago.',
            style: GoogleFonts.splineSans(
              color: palette.textSecondary,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: assignments.map((assignment) {
              final label =
                  assignment.username != null &&
                      assignment.username!.trim().isNotEmpty
                  ? '@${assignment.username}'
                  : assignment.name;
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: palette.primarySurface,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: palette.borderStrong),
                ),
                child: Text(
                  label,
                  style: GoogleFonts.splineSans(
                    color: palette.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Future<void> _goToPayment() async {
    final checkoutState = ref.read(checkoutProvider);
    if (_unassignedExtraTicketCount(checkoutState) > 0) {
      await _reviewAssignmentsBeforeCheckout();
      return;
    }

    await _continueToPayment();
  }

  Future<void> _processCheckout() async {
    final checkoutState = ref.read(checkoutProvider);
    final total = checkoutState.totalAmount;
    final fundingBreakdown = _resolvedFundingBreakdown(checkoutState);
    final selectedTickets = checkoutState.selectedTickets;
    final quantityCout = widget.event.tickets.fold<int>(
      0,
      (sum, ticket) => sum + (selectedTickets[ticket.id] ?? 0),
    );

    // Fetch user profile for booking details
    try {
      final profileData = await ref.read(profileProvider.future);
      // Handle both API response structure (raw_user) and cached fallback (direct map)
      final user = profileData['raw_user'] ?? profileData;

      final bookingData = {
        'event_id': widget.event.id,
        'quantity': quantityCout,
        'total_payment': total,
        'fname': currentUser['fname'] ?? 'Guest',
        'lname': currentUser['lname'] ?? '',
        'email': currentUser['email'] ?? 'guest@duty.do',
        'phone': currentUser['phone'] ?? '',
        'customer_id':
            currentUser['id'], // Critical for linking booking to user
        'country': currentUser['country'] ?? 'Dominican Republic',
        'address': currentUser['address'] ?? 'Santo Domingo',
        'city': currentUser['city'] ?? '',
        'state': currentUser['state'] ?? '',
        'zip_code': currentUser['zip_code'] ?? '',
        'gatewayType': 'online',
        'event_date': widget.event.date,
        'discount': 0,
        'tax': 0,
        'total': total,
        'total_early_bird_dicount': 0,
      };

      if (checkoutState.paymentMethod == 'card' &&
          checkoutState.selectedCardId == 'new_card') {
        // Ensure event title is in payload for success page
        bookingData['event_title'] = widget.event.title;
        context.push('/payment-cc', extra: bookingData);
        return;
      }

      final result = await ref
          .read(checkoutProvider.notifier)
          .submitOrder(bookingData);

      final responsePayload = Map<String, dynamic>.from(result);
      final serverTransferCount =
          int.tryParse(
            responsePayload['gift_transfers_created']?.toString() ?? '',
          ) ??
          checkoutState.recipientAssignments.length;
      responsePayload['success_summary'] = _buildSuccessSummary(
        checkoutState: checkoutState,
        totalTickets: quantityCout,
        transferCount: serverTransferCount,
      );

      if (mounted) {
        final bookingInfo =
            responsePayload['booking_info'] is Map<String, dynamic>
            ? responsePayload['booking_info'] as Map<String, dynamic>
            : <String, dynamic>{};

        context.go(
          '/ticket-success',
          extra: {
            'bookingId':
                bookingInfo['booking_id']?.toString() ??
                responsePayload['booking_id']?.toString() ??
                'N/A',
            'eventTitle': widget.event.title,
            'rawBookingInfo': responsePayload,
          },
        );
      }
    } catch (e) {
      if (mounted) {
        final palette = context.dutyTheme;
        final errorMsg = _friendlyCheckoutErrorMessage(e);

        if (_requiresVerification(e)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Por favor, verifique su cuenta para continuar con la compra.',
              ),
            ),
          );
          context.push('/settings/verification');
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg), backgroundColor: palette.danger),
        );
      }
    }
  }

  bool _requiresVerification(Object error) {
    final raw = error.toString().toLowerCase();
    return raw.contains('email_verification_required') ||
        raw.contains('phone_verification_required');
  }

  String _friendlyCheckoutErrorMessage(Object error) {
    if (error is DioException) {
      final statusCode = error.response?.statusCode;
      final data = error.response?.data;

      if (data is Map) {
        if (data['validation_errors'] is Map) {
          final validationErrors =
              data['validation_errors'] as Map<dynamic, dynamic>;
          final messages = <String>[];
          for (final value in validationErrors.values) {
            if (value is List && value.isNotEmpty) {
              messages.add(value.first.toString());
            } else if (value != null) {
              messages.add(value.toString());
            }
          }

          if (messages.isNotEmpty) {
            return messages.take(2).join('\n');
          }
        }

        final rawMessage =
            data['message']?.toString() ?? data['error']?.toString() ?? '';
        final translated = _translateCheckoutError(rawMessage, statusCode);
        if (translated != null) {
          return translated;
        }
      }

      final translated = _translateCheckoutError(
        error.message ?? error.toString(),
        statusCode,
      );
      if (translated != null) {
        return translated;
      }
    }

    final translated = _translateCheckoutError(error.toString(), null);
    if (translated != null) {
      return translated;
    }

    return 'No pudimos completar la compra ahora mismo. Intenta de nuevo en unos minutos.';
  }

  String? _translateCheckoutError(String rawMessage, int? statusCode) {
    final raw = rawMessage.trim();
    final lower = raw.toLowerCase();

    if (statusCode != null && statusCode >= 500) {
      return 'No pudimos completar la compra ahora mismo. Tu pago no se confirmó correctamente. Intenta de nuevo en unos minutos.';
    }

    if (lower.contains('insufficient') ||
        lower.contains('fondos insuficientes')) {
      return 'No tienes saldo suficiente para completar esta compra.';
    }

    if (lower.contains('purchase_limit_login_required') ||
        lower.contains('límite por usuario')) {
      return 'Inicia sesión para comprar entradas con límite por usuario.';
    }

    if (lower.contains('purchase_limit_reached') ||
        lower.contains('máximo de') ||
        lower.contains('permitidas')) {
      return raw;
    }

    if (lower.contains('select a saved card') ||
        lower.contains('selecciona una tarjeta')) {
      return 'Selecciona una tarjeta guardada para cubrir el monto restante.';
    }

    if (lower.contains('user not logged in')) {
      return 'Tu sesión expiró. Vuelve a iniciar sesión para continuar.';
    }

    if (lower.contains('validation error')) {
      return 'Revisa los datos de la compra e inténtalo de nuevo.';
    }

    if (lower.contains('server error')) {
      return 'No pudimos completar la compra ahora mismo. Intenta de nuevo en unos minutos.';
    }

    if (lower.contains('network error') ||
        lower.contains('socketexception') ||
        lower.contains('connection')) {
      return 'No pudimos conectarnos para completar la compra. Revisa tu conexión e inténtalo de nuevo.';
    }

    final cleaned = raw
        .replaceAll('Exception:', '')
        .replaceAll('DioException [bad response]: ', '')
        .trim();

    if (cleaned.isEmpty) {
      return null;
    }

    if (cleaned.length > 180) {
      return 'No pudimos completar la compra. Si vuelve a pasar, intenta otra vez o revisa tus boletas en unos minutos.';
    }

    return cleaned;
  }

  Map<String, dynamic> _buildSuccessSummary({
    required CheckoutState checkoutState,
    required int totalTickets,
    required int transferCount,
  }) {
    final groupedRecipients = <int, Map<String, dynamic>>{};

    for (final assignment in checkoutState.recipientAssignments.values) {
      final entry =
          groupedRecipients[assignment.recipientId] ??
          <String, dynamic>{
            'recipient_id': assignment.recipientId,
            'name': assignment.name,
            'username': assignment.username,
            'photo_url': assignment.photoUrl,
            'ticket_count': 0,
          };

      entry['ticket_count'] = (entry['ticket_count'] as int) + 1;
      groupedRecipients[assignment.recipientId] = entry;
    }

    final normalizedTransferCount = transferCount.clamp(0, totalTickets);

    return {
      'total_tickets': totalTickets,
      'gift_tickets': normalizedTransferCount,
      'kept_tickets': totalTickets - normalizedTransferCount,
      'gift_recipients': groupedRecipients.values.toList(growable: false),
    };
  }

  Widget _buildCouponSection(CheckoutState state) {
    final palette = context.dutyTheme;
    if (state.appliedCouponCode != null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        margin: const EdgeInsets.only(bottom: 24),
        decoration: BoxDecoration(
          color: palette.success.withAlpha((255 * 0.12).toInt()),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: palette.success.withAlpha((255 * 0.28).toInt()),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.check_circle, color: palette.success, size: 20),
                const SizedBox(width: 8),
                Text(
                  "Cupón aplicado: ${state.appliedCouponCode}",
                  style: GoogleFonts.splineSans(
                    color: palette.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: () {
                _couponController.clear();
                ref.read(checkoutProvider.notifier).removeCoupon();
              },
              child: Icon(Icons.close, color: palette.textSecondary, size: 20),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _couponController,
              style: TextStyle(color: palette.textPrimary),
              decoration: InputDecoration(
                hintText: "Código promocional",
                hintStyle: TextStyle(color: palette.textMuted),
                filled: true,
                fillColor: palette.surfaceAlt,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: palette.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: palette.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: palette.primary),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () {
              if (_couponController.text.trim().isEmpty) return;
              FocusScope.of(context).unfocus();
              ref
                  .read(checkoutProvider.notifier)
                  .applyCoupon(
                    _couponController.text.trim(),
                    widget.event.id,
                    0.0,
                  );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: palette.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "Aplicar",
                style: GoogleFonts.splineSans(
                  color: palette.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.dutyTheme;
    final checkoutState = ref.watch(checkoutProvider);
    final total = _calculateTotal();

    return Scaffold(
      backgroundColor: palette.background,
      body: Stack(
        children: [
          // Background Elements could go here (gradients/blobs)

          // Main Logic Switching
          if (checkoutState.currentStep == CheckoutStep.selection)
            _buildSelectionStep(context, checkoutState, total),
          if (checkoutState.currentStep == CheckoutStep.payment)
            _buildPaymentStep(context, checkoutState),
          if (checkoutState.currentStep == CheckoutStep.confirmation)
            _buildConfirmationStep(context),

          // Loading Overlay
          if (checkoutState.isLoading)
            Container(
              color: palette.background.withAlpha((255 * 0.72).toInt()),
              child: Center(
                child: CircularProgressIndicator(color: palette.primary),
              ),
            ),
        ],
      ),
    );
  }

  // --- Step 1: Ticket Selection ---
  Widget _buildSelectionStep(
    BuildContext context,
    CheckoutState checkoutState,
    double total,
  ) {
    final palette = context.dutyTheme;
    final selectedUnits = _buildSelectedUnits(checkoutState);
    final assignmentUnits = _buildAssignmentUnits(checkoutState);
    final hasAssignmentAssistant =
        selectedUnits.length > 1 ||
        checkoutState.recipientAssignments.isNotEmpty;
    final assignedExtraCount = _assignedExtraTicketCount(checkoutState);
    final unassignedExtraCount = _unassignedExtraTicketCount(checkoutState);
    final allSelectedUnitsAssignedAway = _allSelectedUnitsAssignedAway(
      checkoutState,
    );
    final scrollBottomPadding = hasAssignmentAssistant ? 188.0 : 140.0;

    return Stack(
      children: [
        // Hero Image
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.45,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: widget.event.coverImage ?? widget.event.thumbnail,
                fit: BoxFit.cover,
                errorWidget: (_, _, _) =>
                    Container(color: palette.surfaceMuted),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      palette.background.withAlpha((255 * 0.3).toInt()),
                      palette.background.withAlpha((255 * 0.8).toInt()),
                      palette.background,
                    ],
                    stops: const [0.0, 0.6, 1.0],
                  ),
                ),
              ),
            ],
          ),
        ),

        SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _GlassIconButton(
                      icon: Icons.arrow_back,
                      onTap: () => context.pop(),
                    ),
                    _GlassIconButton(icon: Icons.share, onTap: () {}),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  controller: _selectionScrollController,
                  padding: EdgeInsets.fromLTRB(20, 10, 20, scrollBottomPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SellingFastBadge(),
                      const SizedBox(height: 16),
                      Text(
                        widget.event.title,
                        style: GoogleFonts.splineSans(
                          color: palette.textPrimary,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _EventDetailRow(
                        icon: Icons.calendar_today,
                        text: widget.event.date ?? 'TBA',
                      ),
                      const SizedBox(height: 8),
                      _EventDetailRow(
                        icon: Icons.location_on,
                        text: widget.event.address ?? 'TBA',
                      ),
                      const SizedBox(height: 32),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Select Tickets",
                            style: GoogleFonts.splineSans(
                              color: palette.textPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      ...widget.event.tickets.map((ticket) {
                        final qty =
                            checkoutState.selectedTickets[ticket.id] ?? 0;
                        final firstUnit = _firstUnitForTicket(
                          checkoutState,
                          ticket.id,
                        );
                        final assignedCountForTicket = _assignedCountForTicket(
                          checkoutState,
                          ticket.id,
                        );
                        final firstAssignedRecipient =
                            _firstAssignedRecipientForTicket(
                              checkoutState,
                              ticket.id,
                            );
                        final showGiftHint = qty == 1 && firstUnit != null;
                        return _TicketCard(
                          ticket: ticket,
                          qty: qty,
                          canIncrement: ticket.available,
                          onIncrement: () => _increment(ticket),
                          onDecrement: () => _decrement(ticket.id),
                          showGiftHint: showGiftHint,
                          giftLabel: assignedCountForTicket > 0
                              ? (assignedCountForTicket == qty
                                    ? 'Regalo asignado'
                                    : 'Editar regalos')
                              : 'Regalar',
                          giftHelperText: showGiftHint
                              ? (assignedCountForTicket > 0
                                    ? 'Esta boleta ya está asignada a otra persona.'
                                    : 'También puedes comprar esta boleta para un amigo sin quedarte con una.')
                              : null,
                          giftRecipientSummary: assignedCountForTicket <= 0
                              ? null
                              : qty == 1
                              ? _formatRecipientLabel(firstAssignedRecipient)
                              : '$assignedCountForTicket de $qty boletas asignadas',
                          onGiftTap: firstUnit == null
                              ? null
                              : () => _pickRecipientForUnit(firstUnit),
                        );
                      }),
                      if (_requiredUnassignedTicketCount(checkoutState) >
                          0) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFFF59E0B,
                            ).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: const Color(
                                0xFFF59E0B,
                              ).withValues(alpha: 0.22),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.info_outline_rounded,
                                color: Color(0xFFF59E0B),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Ya alcanzaste tu límite personal para una o más de estas boletas. Esas unidades todavía se pueden comprar, pero deben asignarse a otros usuarios antes de pagar.',
                                  style: GoogleFonts.splineSans(
                                    color: palette.textSecondary,
                                    fontSize: 12.5,
                                    height: 1.45,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      _buildRecipientAssignmentsSection(
                        ref.watch(checkoutProvider),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        if (hasAssignmentAssistant)
          Positioned(
            left: 20,
            right: 20,
            bottom: 118,
            child: _AssignmentStickySummaryBar(
              totalTickets: selectedUnits.length,
              assignedCount: assignedExtraCount,
              unassignedCount: unassignedExtraCount,
              onTap: () async {
                await _scrollToAssignmentsSection();
                if (!mounted) {
                  return;
                }
                final firstPending = _firstUnassignedExtraUnit(
                  ref.read(checkoutProvider),
                );
                if (firstPending != null) {
                  await _pickRecipientForUnit(firstPending);
                } else if (assignmentUnits.isNotEmpty) {
                  await _pickRecipientForUnit(assignmentUnits.first);
                }
              },
            ),
          ),

        // Sticky Bottom Bar
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: _StickyBottomBar(
            total: total,
            btnText: unassignedExtraCount > 0
                ? 'Revisar destinatarios'
                : allSelectedUnitsAssignedAway
                ? 'Comprar y enviar'
                : 'Checkout',
            onTap: _goToPayment,
          ),
        ),
      ],
    );
  }

  // --- Step 2: Payment Checkout ---
  Widget _buildPaymentStep(BuildContext context, CheckoutState state) {
    final palette = context.dutyTheme;
    final fundingBreakdown = _resolvedFundingBreakdown(state);

    return SafeArea(
      child: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    _GlassIconButton(
                      icon: Icons.arrow_back,
                      onTap: () => ref
                          .read(checkoutProvider.notifier)
                          .goToStep(CheckoutStep.selection),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      "Checkout (2/3)",
                      style: GoogleFonts.splineSans(
                        color: palette.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Progress
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 4,
                            width: 30,
                            decoration: BoxDecoration(
                              color: palette.primary.withAlpha(
                                (255 * 0.3).toInt(),
                              ),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            height: 4,
                            width: 30,
                            decoration: BoxDecoration(
                              color: palette.primary,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            height: 4,
                            width: 30,
                            decoration: BoxDecoration(
                              color: palette.primary.withAlpha(
                                (255 * 0.3).toInt(),
                              ),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      Text(
                        "ORDER SUMMARY",
                        style: GoogleFonts.splineSans(
                          color: palette.textMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Order Summary Card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: palette.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: palette.border),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: CachedNetworkImage(
                                    imageUrl:
                                        widget.event.coverImage ??
                                        widget.event.thumbnail,
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                    errorWidget: (_, __, ___) => Container(
                                      width: 80,
                                      height: 80,
                                      color: palette.surfaceMuted,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.event.title,
                                        style: GoogleFonts.splineSans(
                                          color: palette.textPrimary,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        widget.event.date ?? '',
                                        style: GoogleFonts.splineSans(
                                          color: palette.textMuted,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        "${widget.event.tickets.fold<int>(0, (sum, ticket) => sum + (state.selectedTickets[ticket.id] ?? 0))}x Tickets",
                                        style: GoogleFonts.splineSans(
                                          color: palette.primary,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Divider(color: palette.border),
                            const SizedBox(height: 10),
                            _SummaryRow(
                              label: "Subtotal",
                              value:
                                  "\$${state.totalAmount.toStringAsFixed(2)}",
                            ),
                            if (state.appliedCouponCode != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: _SummaryRow(
                                  label: "Descuento (Cupón)",
                                  value:
                                      "- \$${state.discountAmount.toStringAsFixed(2)}",
                                ),
                              ),
                            if (state.applyBonusBalance)
                              Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: _SummaryRow(
                                  label: "Bonus aplicado",
                                  value:
                                      "- \$${fundingBreakdown.bonusApplied.toStringAsFixed(2)}",
                                ),
                              ),
                            if (state.applyWalletBalance)
                              Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: _SummaryRow(
                                  label: "Wallet aplicado",
                                  value:
                                      "- \$${fundingBreakdown.walletApplied.toStringAsFixed(2)}",
                                ),
                              ),
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: _SummaryRow(
                                label: "Processing fee",
                                value:
                                    "\$${fundingBreakdown.processingFee.toStringAsFixed(2)}",
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: _SummaryRow(
                                label: fundingBreakdown.requiresCard
                                    ? "Subtotal a tarjeta"
                                    : "Saldo restante",
                                value:
                                    "\$${fundingBreakdown.cardAmount.toStringAsFixed(2)}",
                              ),
                            ),
                            const SizedBox(height: 8),
                            _SummaryRow(
                              label: "Processing Fee",
                              value: "\$0",
                            ), // Mock fee
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Total a pagar",
                                  style: GoogleFonts.splineSans(
                                    color: palette.textPrimary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  "\$${fundingBreakdown.totalPayable.toStringAsFixed(2)}",
                                  style: GoogleFonts.splineSans(
                                    color: palette.primary,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      _buildAssignmentsSummary(state),

                      const SizedBox(height: 32),
                      Text(
                        "PAYMENT METHOD",
                        style: GoogleFonts.splineSans(
                          color: palette.textMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Payment Methods
                      _PaymentOption(
                        icon: Icons.local_activity_outlined,
                        title: "Bono Duty",
                        subtitle:
                            "Disponible: \$${state.bonusBalance.toStringAsFixed(2)}",
                        isSelected: state.applyBonusBalance,
                        onTap: () async {
                          ref
                              .read(checkoutProvider.notifier)
                              .toggleBonusBalance(!state.applyBonusBalance);
                          await _refreshPaymentPreview();
                        },
                      ),
                      const SizedBox(height: 12),
                      _PaymentOption(
                        icon: Icons.account_balance_wallet,
                        title: "DUTY Wallet",
                        subtitle:
                            "Disponible: \$${state.walletBalance.toStringAsFixed(2)}",
                        isSelected: state.applyWalletBalance,
                        onTap: () async {
                          ref
                              .read(checkoutProvider.notifier)
                              .toggleWalletBalance(!state.applyWalletBalance);
                          await _refreshPaymentPreview();
                        },
                      ),
                      const SizedBox(height: 12),

                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: palette.surfaceAlt,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: palette.border),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              fundingBreakdown.requiresCard
                                  ? Icons.credit_card
                                  : Icons.check_circle_outline,
                              color: fundingBreakdown.requiresCard
                                  ? palette.warning
                                  : palette.success,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                fundingBreakdown.requiresCard
                                    ? fundingBreakdown.processingFee > 0
                                          ? 'El checkout cobrará a la tarjeta \$${fundingBreakdown.cardAmount.toStringAsFixed(2)} más un processing fee de \$${fundingBreakdown.processingFee.toStringAsFixed(2)}. Total en tarjeta: \$${fundingBreakdown.cardTotalCharge.toStringAsFixed(2)}.'
                                          : 'El checkout usará primero bono y wallet. La tarjeta solo cubrirá el remanente de \$${fundingBreakdown.cardAmount.toStringAsFixed(2)}.'
                                    : 'La compra queda totalmente cubierta con saldo interno. No se cargará processing fee.',
                                style: GoogleFonts.splineSans(
                                  color: palette.textSecondary,
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      Text(
                        "CARD FOR REMAINING BALANCE",
                        style: GoogleFonts.splineSans(
                          color: palette.textMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Saved Cards Section
                      ...state.savedCards.map((card) {
                        final isSelected =
                            state.paymentMethod == 'card' &&
                            state.selectedCardId == card.id;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: _PaymentOption(
                            icon: Icons.credit_card,
                            title: "${card.brand} ending in ${card.last4}",
                            subtitle: fundingBreakdown.requiresCard
                                ? fundingBreakdown.processingFee > 0
                                      ? "Expires ${card.expiry} · Subtotal \$${fundingBreakdown.cardAmount.toStringAsFixed(2)} · Fee \$${fundingBreakdown.processingFee.toStringAsFixed(2)} · Total \$${fundingBreakdown.cardTotalCharge.toStringAsFixed(2)}"
                                      : "Expires ${card.expiry} · Remanente \$${fundingBreakdown.cardAmount.toStringAsFixed(2)}"
                                : "Expires ${card.expiry}",
                            isSelected: isSelected,
                            onTap: () async {
                              ref
                                  .read(checkoutProvider.notifier)
                                  .selectCard(card.id);
                              await _refreshPaymentPreview();
                            },
                          ),
                        );
                      }),

                      // Pay with new Card Option
                      GestureDetector(
                        onTap: () async {
                          await ref
                              .read(checkoutProvider.notifier)
                              .addNewCard();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: state.selectedCardId == 'new_card'
                                ? palette.primarySurface
                                : palette.surfaceAlt,
                            border: Border.all(
                              color: state.selectedCardId == 'new_card'
                                  ? palette.primary
                                  : palette.border,
                              style: BorderStyle.solid,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: palette.surfaceMuted,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.add,
                                  color: palette.textPrimary,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Add New Card",
                                    style: GoogleFonts.splineSans(
                                      color: palette.textPrimary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (state.selectedCardId == 'new_card')
                                    Text(
                                      "Enter details on next screen",
                                      style: GoogleFonts.splineSans(
                                        color: palette.primary,
                                        fontSize: 12,
                                      ),
                                    ),
                                ],
                              ),
                              const Spacer(),
                              if (state.selectedCardId == 'new_card')
                                Icon(
                                  Icons.check_circle,
                                  color: palette.primary,
                                ),
                            ],
                          ),
                        ),
                      ),

                      // Loyalty Points
                      const SizedBox(height: 32),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E192D),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withAlpha((255 * 0.05).toInt()),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.amber.withAlpha(
                                  (255 * 0.2).toInt(),
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Use 500 Points",
                                    style: GoogleFonts.splineSans(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    "Save \$50.00 instantly",
                                    style: GoogleFonts.splineSans(
                                      color: Colors.greenAccent,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: false, // activeState
                              onChanged: (val) {},
                              activeThumbColor: kPrimaryColor,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 100), // Space for bottom bar
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Builder(
              builder: (context) {
                return _StickyBottomBar(
                  total: fundingBreakdown.totalPayable,
                  btnText: fundingBreakdown.requiresCard
                      ? "Confirmar y pagar"
                      : "Confirmar compra",
                  onTap: _processCheckout,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- Step 3: Order Confirmation ---
  Widget _buildConfirmationStep(BuildContext context) {
    final palette = context.dutyTheme;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: palette.background),
      child: Stack(
        children: [
          // Ambient Glow
          Positioned(
            top: -50,
            left: -50,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: palette.primaryGlow.withAlpha((255 * 0.2).toInt()),
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Success Icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: palette.primarySurface,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: palette.primary.withAlpha((255 * 0.5).toInt()),
                      ),
                    ),
                    child: Icon(Icons.check, color: palette.primary, size: 40),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Order Confirmed",
                    style: GoogleFonts.splineSans(
                      color: palette.textPrimary,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "You're in! Transaction complete.",
                    style: GoogleFonts.splineSans(
                      color: palette.textSecondary,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Golden Ticket
                  Container(
                    decoration: BoxDecoration(
                      color: palette.surface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: palette.border),
                      boxShadow: [
                        BoxShadow(
                          color: palette.shadow.withAlpha((255 * 0.3).toInt()),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Ticket Image
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(24),
                          ),
                          child: SizedBox(
                            height: 180,
                            width: double.infinity,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                CachedNetworkImage(
                                  imageUrl: widget.event.thumbnail,
                                  fit: BoxFit.cover,
                                  imageBuilder: (context, imageProvider) =>
                                      Container(
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: imageProvider,
                                            fit: BoxFit.cover,
                                            colorFilter: ColorFilter.mode(
                                              Colors.black.withValues(
                                                alpha: 0.2,
                                              ),
                                              BlendMode.darken,
                                            ),
                                          ),
                                        ),
                                      ),
                                ),
                                Positioned(
                                  bottom: 16,
                                  left: 16,
                                  child: Text(
                                    "VIP ACCESS",
                                    style: TextStyle(
                                      color: palette.primary,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.5,
                                      backgroundColor: palette.surfaceMuted
                                          .withAlpha((255 * 0.88).toInt()),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "DATE",
                                        style: TextStyle(
                                          color: palette.textMuted,
                                          fontSize: 10,
                                        ),
                                      ),
                                      Text(
                                        widget.event.date ?? "TBA",
                                        style: TextStyle(
                                          color: palette.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        "TIME",
                                        style: TextStyle(
                                          color: palette.textMuted,
                                          fontSize: 10,
                                        ),
                                      ),
                                      Text(
                                        widget.event.time ?? "TBA",
                                        style: TextStyle(
                                          color: palette.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              // Perforation
                              Row(
                                children: List.generate(
                                  15,
                                  (index) => Expanded(
                                    child: Container(
                                      height: 2,
                                      color: palette.border,
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 2,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              // QR Placeholder
                              Container(
                                width: 100,
                                height: 100,
                                color: palette.textPrimary,
                                child: Center(
                                  child: Icon(
                                    Icons.qr_code_2,
                                    size: 80,
                                    color: palette.background,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Actions
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: palette.surfaceAlt.withAlpha(
                          (255 * 0.1).toInt(),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: () => context.go('/home'),
                      child: Text(
                        "Return to Home",
                        style: GoogleFonts.splineSans(
                          color: palette.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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

// --- Components ---

class _SelectedTicketUnit {
  final String slotKey;
  final int ticketId;
  final String ticketTitle;
  final double price;
  final int unitIndex;
  final int absoluteIndex;

  const _SelectedTicketUnit({
    required this.slotKey,
    required this.ticketId,
    required this.ticketTitle,
    required this.price,
    required this.unitIndex,
    required this.absoluteIndex,
  });
}

class _RecipientPickerResult {
  final TicketRecipientAssignment? assignment;
  final bool clearSelection;

  const _RecipientPickerResult({this.assignment, this.clearSelection = false});
}

class _RecipientCandidate {
  final int id;
  final String name;
  final String? username;
  final String? photoUrl;
  final bool isFriend;
  final bool isMutual;

  const _RecipientCandidate({
    required this.id,
    required this.name,
    this.username,
    this.photoUrl,
    this.isFriend = false,
    this.isMutual = false,
  });

  TicketRecipientAssignment toAssignment() {
    return TicketRecipientAssignment(
      recipientId: id,
      name: name,
      username: username,
      photoUrl: photoUrl,
      isFriend: isFriend,
      isMutual: isMutual,
    );
  }
}

class _TicketRecipientCard extends StatelessWidget {
  final _SelectedTicketUnit unit;
  final bool requiresRecipient;
  final bool canStayWithBuyer;
  final TicketRecipientAssignment? assignment;
  final VoidCallback? onTap;

  const _TicketRecipientCard({
    required this.unit,
    required this.requiresRecipient,
    required this.canStayWithBuyer,
    required this.assignment,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.dutyTheme;
    final isKeepingMine = assignment == null && canStayWithBuyer;
    final label = assignment == null
        ? (requiresRecipient
              ? 'Elige quién la recibirá'
              : 'Se queda contigo por ahora')
        : (assignment!.username != null &&
                  assignment!.username!.trim().isNotEmpty
              ? '@${assignment!.username}'
              : assignment!.name);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: palette.surfaceAlt,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: requiresRecipient
              ? palette.warning.withValues(alpha: 0.34)
              : palette.borderStrong,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: requiresRecipient
                  ? palette.warning.withValues(alpha: 0.14)
                  : palette.primarySurface,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              isKeepingMine
                  ? Icons.person_outline_rounded
                  : Icons.card_giftcard_rounded,
              color: requiresRecipient
                  ? palette.warning
                  : (isKeepingMine ? palette.textSecondary : palette.primary),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ticket ${unit.absoluteIndex + 1} · ${unit.ticketTitle}',
                  style: GoogleFonts.splineSans(
                    color: palette.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: GoogleFonts.splineSans(
                    color: isKeepingMine
                        ? palette.textSecondary
                        : (assignment == null
                              ? palette.textMuted
                              : palette.textPrimary.withValues(alpha: 0.92)),
                    fontSize: 13,
                    fontWeight: assignment == null
                        ? FontWeight.w500
                        : FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  assignment != null
                      ? 'Recibirá una transferencia pendiente para aceptar esta boleta.'
                      : (requiresRecipient
                            ? 'Tu cupo personal ya se agotó para esta boleta. Debes asignarla a otro usuario.'
                            : 'Puedes dejarla contigo o enviarla a alguien de tu red.'),
                  style: GoogleFonts.splineSans(
                    color: palette.textMuted,
                    fontSize: 11,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          if (isKeepingMine)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: palette.surfaceMuted,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                'Tú',
                style: GoogleFonts.splineSans(
                  color: palette.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          else
            IconButton(
              onPressed: onTap,
              icon: Icon(
                assignment == null ? Icons.add_circle_outline : Icons.edit,
                color: requiresRecipient ? palette.warning : palette.primary,
              ),
            ),
        ],
      ),
    );
  }
}

class _RecipientPickerSheet extends ConsumerStatefulWidget {
  final int currentUserId;
  final String ticketLabel;
  final TicketRecipientAssignment? currentAssignment;
  final bool allowKeepMine;

  const _RecipientPickerSheet({
    required this.currentUserId,
    required this.ticketLabel,
    this.currentAssignment,
    this.allowKeepMine = true,
  });

  @override
  ConsumerState<_RecipientPickerSheet> createState() =>
      _RecipientPickerSheetState();
}

class _RecipientPickerSheetState extends ConsumerState<_RecipientPickerSheet> {
  final _controller = TextEditingController();
  Timer? _debounce;
  bool _isSearching = false;
  List<_RecipientCandidate> _searchResults = const [];

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  List<_RecipientCandidate> _mergeFriendCandidates(
    List<dynamic> favorites,
    List<dynamic> followers,
  ) {
    final merged = <int, _RecipientCandidate>{};

    void absorb(List<dynamic> items, {required bool fromFollowers}) {
      for (final raw in items) {
        if (raw is! Map) {
          continue;
        }
        final item = Map<String, dynamic>.from(raw);
        if ((item['type']?.toString() ?? 'user') != 'user') {
          continue;
        }

        final id = int.tryParse(item['id']?.toString() ?? '');
        if (id == null || id <= 0 || id == widget.currentUserId) {
          continue;
        }

        final existing = merged[id];
        final candidate = _RecipientCandidate(
          id: id,
          name: item['name']?.toString().trim().isNotEmpty == true
              ? item['name'].toString().trim()
              : (item['username']?.toString() ?? 'Duty user'),
          username: item['username']?.toString(),
          photoUrl: item['photo']?.toString(),
          isFriend: true,
          isMutual:
              existing?.isMutual == true ||
              item['mutual_connection'] == true ||
              (existing != null && fromFollowers),
        );
        merged[id] = candidate;
      }
    }

    absorb(favorites, fromFollowers: false);
    absorb(followers, fromFollowers: true);

    final values = merged.values.toList()
      ..sort((a, b) {
        if (a.isMutual != b.isMutual) {
          return a.isMutual ? -1 : 1;
        }
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });
    return values;
  }

  Future<void> _performSearch(String query) async {
    final trimmed = query.trim();
    if (trimmed.length < 2) {
      if (!mounted) {
        return;
      }
      setState(() {
        _searchResults = const [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);
    try {
      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.dio.get(
        AppUrls.search,
        queryParameters: {'q': trimmed},
        options: Options(
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      final payload = response.data;
      Map<String, dynamic> json = const {};
      if (payload is Map<String, dynamic>) {
        json = payload;
      } else if (payload is Map) {
        json = Map<String, dynamic>.from(payload);
      } else if (payload is String) {
        json = Map<String, dynamic>.from(jsonDecode(payload) as Map);
      }

      final data = Map<String, dynamic>.from(
        (json['data'] as Map?) ?? const {},
      );
      final users = List<dynamic>.from(data['users'] ?? const []);
      final results = users
          .map((raw) {
            final item = Map<String, dynamic>.from(raw as Map);
            return _RecipientCandidate(
              id: int.tryParse(item['id']?.toString() ?? '') ?? 0,
              name: item['name']?.toString().trim().isNotEmpty == true
                  ? item['name'].toString().trim()
                  : (item['username']?.toString() ?? 'Duty user'),
              username: item['username']?.toString(),
              photoUrl: item['photo']?.toString(),
              isFriend:
                  item['is_following'] == true || item['follows_you'] == true,
              isMutual: item['mutual_connection'] == true,
            );
          })
          .where(
            (candidate) =>
                candidate.id > 0 && candidate.id != widget.currentUserId,
          )
          .toList();

      if (!mounted) {
        return;
      }
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _searchResults = const [];
        _isSearching = false;
      });
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      _performSearch(value);
    });
  }

  void _selectCandidate(_RecipientCandidate candidate) {
    Navigator.of(
      context,
    ).pop(_RecipientPickerResult(assignment: candidate.toAssignment()));
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.dutyTheme;
    final favoritesAsync = ref.watch(
      userFavoritesProvider(widget.currentUserId),
    );
    final followersAsync = ref.watch(
      userFollowersListProvider(widget.currentUserId),
    );

    final favorites = favoritesAsync.valueOrNull ?? const <dynamic>[];
    final followers = followersAsync.valueOrNull ?? const <dynamic>[];
    final friendCandidates = _mergeFriendCandidates(favorites, followers);

    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border.all(color: palette.border),
        ),
        padding: EdgeInsets.fromLTRB(
          20,
          14,
          20,
          20 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: palette.borderStrong,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Enviar ${widget.ticketLabel}',
              style: GoogleFonts.splineSans(
                color: palette.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.allowKeepMine
                  ? 'El ticket se compra contigo y luego se envía como transferencia pendiente al usuario que elijas.'
                  : 'Tu cupo personal para esta boleta ya se agotó. Esta unidad debe asignarse a otro usuario antes de pagar.',
              style: GoogleFonts.splineSans(
                color: palette.textSecondary,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _controller,
              onChanged: _onSearchChanged,
              style: GoogleFonts.splineSans(color: palette.textPrimary),
              decoration: InputDecoration(
                hintText: 'Buscar por nombre o @username',
                hintStyle: GoogleFonts.splineSans(color: palette.textMuted),
                prefixIcon: Icon(Icons.search, color: palette.textSecondary),
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
              ),
            ),
            const SizedBox(height: 14),
            if (widget.allowKeepMine) ...[
              ListTile(
                contentPadding: EdgeInsets.zero,
                onTap: () => Navigator.of(
                  context,
                ).pop(const _RecipientPickerResult(clearSelection: true)),
                leading: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: palette.surfaceMuted,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.person_outline,
                    color: palette.textSecondary,
                  ),
                ),
                title: Text(
                  'Se queda conmigo',
                  style: GoogleFonts.splineSans(
                    color: palette.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                subtitle: Text(
                  'No crear transferencia para este ticket.',
                  style: GoogleFonts.splineSans(color: palette.textMuted),
                ),
              ),
              const SizedBox(height: 6),
            ] else ...[
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: palette.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: palette.warning.withValues(alpha: 0.22),
                  ),
                ),
                child: Text(
                  'Esta boleta ya no puede quedarse contigo. Elige un destinatario para continuar.',
                  style: GoogleFonts.splineSans(
                    color: palette.textSecondary,
                    fontSize: 12.5,
                    height: 1.4,
                  ),
                ),
              ),
            ],
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_isSearching)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: palette.primary,
                          ),
                        ),
                      )
                    else if (_controller.text.trim().length >= 2)
                      _RecipientCandidateList(
                        title: 'Resultados',
                        candidates: _searchResults,
                        onSelected: _selectCandidate,
                        emptyLabel:
                            'No encontramos usuarios con esa búsqueda todavía.',
                      )
                    else
                      _RecipientCandidateList(
                        title: 'Tus amistades',
                        candidates: friendCandidates,
                        onSelected: _selectCandidate,
                        emptyLabel:
                            'Aún no tienes amistades sugeridas. Puedes buscar a cualquier usuario de Duty.',
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecipientCandidateList extends StatelessWidget {
  final String title;
  final List<_RecipientCandidate> candidates;
  final ValueChanged<_RecipientCandidate> onSelected;
  final String emptyLabel;

  const _RecipientCandidateList({
    required this.title,
    required this.candidates,
    required this.onSelected,
    required this.emptyLabel,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.dutyTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.splineSans(
            color: palette.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 10),
        if (candidates.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              emptyLabel,
              style: GoogleFonts.splineSans(
                color: palette.textMuted,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          )
        else
          ...candidates.map((candidate) {
            final subtitle =
                candidate.username != null &&
                    candidate.username!.trim().isNotEmpty
                ? '@${candidate.username}'
                : 'Usuario Duty';
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: palette.surfaceAlt,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: palette.border),
              ),
              child: ListTile(
                onTap: () => onSelected(candidate),
                leading: _RecipientAvatar(
                  photoUrl: candidate.photoUrl,
                  fallbackLabel: candidate.name,
                ),
                title: Text(
                  candidate.name,
                  style: GoogleFonts.splineSans(
                    color: palette.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                subtitle: Text(
                  subtitle,
                  style: GoogleFonts.splineSans(color: palette.textMuted),
                ),
                trailing: Wrap(
                  spacing: 6,
                  children: [
                    if (candidate.isMutual)
                      _SmallStatusPill(
                        label: 'Mutual',
                        color: const Color(0xFF4ADE80),
                      ),
                    if (candidate.isFriend && !candidate.isMutual)
                      _SmallStatusPill(
                        label: 'Amistad',
                        color: palette.primary,
                      ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: palette.textMuted,
                      size: 14,
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }
}

class _RecipientAvatar extends StatelessWidget {
  final String? photoUrl;
  final String fallbackLabel;

  const _RecipientAvatar({required this.photoUrl, required this.fallbackLabel});

  @override
  Widget build(BuildContext context) {
    if (photoUrl != null && photoUrl!.trim().isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.network(
          photoUrl!,
          width: 44,
          height: 44,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _buildFallback(context),
        ),
      );
    }

    return _buildFallback(context);
  }

  Widget _buildFallback(BuildContext context) {
    final palette = context.dutyTheme;
    final initials = fallbackLabel
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part.characters.first.toUpperCase())
        .join();

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: palette.primarySurface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: Text(
          initials.isEmpty ? '?' : initials,
          style: GoogleFonts.splineSans(
            color: palette.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _SmallStatusPill extends StatelessWidget {
  final String label;
  final Color color;

  const _SmallStatusPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.24)),
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
}

enum _ExtraTicketPromptAction { keepMine, assign }

class _ExtraTicketPromptSheet extends StatelessWidget {
  final _SelectedTicketUnit unit;
  final bool requiresRecipient;

  const _ExtraTicketPromptSheet({
    required this.unit,
    required this.requiresRecipient,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.dutyTheme;
    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border.all(color: palette.border),
        ),
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: palette.borderStrong,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              requiresRecipient
                  ? 'Este ticket ya debe ir a otra persona'
                  : 'Este ticket extra ya puede tener destinatario',
              style: GoogleFonts.splineSans(
                color: palette.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              requiresRecipient
                  ? 'Ticket ${unit.absoluteIndex + 1} · ${unit.ticketTitle}. Tu cupo personal para esta boleta ya se agotó, así que esta unidad debe asignarse ahora a otro usuario.'
                  : 'Ticket ${unit.absoluteIndex + 1} · ${unit.ticketTitle}. Puedes dejarlo contigo o asignarlo ahora mismo a un amigo para no olvidarlo luego.',
              style: GoogleFonts.splineSans(
                color: palette.textSecondary,
                fontSize: 13,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 20),
            if (!requiresRecipient) ...[
              _PromptActionCard(
                icon: Icons.person_outline_rounded,
                title: 'Se queda conmigo',
                description: 'Podrás transferirlo más tarde si quieres.',
                onTap: () => Navigator.of(
                  context,
                ).pop(_ExtraTicketPromptAction.keepMine),
              ),
              const SizedBox(height: 12),
            ],
            _PromptActionCard(
              icon: Icons.group_add_rounded,
              title: 'Asignar a un amigo',
              description: requiresRecipient
                  ? 'Abriremos tu lista de amistades y búsqueda por @username para completar esta asignación obligatoria.'
                  : 'Abriremos tu lista de amistades y búsqueda por @username.',
              accentColor: requiresRecipient
                  ? palette.warning
                  : CheckoutPageStateColors.primary,
              onTap: () =>
                  Navigator.of(context).pop(_ExtraTicketPromptAction.assign),
            ),
          ],
        ),
      ),
    );
  }
}

enum _AssignmentReviewAction { assignNow, continueMine }

class _AssignmentReviewSheet extends StatelessWidget {
  final int extraTicketCount;
  final int assignedCount;
  final int unassignedCount;

  const _AssignmentReviewSheet({
    required this.extraTicketCount,
    required this.assignedCount,
    required this.unassignedCount,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.dutyTheme;
    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border.all(color: palette.border),
        ),
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: palette.borderStrong,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Revisa a quién van esos tickets',
              style: GoogleFonts.splineSans(
                color: palette.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tienes $extraTicketCount ticket(s) por revisar. Ya asignaste $assignedCount y todavía quedan $unassignedCount sin definir.',
              style: GoogleFonts.splineSans(
                color: palette.textSecondary,
                fontSize: 13,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: palette.surfaceAlt,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: palette.border),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: palette.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Si continúas así, esos tickets extra quedarán contigo por defecto. Luego podrás transferirlos manualmente.',
                      style: GoogleFonts.splineSans(
                        color: palette.textSecondary,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            _PromptActionCard(
              icon: Icons.group_add_rounded,
              title: 'Asignar ahora',
              description: 'Llévame a la sección de amigos antes de pagar.',
              accentColor: CheckoutPageStateColors.primary,
              onTap: () =>
                  Navigator.of(context).pop(_AssignmentReviewAction.assignNow),
            ),
            const SizedBox(height: 12),
            _PromptActionCard(
              icon: Icons.shopping_bag_outlined,
              title: 'Continuar así',
              description: 'Seguir al pago y dejar esos tickets conmigo.',
              onTap: () => Navigator.of(
                context,
              ).pop(_AssignmentReviewAction.continueMine),
            ),
          ],
        ),
      ),
    );
  }
}

class _PromptActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;
  final Color accentColor;

  const _PromptActionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
    this.accentColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.dutyTheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: palette.surfaceAlt,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: accentColor.withValues(alpha: 0.24)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: accentColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.splineSans(
                      color: palette.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: GoogleFonts.splineSans(
                      color: palette.textSecondary,
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: palette.textMuted,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}

class _AssignmentStickySummaryBar extends StatelessWidget {
  final int totalTickets;
  final int assignedCount;
  final int unassignedCount;
  final VoidCallback onTap;

  const _AssignmentStickySummaryBar({
    required this.totalTickets,
    required this.assignedCount,
    required this.unassignedCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.dutyTheme;
    final hasPending = unassignedCount > 0;
    final subtitle = hasPending
        ? '$unassignedCount ticket(s) por revisar'
        : '$assignedCount ticket(s) ya preparados';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: palette.surface.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: hasPending
              ? palette.primary.withValues(alpha: 0.26)
              : palette.border,
        ),
        boxShadow: [
          BoxShadow(
            color: palette.shadow.withValues(alpha: 0.22),
            blurRadius: 22,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: palette.primarySurface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.group_add_rounded, color: palette.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$totalTickets tickets seleccionados',
                  style: GoogleFonts.splineSans(
                    color: palette.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: GoogleFonts.splineSans(
                    color: hasPending ? palette.primary : palette.textSecondary,
                    fontSize: 12,
                    fontWeight: hasPending ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          TextButton(
            onPressed: onTap,
            style: TextButton.styleFrom(
              foregroundColor: palette.textPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              backgroundColor: palette.primarySurface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              hasPending ? 'Asignar' : 'Editar',
              style: GoogleFonts.splineSans(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class CheckoutPageStateColors {
  static const primary = kPrimaryColor;
}

class _StickyBottomBar extends StatelessWidget {
  final double total;
  final String btnText;
  final VoidCallback onTap;

  const _StickyBottomBar({
    required this.total,
    required this.btnText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.dutyTheme;
    return Container(
      decoration: BoxDecoration(
        // Gradient fade for the bottom area
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            palette.background.withAlpha(0),
            palette.background.withAlpha((255 * 0.90).toInt()),
            palette.background,
          ],
          stops: [0.0, 0.4, 1.0],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: palette.primary,
          foregroundColor: palette.textPrimary,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 10,
          shadowColor: palette.primaryGlow.withAlpha((255 * 0.5).toInt()),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              btnText,
              style: GoogleFonts.splineSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: palette.textPrimary.withAlpha((255 * 0.2).toInt()),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Text(
                    "\$${total.toInt()}.00",
                    style: GoogleFonts.splineSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: palette.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward,
                    size: 16,
                    color: palette.textPrimary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TicketCard extends StatelessWidget {
  final TicketModel ticket;
  final int qty;
  final bool canIncrement;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final bool showGiftHint;
  final String giftLabel;
  final String? giftHelperText;
  final String? giftRecipientSummary;
  final VoidCallback? onGiftTap;

  const _TicketCard({
    required this.ticket,
    required this.qty,
    required this.canIncrement,
    required this.onIncrement,
    required this.onDecrement,
    this.showGiftHint = false,
    this.giftLabel = 'Regalar',
    this.giftHelperText,
    this.giftRecipientSummary,
    this.onGiftTap,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.dutyTheme;
    final remainingAllowance = ticket.remainingPurchaseAllowance;
    final hasLimit = ticket.hasPurchaseLimit;
    final limitReached = hasLimit && (remainingAllowance ?? 0) <= 0;
    final limitHelperText = hasLimit
        ? [
            'Máximo ${ticket.maxPurchasePerUser} por usuario',
            if (ticket.alreadyPurchasedQty > 0)
              'ya compraste ${ticket.alreadyPurchasedQty}',
            if (remainingAllowance != null && !limitReached)
              'te quedan $remainingAllowance',
            if (limitReached)
              'tu cupo ya se agotó; las próximas deben asignarse',
          ].join(' · ')
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: palette.surface,
        border: Border.all(color: palette.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ticket.title,
                      style: GoogleFonts.splineSans(
                        color: palette.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Standard entry",
                      style: GoogleFonts.splineSans(
                        color: palette.textMuted,
                        fontSize: 13,
                      ),
                    ),
                    if (limitHelperText != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        limitHelperText,
                        style: GoogleFonts.splineSans(
                          color: limitReached
                              ? const Color(0xFFF59E0B)
                              : palette.textSecondary,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "\$${ticket.price.toInt()}",
                    style: GoogleFonts.splineSans(
                      color: palette.primary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "per person",
                    style: GoogleFonts.splineSans(
                      color: palette.textMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: ticket.isGated
                      ? const Color(0xFF3B82F6) // Blue for próximamente
                          .withAlpha((255 * 0.1).toInt())
                      : (limitReached
                              ? const Color(0xFFF59E0B)
                              : const Color(0xFF4ADE80))
                          .withAlpha((255 * 0.1).toInt()),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: ticket.isGated
                        ? const Color(0xFF3B82F6)
                            .withAlpha((255 * 0.2).toInt())
                        : (limitReached
                                ? const Color(0xFFF59E0B)
                                : const Color(0xFF4ADE80))
                            .withAlpha((255 * 0.2).toInt()),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (ticket.isGated) ...[
                      const Icon(Icons.lock_clock_rounded, size: 10, color: Color(0xFF3B82F6)),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      ticket.isGated
                          ? "Próximamente"
                          : (limitReached ? "Límite alcanzado" : "Available"),
                      style: GoogleFonts.splineSans(
                        color: ticket.isGated
                            ? const Color(0xFF3B82F6)
                            : (limitReached
                                ? const Color(0xFFF59E0B)
                                : const Color(0xFF4ADE80)),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // Stepper
              Container(
                decoration: BoxDecoration(
                  color: palette.surfaceMuted.withAlpha((255 * 0.5).toInt()),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: palette.border),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    _StepperButton(
                      icon: Icons.remove,
                      onTap: qty > 0 ? onDecrement : null,
                      isPrimary: false,
                    ),
                    SizedBox(
                      width: 32,
                      child: Text(
                        "$qty",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.splineSans(
                          color: palette.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    _StepperButton(
                      icon: Icons.add,
                      onTap: !ticket.isGated && ticket.available && canIncrement
                          ? onIncrement
                          : null,
                      isPrimary: true,
                    ),
                  ],
                ),
              ),

            ],
          ),
          if (showGiftHint) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: palette.surfaceAlt,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: palette.border),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.redeem_rounded, color: palette.primary, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          giftHelperText ??
                              'También puedes regalar esta boleta a un amigo.',
                          style: GoogleFonts.splineSans(
                            color: palette.textSecondary,
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                        if (giftRecipientSummary != null &&
                            giftRecipientSummary!.trim().isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: palette.primarySurface,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: palette.borderStrong),
                            ),
                            child: Text(
                              giftRecipientSummary!,
                              style: GoogleFonts.splineSans(
                                color: palette.primary,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 10),
                        OutlinedButton.icon(
                          onPressed: onGiftTap,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: palette.primary,
                            side: BorderSide(
                              color: palette.primary.withValues(alpha: 0.28),
                            ),
                            backgroundColor: palette.primarySurface,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                          ),
                          icon: const Icon(Icons.group_add_rounded, size: 16),
                          label: Text(
                            giftLabel,
                            style: GoogleFonts.splineSans(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
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
}

class _PaymentOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.dutyTheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? palette.primarySurface : palette.surfaceAlt,
          border: Border.all(
            color: isSelected ? palette.primary : Colors.transparent,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected ? palette.primary : palette.surfaceMuted,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: palette.textPrimary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.splineSans(
                      color: palette.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.splineSans(
                      color: palette.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: palette.primary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  const _SummaryRow({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    final palette = context.dutyTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.splineSans(
            color: palette.textSecondary,
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.splineSans(
            color: palette.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool isPrimary;
  const _StepperButton({
    required this.icon,
    required this.onTap,
    this.isPrimary = false,
  });
  @override
  Widget build(BuildContext context) {
    final palette = context.dutyTheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isPrimary ? palette.primary : palette.surfaceAlt,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          icon,
          size: 16,
          color: isPrimary
              ? palette.textPrimary
              : (onTap == null ? palette.textMuted : palette.textSecondary),
        ),
      ),
    );
  }
}

class _GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _GlassIconButton({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final palette = context.dutyTheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: palette.surfaceAlt.withAlpha((255 * 0.9).toInt()),
          border: Border.all(color: palette.border),
        ),
        child: Icon(icon, color: palette.textPrimary, size: 22),
      ),
    );
  }
}

class _EventDetailRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _EventDetailRow({required this.icon, required this.text});
  @override
  Widget build(BuildContext context) {
    final palette = context.dutyTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: palette.primary, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.splineSans(
              color: palette.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}

class _SellingFastBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final palette = context.dutyTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: palette.primarySurface,
        border: Border.all(color: palette.borderStrong),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: palette.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            "SELLING FAST",
            style: GoogleFonts.splineSans(
              color: palette.primary,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}
