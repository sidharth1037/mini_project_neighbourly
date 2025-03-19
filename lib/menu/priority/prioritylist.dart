import 'package:flutter/material.dart';
import '../../../styles/styles.dart';
import 'volunteer.dart';
import 'searchvol.dart';

class PriorityPage extends StatelessWidget {
  const PriorityPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy JSON list of requests
    List<Map<String, String>> requests = [
      {
        "name": "Blesson K Tomy",
        "age": "22",
        "gender": "Male",
        "rating": "4.5",
      },
      {
        "name": "Alex George",
        "age": "21",
        "gender": "Male",
        "rating": "4.2",
      },
      {
        "name": "Aromal M S",
        "age": "19",
        "gender": "Male",
        "rating": "4.0",
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
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: Text("Volunteer\nPriority List", style: Styles.titleStyle, textAlign: TextAlign.center,),
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

                // Request Cards Section
                Padding(
                  padding: const EdgeInsets.fromLTRB(6, 0, 6, 4),
                  child: Column(
                    children: requests.map((request) {
                      return VolunteerBox(
                        title: request["name"]!,
                        age: request["age"]!,
                        gender: request["gender"]!,
                        rating: request["rating"]!,
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
                      MaterialPageRoute(builder: (context) => SearchVolunteerPage()),
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
                      const Text("Add Volunteer", style: Styles.buttonTextStyle),
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

class VolunteerBox extends StatelessWidget {
  final String title;
  final String age;
  final String gender;
  final String rating;
  final VoidCallback? onTap; // Callback for button press

  const VolunteerBox({
    super.key,
    required this.title,
    required this.age,
    required this.gender,
    required this.rating,
    this.onTap, // Allows passing a function when tapped
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const VolunteerDetailsPage()),
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
                      buildPill("Age: $age", Styles.mildPurple),
                      buildPill(gender, Styles.mildPurple),
                      buildPill("Rating: $rating", Styles.mildPurple, isRating: true),
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

Widget buildPill(String text, Color color, {bool isRating = false}) {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 8),
    decoration: BoxDecoration(
      color: color, // Use the passed color for background
      borderRadius: BorderRadius.circular(20), // Rounded pill shape
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          text,
          style: Styles.buttonTextStyle.copyWith(fontSize: 14, color: Colors.white),
        ),
        if (isRating) ...[
          const SizedBox(width: 4),
          const Icon(Icons.star, color: Colors.yellow, size: 14),
        ],
      ],
    ),
  );
}