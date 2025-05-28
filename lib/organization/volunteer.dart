import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mini_ui/organization/reqhistory/reqhistory.dart';
import '../../../styles/styles.dart';

class VolunteerDetailsPage extends StatefulWidget {
  final String volunteerId; // Unique identifier for the volunteer
  const VolunteerDetailsPage({super.key, required this.volunteerId});

  @override
  State<VolunteerDetailsPage> createState() => _VolunteerDetailsPageState();
}

class _VolunteerDetailsPageState extends State<VolunteerDetailsPage> {
  // Volunteer details stored as a JSON-like Map
  bool isLoading = true; // Loading state for the page
  Map<String, dynamic> volunteerDetails={};
  String neighbourhoodName="";
  @override
  void initState() {
    super.initState();
    details(); // Fetch volunteer details when the page is initialized

  }
   Future<void> details() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance
          .collection('volunteers')
          .doc(widget.volunteerId)
          .get();
      volunteerDetails = querySnapshot.data() ?? {};
      DocumentSnapshot<Map<String, dynamic>> querySnapshot2 = await FirebaseFirestore.instance
      .collection('neighbourhood')
      .doc(volunteerDetails["neighbourhoodId"])
      .get();
  neighbourhoodName = querySnapshot2.data()?["name"]??"";
       setState(() {
      isLoading = false; // Update loading state
      // Update loading state
    });
    } catch (e) {
      debugPrint("Error fetching Firestore data: $e");
    } // Simulate network delay
   }

   

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
       return const Scaffold(
        backgroundColor: Styles.darkPurple,
        body: Center(
          child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white),),
        ),
      );
    }
    else{
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
                    child: Text(
                      "Volunteer Details",
                      style: Styles.titleStyle,
                      textAlign: TextAlign.center,
                    ),
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
                            Text(volunteerDetails["name"]??"", style: Styles.nameStyle),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Age
                  buildInfoContainer("Age:", value:(volunteerDetails["age"]?.toString()??"0")),

                  const SizedBox(height: 10),

                  // Gender
                  buildInfoContainer("Gender:", value: (volunteerDetails["gender"]?.toString()??"")),

                  const SizedBox(height: 10),

                  buildInfoContainer("Phone:", value: (volunteerDetails["phone"]?.toString()??"N/A")),

                  const SizedBox(height: 10),

                  // Rating
                  buildInfoContainer("Rating:", value: (volunteerDetails["rating"]?.toString()??"0"), isRating: true),

                  const SizedBox(height: 10),

                  // Neighbourhood
                  buildInfoContainer("Neighbourhood:", value: neighbourhoodName),

                  const SizedBox(height: 10),

                  // Requests Completed
                  buildInfoContainer("Requests Completed:", value: (volunteerDetails["ratingcount"]?.toString()??"0")),

                  const SizedBox(height: 10),

                  // Services Provided
                  buildInfoContainer("Services Provided:", services: (volunteerDetails["services"] ??[])),

                  const SizedBox(height: 14),

                  // Cancel Request Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OrgVolReqHistoryPage(volunteerId: volunteerDetails["uid"] ?? ""),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[500],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: const BorderSide(color: Styles.offWhite, width: 2),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.history, color: Colors.white, size: 26),
                          SizedBox(width: 8),
                          Text(
                            "Volunteer History",
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
    );}
  }

  // Function to build info container dynamically
  Widget buildInfoContainer(String title, {String value = '', bool isRating = false, List<dynamic>? services}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      decoration: BoxDecoration(
        color: Styles.mildPurple,
        borderRadius: BorderRadius.circular(20),
      ),
      child: services == null
            ? Wrap(
              crossAxisAlignment: WrapCrossAlignment.start,
              spacing: 10,
              runSpacing: 5,
              children: [
              Text(
                "$title ",
                style: Styles.bodyStyle,
              ),
              if (isRating)
                Row(
                mainAxisSize: MainAxisSize.min,
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
