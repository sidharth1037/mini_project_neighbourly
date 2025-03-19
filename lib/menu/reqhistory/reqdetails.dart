import 'package:flutter/material.dart';
import '../../styles/styles.dart';

class ReqDetailsPage extends StatelessWidget {
  const ReqDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Request details stored as a JSON-like Map
    final Map<String, dynamic> requestDetails = {
      "title": "Grocery Pickup",
      "description": "Buy groceries from the nearby store and deliver them.",
      "created": "25.02.25, 10:15 AM",
      "endTime": "25.02.25, 12:00 PM",
      "amount": "500 ₹",
      "status": "Completed",
    };

    return Scaffold(
      backgroundColor: Styles.darkPurple, // Set background color
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Title Section (Top One-Third)
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.33,
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Text("Request Details", style: Styles.titleStyle),
                  ),
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

            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Description Container
                  buildInfoContainer(
                    requestDetails["title"],
                  ),

                  const SizedBox(height: 10),

                  buildInfoContainer(
                    'Description: ',
                    value: requestDetails["description"],
                  ),

                  const SizedBox(height: 10),

                  // Created Time
                  buildInfoContainer("Request Created:", value: requestDetails["created"]),

                  const SizedBox(height: 10),

                  // End Time
                  buildInfoContainer("Request End Time:", value: requestDetails["endTime"]),

                  const SizedBox(height: 10),

                  // Amount
                  buildInfoContainer("Amount:", value: requestDetails["amount"]),

                  const SizedBox(height: 10),

                  // Status Container
                  buildInfoContainer(
                    "Status:",
                    value: requestDetails["status"],
                    isStatus: true, // Apply status-specific styling
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Function to build info container dynamically
  Widget buildInfoContainer(String title, {String value = '', bool isStatus = false}) {

    Color statusColor = Colors.yellow[500]!;

    if (value == 'Completed') {
      statusColor = const Color.fromARGB(255, 145, 255, 150);
    } else if (value == 'Cancelled') {
      statusColor = const Color.fromARGB(255, 255, 103, 92);
    }
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Styles.mildPurple,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        value.isEmpty ? title : "$title $value",
        style: value.isEmpty
            ? Styles.bodyStyle.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              )
            : isStatus
                ? Styles.bodyStyle.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  )
                : Styles.bodyStyle,
      ),
    );
  }
}
