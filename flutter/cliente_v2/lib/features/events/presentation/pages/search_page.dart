import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/constants/app_urls.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  DutyThemeTokens get _palette => context.dutyTheme;

  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _debounce;

  Map<String, List<dynamic>> _results = {};
  bool _isLoading = false;
  bool _hasSearched = false;
  final Set<int> _busyWaitlistEvents = <int>{};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (query.length >= 2) {
        _performSearch(query);
      } else {
        setState(() {
          _results = {};
          _hasSearched = false;
        });
      }
    });
  }

  Future<void> _performSearch(String query) async {
    setState(() => _isLoading = true);

    try {
      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.dio.get(
        AppUrls.search,
        queryParameters: {'q': query},
        options: Options(
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode == 200) {
        final json = _asMap(response.data);
        if (json['success'] == true) {
          final data = json['data'] as Map<String, dynamic>;
          if (!mounted) return;
          setState(() {
            _results = {
              'events': List<dynamic>.from(data['events'] ?? []),
              'artists': List<dynamic>.from(data['artists'] ?? []),
              'venues': List<dynamic>.from(data['venues'] ?? []),
              'organizers': List<dynamic>.from(data['organizers'] ?? []),
              'users': List<dynamic>.from(data['users'] ?? []),
            };
            _hasSearched = true;
            _isLoading = false;
          });
          return;
        }
      }
    } catch (_) {}

    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _hasSearched = true;
    });
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

  int get _totalResults {
    int count = 0;
    _results.forEach((_, list) => count += list.length);
    return count;
  }

  bool _canWaitlistFromResult(Map<String, dynamic> item) =>
      item['type'] == 'event' &&
      ((item['show_waitlist_cta'] == true) ||
          (item['show_waitlist_cta'] == null &&
              item['availability_state']?.toString() == 'sold_out' &&
              item['show_marketplace_fallback'] != true));

  bool _waitlistSubscribed(Map<String, dynamic> item) =>
      item['viewer_waitlist_subscribed'] == true;

  int _waitlistCount(Map<String, dynamic> item) =>
      int.tryParse(item['waitlist_count']?.toString() ?? '0') ?? 0;

  void _updateSearchEventState(
    int eventId, {
    required bool subscribed,
    required int waitlistCount,
  }) {
    setState(() {
      final updated = <String, List<dynamic>>{};
      _results.forEach((key, list) {
        updated[key] = list.map((entry) {
          if (entry is Map<String, dynamic> &&
              entry['type'] == 'event' &&
              int.tryParse(entry['id']?.toString() ?? '') == eventId) {
            return {
              ...entry,
              'viewer_waitlist_subscribed': subscribed,
              'waitlist_count': waitlistCount,
            };
          }
          if (entry is Map &&
              entry['type'] == 'event' &&
              int.tryParse(entry['id']?.toString() ?? '') == eventId) {
            return {
              ...Map<String, dynamic>.from(entry),
              'viewer_waitlist_subscribed': subscribed,
              'waitlist_count': waitlistCount,
            };
          }
          return entry;
        }).toList();
      });
      _results = updated;
    });
  }

  Future<void> _toggleWaitlistFromSearch(Map<String, dynamic> item) async {
    final eventId = int.tryParse(item['id']?.toString() ?? '');
    if (eventId == null || _busyWaitlistEvents.contains(eventId)) return;

    final apiClient = ref.read(apiClientProvider);
    if (!apiClient.hasToken) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Inicia sesión para unirte a la waitlist y enterarte si reaparecen entradas.',
          ),
        ),
      );
      context.push('/login');
      return;
    }

    final currentValue = _waitlistSubscribed(item);
    final currentCount = _waitlistCount(item);
    final nextValue = !currentValue;
    final optimisticCount = nextValue
        ? currentCount + 1
        : (currentCount > 0 ? currentCount - 1 : 0);

    setState(() => _busyWaitlistEvents.add(eventId));
    _updateSearchEventState(
      eventId,
      subscribed: nextValue,
      waitlistCount: optimisticCount,
    );

    try {
      final response = nextValue
          ? await ref
                .read(apiClientProvider)
                .dio
                .post(AppUrls.eventWaitlist(eventId))
          : await ref
                .read(apiClientProvider)
                .dio
                .delete(AppUrls.eventWaitlist(eventId));

      final payload = response.data;
      final data = payload is Map<String, dynamic>
          ? payload['data']
          : payload is Map
          ? Map<String, dynamic>.from(payload)['data']
          : null;

      if (data is Map) {
        final normalized = Map<String, dynamic>.from(data);
        _updateSearchEventState(
          eventId,
          subscribed: normalized['viewer_waitlist_subscribed'] == true,
          waitlistCount:
              int.tryParse(normalized['waitlist_count']?.toString() ?? '0') ??
              0,
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            response.data is Map && response.data['message'] != null
                ? response.data['message'].toString()
                : nextValue
                ? 'Te avisaremos si reaparecen entradas para este evento.'
                : 'Ya no estás en la waitlist de este evento.',
          ),
        ),
      );
    } on DioException catch (error) {
      final payload = error.response?.data;
      final message = payload is Map && payload['message'] != null
          ? payload['message'].toString()
          : 'No pudimos actualizar la waitlist ahora mismo.';
      _updateSearchEventState(
        eventId,
        subscribed: currentValue,
        waitlistCount: currentCount,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (_) {
      _updateSearchEventState(
        eventId,
        subscribed: currentValue,
        waitlistCount: currentCount,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No pudimos actualizar la waitlist ahora mismo.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _busyWaitlistEvents.remove(eventId));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = _palette;
    return Scaffold(
      backgroundColor: palette.background,
      body: SafeArea(
        child: Column(
          children: [
            // Search header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: palette.surfaceAlt,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: palette.border),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios_new,
                        color: palette.textPrimary,
                        size: 18,
                      ),
                      onPressed: () => context.pop(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: palette.surfaceAlt,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: _focusNode.hasFocus
                              ? palette.primary.withValues(alpha: 0.36)
                              : palette.border,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: palette.shadow.withValues(alpha: 0.12),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        style: GoogleFonts.outfit(
                          color: palette.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        onChanged: _onSearchChanged,
                        decoration: InputDecoration(
                          hintText: 'Search events, artists, venues...',
                          hintStyle: GoogleFonts.outfit(
                            color: palette.textMuted,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 16,
                          ),
                          prefixIcon: const Padding(
                            padding: EdgeInsets.only(left: 8),
                            child: Icon(
                              Icons.search_rounded,
                              color: kPrimaryColor,
                              size: 22,
                            ),
                          ),
                          suffixIcon: _controller.text.isNotEmpty
                              ? IconButton(
                                  icon: Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: palette.surface,
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Icon(
                                      Icons.close_rounded,
                                      color: palette.textMuted,
                                      size: 16,
                                    ),
                                  ),
                                  onPressed: () {
                                    _controller.clear();
                                    setState(() {
                                      _results = {};
                                      _hasSearched = false;
                                    });
                                  },
                                )
                              : null,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Results
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: kPrimaryColor,
                        strokeWidth: 2,
                      ),
                    )
                  : !_hasSearched
                  ? _buildEmptyState()
                  : _totalResults == 0
                  ? _buildNoResults()
                  : _buildResults(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final palette = _palette;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 56,
            color: palette.textMuted.withValues(alpha: 0.24),
          ),
          const SizedBox(height: 16),
          Text(
            'Search for anything',
            style: GoogleFonts.manrope(
              color: palette.textSecondary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Events, artists, venues, organizers, users',
            style: GoogleFonts.manrope(color: palette.textMuted, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResults() {
    final palette = _palette;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 56,
            color: palette.textMuted.withValues(alpha: 0.24),
          ),
          const SizedBox(height: 16),
          Text(
            'No results found',
            style: GoogleFonts.manrope(
              color: palette.textSecondary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try a different keyword',
            style: GoogleFonts.manrope(color: palette.textMuted, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    final double bottomContentInset =
        MediaQuery.of(context).padding.bottom + 132;
    return ListView(
      padding: EdgeInsets.fromLTRB(16, 0, 16, bottomContentInset),
      children: [
        if (_results['events']?.isNotEmpty == true)
          _buildSection('Events', Icons.event, _results['events']!),
        if (_results['artists']?.isNotEmpty == true)
          _buildSection('Artists', Icons.music_note, _results['artists']!),
        if (_results['venues']?.isNotEmpty == true)
          _buildSection('Venues', Icons.location_on, _results['venues']!),
        if (_results['organizers']?.isNotEmpty == true)
          _buildSection('Organizers', Icons.business, _results['organizers']!),
        if (_results['users']?.isNotEmpty == true)
          _buildSection('Users', Icons.person, _results['users']!),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSection(String title, IconData icon, List<dynamic> items) {
    final palette = _palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Icon(icon, color: kPrimaryColor, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.manrope(
                  color: palette.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: palette.primarySurface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${items.length}',
                  style: GoogleFonts.manrope(
                    color: kPrimaryColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        ...items.map((item) => _buildResultTile(item)),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildResultTile(Map<String, dynamic> item) {
    final palette = _palette;
    final type = item['type'] ?? '';
    final name = item['name'] ?? 'Unknown';
    final photo = item['photo'];
    final subtitle = _getSubtitle(item);
    final iconData = _getIconForType(type);
    final proofPills = _buildProofPills(item);
    final verified = _isVerifiedIdentity(item);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: palette.border),
        boxShadow: [
          BoxShadow(
            color: palette.shadow.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => _navigateToResult(item),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              photo != null && photo.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        photo,
                        width: 54,
                        height: 54,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) =>
                            _buildPlaceholderAvatar(name, iconData),
                      ),
                    )
                  : _buildPlaceholderAvatar(name, iconData),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: GoogleFonts.outfit(
                              color: palette.textPrimary,
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              height: 1.06,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (verified)
                          Padding(
                            padding: const EdgeInsets.only(left: 6),
                            child: Icon(
                              Icons.verified_rounded,
                              color: palette.primary,
                              size: 16,
                            ),
                          ),
                      ],
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: GoogleFonts.inter(
                          color: palette.textSecondary,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (proofPills.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Wrap(spacing: 6, runSpacing: 6, children: proofPills),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _buildTrailingBadge(item),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderAvatar(String name, IconData iconData) {
    final palette = _palette;
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: palette.primarySurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(child: Icon(iconData, color: palette.primary, size: 24)),
    );
  }

  Widget _buildTrailingBadge(Map<String, dynamic> item) {
    final palette = _palette;
    if (item['type'] == 'event' && item['is_past'] == true) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: palette.surfaceAlt,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          'Past',
          style: GoogleFonts.outfit(
            color: palette.textMuted,
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }
    if (_canWaitlistFromResult(item)) {
      final eventId = int.tryParse(item['id']?.toString() ?? '');
      final busy = eventId != null && _busyWaitlistEvents.contains(eventId);
      final subscribed = _waitlistSubscribed(item);

      return SizedBox(
        height: 34,
        child: ElevatedButton(
          onPressed: busy ? null : () => _toggleWaitlistFromSearch(item),
          style: ElevatedButton.styleFrom(
            backgroundColor: subscribed ? palette.success : palette.primary,
            foregroundColor: palette.onPrimary,
            disabledBackgroundColor: palette.surfaceMuted,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
            ),
            elevation: 0,
          ),
          child: Text(
            subscribed ? 'En waitlist' : 'Avísame',
            style: GoogleFonts.outfit(
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      );
    }
    if (item['type'] == 'event' && item['show_marketplace_fallback'] == true) {
      final count =
          int.tryParse(
            item['marketplace_available_count']?.toString() ?? '0',
          ) ??
          0;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFFFB84D).withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          '$count blackmarket',
          style: GoogleFonts.outfit(
            color: const Color(0xFFFFB84D),
            fontSize: 10.5,
            fontWeight: FontWeight.w800,
          ),
        ),
      );
    }
    return Icon(Icons.chevron_right, color: palette.textMuted, size: 20);
  }

  List<Widget> _buildProofPills(Map<String, dynamic> item) {
    final type = item['type']?.toString() ?? '';
    final followersCount =
        int.tryParse(item['followers_count']?.toString() ?? '0') ?? 0;
    final followingCount =
        int.tryParse(item['following_count']?.toString() ?? '0') ?? 0;
    final upcomingCount =
        int.tryParse(item['upcoming_events_count']?.toString() ?? '0') ?? 0;
    final reviewCount =
        int.tryParse(item['review_count']?.toString() ?? '0') ?? 0;
    final followsYou = item['follows_you'] == true;
    final mutualConnection = item['mutual_connection'] == true;

    final pills = <Widget>[];

    if (mutualConnection) {
      pills.add(_buildProofPill('Mutual', highlighted: true));
    } else if (followsYou) {
      pills.add(_buildProofPill('Follows you', highlighted: true));
    }

    if (followersCount > 0) {
      pills.add(_buildProofPill('$followersCount followers'));
    }

    if (type == 'user' && followingCount > 0) {
      pills.add(_buildProofPill('$followingCount following'));
    }

    if ((type == 'artist' || type == 'venue' || type == 'organizer') &&
        upcomingCount > 0) {
      pills.add(_buildProofPill('$upcomingCount upcoming'));
    }

    if ((type == 'artist' || type == 'venue' || type == 'organizer') &&
        reviewCount > 0) {
      pills.add(_buildProofPill('$reviewCount reviews'));
    }

    if (type == 'event' && _canWaitlistFromResult(item)) {
      final count = _waitlistCount(item);
      pills.add(
        _buildProofPill(
          count > 0 ? '$count en waitlist' : 'Sold out total',
          highlighted: true,
        ),
      );
    }

    if (type == 'event' && item['show_marketplace_fallback'] == true) {
      final count =
          int.tryParse(
            item['marketplace_available_count']?.toString() ?? '0',
          ) ??
          0;
      pills.add(_buildProofPill('$count en blackmarket', highlighted: true));
    }

    return pills;
  }

  Widget _buildProofPill(String label, {bool highlighted = false}) {
    final palette = _palette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: highlighted ? palette.primarySurface : palette.surfaceAlt,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: highlighted ? palette.borderStrong : palette.border,
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.outfit(
          color: highlighted ? palette.primary : palette.textSecondary,
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  bool _isVerifiedIdentity(Map<String, dynamic> item) {
    final identity = item['identity'];
    if (identity is Map<String, dynamic>) {
      return identity['is_verified'] == true;
    }
    if (identity is Map) {
      return identity['is_verified'] == true;
    }
    return false;
  }

  String? _getSubtitle(Map<String, dynamic> item) {
    final type = item['type'];
    if (type == 'user') return '@${item['username'] ?? ''}';
    if (type == 'event') return _formatSearchDate(item['date']);
    if (type == 'artist') return '@${item['username'] ?? ''}';
    if (type == 'venue') return item['city'];
    if (type == 'organizer') return item['city'];
    return null;
  }

  String? _formatSearchDate(dynamic rawDate) {
    if (rawDate == null) return null;
    if (rawDate is DateTime) {
      final local = rawDate.toLocal();
      return '${local.year.toString().padLeft(4, '0')}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
    }

    final value = rawDate.toString().trim();
    if (value.isEmpty) return null;
    final parsed = DateTime.tryParse(value);
    if (parsed == null) return value;
    final local = parsed.toLocal();
    return '${local.year.toString().padLeft(4, '0')}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'event':
        return Icons.event;
      case 'artist':
        return Icons.music_note;
      case 'venue':
        return Icons.location_on;
      case 'organizer':
        return Icons.business;
      case 'user':
        return Icons.person;
      default:
        return Icons.search;
    }
  }

  void _navigateToResult(Map<String, dynamic> item) {
    final type = item['type'];
    final id = item['id'];

    switch (type) {
      case 'event':
        context.push('/event-details/$id');
        break;
      case 'venue':
        context.push('/venue-profile/$id');
        break;
      case 'artist':
        context.push('/artist-profile/$id');
        break;
      case 'organizer':
        context.push('/organizer-profile/$id');
        break;
      case 'user':
        context.push('/user-profile/$id');
        break;
    }
  }
}
