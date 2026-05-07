import 'package:flutter/material.dart';

class UserTile extends StatelessWidget {
  final String text;
  final String? avatarUrl;
  final void Function()? onTap;
  final void Function()? onAvatarTap;

  const UserTile({
    super.key,
    required this.text,
    this.avatarUrl,
    this.onTap,
    this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        decoration: BoxDecoration(
          color: colorScheme.tertiary,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: colorScheme.outline.withValues(alpha: .7)),
        ),
        child: Row(
          children: [
            InkWell(
              onTap: onAvatarTap,
              customBorder: const CircleBorder(),
              child: _buildAvatar(context),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: TextStyle(
                      color: colorScheme.inversePrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    "Tap avatar for profile",
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[500]),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: 24,
        backgroundImage: NetworkImage(avatarUrl!),
        backgroundColor: Colors.grey[300],
      );
    } else {
      return CircleAvatar(
        radius: 24,
        backgroundColor: Theme.of(context).colorScheme.secondary,
        child: Text(
          text.isNotEmpty ? text[0].toUpperCase() : '?',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.inversePrimary,
          ),
        ),
      );
    }
  }
}
