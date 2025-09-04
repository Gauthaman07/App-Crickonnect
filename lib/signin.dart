import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './services/api_service.dart'; // Import the new API service
import 'signup_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import './myteam/create_team_form.dart';
import 'package:flutter/cupertino.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController emailOrMobileController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  bool isButtonEnabled = false;
  bool isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    emailOrMobileController.addListener(_updateButtonState);
    passwordController.addListener(_updateButtonState);
  }

  @override
  void dispose() {
    emailOrMobileController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _updateButtonState() {
    setState(() {
      isButtonEnabled = emailOrMobileController.text.isNotEmpty &&
          passwordController.text.isNotEmpty;
    });
  }

  Future<void> _signIn() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await ApiService.signIn(
        emailOrMobileController.text,
        passwordController.text,
      );

      if (response['success']) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('token', response['token']);
        prefs.setBool('isLoggedIn', true);

        // Save the user ID from the response
        if (response['user'] != null && response['user']['_id'] != null) {
          prefs.setString('_id', response['user']['_id']);
          print('Saved user ID: ${response['user']['_id']}');
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20),
                SizedBox(width: 12),
                Text(
                  'Login Successful!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: EdgeInsets.all(16),
            elevation: 6,
            duration: Duration(seconds: 3),
          ),
        );

        // Check if user has a team before navigating
        await _checkTeamAndNavigate();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white, size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Login failed: ${response["message"]}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: EdgeInsets.all(16),
            elevation: 6,
            duration: Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.white, size: 20),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Error: $e',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.orange[600],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: EdgeInsets.all(16),
          elevation: 6,
          duration: Duration(seconds: 4),
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _checkTeamAndNavigate() async {
    try {
      final teamResponse = await ApiService.getMyTeam();

      if (teamResponse != null && teamResponse.containsKey('error')) {
        // No team found, navigate to team creation form with callback
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => CreateTeamForm(
              onTeamCreated: () {
                // Navigate to home after team creation
                Navigator.pushReplacementNamed(context, '/home');
              },
            ),
          ),
        );
      } else if (teamResponse != null) {
        // Team exists, navigate to home
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        // Fallback - navigate to team creation form
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => CreateTeamForm(
              onTeamCreated: () {
                Navigator.pushReplacementNamed(context, '/home');
              },
            ),
          ),
        );
      }
    } catch (e) {
      print('Error checking team: $e');
      // On error, navigate to team creation form
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => CreateTeamForm(
            onTeamCreated: () {
              Navigator.pushReplacementNamed(context, '/home');
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Image.asset(
                  'assets/team.jpg',
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.cover,
                ),
                Container(
                  height: 250,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black,
                        Colors.black.withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),
                  Center(
                    child: Text(
                      'Crickonnect',
                      style: GoogleFonts.anton(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Center(
                    child: Text(
                      "Knock 'em out!",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.red[700],
                      ),
                    ),
                  ),
                  SizedBox(height: 40),
                  TextField(
                    controller: emailOrMobileController,
                    style: TextStyle(color: Colors.white),
                    cursorColor: Colors.white70,
                    decoration: InputDecoration(
                      labelText: 'Email or Mobile Number',
                      labelStyle: TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.grey[900],
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.white70, width: 1.0),
                      ),
                    ),
                    keyboardType: TextInputType.text,
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: passwordController,
                    obscureText: !isPasswordVisible,
                    style: TextStyle(color: Colors.white),
                    cursorColor: Colors.white70,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.grey[900],
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.white70, width: 1.0),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                          color: Colors.white70,
                        ),
                        onPressed: () {
                          setState(() {
                            isPasswordVisible = !isPasswordVisible;
                          });
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isButtonEnabled && !isLoading ? _signIn : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isButtonEnabled ? Colors.red : Colors.red[300],
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: isLoading
                          ? CupertinoActivityIndicator(
                              radius:
                                  12, // Small size (consistent with other loaders)
                              color: Colors
                                  .white, // White color for contrast on red button
                            )
                          : Text(
                              'Sign In',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  SizedBox(height: 15),
                  Center(
                    child: TextButton(
                      onPressed: () {},
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SignUpScreen()),
                        );
                      },
                      child: Text(
                        "Create Account",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
