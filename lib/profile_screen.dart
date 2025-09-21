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

          // Bottom Section (Beige Background)
          Expanded(
            child: Container(
              width: double.infinity,
              color: const Color(0xFFF5F0ED),
              padding: EdgeInsets.only(top: 30, bottom: 30),
              child: Column(
                children: [
                  _buildNavigationSection("My Bookings", Icons.book_online, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MyBookingsScreen()),
                    );
                  }, isFirst: true),
                  _buildNavigationSection("My Tournaments", Icons.emoji_events, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MyTournamentsScreen()),
                    );
                  }),
                  _buildNavigationSection("My Reviews", Icons.star_rate, () {
                    // TODO: Navigate to My Reviews screen
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('My Reviews - Coming Soon!'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  }, hasSubtext: true, subtext: "Coming Soon"),
                  _buildNavigationSection("Referral", Icons.share, () {
                    // TODO: Navigate to Referral screen
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Referral Program - Coming Soon!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }, hasSubtext: true, subtext: "Coming Soon"),
                  _buildNavigationSection("Terms & Conditions", Icons.description, () {
                    // TODO: Navigate to Terms & Conditions screen
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Terms & Conditions - Coming Soon!'),
                        backgroundColor: Colors.blue,
                      ),
                    );
                  }),
                  _buildNavigationSection("Logout", Icons.logout, () => _logout(context), isLogout: true),
                  if (isGroundOwner)
                    _buildNavigationSection("My Grounds", Icons.location_on, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MyGroundsScreen()),
                      );
                    }),
                  Spacer(), // Pushes content to appropriate spacing
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationSection(String title, IconData icon, VoidCallback onTap, {bool isFirst = false, bool isLogout = false, bool hasSubtext = false, String subtext = ""}) {
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
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: isLogout ? BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(8),
                  ) : null,
                  child: Icon(
                    icon,
                    size: 20,
                    color: isLogout ? Colors.white : Colors.grey.shade700,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: isLogout ? Colors.red.shade700 : Colors.grey.shade800,
                        ),
                      ),
                      if (hasSubtext)
                        Padding(
                          padding: EdgeInsets.only(top: 2),
                          child: Text(
                            subtext,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
