import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart'; // To get ApiClient/Auth info if needed
import '../../data/datasources/booking_remote_data_source.dart';
import '../../data/repositories/booking_repository.dart';
import '../../../../core/services/stripe_service.dart';

// Data Layer Providers
final bookingRemoteDataSourceProvider = Provider<BookingRemoteDataSource>((
  ref,
) {
  return BookingRemoteDataSource(ref.watch(apiClientProvider));
});

final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  return BookingRepository(ref.watch(bookingRemoteDataSourceProvider));
});

double _readBalance(dynamic value) {
  if (value is num) {
    return value.toDouble();
  }
  if (value is String) {
    return double.tryParse(value.trim()) ?? 0.0;
  }
  return 0.0;
}

// Models
class CreditCardModel {
  final String id;
  final String last4;
  final String brand; // 'visa', 'mastercard', etc.
  final String expiry;

  CreditCardModel({
    required this.id,
    required this.last4,
    required this.brand,
    required this.expiry,
  });
}

class TicketRecipientAssignment {
  final int recipientId;
  final String name;
  final String? username;
  final String? photoUrl;
  final bool isFriend;
  final bool isMutual;

  const TicketRecipientAssignment({
    required this.recipientId,
    required this.name,
    this.username,
    this.photoUrl,
    this.isFriend = false,
    this.isMutual = false,
  });

  Map<String, dynamic> toBookingJson({
    required String slotKey,
    required int ticketId,
    required int unitIndex,
  }) {
    return {
      'slot_key': slotKey,
      'ticket_id': ticketId,
      'unit_index': unitIndex,
      'recipient_id': recipientId,
    };
  }
}

// Checkout Steps
enum CheckoutStep { selection, payment, confirmation }

class FundingBreakdown {
  final double subtotal;
  final double discountedSubtotal;
  final double bonusApplied;
  final double walletApplied;
  final double cardAmount;
  final double processingFee;
  final double cardTotalCharge;
  final double totalPayable;

  const FundingBreakdown({
    required this.subtotal,
    required this.discountedSubtotal,
    required this.bonusApplied,
    required this.walletApplied,
    required this.cardAmount,
    required this.processingFee,
    required this.cardTotalCharge,
    required this.totalPayable,
  });

  bool get requiresCard => cardAmount > 0.009;
  bool get usesInternalBalance => bonusApplied > 0.009 || walletApplied > 0.009;
}

FundingBreakdown fundingBreakdownFromServerSummary(
  Map<String, dynamic> summary, {
  required double fallbackSubtotal,
}) {
  double readMoney(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value.trim()) ?? 0.0;
    return 0.0;
  }

  return FundingBreakdown(
    subtotal: fallbackSubtotal,
    discountedSubtotal: readMoney(summary['subtotal']),
    bonusApplied: readMoney(summary['bonus_amount']),
    walletApplied: readMoney(summary['wallet_amount']),
    cardAmount: readMoney(summary['card_amount']),
    processingFee: readMoney(
      summary['card_processing_fee'] ?? summary['processing_fee'],
    ),
    cardTotalCharge: readMoney(
      summary['card_total_charge'] ?? summary['total_to_charge'],
    ),
    totalPayable: readMoney(summary['total_to_charge']),
  );
}

FundingBreakdown calculateFundingBreakdown(
  CheckoutState state,
  double subtotal,
) {
  const stripeFeePercent = 0.05;
  const stripeFeeFixedDop = 15.0;

  double roundMoney(double value) => double.parse(value.toStringAsFixed(2));

  var remaining = subtotal - state.discountAmount;
  if (remaining < 0) remaining = 0;
  final discountedSubtotal = roundMoney(remaining);

  final bonusApplied = state.applyBonusBalance
      ? (remaining < state.bonusBalance ? remaining : state.bonusBalance)
      : 0.0;
  remaining -= bonusApplied;

  final walletApplied = state.applyWalletBalance
      ? (remaining < state.walletBalance ? remaining : state.walletBalance)
      : 0.0;
  remaining -= walletApplied;

  final double cardAmount = remaining < 0 ? 0.0 : remaining.toDouble();
  final requiresCard = cardAmount > 0.009;
  final usesInternalBalance = bonusApplied > 0.009 || walletApplied > 0.009;

  double processingFee = 0.0;
  double cardTotalCharge = cardAmount;

  // Mirror the backend allocation rules exactly: the current server
  // only adds processing fee on pure-card checkouts.
  if (requiresCard && !usesInternalBalance) {
    final grossCharge =
        (discountedSubtotal + stripeFeeFixedDop) / (1 - stripeFeePercent);
    processingFee = grossCharge - discountedSubtotal;
    cardTotalCharge = cardAmount + processingFee;
  }

  processingFee = roundMoney(processingFee);
  cardTotalCharge = roundMoney(cardTotalCharge);
  final double totalPayable = roundMoney(
    bonusApplied + walletApplied + cardTotalCharge,
  );

  return FundingBreakdown(
    subtotal: subtotal,
    discountedSubtotal: discountedSubtotal,
    bonusApplied: roundMoney(bonusApplied),
    walletApplied: roundMoney(walletApplied),
    cardAmount: roundMoney(cardAmount),
    processingFee: processingFee,
    cardTotalCharge: cardTotalCharge,
    totalPayable: totalPayable,
  );
}

// Checkout State
class CheckoutState {
  final bool isLoading;
  final String? error;
  final Map<int, int> selectedTickets; // ticketId -> quantity
  final double totalAmount;
  final CheckoutStep currentStep;
  final String? paymentMethod; // 'wallet', 'card' (generic)
  final List<CreditCardModel> savedCards;
  final String?
  selectedCardId; // ID of selected card if paymentMethod == 'card'
  final bool applyWalletBalance;
  final bool applyBonusBalance;
  final double walletBalance;
  final double bonusBalance;
  final List<int> ticketOrder;
  final Map<String, TicketRecipientAssignment> recipientAssignments;
  final Map<String, dynamic>? paymentSummaryPreview;

  final String? appliedCouponCode;
  final double discountAmount;
  final String? couponMessage;

  CheckoutState({
    this.isLoading = false,
    this.error,
    this.selectedTickets = const {},
    this.totalAmount = 0.0,
    this.currentStep = CheckoutStep.selection,
    this.paymentMethod = 'wallet',
    this.savedCards = const [],
    this.selectedCardId,
    this.walletBalance = 0.0,
    this.bonusBalance = 0.0,
    this.ticketOrder = const [],
    this.recipientAssignments = const {},
    this.paymentSummaryPreview,
    this.appliedCouponCode,
    this.discountAmount = 0.0,
    this.couponMessage,
  });

  final double walletBalance;

  CheckoutState copyWith({
    bool? isLoading,
    String? error,
    Map<int, int>? selectedTickets,
    double? totalAmount,
    CheckoutStep? currentStep,
    String? paymentMethod,
    List<CreditCardModel>? savedCards,
    String? selectedCardId,
    double? walletBalance,
    double? bonusBalance,
    List<int>? ticketOrder,
    Map<String, TicketRecipientAssignment>? recipientAssignments,
    Map<String, dynamic>? paymentSummaryPreview,
    String? appliedCouponCode,
    double? discountAmount,
    String? couponMessage,
    bool clearCoupon = false,
    bool clearPaymentSummaryPreview = false,
  }) {
    return CheckoutState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedTickets: selectedTickets ?? this.selectedTickets,
      totalAmount: totalAmount ?? this.totalAmount,
      currentStep: currentStep ?? this.currentStep,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      savedCards: savedCards ?? this.savedCards,
      selectedCardId: selectedCardId ?? this.selectedCardId,
      walletBalance: walletBalance ?? this.walletBalance,
      bonusBalance: bonusBalance ?? this.bonusBalance,
      ticketOrder: ticketOrder ?? this.ticketOrder,
      recipientAssignments: recipientAssignments ?? this.recipientAssignments,
      paymentSummaryPreview: clearPaymentSummaryPreview
          ? null
          : (paymentSummaryPreview ?? this.paymentSummaryPreview),
      appliedCouponCode: clearCoupon
          ? null
          : (appliedCouponCode ?? this.appliedCouponCode),
      discountAmount: clearCoupon
          ? 0.0
          : (discountAmount ?? this.discountAmount),
      couponMessage: clearCoupon ? null : (couponMessage ?? this.couponMessage),
    );
  }
}

class CheckoutNotifier extends StateNotifier<CheckoutState> {
  final BookingRepository _repository;

  CheckoutNotifier(this._repository) : super(CheckoutState());

  void configureTicketOrder(List<int> ticketOrder) {
    final sanitizedOrder = ticketOrder.toSet().toList(growable: false);
    state = state.copyWith(
      ticketOrder: sanitizedOrder,
      recipientAssignments: _sanitizeRecipientAssignments(
        selectedTickets: state.selectedTickets,
        recipientAssignments: state.recipientAssignments,
        ticketOrder: sanitizedOrder,
      ),
    );
  }

  void startCheckoutSession(List<int> ticketOrder) {
    final sanitizedOrder = ticketOrder.toSet().toList(growable: false);
    final preservedCards = List<CreditCardModel>.from(state.savedCards);
    final preservedSelectedCardId = state.selectedCardId;
    final preservedWalletBalance = state.walletBalance;
    final preservedBonusBalance = state.bonusBalance;

    state = CheckoutState(
      savedCards: preservedCards,
      selectedCardId: preservedSelectedCardId,
      walletBalance: preservedWalletBalance,
      bonusBalance: preservedBonusBalance,
      applyWalletBalance: preservedWalletBalance > 0,
      applyBonusBalance: preservedBonusBalance > 0,
      ticketOrder: sanitizedOrder,
    );
  }

  List<int> _buildQuantityList() {
    final orderedIds = state.ticketOrder.isNotEmpty
        ? state.ticketOrder
        : state.selectedTickets.keys.toList(growable: false);

    return orderedIds
        .map((ticketId) => state.selectedTickets[ticketId] ?? 0)
        .toList(growable: false);
  }

  Map<String, TicketRecipientAssignment> _sanitizeRecipientAssignments({
    required Map<int, int> selectedTickets,
    required Map<String, TicketRecipientAssignment> recipientAssignments,
    required List<int> ticketOrder,
  }) {
    final validSlotKeys = <String>{};
    final orderedIds = ticketOrder.isNotEmpty
        ? ticketOrder
        : selectedTickets.keys.toList(growable: false);

    for (final ticketId in orderedIds) {
      final qty = selectedTickets[ticketId] ?? 0;
      for (var unit = 1; unit <= qty; unit++) {
        validSlotKeys.add('$ticketId:$unit');
      }
    }

    final sanitized = <String, TicketRecipientAssignment>{};
    for (final entry in recipientAssignments.entries) {
      if (validSlotKeys.contains(entry.key)) {
        sanitized[entry.key] = entry.value;
      }
    }

    return sanitized;
  }

  Future<void> fetchSavedCards() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final methods = await _repository.getPaymentMethods();
      final cards = methods
          .map(
            (m) => CreditCardModel(
              id: m['stripe_payment_method_id'],
              last4: m['last4'] ?? '****',
              brand: m['brand'] ?? 'card',
              expiry: m['exp_month'] != null
                  ? "${m['exp_month']}/${m['exp_year']}"
                  : '',
            ),
          )
          .toList();

      state = state.copyWith(
        savedCards: cards,
        isLoading: false,
        // Default to first card if exists and none selected
        selectedCardId:
            state.selectedCardId ?? (cards.isNotEmpty ? cards.first.id : null),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _extractErrorMessage(e));
    }
  }

  Future<void> fetchWallet() async {
    try {
      final wallet = await _repository.getWallet();
      final balance = _readBalance(wallet['balance']);
      state = state.copyWith(
        walletBalance: (wallet['balance'] as num).toDouble(),
      );
    } catch (e) {
      appLog("Error fetching wallet: $e");
    }
  }

  Future<void> fetchBonusWallet() async {
    try {
      final wallet = await _repository.getBonusWallet();
      final balance = _readBalance(wallet['balance']);
      state = state.copyWith(
        bonusBalance: balance,
        applyBonusBalance: state.bonusBalance == 0
            ? balance > 0
            : state.applyBonusBalance,
      );
    } catch (e) {
      appLog("Error fetching bonus wallet: $e");
    }
  }

  String _extractErrorMessage(dynamic e) {
    if (e is DioException) {
      if (e.response?.data != null && e.response?.data is Map) {
        final data = e.response!.data as Map;
        if (data['validation_errors'] is Map) {
          final validationErrors = data['validation_errors'] as Map;
          for (final value in validationErrors.values) {
            if (value is List && value.isNotEmpty) {
              return value.first.toString();
            }
            if (value != null) {
              return value.toString();
            }
          }
        }

        return (data['message'] ?? data['error'] ?? e.message)?.toString() ??
            "Network error";
      }
      return e.message ?? "Network error";
    }
    return e.toString();
  }

  void updateQuantity(int ticketId, int quantity, double price) {
    final updatedTickets = Map<int, int>.from(state.selectedTickets);
    if (quantity > 0) {
      updatedTickets[ticketId] = quantity;
    } else {
      updatedTickets.remove(ticketId);
    }

    state = state.copyWith(
      selectedTickets: updatedTickets,
      recipientAssignments: _sanitizeRecipientAssignments(
        selectedTickets: updatedTickets,
        recipientAssignments: state.recipientAssignments,
        ticketOrder: state.ticketOrder,
      ),
      clearPaymentSummaryPreview: true,
    );
  }

  void assignRecipient(String slotKey, TicketRecipientAssignment assignment) {
    final updatedAssignments = Map<String, TicketRecipientAssignment>.from(
      state.recipientAssignments,
    );
    updatedAssignments[slotKey] = assignment;
    state = state.copyWith(
      recipientAssignments: _sanitizeRecipientAssignments(
        selectedTickets: state.selectedTickets,
        recipientAssignments: updatedAssignments,
        ticketOrder: state.ticketOrder,
      ),
      clearPaymentSummaryPreview: true,
    );
  }

  void clearRecipient(String slotKey) {
    final updatedAssignments = Map<String, TicketRecipientAssignment>.from(
      state.recipientAssignments,
    );
    updatedAssignments.remove(slotKey);
    state = state.copyWith(
      recipientAssignments: updatedAssignments,
      clearPaymentSummaryPreview: true,
    );
  }

  void setTotal(double total) {
    state = state.copyWith(totalAmount: total);
  }

  void goToStep(CheckoutStep step) {
    state = state.copyWith(currentStep: step);
  }

  void setPaymentMethod(String method) {
    state = state.copyWith(paymentMethod: method);
  }

  void toggleWalletBalance(bool value) {
    state = state.copyWith(
      applyWalletBalance: value,
      clearPaymentSummaryPreview: true,
    );
  }

  void toggleBonusBalance(bool value) {
    state = state.copyWith(
      applyBonusBalance: value,
      clearPaymentSummaryPreview: true,
    );
  }

  void setWalletBalance(double balance) {
    state = state.copyWith(walletBalance: balance);
  }

  void selectCard(String cardId) {
    state = state.copyWith(
      selectedCardId: cardId,
      paymentMethod: 'card',
      clearPaymentSummaryPreview: true,
    );
  }

  Future<void> previewCheckout({
    required int eventId,
    required String pricingType,
    int eventGuestCheckoutStatus = 1,
    String gateway = 'stripe',
  }) async {
    final quantityList = _buildQuantityList();
    final hasSelection = quantityList.any((qty) => qty > 0);
    if (!hasSelection) {
      state = state.copyWith(clearPaymentSummaryPreview: true);
      return;
    }

    try {
      final response = await _repository.verifyCheckout({
        'event_id': eventId,
        'quantity': quantityList,
        'event_guest_checkout_status': eventGuestCheckoutStatus,
        'pricing_type': pricingType,
        'gateway': gateway,
        'apply_wallet_balance': state.applyWalletBalance,
        'apply_bonus_balance': state.applyBonusBalance,
      });

      final summary = response['payment_summary'];
      if (summary is Map) {
        state = state.copyWith(
          paymentSummaryPreview: Map<String, dynamic>.from(summary),
        );
        return;
      }
    } catch (e) {
      appLog('Error previewing checkout summary: $e');
    }

    state = state.copyWith(clearPaymentSummaryPreview: true);
  }

  Future<void> addNewCard() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // 1. Get Setup Intent client_secret from Backend
      final clientSecret = await _repository.createSetupIntent();

      // 2. Present Setup Sheet
      final success = await StripeService.instance.makePayment(
        setupIntentClientSecret: clientSecret,
        customerId: null, // Backend handle this via Customer ID in SetupIntent
      );

      if (success) {
        // 3. Refetch cards from backend (Webhook will have processed it)
        // We add a small delay to allow webhook processing
        await Future.delayed(const Duration(seconds: 2));
        await fetchSavedCards();
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> applyCoupon(
    String couponCode,
    int eventId,
    double earlyBirdDiscount,
  ) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final payload = {
        'coupon_code': couponCode,
        'price': state.totalAmount,
        'total_early_bird_dicount': earlyBirdDiscount,
        'event_id': eventId,
      };

      final response = await _repository.applyCoupon(payload);

      if (response['success'] == true) {
        state = state.copyWith(
          isLoading: false,
          appliedCouponCode: couponCode,
          discountAmount: (response['discount'] as num).toDouble(),
          couponMessage: response['message'],
          clearPaymentSummaryPreview: true,
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response['message'] ?? 'Cupón inválido',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _extractErrorMessage(e));
      return false;
    }
  }

  void removeCoupon() {
    state = state.copyWith(
      clearCoupon: true,
      clearPaymentSummaryPreview: true,
    );
  }

  Future<Map<String, dynamic>> submitOrder(
    Map<String, dynamic> bookingPayload,
  ) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final orderedTicketIds = state.ticketOrder.isNotEmpty
          ? state.ticketOrder
          : state.selectedTickets.keys.toList(growable: false);

      final List<Map<String, dynamic>> selTickets = [];
      for (final ticketId in orderedTicketIds) {
        final qty = state.selectedTickets[ticketId] ?? 0;
        if (qty > 0) {
          selTickets.add({'ticket_id': ticketId, 'qty': qty});
        }
      }
      bookingPayload['selTickets'] = selTickets;
      bookingPayload['apply_wallet_balance'] = state.applyWalletBalance;
      bookingPayload['apply_bonus_balance'] = state.applyBonusBalance;

      final ticketRecipients = <Map<String, dynamic>>[];
      for (final ticketId in orderedTicketIds) {
        final qty = state.selectedTickets[ticketId] ?? 0;
        for (var unitIndex = 1; unitIndex <= qty; unitIndex++) {
          final slotKey = '$ticketId:$unitIndex';
          final assignment = state.recipientAssignments[slotKey];
          if (assignment == null) {
            continue;
          }
          ticketRecipients.add(
            assignment.toBookingJson(
              slotKey: slotKey,
              ticketId: ticketId,
              unitIndex: unitIndex,
            ),
          );
        }
      }
      if (ticketRecipients.isNotEmpty) {
        bookingPayload['ticket_recipients'] = ticketRecipients;
      }

      final total = (bookingPayload['total'] as num?)?.toDouble() ?? 0.0;
      final fundingBreakdown = calculateFundingBreakdown(state, total);

      if (fundingBreakdown.requiresCard) {
        if (state.selectedCardId == null ||
            state.selectedCardId == 'new_card') {
          throw Exception(
            'Selecciona una tarjeta guardada para completar el saldo restante.',
          );
        }

        // Update payload for backend
        bookingPayload['paymentStatus'] = 'completed';
        bookingPayload['gateway'] = 'stripe';
        bookingPayload['gatewayType'] = 'online';
        bookingPayload['stripe_payment_method_id'] = state.selectedCardId;
      } else if (state.paymentMethod == 'wallet') {
        debugPrint("CheckoutProvider: Processing with Wallet");
        // Simulate minor processing delay
        await Future.delayed(const Duration(milliseconds: 500));

        // Update payload for backend
        bookingPayload['paymentStatus'] = 'completed';
        bookingPayload['gateway'] = 'wallet';
        bookingPayload['gatewayType'] = 'online';
      } else if (bookingPayload['gateway'] == 'stripe') {
        // Stripe Payment Sheet Flow
        final double totalPay = (bookingPayload['total'] as num).toDouble();

        // Create Payment Intent
        final amount = (totalPay * 100).toInt();
        final clientSecret = await StripeService.instance
            .createTestPaymentIntent(amount, 'dop');

        // Present Payment Sheet
        final success = await StripeService.instance.makePayment(
          paymentIntentClientSecret: clientSecret,
          customerEphemeralKeySecret: null,
          customerId: null, // Setup for guest for now
          currency: 'dop',
          amount: amount.toString(),
        );

        if (!success) {
          throw Exception("Payment cancelled or failed");
        }

        // Update payload for backend
        bookingPayload['paymentStatus'] = 'completed';
        bookingPayload['gateway'] = 'stripe';
        bookingPayload['gatewayType'] = 'online';
      }

      appLog(
        "CheckoutProvider: Creating Booking with payload: $bookingPayload",
      );
      final response = await _repository.createBooking(bookingPayload);

      state = state.copyWith(isLoading: false);

      appLog("CheckoutProvider: Booking Response: $response");

      if (response['status'] == 'success' || response['booking_info'] != null) {
        return response;
      } else if (response.containsKey('validation_errors')) {
        throw Exception("Validation Error: ${response['validation_errors']}");
      } else {
        throw Exception(
          "Booking failed: ${response['message'] ?? 'Unknown Error'}",
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<Map<String, dynamic>> submitCustomOrder(
    Map<String, dynamic> cardDetails,
    Map<String, dynamic> bookingPayload,
  ) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final double totalPay = (bookingPayload['total'] as num).toDouble();
      final amount = (totalPay * 100).toInt();

      // 1. Create Payment Intent
      final clientSecret = await StripeService.instance.createTestPaymentIntent(
        amount,
        'dop',
      );

      // 2. Confirm Payment with Custom Card Details
      final expiryStr = cardDetails['expiry']?.toString() ?? '';
      int month, year;
      if (expiryStr.contains('/')) {
        final parts = expiryStr.split('/');
        month = int.parse(parts[0]);
        year = 2000 + int.parse(parts[1]);
      } else if (expiryStr.length == 4) {
        month = int.parse(expiryStr.substring(0, 2));
        year = 2000 + int.parse(expiryStr.substring(2, 4));
      } else {
        throw Exception("Invalid expiry date format.");
      }

      await StripeService.instance.confirmCustomPayment(
        clientSecret: clientSecret,
        number: cardDetails['number']?.toString() ?? '',
        expMonth: month,
        expYear: year,
        cvc: cardDetails['cvv']?.toString() ?? '',
        name: cardDetails['name']?.toString() ?? 'Customer',
      );

      // 3. Create Booking
      bookingPayload['paymentStatus'] = 'completed';
      bookingPayload['gateway'] = 'stripe';
      bookingPayload['gatewayType'] = 'online';

      final response = await _repository.createBooking(bookingPayload);

      state = state.copyWith(isLoading: false);

      debugPrint("CheckoutProvider: Custom Booking Response: $response");

      if (response['status'] == 'success' || response['booking_info'] != null) {
        if (response.containsKey('booking_info')) {
          return response['booking_info'];
        }
        return response;
      } else if (response.containsKey('validation_errors')) {
        throw Exception("Validation Error: ${response['validation_errors']}");
      } else {
        throw Exception(
          "Booking failed: ${response['message'] ?? 'Unknown Error'}",
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }
}

final checkoutProvider =
    StateNotifierProvider.autoDispose<CheckoutNotifier, CheckoutState>((ref) {
      return CheckoutNotifier(ref.watch(bookingRepositoryProvider));
    });
