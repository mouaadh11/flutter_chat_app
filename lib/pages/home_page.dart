import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  void signUserOut() {
    FirebaseAuth _auth = FirebaseAuth.instance;
    _auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home Page"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              // Sign out the user
              signUserOut();
            },
          ),
        ],
      ),
      body: Center(child: Text("Welcome to the Home Page!")),
    );
  }
}
