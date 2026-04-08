import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/colors.dart';
import '../providers/auth_provider.dart';

class UserTypeSelectionPage extends ConsumerWidget {
  const UserTypeSelectionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                Text(
                  'Elige tu perfil',
                  style: GoogleFonts.outfit(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: palette.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Personaliza tu experiencia en Duty según lo que busques.',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    color: palette.textSecondary,
                  ),
                ),
                const SizedBox(height: 48),
                _UserTypeCard(
                  title: 'Usuario / Consumidor',
                  description:
                      'Busco los mejores eventos, compro tickets y disfruto de experiencias VIP.',
                  icon: Icons.person_rounded,
                  onTap: () async {
                    await ref
                        .read(userTypeControllerProvider)
                        .setUserType('consumer');
                    if (context.mounted) {
                      context.go('/login');
                    }
                  },
                ),
                const SizedBox(height: 20),
                _UserTypeCard(
                  title: 'Profesional',
                  description:
                      'Soy artista, organizador o dueño de un venue. Quiero gestionar eventos y ventas.',
                  icon: Icons.business_center_rounded,
                  isProfessional: true,
                  onTap: () async {
                    await ref
                        .read(userTypeControllerProvider)
                        .setUserType('professional');
                    if (context.mounted) {
                      context.go('/login');
                    }
                  },
                ),
                const Spacer(),
                Center(
                  child: TextButton(
                    onPressed: () => context.go('/login'),
                    child: Text(
                      'Decidir luego',
                      style: GoogleFonts.outfit(color: palette.textMuted),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _UserTypeCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;
  final bool isProfessional;

  const _UserTypeCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
    this.isProfessional = false,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.dutyTheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: palette.border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: (isProfessional ? palette.info : palette.primary)
                    .withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                size: 32,
                color: isProfessional ? palette.info : palette.primary,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: palette.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: palette.textSecondary,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: palette.textMuted),
          ],
        ),
      ),
    );
  }
}
