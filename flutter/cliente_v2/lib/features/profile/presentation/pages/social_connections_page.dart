import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/colors.dart';

import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../data/repositories/social_repository.dart';

class SocialConnectionsPage extends ConsumerStatefulWidget {
  final String initialTab;
  final int? userId;
  final String? title;

  const SocialConnectionsPage({
    super.key,
    this.initialTab = 'following',
    this.userId,
    this.title,
  });

  @override
  ConsumerState<SocialConnectionsPage> createState() =>
      _SocialConnectionsPageState();
}

class _SocialConnectionsPageState extends ConsumerState<SocialConnectionsPage> {
  static const Color _background = kBackgroundDark;
  static const Color _accent = kPrimaryColor;

  String? _busyKey;

  int get _initialIndex {
    final requestsEnabled = widget.userId == null;
    switch (widget.initialTab) {
      case 'followers':
        return 1;
      case 'requests':
        return requestsEnabled ? 2 : 0;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final currentUserId = int.tryParse(currentUser?['id']?.toString() ?? '');
    final targetUserId = widget.userId ?? currentUserId;
    final isSelfView = widget.userId == null || widget.userId == currentUserId;

    if (targetUserId == null) {
      return Scaffold(
        backgroundColor: _background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
          ),
        ),
        body: Center(
          child: Text(
            'We could not load your network right now.',
            style: GoogleFonts.splineSans(color: Colors.white70),
          ),
        ),
      );
    }

    final followingAsync = ref.watch(userFavoritesProvider(targetUserId));
    final followersAsync = ref.watch(userFollowersListProvider(targetUserId));
    final requestsAsync = isSelfView
        ? ref.watch(pendingFollowRequestsProvider)
        : const AsyncValue.data(<dynamic>[]);
    final title = widget.title ?? (isSelfView ? 'My Network' : 'Connections');
    final tabCount = isSelfView ? 3 : 2;

    return DefaultTabController(
      initialIndex: _initialIndex,
      length: tabCount,
      child: Scaffold(
        backgroundColor: _background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
          ),
          title: Text(
            title,
            style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
          ),
          bottom: TabBar(
            indicatorColor: _accent,
            labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.w700),
            tabs: [
              const Tab(text: 'Following'),
              const Tab(text: 'Followers'),
              if (isSelfView)
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Requests'),
                      const SizedBox(width: 6),
                      requestsAsync.maybeWhen(
                        data: (items) => items.isEmpty
                            ? const SizedBox.shrink()
                            : Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: _accent.withValues(alpha: 0.16),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  '${items.length}',
                                  style: GoogleFonts.outfit(
                                    color: _accent,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                        orElse: () => const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.topCenter,
              radius: 1.15,
              colors: [Color(0xFF241438), _background],
            ),
          ),
          child: TabBarView(
            children: [
              _buildFollowingTab(context, followingAsync, isSelfView),
              _buildFollowersTab(context, followersAsync),
              if (isSelfView) _buildRequestsTab(context, requestsAsync),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFollowingTab(
    BuildContext context,
    AsyncValue<List<dynamic>> asyncValue,
    bool isSelfView,
  ) {
    return asyncValue.when(
      data: (items) {
        if (items.isEmpty) {
          return _buildEmptyState(
            'No follows yet',
            'Follow organizers, artists and people to build your scene.',
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = Map<String, dynamic>.from(items[index] as Map);
            final busyKey = 'following-${item['type']}-${item['id']}';

            return _buildEntityCard(
              title: item['name']?.toString() ?? 'Unknown',
              subtitle: _followingSubtitle(item),
              imageUrl: item['photo']?.toString(),
              badge: _typeLabel(item['type']?.toString()),
              trailing: isSelfView
                  ? FilledButton.tonal(
                      onPressed: _busyKey == busyKey
                          ? null
                          : () => _unfollow(item, busyKey),
                      child: Text(
                        _busyKey == busyKey ? 'Working...' : 'Unfollow',
                      ),
                    )
                  : const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: Colors.white38,
                    ),
              onTap: () => _openEntity(context, item),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) =>
          _buildEmptyState('Could not load following', '$error'),
    );
  }

  Widget _buildFollowersTab(
    BuildContext context,
    AsyncValue<List<dynamic>> asyncValue,
  ) {
    return asyncValue.when(
      data: (items) {
        if (items.isEmpty) {
          return _buildEmptyState(
            'No followers yet',
            'When people connect with you, they will show up here.',
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = Map<String, dynamic>.from(items[index] as Map);
            return _buildEntityCard(
              title: item['name']?.toString() ?? 'Unknown',
              subtitle: _followerSubtitle(item),
              imageUrl: item['photo']?.toString(),
              badge: _typeLabel(item['type']?.toString()),
              trailing: const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: Colors.white38,
              ),
              onTap: () => _openEntity(context, item),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) =>
          _buildEmptyState('Could not load followers', '$error'),
    );
  }

  Widget _buildRequestsTab(
    BuildContext context,
    AsyncValue<List<dynamic>> asyncValue,
  ) {
    return asyncValue.when(
      data: (items) {
        if (items.isEmpty) {
          return _buildEmptyState(
            'No pending requests',
            'If someone requests access to your private activity, it will appear here.',
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = Map<String, dynamic>.from(items[index] as Map);
            final id = int.tryParse(item['id']?.toString() ?? '') ?? 0;

            return _buildEntityCard(
              title: item['name']?.toString() ?? 'Unknown',
              subtitle: item['username']?.toString().isNotEmpty == true
                  ? '@${item['username']}'
                  : 'Follow request',
              imageUrl: item['photo']?.toString(),
              badge: 'Request',
              trailing: Wrap(
                spacing: 8,
                children: [
                  OutlinedButton(
                    onPressed: _busyKey == 'request-reject-$id'
                        ? null
                        : () => _rejectRequest(id),
                    child: Text(
                      _busyKey == 'request-reject-$id' ? '...' : 'Decline',
                    ),
                  ),
                  FilledButton.tonal(
                    onPressed: _busyKey == 'request-accept-$id'
                        ? null
                        : () => _acceptRequest(id),
                    child: Text(
                      _busyKey == 'request-accept-$id' ? '...' : 'Accept',
                    ),
                  ),
                ],
              ),
              onTap: () => _openEntity(context, {'type': 'customer', 'id': id}),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) =>
          _buildEmptyState('Could not load requests', '$error'),
    );
  }

  Widget _buildEntityCard({
    required String title,
    required String subtitle,
    required String? imageUrl,
    required String badge,
    required Widget trailing,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              _avatar(imageUrl),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.splineSans(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: _accent.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        badge,
                        style: GoogleFonts.outfit(
                          color: _accent,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              trailing,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String title, String body) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.groups_rounded, color: Colors.white24, size: 54),
            const SizedBox(height: 16),
            Text(
              title,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              body,
              textAlign: TextAlign.center,
              style: GoogleFonts.splineSans(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  Widget _avatar(String? imageUrl) {
    return CircleAvatar(
      radius: 28,
      backgroundColor: Colors.white10,
      backgroundImage: imageUrl != null && imageUrl.isNotEmpty
          ? CachedNetworkImageProvider(imageUrl)
          : null,
      child: imageUrl == null || imageUrl.isEmpty
          ? const Icon(Icons.person_outline, color: Colors.white70)
          : null,
    );
  }

  String _typeLabel(String? type) {
    switch (type) {
      case 'customer':
      case 'user':
        return 'Person';
      case 'organizer':
        return 'Organizer';
      case 'artist':
        return 'Artist';
      case 'venue':
        return 'Venue';
      default:
        return 'Profile';
    }
  }

  String _followingSubtitle(Map<String, dynamic> item) {
    final type = item['type']?.toString() ?? '';
    final identifier = item['identifier']?.toString();

    if (identifier != null && identifier.isNotEmpty) {
      return '@$identifier';
    }

    return switch (type) {
      'organizer' => 'Organizer you follow',
      'artist' => 'Artist you follow',
      'venue' => 'Venue you follow',
      _ => 'Person you follow',
    };
  }

  String _followerSubtitle(Map<String, dynamic> item) {
    final type = item['type']?.toString() ?? '';
    final identifier = item['identifier']?.toString();

    if (identifier != null && identifier.isNotEmpty) {
      return '@$identifier';
    }

    return switch (type) {
      'artist' => 'Artist following you',
      'venue' => 'Venue following you',
      _ => 'Person following you',
    };
  }

  Future<void> _unfollow(Map<String, dynamic> item, String busyKey) async {
    setState(() => _busyKey = busyKey);
    try {
      final type = switch (item['type']?.toString()) {
        'customer' => 'user',
        'organizer' => 'organizer',
        'artist' => 'artist',
        'venue' => 'venue',
        _ => 'user',
      };
      final id = int.tryParse(item['id']?.toString() ?? '') ?? 0;
      await ref.read(socialRepositoryProvider).unfollow(type, id);
      final currentUser = ref.read(currentUserProvider);
      final userId = int.tryParse(currentUser?['id']?.toString() ?? '');
      if (userId != null) {
        ref.invalidate(userFavoritesProvider(userId));
      }
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Removed from following')));
      }
    } finally {
      if (mounted) {
        setState(() => _busyKey = null);
      }
    }
  }

  Future<void> _acceptRequest(int id) async {
    setState(() => _busyKey = 'request-accept-$id');
    try {
      await ref.read(socialRepositoryProvider).acceptRequest(id);
      _invalidateConnectionProviders();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Request accepted')));
      }
    } finally {
      if (mounted) {
        setState(() => _busyKey = null);
      }
    }
  }

  Future<void> _rejectRequest(int id) async {
    setState(() => _busyKey = 'request-reject-$id');
    try {
      await ref.read(socialRepositoryProvider).rejectRequest(id);
      _invalidateConnectionProviders();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Request declined')));
      }
    } finally {
      if (mounted) {
        setState(() => _busyKey = null);
      }
    }
  }

  void _invalidateConnectionProviders() {
    final currentUser = ref.read(currentUserProvider);
    final currentUserId = int.tryParse(currentUser?['id']?.toString() ?? '');
    final targetUserId = widget.userId ?? currentUserId;

    if (targetUserId != null) {
      ref.invalidate(userFavoritesProvider(targetUserId));
      ref.invalidate(userFollowersListProvider(targetUserId));
    }

    if (currentUserId != null && currentUserId != targetUserId) {
      ref.invalidate(userFavoritesProvider(currentUserId));
      ref.invalidate(userFollowersListProvider(currentUserId));
    }
    ref.invalidate(pendingFollowRequestsProvider);
    ref.invalidate(socialFeedProvider);
  }

  void _openEntity(BuildContext context, Map<String, dynamic> item) {
    final type = item['type']?.toString();
    final id = int.tryParse(item['id']?.toString() ?? '');
    if (id == null) return;

    switch (type) {
      case 'organizer':
        context.push('/organizer-profile/$id');
        break;
      case 'artist':
        context.push('/artist-profile/$id');
        break;
      case 'venue':
        context.push('/venue-profile/$id');
        break;
      default:
        context.push('/user-profile/$id');
        break;
    }
  }
}
