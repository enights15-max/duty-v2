import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_auth/local_auth.dart';
import '../../../../core/constants/app_urls.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/theme_mode_provider.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  DutyThemeTokens get _palette => context.dutyTheme;
  bool _faceIdEnabled = false;
  late final LocalAuthentication auth;

  @override
  void initState() {
    super.initState();
    auth = LocalAuthentication();
    _loadFaceIdStatus();
  }

  Future<void> _loadFaceIdStatus() async {
    final prefs = ref.read(sharedPreferencesProvider);
    setState(() {
      _faceIdEnabled = prefs.getBool(AppConstants.faceIdKey) ?? false;
    });
  }

  Future<void> _toggleFaceId(bool value) async {
    if (value) {
      // Trying to enable
      try {
        final bool canAuthenticateWithBiometrics =
            await auth.canCheckBiometrics;
        final bool canAuthenticate =
            canAuthenticateWithBiometrics || await auth.isDeviceSupported();

        if (!canAuthenticate) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Biometric authentication is not supported on this device',
              ),
            ),
          );
          return;
        }

        final bool didAuthenticate = await auth.authenticate(
          localizedReason: 'Please authenticate to enable Face ID for login',
          biometricOnly: true,
        );

        if (didAuthenticate) {
          final prefs = ref.read(sharedPreferencesProvider);
          await prefs.setBool(AppConstants.faceIdKey, true);
          setState(() {
            _faceIdEnabled = true;
          });
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error setting up Face ID: $e')));
      }
    } else {
      // Disable
      final prefs = ref.read(sharedPreferencesProvider);
      await prefs.setBool(AppConstants.faceIdKey, false);
      setState(() {
        _faceIdEnabled = false;
      });
    }
  }

  Future<void> _showThemeModeSheet() async {
    final palette = _palette;
    final controller = ref.read(appThemeModeProvider.notifier);
    final currentMode = ref.read(appThemeModeProvider);

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: palette.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        final sheetPalette = sheetContext.dutyTheme;

        Widget option(ThemeMode mode, String title, String subtitle) {
          final isSelected = currentMode == mode;
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? sheetPalette.primarySurface
                  : sheetPalette.surfaceAlt,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isSelected
                    ? sheetPalette.borderStrong
                    : sheetPalette.border,
              ),
            ),
            child: ListTile(
              onTap: () async {
                Navigator.of(sheetContext).pop();
                await controller.setThemeMode(mode);
              },
              leading: Icon(
                switch (mode) {
                  ThemeMode.system => Icons.brightness_auto_rounded,
                  ThemeMode.light => Icons.light_mode_rounded,
                  ThemeMode.dark => Icons.dark_mode_rounded,
                },
                color: isSelected
                    ? sheetPalette.primary
                    : sheetPalette.textSecondary,
              ),
              title: Text(
                title,
                style: GoogleFonts.splineSans(
                  color: sheetPalette.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              subtitle: Text(
                subtitle,
                style: GoogleFonts.splineSans(
                  color: sheetPalette.textSecondary,
                  fontSize: 12,
                ),
              ),
              trailing: isSelected
                  ? Icon(
                      Icons.check_circle_rounded,
                      color: sheetPalette.primary,
                    )
                  : Icon(
                      Icons.chevron_right_rounded,
                      color: sheetPalette.textMuted,
                    ),
            ),
          );
        }

        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Scarlet Editorial theme',
                  style: GoogleFonts.outfit(
                    color: sheetPalette.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose how Duty should feel across the app. You can keep it automatic or force a clean light or dark look.',
                  style: GoogleFonts.splineSans(
                    color: sheetPalette.textSecondary,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 18),
                option(
                  ThemeMode.system,
                  'System',
                  'Follow the device appearance automatically.',
                ),
                option(
                  ThemeMode.light,
                  'Light',
                  'Warm white surfaces with scarlet accents.',
                ),
                option(
                  ThemeMode.dark,
                  'Dark',
                  'Noir backgrounds with scarlet highlights.',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = _palette;
    final isLoggingOut = ref.watch(authControllerProvider).isLoading;
    final transferInboxCount = ref.watch(pendingTransfersCountProvider);
    final themeMode = ref.watch(appThemeModeProvider);

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        backgroundColor: palette.background.withValues(alpha: 0.92),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: palette.primary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Settings',
          style: GoogleFonts.splineSans(
            color: palette.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Account Section
          _buildSectionHeader('ACCOUNT & PROFILE'),
          const SizedBox(height: 12),
          _buildAccountCard(),

          const SizedBox(height: 32),

          // Security Section
          _buildSectionHeader('SECURITY'),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: palette.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: palette.border),
            ),
            child: Column(
              children: [
                _buildSettingsTile(
                  icon: Icons.face_rounded,
                  title: 'Face ID',
                  trailing: Switch(
                    value: _faceIdEnabled,
                    activeTrackColor: palette.primary.withValues(alpha: 0.45),
                    activeThumbColor: palette.primary,
                    onChanged: _toggleFaceId,
                  ),
                ),
                _buildDivider(),
                _buildSettingsTile(
                  icon: Icons.lock_rounded,
                  title: 'Change Passcode',
                  trailing: Icon(
                    Icons.chevron_right_rounded,
                    color: palette.textMuted,
                  ),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Feature Coming Soon')),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Payment Methods
          _buildSectionHeader('PAYMENT METHODS'),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: palette.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: palette.border),
            ),
            child: Column(
              children: [
                _buildSettingsTile(
                  icon: Icons.credit_card_rounded,
                  title: 'Stored Cards',
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '•••• 4412',
                        style: GoogleFonts.splineSans(
                          color: palette.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: palette.textMuted,
                      ),
                    ],
                  ),
                  onTap: () => context.push('/settings/stored-cards'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Notifications
          _buildSectionHeader('NOTIFICATIONS'),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: palette.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: palette.border),
            ),
            child: Column(
              children: [
                _buildSettingsTile(
                  icon: Icons.notifications_rounded,
                  title: 'Push Notifications',
                  trailing: Text(
                    'On',
                    style: GoogleFonts.splineSans(
                      color: palette.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () => context.push('/settings/notifications'),
                ),
                _buildDivider(),
                _buildSettingsTile(
                  icon: Icons.swap_horizontal_circle_rounded,
                  title: 'Transfer Inbox',
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (transferInboxCount > 0) ...[
                        _buildCountBadge(transferInboxCount),
                        const SizedBox(width: 10),
                      ],
                      Icon(
                        Icons.chevron_right_rounded,
                        color: palette.textMuted,
                      ),
                    ],
                  ),
                  onTap: () => context.push('/pending-transfers'),
                ),
                _buildDivider(),
                _buildSettingsTile(
                  icon: Icons.outbox_rounded,
                  title: 'Transfer Outbox',
                  trailing: Icon(
                    Icons.chevron_right_rounded,
                    color: palette.textMuted,
                  ),
                  onTap: () => context.push('/transfer-outbox'),
                ),
                _buildDivider(),
                _buildSettingsTile(
                  icon: Icons.mail_rounded,
                  title: 'Email Subscriptions',
                  trailing: Icon(
                    Icons.chevron_right_rounded,
                    color: palette.textMuted,
                  ),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Feature Coming Soon')),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Preferences
          _buildSectionHeader('PREFERENCES'),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: palette.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: palette.border),
            ),
            child: Column(
              children: [
                _buildSettingsTile(
                  icon: Icons.shield_moon_rounded,
                  title: 'Social Privacy',
                  trailing: Icon(
                    Icons.chevron_right_rounded,
                    color: palette.textMuted,
                  ),
                  onTap: () => context.push('/settings/privacy'),
                ),
                _buildDivider(),
                _buildSettingsTile(
                  icon: Icons.language_rounded,
                  title: 'Language',
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'English',
                        style: GoogleFonts.splineSans(
                          color: palette.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: palette.textMuted,
                      ),
                    ],
                  ),
                  onTap: () => context.push('/settings/language'),
                ),
                _buildDivider(),
                _buildSettingsTile(
                  icon: Icons.dark_mode_rounded,
                  title: 'App Theme',
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        switch (themeMode) {
                          ThemeMode.light => 'Light',
                          ThemeMode.dark => 'Dark',
                          ThemeMode.system => 'System',
                        },
                        style: GoogleFonts.splineSans(
                          color: palette.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: palette.textMuted,
                      ),
                    ],
                  ),
                  onTap: _showThemeModeSheet,
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Legal
          _buildSectionHeader('LEGAL'),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: palette.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: palette.border),
            ),
            child: Column(
              children: [
                _buildSettingsTile(
                  icon: Icons.description_rounded,
                  title: 'Terms of Service',
                  trailing: Icon(
                    Icons.open_in_new_rounded,
                    color: palette.textMuted,
                  ),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Feature Coming Soon')),
                    );
                  },
                ),
                _buildDivider(),
                _buildSettingsTile(
                  icon: Icons.policy_rounded,
                  title: 'Privacy Policy',
                  trailing: Icon(
                    Icons.open_in_new_rounded,
                    color: palette.textMuted,
                  ),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Feature Coming Soon')),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          Center(
            child: Text(
              'DUTY APP VERSION 4.12.0 (GOLD)',
              style: GoogleFonts.splineSans(
                color: palette.textMuted,
                fontSize: 10,
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Log Out
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.withValues(alpha: 0.1),
                foregroundColor: Colors.red,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.red.withValues(alpha: 0.2)),
                ),
              ),
              onPressed: () async {
                await ref.read(authControllerProvider.notifier).logout();
                // context.go('/login'); // handled by router rebuild usually, but safe to add if needed
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.logout_rounded),
                  const SizedBox(width: 8),
                  Text(
                    'Log Out',
                    style: GoogleFonts.splineSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    final palette = _palette;
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Text(
        title,
        style: GoogleFonts.splineSans(
          color: palette.primary.withValues(alpha: 0.72),
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildCountBadge(int count) {
    final palette = _palette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: palette.primarySurface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: palette.borderStrong),
      ),
      child: Text(
        count > 99 ? '99+' : '$count',
        style: GoogleFonts.splineSans(
          color: palette.primary,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildAccountCard() {
    final palette = _palette;
    final user = ref.watch(currentUserProvider);
    final isEmailVerified = user?['email_verified_at'] != null;
    final isPhoneVerified = user?['phone_verified_at'] != null;
    int count = 0;
    if (isEmailVerified) count++;
    if (isPhoneVerified) count++;
    final statusText = count == 2
        ? '2/2 Verified'
        : (count == 1 ? '1/2 Verified' : '0/2 Unverified');
    final statusColor = count == 2
        ? palette.success
        : (count == 1 ? palette.warning : palette.danger);
    final name = user?['fname'] != null
        ? '${user!['fname']} ${user['lname'] ?? ''}'
        : (user?['name'] ?? 'Guest User');
    final id = user?['id'] ?? 'N/A';
    final avatarUrl =
        AppUrls.getCustomerAvatarUrl(user) ?? 'https://via.placeholder.com/150';

    return Container(
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: palette.border),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => context.push('/settings/edit-profile'),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: palette.borderStrong),
                    ),
                    child: ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: avatarUrl,
                        fit: BoxFit.cover,
                        width: 48,
                        height: 48,
                        placeholder: (context, url) => Container(
                          color: palette.surfaceAlt,
                          child: Icon(
                            Icons.person,
                            size: 30,
                            color: palette.textMuted,
                          ),
                        ),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.person, size: 30),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.splineSans(
                            color: palette.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Member • ID: $id',
                          style: GoogleFonts.splineSans(
                            color: palette.textMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: palette.textMuted),
                ],
              ),
            ),
          ),
          _buildDivider(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: palette.primarySurface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.verified_user_rounded,
                    color: palette.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Verification Status',
                    style: GoogleFonts.splineSans(
                      color: palette.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Text(
                  statusText,
                  style: GoogleFonts.splineSans(
                    color: statusColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          _buildDivider(),
          _buildSettingsTile(
            icon: Icons.shield_rounded,
            title: 'Account Verification',
            trailing: Icon(
              Icons.chevron_right_rounded,
              color: palette.textMuted,
            ),
            onTap: () => context.push('/settings/verification'),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    final palette = _palette;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: palette.primarySurface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: palette.primary, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.splineSans(
                  color: palette.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, color: _palette.border);
  }
}
