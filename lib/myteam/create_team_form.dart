import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '/services/api_service.dart';
import 'package:flutter/services.dart';

class CreateTeamForm extends StatefulWidget {
  final VoidCallback onTeamCreated;

  const CreateTeamForm({super.key, required this.onTeamCreated});

  @override
  _CreateTeamFormState createState() => _CreateTeamFormState();
}

class _CreateTeamFormState extends State<CreateTeamForm> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  File? _teamLogo;
  File? _groundImage; // Added ground image

  final TextEditingController teamNameController = TextEditingController();
  String? teamLocation;
  bool hasOwnGround = false;

  final TextEditingController groundNameController = TextEditingController();
  final TextEditingController groundDescController = TextEditingController();
  final TextEditingController groundLocationController =
      TextEditingController();
  final TextEditingController groundFeesController = TextEditingController();

  // Multi-select ground facilities
  final List<String> availableFacilities = [
    'Floodlights',
    'Turf Pitch',
    'Restroom',
    'Parking',
    'Seating',
    'Scoreboard',
    'Single End',
    'Double End',
    'Drinking Water',
    'First Aid Kit',
  ];
  List<String> selectedFacilities = [];

  bool _isSubmitting = false;

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _teamLogo = File(image.path);
      });
    }
  }

  Future<void> _pickGroundImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _groundImage = File(image.path);
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_teamLogo == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Please upload a team logo')));
      return;
    }

    // Additional validation for ground details
    if (hasOwnGround) {
      if (groundNameController.text.trim().isEmpty ||
          groundDescController.text.trim().isEmpty ||
          groundLocationController.text.trim().isEmpty ||
          groundFeesController.text.trim().isEmpty ||
          _groundImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Please fill all ground details and upload ground image')),
        );
        return;
      }

      if (selectedFacilities.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select at least one facility')),
        );
        return;
      }
    }

    setState(() => _isSubmitting = true);

    // Updated to match backend field names
    Map<String, dynamic> teamData = {
      "teamName": teamNameController.text.trim(),
      "location": teamLocation, // Changed from teamLocation
      "hasOwnGround": hasOwnGround,
      "teamLogo": _teamLogo,
    };

    // Add ground fields directly (not nested) when hasOwnGround is true
    if (hasOwnGround) {
      teamData.addAll({
        "groundName": groundNameController.text.trim(),
        "description":
            groundDescController.text.trim(), // Changed from groundDescription
        "groundMaplink":
            groundLocationController.text.trim(), // Changed from groundLocation
        "facilities": selectedFacilities, // Changed from groundFacilities
        "groundFee":
            groundFeesController.text.trim(), // Changed from groundFees
        "groundImage": _groundImage, // Added ground image
      });
    }

    // ADD THIS DEBUG LOGGING HERE (before the API call)
    print('=== FORM SUBMISSION DEBUG ===');
    print('hasOwnGround: $hasOwnGround');
    print('teamName: ${teamNameController.text.trim()}');
    print('location: $teamLocation');
    print('teamLogo file path: ${_teamLogo?.path}');

    if (hasOwnGround) {
      print('groundName: ${groundNameController.text.trim()}');
      print('description: ${groundDescController.text.trim()}');
      print('groundMaplink: ${groundLocationController.text.trim()}');
      print('facilities: $selectedFacilities');
      print('groundFee: ${groundFeesController.text.trim()}');
      print('groundImage file path: ${_groundImage?.path}');
    }
    print('=== END DEBUG ===');

    try {
      Map<String, dynamic> response = await ApiService.createTeam(teamData);
      bool success = response["success"] ?? false;
      String message = response["message"] ?? 'Something went wrong';

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: success ? Colors.green : Colors.red,
      ));

      if (success) {
        widget.onTeamCreated();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: ${e.toString()}'),
        backgroundColor: Colors.red,
      ));
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // removes the back arrow
        title: const Text(
          'Create Team',
          style: TextStyle(
            fontFamily: 'Boldonse',
            fontSize: 15,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xFF15151E),
        foregroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 70,
        centerTitle: false, // aligns title to the left
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: const Color(0xFFF5F0ED),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Team Logo Upload
                Center(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                        image: _teamLogo != null
                            ? DecorationImage(
                                image: FileImage(_teamLogo!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: _teamLogo == null
                          ? Icon(Icons.add_a_photo,
                              size: 40, color: Colors.grey[600])
                          : null,
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Center(
                  child: Text(
                    "Upload Team Logo",
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(height: 30),

                // Team Basic Information
                // Text(
                //   "TEAM INFORMATION",
                //   style: TextStyle(
                //     fontSize: 14,
                //     fontWeight: FontWeight.bold,
                //     color: Colors.grey[700],
                //     letterSpacing: 1.5,
                //   ),
                // ),
                SizedBox(height: 15),
                TextFormField(
                  controller: teamNameController,
                  decoration: InputDecoration(
                    labelText: 'Team name',
                    labelStyle:
                        TextStyle(color: Colors.grey), // normal label color
                    floatingLabelStyle:
                        TextStyle(color: Colors.black), // color when focused
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.black, width: 1),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.black, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                          color: Colors.black, width: 1), // no color change
                    ),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Enter team name' : null,
                ),

                SizedBox(height: 16),

                // Location Dropdown
                DropdownButtonFormField<String>(
                  value: teamLocation,
                  decoration: InputDecoration(
                    labelText: 'Team location',
                    labelStyle: TextStyle(color: Colors.grey), // normal label
                    floatingLabelStyle:
                        TextStyle(color: Colors.black), // label on focus
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                          color: Colors.black, width: 1), // black border
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                          color: Colors.black, width: 1), // black border
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                          color: Colors.black, width: 1), // stays black
                    ),
                  ),
                  dropdownColor: Colors.white, // popup background
                  items: [
                    'Tirupur',
                    'Coimbatore',
                    'Chennai',
                    'Salem',
                    'Dindigul',
                    'Trichy',
                  ].map((loc) {
                    return DropdownMenuItem(
                      value: loc,
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width *
                            0.6, // popup width reduced
                        child: Text(loc, overflow: TextOverflow.ellipsis),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => teamLocation = value),
                  validator: (value) =>
                      value == null ? 'Select location' : null,
                ),

                SizedBox(height: 30),

                // Ground Section
                ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  tileColor: Colors.white,
                  title: Text(
                    "You have own ground?",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                  trailing: Switch(
                    value: hasOwnGround,
                    onChanged: (value) {
                      HapticFeedback.lightImpact(); // ✅ haptic feedback
                      setState(() => hasOwnGround = value);
                    },
                    activeTrackColor: Colors.green, // background when ON
                    inactiveTrackColor: Colors.grey, // background when OFF
                    activeColor: Colors.white, // thumb (button) color
                    inactiveThumbColor: Colors.white, // thumb stays white
                  ),
                ),

                if (hasOwnGround) ...[
                  // SizedBox(height: 24),
                  // Text(
                  //   "GROUND DETAILS",
                  //   style: TextStyle(
                  //     fontSize: 14,
                  //     fontWeight: FontWeight.bold,
                  //     color: Colors.grey[700],
                  //     letterSpacing: 1.5,
                  //   ),
                  // ),
                  SizedBox(height: 15),
                  TextFormField(
                    controller: groundNameController,
                    decoration: InputDecoration(
                      labelText: 'Ground name',
                      labelStyle: TextStyle(color: Colors.grey), // normal state
                      floatingLabelStyle:
                          TextStyle(color: Colors.black), // on focus
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.black, width: 1),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.black, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                            color: Colors.black, width: 1), // stays black
                      ),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'Enter ground name' : null,
                  ),

                  SizedBox(height: 16),
                  // Ground Description
                  TextFormField(
                    controller: groundDescController,
                    decoration: InputDecoration(
                      labelText: 'Ground description',
                      labelStyle: TextStyle(color: Colors.grey),
                      floatingLabelStyle: TextStyle(color: Colors.black),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.black, width: 1),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.black, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.black, width: 1),
                      ),
                    ),
                    maxLines: 2,
                    validator: (value) =>
                        value!.isEmpty ? 'Enter ground description' : null,
                  ),
                  SizedBox(height: 16),

// Google Map Link
                  TextFormField(
                    controller: groundLocationController,
                    decoration: InputDecoration(
                      labelText: 'Google map link',
                      hintText: 'Paste Google Maps URL',
                      labelStyle: TextStyle(color: Colors.grey),
                      floatingLabelStyle: TextStyle(color: Colors.black),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.black, width: 1),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.black, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.black, width: 1),
                      ),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'Enter ground location link' : null,
                  ),
                  SizedBox(height: 16),

// Ground Fees
                  TextFormField(
                    controller: groundFeesController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Ground fees (₹ per match)',
                      labelStyle: TextStyle(color: Colors.grey),
                      floatingLabelStyle: TextStyle(color: Colors.black),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.black, width: 1),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.black, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.black, width: 1),
                      ),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'Enter ground fees' : null,
                  ),

                  SizedBox(height: 20),

                  // Ground Image Upload
                  Text(
                    "Ground Image",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 12),
                  GestureDetector(
                    onTap: _pickGroundImage,
                    child: Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                        image: _groundImage != null
                            ? DecorationImage(
                                image: FileImage(_groundImage!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: _groundImage == null
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_a_photo,
                                    size: 40, color: Colors.grey[600]),
                                SizedBox(height: 8),
                                Text('Upload Ground Image',
                                    style: TextStyle(color: Colors.grey[600])),
                              ],
                            )
                          : null,
                    ),
                  ),
                  SizedBox(height: 24),

                  // Multi-select Facilities
                  Text(
                    "Avaialable Facilities",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 12),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      // color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: availableFacilities.map((facility) {
                        final isSelected =
                            selectedFacilities.contains(facility);
                        return FilterChip(
                          label: Text(
                            facility,
                            style: TextStyle(
                              color: isSelected ? Colors.green : Colors.black,
                            ),
                          ),
                          selected: isSelected,
                          backgroundColor: Colors.white, // normal state = white
                          selectedColor: Colors.white, // selected state = white
                          checkmarkColor: Colors.green,
                          side: BorderSide(
                            color: isSelected
                                ? Colors.green
                                : Colors.grey.shade300,
                            width: 1.5,
                          ),
                          onSelected: (bool selected) {
                            setState(() {
                              if (selected) {
                                selectedFacilities.add(facility);
                              } else {
                                selectedFacilities.remove(facility);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                  )
                ],

                SizedBox(height: 40),

                // Submit Button
                Center(
                  child: SizedBox(
                    width: 150,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 5,
                      ),
                      child: _isSubmitting
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'CREATE',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                            ),
                    ),
                  ),
                ),
                SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
