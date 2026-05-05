import 'package:flutter/material.dart';
import 'package:flutter_chat_app/components/my_drawer.dart';
import 'package:flutter_chat_app/components/user_tile.dart';
import 'package:flutter_chat_app/pages/chat_screen_page.dart';
import 'package:flutter_chat_app/pages/profile_page.dart';
import 'package:flutter_chat_app/services/auth/auth_service.dart';
import 'package:flutter_chat_app/services/chat/chat_services.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final chatServices = ChatServices();
  final auth = AuthService();
  final TextEditingController searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text("Chats")),
      drawer: MyDrawer(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Search people",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isEmpty
                    ? null
                    : IconButton(
                        tooltip: "Clear search",
                        onPressed: () {
                          searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                        icon: const Icon(Icons.close),
                      ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 10),
            child: Row(
              children: [
                Text(
                  _searchQuery.isEmpty ? "Recent" : "People",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: colorScheme.inversePrimary,
                  ),
                ),
                const Spacer(),
                Text(
                  _searchQuery.isEmpty
                      ? "Start or continue a chat"
                      : "Tap avatar to view",
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
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
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState(
            icon: Icons.chat_bubble_outline,
            title: "No chats yet",
            subtitle: "Search for someone and start a conversation.",
          );
        } else {
          final users = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 12),
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
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState(
            icon: Icons.person_search,
            title: "No people found",
            subtitle: "Try a different username.",
          );
        } else {
          final users = snapshot.data!;
          final filteredUsers = users.where((user) {
            final username = (user['username'] ?? '').toString().toLowerCase();
            return username.contains(_searchQuery);
          }).toList();

          if (filteredUsers.isEmpty) {
            return _buildEmptyState(
              icon: Icons.person_search,
              title: "No match",
              subtitle: "No users found matching '$_searchQuery'.",
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 12),
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
      onAvatarTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProfilePage(userData: user)),
        );
      },
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              receiverName: username,
              receiverAvatarUrl: avatarUrl,
              userId: user['uid'],
              receiverData: user,
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: colorScheme.secondary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: colorScheme.primary, size: 30),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                color: colorScheme.inversePrimary,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
