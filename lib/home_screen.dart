import 'package:flutter/material.dart';
import 'card_widget.dart';
import './myteam/my_team_page.dart';

class HomeScreen extends StatelessWidget {
  final Function(int) onNavigateToTab; // Callback function to switch tab

  const HomeScreen({super.key, required this.onNavigateToTab});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Crickonnect",
          style: TextStyle(
            fontFamily: 'Boldonse',
            fontSize: 16,
            // fontWeight: FontWeight.w800, // ExtraBold (800)
            color: Colors.black,
          ),
        ),

        backgroundColor: Colors.white,
        automaticallyImplyLeading: false, // Removes back button
      ),
      // backgroundColor: Color(0xFFeeeeee),
      backgroundColor: Colors.white,
      body: Center(
        // Centers the content vertically and horizontally
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize:
                MainAxisSize.min, // Makes the column take minimal space
            mainAxisAlignment:
                MainAxisAlignment.center, // Centers content vertically
            children: [
              CardWidget(
                title: "My Team",
                description: "Manage your team members and stats",
                imagePath: "assets/team.jpg",
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyTeamPage()),
                ),
              ),
              SizedBox(height: 20),
              CardWidget(
                title: "My Booking",
                description: "View your ground bookings",
                imagePath: "assets/book.jpg",
                onTap: () => onNavigateToTab(1), // Switch tab instead of push
              ),
              SizedBox(height: 20),
              CardWidget(
                title: "My Tournaments",
                description: "Check upcoming tournaments",
                imagePath: "assets/tr.jpg",
                onTap: () => onNavigateToTab(2), // Switch tab instead of push
              ),
            ],
          ),
        ),
      ),
    );
  }
}
