import 'package:flutter/material.dart';
import '../../styles/styles.dart';
import 'reqdetails.dart';

class ReqHistoryPage extends StatelessWidget {
  const ReqHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy JSON list of requests
    List<Map<String, String>> requests = [
      {
        "name": "Grocery Pickup",
        "date": "26.02.25",
        "status": "Completed"
      },
      {
        "name": "Doctor Appointment",
        "date": "27.02.25",
        "status": "Completed"
      },
      {
        "name": "Home Repair",
        "date": "28.02.25",
        "status": "Cancelled"
      }
    ];

    return Scaffold(
      backgroundColor: Styles.darkPurple, // Set background color
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 100), // Avoid overlapping with button
        child: Column(
          children: [
            // Title Section (Top One-Third)
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.33,
              child: Stack(
                children: [
                  // Title (Centered)
                  Align(
                    alignment: Alignment.center,
                    child: Text("Request History", style: Styles.titleStyle),
                  ),

                  // Back Button (Bottom-Left)
                  Positioned(
                    bottom: 20,
                    left: 20,
                    child: BackButton(
                      color: Styles.white,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
            ),

            // Request Cards Section
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 0, 6, 6),
              child: Column(
                children: requests.map((request) {
                  return RequestBox(
                    title: request["name"]!,
                    date: request["date"]!,
                    status: request["status"]!,
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RequestBox extends StatelessWidget {
  final String title;
  final String date;
  final String status;
  final VoidCallback? onTap; // Callback for button press

  const RequestBox({
    super.key,
    required this.title,
    required this.date,
    required this.status,
    this.onTap, // Allows passing a function when tapped
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ReqDetailsPage()),
        );
      },// Trigger the callback when tapped
      child: Container(
        margin: const EdgeInsets.only(bottom: 6), // Space between cards
        decoration: Styles.boxDecoration, // Use the same decoration as Profile Page
        padding: const EdgeInsets.fromLTRB(12, 16, 12, 16), // Internal padding
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left side: Request details
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Styles.nameStyle),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Styles.buildPill("Date: $date", Styles.mildPurple),
                    const SizedBox(width: 5),
                    Styles.buildPill(status, status == "Completed" ? Colors.green[600]! : Colors.red[400]!),
                  ],
                ),
              ],
            ),
            // Right side: Forward arrow icon
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }
}