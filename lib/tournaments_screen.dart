import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'create_tournament.dart'; // Import the create tournament screen
import '/services/api_service.dart'; // Import the API service

class TournamentsScreen extends StatefulWidget {
  const TournamentsScreen({super.key});

  @override
  State<TournamentsScreen> createState() => _TournamentsScreenState();
}

class _TournamentsScreenState extends State<TournamentsScreen> {
  final ApiService _apiService = ApiService();
  String selectedLocation = 'Tirupur'; // Default location set to Tirupur
  List<dynamic> userTournaments = [];
  List<dynamic> otherTournaments = [];
  bool isLoading = false;

  // List of locations
  final List<String> locations = [
    "Tirupur",
    "Coimbatore",
    "Chennai",
    "Salem",
    "Madurai"
  ];

  @override
  void initState() {
    super.initState();
    _fetchTournaments(selectedLocation);
  }

  Future<void> _fetchTournaments(String location) async {
    setState(() {
      isLoading = true;
    });

    try {
      final result = await _apiService.getTournamentsByLocation(location);

      setState(() {
        userTournaments = result['userTournaments'] ?? [];
        otherTournaments = result['otherTournaments'] ?? [];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showErrorSnackBar('Failed to load tournaments: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _onLocationChanged(String? newLocation) {
    if (newLocation != null) {
      setState(() {
        selectedLocation = newLocation;
      });
      _fetchTournaments(
          selectedLocation); // Fetch tournaments for the new location
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tournaments',
          style: TextStyle(
            fontFamily: 'Boldonse',
            fontSize: 18,
            color: Colors.black,
          ),
        ),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _fetchTournaments(selectedLocation);
        },
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // Dropdown for location selection
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: DropdownButton<String>(
                  value: selectedLocation,
                  onChanged: _onLocationChanged,
                  items: locations.map((String location) {
                    return DropdownMenuItem<String>(
                      value: location,
                      child: Text(location),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
              if (userTournaments.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Text(
                    'Your Tournaments',
                    style: GoogleFonts.montserrat(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.blue[800],
                    ),
                  ),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: userTournaments.length,
                  itemBuilder: (context, index) {
                    final tournament = userTournaments[index];
                    return Card(
                      color: Colors.blue[50],
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tournament['tournamentName'] ??
                                  'Unnamed Tournament',
                              style: GoogleFonts.montserrat(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.blue[800],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              tournament['location'] ?? 'Unknown Location',
                              style: GoogleFonts.montserrat(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
              ],
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Available Tournaments in $selectedLocation',
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              isLoading
                  ? Center(child: CircularProgressIndicator())
                  : otherTournaments.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Text(
                              'No tournaments available in $selectedLocation',
                              style: GoogleFonts.montserrat(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: otherTournaments.length,
                          itemBuilder: (context, index) {
                            final tournament = otherTournaments[index];
                            return Card(
                              color: Colors.white,
                              margin: const EdgeInsets.only(bottom: 16),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      tournament['tournamentName'] ??
                                          'Unnamed Tournament',
                                      style: GoogleFonts.montserrat(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      tournament['location'] ??
                                          'Unknown Location',
                                      style: GoogleFonts.montserrat(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
              SizedBox(height: 80),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateTournamentScreen(),
            ),
          ).then((_) {
            _fetchTournaments(selectedLocation);
          });
        },
        backgroundColor: Colors.red,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'Create Tournament',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
