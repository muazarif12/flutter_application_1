import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        padding: const EdgeInsets.all(20) ,
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
              const SizedBox(height: 25,),
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  labelStyle: GoogleFonts.exo2(),
                  labelText: 'Email or Phone Number',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),

              // Password Input
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

              // Forgot Password Link
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // Navigate to Forgot Password Screen
                    Navigator.pushNamed(context, '/forgot-password');
                  },
                  child: Text('Forgot Password?', style: GoogleFonts.exo2(),),
                ),
              ),
              const SizedBox(height: 20),

              // Login Button
              ElevatedButton(
                onPressed: () async {
                  // Perform login logic
                  bool loginSuccess = await loginUser(
                    email: emailController.text,
                    password: passwordController.text,
                  );

                  if (loginSuccess) {
                    // Navigate to Home Screen
                    Navigator.pushReplacementNamed(context, '/home');
                  } else {
                    // Show error message
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Login failed. Please try again.'),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  backgroundColor: Colors.green, // Button color
                ),
                child: Text(
                  'Login',
                  style: GoogleFonts.exo2(fontSize: 18, color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),

              // Or Divider
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

              // 3rd Party Login Buttons
              Text(
                'Sign in with',
                textAlign: TextAlign.center,
                style: GoogleFonts.exo2(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Google Login
                  IconButton(
                    onPressed: () {
                      // Handle Google login
                    },
                    icon: Image.asset('assets/google.png', height: 40),
                  ),
                  const SizedBox(width: 20),

                  // Facebook Login
                  IconButton(
                    onPressed: () {
                      // Handle Facebook login
                    },
                    icon: Image.asset('assets/facebook.png', height: 40),
                  ),
                  const SizedBox(width: 20),

                  // iCloud Login
                  IconButton(
                    onPressed: () {
                      // Handle iCloud login
                    },
                    icon: Image.asset('assets/icloud.png', height: 40),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Sign Up Prompt
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Don't have an account?", style: GoogleFonts.exo2(),),
                  TextButton(
                    onPressed: () {
                      // Navigate to Sign Up Screen
                      Navigator.pushNamed(context, '/register');
                    },
                    child: Text('Sign Up', style: GoogleFonts.exo2(),),
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
Future<bool> loginUser({required String email, required String password}) async {
  await Future.delayed(const Duration(seconds: 2));
  return email == "test" && password == "123";
}
