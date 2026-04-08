import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_auth/local_auth.dart';
import '../../../../core/providers/profile_state_provider.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/utils/app_logger.dart';
import '../providers/auth_provider.dart';

class AuthLockPage extends ConsumerStatefulWidget {
  const AuthLockPage({super.key});

  @override
  ConsumerState<AuthLockPage> createState() => _AuthLockPageState();
}

class _AuthLockPageState extends ConsumerState<AuthLockPage> {
  final LocalAuthentication _auth = LocalAuthentication();
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _promptBiometrics();
    });
  }

  Future<void> _promptBiometrics() async {
    if (_isAuthenticating) return;
    setState(() {
      _isAuthenticating = true;
    });

    try {
      final bool canCheck =
          await _auth.canCheckBiometrics || await _auth.isDeviceSupported();
      final landingRoute = ref.read(activeProfileLandingRouteProvider);
      if (!canCheck) {
        if (mounted) {
          context.go(landingRoute);
        }
        return;
      }

      final bool didAuthenticate = await _auth.authenticate(
        localizedReason: 'Please authenticate to unlock Duty',
        biometricOnly: true,
      );

      if (didAuthenticate && mounted) {
        context.go(landingRoute);
      }
    } catch (e) {
      debugPrint('Biometrics error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isAuthenticating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.dutyTheme;
    final isLoggingOut = ref.watch(authControllerProvider).isLoading;

    return Scaffold(
      backgroundColor: palette.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline_rounded, size: 80, color: palette.primary),
            const SizedBox(height: 24),
            Text(
              'App Locked',
              style: GoogleFonts.splineSans(
                color: palette.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Use Face ID to unlock',
              style: GoogleFonts.splineSans(
                color: palette.textSecondary,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 48),
            if (_isAuthenticating)
              CircularProgressIndicator(color: palette.primary)
            else
              ElevatedButton.icon(
                onPressed: _promptBiometrics,
                icon: const Icon(Icons.face_retouching_natural_rounded),
                label: const Text('Unlock'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: palette.primary,
                  foregroundColor: palette.onPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () async {
                await ref.read(authControllerProvider.notifier).logout();
              },
              child: Text(
                'Log Out',
                style: GoogleFonts.splineSans(
                  color: palette.danger,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
