import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:duty_client/core/providers/profile_state_provider.dart';
import 'package:duty_client/core/theme/colors.dart';
import 'package:duty_client/features/profile/presentation/providers/profile_provider.dart';
import 'package:duty_client/features/profile/domain/models/profile_model.dart';
import 'package:duty_client/features/auth/presentation/providers/auth_provider.dart';

class ProfileSwitcher extends ConsumerWidget {
  const ProfileSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.dutyTheme;
    final profiles = ref.watch(userProfilesProvider);
    final activeProfile = ref.watch(activeProfileProvider);
    final currentUser = ref.watch(currentUserProvider);

    if (profiles.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            'Mis Identidades',
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: palette.textSecondary,
            ),
          ),
        ),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: profiles.length + 1,
            itemBuilder: (context, index) {
              if (index == profiles.length) {
                return _buildAddProfileButton(context);
              }

              final profile = profiles[index];
              final isSelected = activeProfile?.id == profile.id;

              return _buildProfileCard(
                context,
                ref,
                profile,
                isSelected,
                profile.resolveAvatarUrl(currentUser),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProfileCard(
    BuildContext context,
    WidgetRef ref,
    AppProfile profile,
    bool isSelected,
    String? avatarUrl,
  ) {
    final palette = context.dutyTheme;
    final statusColor = _statusColor(context, profile);
    final canSwitch = profile.isActive;

    return GestureDetector(
      onTap: () =>
          ref.read(profileControllerProvider).switchProfile(profile.id),
      child: Container(
        width: 80,
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? palette.primary
              : canSwitch
              ? palette.surface
              : palette.surfaceAlt,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? palette.onPrimary
                : canSwitch
                ? palette.border
                : statusColor.withValues(alpha: 0.55),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: palette.primary.withValues(alpha: 0.28),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: palette.surfaceMuted,
              backgroundImage: avatarUrl != null
                  ? CachedNetworkImageProvider(avatarUrl)
                  : null,
              child: avatarUrl == null
                  ? Icon(
                      _getIconForType(profile.type),
                      size: 20,
                      color: isSelected ? palette.onPrimary : palette.textMuted,
                    )
                  : null,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                profile.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? palette.onPrimary : palette.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddProfileButton(BuildContext context) {
    final palette = context.dutyTheme;
    return GestureDetector(
      onTap: () {
        context.push('/identity-request');
      },
      child: Container(
        width: 80,
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: palette.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: palette.textSecondary),
            const SizedBox(height: 4),
            Text(
              'Añadir',
              style: TextStyle(fontSize: 10, color: palette.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForType(ProfileType type) {
    switch (type) {
      case ProfileType.personal:
        return Icons.person;
      case ProfileType.artist:
        return Icons.mic_external_on;
      case ProfileType.venue:
        return Icons.location_on;
      case ProfileType.organizer:
        return Icons.event;
    }
  }

  String _statusLabel(AppProfile profile) {
    if (profile.isPending && profile.wasResubmitted) {
      return 'Reenviado';
    }

    switch (profile.status.toLowerCase()) {
      case 'active':
        return 'Activo';
      case 'pending':
        return 'Pendiente';
      case 'rejected':
        return 'Rechazado';
      case 'suspended':
        return 'Suspendido';
      default:
        return profile.status;
    }
  }

  Color _statusColor(BuildContext context, AppProfile profile) {
    final palette = context.dutyTheme;
    if (profile.isPending && profile.wasResubmitted) {
      return palette.info;
    }

    switch (profile.status.toLowerCase()) {
      case 'active':
        return palette.success;
      case 'pending':
        return palette.warning;
      case 'rejected':
        return palette.danger;
      case 'suspended':
        return palette.warning;
      default:
        return palette.textSecondary;
    }
  }
}
