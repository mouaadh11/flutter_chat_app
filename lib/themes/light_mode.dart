import 'package:flutter/material.dart';

final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  scaffoldBackgroundColor: const Color(0xFFF8FAF9),
  colorScheme: const ColorScheme.light(
    primary: Color(0xFF0F766E),
    onPrimary: Colors.white,
    surface: Color(0xFFF8FAF9),
    onSurface: Color(0xFF111827),
    secondary: Color(0xFFE7ECEA),
    onSecondary: Color(0xFF111827),
    tertiary: Color(0xFFFFFFFF),
    inversePrimary: Color(0xFF111827),
    outline: Color(0xFFD8DEDC),
  ),
  appBarTheme: const AppBarTheme(
    elevation: 0,
    centerTitle: false,
    scrolledUnderElevation: 0,
    backgroundColor: Color(0xFFF8FAF9),
    foregroundColor: Color(0xFF111827),
    titleTextStyle: TextStyle(
      color: Color(0xFF111827),
      fontSize: 22,
      fontWeight: FontWeight.w700,
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFFD8DEDC)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFF0F766E), width: 1.4),
    ),
  ),
  drawerTheme: const DrawerThemeData(backgroundColor: Color(0xFFFFFFFF)),
);
