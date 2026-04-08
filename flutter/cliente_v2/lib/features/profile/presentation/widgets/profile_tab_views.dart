import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/repositories/social_repository.dart';
import '../../../../core/constants/app_urls.dart';
import 'package:cached_network_image/cached_network_image.dart';

double _profileTabBottomInset(BuildContext context) =>
    MediaQuery.of(context).padding.bottom + 132;

class ProfileUpcomingAttendanceTab extends ConsumerWidget {
  final int userId;

  const ProfileUpcomingAttendanceTab({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(userUpcomingAttendanceProvider(userId));

    return eventsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Error loading upcoming events: $err',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white54),
          ),
        ),
      ),
      data: (events) {
        if (events.isEmpty) {
          return const Center(
            child: Text(
              'No upcoming attendance shared.',
              style: TextStyle(color: Colors.white54),
            ),
          );
        }
        return ListView.builder(
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            _profileTabBottomInset(context),
          ),
          itemCount: events.length,
          itemBuilder: (context, index) {
            final e = events[index];
            final imageUrl = AppUrls.getEventThumbnailUrl(e['thumbnail']);

            return ListTile(
              onTap: e['id'] != null
                  ? () => context.push('/event-details/${e['id']}')
                  : null,
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: imageUrl,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            Container(color: Colors.white12),
                        errorWidget: (context, url, err) =>
                            const Icon(Icons.event),
                      )
                    : const Icon(Icons.event),
              ),
              title: Text(
                e['title'] ?? '',
                style: const TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                e['date'] ?? '',
                style: const TextStyle(color: Colors.white54),
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: Colors.white24,
              ),
            );
          },
        );
      },
    );
  }
}

// Displays Attended Events (Scanned Tickets)
class ProfileAttendedEventsTab extends ConsumerWidget {
  final int userId;

  const ProfileAttendedEventsTab({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(userAttendedEventsProvider(userId));

    return eventsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Error loading events: $err',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white54),
          ),
        ),
      ),
      data: (events) {
        if (events.isEmpty) {
          return const Center(
            child: Text(
              'No attended events yet.',
              style: TextStyle(color: Colors.white54),
            ),
          );
        }
        return ListView.builder(
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            _profileTabBottomInset(context),
          ),
          itemCount: events.length,
          itemBuilder: (context, index) {
            final e = events[index];
            final imageUrl = AppUrls.getEventThumbnailUrl(e['thumbnail']);

            return ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: imageUrl,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            Container(color: Colors.white12),
                        errorWidget: (context, url, err) =>
                            const Icon(Icons.event),
                      )
                    : const Icon(Icons.event),
              ),
              title: Text(
                e['title'] ?? '',
                style: const TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                e['date'] ?? '',
                style: const TextStyle(color: Colors.white54),
              ),
            );
          },
        );
      },
    );
  }
}

// Displays Interested Events (Wishlist)
class ProfileInterestedEventsTab extends ConsumerWidget {
  final int userId;

  const ProfileInterestedEventsTab({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(userInterestedEventsProvider(userId));

    return eventsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Error loading interests: $err',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white54),
          ),
        ),
      ),
      data: (events) {
        if (events.isEmpty) {
          return const Center(
            child: Text(
              'No interested events yet.',
              style: TextStyle(color: Colors.white54),
            ),
          );
        }
        return ListView.builder(
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            _profileTabBottomInset(context),
          ),
          itemCount: events.length,
          itemBuilder: (context, index) {
            final e = events[index];
            final imageUrl = AppUrls.getEventThumbnailUrl(e['thumbnail']);

            return ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: imageUrl,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            Container(color: Colors.white12),
                        errorWidget: (context, url, err) =>
                            const Icon(Icons.event),
                      )
                    : const Icon(Icons.event),
              ),
              title: Text(
                e['title'] ?? '',
                style: const TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                e['date'] ?? '',
                style: const TextStyle(color: Colors.white54),
              ),
            );
          },
        );
      },
    );
  }
}

// Displays Favorites (Artists, Venues, Organizers)
class ProfileFavoritesTab extends ConsumerWidget {
  final int userId;

  const ProfileFavoritesTab({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesAsync = ref.watch(userFavoritesProvider(userId));

    return favoritesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error loading favorites')),
      data: (favorites) {
        if (favorites.isEmpty) {
          return const Center(
            child: Text(
              'No favorites yet.',
              style: TextStyle(color: Colors.white54),
            ),
          );
        }
        return ListView.builder(
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            _profileTabBottomInset(context),
          ),
          itemCount: favorites.length,
          itemBuilder: (context, index) {
            final f = favorites[index];
            final imageUrl = AppUrls.getAvatarUrl(
              f['photo'],
              isOrganizer: f['type'] == 'organizer',
            );

            return ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.white10,
                backgroundImage: imageUrl != null
                    ? CachedNetworkImageProvider(imageUrl)
                    : null,
                child: imageUrl == null ? const Icon(Icons.person) : null,
              ),
              title: Text(
                f['name'] ?? '',
                style: const TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                f['type'] ?? '',
                style: const TextStyle(color: Colors.white54),
              ),
            );
          },
        );
      },
    );
  }
}
