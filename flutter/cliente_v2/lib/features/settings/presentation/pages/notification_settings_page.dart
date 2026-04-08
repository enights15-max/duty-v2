import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationSettingsPage extends ConsumerStatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  ConsumerState<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState
    extends ConsumerState<NotificationSettingsPage> {
  // Theme Constants
  static const Color kPrimaryColor = Color(0xFF8C25F4);
  static const Color kBackgroundDark = Color(0xFF0A050F);

  bool _quietHoursEnabled = true;
  bool _newDropsEnabled = true;
  bool _ticketSalesEnabled = true;
  bool _showRemindersEnabled = false;
  bool _walletTxEnabled = true;
  bool _friendActivityEnabled = true;

  @override
  Widget build(BuildContext context) {
    // Forcing Dark Mode for now
    const backgroundColor = kBackgroundDark;
    const textColor = Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // Content
          Column(
            children: [
              // Header
              Container(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 16,
                  bottom: 16,
                  left: 24,
                  right: 24,
                ),
                color: backgroundColor.withValues(alpha: 0.8),
                child: ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _GlassIconButton(
                          icon: Icons.chevron_left_rounded,
                          onTap: () => context.pop(),
                        ),
                        Text(
                          'Notifications',
                          style: GoogleFonts.splineSans(
                            color: textColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 40), // Spacer
                      ],
                    ),
                  ),
                ),
              ),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: [
                    const SizedBox(height: 16),
                    // Quiet Hours Section
                    _buildQuietHoursSection(textColor),

                    const SizedBox(height: 32),

                    // Event Updates
                    _buildSectionTitle('EVENT UPDATES'),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.05),
                        ),
                      ),
                      child: Column(
                        children: [
                          _buildToggleTile(
                            icon: Icons.auto_awesome_rounded,
                            title: 'New Event Drops',
                            subtitle: 'Be first to know about new listings',
                            value: _newDropsEnabled,
                            onChanged: (v) =>
                                setState(() => _newDropsEnabled = v),
                          ),
                          Divider(
                            height: 1,
                            color: Colors.white.withValues(alpha: 0.05),
                          ),
                          _buildToggleTile(
                            icon: Icons.timer_rounded,
                            title: 'Ticket Sales Ending',
                            subtitle: 'Last chance warnings for shows',
                            value: _ticketSalesEnabled,
                            onChanged: (v) =>
                                setState(() => _ticketSalesEnabled = v),
                          ),
                          Divider(
                            height: 1,
                            color: Colors.white.withValues(alpha: 0.05),
                          ),
                          _buildToggleTile(
                            icon: Icons.confirmation_number_rounded,
                            title: 'Show Reminders',
                            subtitle: 'Updates on your booked events',
                            value: _showRemindersEnabled,
                            onChanged: (v) =>
                                setState(() => _showRemindersEnabled = v),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Fintech & Social
                    _buildSectionTitle('FINTECH & SOCIAL'),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.05),
                        ),
                      ),
                      child: Column(
                        children: [
                          _buildToggleTile(
                            icon: Icons.account_balance_wallet_rounded,
                            title: 'Wallet Transactions',
                            subtitle: 'Deposit and purchase confirmations',
                            value: _walletTxEnabled,
                            onChanged: (v) =>
                                setState(() => _walletTxEnabled = v),
                          ),
                          Divider(
                            height: 1,
                            color: Colors.white.withValues(alpha: 0.05),
                          ),
                          _buildToggleTile(
                            icon: Icons.group_rounded,
                            title: 'Friend Activity',
                            subtitle: 'See which events your friends join',
                            value: _friendActivityEnabled,
                            onChanged: (v) =>
                                setState(() => _friendActivityEnabled = v),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Delivery Method
                    _buildSectionTitle('DELIVERY METHOD'),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDeliveryOption(
                            icon: Icons.notifications_active_rounded,
                            label: 'Push',
                            isSelected: true,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildDeliveryOption(
                            icon: Icons.mail_rounded,
                            label: 'Email',
                            isSelected: false,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildDeliveryOption(
                            icon: Icons.sms_rounded,
                            label: 'SMS',
                            isSelected: false,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Security Notice
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF251B31),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.security_rounded,
                            color: kPrimaryColor,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'High-priority security alerts and critical wallet notifications will bypass Do Not Disturb settings for your safety.',
                              style: GoogleFonts.splineSans(
                                color: Colors.blueGrey[300],
                                fontSize: 12,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuietHoursSection(Color textColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kPrimaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kPrimaryColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: kPrimaryColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.bedtime_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quiet Hours',
                      style: GoogleFonts.splineSans(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Silence after-event alerts',
                      style: GoogleFonts.splineSans(
                        color: Colors.blueGrey[400],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _quietHoursEnabled,
                activeColor: kPrimaryColor,
                onChanged: (v) => setState(() => _quietHoursEnabled = v),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildTimeBox('From', '23:00')),
              const SizedBox(width: 8),
              Expanded(child: _buildTimeBox('To', '08:00')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeBox(String label, String time) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          Text(
            label.toUpperCase(),
            style: GoogleFonts.splineSans(
              color: Colors.blueGrey[600],
              fontSize: 10,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            time,
            style: GoogleFonts.splineSans(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.splineSans(
        color: Colors.blueGrey[400],
        fontSize: 11,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildToggleTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(icon, color: kPrimaryColor.withValues(alpha: 0.6), size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.splineSans(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.splineSans(
                    color: Colors.blueGrey[400],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeColor: kPrimaryColor,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryOption({
    required IconData icon,
    required String label,
    required bool isSelected,
  }) {
    final bgColor = isSelected
        ? kPrimaryColor
        : Colors.white.withValues(alpha: 0.05);
    final borderColor = isSelected
        ? kPrimaryColor
        : Colors.white.withValues(alpha: 0.05);
    final iconColor = isSelected ? Colors.white : Colors.blueGrey[400];
    final textColor = isSelected ? Colors.white : Colors.blueGrey[400];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(height: 8),
          Text(
            label.toUpperCase(),
            style: GoogleFonts.splineSans(
              color: textColor,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _GlassIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF8C25F4).withValues(alpha: 0.1),
        ),
        child: Icon(icon, size: 20, color: const Color(0xFF8C25F4)),
      ),
    );
  }
}
