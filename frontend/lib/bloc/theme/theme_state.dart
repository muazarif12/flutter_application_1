import 'package:flutter/material.dart';

abstract class ThemeState {
  final ThemeMode themeMode;

  const ThemeState(this.themeMode);
}

class LightThemeState extends ThemeState {
  const LightThemeState() : super(ThemeMode.light);
}

class DarkThemeState extends ThemeState {
  const DarkThemeState() : super(ThemeMode.dark);
}
