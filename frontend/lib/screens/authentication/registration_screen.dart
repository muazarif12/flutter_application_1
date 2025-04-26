import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final usernameController = TextEditingController();
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  void _showTermsAndConditionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Terms and Conditions'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  '1. Introduction',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  'Welcome to Arena Finder. By using our app, you agree to these terms and conditions. Please read them carefully.',
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(height: 20),
                Text(
                  '2. User Responsibilities',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  'You are responsible for maintaining the confidentiality of your account and password. You agree to notify us immediately of any unauthorized use of your account.',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
                Navigator.pushReplacementNamed(
                    context, '/home'); // Navigate to Home Screen
              },
              child: const Text('Agree'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    usernameController.dispose();
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.1),

            // Username Input
            TextFormField(
              controller: usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                labelStyle: TextStyle(fontFamily: 'Exo2'),
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person_outline, color: Colors.blue),
              ),
            ),
            const SizedBox(height: 20),

            // Full Name Input
            TextFormField(
              controller: fullNameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                labelStyle: TextStyle(fontFamily: 'Exo2'),
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person, color: Colors.blue),
              ),
            ),
            const SizedBox(height: 20),

            // Email Input
            TextFormField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(fontFamily: 'Exo2'),
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email, color: Colors.blue),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),

            // Phone Number Input
            TextFormField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                labelStyle: TextStyle(fontFamily: 'Exo2'),
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone, color: Colors.blue),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 20),

            // Password Input
            TextFormField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                labelStyle: TextStyle(fontFamily: 'Exo2'),
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock, color: Colors.blue),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),

            // Confirm Password Input
            TextFormField(
              controller: confirmPasswordController,
              decoration: const InputDecoration(
                labelText: 'Confirm Password',
                labelStyle: TextStyle(fontFamily: 'Exo2'),
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock, color: Colors.blue),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),

            // Sign Up Button
            ElevatedButton(
              onPressed: () async {
                // Password matching validation
                if (passwordController.text != confirmPasswordController.text) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Passwords do not match')),
                  );
                  return;
                }

                // Perform registration logic
                bool registrationSuccess = await registerUser(
                  username: usernameController.text,
                  email: emailController.text,
                  password: passwordController.text,
                  fullName: fullNameController.text,
                  phoneNumber: phoneController.text,
                );

                if (registrationSuccess) {
                  if (context.mounted) {
                    _showTermsAndConditionsDialog(context);
                  }
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Registration failed. Please try again.'),
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                backgroundColor: Colors.blue, // Changed from green to blue
              ),
              child: const Text(
                'Sign Up',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontFamily: 'Exo2',
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Already Have an Account? Login Prompt
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Already have an account?",
                    style: TextStyle(fontFamily: 'Exo2')),
                TextButton(
                  onPressed: () {
                    // Navigate back to Login Screen
                    Navigator.pop(context);
                  },
                  child:
                      const Text('Login', style: TextStyle(fontFamily: 'Exo2')),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Future<bool> registerUser({
  required String username,
  required String email,
  required String password,
  required String fullName,
  required String phoneNumber,
}) async {
  try {
    final response = await http.post(
      Uri.parse('http://10.0.2.2:5600/api/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
        'full_name': fullName,
        'phone_number': phoneNumber,
      }),
    );
    return response.statusCode == 201;
  } catch (e) {
    print('Registration error: $e');
    return false;
  }
}
