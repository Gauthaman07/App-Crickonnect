import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'create_tournament.dart';
import '/services/api_service.dart';
import 'register_tournament.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class TournamentsScreen extends StatefulWidget {
  const TournamentsScreen({super.key});

  @override
  State<TournamentsScreen> createState() => _TournamentsScreenState();
}

class _TournamentsScreenState extends State<TournamentsScreen> {
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

  // For scrolling app bar color change
  late ScrollController _scrollController;
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _fetchTournaments(selectedLocation);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset > 20 && !_isScrolled) {
      setState(() {
        _isScrolled = true;
      });
    } else if (_scrollController.offset <= 20 && _isScrolled) {
      setState(() {
        _isScrolled = false;
      });
    }
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
    if (newLocation != null && newLocation != selectedLocation) {
      setState(() {
        selectedLocation = newLocation;
      });
      _fetchTournaments(selectedLocation);
    }
  }

  String _formatStartDate(String? startDate) {
    if (startDate == null) return '';
    final date = DateTime.parse(startDate);
    return '${date.day}/${date.month}/${date.year}';
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

  void _navigateToCreateTournament() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateTournamentScreen(),
      ),
    ).then((_) {
      _fetchTournaments(selectedLocation);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: _isScrolled ? Colors.red : Colors.white,
        title: Text(
          'Tournaments',
          style: TextStyle(
            fontFamily: 'Boldonse',
            fontSize: 16,
            color: _isScrolled ? Colors.white : Colors.black,
          ),
        ),
        elevation: 0,
        iconTheme: IconThemeData(
          color: _isScrolled ? Colors.white : Colors.black,
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _fetchTournaments(selectedLocation);
        },
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // Location Selector
              _buildLocationSelector(),

              const SizedBox(height: 16),

              // User Tournaments Section
              if (userTournaments.isNotEmpty) ...[
                _buildSectionHeader('Your Tournaments'),
                _buildUserTournamentsList(),
                const SizedBox(height: 16),
              ],

              // Other Tournaments Section
              _buildOtherTournamentsContent(),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildCreateTournamentButton(),
    );
  }

  // UI Components

  Widget _buildLocationSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: _showLocationSelector,
        child: Align(
          alignment: Alignment.centerRight,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.location_on, color: Colors.red),
              const SizedBox(width: 5),
              Text(
                selectedLocation,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Text(
        title,
        style: GoogleFonts.montserrat(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Colors.blue[800],
        ),
      ),
    );
  }

  Widget _buildUserTournamentsList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
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
                  tournament['tournamentName'] ?? 'Unnamed Tournament',
                  style: TextStyle(
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
    );
  }

  Widget _buildOtherTournamentsContent() {
    if (isLoading) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: LoadingAnimationWidget.threeArchedCircle(
            color: Colors.red,
            size: 40,
          ),
        ),
      );
    }

    if (otherTournaments.isEmpty) {
      return Center(
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
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: otherTournaments.length,
      itemBuilder: (context, index) {
        final tournament = otherTournaments[index];
        return _buildTournamentCard(tournament);
      },
    );
  }

  Widget _buildTournamentCard(dynamic tournament) {
    return GestureDetector(
      onTap: () => _navigateToRegisterTournament(tournament),
      child: Card(
        color: Colors.white,
        margin: const EdgeInsets.only(bottom: 16),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(
            color: Color(0xFFDCDCDC),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tournament Type (Top)
              Row(
                children: [
                  Text(
                    tournament['tournamentType'] ?? 'Tournament Type',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_forward_ios,
                      size: 12, color: Colors.black54),
                ],
              ),
              const SizedBox(height: 16),

              // Tournament Name, Location, Start Date
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    // Left side - Tournament name & location
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tournament['tournamentName'] ??
                                'Unnamed Tournament',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            tournament['location'] ?? 'Unknown Location',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Right side - Start Date
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _formatStartDate(tournament['startDate']),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Entry Fee
              Row(
                children: [
                  const Icon(Icons.monetization_on,
                      color: Colors.amber, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    '₹${tournament['entryFee'] ?? '0'} Entry',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreateTournamentButton() {
    return FloatingActionButton.extended(
      onPressed: _navigateToCreateTournament,
      backgroundColor: Colors.red,
      icon: const Icon(Icons.add, color: Colors.white),
      label: Text(
        'Create Tournament',
        style: GoogleFonts.montserrat(
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}
