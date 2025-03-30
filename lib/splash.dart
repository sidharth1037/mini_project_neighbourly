import 'package:flutter/material.dart';
import 'package:mini_ui/navbar.dart';
import 'package:mini_ui/screens/screen_login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './organization/create.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500), // Fade-out duration
    );

    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    // Start fade-out after 0.5 seconds
    Future.delayed(const Duration(milliseconds: 500), () {
      _animationController.forward();
    });

    // Navigate to the appropriate screen with a smooth transition after fade-out
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _navigateToNextScreen();
      }
    });
  }

  Future<void> _navigateToNextScreen() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final userType = prefs.getString('userType') ?? '';
    String organizationName = '';

    if (userType == 'organization') {
      organizationName = prefs.getString('orgName') ?? 'none';
    }

    if (isLoggedIn) {
      if (userType == 'organization' && organizationName == 'none') {
      Navigator.of(context).pushReplacement(PageRouteBuilder(
        transitionDuration:
          const Duration(milliseconds: 500), // Smooth transition duration
        pageBuilder: (context, animation, secondaryAnimation) =>
          const CreateOrganization(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
        },
      ));
      } else {
      Navigator.of(context).pushReplacement(PageRouteBuilder(
        transitionDuration:
          const Duration(milliseconds: 500), // Smooth transition duration
        pageBuilder: (context, animation, secondaryAnimation) =>
          const MainScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
        },
      ));
      }
    } else {
      Navigator.of(context).pushReplacement(PageRouteBuilder(
      transitionDuration:
        const Duration(milliseconds: 500), // Smooth transition duration
      pageBuilder: (context, animation, secondaryAnimation) =>
        const LogInScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
        opacity: animation,
        child: child,
        );
      },
      ));
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _fadeAnimation.value,
      duration: const Duration(milliseconds: 500), // Fade-out duration
      child: const Scaffold(
        backgroundColor: const Color(0xFF2D1E59), // Dark Purple
        body: const Center(
          child: Text(
            "NEIGHBOURLY",
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
    );
  }
}
