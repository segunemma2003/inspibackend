import 'package:flutter/material.dart';
import '../../app/models/user.dart';

class TaggedUsersWidget extends StatelessWidget {
  final List<User> taggedUsers;
  final VoidCallback? onTap;

  const TaggedUsersWidget({
    super.key,
    required this.taggedUsers,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (taggedUsers.isEmpty) return const SizedBox.shrink();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.blue.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.person_add,
              size: 16,
              color: Colors.blue,
            ),
            const SizedBox(width: 8),
            Text(
              'Tagged: ${taggedUsers.map((u) => u.name).join(', ')}',
              style: const TextStyle(
                color: Colors.blue,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TaggedUsersChipsWidget extends StatelessWidget {
  final List<User> taggedUsers;
  final Function(User)? onUserTap;
  final Function(User)? onRemoveUser;

  const TaggedUsersChipsWidget({
    super.key,
    required this.taggedUsers,
    this.onUserTap,
    this.onRemoveUser,
  });

  @override
  Widget build(BuildContext context) {
    if (taggedUsers.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: taggedUsers.map((user) {
        return GestureDetector(
          onTap: onUserTap != null ? () => onUserTap!(user) : null,
          child: Chip(
            avatar: CircleAvatar(
              backgroundImage: user.profilePicture != null
                  ? NetworkImage(user.profilePicture!)
                  : null,
              child: user.profilePicture == null
                  ? Text(user.name?.substring(0, 1).toUpperCase() ?? '?')
                  : null,
              radius: 12,
            ),
            label: Text(
              user.name ?? 'Unknown',
              style: const TextStyle(fontSize: 12),
            ),
            deleteIcon:
                onRemoveUser != null ? const Icon(Icons.close, size: 16) : null,
            onDeleted: onRemoveUser != null ? () => onRemoveUser!(user) : null,
          ),
        );
      }).toList(),
    );
  }
}
