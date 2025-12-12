// // help_request.dart
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:geolocator/geolocator.dart';
//
// class HelpRequestPage extends StatefulWidget {
//   const HelpRequestPage({super.key});
//
//   @override
//   State<HelpRequestPage> createState() => _HelpRequestPageState();
// }
//
// class _HelpRequestPageState extends State<HelpRequestPage> {
//   String? selectedType; // "food" | "water" | "rescue"
//   Position? currentPosition;
//   bool isLocating = false;
//   bool isSubmitting = false;
//
//   final String baseUrl = "http://127.0.0.1:1898";
//
//   Future<void> ensureLocationPermission() async {
//     LocationPermission permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//     }
//     if (permission == LocationPermission.deniedForever) {
//       throw Exception("Location permission is permanently denied.");
//     }
//   }
//
//   Future<void> getCurrentLocation() async {
//     setState(() => isLocating = true);
//     try {
//       await ensureLocationPermission();
//       final pos = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//       );
//       setState(() => currentPosition = pos);
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Location error: $e")),
//         );
//       }
//     } finally {
//       if (mounted) setState(() => isLocating = false);
//     }
//   }
//
//   Future<void> submitHelpRequest() async {
//     if (selectedType == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Please select a request type (Food/Water/Rescue).")),
//       );
//       return;
//     }
//     if (currentPosition == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Please add your GPS location first.")),
//       );
//       return;
//     }
//
//     setState(() => isSubmitting = true);
//     try {
//       final body = {
//         "type": selectedType,
//         "latitude": currentPosition!.latitude,
//         "longitude": currentPosition!.longitude,
//       };
//
//       final response = await http.post(
//         Uri.parse("$baseUrl/help-requests"),
//         headers: {"Content-Type": "application/json"},
//         body: jsonEncode(body),
//       );
//
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text("Help request sent successfully.")),
//           );
//           setState(() {
//             selectedType = null;
//             currentPosition = null;
//           });
//         }
//       } else {
//         throw Exception("Server response: ${response.statusCode}");
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Submit failed: $e")),
//         );
//       }
//     } finally {
//       if (mounted) setState(() => isSubmitting = false);
//     }
//   }
//
//   Widget buildTypeChip(String type, IconData icon, String label) {
//     final bool active = selectedType == type;
//     return ChoiceChip(
//       label: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(icon, size: 18, color: active ? Colors.black : Colors.white),
//           const SizedBox(width: 6),
//           Text(label, style: TextStyle(color: active ? Colors.black : Colors.white)),
//         ],
//       ),
//       selected: active,
//       selectedColor: Colors.lightGreenAccent,
//       backgroundColor: Colors.white10,
//       onSelected: (_) => setState(() => selectedType = type),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF101C22),
//       appBar: AppBar(
//         backgroundColor: const Color(0xFF101C22),
//         elevation: 0,
//         title: const Text("Request Help",
//             style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text("Choose what you need:",
//                 style: TextStyle(color: Colors.white70, fontSize: 16)),
//             const SizedBox(height: 10),
//             Wrap(
//               spacing: 10,
//               runSpacing: 10,
//               children: [
//                 buildTypeChip("food", Icons.fastfood, "Food"),
//                 buildTypeChip("water", Icons.water_drop, "Water"),
//                 buildTypeChip("rescue", Icons.sos, "Rescue"),
//               ],
//             ),
//             const SizedBox(height: 22),
//             const Text("Your location (GPS):",
//                 style: TextStyle(color: Colors.white70, fontSize: 16)),
//             const SizedBox(height: 10),
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: Colors.white10,
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     currentPosition == null
//                         ? "Not added yet"
//                         : "Lat: ${currentPosition!.latitude}\nLng: ${currentPosition!.longitude}",
//                     style: const TextStyle(color: Colors.white70),
//                   ),
//                   const SizedBox(height: 10),
//                   ElevatedButton.icon(
//                     onPressed: isLocating ? null : getCurrentLocation,
//                     icon: const Icon(Icons.my_location),
//                     label: Text(isLocating ? "Getting location..." : "Add / Refresh GPS"),
//                     style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 44)),
//                   ),
//                 ],
//               ),
//             ),
//             const Spacer(),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: isSubmitting ? null : submitHelpRequest,
//                 style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
//                 child: Text(isSubmitting ? "Sending..." : "Send Help Request"),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }



// help_request.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'api_config.dart';

class HelpRequestPage extends StatefulWidget {
  const HelpRequestPage({super.key});

  @override
  State<HelpRequestPage> createState() => _HelpRequestPageState();
}

class _HelpRequestPageState extends State<HelpRequestPage> {
  String? selectedType; // "food" | "water" | "rescue"
  Position? currentPosition;
  bool isLocating = false;
  bool isSubmitting = false;

  final String baseUrl = ApiConfig.baseUrl;

  Future<void> ensureLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception("Location permission is permanently denied.");
    }
  }

  Future<void> getCurrentLocation() async {
    setState(() => isLocating = true);
    try {
      await ensureLocationPermission();
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() => currentPosition = pos);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Location error: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => isLocating = false);
    }
  }

  Future<void> submitHelpRequest() async {
    if (selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a request type (Food/Water/Rescue).")),
      );
      return;
    }
    if (currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please add your GPS location first.")),
      );
      return;
    }

    setState(() => isSubmitting = true);
    try {
      final body = {
        "type": selectedType,
        "latitude": currentPosition!.latitude,
        "longitude": currentPosition!.longitude,
      };

      final response = await http.post(
        Uri.parse("$baseUrl/help-requests"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Help request sent successfully.")),
          );
          setState(() {
            selectedType = null;
            currentPosition = null;
          });
        }
      } else {
        throw Exception("Server response: ${response.statusCode}");
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Submit failed: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => isSubmitting = false);
    }
  }

  Widget buildTypeChip(String type, IconData icon, String label) {
    final bool active = selectedType == type;
    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: active ? Colors.black : Colors.white),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: active ? Colors.black : Colors.white)),
        ],
      ),
      selected: active,
      selectedColor: Colors.lightGreenAccent,
      backgroundColor: Colors.white10,
      onSelected: (_) => setState(() => selectedType = type),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101C22),
      appBar: AppBar(
        backgroundColor: const Color(0xFF101C22),
        elevation: 0,
        title: const Text("Request Help",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Choose what you need:",
                style: TextStyle(color: Colors.white70, fontSize: 16)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                buildTypeChip("food", Icons.fastfood, "Food"),
                buildTypeChip("water", Icons.water_drop, "Water"),
                buildTypeChip("rescue", Icons.sos, "Rescue"),
              ],
            ),
            const SizedBox(height: 22),
            const Text("Your location (GPS):",
                style: TextStyle(color: Colors.white70, fontSize: 16)),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentPosition == null
                        ? "Not added yet"
                        : "Latitude: ${currentPosition!.latitude.toStringAsFixed(6)}\n"
                        "Longitude: ${currentPosition!.longitude.toStringAsFixed(6)}",
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: isLocating ? null : getCurrentLocation,
                      icon: const Icon(Icons.my_location),
                      label: Text(isLocating ? "Getting location..." : "Get Current Location"),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isSubmitting ? null : submitHelpRequest,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.lightGreen,
                  foregroundColor: Colors.black,
                ),
                child: Text(isSubmitting ? "Sending..." : "Send Help Request"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}