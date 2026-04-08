import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/app_logger.dart';
import '../../../../core/widgets/card_setup_sheet.dart';
import '../../data/models/reservation_model.dart';
import '../../data/repositories/reservation_repository.dart';
import '../../data/repositories/booking_repository.dart';
import 'checkout_provider.dart' show bookingRepositoryProvider;

final reservationsProvider = FutureProvider.autoDispose<List<ReservationModel>>(
  (ref) async {
    return ref.watch(reservationRepositoryProvider).getReservations();
  },
);

final reservationDetailsProvider = FutureProvider.family
    .autoDispose<ReservationModel, int>((ref, id) async {
      return ref.watch(reservationRepositoryProvider).getReservation(id);
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

class ReservationCardModel {
  final String id;
  final String last4;
  final String brand;
  final String expiry;

  const ReservationCardModel({
    required this.id,
    required this.last4,
    required this.brand,
    required this.expiry,
  });
}

class ReservationFundingBreakdown {
  final double amount;
  final double bonusApplied;
  final double walletApplied;
  final double cardAmount;

  const ReservationFundingBreakdown({
    required this.amount,
    required this.bonusApplied,
    required this.walletApplied,
    required this.cardAmount,
  });

  bool get requiresCard => cardAmount > 0.009;
  bool get usesInternalBalance => bonusApplied > 0.009 || walletApplied > 0.009;
}

class ReservationFlowState {
  final bool isLoading;
  final String? error;
  final List<ReservationCardModel> savedCards;
  final String? selectedCardId;
  final bool applyWalletBalance;
  final bool applyBonusBalance;
  final double walletBalance;
  final double bonusBalance;

  const ReservationFlowState({
    this.isLoading = false,
    this.error,
    this.savedCards = const [],
    this.selectedCardId,
    this.applyWalletBalance = false,
    this.applyBonusBalance = false,
    this.walletBalance = 0,
    this.bonusBalance = 0,
  });

  ReservationFlowState copyWith({
    bool? isLoading,
    String? error,
    List<ReservationCardModel>? savedCards,
    String? selectedCardId,
    bool? applyWalletBalance,
    bool? applyBonusBalance,
    double? walletBalance,
    double? bonusBalance,
  }) {
    return ReservationFlowState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      savedCards: savedCards ?? this.savedCards,
      selectedCardId: selectedCardId ?? this.selectedCardId,
      applyWalletBalance: applyWalletBalance ?? this.applyWalletBalance,
      applyBonusBalance: applyBonusBalance ?? this.applyBonusBalance,
      walletBalance: walletBalance ?? this.walletBalance,
      bonusBalance: bonusBalance ?? this.bonusBalance,
    );
  }
}

class ReservationFlowNotifier extends StateNotifier<ReservationFlowState> {
  final ReservationRepository _reservationRepository;
  final BookingRepository _bookingRepository;

  ReservationFlowNotifier(this._reservationRepository, this._bookingRepository)
    : super(const ReservationFlowState());

  Future<void> bootstrap() async {
    await Future.wait([fetchWallet(), fetchBonusWallet(), fetchSavedCards()]);
  }

  ReservationFundingBreakdown calculateBreakdown(double amount) {
    var remaining = amount;
    final bonusApplied = state.applyBonusBalance
        ? (remaining < state.bonusBalance ? remaining : state.bonusBalance)
        : 0.0;
    remaining -= bonusApplied;

    final walletApplied = state.applyWalletBalance
        ? (remaining < state.walletBalance ? remaining : state.walletBalance)
        : 0.0;
    remaining -= walletApplied;

    return ReservationFundingBreakdown(
      amount: amount,
      bonusApplied: bonusApplied,
      walletApplied: walletApplied,
      cardAmount: remaining < 0 ? 0 : remaining,
    );
  }

  Future<void> fetchSavedCards() async {
    try {
      final methods = await _bookingRepository.getPaymentMethods();
      final cards = methods
          .map(
            (item) => ReservationCardModel(
              id: item['stripe_payment_method_id']?.toString() ?? '',
              last4: item['last4']?.toString() ?? '****',
              brand: item['brand']?.toString() ?? 'card',
              expiry: item['exp_month'] != null
                  ? '${item['exp_month']}/${item['exp_year']}'
                  : '',
            ),
          )
          .where((card) => card.id.isNotEmpty)
          .toList();

      state = state.copyWith(
        savedCards: cards,
        selectedCardId:
            state.selectedCardId ?? (cards.isNotEmpty ? cards.first.id : null),
      );
    } catch (error) {
      appLog('ReservationFlowNotifier.fetchSavedCards error: $error');
    }
  }

  Future<void> fetchWallet() async {
    try {
      final wallet = await _bookingRepository.getWallet();
      final balance = _readBalance(wallet['balance']);
      state = state.copyWith(
        walletBalance: balance,
        applyWalletBalance: state.walletBalance == 0
            ? balance > 0
            : state.applyWalletBalance,
      );
    } catch (error) {
      appLog('ReservationFlowNotifier.fetchWallet error: $error');
    }
  }

  Future<void> fetchBonusWallet() async {
    try {
      final wallet = await _bookingRepository.getBonusWallet();
      final balance = _readBalance(wallet['balance']);
      state = state.copyWith(
        bonusBalance: balance,
        applyBonusBalance: state.bonusBalance == 0
            ? balance > 0
            : state.applyBonusBalance,
      );
    } catch (error) {
      appLog('ReservationFlowNotifier.fetchBonusWallet error: $error');
    }
  }

  void toggleWalletBalance(bool value) {
    state = state.copyWith(applyWalletBalance: value);
  }

  void toggleBonusBalance(bool value) {
    state = state.copyWith(applyBonusBalance: value);
  }

  void selectCard(String cardId) {
    state = state.copyWith(selectedCardId: cardId);
  }

  Future<void> addNewCard(BuildContext context) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final clientSecret = await _bookingRepository.createSetupIntent();
      state = state.copyWith(isLoading: false);
      if (!context.mounted) {
        return;
      }

      final success = await CardSetupSheet.show(
        context: context,
        clientSecret: clientSecret,
        title: 'Guardar tarjeta',
      );

      if (!success) {
        return;
      }

      state = state.copyWith(isLoading: true);
      await Future.delayed(const Duration(seconds: 2));
      await fetchSavedCards();
      state = state.copyWith(isLoading: false);
    } catch (error) {
      state = state.copyWith(isLoading: false, error: error.toString());
    }
  }

  Future<ReservationModel> createReservation({
    required int ticketId,
    required int quantity,
    required double paymentAmount,
    required String? eventDate,
    Map<String, dynamic>? currentUser,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final breakdown = calculateBreakdown(paymentAmount);
      final payload = <String, dynamic>{
        'ticket_id': ticketId,
        'quantity': quantity,
        'event_date': eventDate,
        'payment_amount': paymentAmount,
        'gateway': _resolveGateway(breakdown),
        'apply_wallet_balance': state.applyWalletBalance,
        'apply_bonus_balance': state.applyBonusBalance,
        'fname': currentUser?['fname'],
        'lname': currentUser?['lname'],
        'email': currentUser?['email'],
        'phone': currentUser?['phone'],
        'country': currentUser?['country'],
        'state': currentUser?['state'],
        'city': currentUser?['city'],
        'zip_code': currentUser?['zip_code'],
        'address': currentUser?['address'],
      };

      if (breakdown.requiresCard) {
        if (state.selectedCardId == null) {
          throw Exception(
            'Selecciona una tarjeta guardada para cubrir el saldo restante.',
          );
        }
        payload['stripe_payment_method_id'] = state.selectedCardId;
      }

      final reservation = await _reservationRepository.createReservation(
        payload,
      );
      state = state.copyWith(isLoading: false);
      return reservation;
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: _extractErrorMessage(error),
      );
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> previewReservation({
    required int ticketId,
    required int quantity,
    required double paymentAmount,
    required String? eventDate,
  }) async {
    try {
      final breakdown = calculateBreakdown(paymentAmount);
      final payload = <String, dynamic>{
        'ticket_id': ticketId,
        'quantity': quantity,
        'event_date': eventDate,
        'payment_amount': paymentAmount,
        'gateway': _resolveGateway(breakdown),
        'apply_wallet_balance': state.applyWalletBalance,
        'apply_bonus_balance': state.applyBonusBalance,
      };

      if (breakdown.requiresCard && state.selectedCardId != null) {
        payload['stripe_payment_method_id'] = state.selectedCardId;
      }

      return await _reservationRepository.previewReservation(payload);
    } catch (error) {
      state = state.copyWith(error: _extractErrorMessage(error));
      return null;
    }
  }

  Future<ReservationModel> payReservation({
    required int reservationId,
    required double paymentAmount,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final breakdown = calculateBreakdown(paymentAmount);
      final payload = <String, dynamic>{
        'payment_amount': paymentAmount,
        'gateway': _resolveGateway(breakdown),
        'apply_wallet_balance': state.applyWalletBalance,
        'apply_bonus_balance': state.applyBonusBalance,
      };

      if (breakdown.requiresCard) {
        if (state.selectedCardId == null) {
          throw Exception(
            'Selecciona una tarjeta guardada para cubrir el saldo restante.',
          );
        }
        payload['stripe_payment_method_id'] = state.selectedCardId;
      }

      final reservation = await _reservationRepository.payReservation(
        reservationId,
        payload,
      );
      state = state.copyWith(isLoading: false);
      return reservation;
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: _extractErrorMessage(error),
      );
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> previewReservationPayment({
    required int reservationId,
    required double paymentAmount,
  }) async {
    try {
      final breakdown = calculateBreakdown(paymentAmount);
      final payload = <String, dynamic>{
        'payment_amount': paymentAmount,
        'gateway': _resolveGateway(breakdown),
        'apply_wallet_balance': state.applyWalletBalance,
        'apply_bonus_balance': state.applyBonusBalance,
      };

      if (breakdown.requiresCard && state.selectedCardId != null) {
        payload['stripe_payment_method_id'] = state.selectedCardId;
      }

      return await _reservationRepository.previewReservationPayment(
        reservationId,
        payload,
      );
    } catch (error) {
      state = state.copyWith(error: _extractErrorMessage(error));
      return null;
    }
  }

  String _resolveGateway(ReservationFundingBreakdown breakdown) {
    if (breakdown.requiresCard) {
      return breakdown.usesInternalBalance ? 'mixed' : 'stripe';
    }
    if (breakdown.bonusApplied > 0.009 && breakdown.walletApplied > 0.009) {
      return 'mixed';
    }
    if (breakdown.bonusApplied > 0.009) {
      return 'bonus';
    }
    if (breakdown.walletApplied > 0.009) {
      return 'wallet';
    }
    throw Exception(
      'Activa wallet/bono o selecciona una tarjeta para completar el pago.',
    );
  }

  String _extractErrorMessage(dynamic error) {
    if (error is DioException) {
      if (error.response?.data is Map) {
        final payload = error.response!.data as Map;
        return payload['message']?.toString() ??
            payload['error']?.toString() ??
            error.message ??
            'Network error';
      }
      return error.message ?? 'Network error';
    }
    return error.toString();
  }
}

final reservationFlowProvider =
    StateNotifierProvider.autoDispose<
      ReservationFlowNotifier,
      ReservationFlowState
    >((ref) {
      return ReservationFlowNotifier(
        ref.watch(reservationRepositoryProvider),
        ref.watch(bookingRepositoryProvider),
      );
    });
