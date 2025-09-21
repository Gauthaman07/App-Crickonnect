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
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          decoration: BoxDecoration(
            color: Color(0xFF181818),
            border: Border(
              top: BorderSide(
                color: Colors.grey.shade400,
                width: 0.5,
              ),
            ),
          ),
          child: Stack(
            children: [
              ClipRRect(
                child: BottomNavigationBar(
                  backgroundColor: Colors.white,
                  currentIndex: currentIndex,
                  onTap: onTap,
                  type: BottomNavigationBarType.fixed,
                  selectedItemColor: Colors.black,
                  unselectedItemColor: Colors.black,
                  showUnselectedLabels: true,
                  selectedLabelStyle: TextStyle(
                    color: Colors.black,
                    fontSize: 11,
                  ),
                  unselectedLabelStyle: TextStyle(
                    color: Colors.black,
                    fontSize: 11,
                  ),
                  elevation: 0,
                  items: [
                    _buildAnimatedNavItem(
                        Icons.home_outlined, Icons.home, "Home", 0),
                    _buildAnimatedNavItem(Icons.book_online_outlined,
                        Icons.book_online, "Booking", 1),
                    _buildAnimatedNavItem(Icons.emoji_events_outlined,
                        Icons.emoji_events, "Tournaments", 2),
                    _buildAnimatedNavItem(
                        Icons.person_outline, Icons.person, "Account", 3),
                  ],
                ),
              ),
              // Red border indicator positioned exactly at the top border
              Positioned(
                top: 0,
                left: (constraints.maxWidth / 4) * currentIndex +
                    (constraints.maxWidth / 4 - 60) / 2,
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  height: 2,
                  width: 60,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(1.5),
                  ),
                ),
              ),
            ],
          ),
        );
      },
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
          size: 20,
          color: Colors.black,
        ),
      ),
      label: label,
    );
  }
}
