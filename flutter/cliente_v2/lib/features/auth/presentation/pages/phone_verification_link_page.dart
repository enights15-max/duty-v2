import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/providers/profile_state_provider.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/utils/app_logger.dart';
import '../providers/auth_provider.dart';

class PhoneVerificationLinkPage extends ConsumerStatefulWidget {
  final String verificationToken;

  const PhoneVerificationLinkPage({super.key, required this.verificationToken});

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
    final palette = context.dutyTheme;
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    final code = PhoneAuthUtils.extractOtpCode(clipboardData?.text);
    if (!mounted) return;

    if (code == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No 6-digit code was found in your clipboard.'),
          backgroundColor: palette.warning,
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
    final palette = context.dutyTheme;
    if (Firebase.apps.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Firebase no está inicializado'),
          backgroundColor: palette.danger,
        ),
      );
      return;
    }

    final phoneText = _phoneController.text.trim();
    if (phoneText.isEmpty || phoneText.length < 7) {
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

    _fullPhone = _selectedAreaCode.replaceAll(' ', '') + phoneText;

    setState(() => _isLoading = true);

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: _fullPhone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification
        },
        verificationFailed: (FirebaseAuthException e) {
          setState(() => _isLoading = false);
          debugPrint('Firebase Auth Error Code: ${e.code}');
          debugPrint('Firebase Auth Error Message: ${e.message}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                PhoneAuthUtils.codeSendErrorMessage(e.code, e.message),
              ),
              duration: const Duration(seconds: 4),
              backgroundColor: palette.danger,
            ),
          );
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _isLoading = false;
            _codeSent = true;
            _verificationId = verificationId;
          });
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al enviar el código. Verifique su conexión.'),
          backgroundColor: palette.danger,
        ),
      );
    }
  }

  Future<void> _verifyOtp() async {
    final palette = context.dutyTheme;
    final code = _otpController.text.trim();
    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor ingrese el código de 6 dígitos'),
          backgroundColor: palette.warning,
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
            SnackBar(
              content: Text(
                'Phone linked successfully. Opening your account...',
              ),
              behavior: SnackBarBehavior.floating,
              backgroundColor: palette.success,
            ),
          );
          await Future.delayed(const Duration(milliseconds: 350));
          if (!mounted) return;
          context.go(ref.read(activeProfileLandingRouteProvider));
        } else {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result?['message'] ?? 'Falló la vinculación'),
              backgroundColor: palette.danger,
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
          backgroundColor: palette.danger,
        ),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('We could not complete the verification right now.'),
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
                  _codeSent ? 'Verify Phone' : 'Link Phone Number',
                  style: GoogleFonts.outfit(
                    color: palette.textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _codeSent
                      ? 'Enter the 6-digit code sent to $_fullPhone'
                      : 'Please link and verify your mobile number to continue using your account securely.',
                  style: GoogleFonts.inter(
                    color: palette.textSecondary,
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
                  accentColor: _isSuccess ? palette.success : palette.primary,
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
                            ? palette.textMuted.withValues(alpha: 0.6)
                            : palette.primary,
                        size: 18,
                      ),
                      label: Text(
                        'Paste code',
                        style: TextStyle(
                          color: _isLoading
                              ? palette.textMuted.withValues(alpha: 0.6)
                              : palette.primary,
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
                          _codeSent
                              ? 'Verify & Continue'
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
                              ? palette.primary
                              : palette.textMuted,
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
    final palette = context.dutyTheme;
    return Container(
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
                icon: Icon(Icons.arrow_drop_down, color: palette.textSecondary),
                style: TextStyle(color: palette.textPrimary, fontSize: 16),
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
            color: palette.border,
            margin: const EdgeInsets.symmetric(horizontal: 12),
          ),
          Expanded(
            child: TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: TextStyle(color: palette.textPrimary),
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
                hintStyle: TextStyle(color: palette.textMuted),
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
    final palette = context.dutyTheme;
    return Container(
      decoration: BoxDecoration(
        color: palette.surfaceAlt.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: palette.border),
      ),
      child: TextField(
        controller: _otpController,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.done,
        autofillHints: const [AutofillHints.oneTimeCode],
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: TextStyle(
          color: palette.textPrimary,
          fontSize: 24,
          letterSpacing: 10,
        ),
        textAlign: TextAlign.center,
        maxLength: 6,
        decoration: InputDecoration(
          counterText: "",
          hintText: '000000',
          hintStyle: TextStyle(
            color: palette.textMuted.withValues(alpha: 0.55),
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
