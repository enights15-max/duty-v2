import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../../../../core/providers/profile_state_provider.dart';
import '../../../../core/theme/colors.dart';
import '../providers/auth_provider.dart';

class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({super.key});

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _fnameController = TextEditingController();
  final _lnameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String _phoneNumber = '';

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Validation state
  bool _isEmailAvailable = true;
  bool _isPhoneAvailable = true;
  bool _isUsernameAvailable = true;
  bool _isCheckingEmail = false;
  bool _isCheckingPhone = false;
  bool _isCheckingUsername = false;

  Timer? _emailDebounce;
  Timer? _phoneDebounce;
  Timer? _usernameDebounce;

  @override
  void dispose() {
    _fnameController.dispose();
    _lnameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emailDebounce?.cancel();
    _phoneDebounce?.cancel();
    _usernameDebounce?.cancel();
    super.dispose();
  }

  void _onUsernameChanged(String username) {
    if (_usernameDebounce?.isActive ?? false) _usernameDebounce!.cancel();
    if (username.isEmpty) {
      setState(() {
        _isUsernameAvailable = true;
        _isCheckingUsername = false;
      });
      return;
    }

    setState(() => _isCheckingUsername = true);
    _usernameDebounce = Timer(const Duration(milliseconds: 500), () async {
      final authNotifier = ref.read(authControllerProvider.notifier);
      final result = await authNotifier.checkAvailability(username: username);
      if (mounted) {
        setState(() {
          _isCheckingUsername = false;
          _isUsernameAvailable = result?['is_username_available'] ?? true;
        });
      }
    });
  }

  void _onEmailChanged(String email) {
    if (_emailDebounce?.isActive ?? false) _emailDebounce!.cancel();
    if (email.isEmpty ||
        !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      setState(() {
        _isEmailAvailable = true;
        _isCheckingEmail = false;
      });
      return;
    }

    setState(() => _isCheckingEmail = true);
    _emailDebounce = Timer(const Duration(milliseconds: 500), () async {
      final authNotifier = ref.read(authControllerProvider.notifier);
      final result = await authNotifier.checkAvailability(email: email);
      if (mounted) {
        setState(() {
          _isCheckingEmail = false;
          _isEmailAvailable = result?['is_email_available'] ?? true;
        });
      }
    });
  }

  void _onPhoneChanged(String phone) {
    if (_phoneDebounce?.isActive ?? false) _phoneDebounce!.cancel();
    _phoneNumber = phone;
    if (phone.isEmpty) {
      setState(() {
        _isPhoneAvailable = true;
        _isCheckingPhone = false;
      });
      return;
    }

    setState(() => _isCheckingPhone = true);
    _phoneDebounce = Timer(const Duration(milliseconds: 500), () async {
      final authNotifier = ref.read(authControllerProvider.notifier);
      final result = await authNotifier.checkAvailability(phone: phone);
      if (mounted) {
        setState(() {
          _isCheckingPhone = false;
          _isPhoneAvailable = result?['is_phone_available'] ?? true;
        });
      }
    });
  }

  void _signup() {
    final palette = context.dutyTheme;
    if (!_isEmailAvailable || !_isPhoneAvailable || !_isUsernameAvailable) {
      return;
    }

    if (_formKey.currentState!.validate()) {
      if (_phoneNumber.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Por favor ingrese su número de teléfono.'),
            backgroundColor: palette.warning,
          ),
        );
        return;
      }

      final data = {
        'fname': _fnameController.text,
        'lname': _lnameController.text,
        'username': _usernameController.text,
        'email': _emailController.text,
        'phone': _phoneNumber,
        'password': _passwordController.text,
        'password_confirmation': _confirmPasswordController.text,
      };

      ref.read(authControllerProvider.notifier).signup(data);
    }
  }

  Widget _buildGlassTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData prefixIcon,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    String? errorText,
  }) {
    final palette = context.dutyTheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: palette.surfaceAlt.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: errorText != null
              ? palette.danger.withValues(alpha: 0.7)
              : palette.border,
        ),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        style: TextStyle(color: palette.textPrimary),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(color: palette.textMuted),
          prefixIcon: Icon(prefixIcon, color: palette.textMuted),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          errorText: errorText,
        ),
        validator: validator,
      ),
    );
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
      } else if (!next.isLoading && !next.hasError && next.hasValue) {
        // Now that signup returns a token, we are automatically authenticated
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registro exitoso. Bienvenido a Duty!'),
            backgroundColor: palette.success,
          ),
        );
        // The AppRouter will automatically detect the auth state change and
        // handle the redirection, but to be sure we navigate cleanly:
        context.go(ref.read(activeProfileLandingRouteProvider));
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
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Stack(
                      alignment: Alignment.centerLeft,
                      children: [
                        IconButton(
                          padding: EdgeInsets.zero,
                          icon: Icon(
                            Icons.arrow_back,
                            color: palette.textPrimary,
                          ),
                          onPressed: () => context.pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Create Account',
                      style: GoogleFonts.outfit(
                        color: palette.textPrimary,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Join the ultimate events ecosystem.',
                      style: GoogleFonts.inter(
                        color: palette.textSecondary,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 40),

                    Row(
                      children: [
                        Expanded(
                          child: _buildGlassTextField(
                            controller: _fnameController,
                            labelText: 'Nombre',
                            prefixIcon: Icons.person_outline,
                            validator: (v) {
                              if (v!.isEmpty) {
                                return 'Requerido';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildGlassTextField(
                            controller: _lnameController,
                            labelText: 'Apellido',
                            prefixIcon: Icons.person_outline,
                            validator: (v) {
                              if (v!.isEmpty) {
                                return 'Requerido';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),

                    _buildGlassTextField(
                      controller: _usernameController,
                      labelText: 'Usuario',
                      prefixIcon: Icons.alternate_email,
                      onChanged: _onUsernameChanged,
                      errorText: !_isUsernameAvailable
                          ? 'Este usuario ya está en uso'
                          : null,
                      suffixIcon: _isCheckingUsername
                          ? Padding(
                              padding: EdgeInsets.all(12.0),
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: palette.primary,
                                ),
                              ),
                            )
                          : (_usernameController.text.isNotEmpty &&
                                    _isUsernameAvailable
                                ? const Icon(
                                    Icons.check_circle,
                                    color: kSuccessColor,
                                  )
                                : null),
                      validator: (v) {
                        if (v!.isEmpty) {
                          return 'Requerido';
                        }
                        if (v.contains(' ')) {
                          return 'El usuario no puede contener espacios';
                        }
                        return null;
                      },
                    ),

                    _buildGlassTextField(
                      controller: _emailController,
                      labelText: 'Email',
                      prefixIcon: Icons.email_outlined,
                      onChanged: _onEmailChanged,
                      errorText: !_isEmailAvailable
                          ? 'Este email ya está en uso'
                          : null,
                      suffixIcon: _isCheckingEmail
                          ? Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: palette.primary,
                                ),
                              ),
                            )
                          : (_emailController.text.isNotEmpty &&
                                    _isEmailAvailable
                                ? const Icon(
                                    Icons.check_circle,
                                    color: kSuccessColor,
                                  )
                                : null),
                      validator: (v) {
                        if (v!.isEmpty) {
                          return 'Requerido';
                        }
                        if (!RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                        ).hasMatch(v)) {
                          return 'Email inválido';
                        }
                        return null;
                      },
                    ),

                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: palette.surfaceAlt.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: !_isPhoneAvailable
                              ? palette.danger.withValues(alpha: 0.7)
                              : palette.border,
                        ),
                      ),
                      child: IntlPhoneField(
                        decoration: InputDecoration(
                          labelText: 'Teléfono',
                          labelStyle: TextStyle(color: palette.textMuted),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          counterText: '',
                          errorText: !_isPhoneAvailable
                              ? 'Este teléfono ya está en uso'
                              : null,
                          suffixIcon: _isCheckingPhone
                              ? Padding(
                                  padding: EdgeInsets.all(12.0),
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: palette.primary,
                                    ),
                                  ),
                                )
                              : (_phoneNumber.isNotEmpty && _isPhoneAvailable
                                    ? const Icon(
                                        Icons.check_circle,
                                        color: kSuccessColor,
                                      )
                                    : null),
                        ),
                        dropdownTextStyle: TextStyle(
                          color: palette.textPrimary,
                        ),
                        style: TextStyle(color: palette.textPrimary),
                        initialCountryCode: 'DO',
                        onChanged: (phone) {
                          _onPhoneChanged(phone.completeNumber);
                        },
                      ),
                    ),

                    _buildGlassTextField(
                      controller: _passwordController,
                      labelText: 'Contraseña',
                      prefixIcon: Icons.lock_outline,
                      obscureText: _obscurePassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: palette.textMuted,
                        ),
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                      ),
                      validator: (v) {
                        if (v!.length < 6) {
                          return 'Mínimo 6 caracteres';
                        }
                        return null;
                      },
                    ),

                    _buildGlassTextField(
                      controller: _confirmPasswordController,
                      labelText: 'Confirmar Contraseña',
                      prefixIcon: Icons.lock_outline,
                      obscureText: _obscureConfirmPassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: palette.textMuted,
                        ),
                        onPressed: () => setState(
                          () => _obscureConfirmPassword =
                              !_obscureConfirmPassword,
                        ),
                      ),
                      validator: (v) {
                        if (v!.isEmpty) {
                          return 'Requerido';
                        }
                        if (v != _passwordController.text) {
                          return 'Las contraseñas no coinciden';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 24),

                    ElevatedButton(
                      onPressed:
                          (authState.isLoading ||
                              !_isEmailAvailable ||
                              !_isPhoneAvailable ||
                              !_isUsernameAvailable)
                          ? null
                          : _signup,
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
                              'Sign Up',
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                    const SizedBox(height: 24),
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
