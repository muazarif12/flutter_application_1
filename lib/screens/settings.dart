import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  int _currentIndex = 2;
  bool _isDarkMode = false;

  void _onTabTapped(int index) {
    if (index != _currentIndex) {
      setState(() {
        _currentIndex = index;
      });
      switch (index) {
        case 0:
          Navigator.pushReplacementNamed(context, '/home');
          break;
        case 1:
          Navigator.pushReplacementNamed(context, '/bookings');
          break;
        case 2:
          Navigator.pushReplacementNamed(context, '/settings');
          break;
      }
    }
  }

  void _toggleDarkMode(bool value) {
    setState(() {
      _isDarkMode = value;
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Colors.transparent, // Keep status bar transparent
        statusBarIconBrightness: _isDarkMode ? Brightness.light : Brightness.dark, // Adjust status bar text color
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isDarkMode ? Colors.black : Colors.white,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(8),
        child: Column(
          children: [
            const SizedBox(height: 50),
            CircleAvatar(
              radius: 77,
              backgroundColor: Colors.green,
              child: ClipOval(
                child: Image.asset(
                  width: 150,
                  'assets/logo.jpeg',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(height: 10,),
            Text(
              'Syed Bilal Ali',
              style: GoogleFonts.exo2(fontSize: 16, color: _isDarkMode ? Colors.white : Colors.black),
            ),
            Text(
              'user@gmail.com',
              style: GoogleFonts.exo2(fontSize: 16, color: _isDarkMode ? Colors.white : Colors.black),
            ),
            const SizedBox(height: 50),
            _buildSettingsOption(icon: Icons.notifications, title: "Notifications", subtitle: "Manage notification preferences", isDarkMode: _isDarkMode),
            _buildSettingsOption(icon: Icons.lock, title: "Privacy & Security", subtitle: "Control your privacy settings", isDarkMode: _isDarkMode),
            _buildSettingsOption(icon: Icons.language, title: "Language", subtitle: "Select your preferred language", isDarkMode: _isDarkMode),
            _buildSettingsOption(
                icon: Icons.palette,
                title: "Theme",
                subtitle: _isDarkMode ? "Dark" : "Light",
                trailing: Switch(
                  value: _isDarkMode,
                  onChanged: _toggleDarkMode, // Call the function to toggle dark mode
                  activeColor: Colors.green,
                ),
                isDarkMode: _isDarkMode
            ),
            _buildSettingsOption(icon: Icons.help_outline, title: "Help & Support", subtitle: "Get help and contact support", isDarkMode: _isDarkMode),
            _buildSettingsOption(icon: Icons.info, title: "About", subtitle: "Version 1.0.0", isDarkMode: _isDarkMode),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.green),
              title: Text("Logout", style: GoogleFonts.exo2(fontWeight: FontWeight.bold, color: _isDarkMode ? Colors.white : Colors.black)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: _isDarkMode ? Colors.black : Colors.white,
        selectedLabelStyle: GoogleFonts.exo2(),
        unselectedLabelStyle: GoogleFonts.exo2(),
        currentIndex: _currentIndex,
        selectedItemColor: Colors.green,
        unselectedItemColor: _isDarkMode ? Colors.white :Colors.black38,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: "Bookings"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
        ],
      ),
    );
  }

  Widget _buildSettingsOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDarkMode,
    Widget? trailing
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.green),
      title: Text(title, style: GoogleFonts.exo2(fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.black)),
      subtitle: Text(subtitle, style: GoogleFonts.exo2(color: Colors.grey)),
      trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: () {},
    );
  }
}
