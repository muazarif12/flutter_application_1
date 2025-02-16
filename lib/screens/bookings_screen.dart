import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/theme/theme_bloc.dart';
import '../bloc/theme/theme_state.dart';

class ListingsPage extends StatelessWidget {
  final Function(int) onTabTapped;
  final int currentIndex;

  const ListingsPage({super.key, required this.onTabTapped, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    final themeState = context.watch<ThemeBloc>().state;
    final bool isDarkMode = themeState is DarkThemeState;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        context.read<ThemeBloc>().setSystemUI();
      }
    });

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "No Arena's found!",
              style: TextStyle(fontSize: 16, color: isDarkMode ? Colors.white : Colors.black54,fontFamily: 'Exo2',),
            ),
            const SizedBox(height: 5),
            Text(
              "Please add one from below.",
              style: TextStyle(fontSize: 14, color: isDarkMode ? Colors.white : Colors.black54,fontFamily: 'Exo2',),
            ),
          ],
        ),
      ),
    );
  }
}
