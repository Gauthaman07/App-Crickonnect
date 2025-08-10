import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'create_tournament.dart';
import '/services/api_service.dart';
import 'register_tournament.dart';
import 'package:flutter/cupertino.dart';
import 'package:url_launcher/url_launcher.dart';
import 'create_tournament.dart';

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

  // For scrolling app bar color change
  late ScrollController _scrollController;
  bool _isScrolled = false;

  // Tab controller for pill selector
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
    _fetchTournaments(selectedLocation);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _tabController.dispose();
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
      backgroundColor: const Color(0xFFF5F0ED),
      appBar: AppBar(
        title: Text(
          "Tournaments",
          style: TextStyle(
            fontFamily: 'Boldonse',
            fontSize: 15,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF15151E),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),

          // Pill Tab Selector
          _buildPillTabSelector(),

          const SizedBox(height: 16),

          // Conditional Location Selector (only for Register tab)
          AnimatedBuilder(
            animation: _tabController,
            builder: (context, child) {
              if (_tabController.index == 1) {
                // Only show in Register tab (index 1)
                return Column(
                  children: [
                    _buildLocationSelector(),
                    const SizedBox(height: 16),
                  ],
                );
              }
              return const SizedBox.shrink(); // Hide when in Create tab
            },
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                CreateTournamentScreen(isEmbedded: true),
                // Register Tab
                RefreshIndicator(
                  onRefresh: () async {
                    await _fetchTournaments(selectedLocation);
                  },
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // User Tournaments Section
                        if (userTournaments.isNotEmpty) ...[
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Pill Tab Selector
  Widget _buildPillTabSelector() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
      ),
      child: AnimatedBuilder(
        animation: _tabController,
        builder: (context, child) {
          return Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _tabController.animateTo(0),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: _tabController.index == 0
                          ? Colors.black
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "Create",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _tabController.index == 0
                            ? Colors.white
                            : Colors.black,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => _tabController.animateTo(1),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: _tabController.index == 1
                          ? Colors.black
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "Register",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _tabController.index == 1
                            ? Colors.white
                            : Colors.black,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // UI Components (rest of your existing methods remain the same)

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
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 400,
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: userTournaments.length,
        itemBuilder: (context, index) {
          final tournament = userTournaments[index];

          final String tournamentName =
              tournament['tournamentName'] ?? 'Unnamed Tournament';
          final String location = tournament['location'] ?? 'Unknown Location';
          final DateTime startDate =
              DateTime.tryParse(tournament['startDate'] ?? '') ??
                  DateTime.now();
          final int totalTeams = tournament['numberOfTeams'] ?? 0;
          final int registeredTeams =
              (tournament['teams'] as List?)?.length ?? 0;
          final String tournamentType = tournament['tournamentType'] ?? '';
          final int overs = tournament['oversPerMatch'] ?? 0;
          final String? fixtureUrl = tournament['fixturePDFUrl'];

          return Container(
            color: Colors.black,
            margin: const EdgeInsets.only(bottom: 16),
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
                          style: GoogleFonts.montserrat(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today,
                              size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            '${startDate.day}/${startDate.month}/${startDate.year}',
                            style: GoogleFonts.montserrat(
                              fontSize: 13,
                              color: Colors.grey[400],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        location,
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildInfoChip(tournamentType),
                      const SizedBox(width: 8),
                      _buildInfoChip('$overs Overs'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Teams: $registeredTeams / $totalTeams',
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      if (fixtureUrl != null && fixtureUrl.isNotEmpty)
                        GestureDetector(
                          onTap: () async {
                            final uri = Uri.parse(fixtureUrl);
                            if (await canLaunchUrl(uri)) {
                              await launchUrl(uri);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Could not open fixture')),
                              );
                            }
                          },
                          child: Text(
                            'View Fixture',
                            style: GoogleFonts.montserrat(
                              fontSize: 14,
                              color: Colors.lightBlueAccent,
                              decoration: TextDecoration.underline,
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
      ),
    );
  }

  Widget _buildInfoChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.montserrat(
          fontSize: 12,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildOtherTournamentsContent() {
    if (isLoading) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: CupertinoActivityIndicator(
            radius: 12, // Small size (consistent with other screens)
            color: Colors.grey.shade600, // Metal silver color
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
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
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
}
