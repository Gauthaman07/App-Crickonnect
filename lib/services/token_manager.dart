import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // Keys for SharedPreferences
  static const String TOKEN_KEY = 'token';
  static const String IS_LOGGED_IN_KEY = 'isLoggedIn';

  // Store authentication token and login status
  static Future<void> storeAuthToken(String token) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(TOKEN_KEY, token);
      await prefs.setBool(IS_LOGGED_IN_KEY, true);
      print('Auth token stored successfully');
    } catch (e) {
      print('Error storing auth token: $e');
    }
  }

  // Get authentication token
  static Future<String?> getAuthToken() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getString(TOKEN_KEY);
    } catch (e) {
      print('Error getting auth token: $e');
      return null;
    }
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getBool(IS_LOGGED_IN_KEY) ?? false;
    } catch (e) {
      print('Error checking login status: $e');
      return false;
    }
  }

  // Clear authentication data (for logout)
  static Future<void> clearAuthData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove(TOKEN_KEY);
      await prefs.setBool(IS_LOGGED_IN_KEY, false);
      print('Auth data cleared successfully');
    } catch (e) {
      print('Error clearing auth data: $e');
    }
  }
}
