import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = "https://crikonnect-api.onrender.com/api";

  static Future<Map<String, dynamic>> signIn(
      String emailOrMobile, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/auth/login"),
        headers: {"Content-Type": "application/json"},
        body:
            jsonEncode({"emailOrMobile": emailOrMobile, "password": password}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // Save token in SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', responseData['token']);
        await prefs.setBool('isLoggedIn', true);

        return {"success": true, "token": responseData['token']};
      } else {
        return {
          "success": false,
          "message": jsonDecode(response.body)["message"] ?? "Login failed"
        };
      }
    } catch (e) {
      return {
        "success": false,
        "message": "Network error: ${e.toString()}",
        "errorType": e.runtimeType.toString()
      };
    }
  }

  // Fetch team details
  static Future<Map<String, dynamic>?> getMyTeam() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString("token");

      if (token == null) {
        return {"error": "Authentication token is missing"};
      }

      final response = await http.get(
        Uri.parse("$baseUrl/team/myteam"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 404 || response.body.isEmpty) {
        return {"error": "no team found for user"};
      } else {
        return {
          "error":
              "Failed to fetch team. Status: ${response.statusCode}, Message: ${response.body}"
        };
      }
    } catch (e) {
      return {
        "error": "Network error: ${e.toString()}",
        "errorType": e.runtimeType.toString()
      };
    }
  }

  // Create a team
  static Future<Map<String, dynamic>> createTeam(
      Map<String, dynamic> teamData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString("token");

      if (token == null) {
        return {"success": false, "message": "Authentication token is missing"};
      }

      final response = await http.post(
        Uri.parse("$baseUrl/team/create"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(teamData),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {"success": true, "message": "Team created successfully"};
      } else {
        return {
          "success": false,
          "message":
              "Failed to create team. Status: ${response.statusCode}, Message: ${response.body}"
        };
      }
    } catch (e) {
      return {
        "success": false,
        "message": "Network error: ${e.toString()}",
        "errorType": e.runtimeType.toString()
      };
    }
  }

  static Future<Map<String, dynamic>> fetchGrounds(String location) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString("token");

      if (token == null) {
        throw Exception("Authentication token is missing");
      }

      final String url = "$baseUrl/grounds?location=$location";
      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);

        if (decodedResponse is Map<String, dynamic>) {
          return {
            "grounds": decodedResponse["grounds"] != null
                ? List<Map<String, dynamic>>.from(decodedResponse["grounds"])
                : [],
            "otherGrounds": decodedResponse["otherGrounds"] != null
                ? List<Map<String, dynamic>>.from(
                    decodedResponse["otherGrounds"])
                : [],
            "yourGround": decodedResponse["yourGround"] != null
                ? Map<String, dynamic>.from(decodedResponse["yourGround"])
                : null, // ✅ Fixed this
            "userBookings": decodedResponse["userBookings"] != null
                ? List<Map<String, dynamic>>.from(
                    decodedResponse["userBookings"])
                : [],
          };
        }

        throw Exception(
            "Invalid response format: Expected a valid JSON object");
      } else {
        throw Exception("Failed to load grounds: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Something went wrong: $e");
    }
  }

  // Fetch and Store User Profile
  static Future<Map<String, dynamic>?> fetchUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString("token");

      if (token == null) {
        throw Exception("Authentication token is missing");
      }

      final String url = "$baseUrl/user/profile";
      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);

        if (decodedResponse is Map<String, dynamic>) {
          // Store user profile in SharedPreferences
          await prefs.setString("userProfile", json.encode(decodedResponse));
          return decodedResponse;
        } else {
          throw Exception("Invalid response format");
        }
      } else {
        throw Exception("Failed to load profile: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Something went wrong: $e");
    }
  }

  // Get Stored User Profile
  static Future<Map<String, dynamic>?> getStoredUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final String? userProfileString = prefs.getString("userProfile");

    if (userProfileString != null) {
      return json.decode(userProfileString);
    }
    return null;
  }

  static Future<Map<String, dynamic>> bookGround(
      Map<String, String> payload) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString("token");

      if (token == null) {
        throw Exception("Authentication token is missing");
      }

      print("📢 Sending API request with payload: $payload"); // Debugging
      print("🔑 Token: $token"); // Debugging

      final response = await http.post(
        Uri.parse("$baseUrl/ground-booking/book"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: json.encode(payload),
      );

      print("✅ Response Code: ${response.statusCode}");
      print("✅ Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        return {"success": false, "message": response.body};
      }
    } catch (e) {
      print("❌ API Error: $e"); // Debugging
      return {"success": false, "message": "Error: $e"};
    }
  }

  Future<bool> updateBookingStatus(String bookingId, String status) async {
    final String url = "$baseUrl/ground-booking/update-status/$bookingId";

    // Get the authentication token from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString("token");

    if (token == null) {
      print("❌ No authentication token available ❌");
      return false;
    }

    print("🔴 API Request Start 🔴");
    print("URL: $url");
    print("Body: ${jsonEncode({"status": status})}");

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({"status": status}),
      );

      print("🔵 API Response (${response.statusCode}) 🔵");
      print("Body: ${response.body}");

      if (response.statusCode == 200) {
        print("✅ API call successful ✅");
        return true;
      } else {
        print("❌ API call failed with status ${response.statusCode} ❌");
        print("Response body: ${response.body}");
        return false;
      }
    } catch (e) {
      print("⚠️ Exception in API call ⚠️");
      print("Error: $e");
      return false;
    }
  }

  Future<Map<String, dynamic>> createTournament(
      Map<String, dynamic> tournamentData) async {
    final url = Uri.parse('$baseUrl/tournaments');
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString("token");

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(tournamentData),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('API Error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to create tournament: ${response.statusCode}');
      }
    } catch (e) {
      print('API Exception: $e');
      throw Exception('Error creating tournament: $e');
    }
  }

  Future<Map<String, dynamic>> getTournamentsByLocation(String location) async {
    final encodedLocation = Uri.encodeComponent(location);
    final url = Uri.parse('$baseUrl/tournaments?location=$encodedLocation');
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString("token");

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return {
          'userTournaments': data['userTournaments'] ?? [],
          'otherTournaments': data['otherTournaments'] ?? [],
        };
      } else if (response.statusCode == 404) {
        print('No tournaments found for this location.');
        return {
          'userTournaments': [],
          'otherTournaments': [],
        };
      } else {
        print('API Error: ${response.statusCode} - ${response.body}');
        throw Exception(
            'Failed to load tournaments by location: ${response.statusCode}');
      }
    } catch (e) {
      print('API Exception: $e');
      throw Exception('Error getting tournaments by location: $e');
    }
  }

  // Get user ID from shared preferences
  Future<String?> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    // Check both possible key names
    String? userId = prefs.getString("userId");
    userId ??= prefs.getString("_id");
    print("Retrieved user ID from storage: $userId");
    return userId;
  }

  Future<Map<String, dynamic>> registerTournament(
      Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/tournaments/register');
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString("token");

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(data),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('API Error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to register: ${response.statusCode}');
      }
    } catch (e) {
      print('API Exception: $e');
      throw Exception('Error registering: $e');
    }
  }
}
