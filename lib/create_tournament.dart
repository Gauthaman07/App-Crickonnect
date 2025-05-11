import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class CreateTournamentScreen extends StatefulWidget {
  const CreateTournamentScreen({super.key});

  @override
  State<CreateTournamentScreen> createState() => _CreateTournamentScreenState();
}

class _CreateTournamentScreenState extends State<CreateTournamentScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  final ApiService _apiService = ApiService();

  // Constants to reduce string literals
  static const _requiredFieldError = 'This field is required';

  // Predefined styles to avoid recreating them
  final _sectionTitleStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );

  final _buttonTextStyle = GoogleFonts.montserrat(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  // Form controllers - lazily initialized
  late final TextEditingController _tournamentNameController;
  late final TextEditingController _tournamentTypeController;
  late final TextEditingController _locationController;
  late final TextEditingController _groundNameController;
  late final TextEditingController _organizerNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _numberOfTeamsController;
  late final TextEditingController _oversPerMatchController;
  late final TextEditingController _ballTypeController;
  late final TextEditingController _entryFeeController;
  late final TextEditingController _winningPrizeController;
  late final TextEditingController _playerEligibilityController;
  late final TextEditingController _teamCompositionController;

  // Form field values
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 7));
  DateTime _lastDateToRegister = DateTime.now().add(const Duration(days: 3));

  String _matchDaysPreference = 'Weekends';
  final List<String> _sessionsAvailable = ['Morning'];
  bool _umpireProvided = false;
  bool _autoFixtureGeneration = false;

  // Options - made static const for better performance
  static const List<String> _matchDaysOptions = [
    'Weekends',
    'Weekdays',
    'Any Day'
  ];
  static const List<String> _sessionOptions = [
    'Morning',
    'Afternoon',
    'Evening',
    'Night'
  ];
  static const List<String> _tournamentTypeOptions = [
    'Knockout',
    'League',
    'Series'
  ];
  static const List<String> _ballTypeOptions = [
    'Tennis',
    'Red Leather',
    'White Leather',
    'Hard Ball'
  ];

  // Reusable decoration properties
  late final BorderRadius _borderRadius;
  late final OutlineInputBorder _normalBorder;
  late final OutlineInputBorder _focusedBorder;

  // DateFormat is expensive, create once
  final _dateFormat = DateFormat('MMM dd, yyyy');

  @override
  void initState() {
    super.initState();

    // Initialize controllers
    _tournamentNameController = TextEditingController();
    _tournamentTypeController =
        TextEditingController(text: _tournamentTypeOptions[0]);
    _locationController = TextEditingController();
    _groundNameController = TextEditingController();
    _organizerNameController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _numberOfTeamsController = TextEditingController();
    _oversPerMatchController = TextEditingController();
    _ballTypeController = TextEditingController(text: _ballTypeOptions[0]);
    _entryFeeController = TextEditingController();
    _winningPrizeController = TextEditingController();
    _playerEligibilityController = TextEditingController();
    _teamCompositionController = TextEditingController();

    // Initialize reusable UI elements
    _borderRadius = BorderRadius.circular(8);
    _normalBorder = OutlineInputBorder(
      borderRadius: _borderRadius,
      borderSide: BorderSide(color: Colors.grey[300]!),
    );
    _focusedBorder = OutlineInputBorder(
      borderRadius: _borderRadius,
      borderSide: const BorderSide(color: Colors.black, width: 2),
    );
  }

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

      try {
        // Create tournament data map (moved inside try block for performance)
        final tournamentData = {
          'tournamentName': _tournamentNameController.text,
          'tournamentType': _tournamentTypeController.text,
          'location': _locationController.text,
          'groundName': _groundNameController.text.isEmpty
              ? null
              : _groundNameController.text,
          'organizerName': _organizerNameController.text,
          'contactDetails': {
            'phone':
                _phoneController.text.isEmpty ? null : _phoneController.text,
            'email':
                _emailController.text.isEmpty ? null : _emailController.text,
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

        // Call API service to create tournament
        await _apiService.createTournament(tournamentData);

        // Success handling
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tournament created successfully!')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        // Error handling
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Error creating tournament: ${e.toString()}')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: Colors.white,
      body: _isLoading
          ? Center(
              child: LoadingAnimationWidget.threeArchedCircle(
                color: Colors.red,
                size: 40,
              ),
            )
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Create Tournament',
                      style: TextStyle(
                        fontFamily: 'Boldonse',
                        fontSize: 15,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _tournamentNameController,
                      label: 'Tournament Name',
                      validator: _requiredFieldValidator,
                    ),
                    _buildDropdown(
                      label: 'Tournament Type',
                      value: _tournamentTypeController.text,
                      items: _tournamentTypeOptions,
                      onChanged: (value) {
                        _tournamentTypeController.text = value!;
                      },
                    ),
                    _buildTextField(
                      controller: _locationController,
                      label: 'Location',
                      // hint: 'Enter tournament location',
                      validator: _requiredFieldValidator,
                    ),
                    _buildTextField(
                      controller: _groundNameController,
                      label: 'Ground Name (Optional)',
                      // hint: 'Enter ground name',
                    ),
                    // const SizedBox(height: 16),
                    _buildTextField(
                      controller: _organizerNameController,
                      label: 'Organizer Name',
                      // hint: 'Enter organizer name',
                      validator: _requiredFieldValidator,
                    ),
                    _buildTextField(
                      controller: _phoneController,
                      label: 'Phone (Optional)',
                      // hint: 'Enter contact phone',
                      keyboardType: TextInputType.phone,
                    ),
                    _buildTextField(
                      controller: _emailController,
                      label: 'Email (Optional)',
                      // hint: 'Enter contact email',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    // const SizedBox(height: 16),
                    _buildDatePicker(
                      label: 'Start Date',
                      value: _dateFormat.format(_startDate),
                      onTap: () => _selectDate(context, 'start'),
                    ),
                    _buildDatePicker(
                      label: 'End Date',
                      value: _dateFormat.format(_endDate),
                      onTap: () => _selectDate(context, 'end'),
                    ),
                    _buildDatePicker(
                      label: 'Last Date to Register',
                      value: _dateFormat.format(_lastDateToRegister),
                      onTap: () => _selectDate(context, 'register'),
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
                    ),
                    // const SizedBox(height: 16),
                    _buildSessionsSelection(),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _numberOfTeamsController,
                      label: 'Number of Teams',
                      // hint: 'Enter number of teams',
                      keyboardType: TextInputType.number,
                      validator: _requiredFieldValidator,
                    ),
                    _buildTextField(
                      controller: _oversPerMatchController,
                      label: 'Overs Per Match',
                      // hint: 'Enter overs per match',
                      keyboardType: TextInputType.number,
                      validator: _requiredFieldValidator,
                    ),
                    _buildDropdown(
                      label: 'Ball Type',
                      value: _ballTypeController.text,
                      items: _ballTypeOptions,
                      onChanged: (value) {
                        _ballTypeController.text = value!;
                      },
                    ),
                    _buildTextField(
                      controller: _entryFeeController,
                      label: 'Entry Fee',
                      // hint: 'Enter entry fee amount',
                      keyboardType: TextInputType.number,
                      validator: _requiredFieldValidator,
                    ),
                    _buildTextField(
                      controller: _winningPrizeController,
                      label: 'Winning Prize (Optional)',
                      // hint: 'Enter winning prize details',
                    ),
                    _buildTextField(
                      controller: _playerEligibilityController,
                      label: 'Player Eligibility (Optional)',
                      // hint: 'Enter eligibility criteria',
                    ),
                    _buildTextField(
                      controller: _teamCompositionController,
                      label: 'Team Composition (players per team)',
                      // hint: 'Enter number of players',
                      keyboardType: TextInputType.number,
                      validator: _requiredFieldValidator,
                    ),
                    // const SizedBox(height: 16),
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
                      secondary: null, // Removed icon
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
                      secondary: null, // Removed icon
                    ),
                    const SizedBox(height: 32),
                    Center(
                      // Centered the button
                      child: _buildSubmitButton(),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  // Extracted common validator function
  String? _requiredFieldValidator(String? val) =>
      val!.isEmpty ? _requiredFieldError : null;

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title, style: _sectionTitleStyle),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    // required String hint,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    // Reuse the decoration for better performance
    final decoration = InputDecoration(
      labelText: label,
      // hintText: hint,
      // Removed prefixIcon
      border: _normalBorder,
      enabledBorder: _normalBorder,
      focusedBorder: _focusedBorder,
      filled: true,
      fillColor: Colors.grey[50],
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: decoration,
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
          // Removed prefixIcon
          border: _normalBorder,
          enabledBorder: _normalBorder,
          focusedBorder: _focusedBorder,
          filled: true,
          fillColor: Colors.grey[50],
          contentPadding:
              const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        ),
      ),
    );
  }

  Widget _buildDatePicker({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            // Removed prefixIcon
            border: _normalBorder,
            enabledBorder: _normalBorder,
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding:
                const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          ),
          child: Text(value),
        ),
      ),
    );
  }

  // Extracted method for sessions selection
  Widget _buildSessionsSelection() {
    return Wrap(
      spacing: 8,
      children: _sessionOptions.map((session) {
        final isSelected = _sessionsAvailable.contains(session);
        return FilterChip(
          label: Text(session),
          selected: isSelected,
          onSelected: (selected) => _toggleSession(session),
          backgroundColor: Colors.white, // Always white
          selectedColor: Colors.white, // Even when selected, stays white
          side: BorderSide(
            color: isSelected ? Colors.red : Colors.grey, // Border changes
            width: 1.5,
          ),
          checkmarkColor: Colors.red,
          labelStyle: TextStyle(
            color: isSelected ? Colors.red[800] : Colors.black,
          ),
        );
      }).toList(),
    );
  }

  // Extracted method for submit button
  Widget _buildSubmitButton() {
    return SizedBox(
      width: 200,
      height: 45,
      child: ElevatedButton(
        onPressed: _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white, // Added foreground color
          padding: EdgeInsets.symmetric(vertical: 16), // Added padding
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30), // Matching border radius
          ),
          elevation: 5, // Added elevation
        ),
        child: Text(
          'CREATE',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }
}
