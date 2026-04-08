import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/app_logger.dart';
import '../providers/auth_provider.dart';
import '../utils/phone_auth_utils.dart';
import '../widgets/auth_status_card.dart';

class PhoneVerificationLinkPage extends ConsumerStatefulWidget {
  final String verificationToken;
  final String? phoneNumber;

  const PhoneVerificationLinkPage({
    super.key,
    required this.verificationToken,
    this.phoneNumber,
  });

  @override
  ConsumerState<PhoneVerificationLinkPage> createState() =>
      _PhoneVerificationLinkPageState();
}

class _PhoneVerificationLinkPageState
    extends ConsumerState<PhoneVerificationLinkPage> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  late final FirebaseAuth _auth;
  bool _isLoading = false;
  String _selectedAreaCode = '+1 809';

  bool _codeSent = false;
  String? _verificationId;
  String? _fullPhone;
  int? _resendToken;
  Timer? _resendTimer;
  int _secondsUntilResend = 0;
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
    try {
      _auth = FirebaseAuth.instance;
    } catch (e) {
      // Firebase not initialized
    }

    if (widget.phoneNumber != null && widget.phoneNumber!.isNotEmpty) {
      final normalized = PhoneAuthUtils.normalizeDominicanPhone(
        selectedAreaCode: _selectedAreaCode,
        rawInput: widget.phoneNumber!,
      );
      if (normalized != null) {
        _selectedAreaCode = normalized.areaCode;
        _phoneController.text = normalized.localNumber;
      } else {
        var phone = widget.phoneNumber!;
        if (phone.startsWith('+')) {
          phone = phone.substring(phone.length > 7 ? 5 : 1);
        }
        if (phone.length > 7) {
          phone = phone.substring(phone.length - 7);
        }
        _phoneController.text = phone;
      }
    }
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _startResendCountdown() {
    _resendTimer?.cancel();
    setState(() => _secondsUntilResend = 30);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_secondsUntilResend <= 1) {
        timer.cancel();
        setState(() => _secondsUntilResend = 0);
        return;
      }
      setState(() => _secondsUntilResend -= 1);
    });
  }

  Future<void> _pasteCodeFromClipboard() async {
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    final code = PhoneAuthUtils.extractOtpCode(clipboardData?.text);
    if (!mounted) return;

    if (code == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No 6-digit code was found in your clipboard.'),
        ),
      );
      return;
    }

    _otpController.text = code;
    await _verifyOtp();
  }

  void _handleOtpChanged(String value) {
    if (value.trim().length == 6 && !_isLoading) {
      Future.microtask(_verifyOtp);
    }
  }

  Future<void> _sendCode() async {
    if (Firebase.apps.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Firebase no está inicializado')),
      );
      return;
    }

    final normalized = PhoneAuthUtils.normalizeDominicanPhone(
      selectedAreaCode: _selectedAreaCode,
      rawInput: _phoneController.text,
    );
    if (normalized == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Enter a valid Dominican phone number. You can use 7 or 10 digits.',
          ),
        ),
      );
      return;
    }

    _selectedAreaCode = normalized.areaCode;
    _phoneController.text = normalized.localNumber;
    _fullPhone = normalized.e164;

    setState(() => _isLoading = true);

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: _fullPhone,
        forceResendingToken: _resendToken,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification
        },
        verificationFailed: (FirebaseAuthException e) {
          setState(() => _isLoading = false);
          appLog('Firebase Auth Error Code: ${e.code}');
          appLog('Firebase Auth Error Message: ${e.message}');

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                PhoneAuthUtils.codeSendErrorMessage(e.code, e.message),
              ),
              duration: const Duration(seconds: 4),
            ),
          );
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _isLoading = false;
            _codeSent = true;
            _verificationId = verificationId;
            _resendToken = resendToken;
          });
          _startResendCountdown();
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al enviar el código. Verifique su conexión.'),
        ),
      );
    }
  }

  Future<void> _verifyOtp() async {
    final code = _otpController.text.trim();
    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor ingrese el código de 6 dígitos'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: code,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );
      final idToken = await userCredential.user?.getIdToken();

      if (idToken != null) {
        // Submit to custom backend with the specific token received previously
        final result = await ref
            .read(authControllerProvider.notifier)
            .verifyPhoneLink(idToken: idToken, token: widget.verificationToken);

        if (!mounted) return;
        if (result != null && result['status'] == 'success') {
          setState(() => _isSuccess = true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Phone linked successfully. Opening your account...',
              ),
              behavior: SnackBarBehavior.floating,
            ),
          );
          await Future.delayed(const Duration(milliseconds: 350));
          if (!mounted) return;
          context.go('/home');
        } else {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result?['message'] ?? 'Falló la vinculación'),
            ),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            PhoneAuthUtils.codeVerifyErrorMessage(e.code, e.message),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('We could not complete the verification right now.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            if (_codeSent) {
              setState(() {
                _codeSent = false;
                _otpController.clear();
              });
            } else {
              context.pop();
            }
          },
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topRight,
            radius: 1.5,
            colors: [Color(0xFF2A1B3D), Color(0xFF0F0F1A)],
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
                  _codeSent ? 'Verify Phone' : 'Link Phone Number',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _codeSent
                      ? 'Enter the 6-digit code sent to ${PhoneAuthUtils.prettyPhone(_fullPhone ?? widget.phoneNumber ?? "")}'
                      : 'Please link and verify your mobile number to continue using your account securely.',
                  style: GoogleFonts.inter(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 18),
                AuthStatusCard(
                  icon: _codeSent
                      ? (_isSuccess
                            ? Icons.check_circle_rounded
                            : Icons.sms_rounded)
                      : Icons.phone_iphone_rounded,
                  title: _codeSent
                      ? (_isSuccess
                            ? 'Phone linked'
                            : 'Verification in progress')
                      : 'Secure your account',
                  subtitle: _codeSent
                      ? (_isSuccess
                            ? 'Your phone is now connected to this account.'
                            : 'Paste the code from SMS or wait for AutoFill to pick it up for you.')
                      : 'We use your phone to protect account access and make sign-in recovery easier.',
                  accentColor: _isSuccess
                      ? const Color(0xFF22C55E)
                      : const Color(0xFF8655F6),
                ),
                const SizedBox(height: 48),
                if (!_codeSent) _buildPhoneInput() else _buildOtpInput(),
                if (_codeSent) ...[
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: _isLoading ? null : _pasteCodeFromClipboard,
                      icon: Icon(
                        Icons.content_paste_rounded,
                        color: _isLoading
                            ? Colors.white.withValues(alpha: 0.35)
                            : const Color(0xFF6200EE),
                        size: 18,
                      ),
                      label: Text(
                        'Paste code',
                        style: TextStyle(
                          color: _isLoading
                              ? Colors.white.withValues(alpha: 0.35)
                              : const Color(0xFF6200EE),
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : (_codeSent ? _verifyOtp : _sendCode),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.black,
                          ),
                        )
                      : Text(
                          _codeSent
                              ? (_isSuccess ? 'Verified' : 'Verify & Continue')
                              : 'Send Verification Code',
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                if (_codeSent) ...[
                  const SizedBox(height: 18),
                  Center(
                    child: TextButton(
                      onPressed: !_isLoading && _secondsUntilResend == 0
                          ? _sendCode
                          : null,
                      child: Text(
                        _secondsUntilResend == 0
                            ? 'Resend Code'
                            : 'Resend in ${_secondsUntilResend}s',
                        style: TextStyle(
                          color: _secondsUntilResend == 0
                              ? const Color(0xFF6200EE)
                              : Colors.white.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneInput() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2C).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedAreaCode,
                dropdownColor: const Color(0xFF1E1E2C),
                icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
                style: const TextStyle(color: Colors.white, fontSize: 16),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() => _selectedAreaCode = newValue);
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
            color: Colors.white.withValues(alpha: 0.2),
            margin: const EdgeInsets.symmetric(horizontal: 12),
          ),
          Expanded(
            child: TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: const TextStyle(color: Colors.white),
              maxLength: 10,
              buildCounter:
                  (
                    context, {
                    required currentLength,
                    required isFocused,
                    maxLength,
                  }) => null,
              decoration: InputDecoration(
                hintText: '8091234567 or 1234567',
                hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpInput() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2C).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: TextField(
        controller: _otpController,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.done,
        autofillHints: const [AutofillHints.oneTimeCode],
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          letterSpacing: 10,
        ),
        textAlign: TextAlign.center,
        maxLength: 6,
        onChanged: _handleOtpChanged,
        onSubmitted: (_) => _verifyOtp(),
        decoration: InputDecoration(
          counterText: "",
          hintText: '000000',
          hintStyle: TextStyle(
            color: Colors.white.withValues(alpha: 0.2),
            letterSpacing: 10,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}
