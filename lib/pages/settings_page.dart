import 'package:flutter/material.dart';
import 'package:flutter_chat_app/pages/edit_profile_page.dart';
import 'package:flutter_chat_app/pages/profile_page.dart';
import 'package:flutter_chat_app/services/auth/auth_service.dart';
import 'package:flutter_chat_app/themes/mode_provider.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
  SettingsPage({super.key});

  final auth = AuthService();

  Future<void> _signOut(BuildContext context) async {
    await auth.signOut();
    if (context.mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          _buildAccountPanel(context),
          const SizedBox(height: 16),
          _buildSectionTitle(context, "Preferences"),
          const SizedBox(height: 8),
          _buildPanel(
            context,
            children: [
              _buildThemeTile(context),
              const Divider(height: 1),
              _buildInfoTile(
                context,
                icon: Icons.photo_library_outlined,
                title: "Profile Photos",
                subtitle: "Up to 5 compressed photos on your profile",
              ),
              const Divider(height: 1),
              _buildInfoTile(
                context,
                icon: Icons.notifications_outlined,
                title: "Chat Notifications",
                subtitle: "Enabled when device permissions allow alerts",
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSectionTitle(context, "Account"),
          const SizedBox(height: 8),
          _buildPanel(
            context,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.person_outline),
                title: const Text("View Profile"),
                subtitle: const Text("See how your profile appears to others"),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfilePage(),
                    ),
                  );
                },
              ),
              const Divider(height: 1),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.edit_outlined),
                title: const Text("Edit Profile"),
                subtitle: const Text("Update bio, avatar, and profile photos"),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  final wasUpdated = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EditProfilePage(),
                    ),
                  );
                  if (context.mounted && wasUpdated == true) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfilePage(),
                      ),
                    );
                  }
                },
              ),
              const Divider(height: 1),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.logout),
                title: const Text("Sign Out"),
                subtitle: const Text("Remove this device from your session"),
                onTap: () => _signOut(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAccountPanel(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return FutureBuilder<Map<String, dynamic>?>(
      future: auth.getCurrentUserData(),
      builder: (context, snapshot) {
        final userData = snapshot.data;
        final username =
            (userData?['username'] ??
                    auth.getCurrentUser()?.email?.split('@').first ??
                    'User')
                .toString();
        final email = (auth.getCurrentUser()?.email ?? '').toString();
        final avatarUrl = (userData?['avatarUrl'] ?? '').toString();

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.tertiary,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: .7),
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: colorScheme.secondary,
                backgroundImage: avatarUrl.isNotEmpty
                    ? NetworkImage(avatarUrl)
                    : null,
                child: avatarUrl.isEmpty
                    ? Text(
                        username.isNotEmpty ? username[0].toUpperCase() : '?',
                        style: TextStyle(
                          color: colorScheme.inversePrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      username,
                      style: TextStyle(
                        color: colorScheme.inversePrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email,
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThemeTile(BuildContext context) {
    final modeProvider = Provider.of<ModeProvider>(context);

    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      secondary: const Icon(Icons.dark_mode_outlined),
      title: const Text("Dark Mode"),
      subtitle: Text(modeProvider.isDarkMode ? "Dark theme" : "Light theme"),
      value: modeProvider.isDarkMode,
      onChanged: (_) {
        Provider.of<ModeProvider>(context, listen: false).toggleMode();
      },
    );
  }

  Widget _buildInfoTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
    );
  }

  Widget _buildPanel(BuildContext context, {required List<Widget> children}) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.tertiary,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outline.withValues(alpha: .7)),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        color: Theme.of(context).colorScheme.inversePrimary,
        fontSize: 14,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}
