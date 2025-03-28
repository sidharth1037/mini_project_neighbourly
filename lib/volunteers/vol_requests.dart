import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../styles/styles.dart';
import 'reqdetails.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// final config = Config();
String apiKey = '';  //config.apiKey;

const String geminiEndpoint = 'https://generativelanguage.googleapis.com/v1/models/gemini-1.5-pro:generateContent';

class VolRequestsPage extends StatefulWidget {
  const VolRequestsPage({super.key});

  @override
  RequestsPageState createState() => RequestsPageState();
}

class RequestsPageState extends State<VolRequestsPage> {
  List<Map<String, dynamic>> requests = []; // State variable to store fetched requests
    final ValueNotifier<List<dynamic>> filteredItems = ValueNotifier([]);
  bool isLoading = true; // State to track loading status
  String errorMessage = ""; // State to store error message

  @override
  void initState() {
    super.initState();
    fetchAllRequests(); // Call the function when the page is rendered
  }

  Future<void> fetchAllRequests() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) {
        setState(() {
          errorMessage = "User not logged in";
          isLoading = false;
        });
      }
      return;
    }

    // Check for internet connection
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      if (mounted) {
        setState(() {
          errorMessage = "No network connection. Try again later.";
          isLoading = false;
        });
      }
      return;
    }

    try {

      final prefs = await SharedPreferences.getInstance();
      String? neighbourhoodId =  prefs.getString('neighbourhoodId')??"";

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('current_requests')
          .where('neighbourhood', isEqualTo: neighbourhoodId)
          .get();

      // Include the document ID as an attribute for each document
      requests = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // Add the document ID
        return data;
      }).toList();

      if (mounted) {
        setState(() {
          // requests = querySnapshot.docs
          // .map((doc) => doc.data() as Map<String, dynamic>)
          // .toList();

          // Sort the requests by timestamp in descending order
          requests.sort((a, b) {
            final timestampA = a['timestamp'] ?? 0;
            final timestampB = b['timestamp'] ?? 0;
            return timestampB.compareTo(timestampA);
          });

          isLoading = false;
          errorMessage = requests.isEmpty ? "No current requests." : "success"; // Show message if no requests
        });
      }
    } catch (e) {
      debugPrint("Error while fetching data: $e");
      if (mounted) {
        setState(() {
          errorMessage = "An error occurred. Try again later.";
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  child: const Center(
                    child: Text("Requests", style: Styles.titleStyle),
                  ),
                ),

                // Request Cards Section
                Padding(
                  padding: const EdgeInsets.fromLTRB(6, 0, 6, 4),
                  child: isLoading
                        ? const Center(
                          child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ) // Show loading indicator
                        : errorMessage == "success"
                          ? Column(
                            children: requests.map((request) {
                            return RequestBox(request: request,);
                            }).toList(),
                          )
                            : Center(
                            child: Container(
                              margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                              width: double.infinity,
                              decoration: BoxDecoration(
                              color: Styles.mildPurple,
                              borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.all(16),
                              child: Text(
                              errorMessage,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                              ),
                            ),
                            ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RequestBox extends StatefulWidget {
  final Map<String, dynamic> request; // Request object containing all data
  final VoidCallback? onTap; // Callback for button press

  const RequestBox({
    super.key,
    required this.request,
    this.onTap, // Allows passing a function when tapped
  });

  @override
  State<RequestBox> createState() => _RequestBoxState();
}

class _RequestBoxState extends State<RequestBox> {
  Future<List<String>> extractKeywords(String inputText) async {
    WidgetsFlutterBinding.ensureInitialized();

    final Map<String, dynamic> payload = {
      "contents": [
        {
          "parts": [
            {
              "text":
                  " Example 1: I need help to buy groceries from the towncenter. The keywords here are: buy, groceries, towncenter. Example 2: I need help to fetch my pet from the vet. The keywords here are: fetch, pet, vet. Based on the given example, extract keywords from the following text and return them in a JSON list: \"$inputText\"",
            },
          ],
        },
      ],
    };

    final headers = {'Content-Type': 'application/json'};

    try {
      final response = await http.post(
        Uri.parse('$geminiEndpoint?key=$apiKey'),
        headers: headers,
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Extract keywords (assuming the API returns JSON like {"keywords": ["urgent", "hospital", "pain"]})
        List<String> keywords = List<String>.from(
          data["candidates"][0]["content"]["parts"][0]["text"].split(','),
        );
        return keywords.map((keyword) => keyword.trim()).toList();
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('Exception: $e');
      return [];
    }
  }

  @override
  void initState() {
    super.initState();
    final String textdesc = widget.request["description"] ?? "Cannot Fetch";
    extractKeywords(textdesc).then((keywords) {
      // DocumentReference userDocRef = FirebaseFirestore.instance.collection("current_requests").doc(widget.request["id"]);
      // // Update the user document by adding the field
      // userDocRef.set({'tags': keywords}, SetOptions(merge: true));
      print(widget.request["id"]);
      print("Extracted Keywords: $keywords");
    });
  }

  @override
  Widget build(BuildContext context) {
    final String title = widget.request["requestType"] ?? "Unknown";
    final String time = widget.request["time"] ?? "N/A";
    final String date = widget.request["date"] != null
        ? (DateTime.tryParse(widget.request["date"]) != null
            ? "${DateTime.parse(widget.request["date"]).day.toString().padLeft(2, '0')}-${DateTime.parse(widget.request["date"]).month.toString().padLeft(2, '0')}-${DateTime.parse(widget.request["date"]).year.toString().substring(2)}"
            : "Invalid Date")
        : "N/A";
    final String status = widget.request["status"] ?? "Unknown";
    final String amount = "${widget.request["amount"] ?? "0.00"} ₹";
    // final String textdesc = widget.request["description"] ?? "Cannot Fetch";

    return TextButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReqDetailsPage(request: widget.request), // Pass request to ReqDetailsPage
          ),
        );
      }, // Trigger the callback when tapped
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
                  const SizedBox(height: 8),
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
            const SizedBox(
              width: 30, // Set fixed width for arrow
              child: Icon(Icons.arrow_forward_ios, color: Colors.white, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}
