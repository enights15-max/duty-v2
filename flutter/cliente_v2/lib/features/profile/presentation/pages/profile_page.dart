import 'package:cached_network_image/cached_network_image.dart';
import 'package:duty_client/core/constants/app_urls.dart';
import 'package:duty_client/core/providers/profile_state_provider.dart';
import 'package:duty_client/core/theme/colors.dart';
import 'package:duty_client/features/auth/presentation/providers/auth_provider.dart';
import 'package:duty_client/features/profile/domain/models/profile_model.dart';
import 'package:duty_client/features/profile/presentation/widgets/profile_switcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.dutyTheme;
    final activeProfile = ref.watch(activeProfileProvider);
    final user = ref.watch(currentUserProvider);

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final avatarUrl = activeProfile?.avatarUrl ?? user['photo'];
    String? fullAvatarUrl;
    if (avatarUrl != null) {
      if (avatarUrl.startsWith('http')) {
        fullAvatarUrl = avatarUrl;
      } else {
        fullAvatarUrl = '${AppConstants.profileImageBaseUrl}$avatarUrl';
      }
    }

    return Scaffold(
      backgroundColor: palette.background,
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [palette.heroGradientStart, palette.background],
                ),
              ),
            ),
          ),
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverAppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  pinned: true,
                  title: Text(
                    'Mi Perfil',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      color: palette.textPrimary,
                    ),
                  ),
                  actions: [
                    IconButton(
                      icon: Icon(
                        Icons.settings_outlined,
                        color: palette.textPrimary,
                      ),
                      onPressed: () => context.push('/settings'),
                    ),
                  ],
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        _buildProfileAvatar(context, fullAvatarUrl),
                        const SizedBox(height: 16),
                        Text(
                          activeProfile?.name ??
                              '${user['fname'] ?? ''} ${user['lname'] ?? ''}',
                          style: GoogleFonts.outfit(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: palette.textPrimary,
                          ),
                        ),
                        if (activeProfile != null)
                          Container(
                            margin: const EdgeInsets.only(top: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: palette.primarySurface,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: palette.borderStrong),
                            ),
                            child: Text(
                              activeProfile.type.name.toUpperCase(),
                              style: GoogleFonts.outfit(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: palette.primary,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 24.0),
                    child: ProfileSwitcher(),
                  ),
                ),
                SliverList(
                  delegate: SliverChildListDelegate([
                    _buildMenuItem(
                      context,
                      icon: Icons.confirmation_number_outlined,
                      title: 'Mis Entradas',
                      onTap: () => context.push('/my-tickets'),
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.person_outline,
                      title: 'Datos Personales',
                      onTap: () => context.push('/settings/edit-profile'),
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.tune_rounded,
                      title: 'Configuración',
                      subtitle: 'Tema, privacidad, idioma y seguridad',
                      onTap: () => context.push('/settings'),
                      highlight: true,
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.lock_outline,
                      title: 'Seguridad',
                      onTap: () => context.push('/settings'),
                    ),
                    if (activeProfile?.type == ProfileType.organizer ||
                        activeProfile?.type == ProfileType.venue)
                      _buildMenuItem(
                        context,
                        icon: Icons.dashboard_customize_outlined,
                        title: 'Panel Administrativo',
                        subtitle: 'Gestiona tus eventos y ventas',
                        onTap: () => context.push('/dashboard'),
                        highlight: true,
                      ),
                    const SizedBox(height: 24),
                    _buildMenuItem(
                      context,
                      icon: Icons.logout,
                      title: isLoggingOut
                          ? 'Cerrando Sesión...'
                          : 'Cerrar Sesión',
                      onTap: isLoggingOut
                          ? () {}
                          : () async {
                              await ref
                                  .read(authControllerProvider.notifier)
                                  .logout();
                              if (context.mounted) {
                                context.go('/login');
                              }
                            },
                      textColor: palette.danger,
                    ),
                    const SizedBox(height: 100),
                  ]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileAvatar(BuildContext context, String? url) {
    final palette = context.dutyTheme;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [palette.primary, palette.primaryDeep],
        ),
        boxShadow: [
          BoxShadow(
            color: palette.primaryGlow.withValues(alpha: 0.28),
            blurRadius: 20,
            spreadRadius: 3,
          ),
        ],
      ),
      child: CircleAvatar(
        radius: 50,
        backgroundColor: palette.surface,
        backgroundImage: url != null ? CachedNetworkImageProvider(url) : null,
        child: url == null
            ? Icon(Icons.person, size: 50, color: palette.textMuted)
            : null,
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    Color? textColor,
    bool highlight = false,
  }) {
    final palette = context.dutyTheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: highlight ? palette.primarySurface : palette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: highlight ? palette.borderStrong : palette.border,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: textColor ?? palette.textSecondary),
        title: Text(
          title,
          style: GoogleFonts.inter(
            color: textColor ?? palette.textPrimary,
            fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: GoogleFonts.inter(
                  color: palette.textMuted,
                  fontSize: 12,
                ),
              )
            : null,
        trailing: Icon(Icons.chevron_right, color: palette.textMuted, size: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
