import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

import '../../styles/styles.dart';
import '../../styles/custom_style.dart';

class Wallet extends StatefulWidget with CustomStyle {
  Wallet({super.key});

  @override
  WalletState createState() => WalletState();
}

class WalletState extends State<Wallet> {
  int _currentAmount = 0;
  bool isLoading = false;
  Map<String, int> requests = {};

  @override
  void initState() {
    super.initState();
    _getAmountFromPreferences(); // Load stored amount first
    _loadAmount(); // Fetch the latest amount from Firestore
    _loadRequests(); // Load requests from Firestore
  }

  Future<void> _loadAmount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String userId = prefs.getString('userId')??"";
      String userType = prefs.getString('userType')??"";
      final homeboundId = prefs.getString("homeboundId")??"";
      if(homeboundId != "") {
        userId = homeboundId;
        userType = "homebound";
      }

        final docSnapshot = await FirebaseFirestore.instance
            .collection(userType)
            .doc(userId)
            .get();

        if (docSnapshot.exists) {
          final data = docSnapshot.data();
          if (data != null && data['amount'] is String) {
            // Safely parse amount string like "33.00" -> 33
            final parsedAmount = double.tryParse(data['amount'])?.toInt() ?? 0;

            if (!mounted) return;

            setState(() {
              _currentAmount = parsedAmount;
            });

            await _saveAmountToPreferences(parsedAmount);
          } else {
            throw Exception('Invalid data format in Firestore document.');
          }
        } else {
          throw Exception('Firestore document does not exist.');
        }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load wallet amount: $e')),
        );
      }
    }
  }

  Future<void> _saveAmountToPreferences(int amount) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('currentAmount', amount); // Store as int
  }

  Future<void> _getAmountFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    // Get the same int you stored
    final storedAmount = prefs.getInt('currentAmount') ?? 0;

    setState(() {
      _currentAmount = storedAmount;
    });
  }

  Future<void> _loadRequests() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String userId = prefs.getString('userId')??"";
      String userType = prefs.getString('userType')??"";
      final homeboundId = prefs.getString("homeboundId")??"";
      if(homeboundId != "") {
        userId = homeboundId;
        userType = "homebound";
      }

        final docSnapshot = await FirebaseFirestore.instance
            .collection(userType)
            .doc(userId)
            .get();

        if (docSnapshot.exists) {
          final data = docSnapshot.data();
          if (data != null && data['requests'] is List) {
            final List<dynamic> requestsList = data['requests'];

            if (!mounted) return;

            setState(() {
              requests = {
                for (var request in requestsList)
                  if (request is Map<String, dynamic> &&
                      request['requestType'] != null &&
                      request['amount'] != null)
                    request['requestType']:
                        double.tryParse(request['amount'].toString())
                                ?.toInt() ??
                            0
              };
            });
          } else {
            throw Exception('Invalid data format in Firestore document.');
          }
        } else {
          throw Exception('Firestore document does not exist.');
        }

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You have not completed any requests yet or an error occured')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height,
            decoration: const BoxDecoration(color: Styles.darkPurple),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.33,
                    child: Stack(
                      children: [
                        const Align(
                          alignment: Alignment.center,
                          child:
                              Text("My Transactions", style: Styles.titleStyle),
                        ),
                        Positioned(
                          bottom: 20,
                          left: 20,
                          child: BackButton(
                            color: const Color.fromARGB(255, 255, 255, 255),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 100,
                        child: PageView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            _buildCard(
                              "Total Spent : ₹ $_currentAmount.00",
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 50),
                      Text(
                        "Total Spent by Request Type",
                        style: Styles.buttonTextStyle.copyWith(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: requests.length,
                        itemBuilder: (context, index) {
                          final entry = requests.entries.elementAt(index);
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 25, vertical: 10),
                            color: Styles.lightPurple,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 15,
                                vertical: 10,
                              ),
                              title: Text(
                                entry.key,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: Styles.mildPurple,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '₹ ${entry.value}.00',
                                  style: const TextStyle(
                                    color: Color.fromARGB(255, 255, 255, 255),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isLoading)
            Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              color:
                  const Color.fromRGBO(0, 0, 0, 0.5),
 // Semi-transparent background
              child: const Center(
                child: CircularProgressIndicator(
                  color: Colors.white, // Customize the indicator color
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCard(String balance) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30),
      decoration: BoxDecoration(
        color: Styles.lightPurple,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5))
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              balance,
              style: Styles.titleStyle.copyWith(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
