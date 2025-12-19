import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'api_config.dart';

class NGOReportPage extends StatelessWidget {
  final int ngoId;

  const NGOReportPage({super.key, required this.ngoId});

  Future<void> downloadReport() async {
    final url = "${ApiConfig.baseUrl}/ngos/$ngoId/export-report";
    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101C22),
      appBar: AppBar(
        backgroundColor: const Color(0xFF101C22),
        title: const Text("NGO Report"),
      ),
      body: Center(
        child: ElevatedButton.icon(
          onPressed: downloadReport,
          icon: const Icon(Icons.picture_as_pdf),
          label: const Text("Download Activity Report"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.lightGreen,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          ),
        ),
      ),
    );
  }
}
