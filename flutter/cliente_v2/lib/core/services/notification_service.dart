import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:duty_client/core/constants/app_urls.dart';
import 'package:duty_client/features/auth/presentation/providers/auth_provider.dart';
import 'package:duty_client/features/chat/presentation/providers/chat_provider.dart';
import 'package:duty_client/features/profile/presentation/providers/marketplace_provider.dart';
import 'package:duty_client/features/profile/presentation/providers/review_prompt_provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:duty_client/core/routes/app_router.dart';
import 'package:duty_client/core/utils/app_logger.dart';

final notificationProvider = Provider((ref) => NotificationNotifier(ref));

class NotificationNotifier {
  final Ref _ref;
  late final FirebaseMessaging _fcm;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

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
      appLog('NotificationService: Firebase not initialized. Skipping.');
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
            appLog(
              'NotificationService: Waiting for APNS token... ($retryCount)',
            );
          }
        }
        if (apnsToken == null) {
          appLog(
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
        appLog('NotificationService: Error getting FCM token: $e');
      }
    }

    // Listen for token refreshes
    _fcm.onTokenRefresh.listen(_registerToken);

    // Listen for user changes to re-register token (e.g., after login)
    _ref.listen<Map<String, dynamic>?>(currentUserProvider, (
      previous,
      next,
    ) async {
      if (next != null && next['id'] != previous?['id']) {
        appLog(
          'NotificationService: User changed, re-registering FCM token...',
        );
        try {
          String? token = await _fcm.getToken();
          if (token != null) {
            await _registerToken(token);
          }
        } catch (e) {
          appLog('NotificationService: Error re-registering token: $e');
        }
      }
    });

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
    }
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
      appLog('Firebase Token Registration Error: $e');
    }
  }
}
