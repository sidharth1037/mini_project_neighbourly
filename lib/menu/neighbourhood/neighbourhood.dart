import '../menu.dart';
import 'create.dart';
import 'join.dart';
import 'package:flutter/material.dart';
import '../../styles/styles.dart'; 
import '../../styles/custom_style.dart';

bool joined = false;
List<Map<String, dynamic>> contents = [
  {"icon": Icons.group_add, "label": "Join", "Navigation": JoinNeighbourhood()},
  {"icon": Icons.add_home, "label": "Create", "Navigation": CreateNeighbourhood()}
];

class Neighbourhood extends StatelessWidget with CustomStyle {
  Neighbourhood({super.key});

  @override
  Widget build(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;
    double deviceHeight = MediaQuery.of(context).size.height;

    if (joined) {
      return Scaffold(
        body: DecoratedBox(
          decoration: BoxDecoration(color: Styles.darkPurple),
          child: Column(
            children: [
              Container(
                height: deviceHeight * 0.33,
                alignment: Alignment.center,
                child: Stack(
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Text("Your Neighbourhood", style: Styles.titleStyle, textAlign: TextAlign.center),
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
              Expanded(
                flex: 2,
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    RequestBox(
                      title: "Green Park",
                      homebound: "5",
                      volunteer: "10",
                      status: "Active",
                      areacode: "112345",
                    ),
                  ],
                ),
              ),
              // Button in the bottom 1/3rd of the screen
              SizedBox(height: deviceHeight * 0.1), // Adds space before the button
              Center(
                child: SizedBox(
                  width: deviceWidth * 0.5, // Reduce width to half of the device width
                  height: deviceHeight * 0.07, // Increase button height
                  child: ElevatedButton(
                    onPressed: () {
                      // Leave neighbourhood action
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Styles.lightPurple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      "Leave Neighbourhood",
                      textAlign: TextAlign.center,
                      style: Styles.buttonTextStyle.copyWith(color: Colors.white),
                    ),
                  ),
                ),
              ),
              SizedBox(height: deviceHeight * 0.05), // Adds space below the button
            ],
          ),
        ),
      );
    } else {
      return Home(content: contents, title: "Join or Create\nNeighbourhood",backbutton: true,);
  }
}

 
}

class RequestBox extends StatelessWidget {
  final String title;
  final String homebound;
  final String volunteer;
  final String status;
  final String areacode; // Callback for button press

  const RequestBox({
    super.key,
    required this.title,
    required this.homebound,
    required this.volunteer,
    required this.status,
    required this.areacode, // Allows passing a function when tapped
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.only(bottom: 4), // Space between cards
        decoration: Styles.boxDecoration, // Use the same decoration as Profile Page
        padding: const EdgeInsets.all(14), // Internal padding
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Left side: Request details
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.all(10),
                  child: 
                    Text(title, style: Styles.nameStyle,),
                  
                ),
                const SizedBox(height: 8),
                // Time and Date Row
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPill("homebound: $homebound"),
                    const SizedBox(width: 5),
                    _buildPill("volunteer: $volunteer"),
                    const SizedBox(width: 5),
                    _buildPill("Zip code: $areacode"),
                    const SizedBox(width: 5),
                    _buildPill(status, isStatus: true),
                  ],
                ),
              ],
            ),
            // Right side: Forward arrow icon
            // Padding(
            //   padding: EdgeInsets.fromLTRB(0, 0, 0,0),
            //   child: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 20)),
          ],
        ),
    );
  }

  // Helper function to create pill-shaped containers
  Widget _buildPill(String text, {bool isStatus = false}) {
    return Center(
      child: 
        Container(
      padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 8),
      decoration: BoxDecoration(
        color:  Styles.lightPurple, // Dark grey for time and date pills
        borderRadius: BorderRadius.circular(20), // Rounded pill shape
      ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: 
              Text(
        text,
                textAlign: TextAlign.left,
        style: Styles.buttonTextStyle.copyWith(fontSize: 14, color: Colors.white),
      ),
            
          ),
        ),
      
    );
  }
}


