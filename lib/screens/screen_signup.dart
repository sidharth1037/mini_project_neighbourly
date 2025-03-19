import 'package:flutter/material.dart';
import 'package:mini_ui/screens/auth_service.dart';
import 'package:mini_ui/styles/styles.dart';
import 'screen_login.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _auth = AuthService();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _aadharController = TextEditingController();

  String? _selectedGender;
  String? _selectedRole; // Default role
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _dobController.dispose();
    _addressController.dispose();
    _aadharController.dispose();
    super.dispose();
  }

  void _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Passwords do not match"),
          ),
        );
        setState(() => _isLoading = false);
        return;
      }

      final userCredential = await _auth.createUserWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text,
      );

      final user = userCredential;

      if (user != null) {
        await FirebaseFirestore.instance.collection("users").doc(user.uid).set({
          "uid": user.uid,
          "name": _nameController.text.trim(),
          "email": _emailController.text.trim(),
          "gender": _selectedGender,
          "dob": _dobController.text.trim(),
          "address": _addressController.text.trim(),
          "aadhar": _aadharController.text.trim(),
          "role": _selectedRole,
          "createdAt": FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Account created successfully!")),
        );

        _goToLogin();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }

    setState(() => _isLoading = false);
  }

  void _goToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LogInScreen()),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        _dobController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Styles.darkPurple,
      body: Center(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(20.0),
          children: [
            const SizedBox(height: 80),
            const Text(
              "NEIGHBOURLY",
              style: Styles.titleStyle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 70),
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2), // Light Purple Background
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const Text(
                    "Sign Up Form",
                    style: Styles.nameStyle,
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    "Please enter your details!",
                    style: Styles.bodyStyle,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildTextField(
                            controller: _nameController, label: 'Name'),
                        _buildTextField(
                          controller: _dobController,
                          label: 'Date of Birth',
                          readOnly: true,
                          icon: Icons.calendar_today,
                          onTap: () => _selectDate(context),
                        ),
                        _buildDropdownField(),
                        _buildTextField(
                          controller: _emailController,
                          label: 'Email',
                          keyboardType: TextInputType.emailAddress,
                        ),
                        _buildTextField(
                            controller: _addressController, label: 'Address'),
                        _buildTextField(
                          controller: _aadharController,
                          label: 'Aadhar Number',
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter
                                .digitsOnly, // Ensures only numeric input
                            LengthLimitingTextInputFormatter(
                                12), // Limits input to 12 digits
                          ],
                        ),
                        _buildPasswordField(),
                        _buildTextField(
                          controller: _confirmPasswordController,
                          label: 'Confirm Password',
                          obscureText: true,
                        ),
                        _buildRoleDropdownField(), // New Role Selection
                        const SizedBox(height: 20),
                        _isLoading
                            ? const CircularProgressIndicator(
                                color: Styles.white)
                            : ElevatedButton(
                                onPressed: _signUp,
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 12.0, horizontal: 24.0),
                                  child: Text('Sign Up'),
                                ),
                              ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Already have an account?",
                                style: TextStyle(
                                    color: Styles.white, fontSize: 16)),
                            TextButton(
                              onPressed: _goToLogin,
                              child: const Text(
                                "Sign in",
                                style:
                                    TextStyle(color: Colors.blue, fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      ],
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    List<TextInputFormatter>? inputFormatters,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    bool obscureText = false,
    IconData? icon,
    void Function()? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        readOnly: readOnly,
        onTap: onTap,
        style: const TextStyle(color: Styles.white), // Text color white
        cursorColor: Styles.white, // Cursor color white
        decoration: Styles.inputDecoration.copyWith(
          labelText: label,
          labelStyle: const TextStyle(color: Styles.white), // Label text white
          prefixIcon: Icon(icon ?? Icons.edit, color: Styles.white),
        ),
        inputFormatters: inputFormatters,
      ),
    );
  }

  Widget _buildPasswordField() {
    return _buildTextField(
      controller: _passwordController,
      label: 'Password',
      obscureText: !_isPasswordVisible,
      icon: Icons.lock,
    );
  }

  Widget _buildDropdownField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: null,
        dropdownColor: Styles.lightPurple,
        items: ["Male", "Female", "Other"].map((gender) {
          return DropdownMenuItem(
            value: gender,
            child: Text(gender, style: const TextStyle(color: Styles.white)),
          );
        }).toList(),
        onChanged: (value) => setState(() => _selectedGender = value!),
        decoration: Styles.inputDecoration.copyWith(
          labelText: "Gender",
          labelStyle: const TextStyle(color: Styles.white),
          prefixIcon: const Icon(Icons.person, color: Styles.white),
        ),
      ),
    );
  }

  Widget _buildRoleDropdownField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        value: null,
        dropdownColor: Styles.lightPurple,
        items:
            ["Homebound", "Volunteer", "Guardian", "Organization"].map((role) {
          return DropdownMenuItem(
            value: role,
            child: Text(role, style: const TextStyle(color: Styles.white)),
          );
        }).toList(),
        onChanged: (value) => setState(() => _selectedRole = value!),
        decoration: Styles.inputDecoration.copyWith(
          labelText: "Select Role",
          labelStyle: const TextStyle(color: Styles.white),
          prefixIcon: const Icon(Icons.people, color: Styles.white),
        ),
      ),
    );
  }
}
