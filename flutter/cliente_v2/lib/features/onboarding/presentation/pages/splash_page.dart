import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/profile_state_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    // Ensure we show the splash for at least 2 seconds
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    // Determine the next route based on current state
    final onboardingSeen = ref.read(onboardingSeenProvider);
    final token = await ref.read(authTokenProvider.future);
    if (!mounted) return;
    final isLoggedIn = token != null;
    final faceIdEnabled = ref.read(faceIdEnabledProvider);
    final keepSignedIn = ref.read(keepSignedInProvider);
    final landingRoute = ref.read(activeProfileLandingRouteProvider);

    if (!onboardingSeen) {
      context.go('/onboarding');
    } else if (isLoggedIn) {
      if (!keepSignedIn) {
        await ref.read(authControllerProvider.notifier).logout();
        if (!mounted) return;
        context.go('/login');
      } else if (faceIdEnabled) {
        context.go('/auth-lock');
      } else {
        context.go(landingRoute);
      }
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 61, 0, 168),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Using the white logo for the black background
            Image.asset('assets/images/logo-w.png', width: 250),
          ],
        ),
      ),
    );
  }
}
