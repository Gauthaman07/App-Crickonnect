import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:flutter/cupertino.dart';

class GroundRequestTab extends StatefulWidget {
  const GroundRequestTab({super.key});

  @override
  _GroundRequestTabState createState() => _GroundRequestTabState();
}

String _capitalize(String text) {
  if (text.isEmpty) return text;

  return text.split(" ").map((word) {
    if (word.isEmpty) return "";
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  }).join(" ");
}

class _GroundRequestTabState extends State<GroundRequestTab> {
  String _getDisplayStatus(String status) {
    switch (status.toLowerCase()) {
      case 'booked':
        return 'CONFIRMED';
      case 'pending':
        return 'PENDING';
      case 'rejected':
        return 'CANCELLED';
      default:
        return status.toUpperCase();
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'booked':
        return Colors.green.shade600;
      case 'pending':
        return Colors.orange.shade600;
      case 'rejected':
        return Colors.red.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'booked':
        return 'Booking confirmed!';
      case 'pending':
        return 'Awaiting your response';
      case 'rejected':
        return 'Request declined';
      default:
        return 'Status updated';
    }
  }

  String _getUserStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'booked':
        return 'Get ready!';
      case 'pending':
        return 'Opponents are huddling...';
      case 'rejected':
        return 'Try another slot';
      default:
        return 'Status updated';
    }
  }

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
              CupertinoActivityIndicator(
                radius: 12, // Smaller size
                color: Colors.grey.shade600, // Metal silver color
              ),
              SizedBox(height: 16),
              Text(
                'Processing request...',
                style: TextStyle(fontSize: 16),
              ),
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
        child: CupertinoActivityIndicator(
          radius: 12, // Smaller size
          color: Colors.grey.shade600, // Metal silver color
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
        // Section Header - Updated to be smaller and left-aligned
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Pending Requests",
              style: TextStyle(
                fontSize: 14, // Reduced from 18
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
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
        // Section Header - Updated to be smaller and left-aligned
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Your Bookings",
              style: TextStyle(
                fontSize: 14, // Already small, kept same
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
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
// 1. PENDING BOOKING CARD - for ground owner (corrected)
  Widget _buildPendingBookingCard(Map<String, dynamic> booking) {
    final String teamName = booking['teamName'] ?? "Unknown";
    final String date = booking['date'] ?? "No date";
    final String time = booking['timeSlot'] ?? "No time";
    final String status = booking['status'] ?? "Unknown";
    final String teamLogo =
        booking['teamLogo'] ?? ""; // Changed from groundImage to teamLogo
    final String bookingId = _extractBookingId(booking);

    // Convert status to display format
    String displayStatus = _getDisplayStatus(status);
    Color statusColor = _getStatusColor(status);
    String statusText = _getStatusText(status);

    // Check if buttons should be shown (only for pending status)
    bool showButtons = status.toLowerCase() == "pending";

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Main content section (above the line)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Team logo (left side) - Changed from ground image
                Container(
                  width: 80,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey.shade200,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: teamLogo.isNotEmpty
                        ? Image.network(
                            teamLogo,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                              color: Colors.red.shade100,
                              child: Icon(
                                Icons.group, // Changed icon to represent team
                                color: Colors.red.shade600,
                                size: 32,
                              ),
                            ),
                          )
                        : Container(
                            color: Colors.red.shade100,
                            child: Icon(
                              Icons.group, // Team icon instead of soccer ball
                              color: Colors.red.shade600,
                              size: 32,
                            ),
                          ),
                  ),
                ),

                const SizedBox(width: 16),

                // Content (right side)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Team name (main title)
                      Text(
                        _capitalize(teamName),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 12),

                      // Date and time (prominent display)
                      Text(
                        "${date.toUpperCase()} | ${time.toUpperCase()}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Thin divider line
          Container(
            height: 1,
            color: Colors.grey.shade300,
            margin: const EdgeInsets.symmetric(horizontal: 16),
          ),

          // Action section (below the line)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Only show status and text if NO buttons are available
                if (!showButtons)
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          displayStatus,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          statusText,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),

                // Show spacing between status and buttons if both exist
                if (!showButtons) const SizedBox(height: 16),

                // Action buttons for ground owner (only if pending)
                if (showButtons)
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: isActionInProgress || bookingId.isEmpty
                              ? null
                              : () => handleBookingAction(bookingId, false),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red.shade600,
                            side: BorderSide(color: Colors.red.shade300),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text(
                            "Reject",
                            style: TextStyle(fontWeight: FontWeight.w600),
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
                            backgroundColor: Colors.green.shade600,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text(
                            "Accept",
                            style: TextStyle(fontWeight: FontWeight.w600),
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

  // 2. USER BOOKING CARD - completely different UI for user bookings
  Widget _buildUserBookingCard(Map<String, dynamic> booking) {
    final String teamName = booking['teamName'] ?? "Unknown";
    final String groundName = booking['groundName'] ?? "Unknown";
    final String date = booking['date'] ?? "No date";
    final String time = booking['timeSlot'] ?? "No time";
    final String status = booking['status'] ?? "Unknown";
    final String groundImage = booking['groundImg'] ?? "";
    final String fee = booking['groundFee']?.toString() ?? "";

    // Convert status to display format
    String displayStatus = _getDisplayStatus(status);
    Color statusColor = _getStatusColor(status);
    String statusText = _getUserStatusText(status);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Main content section (above the line)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ground image (left side)
                Container(
                  width: 80,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey.shade200,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: groundImage.isNotEmpty
                        ? Image.network(
                            groundImage,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                              color: Colors.blue.shade100,
                              child: Icon(
                                Icons.sports_soccer,
                                color: Colors.blue.shade600,
                                size: 32,
                              ),
                            ),
                          )
                        : Container(
                            color: Colors.blue.shade100,
                            child: Icon(
                              Icons.sports_soccer,
                              color: Colors.blue.shade600,
                              size: 32,
                            ),
                          ),
                  ),
                ),

                const SizedBox(width: 16),

                // Content (right side)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Ground name (main title)
                      Text(
                        _capitalize(groundName),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 4),

                      // Team name (subtitle)
                      Text(
                        _capitalize(teamName),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 12),

                      // Date and time
                      Text(
                        "${date.toUpperCase()} | ${time.toUpperCase()}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Price
                      Text(
                        "₹ $fee",
                        style: const TextStyle(
                          fontSize: 18,
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

          // Thin divider line
          Container(
            height: 1,
            color: Colors.grey.shade300,
            margin: const EdgeInsets.symmetric(horizontal: 16),
          ),

          // Status section (below the line)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    displayStatus,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
