import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/pages/settings_page.dart';
import 'package:flutter_chat_app/services/chat/chat_services.dart';

class MyDrawer extends StatelessWidget {
  void signUserOut() {
    FirebaseAuth auth = FirebaseAuth.instance;
    auth.signOut();
  }

  MyDrawer({super.key});
  final chatServices = ChatServices();

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
                  color: Theme.of(context).colorScheme.primary,
                ),
                child: Column(
                   
                  children: [
                    Text(
                      '👋 ${chatServices.getCurrentUser()?.email}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.tertiary,
                        fontSize: 18,
                        overflow: TextOverflow.fade
                      ),
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
