import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/cupertino.dart';
import 'services/api_service.dart';
import 'package:intl/intl.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  _MyBookingsScreenState createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  List<dynamic> bookings = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchUserBookings();
  }

  Future<void> fetchUserBookings() async {
    try {
      final response = await ApiService.getUserBookings();

      if (response['success'] == true) {
        setState(() {
          bookings = response['bookings'] ?? [];
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = response['message'] ?? 'Failed to load bookings';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = false;
      });
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'booked':
      case 'confirmed':
        return Colors.grey.shade600; // FINISHED style
      case 'pending':
        return Colors.orange.shade600;
      case 'rejected':
      case 'cancelled':
        return Colors.green.shade600; // REFUNDED style
      default:
        return Colors.grey.shade600;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'booked':
      case 'confirmed':
        return 'FINISHED';
      case 'pending':
        return 'PENDING';
      case 'rejected':
      case 'cancelled':
        return 'REFUNDED';
      default:
        return status.toUpperCase();
    }
  }

  String _getStatusSubText(String status) {
    switch (status.toLowerCase()) {
      case 'booked':
      case 'confirmed':
        return 'Hope you enjoyed the Match!';
      case 'pending':
        return 'Waiting for confirmation';
      case 'rejected':
      case 'cancelled':
        return 'Refund credited to your original payment mode.';
      default:
        return '';
    }
  }

  String _formatBookingDate(String dateString) {
    try {
      final DateTime date = DateTime.parse(dateString);
      return DateFormat('dd MMM, yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  String _formatMatchDate(String dateString) {
    try {
      // Assuming the dateString is in format like "Mon, Jan 15, 2024"
      return dateString;
    } catch (e) {
      return dateString;
    }
  }

  String _formatTimeSlot(String timeSlot) {
    // Convert to time format
    switch (timeSlot.toLowerCase()) {
      case 'morning':
        return '06:00 AM';
      case 'afternoon':
        return '02:00 PM';
      case 'evening':
        return '06:00 PM';
      default:
        return timeSlot;
    }
  }
  
  Widget _buildMatchTypeBadge(Map<String, dynamic> booking) {
    String matchType = 'Ground Booking';
    Color badgeColor = Colors.green.shade600;
    IconData icon = Icons.sports_cricket;
    
    // Check availability mode and opponent team to determine match type
    if (booking['availabilityMode'] == 'owner_play' || booking['opponentTeam'] == null) {
      matchType = 'Challenge';
      badgeColor = Colors.purple.shade600;
      icon = Icons.sports_kabaddi;
    } else if (booking['availabilityMode'] == 'host_only' || booking['opponentTeam'] != null) {
      matchType = 'Host Match';
      badgeColor = Colors.blue.shade600;
      icon = Icons.sports_cricket;
    }
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: badgeColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: badgeColor,
          ),
          SizedBox(width: 4),
          Text(
            matchType,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: badgeColor,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMatchDescription(Map<String, dynamic> booking) {
    String description = 'Regular ground booking';
    Color descColor = Colors.grey.shade600;
    
    // Determine description based on booking type
    if (booking['availabilityMode'] == 'owner_play' || booking['opponentTeam'] == null) {
      description = 'Challenge match vs ground owner team';
      descColor = Colors.purple.shade600;
    } else if (booking['availabilityMode'] == 'host_only' && booking['opponentTeam'] != null) {
      // If we have opponent team info, show it
      if (booking['opponentTeamName'] != null) {
        description = 'Hosting match vs ${booking['opponentTeamName']}';
      } else {
        description = 'Hosting match vs another team';
      }
      descColor = Colors.blue.shade600;
    }
    
    return Text(
      description,
      style: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: descColor,
        fontStyle: FontStyle.italic,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Your Bookings',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ),
      backgroundColor: Colors.grey.shade100,
      body: isLoading
          ? Center(
              child: CupertinoActivityIndicator(
                radius: 15,
                color: Colors.grey.shade600,
              ),
            )
          : errorMessage.isNotEmpty
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Oops! Something went wrong',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          errorMessage,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              isLoading = true;
                              errorMessage = '';
                            });
                            fetchUserBookings();
                          },
                          child: Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : bookings.isEmpty
                  ? Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.sports_cricket,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No bookings yet',
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Start booking cricket grounds to see them here',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: fetchUserBookings,
                      child: ListView.builder(
                        padding: EdgeInsets.all(0),
                        itemCount: bookings.length,
                        itemBuilder: (context, index) {
                          final booking = bookings[index];

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Ordered on header
                              Container(
                                width: double.infinity,
                                color: Colors.grey.shade200,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                child: Text(
                                  'Booked on: ${_formatBookingDate(booking['createdAt'] ?? '')}',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ),

                              // Booking card
                              Container(
                                color: Colors.white,
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Ground/Team image placeholder
                                        Container(
                                          width: 80,
                                          height: 80,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            gradient: LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                              colors: [
                                                Colors.green.shade600,
                                                Colors.green.shade800,
                                              ],
                                            ),
                                          ),
                                          child: booking['teamLogo'] != null
                                              ? ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  child: Image.network(
                                                    booking['teamLogo'],
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context,
                                                        error, stackTrace) {
                                                      return Center(
                                                        child: Icon(
                                                          Icons.sports_cricket,
                                                          color: Colors.white,
                                                          size: 32,
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                )
                                              : Center(
                                                  child: Icon(
                                                    Icons.sports_cricket,
                                                    color: Colors.white,
                                                    size: 32,
                                                  ),
                                                ),
                                        ),
                                        SizedBox(width: 16),

                                        // Ground details
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // Ground name and category
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      booking['groundName'] ??
                                                          'Unknown Ground',
                                                      style: GoogleFonts.inter(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: Colors.black,
                                                      ),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 8,
                                                            vertical: 4),
                                                    decoration: BoxDecoration(
                                                      color:
                                                          Colors.grey.shade100,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              4),
                                                    ),
                                                    // child: Text(
                                                    //   'Cricket',
                                                    //   style: GoogleFonts.inter(
                                                    //     fontSize: 12,
                                                    //     fontWeight:
                                                    //         FontWeight.w500,
                                                    //     color: Colors
                                                    //         .grey.shade700,
                                                    //   ),
                                                    // ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 4),

                                              // Team name and match type
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      booking['teamName'] ??
                                                          'Unknown Team',
                                                      style: GoogleFonts.inter(
                                                        fontSize: 14,
                                                        fontWeight: FontWeight.w400,
                                                        color: Colors.grey.shade600,
                                                      ),
                                                    ),
                                                  ),
                                                  _buildMatchTypeBadge(booking),
                                                ],
                                              ),
                                              SizedBox(height: 8),
                                              
                                              // Match description based on type
                                              _buildMatchDescription(booking),
                                              SizedBox(height: 8),

                                              // Match date and time
                                              Text(
                                                '${_formatMatchDate(booking['bookedDate'] ?? '')} | ${_formatTimeSlot(booking['timeSlot'] ?? '')}',
                                                style: GoogleFonts.inter(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              SizedBox(height: 4),

                                              // Location
                                              Text(
                                                booking['groundLocation'] ??
                                                    'Location not available',
                                                style: GoogleFonts.inter(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w400,
                                                  color: Colors.grey.shade600,
                                                ),
                                              ),
                                              SizedBox(height: 8),

                                              // Booking details
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    'Fee: ₹${booking['fee'] ?? '0'}',
                                                    style: GoogleFonts.inter(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                  Text(
                                                    booking['groundOwner'] ??
                                                        'Unknown',
                                                    style: GoogleFonts.inter(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color:
                                                          Colors.grey.shade600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),

                                    SizedBox(height: 16),

                                    // Status section
                                    // Row(
                                    //   children: [
                                    //     Container(
                                    //       padding: EdgeInsets.symmetric(
                                    //           horizontal: 12, vertical: 6),
                                    //       decoration: BoxDecoration(
                                    //         color: _getStatusColor(
                                    //             booking['status'] ?? 'pending'),
                                    //         borderRadius:
                                    //             BorderRadius.circular(4),
                                    //       ),
                                    //       child: Text(
                                    //         _getStatusText(
                                    //             booking['status'] ?? 'pending'),
                                    //         style: GoogleFonts.inter(
                                    //           fontSize: 12,
                                    //           fontWeight: FontWeight.w600,
                                    //           color: Colors.white,
                                    //         ),
                                    //       ),
                                    //     ),
                                    //     SizedBox(width: 12),
                                    //     Expanded(
                                    //       child: Text(
                                    //         _getStatusSubText(
                                    //             booking['status'] ?? 'pending'),
                                    //         style: GoogleFonts.inter(
                                    //           fontSize: 14,
                                    //           fontWeight: FontWeight.w400,
                                    //           color: Colors.grey.shade600,
                                    //         ),
                                    //       ),
                                    //     ),
                                    //   ],
                                    // ),
                                  ],
                                ),
                              ),

                              // Divider
                              Container(
                                height: 8,
                                color: Colors.grey.shade100,
                              ),
                            ],
                          );
                        },
                      ),
                    ),
    );
  }
}
