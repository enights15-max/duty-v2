import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class AccountVerificationPage extends ConsumerStatefulWidget {
  const AccountVerificationPage({super.key});

  @override
  ConsumerState<AccountVerificationPage> createState() =>
      _AccountVerificationPageState();
}

class _AccountVerificationPageState
    extends ConsumerState<AccountVerificationPage> {
  bool _isSendingEmailOtp = false;
  bool _isVerifyingEmailOtp = false;
  final TextEditingController _emailOtpController = TextEditingController();

  Future<void> _sendEmailVerification() async {
    setState(() => _isSendingEmailOtp = true);
    final authNotifier = ref.read(authControllerProvider.notifier);
    final result = await authNotifier.sendEmailVerification();
    setState(() => _isSendingEmailOtp = false);

    if (!mounted) return;

    if (result != null && result['status'] == 'success') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verification code sent to your email!')),
      );
      _showEmailVerifyDialog();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result?['message'] ?? 'Failed to send verification email',
          ),
        ),
      );
    }
  }

  void _showEmailVerifyDialog() {
    _emailOtpController.clear();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final palette = context.dutyTheme;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: palette.surface,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: palette.border),
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                'Enter OTP',
                style: GoogleFonts.splineSans(
                  color: palette.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Please enter the 6-digit code sent to your email.',
                    style: GoogleFonts.splineSans(color: palette.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _emailOtpController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    style: TextStyle(color: palette.textPrimary),
                    decoration: InputDecoration(
                      hintText: '123456',
                      hintStyle: TextStyle(color: palette.textMuted),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: palette.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: palette.primary),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: palette.textMuted),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: palette.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _isVerifyingEmailOtp
                      ? null
                      : () async {
                          final code = _emailOtpController.text.trim();
                          if (code.length != 6) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Please enter a valid 6-digit code.',
                                ),
                              ),
                            );
                            return;
                          }

                          setDialogState(() => _isVerifyingEmailOtp = true);
                          final authNotifier = ref.read(
                            authControllerProvider.notifier,
                          );
                          final result = await authNotifier.verifyEmailOtp(
                            code,
                          );
                          setDialogState(() => _isVerifyingEmailOtp = false);

                          if (!context.mounted) return;

                          if (result != null && result['status'] == 'success') {
                            Navigator.pop(context); // Close dialog
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Email verified successfully!'),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  result?['message'] ?? 'Invalid OTP code',
                                ),
                              ),
                            );
                          }
                        },
                  child: _isVerifyingEmailOtp
                      ? SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(
                            color: palette.onPrimary,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Verify'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.dutyTheme;
    final currentUserData = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        backgroundColor: palette.background.withValues(alpha: 0.88),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: palette.primary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Account Verification',
          style: GoogleFonts.splineSans(
            color: palette.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Builder(
        builder: (context) {
          final user = currentUserData;

          if (user == null) {
            return const Center(
              child: Text(
                'Error loading user data',
                style: TextStyle(color: kTextPrimary),
              ),
            );
          }
          final isEmailVerified = user['email_verified_at'] != null;
          final isPhoneVerified = user['phone_verified_at'] != null;

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                'Secure your account by completing our verification process. Some features, like purchasing items, require account verification.',
                style: GoogleFonts.splineSans(
                  color: palette.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),

              _buildVerificationCard(
                icon: Icons.email_rounded,
                title: 'Email Address',
                subtitle: user['email'] ?? 'No email found',
                isVerified: isEmailVerified,
                actionText: _isSendingEmailOtp ? 'Sending...' : 'Verify Email',
                onAction: _isSendingEmailOtp ? null : _sendEmailVerification,
                isLoading: _isSendingEmailOtp,
              ),

              const SizedBox(height: 16),

              _buildVerificationCard(
                icon: Icons.phone_android_rounded,
                title: 'Phone Number',
                subtitle: user['phone'] ?? 'No phone number provided',
                isVerified: isPhoneVerified,
                actionText: 'Verify Phone',
                onAction: () => context.push(
                  '/verify-phone-link',
                ), // Use existing phone verification flow
                // Disable phone verification until email is verified
                isEnabled: isEmailVerified,
                disabledMessage: 'Please verify your email address first.',
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildVerificationCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isVerified,
    required String actionText,
    VoidCallback? onAction,
    bool isLoading = false,
    bool isEnabled = true,
    String? disabledMessage,
  }) {
    final palette = context.dutyTheme;
    return Container(
      decoration: BoxDecoration(
        color: palette.surfaceAlt,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isVerified
              ? palette.success.withValues(alpha: 0.32)
              : palette.border,
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isVerified
                      ? palette.success.withValues(alpha: 0.12)
                      : palette.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: isVerified ? palette.success : palette.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.splineSans(
                        color: palette.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: GoogleFonts.splineSans(
                        color: palette.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              if (isVerified)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: palette.success.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        color: palette.success,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Verified',
                        style: GoogleFonts.splineSans(
                          color: palette.success,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          if (!isVerified) ...[
            const SizedBox(height: 20),
            if (!isEnabled && disabledMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  disabledMessage,
                  style: GoogleFonts.splineSans(
                    color: palette.warning,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isEnabled
                      ? palette.primary
                      : palette.surfaceMuted,
                  foregroundColor: isEnabled
                      ? palette.onPrimary
                      : palette.textMuted,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                onPressed: isEnabled ? onAction : null,
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        actionText,
                        style: GoogleFonts.splineSans(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
