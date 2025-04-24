import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'create_team_form.dart';
import 'package:google_fonts/google_fonts.dart';

class MyTeamPage extends StatefulWidget {
  const MyTeamPage({super.key});

  @override
  _MyTeamPageState createState() => _MyTeamPageState();
}

class _MyTeamPageState extends State<MyTeamPage> {
  Map<String, dynamic>? teamData;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchMyTeam();
  }

  Future<void> fetchMyTeam() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final teamResponse = await ApiService.getMyTeam();

      if (teamResponse == null || teamResponse.containsKey("error")) {
        setState(() {
          errorMessage = teamResponse?["error"] ?? "Failed to fetch team";
          isLoading = false;
        });
      } else {
        setState(() {
          teamData = teamResponse;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "⚠️ Network error: ${e.toString()}";
        isLoading = false;
      });
    }
  }

  void _navigateToCreateTeam() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateTeamForm(
          onTeamCreated: fetchMyTeam, // Refresh data after team creation
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "My Team",
          style: GoogleFonts.montserrat(
            fontSize: 24,
            fontWeight: FontWeight.w800, // ExtraBold (800)
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: fetchMyTeam,
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(errorMessage!, textAlign: TextAlign.center),
                        SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: _navigateToCreateTeam,
                          child: Text("Create Team"),
                        ),
                      ],
                    ),
                  )
                : teamData != null
                    ? ListView(
                        padding: EdgeInsets.all(16),
                        children: [
                          // Team Card
                          Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 3,
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  // Team Logo
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                        50), // Circular image
                                    child: Image.network(
                                      teamData!['team']['teamLogo'] ?? "",
                                      height: 70,
                                      width: 70,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Icon(Icons.broken_image,
                                            size: 70, color: Colors.grey);
                                      },
                                    ),
                                  ),
                                  SizedBox(width: 15),
                                  // Team Name
                                  Expanded(
                                    child: Text(
                                      teamData!['team']['teamName'] ??
                                          "No Team Name",
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          SizedBox(height: 20),

                          // Show Ground Name if Own Ground Exists
                          if (teamData!['team']['hasOwnGround'] == true) ...[
                            Divider(),
                            Text(
                              "Ground: ${teamData!['team']['groundDetails']['groundName']}",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ],
                      )
                    : Center(child: Text("No team data available")),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateTeam,
        tooltip: "Create Team",
        child: Icon(Icons.add),
      ),
    );
  }
}
