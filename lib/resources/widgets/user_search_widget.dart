import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '../../app/networking/post_api_service.dart';

class UserSearchWidget extends StatefulWidget {
  final Function(List<Map<String, dynamic>>) onUsersSelected;
  final List<Map<String, dynamic>> selectedUsers;

  const UserSearchWidget({
    super.key,
    required this.onUsersSelected,
    required this.selectedUsers,
  });

  @override
  State<UserSearchWidget> createState() => _UserSearchWidgetState();
}

class _UserSearchWidgetState extends State<UserSearchWidget> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;
  String _lastQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchUsers(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    if (query == _lastQuery) return; // Avoid duplicate searches

    setState(() {
      _isSearching = true;
      _lastQuery = query;
    });

    try {
      final results = await PostApiService().searchUsersForTagging(
        query: query,
        limit: 10,
      );

      if (mounted) {
        setState(() {
          _searchResults = results ?? [];
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _searchResults = [];
          _isSearching = false;
        });
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to search users: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _selectUser(Map<String, dynamic> user) {
    if (!widget.selectedUsers.any((u) => u['id'] == user['id'])) {
      final updatedUsers = [...widget.selectedUsers, user];
      widget.onUsersSelected(updatedUsers);
    }
  }

  void _removeUser(Map<String, dynamic> user) {
    final updatedUsers =
        widget.selectedUsers.where((u) => u['id'] != user['id']).toList();
    widget.onUsersSelected(updatedUsers);
  }

  bool _isUserSelected(Map<String, dynamic> user) {
    return widget.selectedUsers.any((u) => u['id'] == user['id']);
  }

  Widget _buildUserItem(Map<String, dynamic> user) {
    final isSelected = _isUserSelected(user);

    return ListTile(
      leading: CircleAvatar(
        backgroundImage: user['profile_picture'] != null
            ? NetworkImage(user['profile_picture'])
            : null,
        child: user['profile_picture'] == null
            ? Text(user['name']?.substring(0, 1).toUpperCase() ?? '?')
            : null,
      ),
      title: Text(user['name'] ?? 'Unknown'),
      subtitle: Text('@${user['username'] ?? ''}'),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: Colors.blue)
          : const Icon(Icons.add_circle_outline),
      onTap: () => isSelected ? _removeUser(user) : _selectUser(user),
    );
  }

  Widget _buildSelectedUsers() {
    if (widget.selectedUsers.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tagged Users:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.selectedUsers.map((user) {
            return Chip(
              avatar: CircleAvatar(
                backgroundImage: user['profile_picture'] != null
                    ? NetworkImage(user['profile_picture'])
                    : null,
                child: user['profile_picture'] == null
                    ? Text(user['name']?.substring(0, 1).toUpperCase() ?? '?')
                    : null,
                radius: 12,
              ),
              label: Text(user['name'] ?? 'Unknown'),
              deleteIcon: const Icon(Icons.close, size: 18),
              onDeleted: () => _removeUser(user),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Selected users display
        _buildSelectedUsers(),

        // Search field
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            labelText: 'Search users to tag',
            hintText: 'Type @username or name',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _isSearching
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : null,
            border: const OutlineInputBorder(),
          ),
          onChanged: (value) {
            // Debounce search
            Future.delayed(const Duration(milliseconds: 500), () {
              if (_searchController.text == value) {
                _searchUsers(value);
              }
            });
          },
        ),

        const SizedBox(height: 16),

        // Search results
        if (_searchResults.isNotEmpty)
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final user = _searchResults[index];
                return _buildUserItem(user);
              },
            ),
          ),

        // Instructions
        if (_searchResults.isEmpty && _searchController.text.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Start typing to search for users to tag in your post',
              style: TextStyle(
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }
}
