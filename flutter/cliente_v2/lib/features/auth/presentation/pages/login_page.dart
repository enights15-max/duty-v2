import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_status_card.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _keepSignedIn = true;

  @override
  void initState() {
    super.initState();
    final prefs = ref.read(sharedPreferencesProvider);
    _keepSignedIn = prefs.getBool(AppConstants.keepSignedInKey) ?? true;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    ref
        .read(authControllerProvider.notifier)
<<<<<<< Updated upstream
        .login(_usernameController.text, _passwordController.text);
=======
        .login(
          _usernameController.text,
          _passwordController.text,
          keepSignedIn: _keepSignedIn,
        );

    if (mounted && result != null) {
      final status = result['status'];
      if (status == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Welcome back. Opening your scene...'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        await Future.delayed(const Duration(milliseconds: 300));
        if (!mounted) return;
        context.go('/home');
      } else if (status == 'needs_phone_verification') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['message'] ?? 'Please verify your phone number',
            ),
          ),
        );
        context.push('/verify-phone-link', extra: result['verification_token']);
      }
    }
  }

  Future<void> _loginWithBiometrics() async {
    final auth = LocalAuthentication();
    final isFaceIdEnabled = ref.read(faceIdEnabledProvider);

    if (!isFaceIdEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, activa Face ID en Configuración primero.'),
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
          const SnackBar(
            content: Text('Biometría no soportada en este dispositivo'),
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
          context.go('/home');
        } else {
          // Biometría exitosa pero no hay token (debe hacer login manual primero)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sesión expirada. Inicia sesión manualmente.'),
            ),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error de Face ID: $e')));
    }
>>>>>>> Stashed changes
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(authControllerProvider, (previous, next) {
      if (next.hasError) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.error.toString())));
      } else if (!next.isLoading && !next.hasError && next.hasValue) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Login Exitoso!')));
        context.go('/home');
      }
    });

    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A), // Dark background
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topRight,
            radius: 1.5,
            colors: [
              Color(0xFF2A1B3D), // Purple glow
              Color(0xFF0F0F1A), // Dark base
            ],
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
                          return const Icon(
                            Icons.confirmation_number,
                            size: 80,
                            color: Color(0xFF6200EE),
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
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 18),
                  AuthStatusCard(
                    icon: ref.watch(faceIdEnabledProvider)
                        ? Icons.verified_user_rounded
                        : Icons.login_rounded,
                    title: ref.watch(faceIdEnabledProvider)
                        ? 'This device is ready for quick unlock'
                        : 'Use email, password, or phone login',
                    subtitle: ref.watch(faceIdEnabledProvider)
                        ? 'Your saved session can reopen with Face ID when you keep this device signed in.'
                        : 'Email login gets you in fast. Phone OTP is available when you need a code-based fallback.',
                  ),
                  const SizedBox(height: 40),

                  // Biometrics mock
                  Center(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF6200EE).withOpacity(0.3),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF6200EE).withOpacity(0.1),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.face,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Fast Login',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Biometrics enabled',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Inputs
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E2C).withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _usernameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Username',
                        labelStyle: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                        ),
                        prefixIcon: Icon(
                          Icons.person_outline,
                          color: Colors.white.withOpacity(0.5),
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
                      color: const Color(0xFF1E1E2C).withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Security Password',
                        labelStyle: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                        ),
                        prefixIcon: Icon(
                          Icons.lock_outline,
                          color: Colors.white.withOpacity(0.5),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.white.withOpacity(0.5),
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
                            activeColor: const Color(0xFF6200EE),
                            side: BorderSide(
                              color: Colors.white.withOpacity(0.5),
                            ),
                          ),
                          Text(
                            'Keep me signed in',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                            ),
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
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(color: Color(0xFF6200EE)),
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
                        ? const Color(0xFF8655F6)
                        : const Color(0xFFF59E0B),
                  ),

                  const SizedBox(height: 24),

                  // Button
                  ElevatedButton(
                    onPressed: authState.isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 18),
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
                      Expanded(
<<<<<<< Updated upstream
                        child: Divider(color: Colors.white.withOpacity(0.1)),
=======
                        child: Divider(
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
>>>>>>> Stashed changes
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'ALTERNATIVE ACCESS',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.3),
                            fontSize: 10,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
<<<<<<< Updated upstream
                        child: Divider(color: Colors.white.withOpacity(0.1)),
=======
                        child: Divider(
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
>>>>>>> Stashed changes
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Social
<<<<<<< Updated upstream
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.apple, color: Colors.white),
                          label: const Text(
                            'Apple',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: Colors.white.withOpacity(0.2),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
=======
                  const SizedBox(height: 32),
                  OutlinedButton.icon(
                    onPressed: () => context.push('/phone-login'),
                    icon: const Icon(Icons.phone_android, color: Colors.white),
                    label: const Text(
                      'Login with Phone Number',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
>>>>>>> Stashed changes
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.g_mobiledata,
                            color: Colors.white,
                            size: 28,
                          ), // Mock Google Icon
                          label: const Text(
                            'Google',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: Colors.white.withOpacity(0.2),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
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
                                color: Colors.white,
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
