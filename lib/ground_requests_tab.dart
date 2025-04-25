import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class GroundRequestTab extends StatefulWidget {
  const GroundRequestTab({super.key});

  @override
  _GroundRequestTabState createState() => _GroundRequestTabState();
}

String _capitalizeFirstLetter(String text) {
  if (text.isEmpty) {
    return text;
  }
  return text[0].toUpperCase() + text.substring(1);
}

class _GroundRequestTabState extends State<GroundRequestTab> {
  // Data structures
  List<Map<String, dynamic>> userBookings = [];
  List<Map<String, dynamic>> pendingBookings = [];
  bool isLoading = true;
  bool isActionInProgress = false;

  // Configuration
  String selectedLocation = "Tirupur";

  @override
  void initState() {
    super.initState();
    fetchBookings();
  }

  // DATA FETCHING METHODS
  Future<void> fetchBookings() async {
    setState(() => isLoading = true);
    try {
      final data = await ApiService.fetchGrounds(selectedLocation);

      // Extract your ground data
      final Map<String, dynamic>? yourGround = data["yourGround"];

      setState(() {
        // Extract pending bookings
        pendingBookings = yourGround?["pendingBookings"] != null
            ? List<Map<String, dynamic>>.from(yourGround!["pendingBookings"])
            : [];

        // Extract user bookings
        userBookings = data["userBookings"] ?? [];
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      print("Error: $e");
    }
  }

  // ACTIONS
  Future<void> handleBookingAction(String bookingId, bool accept) async {
    print("\n🏁 Action started 🏁");
    print("BookingId: '$bookingId'");
    print("Action: ${accept ? 'Accept' : 'Reject'}");

    // Validation
    if (bookingId.isEmpty) {
      print("❌ ERROR: BookingId is empty! ❌");
      _showErrorSnackBar('Error: Booking ID is missing');
      return;
    }

    if (isActionInProgress) {
      print("⚠️ Action already in progress, ignoring request ⚠️");
      return;
    }

    setState(() {
      isActionInProgress = true;
    });

    final String status = accept ? "booked" : "rejected";
    print("Status to set: $status");

    try {
      // Show loading indicator
      _showLoadingDialog();

      // Call the API service
      print("📞 Calling API service 📞");
      final ApiService apiService = ApiService();
      final bool success =
          await apiService.updateBookingStatus(bookingId, status);

      // Close loading dialog
      Navigator.of(context).pop();

      if (success) {
        print("✅ Action completed successfully ✅");
        _showActionSuccessSnackBar(accept);
        print("🔄 Refreshing bookings data 🔄");
        await fetchBookings();
      } else {
        print("❌ API returned failure ❌");
        _showErrorSnackBar('Failed to update booking status');
      }
    } catch (e, stackTrace) {
      print("⚠️ Exception in handleBookingAction ⚠️");
      print("Error: $e");
      print("Stack trace: $stackTrace");

      // Close loading dialog if open
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }

      _showErrorSnackBar('Error: $e');
    } finally {
      setState(() {
        isActionInProgress = false;
      });
      print("🏁 Action completed 🏁\n");
    }
  }

  // UI HELPER METHODS
  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LoadingAnimationWidget.threeArchedCircle(
                      color: Colors.red, // Main color for the arcs
                      size: 40, // Size of the loader
                    ),
                    SizedBox(height: 16),
                    Text('Processing request...',
                        style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Text('Processing request...'),
            ],
          ),
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showActionSuccessSnackBar(bool isAccepted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Booking ${isAccepted ? "accepted" : "rejected"} successfully'),
        backgroundColor: isAccepted ? Colors.green : Colors.red,
      ),
    );
  }

  String _capitalize(String text) {
    return text.split(" ").map((word) {
      if (word.isEmpty) return "";
      return word[0].toUpperCase() + word.substring(1);
    }).join(" ");
  }

  // BOOKING DATA EXTRACTION
  String _extractBookingId(Map<String, dynamic> booking) {
    // Check all possible key variations for bookingId
    return booking['bookingId'] ?? booking['_id'] ?? booking['id'] ?? "";
  }

  // MAIN BUILD METHOD
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(
        child: LoadingAnimationWidget.threeArchedCircle(
          color: Colors.red, // Main color for the arcs
          size: 40, // Size of the loader
        ),
      );
    }

    if (pendingBookings.isEmpty && userBookings.isEmpty) {
      return Center(child: Text("No Requests", style: TextStyle(fontSize: 18)));
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          // Pending Bookings Section (with its own UI)
          if (pendingBookings.isNotEmpty) _buildPendingBookingsSection(),

          // User Bookings Section (with different UI)
          if (userBookings.isNotEmpty) _buildUserBookingsSection(),
        ],
      ),
    );
  }

  // SECTION BUILDERS - Now completely separate for the two booking types
  Widget _buildPendingBookingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: Center(
            child: Text(
              "Pending Requests",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ),
        ),
        // List of Pending Booking Cards
        ...pendingBookings.map((booking) => _buildPendingBookingCard(booking)),
      ],
    );
  }

  Widget _buildUserBookingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: Center(
            child: Text(
              "Your Bookings",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'Boldonse',
                color: Colors.red,
              ),
            ),
          ),
        ),
        // List of User Booking Cards
        ...userBookings.map((booking) => _buildUserBookingCard(booking)),
      ],
    );
  }

  // COMPLETELY SEPARATE CARD BUILDERS FOR EACH TYPE

  // 1. PENDING BOOKING CARD - includes accept/reject actions
  Widget _buildPendingBookingCard(Map<String, dynamic> booking) {
    // Extract data specific to pending bookings
    final String teamName = booking['teamName'] ?? "Unknown";
    final String date = booking['date'] ?? "No date";
    final String time = booking['timeSlot'] ?? "No time";
    final String status = booking['status'] ?? "Unknown";
    final String teamLogo = booking['teamLogo'] ?? "";
    final String fee = booking['groundFee']?.toString() ?? "";
    final String bookingId = _extractBookingId(booking);

    print("Extracted bookingId for pending booking: $bookingId");

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(
          vertical: 18, horizontal: 20), // Increased vertical margin
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            // Top section - Team info
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18), // Increased padding
              color: Colors.white,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Team logo
                  Container(
                    width: 75, // Increased from 70
                    height: 90, // Increased from 85
                    decoration: BoxDecoration(
                      color: teamLogo.isNotEmpty ? null : Colors.red.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: teamLogo.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              teamLogo,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Center(
                                child: Icon(Icons.sports_soccer,
                                    color: Colors.red,
                                    size: 34), // Increased icon size
                              ),
                            ),
                          )
                        : const Center(
                            child: Icon(Icons.sports_soccer,
                                color: Colors.red,
                                size: 34), // Increased icon size
                          ),
                  ),
                  const SizedBox(width: 16),
                  // Team details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _capitalize(teamName),
                          style: const TextStyle(
                            fontSize: 20, // Increased from 19
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "$date | $time",
                          style: const TextStyle(
                            fontSize: 16, // Increased from 15
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Status: ${_capitalize(status)}",
                          style: TextStyle(
                            fontSize: 15, // Increased from 14
                            fontWeight: FontWeight.w600,
                            color: status.toLowerCase() == "booked"
                                ? Colors.green
                                : Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Booking label
                  Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(color: Colors.grey.shade200, width: 1),
                      ),
                    ),
                    child: RotatedBox(
                      quarterTurns: 3,
                      child: Text(
                        "Request",
                        style: TextStyle(
                          fontSize: 13, // Increased from 12
                          color: Colors.grey.shade500,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Dotted separator
            Container(
              height: 1,
              color: Colors.grey.shade300,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Flex(
                    direction: Axis.horizontal,
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(
                      (constraints.constrainWidth() / 10).floor(),
                      (index) => Container(
                        height: 1,
                        width: 5,
                        color: Colors.white,
                      ),
                    ),
                  );
                },
              ),
            ),

            // Action buttons - Only for pending bookings
            if (status.toLowerCase() !=
                "booked") // Hide buttons if status is "booked"
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    vertical: 18, horizontal: 20), // Increased vertical padding
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      offset: const Offset(0, -2),
                      blurRadius: 8,
                    ),
                  ],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: isActionInProgress || bookingId.isEmpty
                            ? null
                            : () => handleBookingAction(bookingId, false),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.red.shade700,
                          disabledBackgroundColor: Colors.grey.shade100,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(
                              color: isActionInProgress || bookingId.isEmpty
                                  ? Colors.grey.shade300
                                  : Colors.red.shade500,
                              width: 1.5,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                              vertical: 14), // Increased from 12
                        ),
                        child: Text(
                          "Decline",
                          style: TextStyle(
                            fontSize: 15, // Increased from 14
                            fontWeight: FontWeight.w600,
                            color: isActionInProgress || bookingId.isEmpty
                                ? Colors.grey.shade500
                                : Colors.red.shade700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: isActionInProgress || bookingId.isEmpty
                            ? null
                            : () => handleBookingAction(bookingId, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.green.shade700,
                          disabledBackgroundColor: Colors.grey.shade100,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(
                              color: isActionInProgress || bookingId.isEmpty
                                  ? Colors.grey.shade300
                                  : Colors.green.shade500,
                              width: 1.5,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                              vertical: 14), // Increased from 12
                        ),
                        child: Text(
                          "Accept",
                          style: TextStyle(
                            fontSize: 15, // Increased from 14
                            fontWeight: FontWeight.w600,
                            color: isActionInProgress || bookingId.isEmpty
                                ? Colors.grey.shade500
                                : Colors.green.shade700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // 2. USER BOOKING CARD - completely different UI for user bookings
  Widget _buildUserBookingCard(Map<String, dynamic> booking) {
    // Extract data specific to user bookings
    final String teamName = booking['teamName'] ?? "Unknown";
    final String groundName = booking['groundName'] ?? "Unknown";
    final String date = booking['date'] ?? "No date";
    final String time = booking['timeSlot'] ?? "No time";
    final String status = booking['status'] ?? "Unknown";
    final String groundImage = booking['groundImg'] ?? "";
    final String fee = booking['groundFee']?.toString() ?? "";
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(
          vertical: 18, horizontal: 20), // Increased vertical margin
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            // Top section - Team info
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18), // Increased padding
              color: Colors.white,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Team logo - increased dimensions
                  Container(
                    width: 75, // Increased from 70
                    height: 90, // Increased from 85
                    decoration: BoxDecoration(
                      color:
                          groundImage.isNotEmpty ? null : Colors.red.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: groundImage.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              groundImage,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Center(
                                child: Icon(Icons.sports_soccer,
                                    color: Colors.red,
                                    size: 34), // Increased icon size
                              ),
                            ),
                          )
                        : const Center(
                            child: Icon(Icons.sports_soccer,
                                color: Colors.red,
                                size: 34), // Increased icon size
                          ),
                  ),
                  const SizedBox(width: 16),
                  // Team details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _capitalize(groundName),
                          style: const TextStyle(
                            fontSize: 20, // Increased from 19
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _capitalize(teamName),
                          style: TextStyle(
                            fontSize: 15, // Increased from 14
                            color: Colors.grey.shade600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "${_capitalizeFirstLetter(date)} | $time",
                          style: const TextStyle(
                            fontSize: 15, // Increased from 14
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          " ${_capitalize(status)}",
                          style: TextStyle(
                            fontSize: 15, // Increased from 14
                            fontWeight: FontWeight.w600,
                            color: status.toLowerCase() == 'pending'
                                ? Colors.orange
                                : Colors.green, // Conditional color
                          ),
                        )
                      ],
                    ),
                  ),
                  // Booking label
                  Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(color: Colors.grey.shade200, width: 1),
                      ),
                    ),
                    child: RotatedBox(
                      quarterTurns: 3,
                      child: Text(
                        "Booking",
                        style: TextStyle(
                          fontSize: 13, // Increased from 12
                          color: Colors.grey.shade500,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Dotted separator
            Container(
              height: 1,
              color: Colors.grey.shade300,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Flex(
                    direction: Axis.horizontal,
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(
                      (constraints.constrainWidth() / 10).floor(),
                      (index) => Container(
                        height: 1,
                        width: 5,
                        color: Colors.white,
                      ),
                    ),
                  );
                },
              ),
            ),

            // Amount section
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14), // Increased vertical padding
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Fee",
                    style: TextStyle(
                      fontSize: 17, // Increased from 16
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    "₹ $fee",
                    style: const TextStyle(
                      fontSize: 17, // Increased from 16
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
