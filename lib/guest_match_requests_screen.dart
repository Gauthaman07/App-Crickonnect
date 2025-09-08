import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'package:google_fonts/google_fonts.dart';

class GuestMatchRequestsScreen extends StatefulWidget {
  const GuestMatchRequestsScreen({super.key});

  @override
  _GuestMatchRequestsScreenState createState() =>
      _GuestMatchRequestsScreenState();
}

class _GuestMatchRequestsScreenState extends State<GuestMatchRequestsScreen> {
  List<Map<String, dynamic>> pendingRequests = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchPendingRequests();
  }

  Future<void> fetchPendingRequests() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final response = await ApiService.getPendingGuestRequests();

      if (response != null && response['success'] == true) {
        setState(() {
          pendingRequests = List<Map<String, dynamic>>.from(response['requests'] ?? []);
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

  Future<void> respondToRequest(String requestId, String status, String? responseNote) async {
    try {
      final response = await ApiService.respondToGuestMatch(
        requestId: requestId,
        status: status,
        responseNote: responseNote,
      );

      if (response != null && response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Request ${status} successfully'),
            backgroundColor: status == 'approved' ? Colors.green : Colors.orange,
          ),
        );
        
        // Refresh the requests list
        await fetchPendingRequests();
      } else {
        throw Exception(response?['message'] ?? 'Response failed');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error responding to request: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void showResponseDialog(Map<String, dynamic> request) {
    final TextEditingController noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Respond to Match Request',
            style: GoogleFonts.inter(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${request['teamA']['name']} vs ${request['teamB']['name']}',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '${request['date']} - ${request['timeSlot'].toString().toUpperCase()}',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: noteController,
                decoration: InputDecoration(
                  labelText: 'Response Note (Optional)',
                  hintText: 'Add a note for the teams...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                respondToRequest(request['requestId'], 'rejected', noteController.text.trim());
              },
              child: Text(
                'Reject',
                style: TextStyle(color: Colors.red),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                respondToRequest(request['requestId'], 'approved', noteController.text.trim());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: Text('Approve'),
            ),
          ],
        );
      },
    );
  }

  Widget buildRequestCard(Map<String, dynamic> request) {
    // Determine match type based on availabilityMode or opponentTeam
    String matchType = 'Host Match'; // default
    Color matchTypeColor = Colors.blue.shade600;
    Color matchTypeBgColor = Colors.blue.shade50;
    Color matchTypeBorderColor = Colors.blue.shade200;
    IconData matchIcon = Icons.sports_cricket;
    
    // Check if this is a challenge request (owner_play mode)
    if (request['availabilityMode'] == 'owner_play' || request['opponentTeam'] == null) {
      matchType = 'Challenge Match';
      matchTypeColor = Colors.purple.shade600;
      matchTypeBgColor = Colors.purple.shade50;
      matchTypeBorderColor = Colors.purple.shade200;
      matchIcon = Icons.sports_kabaddi;
    }
    
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with match type and status
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            matchIcon,
                            size: 16,
                            color: matchTypeColor,
                          ),
                          SizedBox(width: 6),
                          Text(
                            matchType,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: matchTypeColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(
                        '${request['teamA']['name']} vs ${request['teamB']['name']}',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.shade300),
                  ),
                  child: Text(
                    'PENDING',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade800,
                    ),
                  ),
                ),
              ],
            ),
            
            // Match type description
            SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: matchTypeBgColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: matchTypeBorderColor),
              ),
              child: Text(
                matchType == 'Challenge Match' 
                    ? '🏏 ${request['teamA']['name']} wants to challenge your team!'
                    : '🏟️ ${request['teamA']['name']} & ${request['teamB']['name']} want to play at your ground',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: matchTypeColor,
                ),
              ),
            ),
            
            SizedBox(height: 16),
            
            // Match details
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16, color: Colors.grey.shade600),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          request['groundLocation'] ?? 'Ground Location',
                          style: GoogleFonts.inter(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade600),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${request['date']} - ${request['timeSlot'].toString().toUpperCase()}',
                          style: GoogleFonts.inter(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.currency_rupee, size: 16, color: Colors.grey.shade600),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Match Fee: ₹${request['matchFee'] ?? 0}',
                          style: GoogleFonts.inter(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Team logos and info
            if (request['teamA']['logo'] != null || request['teamB']['logo'] != null)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Team A
                    Column(
                      children: [
                        CircleAvatar(
                          radius: 25,
                          backgroundImage: request['teamA']['logo'] != null
                              ? NetworkImage(request['teamA']['logo'])
                              : null,
                          child: request['teamA']['logo'] == null
                              ? Text(
                                  request['teamA']['name'][0].toUpperCase(),
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                )
                              : null,
                        ),
                        SizedBox(height: 4),
                        Text(
                          request['teamA']['name'],
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    
                    Text(
                      'VS',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    
                    // Team B
                    Column(
                      children: [
                        CircleAvatar(
                          radius: 25,
                          backgroundImage: request['teamB']['logo'] != null
                              ? NetworkImage(request['teamB']['logo'])
                              : null,
                          child: request['teamB']['logo'] == null
                              ? Text(
                                  request['teamB']['name'][0].toUpperCase(),
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                )
                              : null,
                        ),
                        SizedBox(height: 4),
                        Text(
                          request['teamB']['name'],
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            
            // Match description
            if (request['matchDescription'] != null && request['matchDescription'].isNotEmpty)
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12),
                margin: EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Match Description:',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      request['matchDescription'],
                      style: GoogleFonts.inter(fontSize: 14),
                    ),
                  ],
                ),
              ),
            
            // Requested by info
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.person, size: 16, color: Colors.grey.shade600),
                  SizedBox(width: 8),
                  Text(
                    'Requested by: ${request['requestedBy']}',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 16),
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => respondToRequest(request['requestId'], 'rejected', null),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.red),
                      foregroundColor: Colors.red,
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text('Quick Reject'),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => showResponseDialog(request),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text('Review & Respond'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          'Guest Match Requests',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            onPressed: fetchPendingRequests,
            icon: Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : error != null
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red,
                        ),
                        SizedBox(height: 16),
                        Text(
                          error!,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            color: Colors.red,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: fetchPendingRequests,
                          child: Text('Retry'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : pendingRequests.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inbox_outlined,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'No Pending Requests',
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Guest match requests will appear here',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: fetchPendingRequests,
                      child: ListView.builder(
                        itemCount: pendingRequests.length,
                        itemBuilder: (context, index) {
                          return buildRequestCard(pendingRequests[index]);
                        },
                      ),
                    ),
    );
  }
}