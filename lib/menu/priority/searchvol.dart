import 'dart:convert';
import 'package:mini_ui/styles/styles.dart';

import '../../styles/custom_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class SearchVolunteerPage extends StatelessWidget with CustomStyle {
  SearchVolunteerPage({super.key}) {
    loadJsonData();
  }

  final ValueNotifier<List<dynamic>> filteredItems = ValueNotifier([]);
  final TextEditingController searchController = TextEditingController();
  final ValueNotifier<List<dynamic>> allItems = ValueNotifier([]);

  void filterSearch(String query) {
    if (query.isNotEmpty) {
      filteredItems.value = allItems.value
          .where((item) => item['name'].toString().toLowerCase().contains(query.toLowerCase()))
          .toList();
    } else {
      filteredItems.value = [];
    }
  }

  Future<void> loadJsonData() async {
    try {
      String jsonString = await rootBundle.loadString('assets/data.json');
      allItems.value = json.decode(jsonString);
    } catch (e) {
      debugPrint("Error loading JSON data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;
    double deviceHeight = MediaQuery.of(context).size.height;
    return Container(
      color: Styles.darkPurple,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: DecoratedBox(
          decoration: BoxDecoration(color: Styles.darkPurple),
          child: Column(
            children: [
            Container(
                  height: deviceHeight / 3,
                  alignment: Alignment.center,
                  child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Text("Add new\nVolunteer", style: Styles.titleStyle, textAlign: TextAlign.center),
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
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 22),
                child: TextField(
                  controller: searchController,
                  style: const TextStyle(color: Colors.white),
                  onChanged: (value) {
                    if (allItems.value.isNotEmpty) {
                      filterSearch(value);
                    }
                  },
                  cursorColor: Colors.white,
                  decoration: InputDecoration(
                    hintText: "Enter volunteer name",
                    hintStyle: const TextStyle(color: Styles.offWhite),
                    prefixIcon: const Icon(Icons.search, color: Colors.white),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(color: Colors.white, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(color: Colors.white, width: 1),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: ValueListenableBuilder(
                  valueListenable: filteredItems,
                  builder: (context, List<dynamic> items, child) {
                    if (searchController.text.isEmpty) {
                      return Container(
                        alignment: Alignment.topCenter,
                        child: _buildPill("Enter name to search", deviceWidth, 50),
                      );
                    }
                    return items.isNotEmpty
                        ? ListView.builder(
                            itemCount: items.length,
                            itemBuilder: (context, index) => Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: _buildPill(items[index]['name'], deviceWidth, 50),
                            ),
                          )
                        : Container(
                            alignment: Alignment.topCenter,
                            child: _buildPill("No matching volunteer found", deviceWidth, 50),
                          );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPill(String text, double deviceWidth, double height) {
    return Container(
      height: height,
      width: deviceWidth-40,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Styles.lightPurple,
        borderRadius: BorderRadius.circular(20),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: buttonTextStyle.copyWith(fontSize: 18, color: Colors.white),
        textAlign: TextAlign.center,
      ),
    );
  }
}
