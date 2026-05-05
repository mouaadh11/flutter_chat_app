import 'package:flutter/material.dart';
import 'package:flutter_chat_app/pages/settings_page.dart';
import 'package:flutter_chat_app/services/auth/auth_service.dart';

class ProfilePage extends StatefulWidget {
  final String? userId;
  final Map<String, dynamic>? userData;

  const ProfilePage({super.key, this.userId, this.userData});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final auth = AuthService();
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    if (widget.userData != null) {
      setState(() {
        _userData = widget.userData;
        _isLoading = false;
      });
      return;
    }

    final userData = widget.userId == null
        ? await auth.getCurrentUserData()
        : await auth.getUserData(widget.userId!);
    if (mounted) {
      setState(() {
        _userData = userData;
        _isLoading = false;
      });
    }
  }

  bool get _isCurrentUser {
    final currentUser = auth.getCurrentUser();
    return currentUser != null && _userData?['uid'] == currentUser.uid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        actions: [
          if (_isCurrentUser)
            IconButton(
              tooltip: "Edit profile",
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                );
                _loadProfile();
              },
              icon: const Icon(Icons.edit),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _userData == null
          ? const Center(child: Text("Profile not found"))
          : _buildProfile(context),
    );
  }

  Widget _buildProfile(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final username = (_userData?['username'] ?? 'Unknown user').toString();
    final email = (_userData?['email'] ?? '').toString();
    final avatarUrl = (_userData?['avatarUrl'] ?? '').toString();
    final bio = (_userData?['bio'] ?? '').toString();
    final galleryUrls = List<String>.from(_userData?['galleryUrls'] ?? []);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: colorScheme.tertiary,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: .7),
            ),
          ),
          child: Row(
            children: [
              Hero(
                tag: 'profile-avatar-${_userData?['uid'] ?? username}',
                child: CircleAvatar(
                  radius: 44,
                  backgroundColor: colorScheme.secondary,
                  backgroundImage: avatarUrl.isNotEmpty
                      ? NetworkImage(avatarUrl)
                      : null,
                  child: avatarUrl.isEmpty
                      ? Text(
                          username.isNotEmpty ? username[0].toUpperCase() : '?',
                          style: TextStyle(
                            color: colorScheme.inversePrimary,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      username,
                      style: TextStyle(
                        color: colorScheme.inversePrimary,
                        fontSize: 24,
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
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.secondary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        (_userData?['status'] ?? 'Available').toString(),
                        style: TextStyle(
                          color: colorScheme.inversePrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildSection(context, "Bio", bio.isEmpty ? "No bio added yet." : bio),
        _buildInfoGrid(context),
        const SizedBox(height: 18),
        Row(
          children: [
            Text(
              "Photos",
              style: TextStyle(
                color: colorScheme.inversePrimary,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const Spacer(),
            Text(
              "${galleryUrls.length}",
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
          ],
        ),
        const SizedBox(height: 12),
        galleryUrls.isEmpty
            ? Container(
                height: 130,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colorScheme.tertiary,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: colorScheme.outline.withValues(alpha: .7),
                  ),
                ),
                child: Text(
                  _isCurrentUser
                      ? "Add photos from Edit Profile"
                      : "No photos yet",
                  style: TextStyle(color: Colors.grey[600]),
                ),
              )
            : GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: galleryUrls.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemBuilder: (context, index) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      galleryUrls[index],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: colorScheme.secondary,
                        child: const Icon(Icons.broken_image),
                      ),
                    ),
                  );
                },
              ),
      ],
    );
  }

  Widget _buildSection(BuildContext context, String title, String value) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.tertiary,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outline.withValues(alpha: .7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: colorScheme.inversePrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(color: colorScheme.inversePrimary)),
        ],
      ),
    );
  }

  Widget _buildInfoGrid(BuildContext context) {
    final items = [
      _ProfileInfo(Icons.circle, "Status", _userData?['status']),
      _ProfileInfo(Icons.place, "Location", _userData?['location']),
      _ProfileInfo(Icons.link, "Website", _userData?['website']),
      _ProfileInfo(Icons.phone, "Phone", _userData?['phone']),
    ];

    return Column(
      children: items
          .where((item) => (item.value ?? '').toString().trim().isNotEmpty)
          .map((item) => _buildInfoTile(context, item))
          .toList(),
    );
  }

  Widget _buildInfoTile(BuildContext context, _ProfileInfo item) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.tertiary,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outline.withValues(alpha: .7)),
      ),
      child: Row(
        children: [
          Icon(item.icon, color: colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.label,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                Text(
                  item.value.toString(),
                  style: TextStyle(
                    color: colorScheme.inversePrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileInfo {
  final IconData icon;
  final String label;
  final dynamic value;

  const _ProfileInfo(this.icon, this.label, this.value);
}
