import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../providers/wallet_provider.dart';
import '../../../../core/services/stripe_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/providers/profile_state_provider.dart';
import '../../../../core/theme/colors.dart';
import '../../../../features/profile/domain/models/profile_model.dart';
import '../widgets/transfer_bottom_sheet.dart';

class WalletDetailsPage extends ConsumerWidget {
  const WalletDetailsPage({super.key});

  static const Color kPrimaryColor = Color(0xFFC1121F);
  static const Color kBackgroundDark = Color(0xFF100E14);

  Color _profileAccent(AppProfile? profile) {
    switch (profile?.type) {
      case ProfileType.artist:
        return const Color(0xFFD63A49);
      case ProfileType.venue:
        return const Color(0xFF9E2430);
      case ProfileType.organizer:
        return const Color(0xFF8A0F18);
      case ProfileType.personal:
      case null:
        return kPrimaryColor;
    }
  }

  String _walletTitle(AppProfile? profile) {
    switch (profile?.type) {
      case ProfileType.artist:
        return 'BILLETERA ARTISTA';
      case ProfileType.venue:
        return 'BILLETERA VENUE';
      case ProfileType.organizer:
        return 'BILLETERA ORGANIZER';
      case ProfileType.personal:
      case null:
        return 'BILLETERA PERSONAL';
    }
  }

  String _formatCurrency(num amount) {
    final formatted = NumberFormat('#,##0.00', 'en_US').format(amount);
    return 'RD\$$formatted';
  }

  void _handleBack(BuildContext context, AppProfile? activeProfile) {
    if (context.canPop()) {
      context.pop();
      return;
    }

    if (activeProfile == null || activeProfile.type == ProfileType.personal) {
      context.go('/home');
      return;
    }

    context.go('/dashboard');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.dutyTheme;
    final textColor = palette.textPrimary;
    final walletAsync = ref.watch(walletProvider);
    final historyAsync = ref.watch(walletHistoryProvider);
    final activeProfile = ref.watch(activeProfileProvider);
    final accent = _profileAccent(activeProfile);

    return Scaffold(
      backgroundColor: palette.background,
      body: Stack(
        children: [
          // Ambient Background Glows
          Positioned(
            top: -250,
            left: 0,
            right: 0,
            height: 500,
            child: Container(
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 120, sigmaY: 120),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),

          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => _handleBack(context, activeProfile),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: palette.surfaceAlt.withValues(alpha: 0.92),
                            shape: BoxShape.circle,
                            border: Border.all(color: palette.border),
                          ),
                          child: Icon(
                            Icons.arrow_back_rounded,
                            color: palette.textPrimary,
                            size: 20,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _walletTitle(activeProfile),
                        style: GoogleFonts.splineSans(
                          color: palette.textMuted,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 2.0,
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 40), // Balance spacing
                    ],
                  ),
                ),

                // Balance Container
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          accent.withValues(alpha: 0.85),
                          accent.withValues(alpha: 0.55),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: accent.withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activeProfile?.isProfessional == true
                              ? 'Balance del perfil activo'
                              : 'Balance disponible',
                          style: GoogleFonts.splineSans(
                            color: palette.textPrimary.withValues(alpha: 0.82),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        walletAsync.when(
                          data: (wallet) {
                            final balance =
                                num.tryParse(
                                  (wallet['balance'] ?? 0).toString(),
                                ) ??
                                0;
                            final walletId = wallet['id'];
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _formatCurrency(balance),
                                  style: GoogleFonts.splineSans(
                                    color: palette.textPrimary,
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                SizedBox(
                                  width: double.infinity,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: () =>
                                              _showRechargeSheet(context, ref),
                                          icon: const Icon(
                                            Icons.add_card_rounded,
                                          ),
                                          label: const Text('Agregar fondos'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                palette.textPrimary,
                                            foregroundColor: accent,
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 16,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(ctx),
                                              child: Text(
                                                'Close',
                                                style: GoogleFonts.splineSans(
                                                  color: Colors.white54,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          onPressed: () =>
                                              _showTransferSheet(context, ref),
                                          icon: const Icon(
                                            Icons.swap_horiz_rounded,
                                          ),
                                          label: const Text('Transferir'),
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor:
                                                palette.textPrimary,
                                            side: const BorderSide(
                                              color: Colors.white,
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 16,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: () =>
                                            context.push('/withdraw'),
                                        icon: const Icon(
                                          Icons.north_east_rounded,
                                        ),
                                        label: const Text('Retirar'),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: Colors.white,
                                          side: BorderSide(
                                            color: Colors.white.withValues(
                                              alpha: 0.35,
                                            ),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 14,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: TextButton.icon(
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (ctx) => Dialog(
                                              backgroundColor:
                                                  Colors.transparent,
                                              child: Container(
                                                padding: const EdgeInsets.all(
                                                  24,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: palette.surface,
                                                  borderRadius:
                                                      BorderRadius.circular(32),
                                                  border: Border.all(
                                                    color: palette.border,
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: accent.withValues(
                                                        alpha: 0.2,
                                                      ),
                                                      blurRadius: 30,
                                                      spreadRadius: 5,
                                                    ),
                                                  ],
                                                ),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      'WALLET QR',
                                                      style:
                                                          GoogleFonts.splineSans(
                                                            color: palette
                                                                .textPrimary,
                                                            fontSize: 18,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            letterSpacing: 2,
                                                          ),
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Text(
                                                      'Escanéalo para cobrar o recibir pagos rápido.',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style:
                                                          GoogleFonts.splineSans(
                                                            color: palette
                                                                .textSecondary,
                                                            fontSize: 12,
                                                          ),
                                                    ),
                                                    const SizedBox(height: 24),
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                            16,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              24,
                                                            ),
                                                      ),
                                                      child: QrImageView(
                                                        data:
                                                            'duty-wallet://$walletId',
                                                        version:
                                                            QrVersions.auto,
                                                        size: 200,
                                                        eyeStyle:
                                                            const QrEyeStyle(
                                                              eyeShape:
                                                                  QrEyeShape
                                                                      .square,
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                        dataModuleStyle:
                                                            const QrDataModuleStyle(
                                                              dataModuleShape:
                                                                  QrDataModuleShape
                                                                      .circle,
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 24),
                                                    Text(
                                                      'WALLET ID: $walletId',
                                                      style:
                                                          GoogleFonts.splineSans(
                                                            color: palette
                                                                .textMuted,
                                                            fontSize: 10,
                                                            letterSpacing: 1,
                                                          ),
                                                    ),
                                                    const SizedBox(height: 24),
                                                    SizedBox(
                                                      width: double.infinity,
                                                      child: ElevatedButton(
                                                        onPressed: () =>
                                                            Navigator.pop(ctx),
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor:
                                                              palette
                                                                  .surfaceAlt,
                                                          foregroundColor:
                                                              palette
                                                                  .textPrimary,
                                                          elevation: 0,
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  16,
                                                                ),
                                                            side: BorderSide(
                                                              color: palette
                                                                  .border,
                                                            ),
                                                          ),
                                                          padding:
                                                              const EdgeInsets.symmetric(
                                                                vertical: 16,
                                                              ),
                                                        ),
                                                        child: const Text(
                                                          'Cerrar',
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                        icon: const Icon(
                                          Icons.qr_code_2,
                                          color: Colors.white70,
                                        ),
                                        label: const Text(
                                          'Mostrar QR',
                                          style: TextStyle(
                                            color: Colors.white70,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                          loading: () => const CircularProgressIndicator(
                            color: Colors.white,
                          ),
                          error: (err, st) => Text(
                            'Error loading balance',
                            style: GoogleFonts.splineSans(
                              color: palette.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Transactions List
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  child: Text(
                    'Movimientos recientes',
                    style: GoogleFonts.splineSans(
                      color: textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                Expanded(
                  child: historyAsync.when(
                    data: (transactions) {
                      if (transactions.isEmpty) {
                        return Center(
                          child: Text(
                            'No transactions found.',
                            style: GoogleFonts.splineSans(
                              color: palette.textMuted,
                            ),
                          ),
                        );
                      }
                      return ListView.separated(
                        padding: const EdgeInsets.fromLTRB(24, 8, 24, 132),
                        itemCount: transactions.length,
                        separatorBuilder: (_, _) =>
                            Divider(color: palette.border),
                        itemBuilder: (context, index) {
                          final tx = transactions[index];
                          final isDeposit = tx.amount > 0;

                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color:
                                    (isDeposit
                                            ? palette.success
                                            : palette.danger)
                                        .withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isDeposit
                                    ? Icons.arrow_downward_rounded
                                    : Icons.arrow_upward_rounded,
                                color: isDeposit
                                    ? palette.success
                                    : palette.danger,
                              ),
                            ),
                            title: Text(
                              tx.description,
                              style: GoogleFonts.splineSans(
                                color: palette.textPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: Text(
                              DateFormat(
                                'MMM dd, yyyy \u2022 hh:mm a',
                              ).format(tx.createdAt),
                              style: GoogleFonts.splineSans(
                                color: palette.textMuted,
                                fontSize: 12,
                              ),
                            ),
                            trailing: Text(
                              '${isDeposit ? '+' : ''}${_formatCurrency(tx.amount)}',
                              style: GoogleFonts.splineSans(
                                color: isDeposit
                                    ? palette.success
                                    : palette.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          );
                        },
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (err, st) => Center(
                      child: Text(
                        'Failed to load transactions.\n$err',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.splineSans(color: palette.danger),
                      ),
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

  Future<void> _showRechargeDialog(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    return showDialog(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _RechargeBottomSheet(),
    );
  }

  void _showTransferSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const TransferBottomSheet(),
    );
  }
}

// ─── Recharge Bottom Sheet ──────────────────────────────────────────────────

class _RechargeBottomSheet extends ConsumerStatefulWidget {
  const _RechargeBottomSheet();

  @override
  ConsumerState<_RechargeBottomSheet> createState() =>
      _RechargeBottomSheetState();
}

class _RechargeBottomSheetState extends ConsumerState<_RechargeBottomSheet> {
  final _amountController = TextEditingController();
  int? _selectedQuickAmount;
  String? _selectedCardId;
  bool _isProcessing = false;
  Timer? _previewDebounce;
  Map<String, dynamic>? _topupPreview;
  int _previewRequestKey = 0;

  static const _quickAmounts = [500, 1000, 2000, 5000];
  @override
  void dispose() {
    _previewDebounce?.cancel();
    _amountController.dispose();
    super.dispose();
  }

  double? get _amount {
    if (_selectedQuickAmount != null) return _selectedQuickAmount!.toDouble();
    return double.tryParse(_amountController.text);
  }

  void _selectQuickAmount(int amount) {
    setState(() {
      if (_selectedQuickAmount == amount) {
        _selectedQuickAmount = null;
      } else {
        _selectedQuickAmount = amount;
        _amountController.clear();
      }
    });
    _scheduleTopupPreview();
  }

  IconData _brandIcon(String brand) {
    switch (brand.toLowerCase()) {
      case 'visa':
        return Icons.credit_card;
      case 'mastercard':
        return Icons.credit_card;
      case 'amex':
        return Icons.credit_card;
      default:
        return Icons.credit_card;
    }
  }

  String _brandLabel(String brand) {
    switch (brand.toLowerCase()) {
      case 'visa':
        return 'Visa';
      case 'mastercard':
        return 'Mastercard';
      case 'amex':
        return 'Amex';
      default:
        return brand.isNotEmpty
            ? '${brand[0].toUpperCase()}${brand.substring(1)}'
            : 'Card';
    }
  }

  Future<void> _handleAddCard() async {
    try {
      setState(() => _isProcessing = true);

      final repository = ref.read(walletRepositoryProvider);
      final token = await ref.read(authTokenProvider.future);
      if (token == null) return;

      final clientSecret = await repository.createSetupIntent(token: token);
      if (!mounted) return;

      final success = await CardSetupSheet.show(
        context: context,
        clientSecret: clientSecret,
        title: 'Save New Card',
      );

      if (success) {
        // Refresh the payment methods list
        ref.invalidate(paymentMethodsProvider);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Card added successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add card: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _scheduleTopupPreview() {
    _previewDebounce?.cancel();
    final amount = _amount;

    if (amount == null || amount <= 0) {
      if (mounted) {
        setState(() => _topupPreview = null);
      }
      return;
    }

    _previewDebounce = Timer(const Duration(milliseconds: 250), () {
      _refreshTopupPreview();
    });
  }

  Future<void> _refreshTopupPreview() async {
    final amount = _amount;
    if (amount == null || amount <= 0) {
      if (mounted) {
        setState(() => _topupPreview = null);
      }
      return;
    }

    final token = await ref.read(authTokenProvider.future);
    if (token == null) return;

    final requestKey = ++_previewRequestKey;
    try {
      final preview = await ref
          .read(walletRepositoryProvider)
          .previewTopup(token: token, amount: amount);

      if (!mounted || requestKey != _previewRequestKey) return;
      setState(() => _topupPreview = preview);
    } catch (_) {
      if (!mounted || requestKey != _previewRequestKey) return;
      setState(() => _topupPreview = null);
    }
  }

  double _previewRequestedAmount(double amount) {
    return (_topupPreview?['requested_amount'] as num?)?.toDouble() ?? amount;
  }

  double _previewProcessingFee(double amount) {
    return (_topupPreview?['processing_fee'] as num?)?.toDouble() ?? 0;
  }

  double _previewTotalCharge(double amount) {
    final requested = _previewRequestedAmount(amount);
    return (_topupPreview?['total_charge'] as num?)?.toDouble() ?? requested;
  }

  Widget _buildBreakdownRow(
    BuildContext context,
    String label,
    String value, {
    bool isTotal = false,
  }) {
    final palette = context.dutyTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.splineSans(
            color: isTotal ? palette.textPrimary : palette.textMuted,
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.splineSans(
            color: isTotal ? palette.primary : palette.textPrimary,
            fontSize: isTotal ? 20 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
          ),
          ElevatedButton(
            onPressed: () async {
              final amount = double.tryParse(controller.text);
              if (amount == null || amount <= 0) return;
              Navigator.pop(ctx);
              _handleTopup(context, ref, amount);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Next'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleTopup(
    BuildContext context,
    WidgetRef ref,
    double amount,
  ) async {
    try {
      // Show loading
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Preparing payment...')));

      final repository = ref.read(walletRepositoryProvider);
      final token = await ref.read(authTokenProvider.future);
      if (token == null) return;

      final intentData = await repository.createTopupIntent(
        token: token,
        amount: amount,
      );

      final String clientSecret = intentData['client_secret'];

      bool success = false;

      // 2. Process Payment based on selection
      if (_selectedCardId != null && _selectedCardId != '__new__') {
        // Pay with saved card
        final messenger = ScaffoldMessenger.of(context);
        messenger.showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 12),
                Text('Processing payment...'),
              ],
            ),
            duration: Duration(seconds: 30),
          ),
        );

        success = await StripeService.instance.confirmSavedCardPayment(
          clientSecret: intentData['client_secret'],
          paymentMethodId: _selectedCardId!,
        );
        messenger.hideCurrentSnackBar();
      } else {
        // Show new card form
        success = await CardPaymentSheet.show(
          context: context,
          clientSecret: intentData['client_secret'],
          amount:
              (intentData['total_charge'] as num?)?.toDouble() ??
              _previewTotalCharge(amount),
          currency: 'DOP',
          title: 'Recharge Wallet',
        );
      }

      if (!success || !mounted) {
        setState(() => _isProcessing = false);
        return;
      }

      // 3. Payment succeeded — capture refs before popping
      final messenger = ScaffoldMessenger.of(context);
      final navigator = Navigator.of(context);
      final container = ProviderScope.containerOf(context);

      navigator.pop(); // Close the recharge bottom sheet

      // 4. Confirm topup with backend
      final String? paymentIntentId = intentData['id'];
      if (paymentIntentId == null) {
        throw Exception('PaymentIntent ID missing');
      }

      messenger.showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 12),
              Text('Verifying payment...'),
            ],
          ),
          duration: Duration(seconds: 30),
        ),
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Wallet recharged successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        // Refresh wallet and history
        ref.invalidate(walletProvider);
        ref.invalidate(walletHistoryProvider);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.dutyTheme;
    final paymentMethods = ref.watch(paymentMethodsProvider);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: palette.border),
        boxShadow: [
          BoxShadow(
            color: palette.shadow.withValues(alpha: 0.2),
            blurRadius: 40,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: palette.borderStrong,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        palette.primary.withValues(alpha: 0.3),
                        palette.primary.withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.account_balance_wallet_rounded,
                    color: palette.textPrimary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recharge Wallet',
                        style: GoogleFonts.splineSans(
                          color: palette.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Select amount and funding source',
                        style: GoogleFonts.splineSans(
                          color: palette.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: palette.surfaceAlt,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      color: palette.textMuted,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Content (scrollable)
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── Amount Section ───
                  Text(
                    'AMOUNT (DOP)',
                    style: GoogleFonts.splineSans(
                      color: palette.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Quick amount chips
                  Row(
                    children: _quickAmounts.map((amt) {
                      final isSelected = _selectedQuickAmount == amt;
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            right: amt != _quickAmounts.last ? 8 : 0,
                          ),
                          child: GestureDetector(
                            onTap: () => _selectQuickAmount(amt),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                gradient: isSelected
                                    ? LinearGradient(
                                        colors: [
                                          palette.primary,
                                          palette.primaryGlow,
                                        ],
                                      )
                                    : null,
                                color: isSelected ? null : palette.surfaceAlt,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isSelected
                                      ? palette.primary
                                      : palette.border,
                                  width: isSelected ? 1.5 : 1,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: palette.primaryGlow.withValues(
                                            alpha: 0.3,
                                          ),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Center(
                                child: Text(
                                  '\$$amt',
                                  style: GoogleFonts.splineSans(
                                    color: isSelected
                                        ? palette.textPrimary
                                        : palette.textSecondary,
                                    fontSize: 14,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),

                  // Custom amount input
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.splineSans(
                      color: palette.textPrimary,
                      fontSize: 16,
                    ),
                    onChanged: (_) {
                      if (_selectedQuickAmount != null) {
                        setState(() => _selectedQuickAmount = null);
                      }
                      _scheduleTopupPreview();
                    },
                    decoration: InputDecoration(
                      hintText: 'Custom amount',
                      hintStyle: GoogleFonts.splineSans(
                        color: palette.textMuted,
                        fontSize: 14,
                      ),
                      prefixIcon: Icon(
                        Icons.attach_money_rounded,
                        color: palette.textMuted,
                        size: 20,
                      ),
                      filled: true,
                      fillColor: palette.surfaceAlt,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: palette.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: palette.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: palette.primary.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ─── Saved Cards Section ───
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'SAVED CARD',
                        style: GoogleFonts.splineSans(
                          color: palette.textMuted,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.5,
                        ),
                      ),
                      GestureDetector(
                        onTap: _isProcessing ? null : _handleAddCard,
                        child: Row(
                          children: [
                            Icon(
                              Icons.add_rounded,
                              color: palette.primary,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Add Card',
                              style: GoogleFonts.splineSans(
                                color: palette.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  paymentMethods.when(
                    data: (methods) {
                      if (methods.isEmpty) {
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: palette.surfaceAlt,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: palette.border),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.credit_card_off_rounded,
                                color: palette.textMuted,
                                size: 36,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'No saved cards',
                                style: GoogleFonts.splineSans(
                                  color: palette.textMuted,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Add a card to enable quick payments',
                                style: GoogleFonts.splineSans(
                                  color: palette.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      // Auto-select the first card if none selected
                      if (_selectedCardId == null && methods.isNotEmpty) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted) {
                            setState(() {
                              _selectedCardId =
                                  methods.first['stripe_payment_method_id'];
                            });
                          }
                        });
                      }

                      return Column(
                        children: methods.map((card) {
                          final cardId = card['stripe_payment_method_id'] ?? '';
                          final isSelected = _selectedCardId == cardId;
                          final brand = card['brand'] ?? 'card';
                          final last4 = card['last4'] ?? '****';
                          final expMonth = card['exp_month'];
                          final expYear = card['exp_year'];
                          final expiry = expMonth != null
                              ? '$expMonth/$expYear'
                              : '';
                          final isDefault =
                              card['is_default'] == true ||
                              card['is_default'] == 1;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedCardId = cardId),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  gradient: isSelected
                                      ? LinearGradient(
                                          colors: [
                                            palette.primarySurface,
                                            palette.surfaceAlt,
                                          ],
                                        )
                                      : null,
                                  color: isSelected ? null : palette.surfaceAlt,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSelected
                                        ? palette.primary.withValues(alpha: 0.5)
                                        : palette.border,
                                    width: isSelected ? 1.5 : 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    // Radio indicator
                                    Container(
                                      width: 22,
                                      height: 22,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: isSelected
                                              ? palette.primary
                                              : palette.borderStrong,
                                          width: 2,
                                        ),
                                      ),
                                      child: isSelected
                                          ? Center(
                                              child: Container(
                                                width: 10,
                                                height: 10,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: palette.primary,
                                                ),
                                              ),
                                            )
                                          : null,
                                    ),
                                    const SizedBox(width: 14),

                                    // Card icon
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: palette.surfaceMuted,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        _brandIcon(brand),
                                        color: palette.textSecondary,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 14),

                                    // Details
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                '${_brandLabel(brand)}  ····  $last4',
                                                style: GoogleFonts.splineSans(
                                                  color: palette.textPrimary,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              if (isDefault) ...[
                                                const SizedBox(width: 8),
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 6,
                                                        vertical: 2,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        palette.primarySurface,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          6,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    'DEFAULT',
                                                    style:
                                                        GoogleFonts.splineSans(
                                                          color:
                                                              palette.primary,
                                                          fontSize: 9,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          letterSpacing: 0.5,
                                                        ),
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                          if (expiry.isNotEmpty)
                                            Text(
                                              'Exp: $expiry',
                                              style: GoogleFonts.splineSans(
                                                color: palette.textMuted,
                                                fontSize: 12,
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
                        }).toList(),
                      );
                    },
                    loading: () => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: palette.primary,
                          ),
                        ),
                      ),
                    ),
                    error: (err, _) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        'Failed to load cards',
                        style: GoogleFonts.splineSans(
                          color: palette.danger,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Stripe sheet fallback option
                  GestureDetector(
                    onTap: () {
                      setState(() => _selectedCardId = '__new__');
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _selectedCardId == '__new__'
                            ? palette.primarySurface
                            : palette.surfaceAlt,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _selectedCardId == '__new__'
                              ? palette.primary.withValues(alpha: 0.5)
                              : palette.border,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _selectedCardId == '__new__'
                                    ? palette.primary
                                    : palette.borderStrong,
                                width: 2,
                              ),
                            ),
                            child: _selectedCardId == '__new__'
                                ? Center(
                                    child: Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: palette.primary,
                                      ),
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(width: 14),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: palette.surfaceMuted,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.add_card_rounded,
                              color: palette.textSecondary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Text(
                            'Pay with new card',
                            style: GoogleFonts.splineSans(
                              color: palette.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // ─── Pay Button ───
          Container(
            padding: EdgeInsets.fromLTRB(
              24,
              12,
              24,
              100 + MediaQuery.of(context).viewInsets.bottom,
            ),
            decoration: BoxDecoration(
              color: palette.surface,
              border: Border(top: BorderSide(color: palette.border)),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_amount != null && _amount! > 0)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Column(
                        children: [
                          _buildBreakdownRow(
                            context,
                            'Recharge Amount',
                            '\$${_previewRequestedAmount(_amount!).toStringAsFixed(2)}',
                          ),
                          const SizedBox(height: 8),
                          _buildBreakdownRow(
                            context,
                            'Processing Fee',
                            '\$${_previewProcessingFee(_amount!).toStringAsFixed(2)}',
                          ),
                          Divider(color: palette.border, height: 24),
                          _buildBreakdownRow(
                            context,
                            'Total to Pay',
                            '\$${_previewTotalCharge(_amount!).toStringAsFixed(2)}',
                            isTotal: true,
                          ),
                        ],
                      ),
                    ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          (_amount != null && _amount! > 0 && !_isProcessing)
                          ? _handlePay
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: palette.primary,
                        foregroundColor: palette.textPrimary,
                        disabledBackgroundColor: palette.primary.withValues(
                          alpha: 0.3,
                        ),
                        disabledForegroundColor: palette.textMuted,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: _isProcessing
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: palette.textPrimary,
                              ),
                            )
                          : Text(
                              _amount != null && _amount! > 0
                                  ? 'Pay \$${_previewTotalCharge(_amount!).toStringAsFixed(2)}'
                                  : 'Enter amount to continue',
                              style: GoogleFonts.splineSans(
                                fontSize: 16,
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
