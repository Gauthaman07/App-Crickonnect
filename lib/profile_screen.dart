import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './services/api_service.dart';
import 'signin.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/cupertino.dart';
import 'my_bookings_screen.dart';
import 'my_tournaments_screen.dart';
import 'my_grounds_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? userData;
  bool isLoading = true;
  bool isGroundOwner = false; // This will be determined from user data

  @override
  void initState() {
    super.initState();
    loadUserProfile();
  }

  Future<void> loadUserProfile() async {
    try {
      final storedProfile = await ApiService.getStoredUserProfile();

      if (storedProfile != null && storedProfile['data']?['user'] != null) {
        setState(() {
          userData = storedProfile['data']['user'];
        });
      }

      final freshProfile = await ApiService.fetchUserProfile();
      if (freshProfile != null && freshProfile['data']?['user'] != null) {
        setState(() {
          userData = freshProfile['data']['user'];
          // Check if user is ground owner (you can modify this logic based on your user data structure)
          isGroundOwner = userData?['isGroundOwner'] == true || userData?['role'] == 'ground_owner';
        });
      }
    } catch (e) {
      print("Error loading profile: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => SignInScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Top Section (Red Background)
          Container(
            width: double.infinity,
            color: Colors.red,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 50),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                isLoading
                    ? Center(
                        child: CupertinoActivityIndicator(
                          radius:
                              12, // Small size (consistent with other screens)
                          color: Colors.grey.shade600, // Metal silver color
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 20),
                          Text(
                            userData?["name"]?.toUpperCase() ?? "NO NAME",
                            style: GoogleFonts.anton(
                                fontSize: 26, color: Colors.white),
                          ),
                          SizedBox(height: 5),
                          Text(
                            userData?["email"] ?? "No Email",
                            style:
                                TextStyle(fontSize: 16, color: Colors.white70),
                          ),
                          SizedBox(height: 5),
                          Text(
                            userData?["mobile"] ?? "No Mobile",
                            style:
                                TextStyle(fontSize: 16, color: Colors.white70),
                          ),
                        ],
                      ),
              ],
            ),
          ),

          // Bottom Section (White Background)
          Expanded(
            child: Container(
              width: double.infinity,
              color: Colors.white,
              padding: EdgeInsets.only(top: 30, bottom: 30),
              child: Column(
                children: [
                  _buildNavigationSection("My Bookings", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MyBookingsScreen()),
                    );
                  }, isFirst: true),
                  _buildNavigationSection("My Tournaments", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MyTournamentsScreen()),
                    );
                  }),
                  if (isGroundOwner)
                    _buildNavigationSection("My Grounds", () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MyGroundsScreen()),
                      );
                    }),
                  Spacer(), // Pushes logout button to the bottom
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: ElevatedButton.icon(
                      onPressed: () => _logout(context),
                      icon: Icon(Icons.logout, color: Colors.white),
                      label: Text(
                        "Logout",
                        style: TextStyle(color: Colors.white70),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding:
                            EdgeInsets.symmetric(vertical: 14, horizontal: 40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationSection(String title, VoidCallback onTap, {bool isFirst = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Only show divider if it's not the first item (My Bookings)
        if (!isFirst)
          Divider(color: Colors.grey.shade300, thickness: 1, height: 1),
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey.shade600,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
