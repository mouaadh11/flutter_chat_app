import 'package:flutter/material.dart';
import 'package:flutter_chat_app/pages/profile_page.dart';
import 'package:flutter_chat_app/pages/settings_page.dart';
import 'package:flutter_chat_app/services/auth/auth_service.dart';

class MyDrawer extends StatelessWidget {
  Future<void> signUserOut() {
    return AuthService().signOut();
  }

  MyDrawer({super.key});
  final auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                FutureBuilder<Map<String, dynamic>?>(
                  future: auth.getCurrentUserData(),
                  builder: (context, snapshot) {
                    final colorScheme = Theme.of(context).colorScheme;
                    final userData = snapshot.data;
                    final username =
                        (userData?['username'] ??
                                auth.getCurrentUser()?.email?.split('@').first ??
                                'User')
                            .toString();
                    final email = (auth.getCurrentUser()?.email ?? '').toString();
                    final avatarUrl = (userData?['avatarUrl'] ?? '').toString();
        
                    return Container(
                      width: double.infinity,
                      margin: const EdgeInsets.fromLTRB(14, 18, 14, 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: colorScheme.secondary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 34,
                            backgroundColor: colorScheme.tertiary,
                            backgroundImage: avatarUrl.isNotEmpty
                                ? NetworkImage(avatarUrl)
                                : null,
                            child: avatarUrl.isEmpty
                                ? Text(
                                    username.isNotEmpty
                                        ? username[0].toUpperCase()
                                        : '?',
                                    style: TextStyle(
                                      color: colorScheme.inversePrimary,
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  username,
                                  style: TextStyle(
                                    color: colorScheme.inversePrimary,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  email,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 13,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.chat_bubble_outline),
                  title: const Text('Chats'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: const Text('Profile'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfilePage(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.edit_outlined),
                  title: const Text('Edit Profile'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
        
            Padding(
              padding: const EdgeInsets.only(bottom: 35),
              child: ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: () async {
                  await signUserOut();
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
