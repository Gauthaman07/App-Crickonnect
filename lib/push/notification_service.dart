// lib/services/notification_service.dart

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import '../main.dart'; // for navigatorKey

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // This runs when the app is in background or terminated
  print('🕑 Background message: ${message.messageId}');
}

class NotificationService {
  static final FirebaseMessaging _fm = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _ln =
      FlutterLocalNotificationsPlugin();

  /// Call this once in main() after Firebase.initializeApp()
  static Future<void> initializeFirebaseMessaging() async {
    // 1️⃣ Background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 2️⃣ Set up local notifications
    await _initLocalNotifications();

    // 3️⃣ Foreground messages → show a local notification
    FirebaseMessaging.onMessage.listen((RemoteMessage msg) {
      final notification = msg.notification;
      final type = msg.data['type'];
      if (notification != null) {
        _ln.show(
          msg.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              'booking_channel', // channel id
              'Booking Notifications', // channel name
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
          payload: type, // carry the notification type
        );
      }
    });

    // 4️⃣ App opened from terminated state by tapping a notification
    final initialMsg = await _fm.getInitialMessage();
    if (initialMsg != null) {
      _handleNavigation(initialMsg.data['type'], initialMsg.data);
    }

    // 5️⃣ App resumed (in background) by tapping a notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage msg) {
      _handleNavigation(msg.data['type'], msg.data);
    });
  }

  /// Internal: configure flutter_local_notifications
  static Future<void> _initLocalNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _ln.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse resp) {
        // User tapped the local notification
        _handleNavigation(resp.payload, {});
      },
    );
  }

  /// Routes based on `type` field in the FCM data payload
  static void _handleNavigation(String? type, Map<String, dynamic> data) {
    if (type == null) return;

    switch (type) {
      case 'new_booking_request':
        navigatorKey.currentState?.pushNamed(
          '/bookingrequests',
          arguments: data,
        );
        break;

      // add more cases here for other notification types
      default:
        print('⚠️ Unhandled notification type: $type');
    }
  }

  /// Request permission for iOS / web
  static Future<void> requestNotificationPermissions() async {
    final settings = await _fm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    print('🔔 Notification permission: ${settings.authorizationStatus}');
  }

  /// Retrieve the current FCM token
  static Future<String?> getFcmToken() async {
    try {
      final token = await _fm.getToken();
      print('✉️ FCM Token: $token');
      return token;
    } catch (e) {
      print('❌ Error fetching FCM token: $e');
      return null;
    }
  }

  /// Listen for token refresh events
  static void setupTokenRefreshListener(Function(String) onTokenRefresh) {
    _fm.onTokenRefresh.listen(onTokenRefresh);
  }
}
