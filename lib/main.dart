import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/theme/theme_bloc.dart';
import 'bloc/theme/theme_state.dart';
import 'screens/intro/welcome_screen.dart';
import 'screens/authentication/login_screen.dart';
import 'screens/authentication/registration_screen.dart';
import 'screens/authentication/forgot_password_screen.dart';
import 'screens/intro/terms_and_conditions_screen.dart';
import 'screens/user/home_screen.dart';
import 'screens/user/bookings_screen.dart';
import 'screens/settings/settings.dart';
import 'screens/host/host_main_screen.dart';
import 'screens/host/add_arena_screen.dart';
import 'screens/host/edit_arena_screen.dart';
void main() {
  final themeBloc = ThemeBloc();
  themeBloc.setSystemUI();

  runApp(
    BlocProvider(
      create: (context) => themeBloc,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Arena Finder',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            useMaterial3: true,
            fontFamily: 'Exo2'
          ),
          home: const WelcomeScreen(),
          routes: {
            '/login': (context) => const LoginScreen(),
            '/register': (context) => const RegistrationScreen(),
            '/forgot-password': (context) => const ForgotPasswordScreen(),
            '/terms-and-conditions': (context) => const TermsAndConditionsScreen(),
            '/home': (context) => const MainScreen(), // Use `MainScreen` for indexed navigation
            '/host-home': (context) => const HostMainScreen(),
            '/add-arena': (context) => const AddArenaScreen(),
            '/edit-arena': (context) => const EditArenaScreen(arena: {}),
          },
        );
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  int _currentIndex = 0; // Default to Home screen

  late final List<Widget> _screens; // Declare screens list

  @override
void initState() {
  super.initState();
  _screens = [
    HomeScreen(
      onTabTapped: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      currentIndex: _currentIndex,
    ),
    BookingsScreen(), // Change ListingsPage to BookingsScreen
    const SettingsScreen(),
  ];
}

  @override
  Widget build(BuildContext context) {
    final themeState = context.watch<ThemeBloc>().state;
    final bool isDarkMode = themeState is DarkThemeState;

    // Ensure system UI updates when this screen is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        context.read<ThemeBloc>().setSystemUI();
      }
    });

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens, // Use declared screens list
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent, // Removes splash effect
          highlightColor: Colors.transparent, // Removes highlight effect
          hoverColor: Colors.transparent, // Removes hover effect
        ),
        child: BottomNavigationBar(
          selectedLabelStyle: const TextStyle(fontFamily:'Exo2'),
          unselectedLabelStyle: const TextStyle(fontFamily:'Exo2'),
          backgroundColor: isDarkMode ? Colors.black : Colors.white,
          selectedItemColor: Colors.blue,
          unselectedItemColor: isDarkMode ? Colors.white : Colors.black38,
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index; // Update selected tab
            });
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.book), label: "Bookings"),
            BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
          ],
        ),
      ),
    );
  }
}

