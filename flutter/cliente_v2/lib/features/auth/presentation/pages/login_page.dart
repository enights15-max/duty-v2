import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_auth/local_auth.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/providers/profile_state_provider.dart';
import '../../../../core/theme/colors.dart';
import '../providers/auth_provider.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _keepSignedIn = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final palette = context.dutyTheme;
    final result = await ref
        .read(authControllerProvider.notifier)
        .login(_usernameController.text, _passwordController.text);

    if (mounted && result != null) {
      final status = result['status'];
      if (status == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Welcome back. Opening your scene...'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: palette.success,
          ),
        );
        await Future.delayed(const Duration(milliseconds: 300));
        if (!mounted) return;
        context.go(ref.read(activeProfileLandingRouteProvider));
      } else if (status == 'needs_phone_verification') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['message'] ?? 'Please verify your phone number',
            ),
            backgroundColor: palette.warning,
          ),
        );
        context.push('/verify-phone-link', extra: result['verification_token']);
      }
    }
  }

  Future<void> _loginWithBiometrics() async {
    final palette = context.dutyTheme;
    final auth = LocalAuthentication();
    final isFaceIdEnabled = ref.read(faceIdEnabledProvider);

    if (!isFaceIdEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor, activa Face ID en Configuración primero.'),
          backgroundColor: palette.warning,
        ),
      );
      return;
    }

    try {
      final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
      final bool canAuthenticate =
          canAuthenticateWithBiometrics || await auth.isDeviceSupported();

      if (!canAuthenticate) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Biometría no soportada en este dispositivo'),
            backgroundColor: palette.warning,
          ),
        );
        return;
      }

      final bool didAuthenticate = await auth.authenticate(
        localizedReason: 'Autentícate para iniciar sesión',
        biometricOnly: true,
      );

      if (didAuthenticate && mounted) {
        final secureStorage = ref.read(flutterSecureStorageProvider);
        final token = await secureStorage.read(
          key: AppConstants.secureTokenKey,
        );

        if (!mounted) return;

        if (token != null && token.isNotEmpty) {
          // Ya hay sesión guardada y la biometría fue exitosa
          context.go(ref.read(activeProfileLandingRouteProvider));
        } else {
          // Biometría exitosa pero no hay token (debe hacer login manual primero)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Sesión expirada. Inicia sesión manualmente.'),
              backgroundColor: palette.warning,
            ),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error de Face ID: $e'),
          backgroundColor: palette.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.dutyTheme;
    ref.listen<AsyncValue<void>>(authControllerProvider, (previous, next) {
      if (next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error.toString()),
            backgroundColor: palette.danger,
          ),
        );
      }
    });

    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      backgroundColor: palette.background,
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topRight,
            radius: 1.5,
            colors: [palette.heroGradientStart, palette.background],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Hero(
                      tag: 'app_logo',
                      child: Image.asset(
                        'assets/images/logo-w.png',
                        height: 30,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.confirmation_number,
                            size: 80,
                            color: palette.primary,
                          );
                        },
                      ),
                    ),
                  ),
                  // const SizedBox(height: 16),
                  // Text(
                  //   'Welcome Back',
                  //   style: GoogleFonts.outfit(
                  //     color: Colors.white,
                  //     fontSize: 20,
                  //     fontWeight: FontWeight.bold,
                  //   ),
                  // ),
                  const SizedBox(height: 8),
                  Text(
                    'Access your unified events ecosystem.',
                    style: GoogleFonts.inter(
                      color: palette.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Biometrics button
                  if (ref.watch(faceIdEnabledProvider))
                    Center(
                      child: GestureDetector(
                        onTap: _loginWithBiometrics,
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: palette.primary.withValues(alpha: 0.3),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: palette.primary.withValues(
                                      alpha: 0.14,
                                    ),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.face,
                                size: 40,
                                color: palette.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Fast Login',
                              style: TextStyle(
                                color: palette.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Face ID enabled',
                              style: TextStyle(
                                color: palette.textMuted,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (ref.watch(faceIdEnabledProvider))
                    const SizedBox(height: 40),

                  // Inputs
                  Container(
                    decoration: BoxDecoration(
                      color: palette.surfaceAlt.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: palette.border),
                    ),
                    child: TextField(
                      controller: _usernameController,
                      style: TextStyle(color: palette.textPrimary),
                      decoration: InputDecoration(
                        labelText: 'Username',
                        labelStyle: TextStyle(color: palette.textMuted),
                        prefixIcon: Icon(
                          Icons.person_outline,
                          color: palette.textMuted,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: palette.surfaceAlt.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: palette.border),
                    ),
                    child: TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: TextStyle(color: palette.textPrimary),
                      decoration: InputDecoration(
                        labelText: 'Security Password',
                        labelStyle: TextStyle(color: palette.textMuted),
                        prefixIcon: Icon(
                          Icons.lock_outline,
                          color: palette.textMuted,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: palette.textMuted,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Options
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: _keepSignedIn,
                            onChanged: (v) =>
                                setState(() => _keepSignedIn = v!),
                            activeColor: palette.primary,
                            side: BorderSide(color: palette.textMuted),
                          ),
                          Text(
                            'Keep me signed in',
                            style: TextStyle(color: palette.textSecondary),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () {
                          final rawValue = _usernameController.text.trim();
                          final email = rawValue.contains('@') ? rawValue : '';
                          final query = email.isNotEmpty
                              ? '?email=${Uri.encodeComponent(email)}'
                              : '';
                          context.push('/forgot-password$query');
                        },
                        child: Text(
                          'Forgot Password?',
                          style: TextStyle(color: palette.primary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  AuthStatusCard(
                    icon: _keepSignedIn
                        ? Icons.lock_clock_rounded
                        : Icons.timer_outlined,
                    title: _keepSignedIn
                        ? 'Session stays on this device'
                        : 'Session ends when you relaunch',
                    subtitle: _keepSignedIn
                        ? 'We will keep your session available here and use Face ID lock if you enabled it.'
                        : 'Good for shared or temporary devices. You will need to sign in again next time.',
                    accentColor: _keepSignedIn
                        ? palette.primary
                        : palette.warning,
                  ),

                  const SizedBox(height: 24),

                  // Button
                  ElevatedButton(
                    onPressed: authState.isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: palette.primary,
                      foregroundColor: palette.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                    ),
                    child: authState.isLoading
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: palette.onPrimary,
                            ),
                          )
                        : Text(
                            'Sign In',
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),

                  const SizedBox(height: 32),

                  // Alternative
                  Row(
                    children: [
                      Expanded(child: Divider(color: palette.border)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'ALTERNATIVE ACCESS',
                          style: TextStyle(
                            color: palette.textMuted,
                            fontSize: 10,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: palette.border)),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Social
                  const SizedBox(height: 32),
                  OutlinedButton.icon(
                    onPressed: () => context.push('/phone-login'),
                    icon: Icon(Icons.phone_android, color: palette.textPrimary),
                    label: Text(
                      'Login with Phone Number',
                      style: TextStyle(color: palette.textPrimary),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: palette.borderStrong),
                      backgroundColor: palette.surface,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 48),

                  Center(
                    child: GestureDetector(
                      onTap: () => context.push('/signup'),
                      child: RichText(
                        text: const TextSpan(
                          text: 'New to the platform? ',
                          style: TextStyle(color: Colors.grey),
                          children: [
                            TextSpan(
                              text: 'Create Account',
                              style: TextStyle(
                                color: kTextPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
