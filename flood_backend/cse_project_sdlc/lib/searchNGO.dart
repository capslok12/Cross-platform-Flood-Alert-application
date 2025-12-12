// searchNGO.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SearchNGOPage extends StatefulWidget {
  const SearchNGOPage({super.key});

  @override
  State<SearchNGOPage> createState() => _SearchNGOPageState();
}

class _SearchNGOPageState extends State<SearchNGOPage> {
  List ngos = [];
  List filteredNGOs = [];
  bool isLoading = true;

  String searchQuery = "";

  // Replace with your backend IP when running on real device/emulator
  final String baseUrl = "http://127.0.0.1:1898";

  @override
  void initState() {
    super.initState();
    fetchNGOs();
  }

  Future<void> fetchNGOs() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.get(Uri.parse("$baseUrl/ngos"));
      if (response.statusCode == 200) {
        ngos = jsonDecode(response.body);
        filteredNGOs = ngos;
      } else {
        print("Failed to load NGOs: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching NGOs: $e");
    }
    setState(() {
      isLoading = false;
    });
  }

  void searchNGO(String query) {
    searchQuery = query;
    setState(() {
      filteredNGOs = ngos.where((ngo) {
        final name = ngo["name"].toString().toLowerCase();
        final location = ngo["location"].toString().toLowerCase();
        final description = ngo["description"].toString().toLowerCase();
        final q = query.toLowerCase();
        return name.contains(q) || location.contains(q) || description.contains(q);
      }).toList();
    });
  }

  Future<void> addNGO(Map<String, String> ngo) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/ngos"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(ngo),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        fetchNGOs();
      }
    } catch (e) {
      print("Error adding NGO: $e");
    }
  }

  Future<void> updateNGO(int id, Map<String, String> ngo) async {
    try {
      final response = await http.put(
        Uri.parse("$baseUrl/ngos/$id"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(ngo),
      );
      if (response.statusCode == 200) {
        fetchNGOs();
      }
    } catch (e) {
      print("Error updating NGO: $e");
    }
  }

  Future<void> deleteNGO(int id) async {
    try {
      final response = await http.delete(Uri.parse("$baseUrl/ngos/$id"));
      if (response.statusCode == 200) {
        fetchNGOs();
      }
    } catch (e) {
      print("Error deleting NGO: $e");
    }
  }

  void showNGODialog({Map? ngo}) {
    final nameController = TextEditingController(text: ngo?["name"] ?? "");
    final locationController = TextEditingController(text: ngo?["location"] ?? "");
    final descriptionController = TextEditingController(text: ngo?["description"] ?? "");
    final contactController = TextEditingController(text: ngo?["contact"] ?? "");

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(ngo == null ? "Add NGO" : "Edit NGO"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: "Name")),
              TextField(controller: locationController, decoration: const InputDecoration(labelText: "Location")),
              TextField(controller: descriptionController, decoration: const InputDecoration(labelText: "Description")),
              TextField(controller: contactController, decoration: const InputDecoration(labelText: "Contact")),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              final newNGO = {
                "name": nameController.text,
                "location": locationController.text,
                "description": descriptionController.text,
                "contact": contactController.text,
              };
              if (ngo == null) {
                addNGO(newNGO);
              } else {
                updateNGO(ngo["id"], newNGO);
              }
              Navigator.pop(context);
            },
            child: Text(ngo == null ? "Add" : "Update"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101C22),
      appBar: AppBar(
        backgroundColor: const Color(0xFF101C22),
        elevation: 0,
        centerTitle: true,
        title: const Text("Search NGOs / Projects",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/help'),
            child: const Text("Request Help", style: TextStyle(color: Colors.lightGreen)),
          ),
          IconButton(
            icon: const Icon(Icons.add, color: Colors.green),
            onPressed: () => showNGODialog(),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                style: const TextStyle(color: Colors.white),
                onChanged: searchNGO,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search, color: Colors.white70),
                  hintText: "Search NGOs or Projects...",
                  hintStyle: TextStyle(color: Colors.white54),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text("Results", style: TextStyle(color: Colors.white70, fontSize: 16)),
            const SizedBox(height: 10),
            Expanded(
              child: filteredNGOs.isEmpty
                  ? const Center(
                  child: Text("No NGOs Found",
                      style: TextStyle(color: Colors.white70, fontSize: 18)))
                  : ListView.builder(
                itemCount: filteredNGOs.length,
                itemBuilder: (context, index) {
                  final ngo = filteredNGOs[index];
                  return Card(
                    color: Colors.white10,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(ngo["name"] ?? "Unknown Name",
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          Text(ngo["location"] ?? "Unknown Location",
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 14)),
                          const SizedBox(height: 6),
                          Text(ngo["description"] ?? "",
                              style: const TextStyle(
                                  color: Colors.white60, fontSize: 13)),
                          const SizedBox(height: 6),
                          Text("Contact: ${ngo["contact"] ?? "-"}",
                              style: const TextStyle(
                                  color: Colors.white60, fontSize: 13)),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                  onPressed: () => showNGODialog(ngo: ngo),
                                  icon: const Icon(Icons.edit, color: Colors.green)),
                              IconButton(
                                  onPressed: () => deleteNGO(ngo["id"]),
                                  icon: const Icon(Icons.delete, color: Colors.red)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
