import 'package:flutter/material.dart';
import '../styles/styles.dart';
import 'reqdetails.dart';
import 'newreq.dart';

class RequestsPage extends StatelessWidget {
  const RequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy JSON list of requests
    List<Map<String, String>> requests = [
      {
        "name": "Grocery Pickup",
        "time": "02:30 PM",
        "date": "26.02.25",
        "amount": "500 ₹",
        "status": "Waiting"
      },
      {
        "name": "Doctor Appointment",
        "time": "10:00 AM",
        "date": "27.02.25",
        "amount": "1000 ₹",
        "status": "Accepted"
      },
      {
        "name": "Home Repair",
        "time": "04:45 PM",
        "date": "28.02.25",
        "amount": "300 ₹",
        "status": "Waiting"
      }
    ];

    return Scaffold(
      backgroundColor: Styles.darkPurple, // Set background color
      body: Stack(
        children: [
          // Scrollable Request List
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100), // Avoid overlapping with button
            child: Column(
              children: [
                // Title Section
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.33,
                  child: Center(
                    child: Text("Requests", style: Styles.titleStyle),
                  ),
                ),

                // Request Cards Section
                Padding(
                  padding: const EdgeInsets.fromLTRB(6, 0, 6, 4),
                  child: Column(
                    children: requests.map((request) {
                      return RequestBox(
                        title: request["name"]!,
                        time: request["time"]!,
                        date: request["date"]!,
                        amount: request["amount"]!,
                        status: request["status"]!,
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Fixed "New Request" Button Above Navbar
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 30), // Adjust position above navbar
              child: SizedBox(
                width: MediaQuery.of(context).size.width - 30, // Full screen width minus 20 pixels
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const NewRequestPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Styles.mildPurple,
                    elevation: 10, // Increased elevation for a stronger shadow
                    shadowColor: Colors.black, // Darker and more visible shadow
                    padding: const EdgeInsets.symmetric(vertical: 10), // Removed horizontal padding to fit width
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: const BorderSide(color: Color.fromARGB(255, 209, 209, 209), width: 3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min, // Keep button size compact
                    mainAxisAlignment: MainAxisAlignment.center, // Center text and icon
                    children: [
                      const Icon(Icons.add, color: Colors.white, size: 40), // Plus icon
                      const SizedBox(width: 8), // Space between icon and text
                      const Text("New Request", style: Styles.buttonTextStyle),
                    ],
                  ),
                ),
              )
            ),
          ),
        ],
      ),
    );
  }
}

class RequestBox extends StatelessWidget {
  final String title;
  final String time;
  final String date;
  final String status;
  final String amount;
  final VoidCallback? onTap; // Callback for button press

  const RequestBox({
    super.key,
    required this.title,
    required this.time,
    required this.date,
    required this.status,
    required this.amount,
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
        decoration: Styles.boxDecoration, // Use the same decoration as Profile Page
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10), // Internal padding
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left side: Request details (Flexible)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Styles.nameStyle, softWrap: true, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  // Time, Date, and Status Pills (Auto-wrap)
                  Wrap(
                    alignment: WrapAlignment.start,
                    spacing: 5, // Space between pills
                    runSpacing: 5, // Space between wrapped rows
                    children: [
                      Styles.buildPill("Time: $time", Styles.mildPurple),
                      Styles.buildPill("Date: $date", Styles.mildPurple),
                    ],
                  ),
                  SizedBox(height: 8),
                  Wrap(
                    alignment: WrapAlignment.start,
                    spacing: 5, // Space between pills
                    runSpacing: 5, // Space between wrapped rows
                    children: [
                      Styles.buildPill("Amount: $amount", Styles.mildPurple),
                      Styles.buildPill(status, status == "Accepted" ? Colors.green[500]! : Colors.orange[600]!),
                    ],
                  ),
                ],
              ),
            ),

            // Right side: Fixed-size Forward arrow icon
            SizedBox(
              width: 30, // Set fixed width for arrow
              child: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}