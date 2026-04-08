import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/providers/profile_state_provider.dart';
import '../../../../core/theme/colors.dart';
import '../providers/auth_provider.dart';

class OtpVerificationPage extends ConsumerStatefulWidget {
  final String verificationId;
  final String phoneNumber;

  const OtpVerificationPage({
    super.key,
    required this.verificationId,
    required this.phoneNumber,
  });

  @override
  ConsumerState<OtpVerificationPage> createState() =>
      _OtpVerificationPageState();
}

class _OtpVerificationPageState extends ConsumerState<OtpVerificationPage> {
  final _otpController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
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

  Future<void> _resendCode() async {
    final palette = context.dutyTheme;
    if (_isLoading || _secondsUntilResend > 0) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: widget.phoneNumber,
        forceResendingToken: _resendToken,
        verificationCompleted: (_) {},
        verificationFailed: (FirebaseAuthException e) {
          if (!mounted) return;
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                PhoneAuthUtils.codeSendErrorMessage(e.code, e.message),
              ),
              backgroundColor: palette.danger,
            ),
          );
        },
        codeSent: (String verificationId, int? resendToken) {
          if (!mounted) return;
          setState(() {
            _isLoading = false;
            _verificationId = verificationId;
            _resendToken = resendToken;
            _otpController.clear();
          });
          _startResendCountdown();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'We sent a new code to ${PhoneAuthUtils.prettyPhone(widget.phoneNumber)}.',
              ),
              backgroundColor: palette.success,
            ),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('We could not resend the code right now.'),
          backgroundColor: palette.danger,
        ),
      );
    }
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
        verificationId: widget.verificationId,
        smsCode: code,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );
      final idToken = await userCredential.user?.getIdToken();

      if (idToken != null) {
        // Sync with Backend
        final result = await ref
            .read(authControllerProvider.notifier)
            .loginWithFirebase(idToken);

        if (mounted && result != null) {
          final status = result['status'];
          if (status == 'user_not_found') {
            context.push(
              '/complete-profile',
              extra: {'idToken': idToken, 'phoneNumber': widget.phoneNumber},
            );
          } else if (status == 'needs_email_setup') {
            context.push(
              '/setup-email',
              extra: {
                'setup_token': result['setup_token'],
                'phoneNumber': widget.phoneNumber,
              },
            );
          } else if (status == 'success') {
            setState(() => _isSuccess = true);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Phone verified. Taking you in...'),
                behavior: SnackBarBehavior.floating,
                backgroundColor: palette.success,
              ),
            );
            await Future.delayed(const Duration(milliseconds: 350));
            if (!mounted) return;
            context.go(ref.read(activeProfileLandingRouteProvider));
          }
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
          content: Text('We could not complete the login right now.'),
          backgroundColor: palette.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.dutyTheme;
    // Listen to auth state for errors from backend sync
    ref.listen<AsyncValue<void>>(authControllerProvider, (previous, next) {
      if (next.hasError) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              next.error.toString().replaceFirst('Exception: ', ''),
            ),
            backgroundColor: palette.danger,
          ),
        );
      }
    });

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
                  'Verify Phone',
                  style: GoogleFonts.outfit(
                    color: palette.textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter the 6-digit code sent to ${widget.phoneNumber}',
                  style: GoogleFonts.inter(
                    color: palette.textSecondary,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 18),
                AuthStatusCard(
                  icon: _isSuccess
                      ? Icons.check_circle_rounded
                      : Icons.sms_rounded,
                  title: _isSuccess
                      ? 'Access granted'
                      : 'Code sent to your phone',
                  subtitle: _isSuccess
                      ? 'Your account is verified and your session is ready.'
                      : 'AutoFill should appear above the keyboard when iOS or Android detects the incoming SMS.',
                  accentColor: _isSuccess ? palette.success : palette.primary,
                ),
                const SizedBox(height: 48),
                Container(
                  decoration: BoxDecoration(
                    color: palette.surfaceAlt.withValues(alpha: 0.88),
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
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                    ),
                  ),
                ),
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
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _isLoading ? null : _verifyOtp,
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
                          'Verify & Login',
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: TextButton(
                    onPressed: () => context.pop(),
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
            ),
          ),
        ),
      ),
    );
  }
}
