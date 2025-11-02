import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '/config/app_colors.dart';
import '/app/networking/post_api_service.dart';
import '/app/networking/user_api_service.dart';
import '/app/models/user.dart';
import '/app/models/post.dart';

class PostTaggingWidget extends StatefulWidget {
  final Post post;
  final Function(Post) onPostUpdated;

  const PostTaggingWidget({
    super.key,
    required this.post,
    required this.onPostUpdated,
  });

  @override
  createState() => _PostTaggingWidgetState();
}

class _PostTaggingWidgetState extends NyState<PostTaggingWidget> {
  List<User> _taggedUsers = [];
  List<User> _suggestions = [];
  bool _isLoadingSuggestions = false;
  bool _isLoading = false;
  bool _showAddTag = false;

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _loadTaggedUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _loadTaggedUsers() {

    setState(() {
      _taggedUsers = []; // Initialize with existing tagged users
    });
  }

  Future<void> _searchUsers(String query) async {
    if (query.length < 2) {
      setState(() {
        _suggestions = [];
      });
      return;
    }

    setState(() {
      _isLoadingSuggestions = true;
    });

    try {
      final response = await api<UserApiService>(
        (request) => request.searchUsersByInterests(
          interests: [query],
          perPage: 10,
        ),
      );

      if (response != null && response['success'] == true) {
        final List<dynamic> usersData = response['data'] ?? [];
        final List<User> users =
            usersData.map((json) => User.fromJson(json)).toList();

        setState(() {
          _suggestions = users;
        });
      }
    } catch (e) {
      print('Error searching users: $e');
    } finally {
      setState(() {
        _isLoadingSuggestions = false;
      });
    }
  }

  Future<void> _tagUser(User user) async {
    if (_taggedUsers.any((u) => u.id == user.id)) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await api<PostApiService>(
        (request) => request.tagUsersInPost(
          postId: widget.post.id!,
          userIds: [user.id!],
        ),
      );

      if (response != null && response['success'] == true) {
        setState(() {
          _taggedUsers.add(user);
        });
        _searchController.clear();
        setState(() {
          _showAddTag = false;
        });
        showToast(
          title: "Success",
          description: "User tagged successfully",
          style: ToastNotificationStyleType.success,
        );
      }
    } catch (e) {
      print('Error tagging user: $e');
      showToast(
        title: "Error",
        description: "Failed to tag user",
        style: ToastNotificationStyleType.danger,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _untagUser(User user) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await api<PostApiService>(
        (request) => request.untagUsersFromPost(
          postId: widget.post.id!,
          userIds: [user.id!],
        ),
      );

      if (response != null && response['success'] == true) {
        setState(() {
          _taggedUsers.removeWhere((u) => u.id == user.id);
        });
        showToast(
          title: "Success",
          description: "User untagged successfully",
          style: ToastNotificationStyleType.success,
        );
      }
    } catch (e) {
      print('Error untagging user: $e');
      showToast(
        title: "Error",
        description: "Failed to untag user",
        style: ToastNotificationStyleType.danger,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget view(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.person_add,
                  color: AppColors.primaryPink, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Tagged Users',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _showAddTag = !_showAddTag;
                  });
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryPink,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _showAddTag ? 'Cancel' : 'Add Tag',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          if (_showAddTag) ...[
            Container(
              decoration: BoxDecoration(
                color: AppColors.backgroundPrimary,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                onChanged: _searchUsers,
                decoration: InputDecoration(
                  hintText: 'Search users to tag...',
                  hintStyle: const TextStyle(color: AppColors.textTertiary),
                  prefixIcon:
                      const Icon(Icons.search, color: AppColors.textSecondary),
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
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                style: const TextStyle(color: AppColors.textPrimary),
              ),
            ),
            if (_suggestions.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                constraints: const BoxConstraints(maxHeight: 200),
                decoration: BoxDecoration(
                  color: AppColors.backgroundPrimary,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _suggestions.length,
                  itemBuilder: (context, index) {
                    final user = _suggestions[index];
                    final isTagged = _taggedUsers.any((u) => u.id == user.id);

                    return GestureDetector(
                      onTap: isTagged ? null : () => _tagUser(user),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isTagged
                              ? AppColors.backgroundSecondary
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
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
                                      color: isTagged
                                          ? AppColors.textSecondary
                                          : AppColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    '@${user.username ?? ''}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isTagged
                                          ? AppColors.textTertiary
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isTagged)
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
            ],
            const SizedBox(height: 12),
          ],

          if (_taggedUsers.isNotEmpty) ...[
            const Text(
              'Currently Tagged:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _taggedUsers
                  .map((user) => _buildTaggedUserChip(user))
                  .toList(),
            ),
          ] else if (!_showAddTag) ...[
            const Text(
              'No users tagged yet',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textTertiary,
              ),
            ),
          ],

          if (_isLoading)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildUserAvatar(User user) {
    return Container(
      width: 32,
      height: 32,
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
                        size: 16, color: AppColors.textTertiary);
                  },
                )
              : const Icon(Icons.person,
                  size: 16, color: AppColors.textTertiary),
        ),
      ),
    );
  }

  Widget _buildTaggedUserChip(User user) {
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
            onTap: () => _untagUser(user),
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
