import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/profile/domain/models/profile_model.dart';
import '../../features/profile/presentation/providers/profile_provider.dart';
import '../providers/profile_state_provider.dart';
import '../theme/colors.dart';

Color _profileAccent(ProfileType type) {
  switch (type) {
    case ProfileType.organizer:
      return kPrimaryColor;
    case ProfileType.venue:
      return kInfoColor;
    case ProfileType.artist:
      return kDustRose;
    case ProfileType.personal:
      return kSuccessColor;
  }
}

IconData _profileIcon(ProfileType type) {
  switch (type) {
    case ProfileType.organizer:
      return Icons.domain_rounded;
    case ProfileType.venue:
      return Icons.location_city_rounded;
    case ProfileType.artist:
      return Icons.headphones_rounded;
    case ProfileType.personal:
      return Icons.person_rounded;
  }
}

String _profileLabel(ProfileType type) {
  switch (type) {
    case ProfileType.organizer:
      return 'Organizador';
    case ProfileType.venue:
      return 'Venue';
    case ProfileType.artist:
      return 'Artista';
    case ProfileType.personal:
      return 'Personal';
  }
}

String _statusLabel(String status) {
  switch (status.toLowerCase()) {
    case 'active':
      return 'Activo';
    case 'pending':
      return 'Pendiente';
    case 'rejected':
      return 'Rechazado';
    case 'suspended':
      return 'Suspendido';
    default:
      return status;
  }
}

// ─── Main Sheet ─────────────────────────────────────────────────────────────────

class AccountSwitcherSheet extends ConsumerWidget {
  const AccountSwitcherSheet({super.key});

  static Future<void> show(BuildContext context) {
    HapticFeedback.heavyImpact();
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (_) => const AccountSwitcherSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.dutyTheme;
    final profiles = ref.watch(userProfilesProvider);
    final activeId = ref.watch(activeProfileIdProvider);
    final currentUser = ref.watch(currentUserProvider);
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Container(
      margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      decoration: BoxDecoration(
        color: palette.backgroundAlt,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: palette.textMuted.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // ── Title
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
            child: Text(
              'Cuentas',
              style: GoogleFonts.splineSans(
                color: palette.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          // ── Profile list
          ...profiles.map((profile) {
            final isActive = profile.id == activeId;
            final canSelect = profile.isActive;
            return _ProfileTile(
              profile: profile,
              avatarUrl: profile.resolveAvatarUrl(currentUser),
              isSelected: isActive,
              canSelect: canSelect,
              onTap: () async {
                if (!canSelect || isActive) return;
                HapticFeedback.selectionClick();
                try {
                  await ref
                      .read(profileControllerProvider)
                      .switchProfile(profile.id);
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    if (profile.type == ProfileType.personal) {
                      context.go('/home');
                    } else {
                      context.go('/dashboard');
                    }
                  }
                } catch (_) {
                  if (context.mounted) Navigator.of(context).pop();
                }
              },
            );
          }),

          // ── Divider
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            height: 1,
            color: palette.border,
          ),

          // ── Add professional profile action
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                HapticFeedback.selectionClick();
                Navigator.of(context).pop();
                context.push('/identity-request');
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: palette.primary.withValues(alpha: 0.4),
                          width: 1.5,
                          strokeAlign: BorderSide.strokeAlignInside,
                        ),
                      ),
                      child: Icon(
                        Icons.add_rounded,
                        color: palette.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        'Solicitar perfil profesional',
                        style: GoogleFonts.splineSans(
                          color: palette.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: palette.primary.withValues(alpha: 0.5),
                      size: 14,
                    ),
                  ],
                ),
              ),
            ),
          ),

          SizedBox(height: bottomPad + 8),
        ],
      ),
    );
  }
}

// ─── Profile Tile ───────────────────────────────────────────────────────────────

class _ProfileTile extends StatelessWidget {
  final AppProfile profile;
  final String? avatarUrl;
  final bool isSelected;
  final bool canSelect;
  final VoidCallback onTap;

  const _ProfileTile({
    required this.profile,
    required this.avatarUrl,
    required this.isSelected,
    required this.canSelect,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final palette = context.dutyTheme;
    final accent = _profileAccent(profile.type);
    final dimmed = !canSelect;

    return Opacity(
      opacity: dimmed ? 0.5 : 1.0,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: canSelect ? onTap : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? palette.surfaceAlt : Colors.transparent,
              border: isSelected ? Border.all(color: palette.border) : null,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                // ── Avatar
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        accent.withValues(alpha: 0.3),
                        accent.withValues(alpha: 0.12),
                      ],
                    ),
                    border: Border.all(
                      color: isSelected
                          ? accent
                          : accent.withValues(alpha: 0.3),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: avatarUrl != null
                      ? ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: avatarUrl!,
                            fit: BoxFit.cover,
                            errorWidget: (_, _, _) => Icon(
                              _profileIcon(profile.type),
                              color: accent,
                              size: 20,
                            ),
                          ),
                        )
                      : Icon(
                          _profileIcon(profile.type),
                          color: accent,
                          size: 20,
                        ),
                ),
                const SizedBox(width: 14),

                // ── Name + subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.name,
                        style: GoogleFonts.splineSans(
                          color: palette.textPrimary,
                          fontSize: 14,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            _profileLabel(profile.type),
                            style: GoogleFonts.splineSans(
                              color: accent,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (!profile.isActive) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: profile.isRejected
                                    ? palette.danger.withValues(alpha: 0.15)
                                    : palette.warning.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                _statusLabel(profile.status),
                                style: GoogleFonts.splineSans(
                                  color: profile.isRejected
                                      ? palette.danger
                                      : palette.warning,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // ── Active checkmark
                if (isSelected)
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: palette.primary,
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      color: palette.onPrimary,
                      size: 14,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
