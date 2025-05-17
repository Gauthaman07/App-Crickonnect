import '../push/notification_service.dart';
import 'api_service.dart';
import './token_manager.dart';

class FcmTokenManager {
  // Initialize and send FCM token
  static Future<void> initializeAndSendToken() async {
    try {
      // Check if user is logged in
      bool isLoggedIn = await AuthService.isLoggedIn();

      if (!isLoggedIn) {
        print('User is not logged in. Skipping FCM token update.');
        return;
      }

      // Get FCM token
      String? fcmToken = await NotificationService.getFcmToken();

      if (fcmToken == null || fcmToken.isEmpty) {
        print('Failed to get FCM token.');
        return;
      }

      // Send token to backend
      bool success = await ApiService.updateFcmToken(fcmToken);

      if (success) {
        print('FCM token successfully updated on backend.');
      } else {
        print('Failed to update FCM token on backend.');
      }

      // Set up listener for token refresh
      NotificationService.setupTokenRefreshListener((String newToken) async {
        // Send the new token to backend whenever it refreshes
        await ApiService.updateFcmToken(newToken);
      });
    } catch (e) {
      print('Error in FCM token initialization and sending: $e');
    }
  }
}
