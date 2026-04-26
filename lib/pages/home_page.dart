import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/components/my_drawer.dart';
import 'package:flutter_chat_app/components/user_tile.dart';
import 'package:flutter_chat_app/pages/chat_screen_page.dart';
import 'package:flutter_chat_app/services/auth/auth_service.dart';
import 'package:flutter_chat_app/services/chat/chat_services.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final chatServices = ChatServices();
  final auth = AuthService();

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
        title: Text("Home Page"),
      ),
      drawer: MyDrawer(),
      body: _buildUserList(),
    );
  }

  Widget _buildUserList() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: chatServices.getUserStream(),
      builder: (context, snapshot) {
        // Handle different states of the stream
        if (snapshot.connectionState == ConnectionState.waiting) {
          // While waiting for data, show a loading indicator
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          // If there's an error, display it
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          // If there's no data, show a message
          return Center(child: Text("No users found"));
        } else {
          final users = snapshot.data!;
          print("Users: $users");
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return _buildUserListItem(user, context);
                },
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildUserListItem(Map<String, dynamic> user, BuildContext context) {
    if (user['uid'] == chatServices.getCurrentUser()?.uid) {
      // Don't show the current user in the list
      return SizedBox.shrink();
    }
    return UserTile(
      text: user['email'],
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(userEmail: user['email'], userId: user['uid']),
          ),
        );
      },
    );
  }
}
