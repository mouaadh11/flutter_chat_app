import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/pages/settings_page.dart';
import 'package:flutter_chat_app/themes/light_mode.dart';

class MyDrawer extends StatelessWidget {
  void signUserOut() {
    FirebaseAuth auth = FirebaseAuth.instance;
    auth.signOut();
  }

  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: lightTheme.colorScheme.primary,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Menu',
                      style: TextStyle(
                        color: lightTheme.colorScheme.tertiary,
                        fontSize: 24,
                      ),
                    ),
                    Icon(
                      Icons.message_rounded,
                      color: lightTheme.colorScheme.tertiary,
                      size: 30,
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: Icon(Icons.home),
                title: Text('Home'),
                onTap: () {
                  // Handle Home tap
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.settings),
                title: Text('Settings'),
                onTap: () {
                  print("tapping settings");
                  // Handle Settings tap
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SettingsPage()),
                  );
                },
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.only(bottom: 35),
            child: ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () {
                // Sign out the user
                signUserOut();
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}
