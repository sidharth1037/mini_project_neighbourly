import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Required for SystemNavigator.pop()
import 'profile/profile.dart';
import 'request/requestpage.dart';
import 'styles/styles.dart';
import 'menu/menu.dart';
import 'menu/reqhistory/reqhistory.dart';
import 'menu/neighbourhood/neighbourhood.dart';
import 'menu/customer/support.dart';
import 'menu/wallet/wallet.dart';
import 'menu/priority/prioritylist.dart'; // Ensure this contains your colors

List<Map<String, dynamic>> contents=[
        {"icon":Icons.history,"label":"Request\nHistory","Navigation": ReqHistoryPage()},
        {"icon":Icons.location_city,"label":"Neighbourhood","Navigation":Neighbourhood()},
        {"icon":Icons.priority_high,"label":"Volunteer\nPriority List","Navigation":PriorityPage()},
        {"icon":Icons.checklist,"label":"To-Do List","Navigation":Placeholder()},
        {"icon":Icons.support_agent,"label":"Customer\nCare","Navigation":CustomerSupport()},
        {"icon":Icons.wallet,"label":"Wallet","Navigation":Wallet()}
  ];

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  int selectedIndex = 0; // Default to Home

  // Pages
  final List<Widget> pages = [
    RequestsPage(), // Requests Page (Replace with actual page later)
    Home(content: contents,title: "Menu",backbutton: false,), // Home Page (Replace with actual page later)
    ProfilePage(),
  ];

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Prevents default back behavior
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          SystemNavigator.pop(); // Close the app
        }
      },
      child: Scaffold(
        body: pages[selectedIndex], // Display selected page
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: selectedIndex,
          onTap: onItemTapped,
          backgroundColor: Styles.darkPurple, // Use dark purple
          selectedItemColor: Colors.white, // Highlight selected item
          unselectedItemColor: Colors.grey.shade400, // Dim unselected items
          type: BottomNavigationBarType.fixed, // Ensures all labels are shown
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Requests'),
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Menu'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}
