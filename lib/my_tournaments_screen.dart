import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class MyTournamentsScreen extends StatefulWidget {
  const MyTournamentsScreen({super.key});

  @override
  _MyTournamentsScreenState createState() => _MyTournamentsScreenState();
}

class _MyTournamentsScreenState extends State<MyTournamentsScreen> {
  bool isLoading = true;
  List<Map<String, dynamic>> tournaments = [];

  @override
  void initState() {
    super.initState();
    loadTournaments();
  }

  Future<void> loadTournaments() async {
    // Simulate loading
    await Future.delayed(Duration(seconds: 1));
    
    // Mock data - replace with actual API call
    setState(() {
      tournaments = [
        {
          'name': 'City Cricket Championship',
          'location': 'Mumbai',
          'startDate': '2024-02-15',
          'endDate': '2024-02-25',
          'status': 'Registered',
          'teams': 16,
          'teamName': 'Thunder Bolts',
        },
        {
          'name': 'Corporate Cricket League',
          'location': 'Bangalore',
          'startDate': '2024-03-01',
          'endDate': '2024-03-10',
          'status': 'In Progress',
          'teams': 8,
          'teamName': 'Lightning Warriors',
        },
        {
          'name': 'Weekend Warriors Cup',
          'location': 'Delhi',
          'startDate': '2024-01-20',
          'endDate': '2024-01-30',
          'status': 'Completed',
          'teams': 12,
          'teamName': 'Thunder Bolts',
        },
      ];
      isLoading = false;
    });
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'registered':
        return Colors.blue;
      case 'in progress':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'registered':
        return Icons.app_registration;
      case 'in progress':
        return Icons.sports_cricket;
      case 'completed':
        return Icons.emoji_events;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'My Tournaments',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.red,
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: isLoading
          ? Center(
              child: CupertinoActivityIndicator(
                radius: 20,
                color: Colors.red,
              ),
            )
          : tournaments.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.emoji_events_outlined,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No tournaments found',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Your tournament participations will appear here',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: loadTournaments,
                  color: Colors.red,
                  child: ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: tournaments.length,
                    itemBuilder: (context, index) {
                      final tournament = tournaments[index];
                      return Container(
                        margin: EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade200,
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      tournament['name'],
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(tournament['status'])
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          _getStatusIcon(tournament['status']),
                                          size: 12,
                                          color: _getStatusColor(tournament['status']),
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          tournament['status'],
                                          style: TextStyle(
                                            color: _getStatusColor(tournament['status']),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12),
                              Row(
                                children: [
                                  Icon(Icons.location_on,
                                      size: 16, color: Colors.grey.shade600),
                                  SizedBox(width: 8),
                                  Text(
                                    tournament['location'],
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.calendar_today,
                                      size: 16, color: Colors.grey.shade600),
                                  SizedBox(width: 8),
                                  Text(
                                    '${tournament['startDate']} - ${tournament['endDate']}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.groups,
                                      size: 16, color: Colors.grey.shade600),
                                  SizedBox(width: 8),
                                  Text(
                                    '${tournament['teams']} teams',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.sports_cricket,
                                      size: 16, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text(
                                    'Team: ${tournament['teamName']}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.red,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}