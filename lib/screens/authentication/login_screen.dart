import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isLoading = false; // To manage the loading state

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Transform.translate(
                offset: const Offset(-10, -30),
                child: Image.asset(
                  'assets/logo.png',
                  width: 300,
                  height: 300,
                  fit: BoxFit.contain,
                ),
              ),
              const Spacer(), // Pushes the login section to the bottom
            ],
          ),

          /// Login Container at Bottom
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(40),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(80),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Login',
                      style: TextStyle(fontSize: 32),
                    ),
                    const SizedBox(height: 25),

                    /// Email Input
                    SizedBox(
                      height: 45,
                      child: TextFormField(
                        controller: emailController,
                        decoration: InputDecoration(
                          isDense: true,
                          labelStyle: GoogleFonts.exo2(),
                          labelText: 'Email or Phone Number',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ),
                    const SizedBox(height: 20),

                    /// Password Input
                    SizedBox(
                      height: 45,
                      child: TextFormField(
                        controller: passwordController,
                        decoration: InputDecoration(
                          isDense: true,
                          labelStyle: GoogleFonts.exo2(),
                          labelText: 'Password',
                          border: const OutlineInputBorder(),
                        ),
                        obscureText: true,
                      ),
                    ),
                    const SizedBox(height: 10),

                    /// Forgot Password
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

                    /// Login Button with loading effect
                    SizedBox(
                      height: 45,
                      width: MediaQuery.of(context).size.width * 0.75,
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
                          backgroundColor: Colors.green,
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                            : Text(
                          'Login',
                          style: GoogleFonts.exo2(fontSize: 15, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    /// OR Divider
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

                    /// Social Login
                    Center(
                      child: Text(
                        'Sign in with',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.exo2(fontSize: 16, color: Colors.grey),
                      ),
                    ),
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

                    /// Sign Up Prompt
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
          ),
        ],
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
