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
      showErrorDialog(context, "Failed to load teams: $e");
    }
  }

  Future<void> bookGround() async {
    if (userTeams.isEmpty) {
      showErrorDialog(context, "No teams available for booking.");
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
      showErrorDialog(context, "Ground information is incomplete. Missing ID.");
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
          showErrorDialog(
            context,
            response["message"]?.toString() ??
                "Booking failed. Please try again.",
          );
        }
      }
    } catch (e) {
      // Handle any exceptions during booking
      if (mounted) {
        showErrorDialog(context, "Error during booking: $e");
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

  void showErrorDialog(BuildContext context, String? message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            "Oops!",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(message ?? "Something went wrong."),
          actions: [
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text("Close"),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          backgroundColor: const Color(0xFFF5F0ED),
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
                      top: 28,
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
                      top: 28,
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
                          // Container(
                          //   decoration: BoxDecoration(
                          //     color: Colors.white,
                          //     shape: BoxShape.circle,
                          //   ),
                          //   child: IconButton(
                          //     icon: Icon(Icons.favorite_border),
                          //     onPressed: () {
                          //       // Favorite functionality
                          //     },
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                  ],
                ),
                // Ground name and location with padding
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.ground["groundName"].isNotEmpty
                            ? widget.ground["groundName"]
                                .toUpperCase() // Changed to all caps
                            : "",
                        style: GoogleFonts.robotoCondensed(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                          widget.ground["location"] ?? "Location not specified",
                          style: const TextStyle(
                              fontSize: 16, color: Colors.black)),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),

                // Team name in a box with shadow and logo on left - NO side gaps
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        spreadRadius: 2,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Team Logo on the left
                      ClipRRect(
                        borderRadius: BorderRadius.circular(25),
                        child: Image.network(
                          widget.ground['ownedByTeam']?['teamLogo'] ?? "",
                          height: 50,
                          width: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: Icon(
                                Icons.sports_cricket,
                                size: 25,
                                color: Colors.grey[600],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Team Name on the right
                      Expanded(
                        child: Text(
                          widget.ground['ownedByTeam'] != null
                              ? widget.ground['ownedByTeam']['teamName']
                                      .toString()
                                      .isNotEmpty
                                  ? widget.ground['ownedByTeam']
                                              ['teamName'][0]
                                          .toUpperCase() +
                                      widget.ground['ownedByTeam']
                                              ['teamName']
                                          .substring(1)
                                  : 'No Team'
                              : 'No Team',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Date Selector
                buildDateSelector(),

                // Session Selector
                buildSessionSelector(),

                buildFacilitiesWidget(),
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
          Container(
            height: 45,
            decoration: BoxDecoration(
              color: Colors.grey[200], // Light background
              borderRadius: BorderRadius.circular(25),
            ),
            child: Stack(
              children: [
                // Animated background indicator
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  left: selectedSession == "morning"
                      ? 2
                      : null, // Changed to lowercase
                  right: selectedSession == "afternoon"
                      ? 2
                      : null, // Changed to lowercase
                  top: 2,
                  bottom: 2,
                  width: (MediaQuery.of(context).size.width - 36) / 2,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(23),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
                // Session options
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => selectedSession =
                            "morning"), // Changed to lowercase
                        child: Container(
                          height: 45,
                          alignment: Alignment.center,
                          child: Text(
                            "Morning", // Display text remains capitalized
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: selectedSession ==
                                      "morning" // Changed to lowercase
                                  ? Colors.black87
                                  : Colors.grey[600],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => selectedSession =
                            "afternoon"), // Changed to lowercase
                        child: Container(
                          height: 45,
                          alignment: Alignment.center,
                          child: Text(
                            "Afternoon", // Display text remains capitalized
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: selectedSession ==
                                      "afternoon" // Changed to lowercase
                                  ? Colors.black87
                                  : Colors.grey[600],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
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

  Widget buildFacilitiesWidget() {
    final List<dynamic> facilities = widget.ground['facilities'] ?? [];

    if (facilities.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text(
          'No facilities listed for this ground.',
          style: TextStyle(fontSize: 16, color: Colors.black54),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Facilities",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: facilities.map<Widget>((facility) {
              return Chip(
                label: Text(
                  facility.toString(),
                  style: const TextStyle(color: Colors.black87),
                ),
                backgroundColor: Colors.grey.shade200,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget buildBookNowButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, // Added white background to outer container
        border: Border(
          top: BorderSide(
            color: Colors.grey[300]!,
            width: 1.0,
          ),
        ),
      ),
      child: Row(
        // Removed the inner Container since outer container now has white background
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
