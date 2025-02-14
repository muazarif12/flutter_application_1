import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 50,),
            Text(
              'Enter your email address or phone number to reset your password.',
              style: GoogleFonts.exo2(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Email/Phone Input
            TextFormField(
              decoration: InputDecoration(
                labelStyle: GoogleFonts.exo2(),
                labelText: 'Email or Phone Number',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),

            // Reset Password Button
            ElevatedButton(
              onPressed: () {
                // Handle password reset logic
                // Show a success message or navigate to a confirmation screen
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'Password reset instructions sent to your email/phone.',
                      style: GoogleFonts.exo2(),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                backgroundColor: Colors.green, // Button color
              ),
              child: Text(
                'Reset Password',
                style: GoogleFonts.exo2(fontSize: 18, color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),

            // Back to Login Link
            TextButton(
              onPressed: () {
                // Navigate back to Login Screen
                Navigator.pop(context);
              },
              child: Text('Back to Login', style: GoogleFonts.exo2(),),
            ),
          ],
        ),
      ),
    );
  }
}