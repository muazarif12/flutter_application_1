import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/theme/theme_bloc.dart';
import '../../bloc/theme/theme_event.dart';
import '../../bloc/theme/theme_state.dart';
import '../../colors/app_colors.dart';

class HostSettingsScreen extends StatelessWidget {
  const HostSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeState = context.watch<ThemeBloc>().state;
    final bool isDarkMode = themeState is DarkThemeState;

    // Ensure system UI updates after the screen is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        context.read<ThemeBloc>().setSystemUI();
      }
    });

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            const SizedBox(height: 50),
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.blue, // Blue border color
                  width: 2, // Border width
                ),
              ),
              child: CircleAvatar(
                radius: 77,
                backgroundColor: Colors.white,
                child: ClipOval(
                  child: Image.asset(
                    'assets/logo.png',
                    width: 150,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Syed Bilal Ali',
              style: TextStyle(
                  fontSize: 16,
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontFamily: 'Exo2'),
            ),
            Text(
              'user@gmail.com',
              style: TextStyle(
                  fontSize: 16,
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontFamily: 'Exo2'),
            ),
            const SizedBox(height: 50),
            _buildSettingsOption(
              icon: Icons.notifications,
              title: "Notifications",
              subtitle: "Manage notification preferences",
              isDarkMode: isDarkMode,
            ),
            _buildSettingsOption(
              icon: Icons.lock,
              title: "Privacy & Security",
              subtitle: "Control your privacy settings",
              isDarkMode: isDarkMode,
            ),
            _buildSettingsOption(
              icon: Icons.language,
              title: "Language",
              subtitle: "Select your preferred language",
              isDarkMode: isDarkMode,
            ),
            _buildSettingsOption(
              icon: Icons.palette,
              title: "Theme",
              subtitle: isDarkMode ? "Dark" : "Light",
              trailing: Switch(
                value: isDarkMode,
                onChanged: (value) {
                  context.read<ThemeBloc>().add(ToggleThemeEvent());
                },
                activeColor: Colors.blue,
              ),
              isDarkMode: isDarkMode,
            ),
            _buildSettingsOption(
              icon: Icons.help_outline,
              title: "Help & Support",
              subtitle: "Get help and contact support",
              isDarkMode: isDarkMode,
            ),
            _buildSettingsOption(
              icon: Icons.info,
              title: "About",
              subtitle: "Version 1.0.0",
              isDarkMode: isDarkMode,
            ),
            ListTile(
              leading: const Icon(Icons.person,
                  color: Colors.blue), // Icon change here
              title: Text(
                "Switch to User",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black,
                    fontFamily: 'Exo2'),
              ),
              trailing: const Icon(Icons.arrow_forward_ios,
                  size: 16, color: Colors.blue),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/home');
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.blue),
              title: Text(
                "Logout",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black,
                    fontFamily: 'Exo2'),
              ),
              trailing: const Icon(Icons.arrow_forward_ios,
                  size: 16, color: Colors.blue),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
            const SizedBox(height: 10,),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton.icon(
                  label: const Text(
                    'Switch to User',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.electricBlue, // Electric Blue button
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/home');
                  },
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDarkMode,
    Widget? trailing,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(
        title,
        style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black,
            fontFamily: 'Exo2'),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          color: Colors.grey,
          fontFamily: 'Exo2',
        ),
      ),
      trailing: trailing ??
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.blue),
      onTap: () {},
    );
  }
}
