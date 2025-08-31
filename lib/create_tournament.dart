import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

// Custom Toggle Switch Widget
class CustomToggleSwitch extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color? activeColor;
  final Color? inactiveColor;

  const CustomToggleSwitch({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.activeColor,
    this.inactiveColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: value
              ? (activeColor ?? Colors.green).withOpacity(0.2)
              : Colors.grey.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: () {
              onChanged(!value);
              HapticFeedback.lightImpact();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 56,
              height: 32,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: value
                      ? [
                          activeColor ?? Colors.green,
                          (activeColor ?? Colors.green).withOpacity(0.8),
                        ]
                      : [
                          inactiveColor ?? Colors.grey[300]!,
                          inactiveColor ?? Colors.grey[400]!,
                        ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: value
                        ? (activeColor ?? Colors.green).withOpacity(0.3)
                        : Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    top: 2,
                    left: value ? 26 : 2,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            spreadRadius: 0.5,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: value
                          ? Icon(
                              Icons.check,
                              size: 16,
                              color: activeColor ?? Colors.green,
                            )
                          : Icon(
                              Icons.close,
                              size: 16,
                              color: Colors.grey[500],
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CreateTournamentScreen extends StatefulWidget {
  final bool isEmbedded; // Add this parameter

  const CreateTournamentScreen({super.key, this.isEmbedded = false});

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

          // Only navigate away if not embedded in tabs
          if (!widget.isEmbedded) {
            Navigator.pop(context);
          }
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
    // If embedded, don't show Scaffold
    if (widget.isEmbedded) {
      return _buildFormContent();
    }

    // Original Scaffold version for standalone use
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: Colors.white,
      body: _buildFormContent(),
    );
  }

  Widget _buildFormContent() {
    return _isLoading
        ? Center(
            child: CupertinoActivityIndicator(
              radius: 12, // Small size (consistent with other screens)
              color: Colors.grey.shade600, // Metal silver color
            ),
          )
        : Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Remove the title when embedded
                  if (!widget.isEmbedded) ...[
                    const Text(
                      'Create Tournament',
                      style: TextStyle(
                        fontFamily: 'Boldonse',
                        fontSize: 15,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  _buildTextField(
                    controller: _tournamentNameController,
                    label: 'Tournament name',
                    validator: _requiredFieldValidator,
                  ),
                  _buildDropdown(
                    label: 'Tournament type',
                    value: _tournamentTypeController.text,
                    items: _tournamentTypeOptions,
                    onChanged: (value) {
                      _tournamentTypeController.text = value!;
                    },
                  ),
                  _buildTextField(
                    controller: _locationController,
                    label: 'Location',
                    validator: _requiredFieldValidator,
                  ),
                  _buildTextField(
                    controller: _groundNameController,
                    label: 'Ground name (Optional)',
                  ),
                  _buildTextField(
                    controller: _organizerNameController,
                    label: 'Organizer name',
                    validator: _requiredFieldValidator,
                  ),
                  _buildTextField(
                    controller: _phoneController,
                    label: 'Phone (Optional)',
                    keyboardType: TextInputType.phone,
                  ),
                  _buildTextField(
                    controller: _emailController,
                    label: 'Email (Optional)',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  _buildDatePicker(
                    label: 'Start date',
                    value: _dateFormat.format(_startDate),
                    onTap: () => _selectDate(context, 'start'),
                  ),
                  _buildDatePicker(
                    label: 'End date',
                    value: _dateFormat.format(_endDate),
                    onTap: () => _selectDate(context, 'end'),
                  ),
                  _buildDatePicker(
                    label: 'Last date to register',
                    value: _dateFormat.format(_lastDateToRegister),
                    onTap: () => _selectDate(context, 'register'),
                  ),
                  _buildDropdown(
                    label: 'Match days preference',
                    value: _matchDaysPreference,
                    items: _matchDaysOptions,
                    onChanged: (value) {
                      setState(() {
                        _matchDaysPreference = value!;
                      });
                    },
                  ),
                  _buildSessionsSelection(),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _numberOfTeamsController,
                    label: 'Number of teams',
                    keyboardType: TextInputType.number,
                    validator: _requiredFieldValidator,
                  ),
                  _buildTextField(
                    controller: _oversPerMatchController,
                    label: 'Overs per match',
                    keyboardType: TextInputType.number,
                    validator: _requiredFieldValidator,
                  ),
                  _buildDropdown(
                    label: 'Ball type',
                    value: _ballTypeController.text,
                    items: _ballTypeOptions,
                    onChanged: (value) {
                      _ballTypeController.text = value!;
                    },
                  ),
                  _buildTextField(
                    controller: _entryFeeController,
                    label: 'Entry fee',
                    keyboardType: TextInputType.number,
                    validator: _requiredFieldValidator,
                  ),
                  _buildTextField(
                    controller: _winningPrizeController,
                    label: 'Winning prize (Optional)',
                  ),
                  _buildTextField(
                    controller: _playerEligibilityController,
                    label: 'Player eligibility (Optional)',
                  ),
                  _buildTextField(
                    controller: _teamCompositionController,
                    label: 'Team composition (players per team)',
                    keyboardType: TextInputType.number,
                    validator: _requiredFieldValidator,
                  ),

                  // Replace SwitchListTile with CustomToggleSwitch
                  CustomToggleSwitch(
                    title: 'Umpires',
                    subtitle: 'Will you provide umpires for matches?',
                    value: _umpireProvided,
                    activeColor: Colors.green,
                    onChanged: (value) {
                      setState(() {
                        _umpireProvided = value;
                      });
                    },
                  ),

                  CustomToggleSwitch(
                    title: 'Auto-Generate Fixtures',
                    subtitle: 'Automatically create match fixtures',
                    value: _autoFixtureGeneration,
                    activeColor: Colors.green,
                    onChanged: (value) {
                      setState(() {
                        _autoFixtureGeneration = value;
                      });
                    },
                  ),

                  const SizedBox(height: 32),
                  Center(
                    child: _buildSubmitButton(),
                  ),
                  const SizedBox(height: 24),
                ],
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
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    final normalBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: Colors.black, width: 1),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          border: normalBorder,
          enabledBorder: normalBorder,
          focusedBorder: normalBorder,
          labelStyle: const TextStyle(color: Colors.black),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    final normalBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Colors.black, width: 1),
    );

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
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          border: normalBorder,
          enabledBorder: normalBorder,
          focusedBorder: normalBorder,
          labelStyle: const TextStyle(color: Colors.black),
        ),
      ),
    );
  }

  Widget _buildDatePicker({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    final normalBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.black, width: 1),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            border: normalBorder,
            enabledBorder: normalBorder,
            focusedBorder: normalBorder,
            labelStyle: const TextStyle(color: Colors.black),
          ),
          child: Text(
            value,
            style: const TextStyle(color: Colors.black),
          ),
        ),
      ),
    );
  }

  Widget _buildSessionsSelection() {
    return Wrap(
      spacing: 8,
      children: _sessionOptions.map((session) {
        final isSelected = _sessionsAvailable.contains(session);
        return FilterChip(
          label: Text(session),
          selected: isSelected,
          onSelected: (selected) => _toggleSession(session),
          backgroundColor: Colors.white,
          selectedColor: Colors.white,
          side: BorderSide(
            color: isSelected ? Colors.green : Colors.black,
            width: 1.5,
          ),
          checkmarkColor: Colors.green,
          labelStyle: TextStyle(
            color: isSelected ? Colors.green[800] : Colors.black,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: 200,
      height: 50, // increased from 45
      child: ElevatedButton(
        onPressed: _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 8), // reduced padding
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 5,
        ),
        child: const Text(
          'CREATE',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            fontSize: 16, // optional to make text more visible
          ),
        ),
      ),
    );
  }
}
