import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_auth/local_auth.dart';
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
      if (!canCheck) {
        if (mounted) {
          context.go(
            '/home',
          ); // Fallback to home if biometrics are suddenly not available
        }
        return;
      }

      final bool didAuthenticate = await _auth.authenticate(
        localizedReason: 'Please authenticate to unlock Duty',
        biometricOnly: true,
      );

      if (didAuthenticate && mounted) {
        context.go('/home');
      }
    } catch (e) {
      appLog('Biometrics error: $e');
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
    final isLoggingOut = ref.watch(authControllerProvider).isLoading;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0712),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.lock_outline_rounded,
              size: 80,
              color: Color(0xFF8655F6),
            ),
            const SizedBox(height: 24),
            Text(
              'App Locked',
              style: GoogleFonts.splineSans(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Use Face ID to unlock',
              style: GoogleFonts.splineSans(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 48),
            if (_isAuthenticating)
              const CircularProgressIndicator(color: Color(0xFF8655F6))
            else
              ElevatedButton.icon(
                onPressed: _promptBiometrics,
                icon: const Icon(Icons.face_retouching_natural_rounded),
                label: const Text('Unlock'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8655F6),
                  foregroundColor: Colors.white,
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
              onPressed: isLoggingOut
                  ? null
                  : () async {
                      await ref.read(authControllerProvider.notifier).logout();
                      if (!context.mounted) return;
                      context.go('/login');
                    },
              child: Text(
                isLoggingOut ? 'Logging Out...' : 'Log Out',
                style: GoogleFonts.splineSans(
                  color: Colors.redAccent,
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
