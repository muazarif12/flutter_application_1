import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/theme/theme_bloc.dart';
import '../bloc/theme/theme_state.dart';
import 'host_listings_screen.dart';
import 'host_dashboard_screen.dart';
import 'host_calendar_screen.dart';
import 'host_settings_screen.dart';
// import 'host_messages_screen.dart';
// import 'host_settings_screen.dart';

class HostMainScreen extends StatefulWidget {
  const HostMainScreen({super.key});

  @override
  HostMainScreenState createState() => HostMainScreenState();
}

class HostMainScreenState extends State<HostMainScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
     const HostListingsScreen(), // Hosts manage their arenas
     const HostDashboardScreen(), // Hosts see bookings overview
     const HostCalendarScreen(), // Hosts manage calendar
      // const HostMessagesScreen(), // Chat with customers
      const HostSettingsScreen(), // Settings & payouts
    ];
  }

  @override
  Widget build(BuildContext context) {
    final themeState = context.watch<ThemeBloc>().state;
    final bool isDarkMode = themeState is DarkThemeState;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent, // Removes splash effect
          highlightColor: Colors.transparent, // Removes highlight effect
          hoverColor: Colors.transparent, // Removes hover effect
        ),
        child: BottomNavigationBar(
          selectedLabelStyle: const TextStyle(fontFamily: 'Exo2'),
          unselectedLabelStyle: const TextStyle(fontFamily: 'Exo2'),
          backgroundColor: isDarkMode ? Colors.black : Colors.white,
          selectedItemColor: Colors.green,
          unselectedItemColor: isDarkMode ? Colors.white : Colors.black38,
          currentIndex: _currentIndex,
          type: BottomNavigationBarType.fixed,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.sports_soccer), label: "Listings"),
            BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Dashboard"),
            BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: "Calendar"),
            // BottomNavigationBarItem(icon: Icon(Icons.message), label: "Messages"),
            BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
          ],
        ),
      ),
    );
  }
}
