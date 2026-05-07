import 'package:flutter/material.dart';

final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  scaffoldBackgroundColor: const Color(0xFF0B0F0E),
  colorScheme: const ColorScheme.dark(
    primary: Color(0xFF5EEAD4),
    onPrimary: Color(0xFF042F2E),
    surface: Color(0xFF0B0F0E),
    onSurface: Color(0xFFE5E7EB),
    secondary: Color(0xFF17211F),
    onSecondary: Color(0xFFE5E7EB),
    tertiary: Color(0xFF111816),
    inversePrimary: Color(0xFFE5E7EB),
    outline: Color(0xFF25302D),
  ),
  appBarTheme: const AppBarTheme(
    elevation: 0,
    centerTitle: false,
    scrolledUnderElevation: 0,
    backgroundColor: Color(0xFF0B0F0E),
    foregroundColor: Color(0xFFE5E7EB),
    titleTextStyle: TextStyle(
      color: Color(0xFFE5E7EB),
      fontSize: 22,
      fontWeight: FontWeight.w700,
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFF111816),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFF25302D)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFF5EEAD4), width: 1.4),
    ),
  ),
  drawerTheme: const DrawerThemeData(backgroundColor: Color(0xFF111816)),
);
