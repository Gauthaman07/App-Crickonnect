import 'package:flutter/material.dart';
import 'book_ground_tab.dart';
import 'ground_requests_tab.dart';

class BookingScreen extends StatefulWidget {
  final int initialTabIndex; // Add this parameter

  const BookingScreen(
      {super.key, this.initialTabIndex = 0}); // Default to first tab

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen>
    with SingleTickerProviderStateMixin {
  // Add this mixin
  late TabController _tabController; // Add tab controller

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex, // Set initial tab
    );
  }

  @override
  void dispose() {
    _tabController.dispose(); // Don't forget to dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Bookings",
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
      body: Column(
        children: [
          SizedBox(height: 20),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            child: TabBar(
              controller: _tabController, // Use the controller
              labelColor: Colors.black,
              unselectedLabelColor: Colors.black54,
              indicator: UnderlineTabIndicator(
                borderSide: BorderSide(width: 3.0, color: Colors.red),
                insets: EdgeInsets.zero,
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              tabs: [
                Tab(text: "Explore Grounds"),
                Tab(text: "Manage Requests"),
              ],
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: TabBarView(
              controller: _tabController, // Use the controller
              children: [
                BookGroundTab(),
                GroundRequestTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
