import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/auth_provider.dart';
import '../widgets/auth_status_card.dart';

enum _ForgotPasswordStep { requestCode, resetPassword, success }

class ForgotPasswordPage extends ConsumerStatefulWidget {
  final String? initialEmail;

  const ForgotPasswordPage({super.key, this.initialEmail});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  _ForgotPasswordStep _step = _ForgotPasswordStep.requestCode;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _emailController.text = widget.initialEmail?.trim() ?? '';
  }

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _requestCode() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showMessage('Enter the email linked to your account.');
      return;
    }

    final result = await ref
        .read(authControllerProvider.notifier)
        .requestPasswordResetCode(email);

    if (!mounted || result == null) {
      return;
    }

    setState(() {
      _step = _ForgotPasswordStep.resetPassword;
    });

    _showMessage(
      result['message']?.toString() ??
          'We sent a 6-digit code to your email. Enter it below to reset your password.',
    );
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();
    final code = _codeController.text.trim();
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (email.isEmpty ||
        code.isEmpty ||
        newPassword.isEmpty ||
        confirmPassword.isEmpty) {
      _showMessage('Complete the code and both password fields.');
      return;
    }

    if (newPassword != confirmPassword) {
      _showMessage('The passwords do not match yet.');
      return;
    }

    if (newPassword.length < 6) {
      _showMessage('Use at least 6 characters for your new password.');
      return;
    }

    final result = await ref
        .read(authControllerProvider.notifier)
        .resetPassword(
          email: email,
          code: code,
          newPassword: newPassword,
          newPasswordConfirmation: confirmPassword,
        );

    if (!mounted || result == null) {
      return;
    }

    setState(() {
      _step = _ForgotPasswordStep.success;
    });

    _showMessage(
      result['message']?.toString() ??
          'Your password was updated. You can sign in now.',
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
      prefixIcon: Icon(icon, color: Colors.white.withValues(alpha: 0.5)),
      suffixIcon: suffixIcon,
      border: InputBorder.none,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    );
  }

  Widget _inputShell({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2C).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }

  Widget _stepPill(int number, String label, bool active) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: active
            ? const Color(0xFF6200EE).withValues(alpha: 0.22)
            : Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: active
              ? const Color(0xFFA855F7).withValues(alpha: 0.8)
              : Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: active
                  ? const Color(0xFF6200EE)
                  : Colors.white.withValues(alpha: 0.08),
            ),
            alignment: Alignment.center,
            child: Text(
              '$number',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: active ? 0.95 : 0.55),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(authControllerProvider, (previous, next) {
      if (next.hasError && mounted) {
        _showMessage(next.error.toString().replaceFirst('Exception: ', ''));
      }
    });

    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topRight,
            radius: 1.5,
            colors: [Color(0xFF2A1B3D), Color(0xFF0F0F1A)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => context.pop(),
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: Image.asset(
                        'assets/images/logo-w.png',
                        height: 30,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.confirmation_number,
                            size: 40,
                            color: Color(0xFF6200EE),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _step == _ForgotPasswordStep.success
                          ? 'Password updated'
                          : 'Recover account access',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.w700,
                        height: 1.05,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _step == _ForgotPasswordStep.requestCode
                          ? 'We will send a 6-digit recovery code to the email linked to your Duty account.'
                          : _step == _ForgotPasswordStep.resetPassword
                          ? 'Enter the code from your email and choose a new password.'
                          : 'Everything is ready. Head back to login and sign in with your new password.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        color: Colors.white.withValues(alpha: 0.62),
                        fontSize: 15,
                        height: 1.55,
                      ),
                    ),
                    const SizedBox(height: 18),
                    AuthStatusCard(
                      icon: _step == _ForgotPasswordStep.success
                          ? Icons.check_circle_rounded
                          : _step == _ForgotPasswordStep.resetPassword
                          ? Icons.lock_reset_rounded
                          : Icons.mark_email_read_outlined,
                      title: _step == _ForgotPasswordStep.success
                          ? 'Password refreshed'
                          : _step == _ForgotPasswordStep.resetPassword
                          ? 'Recovery code sent'
                          : 'Recovery by email',
                      subtitle: _step == _ForgotPasswordStep.success
                          ? 'Your account is ready again. Use the new password the next time you sign in.'
                          : _step == _ForgotPasswordStep.resetPassword
                          ? 'Open the latest email from Duty, grab the 6-digit code, and set your new password here.'
                          : 'This keeps account recovery simple without taking you out of the app.',
                      accentColor: _step == _ForgotPasswordStep.success
                          ? const Color(0xFF22C55E)
                          : const Color(0xFF8655F6),
                    ),
                    const SizedBox(height: 28),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      alignment: WrapAlignment.center,
                      children: [
                        _stepPill(
                          1,
                          'Email',
                          _step == _ForgotPasswordStep.requestCode,
                        ),
                        _stepPill(
                          2,
                          'Code + New Password',
                          _step == _ForgotPasswordStep.resetPassword,
                        ),
                        _stepPill(
                          3,
                          'Done',
                          _step == _ForgotPasswordStep.success,
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.08),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _inputShell(
                            child: TextField(
                              controller: _emailController,
                              enabled: _step != _ForgotPasswordStep.success,
                              keyboardType: TextInputType.emailAddress,
                              autofillHints: const [AutofillHints.email],
                              style: const TextStyle(color: Colors.white),
                              decoration: _inputDecoration(
                                label: 'Email address',
                                icon: Icons.alternate_email,
                              ),
                            ),
                          ),
                          if (_step == _ForgotPasswordStep.resetPassword ||
                              _step == _ForgotPasswordStep.success) ...[
                            const SizedBox(height: 16),
                            _inputShell(
                              child: TextField(
                                controller: _codeController,
                                enabled:
                                    _step == _ForgotPasswordStep.resetPassword,
                                keyboardType: TextInputType.number,
                                style: const TextStyle(color: Colors.white),
                                decoration: _inputDecoration(
                                  label: '6-digit code',
                                  icon: Icons.pin_outlined,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            _inputShell(
                              child: TextField(
                                controller: _newPasswordController,
                                enabled:
                                    _step == _ForgotPasswordStep.resetPassword,
                                obscureText: _obscureNewPassword,
                                style: const TextStyle(color: Colors.white),
                                decoration: _inputDecoration(
                                  label: 'New password',
                                  icon: Icons.lock_outline,
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _obscureNewPassword =
                                            !_obscureNewPassword;
                                      });
                                    },
                                    icon: Icon(
                                      _obscureNewPassword
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: Colors.white.withValues(
                                        alpha: 0.5,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            _inputShell(
                              child: TextField(
                                controller: _confirmPasswordController,
                                enabled:
                                    _step == _ForgotPasswordStep.resetPassword,
                                obscureText: _obscureConfirmPassword,
                                style: const TextStyle(color: Colors.white),
                                decoration: _inputDecoration(
                                  label: 'Confirm new password',
                                  icon: Icons.verified_user_outlined,
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _obscureConfirmPassword =
                                            !_obscureConfirmPassword;
                                      });
                                    },
                                    icon: Icon(
                                      _obscureConfirmPassword
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: Colors.white.withValues(
                                        alpha: 0.5,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 22),
                          if (_step == _ForgotPasswordStep.requestCode)
                            ElevatedButton(
                              onPressed: authState.isLoading
                                  ? null
                                  : _requestCode,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 18,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                elevation: 0,
                              ),
                              child: authState.isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.black,
                                      ),
                                    )
                                  : Text(
                                      'Send recovery code',
                                      style: GoogleFonts.outfit(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                            ),
                          if (_step == _ForgotPasswordStep.resetPassword) ...[
                            ElevatedButton(
                              onPressed: authState.isLoading
                                  ? null
                                  : _resetPassword,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 18,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                elevation: 0,
                              ),
                              child: authState.isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.black,
                                      ),
                                    )
                                  : Text(
                                      'Update password',
                                      style: GoogleFonts.outfit(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                            ),
                            const SizedBox(height: 12),
                            TextButton(
                              onPressed: authState.isLoading
                                  ? null
                                  : _requestCode,
                              child: const Text(
                                'Resend code',
                                style: TextStyle(color: Color(0xFF6200EE)),
                              ),
                            ),
                          ],
                          if (_step == _ForgotPasswordStep.success) ...[
                            ElevatedButton(
                              onPressed: () => context.go('/login'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 18,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                'Back to login',
                                style: GoogleFonts.outfit(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
