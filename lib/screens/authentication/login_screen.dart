import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.blue,  // Blue border color
                    width: 2,            // Border width
                  ),
                ),
                child: CircleAvatar(
                  radius: 107,
                  backgroundColor: Colors.white,
                  // backgroundColor: Colors.green,
                  child: ClipOval(
                    child: Image.asset(
                      width: 210,
                      'assets/logo.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 25),
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  labelStyle: GoogleFonts.exo2(),
                  labelText: 'Email or Phone Number',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.email, color: Colors.blue,),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelStyle: GoogleFonts.exo2(),
                  labelText: 'Password',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock, color: Colors.blue,),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/forgot-password');
                  },
                  child: Text('Forgot Password?', style: GoogleFonts.exo2()),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                    setState(() {
                      isLoading = true; // Start loading
                    });

                    final userData = await loginUser(
                      email: emailController.text,
                      password: passwordController.text,
                    );

                    setState(() {
                      isLoading = false; // Stop loading
                    });

                    if (userData != null) {
                      String role = userData['role'];
                      if (role == 'user') {
                        Navigator.pushReplacementNamed(context, '/home');
                      } else if (role == 'host') {
                        Navigator.pushReplacementNamed(context, '/host-home');
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Login failed. Please try again.'),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  )
                      : Text(
                    'Login',
                    style: GoogleFonts.exo2(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text('OR'),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 20),
              Text('Sign in with',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.exo2(fontSize: 16, color: Colors.grey)),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: Image.asset('assets/google.png', height: 40),
                  ),
                  const SizedBox(width: 20),
                  IconButton(
                    onPressed: () {},
                    icon: Image.asset('assets/facebook.png', height: 40),
                  ),
                  const SizedBox(width: 20),
                  IconButton(
                    onPressed: () {},
                    icon: Image.asset('assets/icloud.png', height: 40),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Don't have an account?", style: GoogleFonts.exo2()),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context,
                          '/register'); // Navigate to the registration screen
                    },
                    child: Text('Sign Up', style: GoogleFonts.exo2()),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Dummy login function for demonstration
Future<Map<String, dynamic>?> loginUser({required String email, required String password}) async {
  // Simulate fetching user details from a backend
  await Future.delayed(const Duration(seconds: 2));

  // Dummy users with email, password, and role
  final List<Map<String, dynamic>> users = [
    {'email': 'user', 'password': '123', 'role': 'user'},
    {'email': 'host', 'password': '123', 'role': 'host'},
  ];

  // Check if the entered credentials match any user
  for (var user in users) {
    if (user['email'] == email && user['password'] == password) {
      return {'role': user['role']}; // Return the role if credentials match
    }
  }

  return null; // Return null for invalid credentials
}

