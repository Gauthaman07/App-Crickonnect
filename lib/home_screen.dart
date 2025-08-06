import 'package:flutter/material.dart';
import 'card_widget.dart';
import './myteam/my_team_page.dart';
import '../services/api_service.dart';
import 'booking_screen.dart';

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
            fontSize: 16,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      backgroundColor: Colors.white,
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Colors.red,
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
                            height: 60,
                            width: 60,
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
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
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
                          // 4 Cards in Vertical Layout with Enhanced Navigation
                          CardWidget(
                            title: "Manage Requests",
                            description: "Handle ground booking requests",
                            imagePath: "assets/team.jpg",
                            onTap: () {
                              widget.onNavigateToBookingTab(1);
                            },
                          ),
                          SizedBox(height: 12),

                          CardWidget(
                            title: "Book Matches",
                            description: "Book grounds for your matches",
                            imagePath: "assets/book.jpg",
                            onTap: () {
                              widget.onNavigateToBookingTab(0);
                            },
                          ),
                          SizedBox(height: 12),

                          CardWidget(
                            title: "Tournaments",
                            description: "View and join tournaments",
                            imagePath: "assets/tr.jpg",
                            onTap: () => widget.onNavigateToTab(2),
                          ),
                          SizedBox(height: 12),

                          CardWidget(
                            title: "Create Tournament",
                            description: "Start your own tournament",
                            imagePath: "assets/book.jpg",
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      Text('Create Tournament - Coming Soon!'),
                                  backgroundColor: Colors.orange,
                                ),
                              );
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
