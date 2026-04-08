import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/stripe_service.dart';
import '../theme/colors.dart';

class CardPaymentSheet extends StatefulWidget {
  final String clientSecret;
  final double amount;
  final String currency;
  final String? title;

  const CardPaymentSheet({
    super.key,
    required this.clientSecret,
    required this.amount,
    this.currency = 'DOP',
    this.title,
  });

  static Future<bool> show({
    required BuildContext context,
    required String clientSecret,
    required double amount,
    String currency = 'DOP',
    String? title,
  }) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CardPaymentSheet(
        clientSecret: clientSecret,
        amount: amount,
        currency: currency,
        title: title,
      ),
    );
    return result ?? false;
  }

  @override
  State<CardPaymentSheet> createState() => _CardPaymentSheetState();
}

class _CardPaymentSheetState extends State<CardPaymentSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _numberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();

  bool _isProcessing = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _numberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  Future<void> _pay() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      final number = _numberController.text.replaceAll(' ', '');
      final expParts = _expiryController.text.split('/');
      final expMonth = int.parse(expParts[0]);
      var expYearStr = expParts[1];
      if (expYearStr.length == 2) {
        expYearStr = '20$expYearStr';
      }
      final expYear = int.parse(expYearStr);

      final success = await StripeService.instance.confirmCustomPayment(
        clientSecret: widget.clientSecret,
        number: number,
        expMonth: expMonth,
        expYear: expYear,
        cvc: _cvvController.text,
        name: _nameController.text.trim(),
      );

      if (success && mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Payment failed. Please check your details.";
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.dutyTheme;
    return Container(
      decoration: BoxDecoration(
        color: palette.backgroundAlt,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Stack(
        children: [
          // Background Glow
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: palette.primaryGlow.withValues(alpha: 0.16),
                shape: BoxShape.circle,
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),

          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Handle
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: palette.textMuted.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.title ?? 'Pay Securely',
                              style: GoogleFonts.manrope(
                                color: palette.textPrimary,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Enter your payment details',
                              style: GoogleFonts.manrope(
                                color: palette.textMuted,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: palette.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: palette.primary.withValues(alpha: 0.24),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.verified_user,
                                color: palette.primary,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "SECURE",
                                style: GoogleFonts.manrope(
                                  color: palette.primary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Glass Card Preview
                    _buildGlassCard(),

                    const SizedBox(height: 32),

                    // Amount Bar
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: palette.surfaceAlt,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: palette.border),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'TOTAL TO PAY',
                            style: GoogleFonts.manrope(
                              color: palette.textMuted,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                          Text(
                            '\$${widget.amount.toStringAsFixed(2)} ${widget.currency}',
                            style: GoogleFonts.manrope(
                              color: palette.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Custom Fields
                    Text(
                      "CARD INFORMATION",
                      style: GoogleFonts.manrope(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: palette.primary.withValues(alpha: 0.72),
                        letterSpacing: 1.2,
                      ),
                    ).align(Alignment.centerLeft),
                    const SizedBox(height: 16),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: palette.surfaceAlt,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: palette.border),
                      ),
                      child: Column(
                        children: [
                          _buildTextField(
                            label: "Cardholder Name",
                            hint: "JOHN DOE",
                            controller: _nameController,
                            onChanged: (val) => setState(() {}),
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            label: "Card Number",
                            hint: "0000 0000 0000 0000",
                            controller: _numberController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(16),
                              _CardNumberFormatter(),
                            ],
                            icon: Icons.credit_card,
                            onChanged: (val) => setState(() {}),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  label: "Expiry Date",
                                  hint: "MM/YY",
                                  controller: _expiryController,
                                  keyboardType: TextInputType.datetime,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                      RegExp(r'[0-9/]'),
                                    ),
                                    LengthLimitingTextInputFormatter(5),
                                    _ExpiryDateFormatter(),
                                  ],
                                  onChanged: (val) => setState(() {}),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildTextField(
                                  label: "CVV",
                                  hint: "•••",
                                  controller: _cvvController,
                                  obscureText: true,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(4),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    if (_errorMessage != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        style: TextStyle(color: palette.danger, fontSize: 13),
                      ).align(Alignment.centerLeft),
                    ],

                    const SizedBox(height: 32),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      height: 58,
                      child: ElevatedButton(
                        onPressed: _isProcessing ? null : _pay,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: palette.primary,
                          disabledBackgroundColor: palette.primary.withValues(
                            alpha: 0.3,
                          ),
                          foregroundColor: palette.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          elevation: 8,
                          shadowColor: palette.primary.withValues(alpha: 0.35),
                        ),
                        child: _isProcessing
                            ? SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: palette.onPrimary,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.lock_outline,
                                    size: 18,
                                    color: palette.onPrimary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Confirm & Pay',
                                    style: GoogleFonts.manrope(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // PCI Badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.verified_user_outlined,
                          size: 12,
                          color: palette.textMuted,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "PCI-DSS COMPLIANT",
                          style: GoogleFonts.manrope(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            color: palette.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassCard() {
    final palette = context.dutyTheme;
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: palette.surfaceAlt.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: palette.border),
        boxShadow: [
          BoxShadow(
            color: palette.primary.withValues(alpha: 0.14),
            blurRadius: 40,
            spreadRadius: -10,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Stack(
            children: [
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        palette.textPrimary.withValues(alpha: 0.05),
                        Colors.transparent,
                        palette.primary.withValues(alpha: 0.04),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 44,
                          height: 32,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.yellow.withValues(alpha: 0.4),
                                Colors.yellow[800]!.withValues(alpha: 0.2),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: palette.border),
                          ),
                        ),
                        _buildCardLogoWidget(),
                      ],
                    ),
                    Text(
                      _numberController.text.isEmpty
                          ? "•••• •••• •••• 4242"
                          : _numberController.text,
                      style: GoogleFonts.manrope(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: palette.textPrimary.withValues(alpha: 0.94),
                        letterSpacing: 2.0,
                        shadows: [
                          Shadow(
                            color: palette.shadow.withValues(alpha: 0.35),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "CARD HOLDER",
                              style: GoogleFonts.manrope(
                                fontSize: 9,
                                color: palette.textMuted,
                                letterSpacing: 1.2,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _nameController.text.isEmpty
                                  ? "CUSTOMER NAME"
                                  : _nameController.text.toUpperCase(),
                              style: GoogleFonts.manrope(
                                fontSize: 13,
                                color: palette.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "EXPIRES",
                              style: GoogleFonts.manrope(
                                fontSize: 9,
                                color: palette.textMuted,
                                letterSpacing: 1.2,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _expiryController.text.isEmpty
                                  ? "12/26"
                                  : _expiryController.text,
                              style: GoogleFonts.manrope(
                                fontSize: 13,
                                color: palette.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
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

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    List<TextInputFormatter>? inputFormatters,
    IconData? icon,
    ValueChanged<String>? onChanged,
  }) {
    final palette = context.dutyTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.manrope(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: palette.textSecondary,
            letterSpacing: 1.0,
          ),
        ),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          inputFormatters: inputFormatters,
          onChanged: onChanged,
          validator: (val) => val != null && val.isNotEmpty ? null : "Required",
          style: GoogleFonts.manrope(fontSize: 16, color: palette.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: palette.textMuted.withValues(alpha: 0.8),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: palette.border),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: palette.primary),
            ),
            errorBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: palette.danger),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
            isDense: true,
            suffixIconConstraints: const BoxConstraints(
              minWidth: 24,
              minHeight: 24,
            ),
            suffixIcon: icon != null
                ? Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Icon(icon, color: palette.textMuted, size: 20),
                  )
                : null,
          ),
        ),
      ],
    );
  }

  // --- Dynamic Card Brand Logic ---
  CardType _getCardType(String number) {
    if (number.isEmpty) return CardType.unknown;
    final cleanNumber = number.replaceAll(' ', '');
    if (cleanNumber.startsWith('4')) return CardType.visa;
    if (cleanNumber.startsWith(RegExp(r'^5[1-5]')) ||
        cleanNumber.startsWith(RegExp(r'^2[2-7]'))) {
      return CardType.mastercard;
    }
    if (cleanNumber.startsWith('34') || cleanNumber.startsWith('37')) {
      return CardType.amex;
    }
    if (cleanNumber.startsWith('6011') || cleanNumber.startsWith('65')) {
      return CardType.discover;
    }
    return CardType.unknown;
  }

  Widget _buildCardLogoWidget() {
    final type = _getCardType(_numberController.text);
    switch (type) {
      case CardType.mastercard:
        return SizedBox(
          height: 30,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.8),
                  shape: BoxShape.circle,
                ),
              ),
              Positioned(
                left: 20,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.8),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        );
      case CardType.visa:
        return Text(
          "VISA",
          style: GoogleFonts.inter(
            color: context.dutyTheme.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.w900,
            fontStyle: FontStyle.italic,
          ),
        );
      case CardType.amex:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          decoration: BoxDecoration(
            color: kInfoColor.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            "AMEX",
            style: GoogleFonts.inter(
              color: context.dutyTheme.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      case CardType.discover:
        return Text(
          "Discover",
          style: GoogleFonts.inter(
            color: kWarmGold,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        );
      default:
        return Icon(
          Icons.credit_card,
          color: context.dutyTheme.textSecondary,
          size: 28,
        );
    }
  }
}

enum CardType { visa, mastercard, amex, discover, unknown }

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var text = newValue.text;
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }
    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex % 4 == 0 && nonZeroIndex != text.length) {
        buffer.write(' ');
      }
    }
    var string = buffer.toString();
    return newValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}

class _ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (oldValue.text.length > newValue.text.length) {
      return newValue; // Focus on allowing backspace
    }
    String text = newValue.text.replaceAll('/', '');
    if (text.length >= 3) {
      text = '${text.substring(0, 2)}/${text.substring(2, text.length)}';
    } else if (text.length == 2) {
      text = '$text/';
    }
    return newValue.copyWith(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

extension on Widget {
  Widget align(Alignment alignment) {
    return Align(alignment: alignment, child: this);
  }
}
