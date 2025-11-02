import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '/config/app_colors.dart';
import '/app/networking/user_api_service.dart';
import '/app/models/user.dart';

class UserTaggingWidget extends StatefulWidget {
  final List<User> selectedUsers;
  final Function(List<User>) onUsersChanged;
  final String? hintText;

  const UserTaggingWidget({
    super.key,
    required this.selectedUsers,
    required this.onUsersChanged,
    this.hintText,
  });

  @override
  createState() => _UserTaggingWidgetState();
}

class _UserTaggingWidgetState extends NyState<UserTaggingWidget> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  List<User> _suggestions = [];
  bool _isLoadingSuggestions = false;
  bool _showSuggestions = false;

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _searchUsers(String query) async {
    print('🔍 UserTaggingWidget: Searching for users with query: "$query"');

    if (query.length < 2) {
      setState(() {
        _suggestions = [];
        _showSuggestions = false;
      });
      return;
    }

    setState(() {
      _isLoadingSuggestions = true;
    });

    try {
      print('🔍 UserTaggingWidget: Making API call to getTagSuggestions');
      final response = await api<UserApiService>(
        (request) => request.searchUsersByInterests(
          interests: [query],
          perPage: 10,
        ),
      );

      print('🔍 UserTaggingWidget: API response: $response');

      if (response != null && response['success'] == true) {
        final List<dynamic> usersData = response['data'] ?? [];
        final List<User> users =
            usersData.map((json) => User.fromJson(json)).toList();

        print('🔍 UserTaggingWidget: Found ${users.length} users');
        setState(() {
          _suggestions = users;
          _showSuggestions = true;
        });
      } else {
        print(
            '🔍 UserTaggingWidget: API call failed or returned no data, showing dummy users for testing');

        final List<User> dummyUsers = [
          User.fromJson({
            'id': 1,
            'username': 'testuser1',
            'full_name': 'Test User 1',
            'profile_picture': null,
          }),
          User.fromJson({
            'id': 2,
            'username': 'testuser2',
            'full_name': 'Test User 2',
            'profile_picture': null,
          }),
          User.fromJson({
            'id': 3,
            'username': 'johndoe',
            'full_name': 'John Doe',
            'profile_picture': null,
          }),
        ];

        setState(() {
          _suggestions = dummyUsers;
          _showSuggestions = true;
        });
      }
    } catch (e) {
      print('❌ UserTaggingWidget: Error searching users: $e');

      final List<User> dummyUsers = [
        User.fromJson({
          'id': 1,
          'username': 'testuser1',
          'full_name': 'Test User 1',
          'profile_picture': null,
        }),
        User.fromJson({
          'id': 2,
          'username': 'testuser2',
          'full_name': 'Test User 2',
          'profile_picture': null,
        }),
      ];

      setState(() {
        _suggestions = dummyUsers;
        _showSuggestions = true;
      });
    } finally {
      setState(() {
        _isLoadingSuggestions = false;
      });
    }
  }

  void _addUser(User user) {
    if (!widget.selectedUsers.any((u) => u.id == user.id)) {
      widget.onUsersChanged([...widget.selectedUsers, user]);
    }
    _searchController.clear();
    setState(() {
      _showSuggestions = false;
      _suggestions = [];
    });
  }

  void _removeUser(User user) {
    widget.onUsersChanged(
      widget.selectedUsers.where((u) => u.id != user.id).toList(),
    );
  }

  @override
  Widget view(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Container(
          decoration: BoxDecoration(
            color: AppColors.backgroundSecondary,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            onChanged: _searchUsers,
            decoration: InputDecoration(
              hintText: widget.hintText ?? 'Tag users with @username',
              hintStyle: const TextStyle(color: AppColors.textTertiary),
              prefixIcon:
                  const Icon(Icons.person_add, color: AppColors.textSecondary),
              suffixIcon: _isLoadingSuggestions
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : null,
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            style: const TextStyle(color: AppColors.textPrimary),
          ),
        ),

        if (_showSuggestions && _suggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: AppColors.backgroundPrimary,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderLight),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowLight,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _suggestions.length,
              itemBuilder: (context, index) {
                final user = _suggestions[index];
                final isSelected =
                    widget.selectedUsers.any((u) => u.id == user.id);

                return GestureDetector(
                  onTap: isSelected ? null : () => _addUser(user),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.backgroundSecondary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        _buildUserAvatar(user),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.fullName ?? 'Unknown User',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? AppColors.textSecondary
                                      : AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                '@${user.username ?? ''}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isSelected
                                      ? AppColors.textTertiary
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          const Icon(
                            Icons.check_circle,
                            color: AppColors.primaryGreen,
                            size: 20,
                          )
                        else
                          const Icon(
                            Icons.add_circle_outline,
                            color: AppColors.textTertiary,
                            size: 20,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

        if (widget.selectedUsers.isNotEmpty) ...[
          const SizedBox(height: 12),
          const Text(
            'Tagged Users:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.selectedUsers
                .map((user) => _buildSelectedUserChip(user))
                .toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildUserAvatar(User user) {
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppColors.profileGradient,
      ),
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.backgroundPrimary,
        ),
        child: ClipOval(
          child: user.profilePicture != null
              ? Image.network(
                  user.profilePicture!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppColors.backgroundTertiary,
                      child: const Icon(Icons.person,
                          size: 20, color: AppColors.textTertiary),
                    );
                  },
                )
              : Container(
                  color: AppColors.backgroundTertiary,
                  child: const Icon(Icons.person,
                      size: 20, color: AppColors.textTertiary),
                ),
        ),
      ),
    );
  }

  Widget _buildSelectedUserChip(User user) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primaryPink.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryPink.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.profileGradient,
            ),
            child: Container(
              margin: const EdgeInsets.all(1),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.backgroundPrimary,
              ),
              child: ClipOval(
                child: user.profilePicture != null
                    ? Image.network(
                        user.profilePicture!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.person,
                              size: 12, color: AppColors.textTertiary);
                        },
                      )
                    : const Icon(Icons.person,
                        size: 12, color: AppColors.textTertiary),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '@${user.username ?? ''}',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.primaryPink,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () => _removeUser(user),
            child: const Icon(
              Icons.close,
              size: 16,
              color: AppColors.primaryPink,
            ),
          ),
        ],
      ),
    );
  }
}
