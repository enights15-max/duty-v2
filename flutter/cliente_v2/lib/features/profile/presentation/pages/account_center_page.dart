import 'package:duty_client/core/providers/profile_state_provider.dart';
import 'package:duty_client/core/theme/colors.dart';
import 'package:duty_client/features/profile/domain/models/profile_model.dart';
import 'package:duty_client/features/profile/presentation/providers/profile_provider.dart';
import 'package:duty_client/features/auth/presentation/providers/auth_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class AccountCenterPage extends ConsumerStatefulWidget {
  const AccountCenterPage({super.key});

  @override
  ConsumerState<AccountCenterPage> createState() => _AccountCenterPageState();
}

class _AccountCenterPageState extends ConsumerState<AccountCenterPage> {
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshIdentities();
    });
  }

  Future<void> _refreshIdentities() async {
    if (mounted) {
      setState(() => _isRefreshing = true);
    }

    try {
      await ref.read(profileControllerProvider).refreshIdentities();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudieron sincronizar las identidades.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isRefreshing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.dutyTheme;
    final profiles = ref.watch(userProfilesProvider);
    final activeProfile = ref.watch(activeProfileProvider);
    final currentUser = ref.watch(currentUserProvider);
    final missingTypes = _missingProfessionalTypes(profiles);

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Centro de cuentas',
          style: GoogleFonts.splineSans(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            tooltip: 'Sincronizar',
            onPressed: _isRefreshing ? null : _refreshIdentities,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshIdentities,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          children: [
            _buildActiveProfileCard(activeProfile),
            const SizedBox(height: 16),
            if (_isRefreshing)
              const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: LinearProgressIndicator(minHeight: 2),
              ),
            Text(
              'Perfiles vinculados',
              style: GoogleFonts.splineSans(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: palette.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Gestiona tu cuenta personal y tus perfiles profesionales desde un solo lugar.',
              style: GoogleFonts.splineSans(
                fontSize: 13,
                color: palette.textSecondary,
              ),
            ),
            const SizedBox(height: 14),
            if (profiles.isEmpty)
              _buildEmptyProfilesCard()
            else
              ...profiles.map(
                (profile) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildProfileCard(profile, activeProfile, currentUser),
                ),
              ),
            const SizedBox(height: 8),
            _buildCreateProfileCard(missingTypes),
            if (_canCreateProfessionalEvent(activeProfile)) ...[
              const SizedBox(height: 12),
              _buildProfessionalToolsCard(activeProfile!),
            ],
            const SizedBox(height: 12),
            _buildPolicyCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveProfileCard(AppProfile? activeProfile) {
    final palette = context.dutyTheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: kSurfaceColor.withValues(alpha: 0.55),
        border: Border.all(color: palette.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: kPrimaryColor.withValues(alpha: 0.2),
            ),
            child: const Icon(
              Icons.verified_user_rounded,
              color: kPrimaryColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Perfil activo',
                  style: GoogleFonts.splineSans(
                    color: palette.textMuted,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  activeProfile != null
                      ? '${activeProfile.name} (${_typeLabel(activeProfile.type)})'
                      : 'Sin perfil activo',
                  style: GoogleFonts.splineSans(
                    color: palette.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyProfilesCard() {
    final palette = context.dutyTheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: palette.surface.withValues(alpha: 0.68),
        border: Border.all(color: palette.border),
      ),
      child: Text(
        'No se encontraron identidades vinculadas en este momento.',
        style: GoogleFonts.splineSans(color: palette.textMuted),
      ),
    );
  }

  Widget _buildProfileCard(
    AppProfile profile,
    AppProfile? activeProfile,
    Map<String, dynamic>? currentUser,
  ) {
    final palette = context.dutyTheme;
    final statusColor = _statusColor(profile);
    final isSelected = activeProfile?.id == profile.id;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: palette.surface.withValues(alpha: 0.68),
        border: Border.all(
          color: isSelected
              ? kPrimaryColor.withValues(alpha: 0.85)
              : statusColor.withValues(alpha: 0.35),
        ),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileAvatar(profile, currentUser),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.name,
                      style: GoogleFonts.splineSans(
                        color: palette.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _typeLabel(profile.type),
                      style: GoogleFonts.splineSans(
                        color: palette.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: statusColor.withValues(alpha: 0.2),
                ),
                child: Text(
                  _statusLabel(profile),
                  style: GoogleFonts.splineSans(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          if (profile.revisionReason != null || profile.isRejected) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: palette.surface.withValues(alpha: 0.84),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                profile.revisionReason ??
                    profile.metadata['rejection_reason']?.toString() ??
                    'Este perfil requiere una nueva revisión administrativa.',
                style: GoogleFonts.splineSans(
                  color: palette.textMuted,
                  fontSize: 12,
                ),
              ),
            ),
          ],
          const SizedBox(height: 10),
          _buildProfileActions(profile, activeProfile),
        ],
      ),
    );
  }

  Widget _buildProfileAvatar(
    AppProfile profile,
    Map<String, dynamic>? currentUser,
  ) {
    final avatarUrl = profile.resolveAvatarUrl(currentUser);

    return CircleAvatar(
      radius: 22,
      backgroundColor: kPrimaryColor.withValues(alpha: 0.18),
      backgroundImage: avatarUrl != null
          ? CachedNetworkImageProvider(avatarUrl)
          : null,
      child: avatarUrl == null
          ? Icon(
              _iconForType(profile.type),
              color: context.dutyTheme.textPrimary,
            )
          : null,
    );
  }

  Widget _buildProfileActions(AppProfile profile, AppProfile? activeProfile) {
    final palette = context.dutyTheme;
    final isSelected = activeProfile?.id == profile.id;

    if (profile.isActive) {
      if (isSelected) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInfoTag(
              icon: Icons.check_circle_outline,
              text: 'Este es tu perfil activo para operaciones en la app.',
              color: palette.success,
            ),
            if (profile.isProfessional) ...[
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () {
                  context.push(
                    '/identity-request',
                    extra: {'profile': profile},
                  );
                },
                icon: const Icon(Icons.edit_note_rounded),
                label: const Text('Editar perfil'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: palette.textPrimary,
                  side: BorderSide(
                    color: kPrimaryColor.withValues(alpha: 0.55),
                  ),
                ),
              ),
            ],
          ],
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () async {
                try {
                  await ref
                      .read(profileControllerProvider)
                      .switchProfile(profile.id);
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Ahora estás usando el perfil ${profile.name}.',
                      ),
                      backgroundColor: palette.success,
                    ),
                  );
                } catch (error) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(error.toString()),
                      backgroundColor: palette.danger,
                    ),
                  );
                }
              },
              icon: const Icon(Icons.swap_horiz_rounded),
              label: const Text('Usar este perfil'),
              style: FilledButton.styleFrom(
                backgroundColor: palette.primary,
                foregroundColor: palette.onPrimary,
              ),
            ),
          ),
          if (profile.isProfessional) ...[
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () {
                context.push('/identity-request', extra: {'profile': profile});
              },
              icon: const Icon(Icons.edit_note_rounded),
              label: const Text('Editar perfil'),
              style: OutlinedButton.styleFrom(
                foregroundColor: palette.textPrimary,
                side: BorderSide(color: kPrimaryColor.withValues(alpha: 0.55)),
              ),
            ),
          ],
        ],
      );
    }

    if (profile.hasRevisionRequest) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () {
            context.push('/identity-request', extra: {'profile': profile});
          },
          icon: const Icon(Icons.edit_note_rounded),
          label: const Text('Completar información'),
          style: OutlinedButton.styleFrom(
            foregroundColor: palette.warning,
            side: BorderSide(color: palette.warning),
          ),
        ),
      );
    }

    if (profile.isRejected) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () {
            context.push(
              '/identity-request',
              extra: {'type': profile.type.name, 'prefill_profile': profile},
            );
          },
          icon: const Icon(Icons.replay_rounded),
          label: const Text('Reenviar solicitud'),
          style: OutlinedButton.styleFrom(
            foregroundColor: palette.info,
            side: BorderSide(color: palette.info),
          ),
        ),
      );
    }

    if (profile.isPending && profile.isProfessional) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () {
            context.push('/identity-request', extra: {'profile': profile});
          },
          icon: const Icon(Icons.edit_note_rounded),
          label: const Text('Editar solicitud'),
          style: OutlinedButton.styleFrom(
            foregroundColor: palette.textPrimary,
            side: BorderSide(color: palette.warning.withValues(alpha: 0.8)),
          ),
        ),
      );
    }

    if (profile.isSuspended) {
      return _buildInfoTag(
        icon: Icons.block_rounded,
        text: 'Perfil suspendido por administración. No se puede activar.',
        color: palette.danger,
      );
    }

    return _buildInfoTag(
      icon: Icons.hourglass_bottom_rounded,
      text: 'Perfil en revisión. Se activará cuando sea aprobado.',
      color: palette.warning,
    );
  }

  Widget _buildInfoTag({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: color.withValues(alpha: 0.15),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.splineSans(color: color, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateProfileCard(List<ProfileType> missingTypes) {
    final palette = context.dutyTheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: palette.surfaceAlt.withValues(alpha: 0.9),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Crear perfil profesional',
            style: GoogleFonts.splineSans(
              color: palette.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Cada tipo profesional (artista, organizador, venue) se vincula a tu cuenta personal y requiere aprobación.',
            style: GoogleFonts.splineSans(
              color: palette.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          if (missingTypes.isEmpty)
            Text(
              'Ya tienes perfiles creados para todos los tipos profesionales.',
              style: GoogleFonts.splineSans(
                color: palette.textMuted,
                fontSize: 12,
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: missingTypes.map((type) {
                return OutlinedButton.icon(
                  onPressed: () {
                    context.push('/identity-request', extra: type.name);
                  },
                  icon: Icon(_iconForType(type), size: 16),
                  label: Text(_typeLabel(type)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: palette.textPrimary,
                    side: BorderSide(
                      color: kPrimaryColor.withValues(alpha: 0.6),
                    ),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildPolicyCard() {
    final palette = context.dutyTheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: palette.surface.withValues(alpha: 0.8),
        border: Border.all(color: palette.border),
      ),
      child: Text(
        'Regla operativa: solo perfiles profesionales activos pueden usarse para acciones de negocio. '
        'Las solicitudes pendientes, rechazadas o suspendidas permanecen vinculadas a tu cuenta personal.',
        style: GoogleFonts.splineSans(color: palette.textMuted, fontSize: 12),
      ),
    );
  }

  Widget _buildProfessionalToolsCard(AppProfile activeProfile) {
    final palette = context.dutyTheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          colors: [palette.heroGradientStart, palette.background],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: palette.primary.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Herramientas profesionales',
            style: GoogleFonts.splineSans(
              color: palette.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Tu perfil activo ${activeProfile.name} ya puede publicar eventos desde la app.',
            style: GoogleFonts.splineSans(
              color: palette.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => context.push('/professional/events/create'),
                  icon: const Icon(Icons.add_circle_outline_rounded),
                  label: const Text('Crear evento'),
                  style: FilledButton.styleFrom(
                    backgroundColor: palette.primary,
                    foregroundColor: palette.onPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context.push('/professional/events'),
                  icon: const Icon(Icons.dashboard_outlined),
                  label: const Text('Mis eventos'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<ProfileType> _missingProfessionalTypes(List<AppProfile> profiles) {
    const professionalTypes = [
      ProfileType.artist,
      ProfileType.organizer,
      ProfileType.venue,
    ];

    return professionalTypes
        .where((type) => !profiles.any((profile) => profile.type == type))
        .toList();
  }

  bool _canCreateProfessionalEvent(AppProfile? profile) {
    if (profile == null || !profile.isActive) {
      return false;
    }

    return profile.type == ProfileType.organizer ||
        profile.type == ProfileType.venue;
  }

  Color _statusColor(AppProfile profile) {
    final palette = context.dutyTheme;
    if (profile.isPending && profile.wasResubmitted) {
      return palette.info;
    }
    if (profile.isActive) {
      return palette.success;
    }
    if (profile.isRejected) {
      return palette.danger;
    }
    if (profile.isSuspended) {
      return palette.danger;
    }
    return palette.warning;
  }

  String _statusLabel(AppProfile profile) {
    if (profile.isPending && profile.wasResubmitted) {
      return 'Reenviado';
    }
    if (profile.isActive) {
      return 'Activo';
    }
    if (profile.isRejected) {
      return 'Rechazado';
    }
    if (profile.isSuspended) {
      return 'Suspendido';
    }
    return 'Pendiente';
  }

  String _typeLabel(ProfileType type) {
    switch (type) {
      case ProfileType.personal:
        return 'Personal';
      case ProfileType.artist:
        return 'Artista';
      case ProfileType.venue:
        return 'Venue';
      case ProfileType.organizer:
        return 'Organizador';
    }
  }

  IconData _iconForType(ProfileType type) {
    switch (type) {
      case ProfileType.personal:
        return Icons.person_outline_rounded;
      case ProfileType.artist:
        return Icons.mic_external_on_rounded;
      case ProfileType.venue:
        return Icons.location_on_outlined;
      case ProfileType.organizer:
        return Icons.event_outlined;
    }
  }
}
