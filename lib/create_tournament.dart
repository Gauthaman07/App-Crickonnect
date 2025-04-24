import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart'; // Import your API service

class CreateTournamentScreen extends StatefulWidget {
  const CreateTournamentScreen({super.key});

  @override
  State<CreateTournamentScreen> createState() => _CreateTournamentScreenState();
}

class _CreateTournamentScreenState extends State<CreateTournamentScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  final ApiService _apiService = ApiService();

  // Form fields
  final _tournamentNameController = TextEditingController();
  final _tournamentTypeController = TextEditingController();
  final _locationController = TextEditingController();
  final _groundNameController = TextEditingController();
  final _organizerNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _numberOfTeamsController = TextEditingController();
  final _oversPerMatchController = TextEditingController();
  final _ballTypeController = TextEditingController();
  final _entryFeeController = TextEditingController();
  final _winningPrizeController = TextEditingController();
  final _playerEligibilityController = TextEditingController();
  final _teamCompositionController = TextEditingController();

  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 7));
  DateTime _lastDateToRegister = DateTime.now().add(const Duration(days: 3));

  String _matchDaysPreference = 'Weekends';
  final List<String> _sessionsAvailable = ['Morning'];
  bool _umpireProvided = false;
  bool _autoFixtureGeneration = false;

  final List<String> _matchDaysOptions = ['Weekends', 'Weekdays', 'Any Day'];
  final List<String> _sessionOptions = [
    'Morning',
    'Afternoon',
    'Evening',
    'Night'
  ];
  final List<String> _tournamentTypeOptions = ['Knockout', 'League', 'Series'];
  final List<String> _ballTypeOptions = ['Tennis', 'Leather', 'Hard Ball'];

  @override
  void dispose() {
    // Dispose controllers
    _tournamentNameController.dispose();
    _tournamentTypeController.dispose();
    _locationController.dispose();
    _groundNameController.dispose();
    _organizerNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _numberOfTeamsController.dispose();
    _oversPerMatchController.dispose();
    _ballTypeController.dispose();
    _entryFeeController.dispose();
    _winningPrizeController.dispose();
    _playerEligibilityController.dispose();
    _teamCompositionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, String dateType) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: dateType == 'start'
          ? _startDate
          : dateType == 'end'
              ? _endDate
              : _lastDateToRegister,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.red,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (dateType == 'start') {
          _startDate = picked;
        } else if (dateType == 'end') {
          _endDate = picked;
        } else {
          _lastDateToRegister = picked;
        }
      });
    }
  }

  void _toggleSession(String session) {
    setState(() {
      if (_sessionsAvailable.contains(session)) {
        _sessionsAvailable.remove(session);
      } else {
        _sessionsAvailable.add(session);
      }
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Create tournament data map
      final tournamentData = {
        'tournamentName': _tournamentNameController.text,
        'tournamentType': _tournamentTypeController.text,
        'location': _locationController.text,
        'groundName': _groundNameController.text.isEmpty
            ? null
            : _groundNameController.text,
        'organizerName': _organizerNameController.text,
        'contactDetails': {
          'phone': _phoneController.text.isEmpty ? null : _phoneController.text,
          'email': _emailController.text.isEmpty ? null : _emailController.text,
        },
        'startDate': _startDate.toIso8601String(),
        'endDate': _endDate.toIso8601String(),
        'matchDaysPreference': _matchDaysPreference,
        'sessionsAvailable': _sessionsAvailable,
        'numberOfTeams': int.parse(_numberOfTeamsController.text),
        'oversPerMatch': int.parse(_oversPerMatchController.text),
        'ballType': _ballTypeController.text,
        'entryFee': int.parse(_entryFeeController.text),
        'winningPrize': _winningPrizeController.text.isEmpty
            ? null
            : _winningPrizeController.text,
        'playerEligibility': _playerEligibilityController.text.isEmpty
            ? null
            : _playerEligibilityController.text,
        'teamComposition': int.parse(_teamCompositionController.text),
        'umpireProvided': _umpireProvided,
        'lastDateToRegister': _lastDateToRegister.toIso8601String(),
        'autoFixtureGeneration': _autoFixtureGeneration,
      };

      try {
        // Call API service to create tournament
        final response = await _apiService.createTournament(tournamentData);

        // Success handling
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tournament created successfully!')),
        );

        // Navigate back
        Navigator.pop(context);
      } catch (e) {
        // Error handling
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating tournament: ${e.toString()}')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create Tournament',
          style: TextStyle(
            fontFamily: 'Boldonse',
            fontSize: 18,
            // fontWeight: FontWeight.w800, // ExtraBold (800)
            color: Colors.black,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Tournament Details'),
                    _buildTextField(
                      controller: _tournamentNameController,
                      label: 'Tournament Name',
                      hint: 'Enter tournament name',
                      icon: Icons.emoji_events,
                      validator: (val) =>
                          val!.isEmpty ? 'This field is required' : null,
                    ),
                    _buildDropdown(
                      label: 'Tournament Type',
                      value: _tournamentTypeOptions[0],
                      items: _tournamentTypeOptions,
                      onChanged: (value) {
                        setState(() {
                          _tournamentTypeController.text = value!;
                        });
                      },
                      icon: Icons.category,
                    ),
                    _buildTextField(
                      controller: _locationController,
                      label: 'Location',
                      hint: 'Enter tournament location',
                      icon: Icons.location_on,
                      validator: (val) =>
                          val!.isEmpty ? 'This field is required' : null,
                    ),
                    _buildTextField(
                      controller: _groundNameController,
                      label: 'Ground Name (Optional)',
                      hint: 'Enter ground name',
                      icon: Icons.stadium,
                    ),
                    const SizedBox(height: 16),
                    _buildSectionTitle('Organizer Information'),
                    _buildTextField(
                      controller: _organizerNameController,
                      label: 'Organizer Name',
                      hint: 'Enter organizer name',
                      icon: Icons.person,
                      validator: (val) =>
                          val!.isEmpty ? 'This field is required' : null,
                    ),
                    _buildTextField(
                      controller: _phoneController,
                      label: 'Phone (Optional)',
                      hint: 'Enter contact phone',
                      icon: Icons.phone,
                      keyboardType: TextInputType.phone,
                    ),
                    _buildTextField(
                      controller: _emailController,
                      label: 'Email (Optional)',
                      hint: 'Enter contact email',
                      icon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    _buildSectionTitle('Schedule'),
                    _buildDatePicker(
                      label: 'Start Date',
                      value: DateFormat('MMM dd, yyyy').format(_startDate),
                      onTap: () => _selectDate(context, 'start'),
                      icon: Icons.calendar_today,
                    ),
                    _buildDatePicker(
                      label: 'End Date',
                      value: DateFormat('MMM dd, yyyy').format(_endDate),
                      onTap: () => _selectDate(context, 'end'),
                      icon: Icons.calendar_month,
                    ),
                    _buildDatePicker(
                      label: 'Last Date to Register',
                      value: DateFormat('MMM dd, yyyy')
                          .format(_lastDateToRegister),
                      onTap: () => _selectDate(context, 'register'),
                      icon: Icons.event_available,
                    ),
                    _buildDropdown(
                      label: 'Match Days Preference',
                      value: _matchDaysPreference,
                      items: _matchDaysOptions,
                      onChanged: (value) {
                        setState(() {
                          _matchDaysPreference = value!;
                        });
                      },
                      icon: Icons.date_range,
                    ),
                    const SizedBox(height: 16),
                    _buildSectionTitle('Sessions Available'),
                    Wrap(
                      spacing: 8,
                      children: _sessionOptions.map((session) {
                        return FilterChip(
                          label: Text(session),
                          selected: _sessionsAvailable.contains(session),
                          onSelected: (selected) => _toggleSession(session),
                          backgroundColor: Colors.grey[200],
                          selectedColor: Colors.red[100],
                          checkmarkColor: Colors.red,
                          labelStyle: TextStyle(
                            color: _sessionsAvailable.contains(session)
                                ? Colors.red[800]
                                : Colors.black,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    _buildSectionTitle('Tournament Setup'),
                    _buildTextField(
                      controller: _numberOfTeamsController,
                      label: 'Number of Teams',
                      hint: 'Enter number of teams',
                      icon: Icons.groups,
                      keyboardType: TextInputType.number,
                      validator: (val) =>
                          val!.isEmpty ? 'This field is required' : null,
                    ),
                    _buildTextField(
                      controller: _oversPerMatchController,
                      label: 'Overs Per Match',
                      hint: 'Enter overs per match',
                      icon: Icons.sports_cricket,
                      keyboardType: TextInputType.number,
                      validator: (val) =>
                          val!.isEmpty ? 'This field is required' : null,
                    ),
                    _buildDropdown(
                      label: 'Ball Type',
                      value: _ballTypeOptions[0],
                      items: _ballTypeOptions,
                      onChanged: (value) {
                        setState(() {
                          _ballTypeController.text = value!;
                        });
                      },
                      icon: Icons.sports_baseball,
                    ),
                    _buildTextField(
                      controller: _entryFeeController,
                      label: 'Entry Fee',
                      hint: 'Enter entry fee amount',
                      icon: Icons.attach_money,
                      keyboardType: TextInputType.number,
                      validator: (val) =>
                          val!.isEmpty ? 'This field is required' : null,
                    ),
                    _buildTextField(
                      controller: _winningPrizeController,
                      label: 'Winning Prize (Optional)',
                      hint: 'Enter winning prize details',
                      icon: Icons.card_giftcard,
                    ),
                    _buildTextField(
                      controller: _playerEligibilityController,
                      label: 'Player Eligibility (Optional)',
                      hint: 'Enter eligibility criteria',
                      icon: Icons.person_search,
                    ),
                    _buildTextField(
                      controller: _teamCompositionController,
                      label: 'Team Composition (players per team)',
                      hint: 'Enter number of players',
                      icon: Icons.people,
                      keyboardType: TextInputType.number,
                      validator: (val) =>
                          val!.isEmpty ? 'This field is required' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildSectionTitle('Additional Settings'),
                    SwitchListTile(
                      title: const Text('Umpire Provided'),
                      subtitle:
                          const Text('Will you provide umpires for matches?'),
                      value: _umpireProvided,
                      onChanged: (value) {
                        setState(() {
                          _umpireProvided = value;
                        });
                      },
                      secondary: const Icon(Icons.sports),
                    ),
                    SwitchListTile(
                      title: const Text('Auto-Generate Fixtures'),
                      subtitle:
                          const Text('Automatically create match fixtures'),
                      value: _autoFixtureGeneration,
                      onChanged: (value) {
                        setState(() {
                          _autoFixtureGeneration = value;
                        });
                      },
                      secondary: const Icon(Icons.auto_awesome),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Create Tournament',
                          style: GoogleFonts.montserrat(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: GoogleFonts.montserrat(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Colors.red,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(
            icon,
            color: Colors.grey[700],
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          filled: true,
          fillColor: Colors.grey[50],
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
        keyboardType: keyboardType,
        validator: validator,
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: value,
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.red),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          filled: true,
          fillColor: Colors.grey[50],
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildDatePicker({
    required String label,
    required String value,
    required VoidCallback onTap,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(icon, color: Colors.red),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: Text(value),
        ),
      ),
    );
  }
}
