import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class MyGroundsScreen extends StatefulWidget {
  const MyGroundsScreen({super.key});

  @override
  _MyGroundsScreenState createState() => _MyGroundsScreenState();
}

class _MyGroundsScreenState extends State<MyGroundsScreen> {
  bool isLoading = true;
  List<Map<String, dynamic>> grounds = [];

  @override
  void initState() {
    super.initState();
    loadGrounds();
  }

  Future<void> loadGrounds() async {
    // Simulate loading
    await Future.delayed(Duration(seconds: 1));
    
    // Mock data - replace with actual API call
    setState(() {
      grounds = [
        {
          'name': 'Sports City Ground',
          'location': 'Andheri West, Mumbai',
          'type': 'Cricket Ground',
          'status': 'Active',
          'bookingsToday': 3,
          'totalBookings': 45,
          'rating': 4.5,
          'revenue': '₹12,500',
        },
        {
          'name': 'Metro Cricket Complex',
          'location': 'Bandra East, Mumbai',
          'type': 'Multi-Purpose Ground',
          'status': 'Active',
          'bookingsToday': 5,
          'totalBookings': 78,
          'rating': 4.8,
          'revenue': '₹18,750',
        },
        {
          'name': 'City Sports Arena',
          'location': 'Powai, Mumbai',
          'type': 'Cricket Ground',
          'status': 'Maintenance',
          'bookingsToday': 0,
          'totalBookings': 23,
          'rating': 4.2,
          'revenue': '₹5,200',
        },
      ];
      isLoading = false;
    });
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'maintenance':
        return Colors.orange;
      case 'inactive':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'My Grounds',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.red,
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: Colors.white),
            onPressed: () {
              // Navigate to add ground screen
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Add Ground feature coming soon!'),
                  backgroundColor: Colors.red,
                ),
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(
              child: CupertinoActivityIndicator(
                radius: 20,
                color: Colors.red,
              ),
            )
          : grounds.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.sports_cricket_outlined,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No grounds found',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Your registered grounds will appear here',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          // Navigate to add ground screen
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Add Ground feature coming soon!'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        },
                        icon: Icon(Icons.add, color: Colors.white),
                        label: Text(
                          'Add Your First Ground',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: loadGrounds,
                  color: Colors.red,
                  child: ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: grounds.length,
                    itemBuilder: (context, index) {
                      final ground = grounds[index];
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
                                      ground['name'],
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
                                      color: _getStatusColor(ground['status'])
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      ground['status'],
                                      style: TextStyle(
                                        color: _getStatusColor(ground['status']),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Text(
                                ground['type'],
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.red,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.location_on,
                                      size: 16, color: Colors.grey.shade600),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      ground['location'],
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildStatCard(
                                      'Today',
                                      '${ground['bookingsToday']}',
                                      Icons.today,
                                      Colors.blue,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: _buildStatCard(
                                      'Total',
                                      '${ground['totalBookings']}',
                                      Icons.calendar_month,
                                      Colors.green,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: _buildStatCard(
                                      'Rating',
                                      '${ground['rating']}⭐',
                                      Icons.star,
                                      Colors.orange,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.currency_rupee,
                                          size: 16, color: Colors.green),
                                      SizedBox(width: 4),
                                      Text(
                                        'Revenue: ${ground['revenue']}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.green,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.edit, 
                                            size: 20, color: Colors.blue),
                                        onPressed: () {
                                          // Edit ground functionality
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Edit Ground feature coming soon!'),
                                              backgroundColor: Colors.blue,
                                            ),
                                          );
                                        },
                                        padding: EdgeInsets.zero,
                                        constraints: BoxConstraints(),
                                      ),
                                      SizedBox(width: 8),
                                      IconButton(
                                        icon: Icon(Icons.visibility, 
                                            size: 20, color: Colors.grey.shade600),
                                        onPressed: () {
                                          // View ground details
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('View Ground details coming soon!'),
                                              backgroundColor: Colors.grey.shade600,
                                            ),
                                          );
                                        },
                                        padding: EdgeInsets.zero,
                                        constraints: BoxConstraints(),
                                      ),
                                    ],
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

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, size: 16, color: color),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}