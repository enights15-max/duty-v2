import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_auth/local_auth.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../profile/presentation/providers/marketplace_provider.dart';
import '../../../../core/constants/app_constants.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  // Theme Constants
  static const Color kPrimaryColor = Color(0xFF8655F6);
  static const Color kBackgroundDark = Color(0xFF0A0712);
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

  @override
  Widget build(BuildContext context) {
    // Forcing Dark Mode for now
    const backgroundColor = kBackgroundDark;
    const textColor = Colors.white;
    final isLoggingOut = ref.watch(authControllerProvider).isLoading;
    final transferInboxCount = ref.watch(pendingTransfersCountProvider);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor.withValues(alpha: 0.8),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: kPrimaryColor,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Settings',
          style: GoogleFonts.splineSans(
            color: textColor,
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
          _buildAccountCard(textColor),

          const SizedBox(height: 32),

          // Security Section
          _buildSectionHeader('SECURITY'),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: kPrimaryColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: kPrimaryColor.withValues(alpha: 0.1)),
            ),
            child: Column(
              children: [
                _buildSettingsTile(
                  icon: Icons.face_rounded,
                  title: 'Face ID',
                  trailing: Switch(
                    value: _faceIdEnabled,
                    activeTrackColor: kPrimaryColor.withValues(alpha: 0.5),
                    activeThumbColor: kPrimaryColor,
                    onChanged: _toggleFaceId,
                  ),
                ),
                _buildDivider(),
                _buildSettingsTile(
                  icon: Icons.lock_rounded,
                  title: 'Change Passcode',
                  trailing: const Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.grey,
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
          _buildSectionHeader('CARDS & BILLING'),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: kPrimaryColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: kPrimaryColor.withValues(alpha: 0.1)),
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
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: Colors.grey,
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
              color: kPrimaryColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: kPrimaryColor.withValues(alpha: 0.1)),
            ),
            child: Column(
              children: [
                _buildSettingsTile(
                  icon: Icons.notifications_rounded,
                  title: 'Push Notifications',
                  trailing: Text(
                    'On',
                    style: GoogleFonts.splineSans(
                      color: kPrimaryColor,
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
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                  onTap: () => context.push('/pending-transfers'),
                ),
                _buildDivider(),
                _buildSettingsTile(
                  icon: Icons.outbox_rounded,
                  title: 'Transfer Outbox',
                  trailing: const Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.grey,
                  ),
                  onTap: () => context.push('/transfer-outbox'),
                ),
                _buildDivider(),
                _buildSettingsTile(
                  icon: Icons.mail_rounded,
                  title: 'Email Subscriptions',
                  trailing: const Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.grey,
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
              color: kPrimaryColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: kPrimaryColor.withValues(alpha: 0.1)),
            ),
            child: Column(
              children: [
                _buildSettingsTile(
                  icon: Icons.shield_moon_rounded,
                  title: 'Social Privacy',
                  trailing: const Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.grey,
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
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: Colors.grey,
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
                        'Dark',
                        style: GoogleFonts.splineSans(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: Colors.grey,
                      ),
                    ],
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

          // Legal
          _buildSectionHeader('LEGAL'),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: kPrimaryColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: kPrimaryColor.withValues(alpha: 0.1)),
            ),
            child: Column(
              children: [
                _buildSettingsTile(
                  icon: Icons.description_rounded,
                  title: 'Terms of Service',
                  trailing: const Icon(
                    Icons.open_in_new_rounded,
                    color: Colors.grey,
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
                  trailing: const Icon(
                    Icons.open_in_new_rounded,
                    color: Colors.grey,
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
              style: GoogleFonts.splineSans(color: Colors.grey, fontSize: 10),
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
              onPressed: isLoggingOut
                  ? null
                  : () async {
                      await ref.read(authControllerProvider.notifier).logout();
                      if (!context.mounted) return;
                      context.go('/login');
                    },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isLoggingOut) ...[
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Logging Out...',
                      style: GoogleFonts.splineSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ] else ...[
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
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Text(
        title,
        style: GoogleFonts.splineSans(
          color: kPrimaryColor.withValues(alpha: 0.6),
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildCountBadge(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: kPrimaryColor.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: kPrimaryColor.withValues(alpha: 0.35)),
      ),
      child: Text(
        count > 99 ? '99+' : '$count',
        style: GoogleFonts.splineSans(
          color: kPrimaryColor,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildAccountCard(Color textColor) {
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
        ? Colors.greenAccent
        : (count == 1 ? Colors.orangeAccent : Colors.redAccent);
    final name = user?['fname'] != null
        ? '${user!['fname']} ${user['lname'] ?? ''}'
        : (user?['name'] ?? 'Guest User');
    final id = user?['id'] ?? 'N/A';
    final avatarUrl =
        user?['photo'] != null && !user!['photo'].toString().startsWith('http')
        ? '${AppConstants.profileImageBaseUrl}${user['photo']}'
        : user?['photo'] ?? 'https://via.placeholder.com/150';

    return Container(
      decoration: BoxDecoration(
        color: kPrimaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kPrimaryColor.withValues(alpha: 0.1)),
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
                      border: Border.all(
                        color: kPrimaryColor.withValues(alpha: 0.2),
                      ),
                    ),
                    child: ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: avatarUrl,
                        fit: BoxFit.cover,
                        width: 48,
                        height: 48,
                        placeholder: (context, url) => Container(
                          color: Colors.white.withValues(alpha: 0.05),
                          child: const Icon(
                            Icons.person,
                            size: 30,
                            color: Colors.white24,
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
                            color: textColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Member • ID: $id',
                          style: GoogleFonts.splineSans(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: Colors.grey),
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
                    color: kPrimaryColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.verified_user_rounded,
                    color: kPrimaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Verification Status',
                    style: GoogleFonts.splineSans(
                      color: textColor,
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
            trailing: const Icon(
              Icons.chevron_right_rounded,
              color: Colors.grey,
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
                color: kPrimaryColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: kPrimaryColor, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.splineSans(
                  color: Colors.white,
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
    return Divider(height: 1, color: kPrimaryColor.withValues(alpha: 0.1));
  }
}
