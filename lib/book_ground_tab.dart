import 'package:flutter/material.dart';
import '../services/api_service.dart';
import './ground_details_screen.dart';
import 'package:flutter/cupertino.dart';

class BookGroundTab extends StatefulWidget {
  const BookGroundTab({super.key});

  @override
  _BookGroundTabState createState() => _BookGroundTabState();
}

class _BookGroundTabState extends State<BookGroundTab> {
  List<Map<String, dynamic>> grounds = [];
  bool isLoading = true;
  String selectedLocation = "Tirupur"; // Default location
  final List<String> locations = [
    "Tirupur",
    "Coimbatore",
    "Chennai",
    "Salem",
    "Madurai"
  ];

  @override
  void initState() {
    super.initState();
    fetchGrounds();
  }

  Future<void> fetchGrounds() async {
    setState(() => isLoading = true);
    try {
      final data = await ApiService.fetchGrounds(selectedLocation);
      setState(() {
        // Merge both lists into a single list
        grounds = [...(data["grounds"] ?? []), ...(data["otherGrounds"] ?? [])];
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      print("Error: $e");
    }
  }

  void showLocationSelector() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: locations.map((location) {
              return ListTile(
                title: Text(location, style: TextStyle(fontSize: 18)),
                onTap: () {
                  setState(() {
                    selectedLocation = location;
                  });
                  fetchGrounds();
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.end, // Aligns content to the right
              children: [
                GestureDetector(
                  onTap: showLocationSelector,
                  child: Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.red),
                      SizedBox(width: 5),
                      Text(
                        selectedLocation,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(Icons.keyboard_arrow_down, color: Colors.black54),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(
                    child: CupertinoActivityIndicator(
                      radius: 12, // Small size
                      color: Colors.grey.shade600, // Metal silver color
                    ),
                  )
                : grounds.isEmpty
                    ? Center(child: Text("No grounds found"))
                    : ListView.builder(
                        padding: EdgeInsets.all(10),
                        itemCount: grounds.length,
                        itemBuilder: (context, index) {
                          final ground = grounds[index];
                          return GroundCard(ground: ground);
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class GroundCard extends StatelessWidget {
  final Map<String, dynamic> ground;
  const GroundCard({super.key, required this.ground});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GroundDetailsPage(ground: ground),
            ),
          );
        },
        child: Card(
          margin: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          color: Colors.white,
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image with border radius on all sides
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    ground['image'],
                    width: double.infinity,
                    height: 220,
                    fit: BoxFit.cover,
                  ),
                ),
                // Gap between image and content
                SizedBox(height: 12),
                // Content section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ground['groundName'].toString()[0].toUpperCase() +
                              ground['groundName'].toString().substring(1),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          ground['ownedByTeam'] != null
                              ? ground['ownedByTeam']['teamName'].toUpperCase()
                              : 'NO TEAM',
                          style: TextStyle(fontSize: 14, color: Colors.black),
                        ),
                        Text(
                          ground['location'].toUpperCase(),
                          style: TextStyle(fontSize: 14, color: Colors.black),
                        ),

                        // Text(
                        //   "₹${ground['fee']}",
                        //   style: TextStyle(
                        //     fontSize: 14,
                        //     color: Colors.black,
                        //     decoration: TextDecoration.underline,
                        //   ),
                        // ),
                      ],
                    ),
                    Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 2, horizontal: 12),
                      decoration: BoxDecoration(
                        // color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "₹${ground['fee']}",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ));
  }
}
