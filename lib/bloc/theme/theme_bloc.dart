import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart'; // Import for SystemChrome
import 'theme_event.dart';
import 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(const LightThemeState()) {
    on<ToggleThemeEvent>((event, emit) {
      if (state is LightThemeState) {
        emit(const DarkThemeState());
      } else {
        emit(const LightThemeState());
      }
      setSystemUI(); // Ensure system UI updates when toggling themes
    });
  }

  void setSystemUI() {
    final isDarkMode = state is DarkThemeState;
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // Transparent status bar
      statusBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark, // Adjust status bar icons
      systemNavigationBarColor: isDarkMode ? Colors.black : Colors.white, // Navigation bar color
      systemNavigationBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark, // Adjust navigation icons
    ));
  }
}
