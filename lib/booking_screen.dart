import 'package:flutter/material.dart';
import 'book_ground_tab.dart';
import 'ground_requests_tab.dart';

class BookingScreen extends StatefulWidget {
  final int initialTabIndex;

  const BookingScreen({super.key, this.initialTabIndex = 0});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
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
            fontSize: 15,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF15151E),
        automaticallyImplyLeading: false,
      ),
      backgroundColor: const Color(0xFFF5F0ED),
      body: Column(
        children: [
          SizedBox(height: 20),
          // Custom Pill Tab Selector
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16),
            padding: EdgeInsets.all(3), // Reduced padding to decrease height
            decoration: BoxDecoration(
              color: Colors.white, // Changed to white background
              borderRadius: BorderRadius.circular(25),
            ),
            child: AnimatedBuilder(
              animation: _tabController,
              builder: (context, child) {
                return Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _tabController.animateTo(0),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 10), // Reduced from 12 to 10
                          decoration: BoxDecoration(
                            color: _tabController.index == 0
                                ? Colors.black
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "Grounds",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _tabController.index == 0
                                  ? Colors.white
                                  : Colors.black,
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _tabController.animateTo(1),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 10), // Reduced from 12 to 10
                          decoration: BoxDecoration(
                            color: _tabController.index == 1
                                ? Colors.black
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "Requests",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _tabController.index == 1
                                  ? Colors.white
                                  : Colors.black,
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          SizedBox(height: 10),
          Expanded(
            child: TabBarView(
              controller: _tabController,
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
