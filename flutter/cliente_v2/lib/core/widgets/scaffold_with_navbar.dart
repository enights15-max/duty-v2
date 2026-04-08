import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/profile/domain/models/profile_model.dart';
import '../../core/providers/profile_state_provider.dart';
import '../../features/profile/presentation/providers/marketplace_provider.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../core/constants/app_urls.dart';
import '../theme/colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'account_switcher_sheet.dart';

class ScaffoldWithNavBar extends StatelessWidget {
  final Widget child;

  const ScaffoldWithNavBar({required this.child, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.dutyTheme;

    return Scaffold(
      backgroundColor: palette.background,
      body: Stack(
        children: [
          // Background Gradient (Global)
          /*
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topLeft,
                  radius: 1.2,
                  colors: [
                    Color(0xFF2A1B3D), // Purple glow top-left
                    Color(0xFF0F0F1A), // Dark base
                  ],
                ),
              ),
            ),
          ),
          */
          // We might want to let the child pages handle their own background
          // OR provide a common one here. The user said "tabs" should be the same.
          // Let's keep the background control in the pages for now,
          // as ProfilePage has a specific background logic.

          // The Page Content
          Positioned.fill(child: child),

          // Bottom Navigation Bar (Custom Floating)
          Positioned(
            bottom: 24,
            left: 24,
            right: 24,
            child: _CustomNavBar(context),
          ),
        ],
      ),
    );
  }
}

class _CustomNavBar extends StatelessWidget {
  final BuildContext context;
  const _CustomNavBar(this.context);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = context.dutyTheme;
    final String location = GoRouterState.of(context).uri.toString();
    final transferInboxCount = ref.watch(pendingTransfersCountProvider);
    final currentUser = ref.watch(currentUserProvider);
    final activeProfile = ref.watch(activeProfileProvider);

    final avatarUrl = activeProfile?.isProfessional == true
        ? activeProfile?.avatarUrl
        : AppUrls.getCustomerAvatarUrl(currentUser);
    final isVerified =
        currentUser != null &&
        currentUser['email_verified_at'] != null &&
        currentUser['phone_verified_at'] != null;

    final items = _getNavItems(activeProfile);

    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: palette.navBarSurface,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: palette.shadow.withValues(alpha: 0.22),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: items.map((item) {
          if (item.isScanner) {
            return GestureDetector(
              onTap: () => context.push(item.route),
              child: Container(
                width: 52, // Increased from 48
                height: 52, // Increased from 48
                decoration: BoxDecoration(
                  color: palette.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: palette.primaryGlow.withValues(alpha: 0.42),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(
                  item.icon,
                  color: Colors.white,
                  size: 28,
                ), // Increased from default
              ),
            );
          }

          if (item.isProfile) {
            return Stack(
              clipBehavior: Clip.none,
              children: [
                _AvatarLongPressTrigger(
                  key: const ValueKey('profile_avatar_trigger'),
                  onTap: () => context.go(item.route),
                  onTrigger: () => AccountSwitcherSheet.show(context),
                  child: Container(
                    padding: const EdgeInsets.all(
                      6.0,
                    ), // Reduced slightly to allow more space for the circle
                    color: Colors.transparent,
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: location.startsWith('/profile')
                                  ? palette.primary
                                  : isVerified
                                  ? palette.success
                                  : palette.warning,
                              width: 2.5, // Thicker border
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 15, // Increased from 12
                            backgroundImage: avatarUrl != null
                                ? CachedNetworkImageProvider(avatarUrl)
                                : const CachedNetworkImageProvider(
                                        'https://i.pravatar.cc/150?img=12',
                                      )
                                      as ImageProvider,
                            onBackgroundImageError: (_, _) {},
                          ),
                        ),
                        Positioned(
                          right: -1,
                          bottom: -1,
                          child: Container(
                            padding: const EdgeInsets.all(1.5),
                            decoration: BoxDecoration(
                              color: isVerified
                                  ? palette.success
                                  : palette.warning,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: palette.navBarSurface,
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              isVerified ? Icons.check : Icons.priority_high,
                              color: Colors.white,
                              size: 7, // Slightly larger
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (transferInboxCount > 0)
                  Positioned(
                    top: 4,
                    right: 2,
                    child: _CountBadge(
                      count: transferInboxCount,
                      color: palette.primary,
                    ),
                  ),
              ],
            );
          }

          final isActive = location.startsWith(item.route);

          return IconButton(
            iconSize: 28, // Increased from default
            icon: Icon(
              item.icon,
              size: 28, // Explicitly set
              color: isActive ? palette.primary : palette.textMuted,
            ),
            onPressed: () => context.go(item.route),
          );
        }).toList(),
      ),
    );
  }

  List<_NavItem> _getNavItems(AppProfile? profile) {
    if (profile == null || profile.type == ProfileType.personal) {
      return [
        _NavItem(icon: Icons.home, route: '/home'),
        _NavItem(icon: Icons.explore_rounded, route: '/explore'),
        _NavItem(
          icon: Icons.qr_code_scanner,
          route: '/scanner',
          isScanner: true,
        ),
        _NavItem(icon: Icons.confirmation_number, route: '/my-tickets'),
        _NavItem(icon: Icons.person, route: '/profile', isProfile: true),
      ];
    }

    // Professional Dashboards (Artist, Venue, Organizer)
    final List<_NavItem> items = [
      _NavItem(icon: Icons.dashboard_rounded, route: '/dashboard'),
      _NavItem(icon: Icons.explore_rounded, route: '/explore'),
      _NavItem(icon: Icons.qr_code_scanner, route: '/scanner', isScanner: true),
      _NavItem(icon: Icons.account_balance_wallet_rounded, route: '/wallet'),
    ];

    items.add(_NavItem(icon: Icons.person, route: '/profile', isProfile: true));
    return items;
  }
}

class _NavItem {
  final IconData icon;
  final String route;
  final bool isScanner;
  final bool isProfile;

  _NavItem({
    required this.icon,
    required this.route,
    this.isScanner = false,
    this.isProfile = false,
  });
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count, required this.color});

  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.35), blurRadius: 8),
        ],
      ),
      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
      child: Text(
        count > 99 ? '99+' : count.toString(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 8,
          fontWeight: FontWeight.w800,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _AvatarLongPressTrigger extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final VoidCallback onTrigger;

  const _AvatarLongPressTrigger({
    super.key,
    required this.child,
    required this.onTap,
    required this.onTrigger,
  });

  @override
  State<_AvatarLongPressTrigger> createState() =>
      _AvatarLongPressTriggerState();
}

class _AvatarLongPressTriggerState extends State<_AvatarLongPressTrigger> {
  Timer? _timer;

  void _startTimer() {
    _timer?.cancel();
    HapticFeedback.selectionClick(); // Immediate feedback
    _timer = Timer(const Duration(seconds: 1), () {
      HapticFeedback.heavyImpact();
      widget.onTrigger();
    });
  }

  void _cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _cancelTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onLongPressDown: (_) => _startTimer(),
      onLongPressUp: () => _cancelTimer(),
      onLongPressCancel: () => _cancelTimer(),
      child: widget.child,
    );
  }
}
