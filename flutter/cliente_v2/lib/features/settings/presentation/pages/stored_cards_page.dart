import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/colors.dart';

class StoredCardsPage extends StatelessWidget {
  const StoredCardsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.dutyTheme;
    final cardsAsync = ref.watch(paymentMethodsProvider);

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: palette.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'STORED CARDS',
          style: GoogleFonts.splineSans(
            color: palette.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'YOUR PAYMENT METHODS',
                style: GoogleFonts.splineSans(
                  color: palette.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 16),

              // Dummy Card 1
              _buildCreditCard(
                cardHolder: 'John Doe',
                cardNumber: '**** **** **** 4412',
                expiryDate: '12/26',
                cardType: 'VISA',
                gradientColors: [
                  const Color(0xFF6A11CB),
                  const Color(0xFF2575FC),
                ],
              ),
              const SizedBox(height: 16),

              // Add New Card Button
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                    style: BorderStyle.solid,
                  ),
                  error: (e, _) => Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: palette.textMuted,
                          size: 48,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Could not load cards',
                          style: GoogleFonts.splineSans(
                            color: palette.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () =>
                              ref.invalidate(paymentMethodsProvider),
                          child: const Text(
                            'Retry',
                            style: TextStyle(color: kPrimaryColor),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add New Card',
                      style: GoogleFonts.splineSans(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardsList(
    BuildContext context,
    WidgetRef ref,
    List<Map<String, dynamic>> cards,
  ) {
    final palette = context.dutyTheme;
    return RefreshIndicator(
      color: kPrimaryColor,
      backgroundColor: palette.surface,
      onRefresh: () async {
        ref.invalidate(paymentMethodsProvider);
        // Add a slight delay just to show the refresh animation completely
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: ListView(
        physics:
            const AlwaysScrollableScrollPhysics(), // Required for RefreshIndicator to work when the list is small or empty
        children: [
          // Real saved cards
          ...cards.map((card) {
            final brand = (card['brand'] ?? 'Card').toString().toUpperCase();
            final last4 = card['last4'] ?? '****';
            final expMonth =
                card['exp_month']?.toString().padLeft(2, '0') ?? '--';
            final expYear = card['exp_year']?.toString() ?? '--';
            final expYearShort = expYear.length >= 4
                ? expYear.substring(2)
                : expYear;
            final isDefault =
                card['is_default'] == 1 || card['is_default'] == true;

            final String cardId = card['id']?.toString() ?? '';
            final paymentMethodId =
                card['stripe_payment_method_id']?.toString() ?? cardId;

            return Dismissible(
              key: Key(paymentMethodId),
              direction: DismissDirection.endToStart,
              confirmDismiss: (direction) async {
                return await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      backgroundColor: palette.surface,
                      title: Text(
                        'Delete Card',
                        style: GoogleFonts.splineSans(
                          color: palette.textPrimary,
                        ),
                      ),
                      content: Text(
                        'Are you sure you want to delete this $brand ending in $last4?',
                        style: GoogleFonts.splineSans(
                          color: palette.textSecondary,
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: Text(
                            'Cancel',
                            style: TextStyle(color: palette.textMuted),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: Text(
                            'Delete',
                            style: TextStyle(color: palette.danger),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
              onDismissed: (direction) {
                _handleDeleteCard(context, ref, paymentMethodId);
              },
              background: Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: palette.danger.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 24),
                child: Icon(
                  Icons.delete_outline_rounded,
                  color: palette.onPrimary,
                  size: 32,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _buildCreditCard(
                  cardHolder: isDefault ? 'DEFAULT CARD' : 'SAVED CARD',
                  cardNumber: '**** **** **** $last4',
                  expiryDate: '$expMonth/$expYearShort',
                  cardType: brand,
                  gradientColors: _brandGradient(brand),
                ),
              ),
            );
          }),

          // Add New Card Button
          GestureDetector(
            onTap: () => _handleAddCard(context, ref),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: BoxDecoration(
                color: palette.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: palette.border),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.add_circle_outline_rounded,
                    color: palette.textMuted,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add New Card',
                    style: GoogleFonts.splineSans(
                      color: palette.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Empty state hint
          if (cards.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Text(
                'No cards saved yet. Add a card to enable quick payments for tickets and wallet top-ups.',
                textAlign: TextAlign.center,
                style: GoogleFonts.splineSans(
                  color: palette.textMuted,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _handleAddCard(BuildContext context, WidgetRef ref) async {
    final palette = context.dutyTheme;
    final messenger = ScaffoldMessenger.of(context);

    try {
      messenger.showSnackBar(
        const SnackBar(content: Text('Setting up card...')),
      );

      final repository = ref.read(walletRepositoryProvider);
      final token = await ref.read(authTokenProvider.future);
      if (token == null) {
        messenger.hideCurrentSnackBar();
        messenger.showSnackBar(
          SnackBar(
            content: Text('Please log in to add a card'),
            backgroundColor: palette.danger,
          ),
        );
        return;
      }

      // Get SetupIntent from backend
      final clientSecret = await repository.createSetupIntent(token: token);

      messenger.hideCurrentSnackBar();

      if (!context.mounted) return;

      // Present custom Setup Sheet
      final success = await CardSetupSheet.show(
        context: context,
        clientSecret: clientSecret,
        title: 'Save New Card',
      );

      if (success) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('Card saved successfully!'),
            backgroundColor: palette.success,
          ),
        );
        // Refresh the cards list
        ref.invalidate(paymentMethodsProvider);
      }
    } catch (e) {
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          content: Text('Failed to add card: $e'),
          backgroundColor: palette.danger,
        ),
      );
    }
  }

  Future<void> _handleDeleteCard(
    BuildContext context,
    WidgetRef ref,
    String paymentMethodId,
  ) async {
    final palette = context.dutyTheme;
    final messenger = ScaffoldMessenger.of(context);

    try {
      final repository = ref.read(walletRepositoryProvider);
      final token = await ref.read(authTokenProvider.future);

      if (token != null) {
        final success = await repository.deletePaymentMethod(
          token: token,
          paymentMethodId: paymentMethodId,
        );

        if (success) {
          messenger.showSnackBar(
            SnackBar(
              content: Text('Card deleted successfully'),
              backgroundColor: palette.success,
            ),
          );
        } else {
          messenger.showSnackBar(
            SnackBar(
              content: Text('Failed to delete card'),
              backgroundColor: palette.danger,
            ),
          );
          // If deletion failed, we need to refresh to show the card again
          ref.invalidate(paymentMethodsProvider);
        }
      }
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Error deleting card: $e'),
          backgroundColor: palette.danger,
        ),
      );
      // Retrieve the list again to restore the UI because optimistic deletion failed
      ref.invalidate(paymentMethodsProvider);
    }
  }

  List<Color> _brandGradient(String brand) {
    switch (brand) {
      case 'VISA':
        return [const Color(0xFF6A11CB), const Color(0xFF2575FC)];
      case 'MASTERCARD':
        return [const Color(0xFFEB001B), const Color(0xFFF79E1B)];
      case 'AMEX':
        return [const Color(0xFF006FCF), const Color(0xFF00B3E3)];
      case 'DISCOVER':
        return [const Color(0xFFFF6000), const Color(0xFFFFA500)];
      default:
        return [kGraphiteWine, kPrimaryColor];
    }
  }

  Widget _buildCreditCard({
    required String cardHolder,
    required String cardNumber,
    required String expiryDate,
    required String cardType,
    required List<Color> gradientColors,
  }) {
    return Container(
      width: double.infinity,
      height: 200,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        boxShadow: [
          BoxShadow(
            color: gradientColors[0].withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(
                Icons.contactless_rounded,
                color: Colors.white,
                size: 28,
              ),
              Text(
                cardType,
                style: GoogleFonts.splineSans(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          Text(
            cardNumber,
            style: GoogleFonts.splineSans(
              color: Colors.white,
              fontSize: 22,
              letterSpacing: 4.0,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Card Holder',
                    style: GoogleFonts.splineSans(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 10,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    cardHolder.toUpperCase(),
                    style: GoogleFonts.splineSans(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2.0,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Expires',
                    style: GoogleFonts.splineSans(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 10,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    expiryDate,
                    style: GoogleFonts.splineSans(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2.0,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
