import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../../core/constants/app_urls.dart';
import '../../../../core/theme/colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../chat/presentation/providers/chat_provider.dart';
import '../../data/repositories/social_repository.dart';

class ArtistProfilePage extends ConsumerStatefulWidget {
  final int artistId;

  const ArtistProfilePage({super.key, required this.artistId});

  @override
  ConsumerState<ArtistProfilePage> createState() => _ArtistProfilePageState();
}

class _ArtistProfilePageState extends ConsumerState<ArtistProfilePage> {
  static const Color kPrimaryColor = kDustRose;
  static const Color kDarkBackground = kBackgroundDark;
  static const Color kCardColor = kSurfaceColor;

  Map<String, dynamic>? _profileData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    try {
      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.dio.get(
        AppUrls.artistProfile(widget.artistId),
        options: Options(
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode == 200) {
        final json = _asMap(response.data);
        if (json['success'] == true) {
          if (!mounted) return;
          setState(() {
            _profileData = json['data'];
            _isLoading = false;
          });
          return;
        }
      }
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load artist profile. Please try again.';
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'An error occurred. Check your connection.';
        _isLoading = false;
      });
    }
  }

  Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    if (data is String) {
      final decoded = jsonDecode(data);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    }
    return <String, dynamic>{};
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.dutyTheme;
    if (_isLoading) {
      return Scaffold(
        backgroundColor: kDarkBackground,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: BackButton(color: palette.textPrimary),
        ),
        body: const Center(
          child: CircularProgressIndicator(color: kPrimaryColor),
        ),
      );
    }

    if (_error != null || _profileData == null) {
      return Scaffold(
        backgroundColor: kDarkBackground,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: BackButton(color: palette.textPrimary),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: palette.textSecondary, size: 48),
              const SizedBox(height: 16),
              Text(
                _error ?? 'Artist not found',
                style: GoogleFonts.manrope(color: palette.textMuted),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _error = null;
                  });
                  _fetchProfile();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    final data = _profileData!;
    final name = data['name'] ?? 'Unknown Artist';
    final username = data['username'] ?? '';
    final photo = data['photo'];
    final coverPhoto = data['cover_photo'];
    final details = data['details'];
    final genres = (data['genres'] as List<dynamic>? ?? const [])
        .map((e) => e.toString().trim())
        .where((e) => e.isNotEmpty)
        .toList();
    final location = [
      (data['city'] ?? '').toString().trim(),
      (data['country'] ?? '').toString().trim(),
    ].where((e) => e.isNotEmpty).join(', ');
    final socials = _asMap(data['socials']);
    final gallery = (data['gallery'] as List<dynamic>? ?? const [])
        .map((e) => e.toString().trim())
        .where((e) => e.isNotEmpty)
        .toList();
    final bookingNotes = (data['booking_notes'] ?? '').toString().trim();
    final events = (data['events'] as List<dynamic>?) ?? [];

    return Scaffold(
      backgroundColor: kDarkBackground,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: palette.surface.withValues(alpha: 0.8),
              shape: BoxShape.circle,
            ),
            child: BackButton(color: palette.textPrimary),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Image / Banner
            Stack(
              children: [
                SizedBox(
                  height: 300,
                  width: double.infinity,
                  child:
                      (coverPhoto != null && coverPhoto.isNotEmpty) ||
                          (photo != null && photo.isNotEmpty)
                      ? ShaderMask(
                          shaderCallback: (rect) {
                            return const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.black, Colors.transparent],
                            ).createShader(
                              Rect.fromLTRB(0, 150, rect.width, rect.height),
                            );
                          },
                          blendMode: BlendMode.dstIn,
                          child: CachedNetworkImage(
                            imageUrl:
                                AppUrls.getArtistImageUrl(
                                  coverPhoto ?? photo,
                                ) ??
                                '',
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: kPrimaryColor,
                              ),
                            ),
                            errorWidget: (_, _, _) => _buildFallbackHeader(),
                          ),
                        )
                      : _buildFallbackHeader(),
                ),
                // Gradient overlay at bottom
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: 120,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          kDarkBackground.withValues(alpha: 0.0),
                          kDarkBackground,
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Profile Info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (photo != null && photo.toString().isNotEmpty) ...[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: 92,
                        height: 92,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: kPrimaryColor.withValues(alpha: 0.8),
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: kPrimaryColor.withValues(alpha: 0.25),
                              blurRadius: 24,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: AppUrls.getArtistImageUrl(photo) ?? '',
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: Colors.white12,
                              child: const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: kPrimaryColor,
                                ),
                              ),
                            ),
                            errorWidget: (_, _, _) => Container(
                              color: Colors.white12,
                              child: const Icon(
                                Icons.music_note,
                                color: Colors.white38,
                                size: 36,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                  ],
                  const SizedBox(height: 16),
                  Text(
                    name,
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      height: 1.1,
                    ),
                  ),
                  if (username.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      '@$username',
                      style: GoogleFonts.manrope(
                        color: kPrimaryColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),

                  if (details != null && details.isNotEmpty) ...[
                    Text(
                      'About',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      details.replaceAll(
                        RegExp(r'<[^>]*>|&[^;]+;'),
                        '',
                      ), // basic HTML stripping
                      style: GoogleFonts.manrope(
                        color: Colors.white54,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],

                  if (genres.isNotEmpty || location.isNotEmpty) ...[
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        for (final genre in genres.take(5))
                          _buildMetaChip(genre, icon: Icons.music_note_rounded),
                        if (location.isNotEmpty)
                          _buildMetaChip(location, icon: Icons.place_outlined),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSimpleStat(
                        '${data['followers_count'] ?? 0}',
                        'Followers',
                      ),
                      const SizedBox(width: 24),
                      _buildFollowButton(
                        isFollowing: data['is_following'] == true,
                        hasPendingRequest: data['has_pending_request'] == true,
                        onFollow: () => _handleFollow(data['id']),
                        onUnfollow: () => _handleUnfollow(data['id']),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _buildBookingContactCard(
                    artistId: (data['id'] as num?)?.toInt() ?? 0,
                    bookingNotes: bookingNotes,
                  ),
                  const SizedBox(height: 32),

                  _buildMusicMediaSection(socials),
                  if (socials.isNotEmpty) const SizedBox(height: 32),

                  if (gallery.isNotEmpty) ...[
                    _buildPressGallerySection(gallery),
                    const SizedBox(height: 32),
                  ],

                  if (bookingNotes.isNotEmpty) ...[
                    _buildBookingNotesSection(bookingNotes),
                    const SizedBox(height: 32),
                  ],

                  // Upcoming Events
                  Text(
                    'Featured Events',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (events.isEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: kCardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Text(
                        'No upcoming events right now.',
                        style: GoogleFonts.manrope(color: Colors.white54),
                      ),
                    )
                  else
                    ...events.map((e) => _buildEventCard(e)),

                  const SizedBox(height: 48),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackHeader() {
    return Container(
      color: kCardColor,
      child: const Center(
        child: Icon(Icons.music_note, color: Colors.white12, size: 80),
      ),
    );
  }

  Widget _buildPressGallerySection(List<String> gallery) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Press Gallery',
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'A fast visual read for venues, promoters and collaborators.',
            style: GoogleFonts.manrope(
              color: Colors.white60,
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 112,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: gallery.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final imageUrl = gallery[index];
                return Container(
                  width: 140,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white10),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    errorWidget: (_, _, _) => Container(
                      color: Colors.white10,
                      child: const Icon(
                        Icons.image_outlined,
                        color: Colors.white30,
                      ),
                    ),
                    placeholder: (context, url) => Container(
                      color: Colors.white10,
                      child: const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: kPrimaryColor,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingContactCard({
    required int artistId,
    required String bookingNotes,
  }) {
    final bookingSummary = bookingNotes.trim().isEmpty
        ? 'Use Duty chat to reach the artist for bookings, collaborations or availability questions.'
        : bookingNotes.trim();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kPrimaryColor.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
            color: kPrimaryColor.withValues(alpha: 0.12),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: kPrimaryColor.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.campaign_outlined,
                  color: kPrimaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Book / Contact',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Primary contact happens through Duty chat.',
                      style: GoogleFonts.manrope(
                        color: Colors.white60,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            bookingSummary,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.manrope(
              color: Colors.white70,
              fontSize: 14,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: artistId <= 0
                  ? null
                  : () => _startArtistChat(artistId),
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
              label: const Text('Book / Contact in Duty'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingNotesSection(String bookingNotes) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'For Promoters & Venues',
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            bookingNotes,
            style: GoogleFonts.manrope(
              color: Colors.white70,
              fontSize: 14,
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMusicMediaSection(Map<String, dynamic> socials) {
    final items = <_ArtistMediaAction>[
      if ((socials['instagram'] ?? '').toString().trim().isNotEmpty)
        _ArtistMediaAction(
          icon: Icons.camera_alt_outlined,
          label: 'Instagram',
          subtitle: 'Social profile',
          accent: const Color(0xFFE1306C),
          externalUrl: _normalizeSocialUrl(
            socials['instagram'].toString(),
            'instagram',
          ),
        ),
      if ((socials['facebook'] ?? '').toString().trim().isNotEmpty)
        _ArtistMediaAction(
          icon: Icons.facebook_rounded,
          label: 'Facebook',
          subtitle: 'Community updates',
          accent: const Color(0xFF1877F2),
          externalUrl: _normalizeSocialUrl(
            socials['facebook'].toString(),
            'facebook',
          ),
        ),
      if ((socials['tiktok'] ?? '').toString().trim().isNotEmpty)
        _ArtistMediaAction(
          icon: Icons.music_note_rounded,
          label: 'TikTok',
          subtitle: 'Short-form edits',
          accent: Colors.white,
          externalUrl: _normalizeSocialUrl(
            socials['tiktok'].toString(),
            'tiktok',
          ),
        ),
      if ((socials['spotify'] ?? '').toString().trim().isNotEmpty)
        _ArtistMediaAction(
          icon: Icons.queue_music_rounded,
          label: 'Spotify',
          subtitle: 'Listen now',
          accent: const Color(0xFF1DB954),
          externalUrl: _normalizeSocialUrl(
            socials['spotify'].toString(),
            'spotify',
          ),
          embedUrl: _buildSpotifyEmbedUrl(
            _normalizeSocialUrl(socials['spotify'].toString(), 'spotify'),
          ),
        ),
      if ((socials['soundcloud'] ?? '').toString().trim().isNotEmpty)
        _ArtistMediaAction(
          icon: Icons.graphic_eq_rounded,
          label: 'SoundCloud',
          subtitle: 'Tracks & demos',
          accent: const Color(0xFFFF7700),
          externalUrl: _normalizeSocialUrl(
            socials['soundcloud'].toString(),
            'soundcloud',
          ),
          embedUrl: _buildSoundCloudEmbedUrl(
            _normalizeSocialUrl(socials['soundcloud'].toString(), 'soundcloud'),
          ),
        ),
      if ((socials['youtube'] ?? '').toString().trim().isNotEmpty)
        _ArtistMediaAction(
          icon: Icons.ondemand_video_rounded,
          label: 'YouTube',
          subtitle: 'Live sets & videos',
          accent: const Color(0xFFFF0000),
          externalUrl: _normalizeSocialUrl(
            socials['youtube'].toString(),
            'youtube',
          ),
          embedUrl: _buildYouTubeEmbedUrl(
            _normalizeSocialUrl(socials['youtube'].toString(), 'youtube'),
          ),
        ),
    ];

    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Music & Media',
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'A compact artist press surface: listening links, media channels and upcoming dates in one place.',
            style: GoogleFonts.manrope(
              color: Colors.white60,
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: items.map((item) {
              return InkWell(
                onTap: () => _handleMediaTap(item),
                borderRadius: BorderRadius.circular(16),
                child: Ink(
                  width: 158,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: item.accent.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: item.accent.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(item.icon, color: item.accent, size: 19),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              item.label,
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item.subtitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.manrope(
                                color: Colors.white60,
                                fontSize: 11,
                                height: 1.25,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          Text(
            'Tap a music channel to open an embedded player when available, or jump out to the original platform.',
            style: GoogleFonts.manrope(
              color: Colors.white38,
              fontSize: 11,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleMediaTap(_ArtistMediaAction item) async {
    if (item.embedUrl != null && item.embedUrl!.isNotEmpty) {
      await _showMediaEmbed(item);
      return;
    }

    await _openExternalLink(item.externalUrl);
  }

  Future<void> _showMediaEmbed(_ArtistMediaAction item) async {
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(item.embedUrl!));

    if (!mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.82,
          child: Container(
            decoration: const BoxDecoration(
              color: kDarkBackground,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 12),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: item.accent.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(item.icon, color: item.accent, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.label,
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              item.subtitle,
                              style: GoogleFonts.manrope(
                                color: Colors.white60,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () => _openExternalLink(item.externalUrl),
                        child: Text(
                          'Open',
                          style: GoogleFonts.manrope(
                            color: item.accent,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Colors.white10),
                Expanded(child: WebViewWidget(controller: controller)),
              ],
            ),
          ),
        );
      },
    );
  }

  String? _buildSpotifyEmbedUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return null;

    if (uri.host.contains('open.spotify.com')) {
      return 'https://open.spotify.com/embed${uri.path}';
    }

    if (url.startsWith('spotify:')) {
      final embedPath = url.replaceFirst('spotify:', '/').replaceAll(':', '/');
      return 'https://open.spotify.com/embed$embedPath';
    }

    return null;
  }

  String? _buildSoundCloudEmbedUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return null;

    return 'https://w.soundcloud.com/player/?url=${Uri.encodeComponent(uri.toString())}&auto_play=false&hide_related=false&show_comments=false&show_user=true&show_reposts=false&visual=true';
  }

  String? _buildYouTubeEmbedUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return null;

    String? videoId;
    if (uri.host.contains('youtu.be')) {
      if (uri.pathSegments.isNotEmpty) {
        videoId = uri.pathSegments.first;
      }
    } else if (uri.queryParameters['v'] != null) {
      videoId = uri.queryParameters['v'];
    } else if (uri.pathSegments.contains('shorts')) {
      final index = uri.pathSegments.indexOf('shorts');
      if (index != -1 && uri.pathSegments.length > index + 1) {
        videoId = uri.pathSegments[index + 1];
      }
    } else if (uri.pathSegments.contains('embed')) {
      final index = uri.pathSegments.indexOf('embed');
      if (index != -1 && uri.pathSegments.length > index + 1) {
        videoId = uri.pathSegments[index + 1];
      }
    }

    if (videoId == null || videoId.trim().isEmpty) {
      return null;
    }

    return 'https://www.youtube.com/embed/${videoId.trim()}';
  }

  Widget _buildMetaChip(String label, {required IconData icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: kPrimaryColor, size: 15),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.manrope(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event) {
    final title = event['title'] ?? 'Unnamed Event';
    final thumbnail = event['thumbnail'];
    final dateStr = event['date'];
    final isPast = event['is_past'] == true;

    DateTime? date;
    if (dateStr != null) {
      date = DateTime.tryParse(dateStr);
    }

    return GestureDetector(
      onTap: () {
        context.push('/event-details/${event['id']}');
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        height: 100,
        decoration: BoxDecoration(
          color: kCardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            // Thumbnail
            SizedBox(
              width: 100,
              height: 100,
              child: thumbnail != null
                  ? CachedNetworkImage(
                      imageUrl: AppUrls.getEventThumbnailUrl(thumbnail) ?? '',
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: kPrimaryColor,
                        ),
                      ),
                      errorWidget: (_, _, _) => Container(
                        color: Colors.white12,
                        child: const Icon(Icons.image, color: Colors.white38),
                      ),
                    )
                  : Container(
                      color: Colors.white12,
                      child: const Icon(Icons.image, color: Colors.white38),
                    ),
            ),

            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    if (date != null)
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: kPrimaryColor,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat('MMM d, yyyy').format(date),
                            style: GoogleFonts.manrope(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          if (isPast) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white12,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Past',
                                style: GoogleFonts.inter(
                                  color: Colors.white54,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleStat(String value, String label) {
    final palette = context.dutyTheme;
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            color: palette.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.manrope(
            color: palette.textSecondary,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildFollowButton({
    required bool isFollowing,
    required bool hasPendingRequest,
    required VoidCallback onFollow,
    required VoidCallback onUnfollow,
  }) {
    final palette = context.dutyTheme;
    if (isFollowing) {
      return ElevatedButton(
        onPressed: onUnfollow,
        style: ElevatedButton.styleFrom(
          backgroundColor: palette.surface.withValues(alpha: 0.82),
          foregroundColor: palette.textPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
        child: const Text('Following'),
      );
    } else if (hasPendingRequest) {
      return ElevatedButton(
        onPressed: onUnfollow,
        style: ElevatedButton.styleFrom(
          backgroundColor: palette.surface.withValues(alpha: 0.82),
          foregroundColor: palette.textPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
        child: const Text('Requested'),
      );
    } else {
      return ElevatedButton(
        onPressed: onFollow,
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimaryColor,
          foregroundColor: palette.onPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
        child: const Text('Follow'),
      );
    }
  }

  Future<void> _handleFollow(int targetId) async {
    final success = await ref
        .read(followActionProvider.notifier)
        .follow('artist', targetId);
    if (success != null && success['success'] == true) {
      _fetchProfile();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to follow artist')),
        );
      }
    }
  }

  Future<void> _handleUnfollow(int targetId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kCardColor,
        title: Text(
          'Unfollow?',
          style: GoogleFonts.plusJakartaSans(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to unfollow this artist?',
          style: GoogleFonts.manrope(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.manrope(color: Colors.white54),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Unfollow',
              style: GoogleFonts.manrope(color: kDangerColor),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final success = await ref
        .read(followActionProvider.notifier)
        .unfollow('artist', targetId);
    if (success) {
      _fetchProfile();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to unfollow artist')),
        );
      }
    }
  }

  Future<void> _startArtistChat(int targetId) async {
    final chat = await ref
        .read(chatActionProvider.notifier)
        .startChat(targetId: targetId, targetType: 'artist');
    if (!mounted) return;

    if (chat != null) {
      context.push('/chat-room', extra: chat);
      return;
    }

    final error = ref.read(chatActionProvider.notifier).lastError;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error ?? 'Failed to start chat. Are you logged in?'),
        backgroundColor: kDangerColor,
      ),
    );
  }

  Future<void> _openExternalLink(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      return;
    }

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  String _normalizeSocialUrl(String value, String kind) {
    final trimmed = value.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }

    final clean = trimmed.startsWith('@') ? trimmed.substring(1) : trimmed;
    switch (kind) {
      case 'instagram':
        return 'https://instagram.com/$clean';
      case 'facebook':
        return 'https://facebook.com/$clean';
      case 'tiktok':
        return clean.startsWith('www.') || clean.contains('tiktok.com/')
            ? 'https://$clean'
            : 'https://www.tiktok.com/@$clean';
      case 'spotify':
        return clean.contains('spotify.com/')
            ? 'https://$clean'.replaceFirst('https://https://', 'https://')
            : 'https://open.spotify.com/$clean';
      case 'soundcloud':
        return clean.contains('soundcloud.com/')
            ? 'https://$clean'.replaceFirst('https://https://', 'https://')
            : 'https://soundcloud.com/$clean';
      case 'youtube':
        return clean.contains('youtube.com/') ||
                clean.contains('youtu.be/') ||
                clean.contains('youtube.com/@')
            ? 'https://$clean'.replaceFirst('https://https://', 'https://')
            : 'https://youtube.com/@$clean';
      default:
        return trimmed;
    }
  }
}

class _ArtistMediaAction {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color accent;
  final String externalUrl;
  final String? embedUrl;

  const _ArtistMediaAction({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.accent,
    required this.externalUrl,
    this.embedUrl,
  });
}
