import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mini_ui/organization/volunteer.dart';
import 'package:mini_ui/request/rating.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../styles/styles.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class ReqDetailsPage extends StatefulWidget {
  final String requestId;

  const ReqDetailsPage({super.key, required this.requestId});

  @override
  State<ReqDetailsPage> createState() => _ReqDetailsPageState();
}

class _ReqDetailsPageState extends State<ReqDetailsPage> {
  Map<String, dynamic>? request;
  String status = "";
  bool isLoading = false;
  Razorpay? _razorpay;

  @override
  void initState() {
    super.initState();
    fetchRequest();

    // Initialize Razorpay
    _razorpay = Razorpay();
    _razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay!.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay?.clear(); // Clear Razorpay instance
    super.dispose();
  }

  Future<void> fetchRequest() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('current_requests')
          .doc(widget.requestId)
          .get();

      if (doc.exists) {
        setState(() {
          request = doc.data() as Map<String, dynamic>;
          status = request!["status"];
        });
      } else {
        setState(() {
          request = {}; // Empty map if no request found
        });
      }
    } catch (e) {
      setState(() {
        request = null; // Null signifies an error
      });
    }
  }

  Future<void> moveToHistory() async {
    try {
      setState(() {
        isLoading = true;
      });

      DocumentReference requestDoc = FirebaseFirestore.instance
          .collection("current_requests")
          .doc(widget.requestId);

      DocumentSnapshot snapshot = await requestDoc.get();

      if (snapshot.exists) {
        Map<String, dynamic> requestData =
            snapshot.data() as Map<String, dynamic>;
        requestData["status"] = "Completed";

        await FirebaseFirestore.instance
            .collection("completed_requests")
            .doc(snapshot.id)
            .set(requestData);

        await requestDoc.delete();

        final prefs = await SharedPreferences.getInstance();
        String? userId = prefs.getString("userId");
        String homeboundId = prefs.getString("homeboundId")??"";

        if(homeboundId != "") {
          userId=homeboundId;
        }

        if (userId != null) {
          DocumentReference homeboundDoc =
              FirebaseFirestore.instance.collection("homebound").doc(userId);

          DocumentSnapshot homeboundSnapshot = await homeboundDoc.get();

          if (homeboundSnapshot.exists) {
            Map<String, dynamic> homeboundData =
                homeboundSnapshot.data() as Map<String, dynamic>;

            List<dynamic> requestsList = homeboundData["requests"] ?? [];

            bool requestTypeExists = false;
            for (var request in requestsList) {
              if (request["requestType"].toString().trim().toLowerCase() ==
                  requestData["requestType"].toString().trim().toLowerCase()) {
                double existingAmount =
                    double.tryParse(request["amount"].toString()) ?? 0.0;
                double newRequestAmount =
                    double.tryParse(requestData["amount"].toString()) ?? 0.0;
                request["amount"] =
                    (existingAmount + newRequestAmount).toStringAsFixed(2);
                requestTypeExists = true;
                break;
              }
            }

            if (!requestTypeExists) {
              requestsList.add({
                "requestType": requestData["requestType"].toString().trim(),
                "amount": double.tryParse(requestData["amount"].toString())
                        ?.toStringAsFixed(2) ??
                    "0.00",
              });
            }

            double currentTotal = 0.0;
            if (homeboundData["amount"] != null) {
              currentTotal =
                  double.tryParse(homeboundData["amount"].toString()) ?? 0.0;
            }
            double newAmount =
                double.tryParse(requestData["amount"].toString()) ?? 0.0;
            double updatedTotal = currentTotal + newAmount;

            await homeboundDoc.update({
              "requests": requestsList,
              "amount": updatedTotal.toStringAsFixed(2),
            });
          }
        }
        // Update the corresponding volunteer record in the volunteers collection,
        // provided the requestData contains a valid 'volunteerId'.
        if (requestData.containsKey('volunteerId') &&
            requestData['volunteerId'] != null) {
          String volunteerId = requestData['volunteerId'].toString();

          DocumentReference volunteerDoc = FirebaseFirestore.instance
              .collection("volunteers")
              .doc(volunteerId);
          DocumentSnapshot volunteerSnapshot = await volunteerDoc.get();

          if (volunteerSnapshot.exists) {
            Map<String, dynamic> volunteerData =
                volunteerSnapshot.data() as Map<String, dynamic>;

            List<dynamic> volunteerRequestsList =
                volunteerData["requests"] ?? [];

            bool volunteerRequestTypeExists = false;
            // Update volunteer's request type amount if present
            for (var request in volunteerRequestsList) {
              if (request["requestType"].toString().trim().toLowerCase() ==
                  requestData["requestType"].toString().trim().toLowerCase()) {
                double existingAmount =
                    double.tryParse(request["amount"].toString()) ?? 0.0;
                double newRequestAmount =
                    double.tryParse(requestData["amount"].toString()) ?? 0.0;
                request["amount"] =
                    (existingAmount + newRequestAmount).toStringAsFixed(2);
                volunteerRequestTypeExists = true;
                break;
              }
            }
            // If not present in volunteer's data, add a new request type entry
            if (!volunteerRequestTypeExists) {
              volunteerRequestsList.add({
                "requestType": requestData["requestType"].toString().trim(),
                "amount": double.tryParse(requestData["amount"].toString())
                        ?.toStringAsFixed(2) ??
                    "0.00",
              });
            }

            // Update total amount for volunteer document
            double volunteerCurrentTotal = 0.0;
            if (volunteerData["amount"] != null) {
              volunteerCurrentTotal =
                  double.tryParse(volunteerData["amount"].toString()) ?? 0.0;
            }
            double volunteerNewAmount =
                double.tryParse(requestData["amount"].toString()) ?? 0.0;
            double volunteerUpdatedTotal =
                volunteerCurrentTotal + volunteerNewAmount;

            await volunteerDoc.update({
              "requests": volunteerRequestsList,
              "amount": volunteerUpdatedTotal.toStringAsFixed(2),
            });
          }
        }
      }
    } catch (e) {
      debugPrint("Error moving request to history: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    setState(() {
      isLoading = true; // Start showing the loading indicator
    });

    try {
      // Get userId from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString("userId");

      if (userId != null) {
        DocumentReference requestDoc = FirebaseFirestore.instance
            .collection("current_requests")
            .doc(widget.requestId);

        // Update the request status
        await requestDoc.update({"status": "Pending Rating"});
      }

      if (mounted) {
        // After processing, show the success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              "Payment successful.",
              style: TextStyle(fontSize: 17),
            ),
            backgroundColor: Colors.green[400],
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        isLoading = false; // Stop showing the loading indicator
      });
      fetchRequest(); // Refresh the request data
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Payment failed: ${response.message}"),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("External Wallet selected: ${response.walletName}"),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _openRazorpay(String amount) async {
    try {
      // Fetch volunteer's name from Firestore
      String volunteerName = "Volunteer"; // Default name
      if (request != null && request!["volunteerId"] != null) {
        DocumentSnapshot volunteerSnapshot = await FirebaseFirestore.instance
            .collection("volunteers")
            .doc(request!["volunteerId"])
            .get();

        if (volunteerSnapshot.exists) {
          volunteerName = volunteerSnapshot.get("name") ?? "Volunteer";
        }
      }

      // Razorpay options
      var options = {
        'key': 'rzp_test_P0rbeHlMJetxCa', // Your Razorpay API key
        'amount': (double.parse(amount) * 100).toInt(), // Amount in paise
        'name': volunteerName, // Volunteer name as account name
        'description': 'Payment for request',
        'prefill': {
          'contact': '1234567890',
          'email': 'test@example.com',
        },
        'theme': {
          'color': '#3399cc',
        },
      };

      _razorpay!.open(options);
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  void showPaymentDialog(
      BuildContext context, String amount, String volunteerId) async {
    String volunteerName = "Volunteer"; // Default name
    try {
      DocumentSnapshot volunteerSnapshot = await FirebaseFirestore.instance
          .collection("volunteers")
          .doc(volunteerId)
          .get();

      if (volunteerSnapshot.exists) {
        volunteerName = volunteerSnapshot.get("name") ?? "Volunteer";
      }
    } catch (e) {
      debugPrint('Error fetching volunteer name: $e');
    }

    if (!context.mounted) return;

    showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: Styles.mildPurple,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              "Confirm Payment to $volunteerName",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            content: isLoading
                ? const SizedBox(
                    height: 80,
                    width: 40,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    ),
                  )
                : const Text(
                    "Are you sure you want to pay the specified amount?",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
            actions: isLoading
                ? []
                : [
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
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text(
                              "Cancel",
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
                            onPressed: () async {
                              setState(() {
                                isLoading = true;
                              });

                              await Future.delayed(
                                  const Duration(seconds: 1)); // Simulate delay

                              if (context.mounted) {
                                Navigator.pop(context); // Close the dialog
                                _openRazorpay(amount); // Call payment
                              }
                            },
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.green[400],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: Text(
                              "Pay ₹ $amount",
                              style: const TextStyle(
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
    },
  );
  }

  void showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        bool isLoading = false;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Styles.mildPurple,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text(
                "Confirm Cancellation",
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              content: isLoading
                  ? const SizedBox(
                      height: 80,
                      width: 40,
                      child: Center(
                        child: Column(
                          children: [
                            SizedBox(
                              height: 30,
                            ),
                            CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          ],
                        ),
                      ),
                    )
                  : const Text(
                      "Are you sure you want to cancel this request?",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
              actions: isLoading
                  ? []
                  : [
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
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
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
                              onPressed: () async {
                                setState(() => isLoading = true);

                                try {
                                  await FirebaseFirestore.instance
                                      .collection("current_requests")
                                      .doc(widget.requestId)
                                      .delete();

                                  if (context.mounted) {
                                    Navigator.of(context).pop();
                                  }

                                  if (context.mounted) {
                                    Navigator.of(context).pop();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Text(
                                          "Request cancelled successfully",
                                          style: TextStyle(fontSize: 17),
                                        ),
                                        backgroundColor: Colors.green[400],
                                        behavior: SnackBarBehavior.floating,
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 10),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(18),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 22, horizontal: 16),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  setState(() => isLoading = false);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("Error: ${e.toString()}"),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              },
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.red[400],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Styles.darkPurple,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.33,
              child: Stack(
                children: [
                  const Align(
                    alignment: Alignment.center,
                    child: Text("Request Details ", style: Styles.titleStyle),
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
            (request == null || isLoading)
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                : request!.isEmpty
                    ? const Center(
                        child: Text(
                          "Request not found",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildInfoContainer(request!["requestType"]),
                            const SizedBox(height: 10),
                            buildInfoContainer('Description:',
                                value: request!["description"]),
                            const SizedBox(height: 10),
                            buildInfoContainer("Date:",
                                value: request!["date"]),
                            const SizedBox(height: 10),
                            buildInfoContainer(
                              "Time:",
                              value: request!["date"] != null
                                  ? (DateTime.tryParse(request!["date"]) != null
                                      ? "${DateTime.parse(request!["date"]).day.toString().padLeft(2, '0')}-${DateTime.parse(request!["date"]).month.toString().padLeft(2, '0')}-${DateTime.parse(request!["date"]).year}"
                                      : "Invalid Date")
                                  : "N/A",
                            ),
                            const SizedBox(height: 10),
                            buildInfoContainer("Amount:",
                                value: "₹ ${request!["amount"]}"),
                            const SizedBox(height: 10),
                            buildInfoContainer("Volunteer Preference:",
                                value: request!["volunteerGender"]),
                            const SizedBox(height: 10),
                            buildInfoContainer("Send To:",
                                value: request!["requestAt"]),
                            const SizedBox(height: 10),
                            buildInfoContainer("Status: ",
                                value: request!["status"], isStatus: true),
                            const SizedBox(height: 10),
                            if (status == "Accepted" ||
                                status == "Pending Rating") ...{
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.fromLTRB(6, 4, 0, 4),
                                decoration: Styles.boxDecoration.copyWith(
                                  color: Styles.mildPurple,
                                ),
                                child: TextButton(
                                  onPressed: () async {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              VolunteerDetailsPage(
                                                  volunteerId:
                                                      request!["volunteerId"])),
                                    );
                                  },
                                  child: const Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("Volunteer Details",
                                          style: Styles.bodyStyle),
                                      Icon(Icons.arrow_forward_ios,
                                          size: 20, color: Colors.white),
                                    ],
                                  ),
                                ),
                              ),
                            },
                            const SizedBox(height: 26),
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: () {
                                if (status == "Waiting") {
                                  return TextButton(
                                    onPressed: () =>
                                        showConfirmationDialog(context),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red[400],
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        side: const BorderSide(
                                            color: Styles.offWhite, width: 2),
                                      ),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.cancel,
                                            color: Colors.white, size: 26),
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
                                  );
                                } else if (status == "Accepted") {
                                  return TextButton(
                                    onPressed: () => showPaymentDialog(
                                        context,
                                        request!["amount"],
                                        request!["volunteerId"]),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green[500],
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        side: const BorderSide(
                                            color: Styles.offWhite, width: 2),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.payment,
                                            color: Colors.white, size: 26),
                                        const SizedBox(width: 8),
                                        Text(
                                          "Pay ₹ ${request!["amount"]}",
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                } else if (status == "Pending Rating") {
                                  return TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              RateVolunteerPage(
                                                  volunteerId:
                                                      request!["volunteerId"]),
                                        ),
                                      ).then((_) async {
                                        await moveToHistory();
                                        if (context.mounted) {
                                          Navigator.pop(context);
                                        }
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue[300],
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        side: const BorderSide(
                                            color: Styles.offWhite, width: 2),
                                      ),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.star,
                                            color: Colors.white, size: 26),
                                        SizedBox(width: 8),
                                        Text(
                                          "Rate Volunteer",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                } else {
                                  return const SizedBox
                                      .shrink(); // Return an empty widget if no condition matches
                                }
                              }(),
                            ),
                          ],
                        ),
                      ),
          ],
        ),
      ),
    );
  }

  Widget buildInfoContainer(String title,
      {String value = '', bool isStatus = false}) {
    Color statusColor = Colors.yellow[500]!;
    String statusText = "";

    if (value == 'Accepted') {
      statusColor = const Color.fromARGB(255, 145, 255, 150);
      statusText = "Accepted by a volunteer";
    } else if (value == 'Waiting') {
      statusColor = Colors.yellow[500]!;
      statusText = "Waiting for volunteer";
    } else if (value == 'Pending Rating') {
      statusColor = Colors.blue[300]!;
      statusText = "Request & Payment completed";
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(15, 15, 20, 15),
      decoration: BoxDecoration(
        color: Styles.mildPurple,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isStatus
            ? "Status: $statusText"
            : (value.isEmpty ? title : "⦿ $title $value"),
        style: value.isEmpty
            ? Styles.bodyStyle
                .copyWith(fontSize: 20, fontWeight: FontWeight.bold)
            : isStatus
                ? Styles.bodyStyle
                    .copyWith(color: statusColor, fontWeight: FontWeight.bold)
                : Styles.bodyStyle,
      ),
    );
  }
}
