import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'package:google_fonts/google_fonts.dart';

class GroundRequestTab extends StatefulWidget {
  const GroundRequestTab({super.key});

  @override
  _GroundRequestTabState createState() => _GroundRequestTabState();
}

class _GroundRequestTabState extends State<GroundRequestTab> {
  List<Map<String, dynamic>> groupedRequests = [];
  List<Map<String, dynamic>> confirmedMatches = [];
  List<Map<String, dynamic>> userBookings = [];
  bool isLoading = true;
  String? error;
  bool hasGround = false;

  @override
  void initState() {
    super.initState();
    checkUserGroundStatus();
  }

  Future<void> checkUserGroundStatus() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      // Check if user has ground by getting team info
      final teamResponse = await ApiService.getMyTeam();

      if (teamResponse != null && teamResponse['team'] != null) {
        bool userHasGround = teamResponse['team']['hasOwnGround'] == true;

        setState(() {
          hasGround = userHasGround;
        });

        if (userHasGround) {
          // User has ground - fetch pending requests for ground owners
          await fetchPendingRequests();
        } else {
          // User doesn't have ground - fetch their booking requests
          await fetchUserBookings();
        }
      } else {
        setState(() {
          error = 'Failed to get team information';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error: $e';
        isLoading = false;
      });
    }
  }

  Future<void> fetchPendingRequests() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      // Fetch the new grouped ground requests
      final response = await ApiService.getPendingGroundRequests();

      if (response != null && response['success'] == true) {
        setState(() {
          groupedRequests =
              List<Map<String, dynamic>>.from(response['pendingRequests'] ?? []);
          confirmedMatches =
              List<Map<String, dynamic>>.from(response['confirmedMatches'] ?? []);
          isLoading = false;
        });
      } else {
        setState(() {
          error = response?['message'] ?? 'Failed to fetch requests';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error: $e';
        isLoading = false;
      });
    }
  }

  Future<void> fetchUserBookings() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final response = await ApiService.getUserBookings();

      if (response != null && response['success'] == true) {
        setState(() {
          userBookings =
              List<Map<String, dynamic>>.from(response['bookings'] ?? []);
          isLoading = false;
        });
      } else {
        setState(() {
          error = response?['message'] ?? 'Failed to fetch your bookings';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error: $e';
        isLoading = false;
      });
    }
  }

  Future<void> respondToRequest(
      List<String> requestIds, String status, String? responseNote) async {
    try {
      final response = await ApiService.respondToGroundBookings(
        requestIds: requestIds,
        status: status,
        responseNote: responseNote,
      );

      if (response != null && response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                response['message'] ?? 'Request(s) ${status} successfully'),
            backgroundColor:
                status == 'booked' ? Colors.green : Colors.orange,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );

        // Refresh the appropriate data based on user type
        await checkUserGroundStatus();
      } else {
        throw Exception(response?['message'] ?? 'Response failed');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error responding to request: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  void showResponseDialog(Map<String, dynamic> request) {
    final TextEditingController noteController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            constraints: BoxConstraints(maxWidth: 400),
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  Colors.grey.shade50,
                ],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.sports_cricket,
                        color: Colors.blue.shade600,
                        size: 20,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Respond to Request',
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800,
                            ),
                          ),
                          Text(
                            _getMatchDisplayText(request),
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 20),

                // Match details card
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.calendar_today,
                              size: 16, color: Colors.grey.shade600),
                          SizedBox(width: 8),
                          Text(
                            '${request['date']} - ${request['timeSlot'].toString().toUpperCase()}',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.location_on,
                              size: 16, color: Colors.grey.shade600),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              request['groundLocation'] ?? 'Ground Location',
                              style: GoogleFonts.inter(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 16),

                // Response note field
                TextField(
                  controller: noteController,
                  decoration: InputDecoration(
                    labelText: 'Response Note (Optional)',
                    hintText: 'Add a note for the teams...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: Colors.blue.shade400, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  maxLines: 3,
                  style: GoogleFonts.inter(fontSize: 14),
                ),

                SizedBox(height: 24),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey.shade400),
                          foregroundColor: Colors.grey.shade700,
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          respondToRequest(request['requestIds'].cast<String>(),
                              'rejected', noteController.text.trim());
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.red.shade300),
                          foregroundColor: Colors.red.shade600,
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Reject',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          respondToRequest(request['requestIds'].cast<String>(),
                              'booked', noteController.text.trim());
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade500,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 14),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Approve',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getMatchDisplayText(Map<String, dynamic> request) {
    switch (request['type']) {
      case 'challenge_match':
        return '${request['teamA']['name']} vs Your Team';
      case 'host_match_complete':
        return '${request['teamA']['name']} vs ${request['teamB']['name']}';
      case 'host_match_waiting':
        return '${request['teamA']['name']} waiting for opponent';
      default:
        return '${request['teamA']['name']} - Regular Booking';
    }
  }

  String _getTeamVsText(Map<String, dynamic> request) {
    switch (request['type']) {
      case 'challenge_match':
        return '${request['teamA']['name']} vs Your Team';
      case 'host_match_complete':
        return '${request['teamA']['name']} vs ${request['teamB']['name']}';
      case 'host_match_waiting':
        return '${request['teamA']['name']} vs TBD';
      default:
        return request['teamA']['name'];
    }
  }

  String _getTeamAName(Map<String, dynamic> request) {
    return request['teamA']['name'] ?? 'Team A';
  }

  String _getTeamBName(Map<String, dynamic> request) {
    switch (request['type']) {
      case 'challenge_match':
        return request['groundOwnerTeam']?['name'] ?? 'Your Team';
      case 'host_match_complete':
        return request['teamB']?['name'] ?? 'Team B';
      case 'host_match_waiting':
        return 'TBD';
      default:
        return 'Team B';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(color: Colors.blue.shade600),
      );
    }

    if (error != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red.shade400,
              ),
              SizedBox(height: 16),
              Text(
                error!,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: Colors.red.shade600,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: checkUserGroundStatus,
                child: Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (hasGround && groupedRequests.isEmpty && confirmedMatches.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 80,
              color: Colors.grey.shade400,
            ),
            SizedBox(height: 16),
            Text(
              'No Pending Requests',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Ground booking requests will appear here',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    if (!hasGround && userBookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sports_cricket,
              size: 80,
              color: Colors.grey.shade400,
            ),
            SizedBox(height: 16),
            Text(
              'No Match Requests',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Your match requests will appear here',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: checkUserGroundStatus,
      color: Colors.blue.shade600,
      child: hasGround
          ? SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Pending Requests Section
                  if (groupedRequests.isNotEmpty) ...[
                    _buildSectionHeader(
                      'Pending Requests', 
                      groupedRequests.length,
                      Colors.orange.shade600,
                      Icons.pending_actions,
                    ),
                    SizedBox(height: 12),
                    ...groupedRequests.map((request) {
                      switch (request['type']) {
                        case 'challenge_match':
                          return _buildChallengeCard(request);
                        case 'host_match_complete':
                          return _buildCompleteHostCard(request);
                        case 'host_match_waiting':
                          return _buildWaitingHostCard(request);
                        default:
                          return _buildRegularCard(request);
                      }
                    }).toList(),
                    SizedBox(height: 24),
                  ],
                  
                  // Confirmed Matches Section
                  if (confirmedMatches.isNotEmpty) ...[
                    _buildSectionHeader(
                      'Confirmed Matches', 
                      confirmedMatches.length,
                      Colors.green.shade600,
                      Icons.check_circle,
                    ),
                    SizedBox(height: 12),
                    ...confirmedMatches.map((match) => _buildConfirmedMatchCard(match)).toList(),
                  ],
                ],
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: userBookings.length,
              itemBuilder: (context, index) {
                final booking = userBookings[index];
                return _buildUserBookingCard(booking);
              },
            ),
    );
  }

  // Challenge Match Card - Clean white card
  Widget _buildChallengeCard(Map<String, dynamic> request) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            spreadRadius: 1,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: _buildCardContent(
        request: request,
        icon: Icons.sports_kabaddi,
        iconColor: Color(0xFF15151E),
        iconBgColor: Color(0xFFF5F0ED),
        title: 'Challenge Request',
        subtitle: 'They want to challenge your team!',
        titleColor: Color(0xFF15151E),
        accentColor: Color(0xFF15151E),
      ),
    );
  }

  // Complete Host Match Card - Clean white card
  Widget _buildCompleteHostCard(Map<String, dynamic> request) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            spreadRadius: 1,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: _buildCardContent(
        request: request,
        icon: Icons.sports_cricket,
        iconColor: Colors.blue.shade600,
        iconBgColor: Colors.blue.shade50,
        title: 'Host Match Request',
        subtitle: 'Two teams ready to play at your ground',
        titleColor: Colors.blue.shade700,
        accentColor: Colors.blue.shade600,
      ),
    );
  }

  // Waiting Host Match Card - Clean white card
  Widget _buildWaitingHostCard(Map<String, dynamic> request) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            spreadRadius: 1,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: _buildCardContent(
        request: request,
        icon: Icons.hourglass_empty,
        iconColor: Colors.grey.shade600,
        iconBgColor: Colors.grey.shade100,
        title: 'Looking for Opponent',
        subtitle: 'Waiting for another team to join',
        titleColor: Colors.grey.shade700,
        accentColor: Colors.grey.shade600,
        showApprovalButtons: false,
      ),
    );
  }

  // Regular Booking Card - Clean white card
  Widget _buildRegularCard(Map<String, dynamic> request) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            spreadRadius: 1,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: _buildCardContent(
        request: request,
        icon: Icons.sports_cricket,
        iconColor: Colors.green.shade600,
        iconBgColor: Colors.green.shade50,
        title: 'Ground Booking',
        subtitle: 'Regular ground rental request',
        titleColor: Colors.green.shade700,
        accentColor: Colors.green.shade600,
      ),
    );
  }

  Widget _buildCardContent({
    required Map<String, dynamic> request,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    required Color titleColor,
    required Color accentColor,
    bool showApprovalButtons = true,
  }) {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: titleColor,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: request['status'] == 'ready_for_approval'
                      ? Colors.green.shade100
                      : Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  request['status'] == 'ready_for_approval'
                      ? 'READY'
                      : 'WAITING',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: request['status'] == 'ready_for_approval'
                        ? Colors.green.shade700
                        : Colors.orange.shade700,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 20),

          // Team vs Team vertical display
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                Text(
                  _getTeamAName(request),
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  'vs',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  _getTeamBName(request),
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          SizedBox(height: 16),

          // Match details
          Row(
            children: [
              Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade600),
              SizedBox(width: 8),
              Text(
                '${request['date']} • ${request['timeSlot'].toString().toUpperCase()}',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),

          SizedBox(height: 8),

          Row(
            children: [
              Icon(Icons.location_on, size: 16, color: Colors.grey.shade600),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  request['groundLocation'] ?? 'Ground Location',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ),

          if (showApprovalButtons &&
              request['status'] == 'ready_for_approval') ...[
            SizedBox(height: 20),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => respondToRequest(
                        request['requestIds'].cast<String>(), 'rejected', null),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.red.shade300),
                      foregroundColor: Colors.red.shade600,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Reject',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () => respondToRequest(
                        request['requestIds'].cast<String>(), 'booked', null),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Accept',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // User Booking Card - Shows status of user's own requests
  Widget _buildUserBookingCard(Map<String, dynamic> booking) {
    Color statusColor;
    String statusText;
    String statusMessage;

    switch (booking['status']?.toLowerCase()) {
      case 'booked':
        statusColor = Colors.green.shade600;
        statusText = 'ACCEPTED';
        statusMessage = 'Get Ready! Match is on';
        break;
      case 'rejected':
        statusColor = Colors.red.shade600;
        statusText = 'REJECTED';
        statusMessage = 'Sorry, request was declined';
        break;
      default:
        statusColor = Colors.orange.shade600;
        statusText = 'PENDING';
        statusMessage = 'Waiting for ground owner approval';
    }

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            spreadRadius: 1,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main content layout - image left, details right
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ground image
                Container(
                  width: 80,
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey.shade200,
                  ),
                  child: booking['groundImage'] != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            booking['groundImage'],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.sports_cricket,
                                  color: Colors.grey.shade600,
                                  size: 30,
                                ),
                              );
                            },
                          ),
                        )
                      : Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.sports_cricket,
                            color: Colors.grey.shade600,
                            size: 30,
                          ),
                        ),
                ),
                SizedBox(width: 16),

                // All details on right side
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Ground name and team info
                      Text(
                        booking['groundName'] ?? 'Ground Name',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2),
                      Text(
                        _getUserBookingTeamsText(booking),
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                      SizedBox(height: 12),

                      // Date and time
                      Text(
                        '${_formatDate(booking['bookedDate'])} | ${_formatTimeSlot(booking['timeSlot'])}',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),

                      SizedBox(height: 4),

                      // Location
                      Text(
                        booking['groundLocation'] ?? 'Ground Location',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 20),

            // Thin divider line
            Transform.translate(
              offset: Offset(-20, 0),
              child: Container(
                height: 1,
                width: MediaQuery.of(context).size.width,
                color: Colors.grey.shade300,
              ),
            ),

            SizedBox(height: 16),

            // Status section at bottom
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    statusText,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    statusMessage,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ),

            if (booking['responseNote'] != null &&
                booking['responseNote'].toString().isNotEmpty) ...[
              SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ground Owner Note:',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      booking['responseNote'],
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.blue.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Date';
    try {
      final date = DateTime.parse(dateString);
      final weekday =
          ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'][date.weekday % 7];
      final day = date.day.toString().padLeft(2, '0');
      final month = [
        '',
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ][date.month];
      final year = date.year;
      return '$weekday, $day $month, $year';
    } catch (e) {
      return dateString;
    }
  }

  String _formatTimeSlot(String? timeSlot) {
    if (timeSlot == null) return 'TIME';
    return timeSlot.toUpperCase();
  }

  String _getUserBookingSubtitle(Map<String, dynamic> booking) {
    switch (booking['availabilityMode']) {
      case 'owner_play':
        return 'Challenge match request';
      case 'host_only':
        return 'Host match request';
      default:
        return 'Ground booking request';
    }
  }

  String _getUserBookingTeamsText(Map<String, dynamic> booking) {
    switch (booking['matchType']) {
      case 'owner_play':
        return booking['groundOwner'] ?? 'Ground Owner';
      case 'host_only':
        if (booking['opponentTeam'] != null) {
          return booking['opponentTeam']['name'];
        } else {
          return 'TBD';
        }
      default:
        return booking['teamName'];
    }
  }

  // Section Header Widget
  Widget _buildSectionHeader(String title, int count, Color color, IconData icon) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                '$count ${count == 1 ? 'item' : 'items'}',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Confirmed Match Card Widget
  Widget _buildConfirmedMatchCard(Map<String, dynamic> match) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Match Type Badge (top left only)
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _getMatchTypeColor(match['type'])['background'],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _getMatchTypeText(match['type']),
                  style: GoogleFonts.inter(
                    fontSize: 8,
                    fontWeight: FontWeight.w600,
                    color: _getMatchTypeColor(match['type'])['text'],
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: 12),
          
          // Teams
          Row(
            children: [
              Expanded(
                child: Text(
                  _getConfirmedTeamAName(match),
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              Text(
                'vs',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Expanded(
                child: Text(
                  _getConfirmedTeamBName(match),
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
          
          SizedBox(height: 8),
          
          // Ground and Location
          Text(
            '${match['groundName']} • ${match['groundLocation']}',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
          
          SizedBox(height: 8),
          
          // Date and Time
          Text(
            '${match['date']} • ${match['timeSlot'].toUpperCase()}',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          
          SizedBox(height: 12),
          
          // Divider
          Container(
            height: 0.5,
            width: double.infinity,
            color: Colors.grey.shade300,
          ),
          
          SizedBox(height: 12),
          
          // CONFIRMED Badge with text
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'CONFIRMED',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(width: 8),
              Text(
                'Get Ready! Match is scheduled',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getMatchTypeText(String type) {
    switch (type) {
      case 'challenge_match':
        return 'CHALLENGE';
      case 'host_match':
      case 'host_match_single':
        return 'HOSTING';
      default:
        return 'BOOKING';
    }
  }

  Map<String, Color> _getMatchTypeColor(String type) {
    switch (type) {
      case 'challenge_match':
        return {
          'background': Colors.orange.shade100,
          'text': Colors.orange.shade700,
        };
      case 'host_match':
      case 'host_match_single':
        return {
          'background': Colors.blue.shade100,
          'text': Colors.blue.shade700,
        };
      default:
        return {
          'background': Colors.purple.shade100,
          'text': Colors.purple.shade700,
        };
    }
  }

  String _getConfirmedTeamAName(Map<String, dynamic> match) {
    switch (match['type']) {
      case 'challenge_match':
        // For challenge matches: Guest team vs Your team
        return match['teamB']?['name'] ?? 'Guest Team';
      case 'host_match':
      case 'host_match_single':
        // For host matches: Team A vs Team B (you're just hosting)
        return match['teamA']?['name'] ?? 'Team A';
      default:
        // For regular bookings: Just the booking team
        return match['teamA']?['name'] ?? 'Team';
    }
  }

  String _getConfirmedTeamBName(Map<String, dynamic> match) {
    switch (match['type']) {
      case 'challenge_match':
        // For challenge matches: Guest team vs Your team
        return match['teamA']?['name'] ?? 'Your Team';
      case 'host_match':
        // For host matches: Team A vs Team B (you're just hosting)
        return match['teamB']?['name'] ?? 'Team B';
      case 'host_match_single':
        // For single host matches: Team A vs TBD
        return 'TBD';
      default:
        // For regular bookings: No opponent
        return 'Ground Booking';
    }
  }
}
