import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:duty_client/core/constants/app_urls.dart';
import 'package:duty_client/features/auth/presentation/providers/auth_provider.dart';
import 'package:duty_client/features/chat/presentation/providers/chat_provider.dart';
import 'package:duty_client/features/events/presentation/providers/event_details_provider.dart';
import 'package:duty_client/features/events/presentation/providers/professional_event_provider.dart';
import 'package:duty_client/features/profile/presentation/providers/profile_provider.dart';
import 'package:duty_client/features/profile/presentation/providers/marketplace_provider.dart';
import 'package:duty_client/features/profile/presentation/providers/review_prompt_provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:duty_client/core/routes/app_router.dart';
import 'package:duty_client/core/utils/app_logger.dart';

final notificationProvider = Provider((ref) => NotificationNotifier(ref));

class NotificationNotifier {
  final Ref _ref;
  late final FirebaseMessaging _fcm;

  NotificationNotifier(this._ref);

  Future<void> initialize() async {
    // 1. Initialize Local Notifications for foreground alerts
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        final payload = response.payload;
        if (payload != null && payload.startsWith('chat:')) {
          final chatId = payload.split(':')[1];
          _ref.read(appRouterProvider).push('/chat-room?id=$chatId');
        } else if (payload != null && payload.startsWith('transfer:')) {
          final transferId = payload.split(':')[1];
          _ref.invalidate(pendingTransfersProvider);
          _ref.invalidate(outboxTransfersProvider);
          _ref.read(appRouterProvider).push('/transfer-requests/$transferId');
        } else if (payload == 'reviews:pending') {
          _ref.invalidate(pendingReviewPromptsProvider);
          _ref.read(appRouterProvider).push('/reviews/pending');
        } else if (payload != null && payload.startsWith('event-review:')) {
          _handleEventReviewPayload(payload);
        } else if (payload != null && payload.startsWith('event-waitlist:')) {
          _handleWaitlistPayload(payload);
        } else if (payload != null &&
            payload.startsWith('collaboration-auto-release:')) {
          _handleCollaborationAutoReleasePayload(payload);
        }
      },
    );

    // 2. Setup Android Channel for High Importance
    if (Platform.isAndroid) {
      const AndroidNotificationChannel chatChannel = AndroidNotificationChannel(
        'chat_messages',
        'Mensajes de Chat',
        description: 'Notificaciones de nuevos mensajes de chat',
        importance: Importance.max,
      );
      const AndroidNotificationChannel updatesChannel =
          AndroidNotificationChannel(
            'duty_updates',
            'Actualizaciones de Duty',
            description: 'Prompts de reviews y actualizaciones del ecosistema',
            importance: Importance.high,
          );

      await _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(chatChannel);
      await _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(updatesChannel);
    }

    // 3. Double check if Firebase is initialized
    if (Firebase.apps.isEmpty) {
      print('NotificationService: Firebase not initialized. Skipping.');
      return;
    }

    _fcm = FirebaseMessaging.instance;

    // Request permissions for iOS
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // On iOS, we need to wait for the APNS token to be available before getting the FCM token
      if (Platform.isIOS) {
        String? apnsToken;
        int retryCount = 0;
        while (apnsToken == null && retryCount < 10) {
          apnsToken = await _fcm.getAPNSToken();
          if (apnsToken == null) {
            await Future.delayed(const Duration(seconds: 1));
            retryCount++;
            print(
              'NotificationService: Waiting for APNS token... ($retryCount)',
            );
          }
        }
        if (apnsToken == null) {
          print(
            'NotificationService: APNS token not set. Check Xcode/Firebase config.',
          );
          return;
        }
      }

      try {
        String? token = await _fcm.getToken();
        if (token != null) {
          await _registerToken(token);
        }
      } catch (e) {
        print('NotificationService: Error getting FCM token: $e');
      }
    }

    // Listen for token refreshes
    _fcm.onTokenRefresh.listen(_registerToken);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      appLog('Foreground Message Received: ${message.notification?.title}');

      // If it's a chat message, refresh the unread count and chat list immediately
      final String? type = message.data['type'];
      if (type == 'chat') {
        appLog('Chat message detected, refreshing providers...');
        _ref.invalidate(unreadCountProvider);
        _ref.invalidate(allChatsProvider);

        final String? chatIdStr = message.data['chat_id'];
        if (chatIdStr != null) {
          final chatId = int.tryParse(chatIdStr);
          if (chatId != null) {
            appLog('Refreshing messages for chat: $chatId');
            _ref.invalidate(chatMessagesProvider(chatId));
          }
        }

        // Show local notification for foreground alert
        if (message.notification != null) {
          _localNotifications.show(
            message.hashCode,
            message.notification?.title,
            message.notification?.body,
            const NotificationDetails(
              android: AndroidNotificationDetails(
                'chat_messages',
                'Mensajes de Chat',
                channelDescription: 'Notificaciones de nuevos mensajes de chat',
                importance: Importance.max,
                priority: Priority.high,
                showWhen: true,
              ),
              iOS: DarwinNotificationDetails(
                presentAlert: true,
                presentBadge: true,
                presentSound: true,
              ),
            ),
            payload: 'chat:${message.data['chat_id']}',
          );
        }
      } else if (type == 'review_prompt') {
        _ref.invalidate(pendingReviewPromptsProvider);

        if (message.notification != null) {
          _localNotifications.show(
            message.hashCode,
            message.notification?.title,
            message.notification?.body,
            const NotificationDetails(
              android: AndroidNotificationDetails(
                'duty_updates',
                'Actualizaciones de Duty',
                channelDescription:
                    'Prompts de reviews y actualizaciones del ecosistema',
                importance: Importance.high,
                priority: Priority.high,
                showWhen: true,
              ),
              iOS: DarwinNotificationDetails(
                presentAlert: true,
                presentBadge: true,
                presentSound: true,
              ),
            ),
            payload: 'reviews:pending',
          );
        }
      } else if (type == 'transfer_request' ||
          type == 'transfer_accepted' ||
          type == 'transfer_rejected' ||
          type == 'transfer_cancelled') {
        _ref.invalidate(pendingTransfersProvider);
        _ref.invalidate(outboxTransfersProvider);

        if (message.notification != null) {
          final transferId = message.data['transfer_id']?.toString();
          _localNotifications.show(
            message.hashCode,
            message.notification?.title,
            message.notification?.body,
            const NotificationDetails(
              android: AndroidNotificationDetails(
                'duty_updates',
                'Actualizaciones de Duty',
                channelDescription:
                    'Prompts de reviews y actualizaciones del ecosistema',
                importance: Importance.high,
                priority: Priority.high,
                showWhen: true,
              ),
              iOS: DarwinNotificationDetails(
                presentAlert: true,
                presentBadge: true,
                presentSound: true,
              ),
            ),
            payload: transferId != null ? 'transfer:$transferId' : null,
          );
        }
      } else if (type == 'event_review_status') {
        _ref.invalidate(professionalDashboardProvider);

        if (message.notification != null) {
          final eventId = message.data['event_id']?.toString() ?? '';
          final identityId = message.data['identity_id']?.toString() ?? '';
          final payload = 'event-review:$eventId:$identityId';
          _localNotifications.show(
            message.hashCode,
            message.notification?.title,
            message.notification?.body,
            const NotificationDetails(
              android: AndroidNotificationDetails(
                'duty_updates',
                'Actualizaciones de Duty',
                channelDescription:
                    'Prompts de reviews y actualizaciones del ecosistema',
                importance: Importance.high,
                priority: Priority.high,
                showWhen: true,
              ),
              iOS: DarwinNotificationDetails(
                presentAlert: true,
                presentBadge: true,
                presentSound: true,
              ),
            ),
            payload: payload,
          );
        }
      } else if (type == 'event_waitlist_update') {
        final eventId = message.data['event_id']?.toString() ?? '';
        if (message.notification != null) {
          _localNotifications.show(
            message.hashCode,
            message.notification?.title,
            message.notification?.body,
            const NotificationDetails(
              android: AndroidNotificationDetails(
                'duty_updates',
                'Actualizaciones de Duty',
                channelDescription:
                    'Prompts de reviews y actualizaciones del ecosistema',
                importance: Importance.high,
                priority: Priority.high,
                showWhen: true,
              ),
              iOS: DarwinNotificationDetails(
                presentAlert: true,
                presentBadge: true,
                presentSound: true,
              ),
            ),
            payload: eventId.isNotEmpty ? 'event-waitlist:$eventId' : null,
          );
        }
      } else if (type == 'collaboration_auto_release') {
        _ref.invalidate(professionalCollaborationsProvider);
        _ref.invalidate(professionalDashboardProvider);

        if (message.notification != null) {
          final earningId = message.data['earning_id']?.toString() ?? '';
          final eventId = message.data['event_id']?.toString() ?? '';
          final identityId = message.data['identity_id']?.toString() ?? '';
          final payload =
              'collaboration-auto-release:$earningId:$eventId:$identityId';

          _localNotifications.show(
            message.hashCode,
            message.notification?.title,
            message.notification?.body,
            const NotificationDetails(
              android: AndroidNotificationDetails(
                'duty_updates',
                'Actualizaciones de Duty',
                channelDescription:
                    'Prompts de reviews y actualizaciones del ecosistema',
                importance: Importance.high,
                priority: Priority.high,
                showWhen: true,
              ),
              iOS: DarwinNotificationDetails(
                presentAlert: true,
                presentBadge: true,
                presentSound: true,
              ),
            ),
            payload: payload,
          );
        }
      }
    });

    // Handle background/terminated state notification taps
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationClick(message);
    });

    // Handle app opening from terminated state
    _fcm.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        _handleNotificationClick(message);
      }
    });
  }

  void _handleNotificationClick(RemoteMessage message) {
    final String? type = message.data['type'];
    final String? chatId = message.data['chat_id'];

    if (type == 'chat' && chatId != null) {
      _ref.read(appRouterProvider).push('/chat-room?id=$chatId');
      return;
    }

    if (type == 'transfer_request' ||
        type == 'transfer_accepted' ||
        type == 'transfer_rejected' ||
        type == 'transfer_cancelled') {
      final transferId = message.data['transfer_id']?.toString();
      _ref.invalidate(pendingTransfersProvider);
      _ref.invalidate(outboxTransfersProvider);
      if (transferId != null && transferId.isNotEmpty) {
        _ref.read(appRouterProvider).push('/transfer-requests/$transferId');
      } else {
        _ref.read(appRouterProvider).push('/pending-transfers');
      }
      return;
    }

    if (type == 'review_prompt') {
      _ref.invalidate(pendingReviewPromptsProvider);
      _ref.read(appRouterProvider).push('/reviews/pending');
      return;
    }

    if (type == 'event_review_status') {
      _ref.invalidate(professionalDashboardProvider);
      final eventId = message.data['event_id']?.toString();
      final identityId = message.data['identity_id']?.toString();
      _openEventReviewDestination(eventId: eventId, identityId: identityId);
      return;
    }

    if (type == 'event_waitlist_update') {
      final eventId = message.data['event_id']?.toString();
      _openWaitlistDestination(eventId);
      return;
    }

    if (type == 'collaboration_auto_release') {
      final eventId = message.data['event_id']?.toString();
      final identityId = message.data['identity_id']?.toString();
      _openCollaborationDestination(eventId: eventId, identityId: identityId);
    }
  }

  void _handleEventReviewPayload(String payload) {
    final parts = payload.split(':');
    final eventId = parts.length > 1 ? parts[1] : null;
    final identityId = parts.length > 2 ? parts[2] : null;
    _ref.invalidate(professionalDashboardProvider);
    _openEventReviewDestination(eventId: eventId, identityId: identityId);
  }

  void _handleWaitlistPayload(String payload) {
    final parts = payload.split(':');
    final eventId = parts.length > 1 ? parts[1] : null;
    _openWaitlistDestination(eventId);
  }

  void _handleCollaborationAutoReleasePayload(String payload) {
    final parts = payload.split(':');
    final eventId = parts.length > 2 ? parts[2] : null;
    final identityId = parts.length > 3 ? parts[3] : null;
    _openCollaborationDestination(eventId: eventId, identityId: identityId);
  }

  void _openEventReviewDestination({String? eventId, String? identityId}) {
    Future(() async {
      if (identityId != null && identityId.isNotEmpty) {
        try {
          await _ref.read(profileControllerProvider).switchProfile(identityId);
        } catch (e) {
          appLog(
            'NotificationService: failed to switch profile for event review: $e',
          );
        }
      }

      final router = _ref.read(appRouterProvider);
      if (eventId != null && eventId.isNotEmpty) {
        router.push('/professional/events/$eventId/edit');
      } else {
        router.push('/professional/events');
      }
    });
  }

  void _openWaitlistDestination(String? eventId) {
    Future(() {
      final parsedId = int.tryParse(eventId ?? '');
      if (parsedId != null) {
        _ref.invalidate(eventDetailsProvider(parsedId));
        _ref.read(appRouterProvider).push('/event-details/$parsedId');
      } else {
        _ref.read(appRouterProvider).push('/search');
      }
    });
  }

  void _openCollaborationDestination({String? eventId, String? identityId}) {
    Future(() async {
      if (identityId != null && identityId.isNotEmpty) {
        try {
          await _ref.read(profileControllerProvider).switchProfile(identityId);
        } catch (e) {
          appLog(
            'NotificationService: failed to switch profile for collaboration payout: $e',
          );
        }
      }

      _ref.invalidate(professionalCollaborationsProvider);
      _ref.invalidate(professionalDashboardProvider);

      final parsedEventId = int.tryParse(eventId ?? '');
      if (parsedEventId != null) {
        _ref.invalidate(professionalEventInventoryProvider(parsedEventId));
      }

      _ref.read(appRouterProvider).push('/professional/collaborations');
    });
  }

  Future<void> _registerToken(String token) async {
    final apiClient = _ref.read(apiClientProvider);
    final userId = _ref.read(currentUserProvider)?['id'];

    try {
      await apiClient.dio.post(
        AppUrls.saveFcmToken,
        data: {
          'token': token,
          'user_id': userId,
          'platform': Platform.isAndroid ? 'android' : 'ios',
        },
      );
    } catch (e) {
      print('Firebase Token Registration Error: $e');
    }
  }
}
