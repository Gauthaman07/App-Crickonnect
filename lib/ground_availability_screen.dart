import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'package:google_fonts/google_fonts.dart';

class GroundAvailabilityScreen extends StatefulWidget {
  const GroundAvailabilityScreen({super.key});

  @override
  _GroundAvailabilityScreenState createState() =>
      _GroundAvailabilityScreenState();
}

class _GroundAvailabilityScreenState extends State<GroundAvailabilityScreen> {
  Map<String, dynamic>? weeklyAvailability;
  Map<String, dynamic>? groundInfo;
  bool isLoading = true;
  String? error;
  DateTime selectedWeek = DateTime.now();

  // Days of the week
  final List<String> days = [
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
    'saturday',
    'sunday'
  ];

  final List<String> dayLabels = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];

  final List<String> timeSlots = ['morning', 'afternoon'];
  final List<String> timeLabels = ['Morning', 'Afternoon'];

  // Availability modes
  final Map<String, String> modes = {
    'owner_play': 'Owner Play',
    'host_only': 'Host Only',
    'unavailable': 'Unavailable'
  };

  final Map<String, Color> modeColors = {
    'owner_play': Colors.blue.shade100,
    'host_only': Colors.green.shade100,
    'unavailable': Colors.grey.shade200,
  };

  final Map<String, Color> modeBorderColors = {
    'owner_play': Colors.blue,
    'host_only': Colors.green,
    'unavailable': Colors.grey,
  };

  @override
  void initState() {
    super.initState();
    fetchWeeklyAvailability();
  }

  DateTime getMonday(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  Future<void> fetchWeeklyAvailability() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final monday = getMonday(selectedWeek);
      final response = await ApiService.getWeeklyAvailability(monday);

      if (response != null && response['success'] == true) {
        setState(() {
          weeklyAvailability = response['availability'];
          groundInfo = response['groundInfo'];
          isLoading = false;
        });
      } else {
        setState(() {
          error = response?['message'] ?? 'Failed to fetch availability';
          isLoading = false;
        });
      }
    } catch (e) {
      String errorMessage = 'Error: $e';
      if (e.toString().contains('Connection closed') || e.toString().contains('timeout')) {
        errorMessage = 'Network timeout. Please check your connection and try again.';
      } else if (e.toString().contains('Next week availability already exists')) {
        errorMessage = 'This week is already available. Use the navigation arrows to browse weeks.';
      }
      
      setState(() {
        error = errorMessage;
        isLoading = false;
      });
    }
  }

  Future<void> updateSlot(String day, String timeSlot, String mode) async {
    try {
      final monday = getMonday(selectedWeek);
      final response = await ApiService.updateDayTimeSlot(
        weekStartDate: monday,
        day: day,
        timeSlot: timeSlot,
        mode: mode,
      );

      if (response != null && response['success'] == true) {
        // Refresh the data
        await fetchWeeklyAvailability();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Availability updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception(response?['message'] ?? 'Update failed');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating slot: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }


  void showModeSelector(String day, String timeSlot, String currentMode) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Availability Mode',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Text(
                '${dayLabels[days.indexOf(day)]} ${timeLabels[timeSlots.indexOf(timeSlot)]}',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: Colors.grey.shade700,
                ),
              ),
              SizedBox(height: 16),
              ...modes.keys.map((mode) => ListTile(
                    leading: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: modeColors[mode],
                        border: Border.all(color: modeBorderColors[mode]!),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    title: Text(modes[mode]!),
                    trailing: currentMode == mode
                        ? Icon(Icons.check, color: Colors.green)
                        : null,
                    onTap: () {
                      Navigator.pop(context);
                      updateSlot(day, timeSlot, mode);
                    },
                  )),
            ],
          ),
        );
      },
    );
  }

  Widget buildWeekSelector() {
    final monday = getMonday(selectedWeek);
    final sunday = monday.add(Duration(days: 6));

    return Container(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {
              setState(() {
                selectedWeek = selectedWeek.subtract(Duration(days: 7));
              });
              fetchWeeklyAvailability();
            },
            icon: Icon(Icons.arrow_back_ios, color: Colors.blue),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  'Week Schedule',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '${monday.day}/${monday.month}/${monday.year} - ${sunday.day}/${sunday.month}/${sunday.year}',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.blue.shade600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                selectedWeek = selectedWeek.add(Duration(days: 7));
              });
              fetchWeeklyAvailability();
            },
            icon: Icon(Icons.arrow_forward_ios, color: Colors.blue),
          ),
        ],
      ),
    );
  }

  Widget buildAvailabilityGrid() {
    if (weeklyAvailability == null) return Container();

    final schedule = weeklyAvailability!['schedule'] as Map<String, dynamic>;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Header row
          Container(
            padding: EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'Day',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'Morning',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'Afternoon',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          // Schedule rows
          ...days.asMap().entries.map((entry) {
            int index = entry.key;
            String day = entry.value;
            final daySchedule = schedule[day] as Map<String, dynamic>;

            return Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade300, width: 0.5),
                  left: BorderSide(color: Colors.grey.shade300, width: 0.5),
                  right: BorderSide(color: Colors.grey.shade300, width: 0.5),
                ),
              ),
              child: Row(
                children: [
                  // Day name
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        border: Border(
                          right: BorderSide(color: Colors.grey.shade300, width: 0.5),
                        ),
                      ),
                      child: Text(
                        dayLabels[index],
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  // Morning slot
                  Expanded(
                    flex: 3,
                    child: GestureDetector(
                      onTap: () => showModeSelector(day, 'morning', daySchedule['morning']['mode']),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                        decoration: BoxDecoration(
                          color: modeColors[daySchedule['morning']['mode']],
                          border: Border(
                            right: BorderSide(color: Colors.grey.shade300, width: 0.5),
                          ),
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                              decoration: BoxDecoration(
                                color: modeBorderColors[daySchedule['morning']['mode']],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                modes[daySchedule['morning']['mode']]!,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            if (daySchedule['morning']['guestMatchRequest'] != null)
                              Padding(
                                padding: EdgeInsets.only(top: 4),
                                child: Icon(
                                  Icons.pending,
                                  size: 16,
                                  color: Colors.orange,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Afternoon slot
                  Expanded(
                    flex: 3,
                    child: GestureDetector(
                      onTap: () => showModeSelector(day, 'afternoon', daySchedule['afternoon']['mode']),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                        color: modeColors[daySchedule['afternoon']['mode']],
                        child: Column(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                              decoration: BoxDecoration(
                                color: modeBorderColors[daySchedule['afternoon']['mode']],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                modes[daySchedule['afternoon']['mode']]!,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            if (daySchedule['afternoon']['guestMatchRequest'] != null)
                              Padding(
                                padding: EdgeInsets.only(top: 4),
                                child: Icon(
                                  Icons.pending,
                                  size: 16,
                                  color: Colors.orange,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0ED),
      appBar: AppBar(
        title: Text(
          'Ground Availability',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF15151E),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
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
                          onPressed: fetchWeeklyAvailability,
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
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (groundInfo != null)
                        Container(
                          width: double.infinity,
                          margin: EdgeInsets.all(16),
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 10,
                                spreadRadius: 0,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Colors.green.shade400, Colors.blue.shade500],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.sports_cricket,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      groundInfo!['groundName'] ?? 'Your Ground',
                                      style: GoogleFonts.inter(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    if (groundInfo!['location'] != null) ...[
                                      SizedBox(height: 4),
                                      Text(
                                        groundInfo!['location'],
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      
                      buildWeekSelector(),
                      
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          children: [
                            Text(
                              'Weekly Schedule',
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Spacer(),
                            Text(
                              'Tap to edit',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      buildAvailabilityGrid(),
                      
                      // Legend
                      Container(
                        margin: EdgeInsets.all(16),
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 8,
                              spreadRadius: 0,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Legend',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 12),
                            Row(
                              children: [
                                Container(
                                  width: 16,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade100,
                                    border: Border.all(color: Colors.blue),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text('Owner Play', style: GoogleFonts.inter(fontSize: 14)),
                                SizedBox(width: 24),
                                Container(
                                  width: 16,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade100,
                                    border: Border.all(color: Colors.green),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text('Host Only', style: GoogleFonts.inter(fontSize: 14)),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Container(
                                  width: 16,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text('Unavailable', style: GoogleFonts.inter(fontSize: 14)),
                                SizedBox(width: 24),
                                Icon(Icons.pending, size: 16, color: Colors.orange),
                                SizedBox(width: 8),
                                Text('Pending Request', style: GoogleFonts.inter(fontSize: 14)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      SizedBox(height: 80), // Bottom padding for navigation
                    ],
                  ),
                ),
    );
  }
}