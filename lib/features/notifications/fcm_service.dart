import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import '../../core/utils/analytics.dart';
import '../../core/utils/notification_handler.dart';
import '../../main.dart';
import 'notification_screen.dart';

enum NotificationType { product, order, promotion, lookbook, general }

@pragma('vm:entry-point')
Future<void> _handleBackground(RemoteMessage message) async {
  // Background handler: called even when app is terminated.
  // Store notification for later display.
  await storeNotification(NotificationItem(
    id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
    title: message.notification?.title ?? 'Pashtun Collections',
    body: message.notification?.body ?? '',
    type: message.data['type'] as String? ?? 'general',
    dataId: message.data['id'] as String?,
    receivedAt: DateTime.now(),
    isRead: false,
  ));
}

class FCMService {
  FCMService._();

  static final _messaging = FirebaseMessaging.instance;

  static Future<void> init(BuildContext context) async {
    // Request permission
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Background handler
    FirebaseMessaging.onBackgroundMessage(_handleBackground);

    // Foreground handler
    FirebaseMessaging.onMessage.listen((message) {
      _handleForeground(message, context);
    });

    // App opened via notification (from background/terminated)
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      _handleTap(message, context);
    });

    // Check if app was launched from a notification
    final initial = await _messaging.getInitialMessage();
    if (initial != null) {
      _handleTap(initial, context);
    }

    // Create notification channel for Android
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  static void _handleForeground(RemoteMessage message, BuildContext context) {
    // Store to Hive
    storeNotification(NotificationItem(
      id:
          message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: message.notification?.title ?? 'Pashtun Collections',
      body: message.notification?.body ?? '',
      type: message.data['type'] as String? ?? 'general',
      dataId: message.data['id'] as String?,
      receivedAt: DateTime.now(),
      isRead: false,
    ));

    Analytics.notificationTapped(
      notificationType: message.data['type'] as String? ?? 'general',
      notificationId: message.messageId,
    );

    // Show in-app snack bar
    if (navigatorKey.currentContext != null) {
      ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
        SnackBar(
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message.notification?.title ?? 'New Notification',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.white),
              ),
              if (message.notification?.body != null)
                Text(message.notification!.body!,
                    style: const TextStyle(color: Colors.white70)),
            ],
          ),
          action: SnackBarAction(
            label: 'View',
            textColor: const Color(0xFFC8860A),
            onPressed: () => _handleTap(message, context),
          ),
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  static void _handleTap(RemoteMessage message, BuildContext context) {
    Analytics.notificationTapped(
      notificationType: message.data['type'] as String? ?? 'general',
      notificationId: message.messageId,
    );

    final ctx = navigatorKey.currentContext ?? context;
    NotificationHandler.handleTap(ctx, message.data);
  }
}
