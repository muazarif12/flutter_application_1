import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

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
              CircleAvatar(
                radius: 107,
                backgroundColor: Colors.green,
                child: ClipOval(
                  child: Image.asset(
                    width: 210,
                    'assets/logo.jpeg',
                    fit: BoxFit.contain,
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
                  prefixIcon: const Icon(Icons.email),
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
                  prefixIcon: const Icon(Icons.lock),
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
                  backgroundColor: Colors.green,
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
                      Navigator.pushNamed(context, '/register');
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
