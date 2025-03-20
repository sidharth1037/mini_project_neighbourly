import 'package:flutter/material.dart';
import '../styles/styles.dart';

class ReqDetailsPage extends StatelessWidget {
  final Map<String, dynamic> request;

  const ReqDetailsPage({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
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
                  const Align(
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
                    request["requestType"],
                  ),

                  const SizedBox(height: 10),

                  buildInfoContainer(
                    'Description: ',
                    value: request["description"],
                  ),

                  const SizedBox(height: 10),

                  // Created Time
                  buildInfoContainer("Date:", value: request["date"]),

                  const SizedBox(height: 10),

                  // End Time
                  buildInfoContainer("Time:", value: request["date"] != null
                    ? (DateTime.tryParse(request["date"]) != null
                    ? "${DateTime.parse(request["date"]).day.toString().padLeft(2, '0')}-${DateTime.parse(request["date"]).month.toString().padLeft(2, '0')}-${DateTime.parse(request["date"]).year}"
                    : "Invalid Date")
                    : "N/A"),

                  const SizedBox(height: 10),
                  buildInfoContainer("Amount:", value: "${request["amount"]} ₹"),

                  const SizedBox(height: 10),
                  buildInfoContainer("Volunteer Preference:", value: request["volunteerGender"]),

                  const SizedBox(height: 10),
                  buildInfoContainer("Send To:", value: request["requestAt"]),

                  const SizedBox(height: 10),

                  // Status Container
                  buildInfoContainer(
                    "Status: ",
                    value: request["status"],
                    isStatus: true, // Apply status-specific styling
                  ),

                  const SizedBox(height: 26),

                  // Cancel Request Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: TextButton(
                      onPressed: () {
                        showConfirmationDialog(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[400],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: const BorderSide(color: Styles.offWhite, width: 2),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.cancel, color: Colors.white, size: 26),
                          SizedBox(width: 8),
                          Text(
                            "Cancel Request",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
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

  // Function to build info container dynamically
  Widget buildInfoContainer(String title, {String value = '', bool isStatus = false}) {
    Color statusColor = Colors.yellow[500]!;
    String statusText = "";

    if (value == 'Accepted') {
      statusColor = const Color.fromARGB(255, 145, 255, 150); 
      statusText = "Accepted by a volunteer";
    } else if (value == 'Waiting') {
      statusColor = Colors.yellow[500]!;
      statusText = "Waiting for volunteer";
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(15, 15, 20, 15),
      decoration: BoxDecoration(
        color: Styles.mildPurple,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isStatus ? "Status: $statusText" : (value.isEmpty ? title : "⦿ $title $value"),
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

// Confirmation Dialog Function
void showConfirmationDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Styles.mildPurple,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          "Confirm Cancellation",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        content: const Text(
          "Are you sure you want to cancel this request?",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        actions: [
          Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    backgroundColor: Styles.lightPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    "Do Not Cancel",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.red[400],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    "Cancel Request",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    },
  );
}
