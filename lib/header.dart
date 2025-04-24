import 'package:flutter/material.dart';

class CustomHeader extends StatelessWidget implements PreferredSizeWidget {
  const CustomHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Row(
        children: [
          Text(
            "Crickonnect",
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),
          ),
          Spacer(), // Pushes notification icon to the right
          Icon(
            Icons.notifications,
            color: Colors.white, // Set icon color to white
          ),
        ],
      ),
      backgroundColor: Color(0xFF181818), // Change color as needed
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight); // Standard AppBar height
}
