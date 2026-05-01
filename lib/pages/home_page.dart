import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/components/my_drawer.dart';
import 'package:flutter_chat_app/components/user_tile.dart';
import 'package:flutter_chat_app/pages/chat_screen_page.dart';
import 'package:flutter_chat_app/services/auth/auth_service.dart';
import 'package:flutter_chat_app/services/chat/chat_services.dart';
import 'package:flutter_chat_app/services/chat/chat_notification.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final chatServices = ChatServices();
  final notificationService = ChatNotification();
  final auth = AuthService();
  final TextEditingController searchController = TextEditingController();
  String _searchQuery = '';
  @override
  void initState() {
    super.initState();
    notificationService.initNotifications();
    chatServices.msgNotification();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: "Search by username...",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.secondary,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.toLowerCase();
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          if (_searchQuery.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Text(
                    "Recent Chats",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: _searchQuery.isEmpty
                ? _buildRecentChatsList()
                : _buildSearchResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentChatsList() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: chatServices.getRecentChatsStream(),
      builder: (context, snapshot) {
        print("in the recent chat list logic");
        if (snapshot.connectionState == ConnectionState.waiting) {
          print("loading .....");
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          print("there's an error");
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          print(snapshot.data);
          return Center(
            child: Text(
              "No recent chats. Search for users to start a conversation!",
            ),
          );
        } else {
          final users = snapshot.data!;
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return _buildUserListItem(user, context);
            },
          );
        }
      },
    );
  }

  Widget _buildSearchResults() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: chatServices.getUserStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text("No users found"));
        } else {
          final users = snapshot.data!;
          final filteredUsers = users.where((user) {
            final username = (user['username'] ?? '').toString().toLowerCase();
            return username.contains(_searchQuery);
          }).toList();

          if (filteredUsers.isEmpty) {
            return Center(
              child: Text("No users found matching '$_searchQuery'"),
            );
          }

          return ListView.builder(
            itemCount: filteredUsers.length,
            itemBuilder: (context, index) {
              final user = filteredUsers[index];
              return _buildUserListItem(user, context);
            },
          );
        }
      },
    );
  }

  Widget _buildUserListItem(Map<String, dynamic> user, BuildContext context) {
    if (user['uid'] == chatServices.getCurrentUser()?.uid) {
      return SizedBox.shrink();
    }
    final username = user['username'] ?? 'Unknown';
    final avatarUrl = user['avatarUrl'] ?? '';

    return UserTile(
      text: username,
      avatarUrl: avatarUrl,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              userEmail: user['username'] ?? '',
              userId: user['uid'],
            ),
          ),
        );
      },
    );
  }
}
