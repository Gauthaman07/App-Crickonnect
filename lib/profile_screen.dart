import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './services/api_service.dart';
import 'signin.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? userData;
  bool isLoading = true;

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
                        child: CircularProgressIndicator(color: Colors.white),
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
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: Column(
                children: [
                  _buildProfileSection("Personal Information"),
                  _buildProfileSection("My Bookings"),
                  _buildProfileSection("My Requests"),
                  _buildProfileSection("My Favourites"),
                  _buildProfileSection("My Ground"),
                  _buildProfileSection("Review"),
                  Spacer(), // Pushes logout button to the bottom
                  ElevatedButton.icon(
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(color: Colors.grey.shade300, thickness: 1),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Text(
            title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
