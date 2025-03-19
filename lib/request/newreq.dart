import 'package:flutter/material.dart';
import '../styles/styles.dart';

class NewRequestPage extends StatefulWidget {
  const NewRequestPage({super.key});

  @override
  State<NewRequestPage> createState() => _NewRequestPageState();
}

class _NewRequestPageState extends State<NewRequestPage> {
  final TextEditingController descriptionController = TextEditingController();
  String selectedRequest = "Buy Groceries";
  String requestAt = "Neighbourhood";
  String selectedGender = "Male";
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  // Function to pick a date
  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  // Function to pick a time
  Future<void> pickTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        selectedTime = picked;
      });
    }
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
                    child: Text("New Request", style: Styles.titleStyle),
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
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 6),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Styles.mildPurple,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dropdown
                    Text("Request Type :", style: Styles.bodyStyle),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Styles.lightPurple,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedRequest,
                          dropdownColor: Styles.lightPurple,
                          style: Styles.bodyStyle,
                          isExpanded: true,
                          items: ["Buy Groceries", "Drive to a Place", "Gardening"]
                              .map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedRequest = newValue!;
                            });
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // Description TextField
                    Text("Description :", style: Styles.bodyStyle),
                    const SizedBox(height: 8),
                    TextField(
                      controller: descriptionController,
                      maxLines: null,
                      style: Styles.bodyStyle,
                      cursorColor: Colors.white,
                      decoration: InputDecoration(
                      filled: true,
                      hintText: "Describe what you need...",
                      hintStyle: const TextStyle(color: Styles.offWhite),
                      fillColor: Styles.lightPurple,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // Date Picker
                    Text("Select Date :", style: Styles.bodyStyle),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => _pickDate(context),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Styles.lightPurple,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          selectedDate == null
                              ? "Pick a Date"
                              : "${selectedDate!.day.toString().padLeft(2, '0')}.${selectedDate!.month.toString().padLeft(2, '0')}.${selectedDate!.year}",
                          style: Styles.bodyStyle,
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // Time Picker
                    Text("Select Time :", style: Styles.bodyStyle),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => pickTime(context),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Styles.lightPurple,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          selectedTime == null
                              ? "Pick a Time"
                              : selectedTime!.format(context),
                          style: Styles.bodyStyle,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text("Volunteer Gender :", style: Styles.bodyStyle),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Styles.lightPurple,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                        GestureDetector(
                          onTap: () {
                          setState(() {
                            selectedGender = "Male";
                          });
                          },
                          child: Row(
                          children: [
                            Radio<String>(
                            value: "Male",
                            groupValue: selectedGender,
                            onChanged: (String? value) {
                              setState(() {
                              selectedGender = value!;
                              });
                            },
                            activeColor: Colors.white,
                            fillColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
                              return Colors.white;
                            }),
                            ),
                            Text("Male", style: Styles.bodyStyle),
                          ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                          setState(() {
                            selectedGender = "Female";
                          });
                          },
                          child: Row(
                          children: [
                            Radio<String>(
                            value: "Female",
                            groupValue: selectedGender,
                            onChanged: (String? value) {
                              setState(() {
                              selectedGender = value!;
                              });
                            },
                            activeColor: Colors.white,
                            fillColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
                              return Colors.white;
                            }),
                            ),
                            Text("Female", style: Styles.bodyStyle),
                          ],
                          ),
                        ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 15),
                    Text("Send Request To :", style: Styles.bodyStyle),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Styles.lightPurple,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: requestAt,
                          dropdownColor: Styles.lightPurple,
                          style: Styles.bodyStyle,
                          isExpanded: true,
                          items: ["Neighbourhood", "Priority List", "Both Neighbourhood & Priority List"]
                              .map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              requestAt = newValue!;
                            });
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),
                    // Amount Input
                    Text("Amount :", style: Styles.bodyStyle),
                    const SizedBox(height: 8),
                    TextField(
                      keyboardType: TextInputType.number,
                      style: Styles.bodyStyle,
                      cursorColor: Colors.white,
                      decoration: InputDecoration(
                        filled: true,
                        hintText: "Enter the amount...",
                        hintStyle: const TextStyle(color: Styles.offWhite),
                        fillColor: Styles.lightPurple,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: TextButton(
                  onPressed: () {
                    showConfirmationDialog(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[500],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: const BorderSide(color: Styles.offWhite, width: 2),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle, color: Colors.white, size: 26),
                      const SizedBox(width: 8),
                      const Text(
                        "Submit Request",
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
            ),
          ],
        ),
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
          "Confirm Submission",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        content: const Text(
          "Are you sure you want to submit this request?",
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
                    "Submit Request",
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
