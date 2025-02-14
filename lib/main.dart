import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/bookings_screen.dart';
import 'package:flutter_application_1/screens/settings.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/registration_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/terms_and_conditions_screen.dart';
import 'screens/home_screen.dart'; // Import the Home Screen

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Arena Finder',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const WelcomeScreen(),
      routes: {
        '/login': (context) => const LoginScreen(), // Login Screen route
        '/register': (context) => const RegistrationScreen(), // Registration Screen route
        '/forgot-password': (context) => const ForgotPasswordScreen(), // Forgot Password Screen route
        '/terms-and-conditions': (context) => const TermsAndConditionsScreen(), // Terms and Conditions Screen route
        '/home': (context) => const HomeScreen(isDarkMode: true,),
        '/settings': (context) => const SettingsScreen(),
        '/bookings': (context) => const ListingsPage(),
      },
    );
  }
}