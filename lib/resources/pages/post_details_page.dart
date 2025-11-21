import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '/app/models/post.dart';
import '/app/models/user.dart';
import '/app/networking/post_api_service.dart';
import '/app/networking/user_api_service.dart';
import '/resources/widgets/smart_media_widget.dart';

class PostDetailsPage extends NyStatefulWidget {
  static RouteView path = ("/post-details", (_) => PostDetailsPage());

  PostDetailsPage({super.key, this.post})
      : super(child: () => _PostDetailsPageState());

  final Post? post;
}

class _PostDetailsPageState extends NyPage<PostDetailsPage> {
  Post? _post;
  User? _currentUser;
  bool _isLoading = true;
  bool _isDeleting = false;

  @override
  get init => () async {
        await _loadData();
      };

  Future<void> _loadData() async {
    try {
      _post = widget.post ?? widget.data()?['post'] as Post?;

      final user =
          await api<UserApiService>((request) => request.fetchCurrentUser());
      if (user != null) {
        _currentUser = user;
        print('👤 PostDetailsPage: Current user loaded: ${_currentUser?.id}');
        print('👤 PostDetailsPage: Post user: ${_post?.user?.id}');
        print(
            '👤 PostDetailsPage: Can delete: ${_currentUser?.id == _post?.user?.id}');
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ PostDetailsPage: Error loading data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deletePost() async {
    if (_post == null) return;

    if (_currentUser?.id != _post?.user?.id) {
      showToast(
        title: "Error",
        description: "You can only delete your own posts",
        style: ToastNotificationStyleType.danger,
      );
      return;
    }

    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Post'),
          content: const Text(
              'Are you sure you want to delete this post? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;

    try {
      if (mounted) {
        setState(() {
          _isDeleting = true;
        });
      }

      final response = await api<PostApiService>(
        (request) => request.deletePost(_post!.id!),
      );

      if (response != null && response['success'] == true) {
        showToast(
          title: "Success",
          description: "Post deleted successfully",
          style: ToastNotificationStyleType.success,
        );

        Navigator.of(context).pop(true); // Return true to indicate deletion
      } else {
        showToast(
          title: "Error",
          description: "Failed to delete post. Please try again.",
          style: ToastNotificationStyleType.danger,
        );
      }
    } catch (e) {
      print('❌ PostDetailsPage: Error deleting post: $e');
      showToast(
        title: "Error",
        description: "Network error. Please try again.",
        style: ToastNotificationStyleType.danger,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  @override
  Widget view(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_post == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Post Details"),
        ),
        body: const Center(
          child: Text("Post not found"),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "Post Details",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        actions: [
          if (_currentUser?.id == _post?.user?.id)
            IconButton(
              icon: _isDeleting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.delete, color: Colors.red),
              onPressed: _isDeleting ? null : _deletePost,
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundImage: _post!.user?.profilePicture != null
                        ? NetworkImage(_post!.user!.profilePicture!)
                        : null,
                    backgroundColor: const Color(0xFF9ACD32),
                    child: _post!.user?.profilePicture == null
                        ? Text(
                            _post!.user?.name?.substring(0, 1).toUpperCase() ??
                                'U',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
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
                          _post!.user?.fullName ??
                              _post!.user?.name ??
                              'Unknown User',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '@${_post!.user?.username ?? 'unknown'}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_post!.category != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF69B4),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _post!.category!.name ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (_post!.mediaUrl != null)
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black,
                ),
                child: SmartMediaWidget(
                  post: _post!,
                  width: double.infinity,
                  height: 400,
                  fit: BoxFit.contain,
                ),
              ),
            if (_post!.caption != null && _post!.caption!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  _post!.caption!,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            if (_post!.location != null && _post!.location!.isNotEmpty)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      _post!.location!,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.favorite, size: 16, color: Colors.red),
                  const SizedBox(width: 4),
                  Text(
                    '${_post!.likesCount ?? 0} likes',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.share, size: 16, color: Colors.green),
                  const SizedBox(width: 4),
                  Text(
                    '${_post!.sharesCount ?? 0} shares',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.bookmark, size: 16, color: Colors.blue),
                  const SizedBox(width: 4),
                  Text(
                    '${_post!.savesCount ?? 0} saves',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
