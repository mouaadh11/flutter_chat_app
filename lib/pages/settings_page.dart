import 'package:flutter/material.dart';
import 'package:flutter_chat_app/themes/mode_provider.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.tertiary),
        titleTextStyle: TextStyle(
          color: Theme.of(context).colorScheme.tertiary,
          fontSize: 20,
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text("Settings"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary,
            borderRadius: BorderRadius.circular(10),

          ),
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 2.0),
          child: Row(
          
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Dark Mode",
                style: TextStyle(fontSize: 18, color: Theme.of(context).colorScheme.inversePrimary),
              ),
              Switch(
                value: Provider.of<ModeProvider>(context).isDarkMode,
                onChanged: (value) {
                  Provider.of<ModeProvider>(context, listen: false).toggleMode();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
