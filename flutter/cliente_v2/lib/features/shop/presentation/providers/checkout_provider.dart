import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/api_client.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart'; // To get ApiClient/Auth info if needed
import '../../data/datasources/booking_remote_data_source.dart';
import '../../data/repositories/booking_repository.dart';

// Data Layer Providers
final bookingRemoteDataSourceProvider = Provider<BookingRemoteDataSource>((
  ref,
) {
  return BookingRemoteDataSource(
    ApiClient(),
  ); // Or ref.watch(apiClientProvider)
});

final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  return BookingRepository(ref.watch(bookingRemoteDataSourceProvider));
});

<<<<<<< Updated upstream
=======
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

// Checkout Steps
enum CheckoutStep { selection, payment, confirmation }

class FundingBreakdown {
  final double subtotal;
  final double bonusApplied;
  final double walletApplied;
  final double cardAmount;

  const FundingBreakdown({
    required this.subtotal,
    required this.bonusApplied,
    required this.walletApplied,
    required this.cardAmount,
  });

  bool get requiresCard => cardAmount > 0.009;
  bool get usesInternalBalance => bonusApplied > 0.009 || walletApplied > 0.009;
}

FundingBreakdown calculateFundingBreakdown(
  CheckoutState state,
  double subtotal,
) {
  var remaining = subtotal;
  remaining -= state.discountAmount;
  if (remaining < 0) remaining = 0;

  final bonusApplied = state.applyBonusBalance
      ? (remaining < state.bonusBalance ? remaining : state.bonusBalance)
      : 0.0;
  remaining -= bonusApplied;

  final walletApplied = state.applyWalletBalance
      ? (remaining < state.walletBalance ? remaining : state.walletBalance)
      : 0.0;
  remaining -= walletApplied;

  return FundingBreakdown(
    subtotal: subtotal,
    bonusApplied: bonusApplied,
    walletApplied: walletApplied,
    cardAmount: remaining < 0 ? 0 : remaining,
  );
}

>>>>>>> Stashed changes
// Checkout State
class CheckoutState {
  final bool isLoading;
  final String? error;
  final Map<int, int> selectedTickets; // ticketId -> quantity
  final double totalAmount;

  final String? appliedCouponCode;
  final double discountAmount;
  final String? couponMessage;

  CheckoutState({
    this.isLoading = false,
    this.error,
    this.selectedTickets = const {},
    this.totalAmount = 0.0,
<<<<<<< Updated upstream
=======
    this.currentStep = CheckoutStep.selection,
    this.paymentMethod = 'wallet',
    this.savedCards = const [],
    this.selectedCardId,
    this.applyWalletBalance = false,
    this.applyBonusBalance = false,
    this.walletBalance = 0.0,
    this.bonusBalance = 0.0,
    this.appliedCouponCode,
    this.discountAmount = 0.0,
    this.couponMessage,
>>>>>>> Stashed changes
  });

  CheckoutState copyWith({
    bool? isLoading,
    String? error,
    Map<int, int>? selectedTickets,
    double? totalAmount,
<<<<<<< Updated upstream
=======
    CheckoutStep? currentStep,
    String? paymentMethod,
    List<CreditCardModel>? savedCards,
    String? selectedCardId,
    bool? applyWalletBalance,
    bool? applyBonusBalance,
    double? walletBalance,
    double? bonusBalance,
    String? appliedCouponCode,
    double? discountAmount,
    String? couponMessage,
    bool clearCoupon = false,
>>>>>>> Stashed changes
  }) {
    return CheckoutState(
      isLoading: isLoading ?? this.isLoading,
      error: error, // Reset error if not provided (or handle explicitly)
      selectedTickets: selectedTickets ?? this.selectedTickets,
      totalAmount: totalAmount ?? this.totalAmount,
<<<<<<< Updated upstream
=======
      currentStep: currentStep ?? this.currentStep,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      savedCards: savedCards ?? this.savedCards,
      selectedCardId: selectedCardId ?? this.selectedCardId,
      applyWalletBalance: applyWalletBalance ?? this.applyWalletBalance,
      applyBonusBalance: applyBonusBalance ?? this.applyBonusBalance,
      walletBalance: walletBalance ?? this.walletBalance,
      bonusBalance: bonusBalance ?? this.bonusBalance,
      appliedCouponCode: clearCoupon ? null : (appliedCouponCode ?? this.appliedCouponCode),
      discountAmount: clearCoupon ? 0.0 : (discountAmount ?? this.discountAmount),
      couponMessage: clearCoupon ? null : (couponMessage ?? this.couponMessage),
>>>>>>> Stashed changes
    );
  }
}

class CheckoutNotifier extends StateNotifier<CheckoutState> {
  final BookingRepository _repository;

  CheckoutNotifier(this._repository) : super(CheckoutState());

  void updateQuantity(int ticketId, int quantity, double price) {
    final updatedTickets = Map<int, int>.from(state.selectedTickets);
    if (quantity > 0) {
      updatedTickets[ticketId] = quantity;
    } else {
      updatedTickets.remove(ticketId);
    }

    // Recalculate total (Logic needs access to all ticket prices, often passed or stored)
    // For now, we update state. Detailed calculation should ideally be done
    // based on full ticket list or passed explicitly.
    // Simplifying: assumes caller updates total or we implement logic to fetch/store ticket models here.

    state = state.copyWith(selectedTickets: updatedTickets);
  }

  void setTotal(double total) {
    state = state.copyWith(totalAmount: total);
  }

  Future<void> submitOrder(Map<String, dynamic> bookingPayload) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // 1. Verify (Optional, depending on flow)
      // await _repository.verifyCheckout(...);

      // 2. Submit
      final result = await _repository.createBooking(bookingPayload);

      if (result['status'] == 'success' || result['alert_type'] == 'success') {
        // Success
        state = state.copyWith(isLoading: false);
<<<<<<< Updated upstream
        // Navigate or return success signal
=======
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> applyCoupon(String couponCode, int eventId, double earlyBirdDiscount) async {
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
    state = state.copyWith(clearCoupon: true);
  }

  Future<Map<String, dynamic>> submitOrder(
    Map<String, dynamic> bookingPayload,
  ) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // 1. Prepare variations (selTickets) for backend
      final List<Map<String, dynamic>> selTickets = [];
      state.selectedTickets.forEach((ticketId, qty) {
        if (qty > 0) {
          selTickets.add({'ticket_id': ticketId, 'qty': qty});
        }
      });
      bookingPayload['selTickets'] = selTickets;
      bookingPayload['apply_wallet_balance'] = state.applyWalletBalance;
      bookingPayload['apply_bonus_balance'] = state.applyBonusBalance;
      final total = (bookingPayload['total'] as num?)?.toDouble() ?? 0.0;
      final fundingBreakdown = calculateFundingBreakdown(state, total);

      // 2. Payment Logic
      if (fundingBreakdown.requiresCard) {
        if (state.selectedCardId == null ||
            state.selectedCardId == 'new_card') {
          throw Exception(
            'Selecciona una tarjeta guardada para completar el saldo restante.',
          );
        }

        bookingPayload['paymentStatus'] = 'completed';
        bookingPayload['gatewayType'] = 'online';
        bookingPayload['gateway'] = fundingBreakdown.usesInternalBalance
            ? 'mixed'
            : 'stripe';
        bookingPayload['stripe_payment_method_id'] = state.selectedCardId;
      } else {
        bookingPayload['paymentStatus'] = 'completed';
        bookingPayload['gatewayType'] = 'online';
        bookingPayload.remove('stripe_payment_method_id');

        if (fundingBreakdown.bonusApplied > 0 &&
            fundingBreakdown.walletApplied > 0) {
          bookingPayload['gateway'] = 'mixed';
        } else if (fundingBreakdown.bonusApplied > 0) {
          bookingPayload['gateway'] = 'bonus';
        } else if (fundingBreakdown.walletApplied > 0) {
          bookingPayload['gateway'] = 'wallet';
        } else if (state.selectedCardId != null &&
            state.selectedCardId != 'new_card') {
          bookingPayload['gateway'] = 'stripe';
          bookingPayload['stripe_payment_method_id'] = state.selectedCardId;
        } else {
          throw Exception(
            'Activa wallet/bono o selecciona una tarjeta para completar la compra.',
          );
        }
      }

      // 2. Create Booking (Only if payment succeeded)
      appLog(
        "CheckoutProvider: Creating Booking with payload: $bookingPayload",
      );
      final response = await _repository.createBooking(bookingPayload);

      // Success - State update managed by UI navigation, but we reset loading
      state = state.copyWith(isLoading: false);

      // Return booking info for navigation
      appLog("CheckoutProvider: Booking Response: $response");

      if (response['status'] == 'success' || response['booking_info'] != null) {
        if (response.containsKey('booking_info')) {
          return response['booking_info'];
        }
        return response;
      } else if (response.containsKey('validation_errors')) {
        throw Exception(
          "Validation Error: ${response['validation_errors']}",
        ); // Show backend validation error
>>>>>>> Stashed changes
      } else {
        throw Exception(
          result['message'] ?? result['error'] ?? 'Booking Failed',
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }
}

final checkoutProvider = StateNotifierProvider<CheckoutNotifier, CheckoutState>(
  (ref) {
    return CheckoutNotifier(ref.watch(bookingRepositoryProvider));
  },
);
