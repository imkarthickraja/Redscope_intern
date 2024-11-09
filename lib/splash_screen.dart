import 'package:flutter/material.dart';
import 'dart:async';

import 'package:test/home_screen.dart';  // To use Timer

// Import the HomePage screen to navigate to after splash screen


class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Start the timer to show the splash screen for 3 seconds
    _startSplashTimer();
  }

  void _startSplashTimer() {
    Timer(Duration(seconds: 3), () {
      // After 3 seconds, navigate to the HomePage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()), // Navigate to HomePage
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent, // Splash screen background color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Display logo (use your own logo or an image here)
            Image.asset('assests/logo.jpg', width: 150, height: 150),
            SizedBox(height: 20),
            Text(
              'Github repo & image listing app',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
