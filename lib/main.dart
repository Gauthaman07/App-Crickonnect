// lib/main.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'push/notification_service.dart';
import './services/fcm_manager.dart';
import 'bottom_navbar.dart';
import 'home_screen.dart';
import 'booking_screen.dart';
import 'tournaments_screen.dart';
import 'profile_screen.dart';
import 'signup_screen.dart';
import 'signin.dart';
import 'ground_requests_tab.dart';

/// Global navigator key for navigation from background handlers.
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1️⃣ Initialize Firebase
  await Firebase.initializeApp();

  // 2️⃣ Initialize and configure FCM & local notifications
  await NotificationService.initializeFirebaseMessaging();
  await NotificationService.requestNotificationPermissions();

  // 3️⃣ Get & send FCM token to your backend
  await FcmTokenManager.initializeAndSendToken();

  // 4️⃣ Check login state
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  // 5️⃣ Start the app
  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      // Initial screen based on login
      home: isLoggedIn ? HomePage() : SignInScreen(),
      routes: {
        '/signin': (c) => SignInScreen(),
        '/signup': (c) => SignUpScreen(),
        '/home': (c) => HomePage(),
        '/bookingrequests': (c) =>
            GroundRequestTab(), // your pending bookings page
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    // Remove manual onMessage snack—NotificationService handles it now

    _screens = [
      HomeScreen(onNavigateToTab: _onItemTapped),
      BookingScreen(),
      TournamentsScreen(),
      ProfileScreen(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar:
          BottomNavBar(currentIndex: _selectedIndex, onTap: _onItemTapped),
    );
  }
}
