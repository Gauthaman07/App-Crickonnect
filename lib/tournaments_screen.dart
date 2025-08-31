import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'create_tournament.dart';
import '/services/api_service.dart';
import 'register_tournament.dart';
import 'package:flutter/cupertino.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class TournamentsScreen extends StatefulWidget {
  const TournamentsScreen({super.key});

  @override
  State<TournamentsScreen> createState() => _TournamentsScreenState();
}

class _TournamentsScreenState extends State<TournamentsScreen>
    with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  final List<String> locations = [
    "Tirupur",
    "Coimbatore",
    "Chennai",
    "Salem",
    "Madurai"
  ];

  String selectedLocation = 'Tirupur';
  List<dynamic> userTournaments = [];
  List<dynamic> otherTournaments = [];
  bool isLoading = false;
  bool isLoadingMyTournaments = false;
  bool isLoadingOtherTournaments = false;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Add listener to detect tab changes
    _tabController.addListener(_onTabChanged);
    
    // Initial load
    _fetchMyTournaments();
    _fetchTournaments(selectedLocation);
  }

  void _onTabChanged() {
    if (!mounted) return;
    
    print('🔄 Tab changed to index: ${_tabController.index}');
    print('📊 Current state - userTournaments: ${userTournaments.length}, otherTournaments: ${otherTournaments.length}');
    
    // Always refresh data when switching tabs to ensure fresh data
    if (_tabController.index == 0) {
      // My Tournaments tab
      print('📱 User switched to My Tournaments tab');
      if (!isLoadingMyTournaments) {
        _fetchMyTournaments();
      }
    } else if (_tabController.index == 1) {
      // Join Tournaments tab
      print('📱 User switched to Join Tournaments tab');
      if (!isLoadingOtherTournaments) {
        _fetchTournaments(selectedLocation);
      }
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  // Fetch user's created tournaments (no location filter)
  Future<void> _fetchMyTournaments() async {
    if (isLoadingMyTournaments) {
      print('⏳ Already loading my tournaments, skipping...');
      return;
    }

    try {
      setState(() {
        isLoadingMyTournaments = true;
        isLoading = true;
      });

      print('🔍 Starting to fetch user tournaments...');
      print('🔄 Scanning all locations to find user tournaments...');
      await _fetchMyTournamentsFromAllLocations();
    } catch (e) {
      setState(() {
        isLoadingMyTournaments = false;
        isLoading = false;
      });
      print('❌ Error fetching my tournaments: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading your tournaments: $e')),
        );
      }
    }
  }

  // Fallback: Collect user tournaments from all available locations
  Future<void> _fetchMyTournamentsFromAllLocations() async {
    List<dynamic> allUserTournaments = [];
    
    // Fetch from each location and combine userTournaments
    for (String location in locations) {
      try {
        print('🔍 Checking location: $location');
        final response = await _apiService.getTournamentsByLocation(location);
        final locationUserTournaments = response['userTournaments'] ?? [];
        print('📍 Location $location: Found ${locationUserTournaments.length} user tournaments');
        
        if (locationUserTournaments.isNotEmpty) {
          print('📝 Tournaments found in $location:');
          for (var tournament in locationUserTournaments) {
            print('   - ${tournament['tournamentName']} (ID: ${tournament['_id']})');
          }
        }
        
        allUserTournaments.addAll(locationUserTournaments);
      } catch (e) {
        print('❌ Error fetching tournaments from $location: $e');
        // Continue with other locations even if one fails
      }
    }
    
    // Remove duplicates based on tournament ID
    final Map<String, dynamic> uniqueTournaments = {};
    for (var tournament in allUserTournaments) {
      final id = tournament['_id'] ?? tournament['id'];
      if (id != null) {
        uniqueTournaments[id] = tournament;
      }
    }
    
    setState(() {
      userTournaments = uniqueTournaments.values.toList();
      isLoading = false;
      isLoadingMyTournaments = false;
    });
    
    print('✅ Fetched ${userTournaments.length} user tournaments from all locations');
  }

  // Fetch tournaments by location for joining
  Future<void> _fetchTournaments(String location) async {
    if (isLoadingOtherTournaments) {
      print('⏳ Already loading other tournaments, skipping...');
      return;
    }

    try {
      setState(() {
        isLoadingOtherTournaments = true;
        isLoading = true;
      });

      final result = await _apiService.getTournamentsByLocation(location);
      setState(() {
        otherTournaments = result['otherTournaments'] ?? [];
        isLoading = false;
        isLoadingOtherTournaments = false;
      });
      print('✅ Fetched ${otherTournaments.length} other tournaments for $location');
    } catch (e) {
      setState(() {
        isLoading = false;
        isLoadingOtherTournaments = false;
      });
      print('❌ Error loading tournaments for $location: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading tournaments: $e')),
        );
      }
    }
  }

  void _onLocationChanged(String? newLocation) {
    if (newLocation != null && newLocation != selectedLocation) {
      setState(() {
        selectedLocation = newLocation;
      });
      _fetchTournaments(selectedLocation);
    }
  }

  void _showLocationSelector() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return ListView.builder(
          itemCount: locations.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(locations[index]),
              trailing: locations[index] == selectedLocation
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
              onTap: () {
                Navigator.pop(context);
                _onLocationChanged(locations[index]);
              },
            );
          },
        );
      },
    );
  }

  // Download fixtures PDF
  Future<void> _downloadFixtures(String tournamentId, String tournamentName) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.get(
        Uri.parse('https://crikonnect-api.onrender.com/api/fixtures/$tournamentId/download'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/${tournamentName}_fixtures.pdf');
        await file.writeAsBytes(bytes);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Fixtures downloaded successfully'),
              action: SnackBarAction(
                label: 'Open',
                onPressed: () => _openPDF(file.path),
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception('Failed to download fixtures (${response.statusCode})');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error downloading fixtures: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _openPDF(String path) async {
    final uri = Uri.file(path);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<String?> _getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('token');
    } catch (e) {
      print('Error getting token: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0ED), // Consistent with other screens
      appBar: AppBar(
        title: Text(
          "Tournaments",
          style: TextStyle(
            fontFamily: 'Boldonse',
            fontSize: 15,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF15151E), // Consistent dark header
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.red,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'My Tournaments'),
            Tab(text: 'Join Tournaments'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMyTournamentsTab(),
          _buildJoinTournamentsTab(),
        ],
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton.extended(
              onPressed: _navigateToCreateTournament,
              backgroundColor: Colors.red,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Create Tournament',
                style: TextStyle(color: Colors.white),
              ),
            )
          : null,
    );
  }

  // Tab 1: My Tournaments (Creator Dashboard)
  Widget _buildMyTournamentsTab() {
    if (isLoadingMyTournaments) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.red),
      );
    }

    if (userTournaments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.emoji_events_outlined, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No tournaments created yet',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first tournament to get started',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchMyTournaments,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: userTournaments.length,
        itemBuilder: (context, index) {
          final tournament = userTournaments[index];
          return _buildCreatorTournamentCard(tournament);
        },
      ),
    );
  }

  // Tab 2: Join Tournaments (Discovery)
  Widget _buildJoinTournamentsTab() {
    return Column(
      children: [
        // Location Selector
        Container(
          color: Colors.white,
          child: _buildLocationSelector(),
        ),
        const SizedBox(height: 16),
        
        // Tournaments List
        Expanded(
          child: isLoadingOtherTournaments
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.red),
                )
              : otherTournaments.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      onRefresh: () => _fetchTournaments(selectedLocation),
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: otherTournaments.length,
                        itemBuilder: (context, index) {
                          final tournament = otherTournaments[index];
                          return _buildJoinTournamentCard(tournament);
                        },
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _buildLocationSelector() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on, color: Colors.red),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              selectedLocation,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),
          GestureDetector(
            onTap: _showLocationSelector,
            child: const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'No tournaments available',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'in $selectedLocation',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  // Creator Tournament Card (with management features)
  Widget _buildCreatorTournamentCard(dynamic tournament) {
    final String tournamentName = tournament['tournamentName'] ?? 'Unnamed Tournament';
    final String location = tournament['location'] ?? 'Unknown Location';
    final String startDate = tournament['startDate'] ?? '';
    final int registrationCount = tournament['teams']?.length ?? 0; // Use teams array length
    final int maxTeams = tournament['numberOfTeams'] ?? 16; // Use numberOfTeams from API
    final String status = _getTournamentStatus(tournament);
    final bool hasFixtures = tournament['fixturePDFUrl'] != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    tournamentName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                _buildStatusChip(status),
              ],
            ),
            const SizedBox(height: 8),
            
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.red, size: 16),
                const SizedBox(width: 4),
                Text(
                  location,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.calendar_today, color: Colors.grey, size: 16),
                const SizedBox(width: 4),
                Text(
                  _formatStartDate(startDate),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Registration Progress
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Teams Registered',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: registrationCount / maxTeams,
                        backgroundColor: Colors.grey[300],
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$registrationCount/$maxTeams teams',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Action Buttons
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () => _viewRegistrations(tournament),
                  icon: const Icon(Icons.group, size: 14),
                  label: const Text(
                    'View Teams',
                    style: TextStyle(fontSize: 12),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    minimumSize: const Size(80, 32),
                  ),
                ),
                const SizedBox(width: 8),
                if (hasFixtures) ...[
                  ElevatedButton.icon(
                    onPressed: () => _downloadFixtures(tournament['_id'], tournamentName),
                    icon: const Icon(Icons.picture_as_pdf, size: 14),
                    label: const Text(
                      'Fixtures',
                      style: TextStyle(fontSize: 12),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      minimumSize: const Size(80, 32),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Join Tournament Card (simpler for discovery)
  Widget _buildJoinTournamentCard(dynamic tournament) {
    final String tournamentName = tournament['tournamentName'] ?? 'Unnamed Tournament';
    final String location = tournament['location'] ?? 'Unknown Location';
    final String startDate = tournament['startDate'] ?? '';
    final String prizePool = tournament['prizePool'] ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tournamentName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.red, size: 16),
                const SizedBox(width: 4),
                Text(
                  location,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.calendar_today, color: Colors.grey, size: 16),
                const SizedBox(width: 4),
                Text(
                  _formatStartDate(startDate),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            if (prizePool.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.emoji_events, color: Colors.amber, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'Prize Pool: $prizePool',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _navigateToRegisterTournament(tournament),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Register Team',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    Color textColor;
    String displayText;

    switch (status.toLowerCase()) {
      case 'active':
        backgroundColor = Colors.green;
        textColor = Colors.white;
        displayText = 'Active';
        break;
      case 'completed':
        backgroundColor = Colors.grey;
        textColor = Colors.white;
        displayText = 'Completed';
        break;
      default:
        backgroundColor = Colors.blue;
        textColor = Colors.white;
        displayText = 'Upcoming';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        displayText,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _formatStartDate(String? startDate) {
    if (startDate == null || startDate.isEmpty) return '';
    try {
      final date = DateTime.parse(startDate);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return startDate;
    }
  }

  String _getTournamentStatus(dynamic tournament) {
    try {
      final startDate = DateTime.parse(tournament['startDate'] ?? '');
      final endDate = DateTime.parse(tournament['endDate'] ?? '');
      final now = DateTime.now();

      if (now.isAfter(endDate)) {
        return 'completed';
      } else if (now.isAfter(startDate)) {
        return 'active';
      } else {
        return 'upcoming';
      }
    } catch (e) {
      return 'upcoming';
    }
  }

  void _navigateToCreateTournament() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateTournamentScreen(),
      ),
    ).then((_) {
      _fetchMyTournaments();
    });
  }

  void _navigateToRegisterTournament(dynamic tournament) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RegisterTournamentScreen(
          tournamentId: tournament['_id'],
          tournamentName: tournament['tournamentName'],
        ),
      ),
    );
  }

  void _viewRegistrations(dynamic tournament) async {
    try {
      // Fetch registered teams for this tournament
      final token = await _getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.get(
        Uri.parse('https://crikonnect-api.onrender.com/api/tournaments/${tournament['_id']}/registrations'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final registrations = data['registrations'] ?? [];
        
        if (mounted) {
          _showRegistrationsDialog(tournament, registrations);
        }
      } else {
        throw Exception('Failed to fetch registrations');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading registrations: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showRegistrationsDialog(dynamic tournament, List<dynamic> registrations) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          '${tournament['tournamentName']} Teams',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: registrations.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.group_off, size: 60, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No teams registered yet',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: registrations.length,
                  itemBuilder: (context, index) {
                    final registration = registrations[index];
                    final team = registration['team'] ?? {};
                    final teamName = team['teamName'] ?? 'Unknown Team';
                    final captainName = registration['captainName'] ?? 'Unknown Captain';
                    final contactInfo = registration['contactInfo'] ?? '';
                    final status = registration['status'] ?? 'pending';
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                teamName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: status == 'approved' ? Colors.green : Colors.orange,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  status.toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Captain: $captainName',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          if (contactInfo.isNotEmpty)
                            Text(
                              'Contact: $contactInfo',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Close',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}