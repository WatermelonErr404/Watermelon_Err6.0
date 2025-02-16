// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:isl_application/screens/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback toggleTheme;

  const SplashScreen({super.key, required this.toggleTheme});
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Simulate a delay for the splash screen, then navigate.
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => OnboardingScreen(
            toggleTheme: widget.toggleTheme,
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Image.asset(
            "assets/images/splash.png", // Ensure this path is correct.
            fit: BoxFit.fitWidth,
          ),
          // Overlay with app logo and text
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Image.asset(
              //   "assets/images/app_logo.png", // Ensure this path is correct.
              //   width: 150,
              //   height: 150,
              // ),
              const SizedBox(height: 100),
              Text(
                "SIGNLIFY",
                style: Theme.of(context)
                    .textTheme
                    .displayLarge
                    ?.copyWith(fontSize: 40, fontWeight: FontWeight.bold),
              ),
            ],
          )
        ],
      ),
    );
  }
}
