
import 'details.dart';
import 'package:flutter/material.dart';

import '../../styles/styles.dart'; 
import '../../styles/custom_style.dart';


class Wallet extends StatelessWidget with CustomStyle {
  Wallet({super.key});

  @override
  Widget build(BuildContext context) {
      return Scaffold(
        body: DecoratedBox(
          decoration: BoxDecoration(color: Styles.darkPurple),
          child: Column(
            children: [
              SizedBox(
              height: MediaQuery.of(context).size.height * 0.33,
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Text("E-Wallet", style: Styles.titleStyle),
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
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 200,
                    child: PageView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildCard("€ 6,815.53", "7995"),
                        _buildCard("€ 3,420.00", "1234"),
                        _buildCard("€ 1,250.75", "5678"),
                      ],
                    ),
                  ),
                  SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                     _buildActionButton(Icons.add, "Top up", context, CardListScreen()),
                      _buildActionButton(Icons.sync_alt, "Exchange", context, CardListScreen()),
                      _buildActionButton(Icons.info, "Details", context, CardListScreen()),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    } 
  }

  Widget _buildCard(String balance, String lastDigits) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 30),
      decoration: BoxDecoration(
        color: Styles.lightPurple,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5))],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              balance,
              style: Styles.buttonTextStyle.copyWith(color: Colors.white, fontSize: 24),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Text(
              "**** $lastDigits",
              style: Styles.buttonTextStyle.copyWith(color: Colors.white, fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }

   Widget _buildActionButton(IconData icon, String label, BuildContext context, Widget page) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: Styles.lightPurple,
            radius: 30,
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          SizedBox(height: 10),
          Text(label, style: Styles.buttonTextStyle.copyWith(color: Colors.white, fontSize: 14)),
        ],
      ),
    );
  }

