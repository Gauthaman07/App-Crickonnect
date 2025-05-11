import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

// Background message handler - must be top-level function
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you need the Firebase instance in the background handler,
  // you would initialize it here
  // await Firebase.initializeApp();

  print("Handling a background message: ${message.messageId}");
  // Handle background message
}

class NotificationService {
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;

  // Initialize Firebase Messaging
  static Future<void> initializeFirebaseMessaging() async {
    // Set up background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle messages when the app is in the foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification:');
        print('Title: ${message.notification!.title}');
        print('Body: ${message.notification!.body}');
      }

      // Here you would typically show a local notification
      // using flutter_local_notifications package
    });

    // Handle when a user taps on a notification and the app was terminated
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      if (message != null) {
        print('App opened from terminated state by notification');
        // Navigate to relevant page based on the notification data
      }
    });

    // Handle when a user taps on a notification and the app was in the background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('App opened from background state by notification');
      // Navigate to relevant page based on the notification data
    });

    // For web platform
    if (kIsWeb) {
      // Request permission for web
      NotificationSettings settings =
          await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      print(
          'Web notification authorization status: ${settings.authorizationStatus}');
    }
  }

  static Future<String?> getFcmToken() async {
    try {
      String? token = await _firebaseMessaging.getToken();
      print('FCM Token: $token');
      return token;
    } catch (e) {
      print('Error getting FCM token: $e');
      return null;
    }
  }

  static void setupTokenRefreshListener(Function(String) onTokenRefresh) {
    _firebaseMessaging.onTokenRefresh.listen((String token) {
      print('FCM token refreshed: $token');
      // Call the callback function with the new token
      onTokenRefresh(token);
    });
  }

  // Add the permission request function here too
  static Future<void> requestNotificationPermissions() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print(
        'User notification permission status: ${settings.authorizationStatus}');

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }
  }
}
