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
                // Comprehensive Team Info Box
                if (teamData != null) ...[
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.only(top: 1),
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF15151E),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Top Row: Logo + Team Info
                        Row(
                          children: [
                            // Team Logo
                            Container(
                              padding: EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(28),
                                child: Image.network(
                                  teamData!['team']['teamLogo'] ?? "",
                                  height: 56,
                                  width: 56,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      height: 56,
                                      width: 56,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(28),
                                      ),
                                      child: Icon(
                                        Icons.sports_cricket,
                                        size: 28,
                                        color: Colors.grey[600],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),

                            SizedBox(width: 16),

                            // Team Name & Match Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Team Name
                                  Text(
                                    (teamData!['team']['teamName'] ?? "My Team")
                                        .toUpperCase(),
                                    style: GoogleFonts.robotoCondensed(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 0.5,
                                    ),
                                  ),

                                  SizedBox(height: 8),

                                  // Upcoming Match Info
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.event,
                                          color: Colors.white70,
                                          size: 14,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          'Next Match: Today, 6:00 PM',
                                          style: GoogleFonts.robotoCondensed(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.white70,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        // Manage Schedule Section (only for ground owners)
                        if (teamData!['team']['hasOwnGround'] == true) ...[
                          SizedBox(height: 16),

                          // Divider
                          Container(
                            height: 1,
                            color: Colors.white.withOpacity(0.2),
                          ),

                          SizedBox(height: 16),

                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      GroundAvailabilityScreen(),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: Colors.white.withOpacity(0.3)),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Manage Ground Schedule',
                                      style: GoogleFonts.robotoCondensed(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    color: Colors.white70,
                                    size: 16,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],

                // Action Grid Section
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Striking Heading
                        Padding(
                          padding: EdgeInsets.only(left: 4, bottom: 16, top: 4),
                          child: Text(
                            'EXPLORE',
                            style: TextStyle(
                              fontFamily: 'Boldonse',
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: Colors.black87,
                              // letterSpacing: 1.5,
                            ),
                          ),
                        ),

                        // Grid
                        Expanded(
                          child: GridView.count(
                            crossAxisCount: 2,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                            childAspectRatio: 0.9,
                            children: [
                              // Book Matches
                              _buildImageCard(
                                title: "BOOK\nMATCHES",
                                imagePath: "assets/book.jpg",
                                onTap: () {
                                  widget.onNavigateToBookingTab(0);
                                },
                              ),

                              // Manage Requests
                              _buildImageCard(
                                title: "MANAGE\nREQUESTS",
                                imagePath: "assets/team.jpg",
                                onTap: () {
                                  widget.onNavigateToBookingTab(1);
                                },
                              ),

                              // Join Tournaments
                              _buildImageCard(
                                title: "JOIN\nTOURNAMENTS",
                                imagePath: "assets/tr.jpg",
                                onTap: () {
                                  widget.onNavigateToTab(2);
                                },
                              ),

                              // Create Tournament
                              _buildImageCard(
                                title: "CREATE\nTOURNAMENT",
                                imagePath: "assets/book.jpg",
                                onTap: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          CreateTournamentScreen(),
                                    ),
                                  );
                                  if (result == true) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'Tournament created successfully!'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  }
                                },
                              ),
                            ],
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

  // Image Card Widget - Card with background image and text overlay
  Widget _buildImageCard({
    required String title,
    required String imagePath,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
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
                            Colors.grey.shade400,
                            Colors.grey.shade600,
                          ],
                        ),
                      ),
                      child: Icon(
                        Icons.image,
                        color: Colors.white,
                        size: 40,
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
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
              ),

              // Text Overlay
              Positioned.fill(
                child: Container(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: _buildTitleSpans(title),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper function to build text spans with typography hierarchy
  List<TextSpan> _buildTitleSpans(String title) {
    final lines = title.split('\n');

    if (lines.length >= 2) {
      // Two-line format: Action (large) + Object (smaller)
      return [
        TextSpan(
          text: lines[0], // Main action word (BOOK, MANAGE, etc.)
          style: GoogleFonts.robotoCondensed(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
        TextSpan(
          text: '\n${lines[1]}', // Object word (Matches, Requests, etc.)
          style: GoogleFonts.robotoCondensed(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white.withOpacity(0.9),
            letterSpacing: 0.3,
          ),
        ),
      ];
    } else {
      // Single line fallback
      return [
        TextSpan(
          text: title,
          style: GoogleFonts.robotoCondensed(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
      ];
    }
  }
}
