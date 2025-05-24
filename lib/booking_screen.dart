import 'package:flutter/material.dart';
import 'book_ground_tab.dart';
import 'ground_requests_tab.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Number of tabs
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Bookings",
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
        backgroundColor: Colors.white,
        body: Column(
          children: [
            SizedBox(height: 20),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
              ),
              child: TabBar(
                labelColor: Colors.black, // Text color of selected tab
                unselectedLabelColor:
                    Colors.black54, // Faded text for unselected tabs
                indicator: UnderlineTabIndicator(
                  borderSide: BorderSide(
                      width: 3.0, color: Colors.red), // Red underline
                  insets: EdgeInsets
                      .zero, // Remove the horizontal insets completely
                ),
                indicatorSize:
                    TabBarIndicatorSize.tab, // Makes indicator match tab width
                labelStyle:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                tabs: [
                  Tab(text: "Explore Grounds"),
                  Tab(text: "Manage Requests"),
                ],
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: TabBarView(
                children: [
                  BookGroundTab(),
                  GroundRequestTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
