import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../profile/data/repositories/social_repository.dart';

class PrivacySettingsPage extends ConsumerStatefulWidget {
  const PrivacySettingsPage({super.key});

  @override
  ConsumerState<PrivacySettingsPage> createState() =>
      _PrivacySettingsPageState();
}

class _PrivacySettingsPageState extends ConsumerState<PrivacySettingsPage> {
  DutyThemeTokens get _palette => context.dutyTheme;

  bool _isSaving = false;

  Future<void> _saveSettings(Map<String, dynamic> patch) async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final updated = await ref
          .read(socialRepositoryProvider)
          .updatePrivacySettings(patch);

      final prefs = ref.read(sharedPreferencesProvider);
      final currentUser = ref.read(currentUserProvider);
      if (currentUser != null) {
        final nextUser = Map<String, dynamic>.from(currentUser)
          ..addAll(updated.toJson());
        await prefs.setString(AppConstants.userKey, jsonEncode(nextUser));
        ref.read(currentUserProvider.notifier).state = nextUser;
      }

      ref.invalidate(privacySettingsProvider);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Privacy settings updated'),
          backgroundColor: kSuccessColor,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update settings: $e'),
          backgroundColor: kDangerColor,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = _palette;
    final settingsAsync = ref.watch(privacySettingsProvider);

    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: palette.primary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Social Privacy',
          style: GoogleFonts.splineSans(
            color: palette.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: settingsAsync.when(
        loading: () =>
            Center(child: CircularProgressIndicator(color: palette.primary)),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Failed to load privacy settings.',
              style: GoogleFonts.splineSans(color: palette.textSecondary),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (settings) => ListView(
          padding: const EdgeInsets.all(24),
          children: [
            if (_isSaving)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: LinearProgressIndicator(color: palette.primary),
              ),
            _buildHeroCard(),
            const SizedBox(height: 24),
            _buildSectionTitle('ACCOUNT'),
            const SizedBox(height: 12),
            _buildToggleCard(
              title: 'Private account',
              subtitle:
                  'Only approved followers can see your shared social activity.',
              value: settings.isPrivate,
              onChanged: (value) => _saveSettings({'is_private': value}),
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('SHARED ACTIVITY'),
            const SizedBox(height: 12),
            _buildToggleCard(
              title: 'Show interested events',
              subtitle:
                  'Let others see the events you marked as interesting or saved.',
              value: settings.showInterestedEvents,
              onChanged: (value) =>
                  _saveSettings({'show_interested_events': value}),
            ),
            const SizedBox(height: 12),
            _buildToggleCard(
              title: 'Show attended events',
              subtitle:
                  'Expose your confirmed event history when your profile allows it.',
              value: settings.showAttendedEvents,
              onChanged: (value) =>
                  _saveSettings({'show_attended_events': value}),
            ),
            const SizedBox(height: 12),
            _buildToggleCard(
              title: 'Show upcoming attendance',
              subtitle:
                  'Let people see future events you are already attending with a paid booking.',
              value: settings.showUpcomingAttendance,
              onChanged: (value) =>
                  _saveSettings({'show_upcoming_attendance': value}),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroCard() {
    final palette = _palette;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: palette.border),
        gradient: LinearGradient(
          colors: [palette.heroGradientStart, palette.surface],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Control how your event activity appears inside Duty.',
            style: GoogleFonts.plusJakartaSans(
              color: palette.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Interest, attendance and profile privacy are handled separately so you can keep social discovery useful without exposing more than you want.',
            style: GoogleFonts.splineSans(
              color: palette.textSecondary,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    final palette = _palette;
    return Text(
      title,
      style: GoogleFonts.splineSans(
        color: palette.primary.withValues(alpha: 0.72),
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.4,
      ),
    );
  }

  Widget _buildToggleCard({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final palette = _palette;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: palette.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    color: palette.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: GoogleFonts.splineSans(
                    color: palette.textSecondary,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Switch(
            value: value,
            onChanged: _isSaving ? null : onChanged,
            activeThumbColor: palette.primary,
            activeTrackColor: palette.primary.withValues(alpha: 0.4),
          ),
        ],
      ),
    );
  }
}
