import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import 'booking_confirmation_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class GroundDetailsPage extends StatefulWidget {
  final Map<String, dynamic> ground;

  const GroundDetailsPage({super.key, required this.ground});

  @override
  _GroundDetailsPageState createState() => _GroundDetailsPageState();
}

class _GroundDetailsPageState extends State<GroundDetailsPage> {
  List<String> upcomingDates = [];
  String selectedDate = "";
  String selectedSession = "morning";
  List<Map<String, dynamic>> userTeams = [];
  bool isLoadingTeams = true;
  bool isBooking = false;

  @override
  void initState() {
    super.initState();
    generateUpcomingDates();
    fetchUserTeams();
  }

  void generateUpcomingDates() {
    DateTime today = DateTime.now();
    setState(() {
      upcomingDates = List.generate(15, (index) {
        return DateFormat('yyyy-MM-dd')
            .format(today.add(Duration(days: index)));
      });
      selectedDate = upcomingDates[0];
    });
  }

  Future<void> fetchUserTeams() async {
    try {
      final response = await ApiService.getMyTeam();
      if (response != null && response.containsKey("team")) {
        setState(() {
          userTeams = [response["team"]];
          isLoadingTeams = false;
        });
      } else {
        setState(() {
          isLoadingTeams = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoadingTeams = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load teams: $e")),
      );
    }
  }

  Future<void> bookGround() async {
    if (userTeams.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No teams available for booking.")),
      );
      return;
    }

    // Debug the ground object to see its structure
    print("📢 Ground object: ${widget.ground}");

    // Try different possible ID fields
    final String? groundId = widget.ground["_id"] ??
        widget.ground["id"] ??
        widget.ground["groundId"];

    // Validate ground ID
    if (groundId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Ground information is incomplete. Missing ID.")),
      );
      return;
    }

    // Start the booking process and show loader
    setState(() {
      isBooking = true;
    });

    try {
      Map<String, String> payload = {
        "bookedByTeam": userTeams[0]["_id"],
        "bookedDate": selectedDate,
        "groundId": groundId,
        "timeSlot": selectedSession,
      };

      print("📢 Booking Payload: $payload"); // Debugging

      final response = await ApiService.bookGround(payload);

      print("✅ Booking Response: $response"); // Debugging

      // Check response and navigate if successful
      if (response.containsKey("success") && response["success"] == true) {
        // Navigate to confirmation page with detailed information
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BookingConfirmationPage(
                groundName: widget.ground["groundName"] ?? "Ground",
                bookedDate: selectedDate,
                session: selectedSession,
              ),
            ),
          );
        }
      } else {
        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  response["message"] ?? "Booking failed. Please try again."),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // Handle any exceptions during booking
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error during booking: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      // Always hide the loader, regardless of outcome
      if (mounted) {
        setState(() {
          isBooking = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image with overlay buttons
                Stack(
                  children: [
                    // Image at the top
                    Image.network(
                      widget.ground["image"] ??
                          'https://placeholder.com/ground',
                      width: double.infinity,
                      height: 250,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: double.infinity,
                          height: 250,
                          color: Colors.grey[300],
                          child:
                              const Center(child: Text("Image not available")),
                        );
                      },
                    ),

                    // Back button at top left with white background
                    Positioned(
                      top: 25,
                      left: 20,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(Icons.arrow_back),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ),

                    // Share and favorite icons at top right
                    Positioned(
                      top: 25,
                      right: 20,
                      child: Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: Icon(Icons.share),
                              onPressed: () {
                                // Share functionality
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: Icon(Icons.favorite_border),
                              onPressed: () {
                                // Favorite functionality
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.ground["groundName"].isNotEmpty
                            ? widget.ground["groundName"][0].toUpperCase() +
                                widget.ground["groundName"].substring(1)
                            : "",
                        style: GoogleFonts.montserrat(
                          fontSize: 24,
                          fontWeight: FontWeight.w600, // ExtraBold (800)
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                          widget.ground["location"] ?? "Location not specified",
                          style: const TextStyle(
                              fontSize: 16, color: Colors.black)),
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity, // Makes it take full width
                        alignment: Alignment.center, // Centers the text
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(
                                color: Colors.grey.shade300,
                                width: 1), // Gainsboro
                            bottom: BorderSide(
                                color: Colors.grey.shade300,
                                width: 1), // Gainsboro
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 14), // Adjust padding for spacing
                        child: Text(
                          widget.ground['ownedByTeam'] != null
                              ? widget.ground['ownedByTeam']['teamName']
                                      .toString()
                                      .isNotEmpty
                                  ? widget.ground['ownedByTeam']['teamName'][0]
                                          .toUpperCase() +
                                      widget.ground['ownedByTeam']['teamName']
                                          .substring(1)
                                  : 'No Team'
                              : 'No Team',
                          style: TextStyle(fontSize: 16, color: Colors.black54),
                          textAlign: TextAlign
                              .center, // Ensures text alignment inside the container
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),

                // Date Selector
                buildDateSelector(),

                // Session Selector
                buildSessionSelector(),
              ],
            ),
          ),
          bottomNavigationBar: buildBookNowButton(),
        ),

        // Full screen loader overlay
        if (isBooking) buildFullScreenLoader(),
      ],
    );
  }

  Widget buildDateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Selected Date Display (Above the Date Picker)

        Padding(
          padding: const EdgeInsets.all(16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              selectedDate.isNotEmpty
                  ? DateFormat('dd MMMM yyyy')
                      .format(DateTime.parse(selectedDate))
                  : "Select a date",
              style: const TextStyle(
                fontSize: 16, // Increased from 14
                fontWeight: FontWeight.w600,
                color:
                    Colors.black, // Changed from Colors.black54 to full black
              ),
            ),
          ),
        ),

        // Horizontal Date Picker
        Container(
          height: 80,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: upcomingDates.length,
            itemBuilder: (context, index) {
              String date = upcomingDates[index];
              DateTime dateTime = DateTime.parse(date);
              String day = DateFormat('E').format(dateTime); // Mon, Tue, etc.
              String dayNumber =
                  DateFormat('d').format(dateTime); // 30, 31, etc.

              return GestureDetector(
                onTap: () => setState(() => selectedDate = date),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: selectedDate == date
                        ? Colors.red.withOpacity(0.09)
                        : Colors.white,
                    // border: Border.all(
                    //   color: selectedDate == date ? Colors.red : Colors.grey,
                    //   width: 1, // 1px border
                    // ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        dayNumber, // Big font for the day number
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        day, // Small font for the weekday
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget buildSessionSelector() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Session",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              buildSessionButton("Morning"),
              const SizedBox(width: 10),
              buildSessionButton("Afternoon"),
              const SizedBox(width: 10),
              buildSessionButton("Evening"), // Added Evening
            ],
          ),
        ],
      ),
    );
  }

  Widget buildSessionButton(String session) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedSession = session.toLowerCase()),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            border: Border.all(
              color: selectedSession == session.toLowerCase()
                  ? Colors.red
                  : Colors.grey,
              width: 1, // Set border width to 1px
            ),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(
            child: Text(
              session,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildBookNowButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.grey[300]!,
            width: 1.0,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Fee display on left with some padding
          Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: Text(
              "₹${widget.ground["fee"] ?? 'N/A'}",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Book Now button on right (shorter)
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6.0),
              ),
            ),
            onPressed: isLoadingTeams ? null : bookGround,
            child: Text(isLoadingTeams ? "Loading..." : "Book Now",
                style: const TextStyle(fontSize: 16, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget buildFullScreenLoader() {
    return Container(
      color: Colors.black54,
      width: double.infinity,
      height: double.infinity,
      child: const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }
}
