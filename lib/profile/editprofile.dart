import 'package:flutter/material.dart';
import '../styles/styles.dart';
import 'package:flutter/services.dart';

final Map<String, dynamic> userProfile = {
  'name': 'John Doe',
  'email': 'john.doe@example.com',
  'phone': '1234567890',
  'address': '123 Main St, Springfield, USA'
};

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  EditProfilePageState createState() => EditProfilePageState();
}

class EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = userProfile['name'];
    _emailController.text = userProfile['email'];
    _phoneController.text = userProfile['phone'];
    _addressController.text = userProfile['address'];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
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
                  Align(
                    alignment: Alignment.center,
                    child: Text("Edit Profile", style: Styles.titleStyle),
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
            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Styles.mildPurple,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text("Name :", style: TextStyle(color: Colors.white, fontSize: 16),),
                  ),
                  SizedBox(height: 10),
                  TextField(
                  controller: _nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: Styles.inputDecoration,
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text("Email :", style: TextStyle(color: Colors.white, fontSize: 16),),
                  ),
                  SizedBox(height: 10),
                  TextField(
                  controller: _emailController,
                  style: const TextStyle(color: Colors.white),
                  decoration: Styles.inputDecoration,
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text("Phone :", style: TextStyle(color: Colors.white, fontSize: 16),),
                  ),
                  SizedBox(height: 10),
                    TextField(
                    controller: _phoneController,
                    style: const TextStyle(color: Colors.white),
                    decoration: Styles.inputDecoration,
                    keyboardType: TextInputType.phone,
                    inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                    ],
                    ),
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text("Address :", style: TextStyle(color: Colors.white, fontSize: 16),),
                  ),
                  SizedBox(height: 10),
                  TextField(
                  controller: _addressController,
                  style: const TextStyle(color: Colors.white),
                  decoration: Styles.inputDecoration,
                  maxLines: null, // Allows the TextField to expand with content
                  ),
                  SizedBox(height: 30),
                  Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Styles.lightPurple,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: TextButton(
                    onPressed: () {
                      showConfirmationDialog(context);
                    },
                    child: Text('Save Changes', style: Styles.buttonTextStyle),
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
          "Confirm Changes",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        content: const Text(
          "Are you sure you want to apply the changes?",
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
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.green[500],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    "Apply Changes",
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