import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/colors.dart';
import '../providers/checkout_provider.dart';

class PaymentCCPage extends ConsumerStatefulWidget {
  final Map<String, dynamic> bookingPayload;

  const PaymentCCPage({super.key, required this.bookingPayload});

  @override
  ConsumerState<PaymentCCPage> createState() => _PaymentCCPageState();
}

class _PaymentCCPageState extends ConsumerState<PaymentCCPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _numberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  bool _saveCard = true;

  // Colors from HTML
  static const Color kPrimaryColor = Color(0xFF8C06F9);
  static const Color kBackgroundColor = Color(0xFF0A050F);

  @override
  void dispose() {
    _nameController.dispose();
    _numberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  void _onPay() async {
    if (_formKey.currentState?.validate() ?? false) {
      // Logic placeholder
      final cardDetails = {
        'name': _nameController.text,
        'number': _numberController.text.replaceAll(' ', ''),
        'expiry': _expiryController.text, // MM/YY
        'cvv': _cvvController.text,
        'saveCard': _saveCard,
      };

      try {
        final bookingInfo = await ref
            .read(checkoutProvider.notifier)
            .submitCustomOrder(cardDetails, widget.bookingPayload);

        if (mounted) {
          // Navigate to Ticket Success Page
          context.go(
            '/ticket-success',
            extra: {
              'bookingId': bookingInfo['booking_id'] ?? 'N/A',
              'eventTitle':
                  widget.bookingPayload['event_title'] ??
                  'Event', // Ensure this key exists in payload
            },
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch provider to see total amount
    final checkoutState = ref.watch(checkoutProvider);

    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Stack(
        children: [
          // Background Decoration
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: kPrimaryColor.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 120, sigmaY: 120),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            right: -100,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: kPrimaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                child: Container(color: Colors.transparent),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white70,
                          size: 20,
                        ),
                        onPressed: () => context.pop(),
                      ),
                      Text(
                        "Secure Card Entry",
                        style: GoogleFonts.manrope(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: kPrimaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: kPrimaryColor.withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.verified_user,
                              color: kPrimaryColor,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "SECURE",
                              style: GoogleFonts.manrope(
                                color: kPrimaryColor,
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
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Glass Card Preview
                          _buildGlassCard(),

                          const SizedBox(height: 32),

                          // Form Fields
                          _buildTextField(
                            label: "Cardholder Name",
                            hint: "Enter full name",
                            controller: _nameController,
                            onChanged: (val) => setState(() {}),
                          ),
                          const SizedBox(height: 20),
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

                          const SizedBox(height: 20),

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
                              const SizedBox(width: 20),
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

                          const SizedBox(height: 24),

                          // Save Toggle
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Save card details",
                                    style: GoogleFonts.manrope(
                                      color: Colors.white.withValues(
                                        alpha: 0.9,
                                      ),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    "For faster checkout next time",
                                    style: GoogleFonts.manrope(
                                      color: Colors.white.withValues(
                                        alpha: 0.4,
                                      ),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              Switch(
                                value: _saveCard,
                                onChanged: (val) =>
                                    setState(() => _saveCard = val),
                                activeColor: kPrimaryColor,
                                inactiveTrackColor: Colors.white10,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Footer
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: checkoutState.isLoading ? null : _onPay,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 8,
                            shadowColor: kPrimaryColor.withOpacity(0.4),
                          ),
                          child: checkoutState.isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.lock_outline,
                                      size: 20,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      "Confirm & Pay DOP ${checkoutState.totalAmount.toStringAsFixed(2)}",
                                      style: GoogleFonts.manrope(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.verified_user_outlined,
                            size: 12,
                            color: Colors.white30,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "PCI-DSS COMPLIANT",
                            style: GoogleFonts.manrope(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                              color: Colors.white30,
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildGlassCard() {
    return Container(
      width: double.infinity,
      height: 220,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: kPrimaryColor.withOpacity(0.2),
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
              // Gradient Overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withOpacity(0.05),
                        Colors.transparent,
                        Colors.white.withOpacity(0.02),
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
                        // Chip
                        Container(
                          width: 48,
                          height: 36,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.yellow.withOpacity(0.4),
                                Colors.yellow[800]!.withOpacity(0.2),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.white10),
                          ),
                        ),
                        // Dynamic Logo based on card number
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
                        color: Colors.white.withOpacity(0.9),
                        letterSpacing: 2.0,
                        shadows: [
                          Shadow(
                            color: Colors.black26,
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
                                fontSize: 10,
                                color: Colors.white38,
                                letterSpacing: 1.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _nameController.text.isEmpty
                                  ? "JOHN DOE"
                                  : _nameController.text.toUpperCase(),
                              style: GoogleFonts.manrope(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.9),
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
                                fontSize: 10,
                                color: Colors.white38,
                                letterSpacing: 1.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _expiryController.text.isEmpty
                                  ? "12/26"
                                  : _expiryController.text,
                              style: GoogleFonts.manrope(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.9),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.manrope(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: kPrimaryColor.withOpacity(0.6),
            letterSpacing: 1.2,
          ),
        ),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          inputFormatters: inputFormatters,
          onChanged: onChanged,
          validator: (val) => val != null && val.isNotEmpty ? null : "Required",
          style: GoogleFonts.manrope(fontSize: 16, color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: kPrimaryColor),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
            suffixIcon: icon != null
                ? Icon(icon, color: Colors.white24, size: 20)
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
        cleanNumber.startsWith(RegExp(r'^2[2-7]')))
      return CardType.mastercard;
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
                  color: Colors.red.withOpacity(0.8),
                  shape: BoxShape.circle,
                ),
              ),
              Positioned(
                left: 20,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.8),
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
            color: Colors.white,
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
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      case CardType.discover:
        return Text(
          "Discover",
          style: GoogleFonts.inter(
            color: kWarningColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        );
      default:
        return const Icon(Icons.credit_card, color: Colors.white54, size: 28);
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
