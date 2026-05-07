import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/services/auth/auth_service.dart';
import 'package:flutter_chat_app/services/chat/chat_notification.dart';
import 'package:flutter_chat_app/themes/mode_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final auth = AuthService();
  final _chatNotification = ChatNotification();
  bool _notificationsEnabled = true;
  bool _isLoadingNotifications = true;
  bool _isUpdatingNotifications = false;

  @override
  void initState() {
    super.initState();
    _loadNotificationSetting();
  }

  Future<void> _loadNotificationSetting() async {
    final isEnabled = await _chatNotification.areNotificationsEnabled();

    if (!mounted) return;

    setState(() {
      _notificationsEnabled = isEnabled;
      _isLoadingNotifications = false;
    });
  }

  Future<void> _signOut(BuildContext context) async {
    await auth.signOut();
    if (context.mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _toggleNotifications(bool enabled) async {
    setState(() {
      _notificationsEnabled = enabled;
      _isUpdatingNotifications = true;
    });

    try {
      await _chatNotification.setNotificationsEnabled(enabled);
    } catch (_) {
      if (mounted) {
        setState(() {
          _notificationsEnabled = !enabled;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Couldn't update notification settings"),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingNotifications = false;
        });
      }
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
              _buildNotificationTile(context),
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

  Widget _buildProfileFields(BuildContext context) {
    return _buildPanel(
      context,
      children: [
        _buildTextField(_usernameController, "Username", Icons.person),
        const SizedBox(height: 12),
        _buildTextField(_bioController, "Bio", Icons.notes, maxLines: 4),
        const SizedBox(height: 12),
        _buildTextField(_statusController, "Status", Icons.circle),
        const SizedBox(height: 12),
        _buildTextField(_locationController, "Location", Icons.place),
        const SizedBox(height: 12),
        _buildTextField(_websiteController, "Website", Icons.link),
        const SizedBox(height: 12),
        _buildTextField(_phoneController, "Phone", Icons.phone),
      ],
    );
  }

  Widget _buildGalleryEditor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return _buildPanel(
      context,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                "Profile Photos (${_galleryUrls.length}/5)",
                style: TextStyle(
                  color: colorScheme.inversePrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            IconButton(
              tooltip: "Add photos",
              onPressed: _isUploadingGallery || _galleryUrls.length >= 5
                  ? null
                  : _pickGalleryImages,
              icon: _isUploadingGallery
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.add_photo_alternate),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _galleryUrls.isEmpty
            ? Container(
                height: 110,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.withValues(alpha: .35)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "Add multiple photos for your profile",
                  style: TextStyle(color: Colors.grey[600]),
                ),
              )
            : GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _galleryUrls.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemBuilder: (context, index) {
                  final imageUrl = _galleryUrls[index];
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                color: colorScheme.secondary,
                                child: const Icon(Icons.broken_image),
                              ),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: InkWell(
                          onTap: () => _removeGalleryImage(imageUrl),
                          child: const CircleAvatar(
                            radius: 13,
                            backgroundColor: Colors.black54,
                            child: Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
      ],
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

  Widget _buildNotificationTile(BuildContext context) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      secondary: const Icon(Icons.notifications_outlined),
      title: const Text("Chat Notifications"),
      subtitle: Text(
        _notificationsEnabled
            ? "Alerts are active when device permissions allow"
            : "Alerts are turned off for this account",
      ),
      value: _notificationsEnabled,
      onChanged: _isLoadingNotifications || _isUpdatingNotifications
          ? null
          : _toggleNotifications,
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.tertiary,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outline.withValues(alpha: .7)),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.inversePrimary,
          fontSize: 14,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
    );
  }
}
