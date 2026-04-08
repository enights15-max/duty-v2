import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/card_setup_sheet.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../../features/shop/data/repositories/booking_repository.dart';
import '../../../../features/shop/presentation/providers/checkout_provider.dart';
import '../../data/datasources/review_prompt_remote_data_source.dart';
import '../../data/models/review_prompt_model.dart';
import '../../data/repositories/review_prompt_repository.dart';

final reviewPromptRemoteDataSourceProvider =
    Provider<ReviewPromptRemoteDataSource>((ref) {
      final apiClient = ref.watch(apiClientProvider);
      return ReviewPromptRemoteDataSource(apiClient);
    });

final reviewPromptRepositoryProvider = Provider<ReviewPromptRepository>((ref) {
  final dataSource = ref.watch(reviewPromptRemoteDataSourceProvider);
  return ReviewPromptRepository(dataSource);
});

final pendingReviewPromptsProvider = FutureProvider<List<ReviewPromptModel>>((
  ref,
) async {
  final repository = ref.watch(reviewPromptRepositoryProvider);
  return repository.getPendingReviews();
});

final pendingReviewTargetsCountProvider = Provider<int>((ref) {
  final asyncPrompts = ref.watch(pendingReviewPromptsProvider);
  return asyncPrompts.maybeWhen(
    data: (items) =>
        items.fold<int>(0, (sum, item) => sum + item.targets.length),
    orElse: () => 0,
  );
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

final reviewPromptActionProvider =
    StateNotifierProvider<ReviewPromptActionNotifier, AsyncValue<void>>((ref) {
      final repository = ref.watch(reviewPromptRepositoryProvider);
      return ReviewPromptActionNotifier(repository, ref);
    });

class ReviewPromptActionNotifier extends StateNotifier<AsyncValue<void>> {
  final ReviewPromptRepository _repository;
  final Ref _ref;

  ReviewPromptActionNotifier(this._repository, this._ref)
    : super(const AsyncValue.data(null));

  Future<void> submit({
    required String targetType,
    required int targetId,
    required int eventId,
    required int rating,
    String? comment,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _repository.submitReview(
        targetType: targetType,
        targetId: targetId,
        eventId: eventId,
        rating: rating,
        comment: comment,
      );
      _ref.invalidate(pendingReviewPromptsProvider);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }
}

class ArtistTipCardModel {
  final String id;
  final String last4;
  final String brand;
  final String expiry;

  const ArtistTipCardModel({
    required this.id,
    required this.last4,
    required this.brand,
    required this.expiry,
  });
}

class ArtistTipBreakdown {
  final double amount;
  final double walletApplied;
  final double cardAmount;

  const ArtistTipBreakdown({
    required this.amount,
    required this.walletApplied,
    required this.cardAmount,
  });

  bool get requiresCard => cardAmount > 0.009;
}

class ArtistTipFlowState {
  final bool isLoading;
  final String? error;
  final List<ArtistTipCardModel> savedCards;
  final String? selectedCardId;
  final bool applyWalletBalance;
  final double walletBalance;

  const ArtistTipFlowState({
    this.isLoading = false,
    this.error,
    this.savedCards = const [],
    this.selectedCardId,
    this.applyWalletBalance = false,
    this.walletBalance = 0,
  });

  ArtistTipFlowState copyWith({
    bool? isLoading,
    String? error,
    List<ArtistTipCardModel>? savedCards,
    String? selectedCardId,
    bool? applyWalletBalance,
    double? walletBalance,
  }) {
    return ArtistTipFlowState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      savedCards: savedCards ?? this.savedCards,
      selectedCardId: selectedCardId ?? this.selectedCardId,
      applyWalletBalance: applyWalletBalance ?? this.applyWalletBalance,
      walletBalance: walletBalance ?? this.walletBalance,
    );
  }
}

class ArtistTipFlowNotifier extends StateNotifier<ArtistTipFlowState> {
  final ReviewPromptRepository _reviewRepository;
  final BookingRepository _bookingRepository;

  ArtistTipFlowNotifier(this._reviewRepository, this._bookingRepository)
    : super(const ArtistTipFlowState());

  Future<void> bootstrap() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await Future.wait([fetchWallet(), fetchSavedCards()]);
      state = state.copyWith(isLoading: false);
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: _extractErrorMessage(error),
      );
    }
  }

  ArtistTipBreakdown calculateBreakdown(double amount) {
    final walletApplied = state.applyWalletBalance
        ? (amount < state.walletBalance ? amount : state.walletBalance)
        : 0.0;
    final cardAmount = amount - walletApplied;

    return ArtistTipBreakdown(
      amount: amount,
      walletApplied: walletApplied,
      cardAmount: cardAmount < 0 ? 0 : cardAmount,
    );
  }

  Future<void> fetchWallet() async {
    final wallet = await _bookingRepository.getWallet();
    final balance = _readBalance(wallet['balance']);
    state = state.copyWith(
      walletBalance: balance,
      applyWalletBalance: state.walletBalance == 0
          ? balance > 0
          : state.applyWalletBalance,
    );
  }

  Future<void> fetchSavedCards() async {
    final methods = await _bookingRepository.getPaymentMethods();
    final cards = methods
        .map(
          (item) => ArtistTipCardModel(
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
  }

  void toggleWalletBalance(bool value) {
    state = state.copyWith(applyWalletBalance: value);
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
        title: 'Guardar tarjeta para propina',
      );

      if (!success) {
        return;
      }

      state = state.copyWith(isLoading: true);
      await Future.delayed(const Duration(seconds: 2));
      await fetchSavedCards();
      state = state.copyWith(isLoading: false);
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: _extractErrorMessage(error),
      );
    }
  }

  Future<Map<String, dynamic>> submitTip({
    required int artistId,
    required int bookingId,
    required double amount,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final breakdown = calculateBreakdown(amount);
      if (breakdown.requiresCard && state.selectedCardId == null) {
        throw Exception(
          'Selecciona una tarjeta guardada para cubrir el resto de la propina.',
        );
      }

      final response = await _reviewRepository.submitArtistTip(
        artistId: artistId,
        bookingId: bookingId,
        amount: amount,
        applyWalletBalance: state.applyWalletBalance,
        stripePaymentMethodId: breakdown.requiresCard
            ? state.selectedCardId
            : null,
      );

      await fetchWallet();
      state = state.copyWith(isLoading: false);
      return response;
    } catch (error, stackTrace) {
      state = state.copyWith(
        isLoading: false,
        error: _extractErrorMessage(error),
      );
      Error.throwWithStackTrace(error, stackTrace);
    }
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

final artistTipFlowProvider =
    StateNotifierProvider.autoDispose<
      ArtistTipFlowNotifier,
      ArtistTipFlowState
    >((ref) {
      return ArtistTipFlowNotifier(
        ref.watch(reviewPromptRepositoryProvider),
        ref.watch(bookingRepositoryProvider),
      );
    });
