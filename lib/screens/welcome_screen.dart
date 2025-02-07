import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Background color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo or Title
            const Text(
              "Arena Finder",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.green, // Primary color
              ),
            ),
            const SizedBox(height: 20), // Spacing

            // Subtitle
            const Text(
              "Find the best sports arenas near you",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey, // Secondary color
              ),
            ),
            const SizedBox(height: 40), // Spacing

            // Get Started Button
            ElevatedButton(
              onPressed: () {
                // Navigate to the next screen (e.g., Registration/Login)
                Navigator.pushNamed(context, '/login');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, // Button color
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30), // Rounded corners
                ),
              ),
              child: const Text(
                "Get Started",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white, // Text color
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}