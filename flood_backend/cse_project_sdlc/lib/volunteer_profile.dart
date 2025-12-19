import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class VolunteerProfilePage extends StatefulWidget {
  final int volunteerId;

  const VolunteerProfilePage({super.key, required this.volunteerId});

  @override
  State<VolunteerProfilePage> createState() => _VolunteerProfilePageState();
}

class _VolunteerProfilePageState extends State<VolunteerProfilePage> {
  bool isLoading = true;
  Map<String, dynamic>? profile;

  Future<void> fetchProfile() async {
    final response = await http.get(
      Uri.parse("${ApiConfig.baseUrl}/volunteers/${widget.volunteerId}/profile"),
    );

    if (response.statusCode == 200) {
      setState(() {
        profile = jsonDecode(response.body);
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101C22),
      appBar: AppBar(
        backgroundColor: const Color(0xFF101C22),
        title: const Text("Volunteer Profile"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              profile!["name"],
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              "Verified Hours: ${profile!["verified_hours"]}",
              style: const TextStyle(color: Colors.lightGreen),
            ),
            const SizedBox(height: 20),

            const Text("Completed Tasks",
                style: TextStyle(color: Colors.white70)),
            ...profile!["completed_tasks"].map<Widget>((task) {
              return ListTile(
                title: Text(task["title"],
                    style: const TextStyle(color: Colors.white)),
              );
            }).toList(),

            const SizedBox(height: 20),
            const Text("Badges",
                style: TextStyle(color: Colors.white70)),
            Wrap(
              spacing: 8,
              children: profile!["badges"].map<Widget>((badge) {
                return Chip(
                  label: Text(badge["name"]),
                  backgroundColor: Colors.lightGreenAccent,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
