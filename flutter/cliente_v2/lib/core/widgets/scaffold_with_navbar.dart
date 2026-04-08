import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/profile/presentation/providers/marketplace_provider.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../core/constants/app_urls.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ScaffoldWithNavBar extends ConsumerWidget {
  final Widget child;

  const ScaffoldWithNavBar({required this.child, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      body: Stack(
        children: [
          Positioned.fill(child: child),
          Positioned(bottom: 24, left: 24, right: 24, child: _CustomNavBar()),
        ],
      ),
    );
  }
}

class _CustomNavBar extends ConsumerWidget {
  const _CustomNavBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String location = GoRouterState.of(context).uri.toString();
    final transferInboxCount = ref.watch(pendingTransfersCountProvider);
    final currentUser = ref.watch(currentUserProvider);
    final avatarUrl = AppUrls.getAvatarUrl(currentUser?['photo']?.toString());
    final isVerified = currentUser != null && currentUser['email_verified_at'] != null && currentUser['phone_verified_at'] != null;

    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2C),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: Icon(
              Icons.home,
              color: location == '/home'
                  ? const Color(0xFF6200EE)
                  : Colors.grey,
            ),
            onPressed: () => context.go('/home'),
          ),
          IconButton(
            icon: Icon(
              Icons.explore_rounded,
              color: location == '/explore'
                  ? const Color(0xFF8F0DF2)
                  : Colors.grey,
            ),
            onPressed: () => context.go('/explore'),
          ),

          GestureDetector(
            onTap: () => context.push('/scanner'),
            child: Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: Color(0xFF6200EE),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF6200EE),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(Icons.qr_code_scanner, color: Colors.white),
            ),
          ),

          IconButton(
            icon: Icon(
              Icons.confirmation_number,
              color: location.startsWith('/my-tickets')
                  ? const Color(0xFF6200EE)
                  : Colors.grey,
            ),
            onPressed: () => context.go('/my-tickets'),
          ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              GestureDetector(
                onTap: () => context.go('/profile'),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: location.startsWith('/profile')
                                ? const Color(0xFF6200EE)
                                : isVerified
                                    ? Colors.greenAccent
                                    : Colors.orangeAccent,
                            width: 2,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 12, // scaled down to fit navbar
                          backgroundImage: avatarUrl != null
                              ? CachedNetworkImageProvider(avatarUrl)
                              : const CachedNetworkImageProvider(
                                  'https://i.pravatar.cc/150?img=12',
                                ) as ImageProvider,
                          onBackgroundImageError: (_, _) {},
                        ),
                      ),
                      Positioned(
                        right: -2,
                        bottom: -2,
                        child: Container(
                          padding: const EdgeInsets.all(1),
                          decoration: BoxDecoration(
                            color: isVerified ? Colors.green : Colors.orange,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF1E1E2C), // Navbar bg
                              width: 1.5,
                            ),
                          ),
                          child: Icon(
                            isVerified ? Icons.check : Icons.priority_high,
                            color: Colors.white,
                            size: 6,
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
                    color: const Color(0xFF8655F6),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
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
