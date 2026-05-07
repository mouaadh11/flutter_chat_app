import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/services/auth/auth_service.dart';
import 'package:image_picker/image_picker.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  static const double _profileImageMaxDimension = 1200;
  static const int _profileImageQuality = 75;

  final auth = AuthService();
  final ImagePicker _picker = ImagePicker();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _statusController = TextEditingController();

  String? _avatarUrl;
  List<String> _galleryUrls = [];
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isUploadingGallery = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userData = await auth.getCurrentUserData();
    if (!mounted) return;

    setState(() {
      _usernameController.text = (userData?['username'] ?? '').toString();
      _bioController.text = (userData?['bio'] ?? '').toString();
      _locationController.text = (userData?['location'] ?? '').toString();
      _websiteController.text = (userData?['website'] ?? '').toString();
      _phoneController.text = (userData?['phone'] ?? '').toString();
      _statusController.text = (userData?['status'] ?? 'Available').toString();
      _avatarUrl = (userData?['avatarUrl'] ?? '').toString();
      _galleryUrls = List<String>.from(
        userData?['galleryUrls'] ?? [],
      ).take(5).toList();
      _isLoading = false;
    });
  }

  Future<void> _pickAvatar() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: _profileImageMaxDimension,
        maxHeight: _profileImageMaxDimension,
        imageQuality: _profileImageQuality,
      );
      if (image == null) return;

      final currentUser = auth.getCurrentUser();
      if (currentUser == null) return;

      final storageRef = FirebaseStorage.instance
          .ref()
          .child('avatars')
          .child('${currentUser.uid}.jpg');

      await storageRef.putFile(File(image.path));
      final downloadUrl = await storageRef.getDownloadURL();

      await auth.updateUserProfile(avatarUrl: downloadUrl);

      if (!mounted) return;
      setState(() => _avatarUrl = downloadUrl);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Avatar updated successfully!")),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error updating avatar: $e")));
    }
  }

  Future<void> _pickGalleryImages() async {
    try {
      final remainingSlots = 5 - _galleryUrls.length;
      if (remainingSlots <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile photos are limited to 5")),
        );
        return;
      }

      final images = await _picker.pickMultiImage(
        maxWidth: _profileImageMaxDimension,
        maxHeight: _profileImageMaxDimension,
        imageQuality: _profileImageQuality,
      );
      if (images.isEmpty) return;

      final currentUser = auth.getCurrentUser();
      if (currentUser == null) return;

      setState(() => _isUploadingGallery = true);

      final uploadedUrls = <String>[];
      for (final image in images.take(remainingSlots)) {
        final fileName = '${DateTime.now().microsecondsSinceEpoch}.jpg';
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('profile_gallery')
            .child(currentUser.uid)
            .child(fileName);

        await storageRef.putFile(File(image.path));
        uploadedUrls.add(await storageRef.getDownloadURL());
      }

      final updatedGallery = [
        ..._galleryUrls,
        ...uploadedUrls,
      ].take(5).toList();
      await auth.updateUserProfile(galleryUrls: updatedGallery);

      if (!mounted) return;
      setState(() {
        _galleryUrls = updatedGallery;
        _isUploadingGallery = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            images.length > remainingSlots
                ? "Added $remainingSlots photos. Profiles can show up to 5."
                : "Photos added to your profile",
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isUploadingGallery = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error uploading photos: $e")));
    }
  }

  Future<void> _saveProfile() async {
    final username = _usernameController.text.trim();
    if (username.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Username cannot be empty")));
      return;
    }

    setState(() => _isSaving = true);
    try {
      await auth.updateUserProfile(
        username: username,
        bio: _bioController.text.trim(),
        location: _locationController.text.trim(),
        website: _websiteController.text.trim(),
        phone: _phoneController.text.trim(),
        status: _statusController.text.trim(),
      );

      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile saved successfully!")),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error saving profile: $e")));
    }
  }

  Future<void> _removeGalleryImage(String imageUrl) async {
    final updatedGallery = _galleryUrls
        .where((url) => url != imageUrl)
        .toList();
    await auth.updateUserProfile(galleryUrls: updatedGallery);
    if (!mounted) return;
    setState(() => _galleryUrls = updatedGallery);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    _websiteController.dispose();
    _phoneController.dispose();
    _statusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        actions: [
          IconButton(
            tooltip: "Save profile",
            onPressed: _isSaving ? null : _saveProfile,
            icon: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 32),
              child: Column(
                children: [
                  _buildAvatarEditor(context),
                  const SizedBox(height: 20),
                  _buildSectionTitle(context, "Details"),
                  const SizedBox(height: 8),
                  _buildProfileFields(context),
                  const SizedBox(height: 16),
                  _buildGalleryEditor(context),
                ],
              ),
            ),
    );
  }

  Widget _buildAvatarEditor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: _pickAvatar,
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 54,
                  backgroundColor: colorScheme.tertiary,
                  backgroundImage: _avatarUrl != null && _avatarUrl!.isNotEmpty
                      ? NetworkImage(_avatarUrl!)
                      : null,
                  child: _avatarUrl == null || _avatarUrl!.isEmpty
                      ? Icon(Icons.person, size: 52, color: Colors.grey[700])
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: colorScheme.primary,
                    child: Icon(
                      Icons.camera_alt,
                      size: 18,
                      color: colorScheme.onPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Tap to change avatar",
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
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
                          gaplessPlayback: true,
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
