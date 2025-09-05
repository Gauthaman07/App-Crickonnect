// lib/main.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_fonts/google_fonts.dart';
import 'push/notification_service.dart';
import './services/fcm_manager.dart';
import './services/api_service.dart';
import 'bottom_navbar.dart';
import 'home_screen.dart';
import 'booking_screen.dart';
import 'tournaments_screen.dart';
import 'profile_screen.dart';
import 'signup_screen.dart';
import 'signin.dart';
import 'ground_requests_tab.dart';
import './myteam/create_team_form.dart';

/// Global navigator key for navigation from background handlers.
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1️⃣ Initialize Firebase
  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

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
      // Updated home logic to check team status
      home: isLoggedIn ? InitialScreen() : SignInScreen(),
      routes: {
        '/signin': (c) => SignInScreen(),
        '/signup': (c) => SignUpScreen(),
        '/home': (c) => HomePage(),
        '/bookingrequests': (c) => GroundRequestTab(),
      },
    );
  }
}

// Updated InitialScreen widget in main.dart
class InitialScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: ApiService.getMyTeam(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show splash screen with logo while checking team
          return SplashScreen();
        }

        if (snapshot.hasError) {
          print('Error in InitialScreen: ${snapshot.error}');
          // On error, show team creation form
          return CreateTeamForm(
            onTeamCreated: () {
              Navigator.pushReplacementNamed(context, '/home');
            },
          );
        }

        // More robust team checking logic
        final data = snapshot.data;
        print('Team data received: $data'); // Debug print

        // Check multiple conditions to determine if user has a valid team
        bool hasValidTeam = false;

        if (data != null) {
          // Check if there's an explicit error
          if (data.containsKey('error')) {
            hasValidTeam = false;
          }
          // Check if response has team data
          else if (data.containsKey('team') && data['team'] != null) {
            hasValidTeam = true;
          }
          // Check if response has success flag
          else if (data.containsKey('success') && data['success'] == true) {
            hasValidTeam = true;
          }
          // Check if response directly contains team fields
          else if (data.containsKey('teamName') || data.containsKey('_id')) {
            hasValidTeam = true;
          } else {
            hasValidTeam = false;
          }
        }

        if (hasValidTeam) {
          print('User has valid team - going to HomePage');
          return HomePage();
        } else {
          print('No valid team found - showing CreateTeamForm');
          return CreateTeamForm(
            onTeamCreated: () {
              Navigator.pushReplacementNamed(context, '/home');
            },
          );
        }
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
  int _bookingTabIndex = 0; // Add this to track booking tab index
  late List<Widget> _screens; // Changed from final to allow updates

  @override
  void initState() {
    super.initState();
    _buildScreens(); // Build screens with current booking tab index
  }

  // Method to build/rebuild screens
  void _buildScreens() {
    _screens = [
      HomeScreen(
        onNavigateToTab: _onItemTapped,
        onNavigateToBookingTab: _onNavigateToBookingTab, // Add this callback
      ),
      BookingScreen(initialTabIndex: _bookingTabIndex), // Pass the tab index
      TournamentsScreen(),
      ProfileScreen(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // New method to handle booking tab navigation
  void _onNavigateToBookingTab(int bookingTabIndex) {
    setState(() {
      _selectedIndex = 1; // Switch to booking screen
      _bookingTabIndex = bookingTabIndex; // Set the specific tab
      _buildScreens(); // Rebuild screens with new booking tab index
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

// Clean Splash Screen with Logo Only
class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset(
          'assets/cklogo.png',
          width: 150,
          height: 150,
        ),
      ),
    );
  }
}
