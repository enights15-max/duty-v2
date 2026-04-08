import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/providers/profile_state_provider.dart';
import '../../../../core/theme/colors.dart';
import '../../../profile/domain/models/profile_model.dart';
import '../providers/wallet_provider.dart';
import '../providers/withdrawal_provider.dart';

class WithdrawalPage extends ConsumerStatefulWidget {
  const WithdrawalPage({super.key});

  @override
  ConsumerState<WithdrawalPage> createState() => _WithdrawalPageState();
}

class _WithdrawalPageState extends ConsumerState<WithdrawalPage> {
  final _amountController = TextEditingController();
  final _bankAccountController = TextEditingController();
  String _selectedMethod = 'bank_transfer';

  Color _profileAccent(AppProfile? profile) {
    switch (profile?.type) {
      case ProfileType.artist:
        return kDustRose;
      case ProfileType.venue:
        return kInfoColor;
      case ProfileType.organizer:
        return kPrimaryColorDeep;
      case ProfileType.personal:
      case null:
        return kPrimaryColor;
    }
  }

  String _formatCurrency(num amount) {
    final formatted = NumberFormat('#,##0.00', 'en_US').format(amount);
    return 'RD\$$formatted';
  }

  void _handleBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go('/wallet');
  }

  @override
  void dispose() {
    _amountController.dispose();
    _bankAccountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.dutyTheme;
    final walletAsync = ref.watch(walletProvider);
    final withdrawalState = ref.watch(withdrawalProvider);
    final activeProfile = ref.watch(activeProfileProvider);
    final accent = _profileAccent(activeProfile);

    return Scaffold(
      backgroundColor: palette.background,
      body: Stack(
        children: [
          Positioned(
            top: -100,
            right: -100,
            width: 300,
            height: 300,
            child: Container(
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => _handleBack(context),
                        icon: Icon(
                          Icons.arrow_back_ios_new,
                          color: palette.textPrimary,
                        ),
                      ),
                      Text(
                        activeProfile?.isProfessional == true
                            ? 'Retirar desde ${activeProfile!.name}'
                            : 'Retirar fondos',
                        style: GoogleFonts.manrope(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: palette.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    children: [
                      const SizedBox(height: 20),
                      Text(
                        activeProfile?.isProfessional == true
                            ? 'Balance del perfil activo'
                            : 'Balance disponible',
                        style: GoogleFonts.manrope(
                          color: palette.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      walletAsync.when(
                        data: (wallet) {
                          final balance =
                              double.tryParse(
                                (wallet['balance'] ?? 0).toString(),
                              ) ??
                              0.0;
                          return Text(
                            _formatCurrency(balance),
                            style: GoogleFonts.manrope(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: palette.textPrimary,
                            ),
                          );
                        },
                        loading: () => const SizedBox(
                          height: 40,
                          width: 40,
                          child: CircularProgressIndicator(),
                        ),
                        error: (_, _) => Text(
                          'Error',
                          style: TextStyle(color: palette.danger),
                        ),
                      ),
                      const SizedBox(height: 40),
                      _buildLabel('Monto a retirar'),
                      _buildTextField(
                        controller: _amountController,
                        hint: '0.00',
                        keyboardType: TextInputType.number,
                        prefix: Icon(
                          Icons.account_balance_wallet,
                          color: accent,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildLabel('Método de retiro'),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: palette.surfaceAlt,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: palette.border),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedMethod,
                            dropdownColor: palette.surface,
                            isExpanded: true,
                            icon: Icon(
                              Icons.keyboard_arrow_down,
                              color: palette.textSecondary,
                            ),
                            items: [
                              DropdownMenuItem(
                                value: 'bank_transfer',
                                child: Text(
                                  'Transferencia bancaria',
                                  style: TextStyle(color: palette.textPrimary),
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'stripe',
                                child: Text(
                                  'Stripe Connect',
                                  style: TextStyle(color: palette.textPrimary),
                                ),
                              ),
                            ],
                            onChanged: (val) {
                              if (val != null)
                                setState(() => _selectedMethod = val);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (_selectedMethod == 'bank_transfer') ...[
                        _buildLabel('Detalles bancarios'),
                        _buildTextField(
                          controller: _bankAccountController,
                          hint: 'Número de cuenta / IBAN',
                          prefix: Icon(
                            Icons.account_balance,
                            color: palette.textSecondary,
                          ),
                        ),
                      ],
                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: withdrawalState.isLoading
                              ? null
                              : _handleSubmit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accent,
                            foregroundColor: palette.onPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: withdrawalState.isLoading
                              ? CircularProgressIndicator(
                                  color: palette.onPrimary,
                                )
                              : Text(
                                  'Enviar solicitud',
                                  style: GoogleFonts.manrope(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'El retiro mínimo es RD\$10.00. Las solicitudes se procesan en 24-48 horas hábiles.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: palette.textMuted,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4),
      child: Text(
        text,
        style: GoogleFonts.manrope(
          color: context.dutyTheme.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    Widget? prefix,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: context.dutyTheme.surfaceAlt,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.dutyTheme.border),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: TextStyle(color: context.dutyTheme.textPrimary),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: context.dutyTheme.textMuted),
          prefixIcon: prefix,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  void _handleSubmit() async {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ingresa un monto válido (mínimo RD\$10).'),
        ),
      );
      return;
    }

    if (_selectedMethod == 'bank_transfer' &&
        _bankAccountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa los detalles bancarios.')),
      );
      return;
    }

    final details = {
      'account_details': _bankAccountController.text,
      'requested_at': DateTime.now().toIso8601String(),
    };

    await ref
        .read(withdrawalProvider.notifier)
        .requestWithdrawal(
          amount: amount,
          method: _selectedMethod,
          paymentDetails: details,
        );

    if (ref.read(withdrawalProvider).hasError) {
      final error = ref.read(withdrawalProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $error'),
          backgroundColor: context.dutyTheme.danger,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Solicitud de retiro enviada.'),
          backgroundColor: context.dutyTheme.success,
        ),
      );
      context.pop();
    }
  }
}
