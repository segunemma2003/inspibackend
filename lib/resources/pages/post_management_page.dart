import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '../../app/networking/post_api_service.dart';
import '../../app/models/post.dart';
import '../widgets/smart_media_widget.dart';

class PostManagementPage extends NyStatefulWidget {
  static RouteView path = ("/post-management", (_) => PostManagementPage());

  PostManagementPage({super.key})
      : super(child: () => _PostManagementPageState());
}

class _PostManagementPageState extends NyPage<PostManagementPage> {
  List<Post> _userPosts = [];
  bool _isLoading = true;
  int _currentPage = 1;
  bool _hasMore = true;
  int? _userId;

  @override
  get init => () async {
        final args = widget.data();
        _userId = args?['userId'];
        await _loadUserPosts();
      };

  Future<void> _loadUserPosts({bool refresh = false}) async {
    if (_userId == null) return;

    if (refresh) {
      _currentPage = 1;
      _userPosts.clear();
      _hasMore = true;
    }

    if (!_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await api<PostApiService>(
        (request) => request.getPostsByUser(
          userId: _userId!,
          perPage: 20,
          page: _currentPage,
        ),
      );

      if (response != null && response['success'] == true) {
        final List<dynamic> postsData = response['data']['data'] ?? [];
        final List<Post> newPosts =
            postsData.map((json) => Post.fromJson(json)).toList();

        setState(() {
          if (refresh) {
            _userPosts = newPosts;
          } else {
            _userPosts.addAll(newPosts);
          }
          _currentPage++;
          _hasMore = newPosts.length == 20;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ PostManagementPage: Error loading user posts: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deletePost(Post post) async {
    try {
      final response = await api<PostApiService>(
        (request) => request.deletePost(post.id!),
      );

      if (response != null && response['success'] == true) {
        setState(() {
          _userPosts.removeWhere((p) => p.id == post.id);
        });
        showToast(
          title: 'Success',
          description: 'Post deleted successfully',
          style: ToastNotificationStyleType.success,
        );
      } else {
        showToast(
          title: 'Error',
          description: 'Failed to delete post',
          style: ToastNotificationStyleType.danger,
        );
      }
    } catch (e) {
      print('❌ PostManagementPage: Error deleting post: $e');
      showToast(
        title: 'Error',
        description: 'Failed to delete post',
        style: ToastNotificationStyleType.danger,
      );
    }
  }

  void _showDeleteConfirmation(Post post) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Post'),
        content: const Text(
            'Are you sure you want to delete this post? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deletePost(post);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildPostItem(Post post) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          if (post.mediaUrl != null)
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(8)),
              child: SmartMediaWidget(
                post: post,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                if (post.caption != null && post.caption!.isNotEmpty)
                  Text(
                    post.caption!,
                    style: const TextStyle(fontSize: 14),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),

                const SizedBox(height: 8),

                Row(
                  children: [
                    Icon(Icons.favorite, size: 16, color: Colors.red),
                    const SizedBox(width: 4),
                    Text('${post.likesCount ?? 0}'),
                    const SizedBox(width: 16),
                    Icon(Icons.bookmark, size: 16, color: Colors.blue),
                    const SizedBox(width: 4),
                    Text('${post.savesCount ?? 0}'),
                    const SizedBox(width: 16),
                    Icon(Icons.share, size: 16, color: Colors.green),
                    const SizedBox(width: 4),
                    Text('${post.sharesCount ?? 0}'),
                    const SizedBox(width: 16),
                  ],
                ),

                const SizedBox(height: 8),

                Text(
                  'Posted ${_formatDate(post.createdAt)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),

                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _showDeleteConfirmation(post),
                    icon: const Icon(Icons.delete, size: 18),
                    label: const Text('Delete Post'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown';

    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Posts'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        automaticallyImplyLeading: true,
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadUserPosts(refresh: true),
        child: _isLoading && _userPosts.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : _userPosts.isEmpty
                ? const Center(
                    child: Text(
                      'No posts yet',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: _userPosts.length + (_hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _userPosts.length) {
                        if (_isLoading) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      }
                      return _buildPostItem(_userPosts[index]);
                    },
                  ),
      ),
    );
  }
}
