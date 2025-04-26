import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

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
                    color: Colors.blue, // Blue border color
                    width: 2, // Border width
                  ),
                ),
                child: CircleAvatar(
                  radius: 107,
                  backgroundColor: Colors.white, // Changed from green to white
                  child: ClipOval(
                    child: Image.asset(
                      width: 210,
                      'assets/logo.jpeg',
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
                  prefixIcon: const Icon(Icons.email,
                      color: Colors.blue), // Changed icon color to blue
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
                  prefixIcon: const Icon(Icons.lock,
                      color: Colors.blue), // Changed icon color to blue
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
              ElevatedButton(
                onPressed: () async {
                  final userData = await loginUser(
                    email: emailController.text,
                    password: passwordController.text,
                  );

                  print('Login response: $userData'); // 🔍 Check the output

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
                          content: Text('Login failed. Please try again.')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  backgroundColor: Colors.blue, // Changed from green to blue
                ),
                child: Text('Login',
                    style: GoogleFonts.exo2(fontSize: 18, color: Colors.white)),
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
                    onPressed: () {
                      handleGoogleSignIn(context);
                    },
                    icon: Image.asset('assets/google.png', height: 40),
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

Future<Map<String, dynamic>?> loginUser(
    {required String email, required String password}) async {
  final response = await http.post(
    Uri.parse('http://10.0.2.2:5600/api/auth/login'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'email': email, 'password': password}),
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    return null;
  }
}

// Google Sign-In Setup
final GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: ['email', 'profile'],
  // Optional: Force web client ID for testing (remove later)
  // clientId: 'YOUR_WEB_CLIENT_ID.apps.googleusercontent.com',
);

Future<void> handleGoogleSignIn(BuildContext context) async {
  try {
    print('Initiating Google Sign-In...');

    // Force sign out first to clear any existing session
    await _googleSignIn.signOut();

    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      print('User cancelled sign-in');
      return;
    }

    print('User email: ${googleUser.email}');

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    print('ID Token: ${googleAuth.idToken}');
    print('Access Token: ${googleAuth.accessToken}');

    if (googleAuth.idToken == null) {
      throw Exception('ID Token is null - check configuration');
    }

    // Send to your Node.js backend
    final response = await http.post(
      Uri.parse('http://10.0.2.2:5600/api/auth/google-sign-in'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${googleAuth.idToken}'
      },
      // You might want to send both tokens
      body: jsonEncode({
        'idToken': googleAuth.idToken,
        'accessToken': googleAuth.accessToken,
        'email': googleUser.email,
      }),
    );

    if (response.statusCode == 200) {
      final userData = jsonDecode(response.body);
      // Handle successful login
    } else {
      print('Backend error: ${response.body}');
    }
  } catch (error) {
    print('Google Sign-In Error: $error');
  }
}
