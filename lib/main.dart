import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'bottom_navbar.dart';
import 'home_screen.dart';
import 'booking_screen.dart';
import 'tournaments_screen.dart';
import 'profile_screen.dart';
import 'signup_screen.dart';
import 'signin.dart'; // Import Sign-In screen
import 'package:firebase_core/firebase_core.dart';
import 'push/notification_service.dart';
import './services/fcm_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize Firebase Messaging
  await NotificationService.initializeFirebaseMessaging();

  // Request notification permissions
  await NotificationService.requestNotificationPermissions();

  await FcmTokenManager.initializeAndSendToken();
  // Get shared preferences for login status
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  // Run app with login status
  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: isLoggedIn ? HomePage() : SignInScreen(), // Show Sign-In first
      routes: {
        '/home': (context) => HomePage(),
        '/signup': (context) => SignUpScreen(),
        '/signin': (context) => SignInScreen(),
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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<Widget> _screens = [
    HomeScreen(onNavigateToTab: (index) {}), // Placeholder for now
    BookingScreen(),
    TournamentsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          HomeScreen(onNavigateToTab: _onItemTapped), // Updated here ✅
          BookingScreen(),
          TournamentsScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
