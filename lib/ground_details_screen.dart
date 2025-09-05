import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import 'booking_confirmation_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

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
        // Show error message - extract only the message text
        String errorMessage = "Booking failed. Please try again.";

        // Handle different response types
        String responseStr = response.toString();

        if (responseStr.contains('"message"')) {
          // Extract message using regex pattern
          RegExp messageRegex = RegExp(r'"message"\s*:\s*"([^"]*)"');
          Match? match = messageRegex.firstMatch(responseStr);

          if (match != null && match.group(1) != null) {
            errorMessage = match.group(1)!;
          } else {
            // Try alternative patterns
            RegExp altRegex = RegExp(r'"message":\s*"([^"]*)"');
            Match? altMatch = altRegex.firstMatch(responseStr);
            if (altMatch != null && altMatch.group(1) != null) {
              errorMessage = altMatch.group(1)!;
            }
          }
        } else if (response is Map && response["message"] != null) {
          errorMessage = response["message"].toString();
        }

        if (mounted) {
          showErrorDialog(context, errorMessage);
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

  void _shareGround() {
    final String groundName = widget.ground["groundName"] ?? "Cricket Ground";
    final String location = widget.ground["location"] ?? "Location";
    final String fee = widget.ground["fee"]?.toString() ?? "N/A";
    final String teamName =
        widget.ground['ownedByTeam']?['teamName'] ?? "Unknown Team";

    final String shareText = '''🏏 Check out this cricket ground!

📍 $groundName
📍 Location: $location
🏏 Owned by: $teamName  
💰 Fee: ₹$fee

Book now through Crickonnect App!''';

    // Copy to clipboard and show confirmation
    Clipboard.setData(ClipboardData(text: shareText)).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.content_copy, color: Colors.white, size: 20),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Ground details copied to clipboard!',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: EdgeInsets.all(16),
          elevation: 6,
          duration: Duration(seconds: 3),
        ),
      );
    });
  }

  void showErrorDialog(BuildContext context, String? message) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 10,
          backgroundColor: Colors.white,
          child: Container(
            constraints: BoxConstraints(maxWidth: 320),
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Error Icon
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.error_outline_rounded,
                    color: Colors.red.shade500,
                    size: 32,
                  ),
                ),
                SizedBox(height: 20),

                // Title
                Text(
                  "Oops!",
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12),

                // Message
                Text(
                  message ?? "Something went wrong. Please try again.",
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24),

                // Action Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade500,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "Got it",
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
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
                // Image with overlay buttons and gradient
                Stack(
                  children: [
                    // Image at the top
                    Container(
                      width: double.infinity,
                      height: 280,
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(
                              widget.ground["image"] ??
                                  'https://placeholder.com/ground',
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  color: Colors.grey[200],
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      value:
                                          loadingProgress.expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null,
                                      color: Colors.red,
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.red.shade300,
                                        Colors.red.shade600,
                                      ],
                                    ),
                                  ),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.sports_cricket,
                                          size: 48,
                                          color: Colors.white,
                                        ),
                                        SizedBox(height: 8),
                                        Text(
                                          "Ground Image",
                                          style: GoogleFonts.inter(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                            // Gradient overlay for better text readability
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withOpacity(0.3),
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.7),
                                  ],
                                  stops: [0.0, 0.5, 1.0],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Back button at top left with white background
                    Positioned(
                      top: 28,
                      left: 20,
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.arrow_back,
                            size: 20,
                            color: Colors.black87,
                          ),
                          onPressed: () => Navigator.pop(context),
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    ),

                    // Share icon at top right
                    // Positioned(
                    //   top: 28,
                    //   right: 20,
                    //   child: Container(
                    //     width: 38,
                    //     height: 38,
                    //     decoration: BoxDecoration(
                    //       color: Colors.white.withOpacity(0.9),
                    //       shape: BoxShape.circle,
                    //       boxShadow: [
                    //         BoxShadow(
                    //           color: Colors.black.withOpacity(0.1),
                    //           blurRadius: 4,
                    //           offset: Offset(0, 2),
                    //         ),
                    //       ],
                    //     ),
                    //     child: IconButton(
                    //       icon: Icon(
                    //         Icons.share,
                    //         size: 20,
                    //         color: Colors.black87,
                    //       ),
                    //       onPressed: _shareGround,
                    //       padding: EdgeInsets.zero,
                    //     ),
                    //   ),
                    // ),
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
                      const SizedBox(height: 8),
                      // Location with icon - smaller and lighter
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),
                          SizedBox(width: 4),
                          Text(
                            widget.ground["location"] ??
                                "Location not specified",
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Rating section
                      Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.orange.shade200),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star,
                              size: 16,
                              color: Colors.orange.shade600,
                            ),
                            SizedBox(width: 4),
                            Text(
                              "4.5",
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.orange.shade800,
                              ),
                            ),
                            SizedBox(width: 4),
                            Text(
                              "(24 reviews)",
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),

                // Team information card - NO side gaps
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 12,
                        spreadRadius: 0,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      // Team Logo with better fallback
                      Container(
                        height: 60,
                        width: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: Colors.grey.shade200,
                            width: 2,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(28),
                          child: widget.ground['ownedByTeam']?['teamLogo'] !=
                                      null &&
                                  widget.ground['ownedByTeam']['teamLogo']
                                      .toString()
                                      .isNotEmpty
                              ? Image.network(
                                  widget.ground['ownedByTeam']['teamLogo'],
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return _buildTeamLogoFallback();
                                  },
                                )
                              : _buildTeamLogoFallback(),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Team Information
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.ground['ownedByTeam'] != null &&
                                      widget.ground['ownedByTeam']['teamName']
                                          .toString()
                                          .isNotEmpty
                                  ? widget.ground['ownedByTeam']['teamName']
                                      .toString()
                                      .split(' ')
                                      .map((word) => word.isNotEmpty
                                          ? word[0].toUpperCase() +
                                              word.substring(1).toLowerCase()
                                          : word)
                                      .join(' ')
                                  : 'No Team Assigned',
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Ground Owner",
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Section Divider
                Container(
                  height: 8,
                  color: const Color(0xFFF5F0ED),
                ),

                // Date Selector
                buildDateSelector(),

                // Section Divider
                Container(
                  height: 8,
                  color: const Color(0xFFF5F0ED),
                ),

                // Session Selector
                buildSessionSelector(),

                // Section Divider
                Container(
                  height: 8,
                  color: const Color(0xFFF5F0ED),
                ),

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

  // Team logo fallback widget
  Widget _buildTeamLogoFallback() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.red.shade400,
            Colors.red.shade600,
          ],
        ),
      ),
      child: Center(
        child: Text(
          widget.ground['ownedByTeam'] != null &&
                  widget.ground['ownedByTeam']['teamName'].toString().isNotEmpty
              ? widget.ground['ownedByTeam']['teamName']
                  .toString()
                  .substring(0, 1)
                  .toUpperCase()
              : "T",
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget buildDateSelector() {
    DateTime today = DateTime.now();
    String currentMonth = "";
    List<Widget> dateWidgets = [];

    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Select Date",
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  selectedDate.isNotEmpty
                      ? DateFormat('EEEE, MMMM dd, yyyy')
                          .format(DateTime.parse(selectedDate))
                      : "Choose your preferred date",
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          // Enhanced Date Picker with month headers
          Container(
            height: 100,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: upcomingDates.length,
              itemBuilder: (context, index) {
                String date = upcomingDates[index];
                DateTime dateTime = DateTime.parse(date);
                String monthName = DateFormat('MMMM').format(dateTime);
                String day = DateFormat('E').format(dateTime);
                String dayNumber = DateFormat('d').format(dateTime);

                bool isSelected = selectedDate == date;
                bool isToday = DateFormat('yyyy-MM-dd').format(today) == date;
                bool isPast =
                    dateTime.isBefore(today.subtract(Duration(days: 1)));

                // Check if we need to show month header
                Widget monthHeader = Container();
                if (currentMonth != monthName) {
                  currentMonth = monthName;
                  monthHeader = Container(
                    margin:
                        EdgeInsets.only(right: 8, left: index == 0 ? 0 : 16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          monthName,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        Container(
                          width: 40,
                          height: 2,
                          margin: EdgeInsets.only(top: 4),
                          color: Colors.red.shade300,
                        ),
                      ],
                    ),
                  );
                }

                return Row(
                  children: [
                    if (currentMonth == monthName && index > 0) monthHeader,
                    GestureDetector(
                      onTap: isPast
                          ? null
                          : () => setState(() => selectedDate = date),
                      child: Container(
                        width: 70,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.red
                              : isPast
                                  ? Colors.grey.shade100
                                  : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? Colors.red
                                : isToday
                                    ? Colors.red.shade300
                                    : isPast
                                        ? Colors.grey.shade300
                                        : Colors.grey.shade200,
                            width: 2,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: Colors.red.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: Offset(0, 4),
                                  ),
                                ]
                              : isPast
                                  ? []
                                  : [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 4,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                dayNumber,
                                style: GoogleFonts.inter(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? Colors.white
                                      : isPast
                                          ? Colors.grey.shade400
                                          : Colors.black87,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                day,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: isSelected
                                      ? Colors.white.withOpacity(0.9)
                                      : isPast
                                          ? Colors.grey.shade400
                                          : Colors.grey.shade600,
                                ),
                              ),
                              if (isToday && !isSelected)
                                Container(
                                  margin: EdgeInsets.only(top: 2),
                                  width: 4,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget buildSessionSelector() {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Select Session",
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 4),
            Text(
              "Choose your preferred time slot",
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 16),
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
                              style: GoogleFonts.inter(
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
                              style: GoogleFonts.inter(
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

    return Container(
      color: Colors.white,
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Facilities & Amenities",
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 4),
          Text(
            facilities.isEmpty
                ? "No facilities information available"
                : "Available amenities at this ground",
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 16),
          facilities.isEmpty
              ? Container(
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 32,
                          color: Colors.grey.shade400,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'No facilities listed',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: facilities.map<Widget>((facility) {
                    return Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.blue.shade100),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getFacilityIcon(facility.toString()),
                            size: 16,
                            color: Colors.blue.shade600,
                          ),
                          SizedBox(width: 8),
                          Text(
                            facility.toString(),
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.blue.shade800,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
        ],
      ),
    );
  }

  IconData _getFacilityIcon(String facility) {
    String lower = facility.toLowerCase();
    if (lower.contains('parking')) return Icons.local_parking;
    if (lower.contains('restroom') || lower.contains('toilet')) return Icons.wc;
    if (lower.contains('water')) return Icons.water_drop;
    if (lower.contains('light') || lower.contains('flood'))
      return Icons.lightbulb;
    if (lower.contains('changing') || lower.contains('room'))
      return Icons.meeting_room;
    if (lower.contains('canteen') || lower.contains('food'))
      return Icons.restaurant;
    if (lower.contains('first aid')) return Icons.medical_services;
    if (lower.contains('security')) return Icons.security;
    return Icons.star;
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
