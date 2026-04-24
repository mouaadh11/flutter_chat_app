import 'package:flutter/material.dart';
import 'package:flutter_chat_app/themes/light_mode.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: lightTheme.colorScheme.tertiary),
        titleTextStyle: TextStyle(
          color: lightTheme.colorScheme.tertiary,
          fontSize: 20,
        ),
        backgroundColor: lightTheme.colorScheme.primary,
        title: const Text("Settings"),
      ),
      body: const Center(child: Text("Settings Page")),
    );
  }
}
