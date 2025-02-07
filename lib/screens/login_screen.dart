import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login / Sign Up'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Email/Phone Input
            TextFormField(
              controller: emailController,
              decoration: const InputDecoration(
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
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
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
                child: const Text('Forgot Password?'),
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
              child: const Text(
                'Login',
                style: TextStyle(fontSize: 18, color: Colors.white),
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
            const Text(
              'Sign in with',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
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
                const Text("Don't have an account?"),
                TextButton(
                  onPressed: () {
                    // Navigate to Sign Up Screen
                    Navigator.pushNamed(context, '/register');
                  },
                  child: const Text('Sign Up'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Dummy login function for demonstration
Future<bool> loginUser({required String email, required String password}) async {
  // Simulate a network call
  await Future.delayed(const Duration(seconds: 2));
  return email == "test" && password == "123";
}
