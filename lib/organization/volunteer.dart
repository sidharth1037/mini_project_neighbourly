import 'package:flutter/material.dart';
import '../../../styles/styles.dart';

class VolunteerDetailsPage extends StatelessWidget {
  const VolunteerDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Volunteer details stored as a JSON-like Map
    final Map<String, dynamic> volunteerDetails = {
      "name": "Blesson K Tomy",
      "age": "22",
      "gender": "Male",
      "rating": "4.8",
      "neighbourhood": "Pala",
      "requestsCompleted": "32",
      "servicesProvided": [
        "Grocery Pickup",
        "Good Morning",
        "Gardening",
        "Medicine Delivery",
        "Driving",
        "IEEE President"
        ],
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
                  const Align(
                    alignment: Alignment.center,
                    child: Text("Volunteer Details", style: Styles.titleStyle, textAlign: TextAlign.center,),
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
                  // Name
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Styles.mildPurple,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            // Profile Picture
                            Container(
                              width: 60,
                              height: 60,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Styles.white,
                              ),
                              child: const Icon(Icons.person, size: 40, color: Colors.grey),
                            ),
                            const SizedBox(width: 16),

                            // Name
                            const Text("Blesson K Tomy", style: Styles.nameStyle),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Age
                  buildInfoContainer("Age:", value: volunteerDetails["age"]),

                  const SizedBox(height: 10),

                  // Gender
                  buildInfoContainer("Gender:", value: volunteerDetails["gender"]),

                  const SizedBox(height: 10),

                  // Rating
                  buildInfoContainer("Rating:", value: volunteerDetails["rating"], isRating: true),

                  const SizedBox(height: 10),

                  // Neighbourhood
                  buildInfoContainer("Neighbourhood:", value: volunteerDetails["neighbourhood"]),

                  const SizedBox(height: 10),

                  // Requests Completed
                  buildInfoContainer("Requests Completed:", value: volunteerDetails["requestsCompleted"]),

                  const SizedBox(height: 10),

                  // Services Provided
                  buildInfoContainer("Services Provided:", services: volunteerDetails["servicesProvided"]),

                  const SizedBox(height: 14),

                  // Cancel Request Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: TextButton(
                      onPressed: () {
                        showConfirmationDialog(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[500],
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
                            "Remove Volunteer",
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
  Widget buildInfoContainer(String title, {String value = '', bool isRating = false, List<String>? services}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      decoration: BoxDecoration(
        color: Styles.mildPurple,
        borderRadius: BorderRadius.circular(20),
      ),
      child: services == null
          ? Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
          "$title ",
          style: Styles.bodyStyle,
            ),
            const SizedBox(height: 5),
            if (isRating)
          Row(
            children: [
              Text(
            value,
            style: Styles.bodyStyle,
              ),
              const SizedBox(width: 5),
              Icon(
            Icons.star,
            color: Colors.yellow[500],
            size: 20,
              ),
            ],
          )
            else
          Text(
            value,
            style: Styles.bodyStyle,
          ),
          ],
        )
          : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
          "$title ",
          style: Styles.bodyStyle,
            ),
            const SizedBox(height: 5),
            Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: services.map((service) => Text("• $service", style: Styles.bodyStyle)).toList(),
            ),
          ],
        ),
    );
  }

  // Function to build name container with bold text
  Widget buildNameContainer(String name) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Styles.mildPurple,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        "Name: $name",
        style: Styles.bodyStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 20),
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
          "Confirm Removal",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        content: const Text(
          "Are you sure you want to remove this volunteer from the list?",
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
                    "Do Not Remove",
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
                    backgroundColor: Colors.red[500],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    "Remove Volunteer",
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
