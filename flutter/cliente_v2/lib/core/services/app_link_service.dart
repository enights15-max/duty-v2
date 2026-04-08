import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../routes/app_router.dart';

class AppLinkListener extends ConsumerStatefulWidget {
  final Widget child;

  const AppLinkListener({super.key, required this.child});

  @override
  ConsumerState<AppLinkListener> createState() => _AppLinkListenerState();
}

class _AppLinkListenerState extends ConsumerState<AppLinkListener> {
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _subscription;
  String? _lastHandledUri;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_initializeLinks());
    });
  }

  Future<void> _initializeLinks() async {
    await _handleInitialUri();

    try {
      _subscription = _appLinks.uriLinkStream.listen(
        _handleUri,
        onError: (_) {
          // Beta-safe: ignore stream errors and keep the app usable.
        },
      );
    } on MissingPluginException {
      // Plugin not available in the currently running binary.
      // A full restart will pick it up after dependency changes.
    } on PlatformException {
      // Keep startup resilient in environments where link listeners are unavailable.
    }
  }

  Future<void> _handleInitialUri() async {
    try {
      final uri = await _appLinks.getInitialLink();
      if (uri != null) {
        _handleUri(uri);
      }
    } on MissingPluginException {
      // Plugin not available in the current runtime yet.
    } on PlatformException {
      // Unsupported platform/runtime. Safe to ignore in beta.
    } catch (_) {
      // Keep startup resilient in beta; a bad link should not crash the app.
    }
  }

  void _handleUri(Uri uri) {
    final raw = uri.toString();
    if (raw.isEmpty || raw == _lastHandledUri) {
      return;
    }

    final eventId = AppLinkParser.eventIdFromUri(uri);
    if (eventId == null || eventId <= 0) {
      return;
    }

    _lastHandledUri = raw;
    ref.read(appRouterProvider).go('/event-details/$eventId');
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class AppLinkParser {
  AppLinkParser._();

  static int? eventIdFromUri(Uri uri) {
    final queryId =
        _parseInt(uri.queryParameters['event_id']) ??
        _parseInt(uri.queryParameters['event']);
    if (queryId != null && queryId > 0) {
      return queryId;
    }

    final segments = uri.pathSegments
        .where((segment) => segment.isNotEmpty)
        .toList();

    if (uri.scheme == 'duty' && uri.host == 'event') {
      if (segments.isNotEmpty) {
        return _parseInt(segments.first);
      }
    }

    final openEventIndex = _indexOfSegmentSequence(segments, const [
      'open',
      'event',
    ]);
    if (openEventIndex != null && segments.length > openEventIndex + 2) {
      return _parseInt(segments[openEventIndex + 2]);
    }

    final eventDetailsIndex = _indexOfSegmentSequence(segments, const [
      'event-details',
    ]);
    if (eventDetailsIndex != null && segments.length > eventDetailsIndex + 1) {
      return _parseInt(segments[eventDetailsIndex + 1]);
    }

    final eventIndex = _indexOfSegmentSequence(segments, const ['event']);
    if (eventIndex != null && segments.length > eventIndex + 1) {
      final tail = _parseInt(segments.last);
      if (tail != null && tail > 0) {
        return tail;
      }
    }

    return null;
  }

  static int? transferRecipientIdFromUri(Uri uri) {
    final queryId = _parseInt(uri.queryParameters['recipient_id']);
    if (queryId != null && queryId > 0) {
      return queryId;
    }

    final segments = uri.pathSegments
        .where((segment) => segment.isNotEmpty)
        .toList();

    if (uri.scheme == 'duty' && uri.host == 'transfer-recipient') {
      if (segments.isNotEmpty) {
        return _parseInt(segments.first);
      }
    }

    final transferIndex = _indexOfSegmentSequence(segments, const [
      'open',
      'transfer-recipient',
    ]);
    if (transferIndex != null && segments.length > transferIndex + 2) {
      return _parseInt(segments[transferIndex + 2]);
    }

    return null;
  }

  static String? transferTicketTokenFromUri(Uri uri) {
    final queryToken = uri.queryParameters['token']?.trim();
    if (queryToken != null && queryToken.isNotEmpty) {
      return queryToken;
    }

    final segments = uri.pathSegments
        .where((segment) => segment.isNotEmpty)
        .toList();

    if (uri.scheme == 'duty' && uri.host == 'transfer-ticket') {
      if (segments.isNotEmpty && segments.first.trim().isNotEmpty) {
        return segments.first.trim();
      }
      return null;
    }

    final transferIndex = _indexOfSegmentSequence(segments, const [
      'open',
      'transfer-ticket',
    ]);
    if (transferIndex != null && segments.length > transferIndex + 2) {
      final token = segments[transferIndex + 2].trim();
      if (token.isNotEmpty) {
        return token;
      }
    }

    return null;
  }

  static int? _indexOfSegmentSequence(
    List<String> segments,
    List<String> needle,
  ) {
    if (needle.isEmpty || segments.length < needle.length) {
      return null;
    }

    for (var i = 0; i <= segments.length - needle.length; i++) {
      var matches = true;
      for (var j = 0; j < needle.length; j++) {
        if (segments[i + j] != needle[j]) {
          matches = false;
          break;
        }
      }
      if (matches) {
        return i;
      }
    }

    return null;
  }

  static int? _parseInt(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    return int.tryParse(value.trim());
  }
}
