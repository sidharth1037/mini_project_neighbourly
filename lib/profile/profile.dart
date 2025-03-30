import 'package:flutter/material.dart';
import 'package:mini_ui/screens/auth_service.dart';
import 'package:mini_ui/screens/screen_login.dart';
import 'editprofile.dart' as edit;
import '../styles/styles.dart';
// import 'roles.dart' as roles;
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  static final _auth = AuthService();
  String _userName = "Loading..."; // Default until data loads

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('userName') ?? "User"; // Fallback if not found
    });
  }

  static void _goToLogin(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LogInScreen()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Styles.darkPurple,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Title Section
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.33,
              child: const Stack(
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Text("Profile", style: Styles.titleStyle),
                  ),
                ],
              ),
            ),

            // Content Section
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                children: [
                  // Profile Section Box
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: Styles.boxDecoration,
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
                              child: const Icon(Icons.person,
                                  size: 40, color: Colors.grey),
                            ),
                            const SizedBox(width: 16),

                            // Display logged-in user's name dynamically
                            Text(_userName, style: Styles.nameStyle),
                          ],
                        ),

                        // Edit Button
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const edit.EditProfilePage()),
                            );
                          },
                          child: const Row(
                            children: [
                              Text("Edit", style: Styles.buttonTextStyle),
                              SizedBox(width: 4),
                              Icon(Icons.arrow_forward_ios,
                                  size: 16, color: Styles.white),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // const SizedBox(height: 20),

                  // Role Section Box (Unchanged)
                  // Container(
                  //   width: double.infinity,
                  //   padding: const EdgeInsets.all(16),
                  //   decoration: Styles.boxDecoration
                  //       .copyWith(color: Styles.lightPurple),
                  //   child: Row(
                  //     mainAxisAlignment: MainAxisAlignment.start,
                  //     children: [
                  //       const Text("Role : ",
                  //           style: TextStyle(
                  //               color: Styles.white,
                  //               fontSize: 20,
                  //               fontWeight: FontWeight.bold)),
                  //       const SizedBox(width: 4),
                  //       Expanded(
                  //         child: TextButton(
                  //           onPressed: () {
                  //             Navigator.push(
                  //               context,
                  //               MaterialPageRoute(
                  //                   builder: (context) =>
                  //                       const roles.ChangeRolePage()),
                  //             );
                  //           },
                  //           style: Styles.settingsButtonStyle,
                  //           child: const Row(
                  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //             children: [
                  //               Text("Volunteer",
                  //                   style: Styles.buttonTextStyle),
                  //               Icon(Icons.arrow_forward_ios,
                  //                   size: 16, color: Styles.white),
                  //             ],
                  //           ),
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),

                  const SizedBox(height: 20),

                  // Settings Section Box (Unchanged)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: Styles.boxDecoration,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Settings",
                            style: Styles.settingsTitleStyle),
                        const SizedBox(height: 10),
                        Column(
                          children: [
                            settingsButton("Notifications"),
                            const SizedBox(height: 10),
                            settingsButton("Privacy"),
                            const SizedBox(height: 10),
                            settingsButton("Account"),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Logout Section Box (Unchanged)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                    decoration: Styles.boxDecoration.copyWith(
                      color: Styles.lightPurple,
                    ),
                    child: TextButton(
                      onPressed: () async {
                        showConfirmationDialog(context);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Log Out",
                              style: Styles.buttonTextStyle
                                  .copyWith(fontSize: 16)),
                          Icon(Icons.logout, size: 26, color: Colors.red[400]),
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
}

// Function to Create Buttons (Unchanged)
Widget settingsButton(String text) {
  return TextButton(
    onPressed: () {},
    style: Styles.settingsButtonStyle,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(text, style: Styles.buttonTextStyle),
        const Icon(Icons.arrow_forward_ios, size: 16, color: Styles.white),
      ],
    ),
  );
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
          "Confirm Log Out",
          style: TextStyle(
              fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        content: const Text(
          "Are you sure you want to log out?",
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
                    await ProfilePageState._auth.signOut(context);
                    ProfilePageState._goToLogin(context);
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.red[400],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    "Log Out",
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
