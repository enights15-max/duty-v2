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

// Checkout State
class CheckoutState {
  final bool isLoading;
  final String? error;
  final Map<int, int> selectedTickets; // ticketId -> quantity
  final double totalAmount;

  CheckoutState({
    this.isLoading = false,
    this.error,
    this.selectedTickets = const {},
    this.totalAmount = 0.0,
  });

  CheckoutState copyWith({
    bool? isLoading,
    String? error,
    Map<int, int>? selectedTickets,
    double? totalAmount,
  }) {
    return CheckoutState(
      isLoading: isLoading ?? this.isLoading,
      error: error, // Reset error if not provided (or handle explicitly)
      selectedTickets: selectedTickets ?? this.selectedTickets,
      totalAmount: totalAmount ?? this.totalAmount,
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
        // Navigate or return success signal
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
