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
                // Team Header Section
                if (teamData != null) ...[
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    child: Row(
                      children: [
                        // Team Logo (Circular)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(25),
                          child: Image.network(
                            teamData!['team']['teamLogo'] ?? "",
                            height: 50,
                            width: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 50,
                                width: 50,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(25),
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
                            (teamData!['team']['teamName'] ?? "My Team").toUpperCase(),
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Thin Separator Line
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 16),
                    height: 1,
                    color: Colors.grey[300],
                  ),

                  // Manage Schedule Section (only for ground owners)
                  if (teamData!['team']['hasOwnGround'] == true) ...[
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GroundAvailabilityScreen(),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today_rounded,
                                color: Colors.green[600],
                                size: 24,
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  'Manage Schedule',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.grey[600],
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ],


                // Grid Cards Section 
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // 2x2 Grid Layout
                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          childAspectRatio: 0.85, // Adjust for card proportions
                          crossAxisSpacing: 0,
                          mainAxisSpacing: 0,
                            children: [
                              // Book Matches - Top Left
                              _buildGridCard(
                                title: "BOOK\nMatches",
                                description: "",
                                imagePath: "assets/book.jpg",
                                onTap: () {
                                  widget.onNavigateToBookingTab(0);
                                },
                              ),
                              
                              // Manage Requests - Top Right
                              _buildGridCard(
                                title: "MANAGE\nRequests",
                                description: "",
                                imagePath: "assets/team.jpg",
                                onTap: () {
                                  widget.onNavigateToBookingTab(1);
                                },
                              ),
                              
                              // Tournaments - Bottom Left
                              _buildGridCard(
                                title: "JOIN\nTournaments",
                                description: "",
                                imagePath: "assets/tr.jpg",
                                onTap: () {
                                  widget.onNavigateToTab(2);
                                },
                              ),
                              
                              // Create Tournament - Bottom Right
                              _buildGridCard(
                                title: "CREATE\nTournament",
                                description: "",
                                imagePath: "assets/book.jpg",
                                onTap: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CreateTournamentScreen(),
                                    ),
                                  );
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
                            ],
                          ),
                          SizedBox(height: 16), // Bottom spacing
                        ],
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  // Grid Card Widget - Optimized for 2x2 grid layout
  Widget _buildGridCard({
    required String title,
    required String description,
    required String imagePath,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [
            // Background Image
            Positioned.fill(
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.blue.shade400,
                          Colors.blue.shade600,
                        ],
                      ),
                    ),
                    child: Icon(
                      Icons.image,
                      color: Colors.white,
                      size: 30,
                    ),
                  );
                },
              ),
            ),
            
            // Dark Overlay for better text readability
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.3),
                      Colors.black.withOpacity(0.6),
                    ],
                  ),
                ),
              ),
            ),
            
            // Text Overlay
            Positioned(
              left: 16,
              right: 16,
              bottom: 24, // Moved up from bottom
              child: RichText(
                text: TextSpan(
                  children: _buildTextSpans(title),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper function to build text spans with hierarchy
  List<TextSpan> _buildTextSpans(String title) {
    final lines = title.split('\n');
    
    if (lines.length >= 2) {
      // Two-line format: First line (large, ALL CAPS), second line (smaller, normal case)
      return [
        TextSpan(
          text: lines[0], // Main word (already in caps from title)
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
        TextSpan(
          text: '\n${lines[1]}', // Secondary word
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white.withOpacity(0.9),
            letterSpacing: 0.2,
          ),
        ),
      ];
    } else {
      // Single line fallback
      return [
        TextSpan(
          text: title,
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: -0.2,
          ),
        ),
      ];
    }
  }
}
