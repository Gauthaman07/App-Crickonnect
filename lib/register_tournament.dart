import 'package:flutter/material.dart';
import '/services/api_service.dart';

class RegisterTournamentScreen extends StatefulWidget {
  final String tournamentId;
  final String tournamentName;

  const RegisterTournamentScreen({
    super.key,
    required this.tournamentId,
    required this.tournamentName,
  });

  @override
  _RegisterTournamentScreenState createState() =>
      _RegisterTournamentScreenState();
}

class _RegisterTournamentScreenState extends State<RegisterTournamentScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();

  String captainName = '';
  String contactInfo = '';
  String numberOfPlayers = '';
  String preferredSlot = '';
  bool rulesAgreement = false;
  bool isSubmitting = false;

  // Add variables for team selection
  List<Map<String, dynamic>> userTeams = [];
  bool isLoadingTeams = true;
  String? selectedTeamId;
  String selectedTeamName = ''; // Keep track of selected team name for API

  @override
  void initState() {
    super.initState();
    fetchUserTeams();
  }

  Future<void> fetchUserTeams() async {
    try {
      final response = await ApiService.getMyTeam();
      if (response != null && response.containsKey("team")) {
        setState(() {
          userTeams = [response["team"]];
          // If there's a team available, preselect it
          if (userTeams.isNotEmpty) {
            selectedTeamId = userTeams[0]["_id"];
            selectedTeamName = userTeams[0]["name"] ?? "";
          }
          isLoadingTeams = false;
        });
      } else {
        setState(() {
          isLoadingTeams = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoadingTeams = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load teams: $e")),
      );
    }
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate() || !rulesAgreement) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Please fill all required fields and agree to the rules')),
      );
      return;
    }

    // Validate team ID
    if (selectedTeamId == null || selectedTeamId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a team to register')),
      );
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      final data = {
        "tournamentId": widget.tournamentId,
        "teamId": selectedTeamId,
        "teamName": selectedTeamName, // Use the stored team name from selection
        "captainName": captainName,
        "contactInfo": contactInfo,
        "numberOfPlayers": int.tryParse(numberOfPlayers) ?? 0,
        "preferredSlot": preferredSlot,
        "rulesAgreement": rulesAgreement,
      };

      final result = await _apiService.registerTournament(data);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Registration successful')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        isSubmitting = false;
      });
    }
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.grey), // Default label color
      floatingLabelStyle:
          const TextStyle(color: Colors.red), // Color when focused
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.grey, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.grey, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.grey, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Register  ',
          style: TextStyle(
            fontFamily: 'Boldonse',
            fontSize: 16,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
      ),
      backgroundColor: Colors.white, // Set the background color to white
      body: isLoadingTeams
          ? const Center(child: CircularProgressIndicator(color: Colors.red))
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    // Title at the top with margin
                    Padding(
                      padding: const EdgeInsets.only(top: 20), // Add top margin
                      child: Text(
                        widget
                            .tournamentName, // Display tournament name dynamically
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20), // Space after title

                    // Team selection dropdown
                    Center(
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: DropdownButtonFormField<String>(
                          decoration: _inputDecoration('Select Team'),
                          value: selectedTeamId,
                          items: userTeams.map((team) {
                            return DropdownMenuItem<String>(
                              value: team["_id"],
                              child: Text(team["teamName"] ?? "Unnamed Team"),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedTeamId = value;
                              // Find the selected team and update the team name
                              if (value != null) {
                                final selectedTeam = userTeams.firstWhere(
                                  (team) => team["_id"] == value,
                                  orElse: () => {},
                                );
                                selectedTeamName = selectedTeam["name"] ?? "";
                              }
                            });
                          },
                          validator: (value) => value == null || value.isEmpty
                              ? 'Please select a team'
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    Center(
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: TextFormField(
                          decoration: _inputDecoration('Captain Name'),
                          validator: (value) => value == null || value.isEmpty
                              ? 'Required'
                              : null,
                          onChanged: (value) => captainName = value,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    Center(
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: TextFormField(
                          decoration: _inputDecoration('Contact Info'),
                          validator: (value) => value == null || value.isEmpty
                              ? 'Required'
                              : null,
                          onChanged: (value) => contactInfo = value,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    Center(
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: TextFormField(
                          decoration:
                              _inputDecoration('Number of Players (optional)'),
                          keyboardType: TextInputType.number,
                          onChanged: (value) => numberOfPlayers = value,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    Center(
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: TextFormField(
                          decoration:
                              _inputDecoration('Preferred Slot (optional)'),
                          onChanged: (value) => preferredSlot = value,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                    // Checkbox for rules agreement
                    CheckboxListTile(
                      title: const Text("I agree to the tournament rules"),
                      value: rulesAgreement,
                      onChanged: (value) {
                        setState(() {
                          rulesAgreement = value ?? false;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    // Submit Button
                    Center(
                      child: SizedBox(
                        width: 150, // Same width as your original button
                        child: ElevatedButton(
                          onPressed: isSubmitting ? null : _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                vertical: 16), // Only vertical padding
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  30), // 30 radius like original
                            ),
                            elevation: 5, // Added elevation
                          ),
                          child: isSubmitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'SUBMIT',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
