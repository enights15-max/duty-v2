import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/theme/colors.dart';
import '../utils/phone_auth_utils.dart';
import '../widgets/auth_status_card.dart';

class PhoneLoginPage extends ConsumerStatefulWidget {
  const PhoneLoginPage({super.key});

  @override
  ConsumerState<PhoneLoginPage> createState() => _PhoneLoginPageState();
}

class _PhoneLoginPageState extends ConsumerState<PhoneLoginPage> {
  final _phoneController = TextEditingController();
  late final FirebaseAuth _auth;
  bool _isLoading = false;
  String _selectedAreaCode = '+1 809';

  @override
  void initState() {
    super.initState();
    try {
      _auth = FirebaseAuth.instance;
    } catch (e) {
      // Firebase not initialized
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _verifyPhone() async {
    final palette = context.dutyTheme;
    final normalized = PhoneAuthUtils.normalizeDominicanPhone(
      selectedAreaCode: _selectedAreaCode,
      rawInput: _phoneController.text,
    );
    if (normalized == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Enter a valid Dominican phone number. You can use 7 or 10 digits.',
          ),
          backgroundColor: palette.warning,
        ),
      );
      return;
    }

    final fullPhone = _selectedAreaCode.replaceAll(' ', '') + phoneText;

    setState(() => _isLoading = true);

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: fullPhone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification IF possible (Android only)
        },
        verificationFailed: (FirebaseAuthException e) {
          setState(() => _isLoading = false);
          debugPrint('Firebase Auth Error Code: ${e.code}');
          debugPrint('Firebase Auth Error Message: ${e.message}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error [${e.code}]: ${e.message}'),
              duration: const Duration(seconds: 5),
              backgroundColor: palette.danger,
            ),
          );
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() => _isLoading = false);
          context.push(
            '/otp-verification',
            extra: {'verificationId': verificationId, 'phoneNumber': fullPhone},
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ocurrió un error: $e'),
          backgroundColor: palette.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.dutyTheme;
    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: palette.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topRight,
            radius: 1.5,
            colors: [palette.heroGradientStart, palette.background],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                Text(
                  'Login with Phone',
                  style: GoogleFonts.outfit(
                    color: palette.textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter your mobile number to receive a verification code.',
                  style: GoogleFonts.inter(
                    color: palette.textSecondary,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 48),
                Container(
                  decoration: BoxDecoration(
                    color: palette.surfaceAlt.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: palette.border),
                  ),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedAreaCode,
                            dropdownColor: palette.surface,
                            icon: Icon(
                              Icons.arrow_drop_down,
                              color: palette.textSecondary,
                            ),
                            style: TextStyle(
                              color: palette.textPrimary,
                              fontSize: 16,
                            ),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  _selectedAreaCode = newValue;
                                });
                              }
                            },
                            items: <String>['+1 809', '+1 829', '+1 849']
                                .map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text('🇩🇴 $value'),
                                  );
                                })
                                .toList(),
                          ),
                        ),
                      ),
                      Container(
                        height: 24,
                        width: 1,
                        color: palette.border,
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          style: TextStyle(color: palette.textPrimary),
                          maxLength: 10,
                          buildCounter:
                              (
                                context, {
                                required currentLength,
                                required isFocused,
                                maxLength,
                              }) => null, // Hide counter
                          decoration: InputDecoration(
                            hintText: '8091234567 or 1234567',
                            hintStyle: TextStyle(color: palette.textMuted),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _isLoading || Firebase.apps.isEmpty
                      ? null
                      : _verifyPhone,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: palette.primary,
                    foregroundColor: palette.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: _isLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: palette.onPrimary,
                          ),
                        )
                      : Text(
                          'Send Verification Code',
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Tip: you can type 1234567 or a full local number like 8091234567.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    color: palette.textMuted,
                    fontSize: 12,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
