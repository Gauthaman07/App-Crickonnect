import 'package:flutter/material.dart';
import 'card_widget.dart';
import './myteam/my_team_page.dart';
import '../services/api_service.dart';
import 'booking_screen.dart';
import 'create_tournament.dart';
import 'tournaments_screen.dart';
import 'ground_availability_screen.dart';
import 'guest_match_requests_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  final Function(int) onNavigateToTab;
  final Function(int) onNavigateToBookingTab;

  const HomeScreen({
    super.key,
    required this.onNavigateToTab,
    required this.onNavigateToBookingTab,
  });

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? teamData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMyTeam();
  }

  Future<void> fetchMyTeam() async {
    try {
      final teamResponse = await ApiService.getMyTeam();
      if (teamResponse != null && !teamResponse.containsKey("error")) {
        setState(() {
          teamData = teamResponse;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Crickonnect",
          style: TextStyle(
            fontFamily: 'Boldonse',
            fontSize: 15,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF15151E),
        automaticallyImplyLeading: false,
      ),
      backgroundColor: const Color(0xFFF5F0ED),
      body: isLoading
          ? Center(
              child: CupertinoActivityIndicator(
                radius: 12, // Small size
                color: Colors.grey.shade600, // Metal silver color
              ),
            )
          : Column(
              children: [
                // Full-Width Team Header Section (No margins/padding on sides)
                if (teamData != null) ...[
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16), // Only horizontal padding for content
                    margin: EdgeInsets.only(bottom: 20), // Only bottom margin
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      // Removed borderRadius and border for full-width effect
                    ),
                    child: Row(
                      children: [
                        // Team Logo (Circular)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: Image.network(
                            teamData!['team']['teamLogo'] ?? "",
                            height: 50,
                            width: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 60,
                                width: 60,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Icon(
                                  Icons.sports_cricket,
                                  size: 30,
                                  color: Colors.grey[600],
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(width: 16),
                        // Team Name
                        Expanded(
                          child: Text(
                            (teamData!['team']['teamName'] ?? "My Team")
                                .toUpperCase(), // Added .toUpperCase()
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Ground Availability Hero Banner (only for ground owners)
                if (teamData != null && teamData!['team']['hasOwnGround'] == true) ...[
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Material(
                      elevation: 8,
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GroundAvailabilityScreen(),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.green.shade600, Colors.blue.shade600],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.calendar_month,
                                  color: Colors.white,
                                  size: 32,
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Ground Availability',
                                      style: GoogleFonts.inter(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Manage your weekly schedule & guest requests',
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        color: Colors.white.withOpacity(0.9),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],


                // Cards Section with normal padding
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0), // Only for cards
                      child: Column(
                        children: [
                          CardWidget(
                            title: "Book Matches",
                            description: "Book grounds for your matches",
                            imagePath: "assets/book.jpg",
                            onTap: () {
                              // Navigate to booking tab (Book Ground tab)
                              widget.onNavigateToBookingTab(0);
                            },
                          ),
                          SizedBox(height: 12),
                          // Enhanced Manage Requests Card for Ground Owners
                          CardWidget(
                            title: teamData != null && teamData!['team']['hasOwnGround'] == true
                                ? "Manage All Requests"
                                : "Manage Requests",
                            description: teamData != null && teamData!['team']['hasOwnGround'] == true
                                ? "Handle booking & guest match requests"
                                : "Handle ground booking requests",
                            imagePath: "assets/team.jpg",
                            onTap: () {
                              // Navigate to booking tab (Ground Requests tab)
                              widget.onNavigateToBookingTab(1);
                            },
                          ),

                          SizedBox(height: 12),

                          CardWidget(
                            title: "Tournaments",
                            description: "View and join tournaments",
                            imagePath: "assets/tr.jpg",
                            onTap: () {
                              // Navigate to tournaments tab
                              widget.onNavigateToTab(2);
                            },
                          ),
                          SizedBox(height: 12),

                          CardWidget(
                            title: "Create Tournament",
                            description: "Start your own tournament",
                            imagePath: "assets/book.jpg",
                            onTap: () async {
                              // Navigate to create tournament screen
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CreateTournamentScreen(),
                                ),
                              );
                              // Optional: Handle result if tournament was created
                              if (result == true) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Tournament created successfully!'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            },
                          ),
                          
                          
                          SizedBox(height: 16), // Bottom spacing
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
