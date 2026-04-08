import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/providers/profile_state_provider.dart';
import '../../../../core/theme/colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingItem> _items = [
    OnboardingItem(
      title: 'Bienvenido a Duty',
      description:
          'Acceso exclusivo a los mejores eventos y experiencias VIP en un solo lugar.',
      image:
          'assets/images/onboarding_1.png', // Placeholder, using icons for now
      icon: Icons.event_available_rounded,
    ),
    OnboardingItem(
      title: 'Tus Entradas Seguras',
      description:
          'Gestiona tus tickets de forma digital y segura. Olvídate del papel.',
      image: 'assets/images/onboarding_2.png',
      icon: Icons.vignette_rounded,
    ),
    OnboardingItem(
      title: 'Únete a la Comunidad',
      description:
          'Conéctate con otros asistentes y vive la experiencia Duty al máximo.',
      image: 'assets/images/onboarding_3.png',
      icon: Icons.people_alt_rounded,
    ),
  ];

  Future<void> _completeAndContinue() async {
    await ref.read(onboardingControllerProvider).completeOnboarding();
    if (!mounted) return;

    final token = await ref.read(authTokenProvider.future);
    if (!mounted) return;

    final isLoggedIn = token != null;
    final keepSignedIn = ref.read(keepSignedInProvider);
    final faceIdEnabled = ref.read(faceIdEnabledProvider);
    final landingRoute = ref.read(activeProfileLandingRouteProvider);

    if (isLoggedIn && keepSignedIn) {
      context.go(faceIdEnabled ? '/auth-lock' : landingRoute);
      return;
    }

    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.dutyTheme;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              palette.heroGradientStart,
              palette.backgroundAlt,
              palette.background,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _items.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(40),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: palette.surface.withValues(alpha: 0.68),
                              border: Border.all(color: palette.borderStrong),
                            ),
                            child: Icon(
                              item.icon,
                              size: 100,
                              color: palette.primary,
                            ),
                          ),
                          const SizedBox(height: 60),
                          Text(
                            item.title,
                            style: GoogleFonts.outfit(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: palette.textPrimary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            item.description,
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              color: palette.textSecondary,
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(40.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _items.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          height: 8,
                          width: _currentPage == index ? 24 : 8,
                          decoration: BoxDecoration(
                            color: _currentPage == index
                                ? palette.primary
                                : palette.textMuted.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_currentPage == _items.length - 1) {
                            await _completeAndContinue();
                          } else {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: palette.primary,
                          foregroundColor: palette.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          _currentPage == _items.length - 1
                              ? 'Comenzar'
                              : 'Siguiente',
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (_currentPage < _items.length - 1)
                      TextButton(
                        onPressed: () async {
                          await _completeAndContinue();
                        },
                        child: Text(
                          'Saltar',
                          style: GoogleFonts.outfit(
                            color: palette.textSecondary,
                            fontSize: 16,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OnboardingItem {
  final String title;
  final String description;
  final String image;
  final IconData icon;

  OnboardingItem({
    required this.title,
    required this.description,
    required this.image,
    required this.icon,
  });
}
