import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF181818),
        // borderRadius: BorderRadius.only(
        //   topLeft: Radius.circular(25),
        //   topRight: Radius.circular(25),
        // ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        // borderRadius: BorderRadius.only(
        //   topLeft: Radius.circular(25),
        //   topRight: Radius.circular(25),
        // ),
        child: BottomNavigationBar(
          // backgroundColor: Color(0xFF616161),
          backgroundColor: Colors.white,
          currentIndex: currentIndex,
          onTap: onTap,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.red,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: false,
          elevation: 0,
          items: [
            _buildAnimatedNavItem(Icons.home_outlined, Icons.home, "Home", 0),
            _buildAnimatedNavItem(
                Icons.book_online_outlined, Icons.book_online, "Booking", 1),
            _buildAnimatedNavItem(Icons.emoji_events_outlined,
                Icons.emoji_events, "Tournaments", 2),
            _buildAnimatedNavItem(
                Icons.person_outline, Icons.person, "Profile", 3),
          ],
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildAnimatedNavItem(
      IconData outlinedIcon, IconData filledIcon, String label, int index) {
    return BottomNavigationBarItem(
      icon: AnimatedSwitcher(
        duration: Duration(milliseconds: 300),
        switchInCurve: Curves.easeInOut,
        switchOutCurve: Curves.easeInOut,
        child: Icon(
          currentIndex == index ? filledIcon : outlinedIcon,
          key: ValueKey<int>(index + (currentIndex == index ? 1 : 0)),
          size: 28,
        ),
      ),
      label: label,
    );
  }
}
