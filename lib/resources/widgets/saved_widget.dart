import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '/app/networking/post_api_service.dart';
import '/app/models/post.dart';
import '/resources/widgets/smart_media_widget.dart';

class Saved extends StatefulWidget {
  const Saved({super.key});

  @override
  createState() => _SavedState();
}

class _SavedState extends NyState<Saved> {
  @override
  Widget view(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),

            // Saved Posts with NyPullToRefresh
            Expanded(
              child: NyPullToRefresh.separated(
                child: (BuildContext context, dynamic data) {
                  return _buildSavedPostCard(data);
                },
                data: (int iteration) async {
                  print('📱 Saved: Loading saved posts - page: $iteration');

                  try {
                    final response = await api<PostApiService>(
                      (request) => request.getSavedPosts(
                        perPage: 20,
                        page:
                            iteration, // Use iteration directly as page number
                      ),
                    );

                    if (response != null && response['success'] == true) {
                      final List<dynamic> postsData =
                          response['data']['data'] ?? [];
                      final posts =
                          postsData.map((json) => Post.fromJson(json)).toList();

                      print('📱 Saved: Loaded ${posts.length} saved posts');
                      return posts;
                    } else {
                      print(
                          '❌ Saved: Failed to load saved posts: ${response?['message']}');
                      return [];
                    }
                  } catch (e) {
                    print('❌ Saved: Error loading saved posts: $e');
                    return [];
                  }
                },
                separatorBuilder: (BuildContext context, int index) {
                  return const SizedBox(height: 16);
                },
                stateName: "saved_posts_list",
                empty: _buildEmptyState(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Text(
            'Saved Posts',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {
              // Refresh the saved posts
              setState(() {});
            },
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh saved posts',
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bookmark_border,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 20),
            Text(
              'No saved posts yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Posts you save will appear here',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavedPostCard(Post post) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: post.user?.profilePicture != null
                      ? NetworkImage(post.user!.profilePicture!)
                      : null,
                  backgroundColor: const Color(0xFF9ACD32),
                  child: post.user?.profilePicture == null
                      ? Text(
                          post.user?.name?.substring(0, 1).toUpperCase() ?? 'U',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
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
                        post.user?.fullName ??
                            post.user?.name ??
                            'Unknown User',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '@${post.user?.username ?? 'unknown'}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) async {
                    if (value == 'unsave') {
                      await _unsavePost(post);
                    } else if (value == 'share') {
                      await _sharePost(post);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'unsave',
                      child: Row(
                        children: [
                          Icon(Icons.bookmark_remove, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Unsave'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'share',
                      child: Row(
                        children: [
                          Icon(Icons.share, color: Colors.blue),
                          SizedBox(width: 8),
                          Text('Share'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Media content
          if (post.mediaUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SmartMediaWidget(
                post: post,
                height: 300,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

          // Caption
          if (post.caption != null && post.caption!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                post.caption!,
                style: const TextStyle(fontSize: 16),
              ),
            ),

          // Tags
          if (post.tags != null && post.tags!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Wrap(
                spacing: 8,
                children: post.tags!
                    .map((tag) => Chip(
                          label: Text('#$tag'),
                          backgroundColor: Colors.blue.withValues(alpha: 0.1),
                          labelStyle: const TextStyle(
                            color: Colors.blue,
                            fontSize: 12,
                          ),
                        ))
                    .toList(),
              ),
            ),

          // Location
          if (post.location != null && post.location!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    post.location!,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    IconData icon,
    String label, {
    Color? color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime? timestamp) {
    if (timestamp == null) return '';

    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  Future<void> _handlePostAction(String action, Post post) async {
    switch (action) {
      case 'unsave':
        await _unsavePost(post);
        break;
      case 'share':
        await _sharePost(post);
        break;
    }
  }

  Future<void> _toggleLike(Post post) async {
    try {
      print('❤️ Saved: Toggling like for post ${post.id}');

      // Optimistic update
      final wasLiked = post.isLiked ?? false;
      final oldLikesCount = post.likesCount ?? 0;

      setState(() {
        post.isLiked = !wasLiked;
        post.likesCount = wasLiked ? oldLikesCount - 1 : oldLikesCount + 1;
      });

      final response = await api<PostApiService>(
        (request) => request.toggleLike(post.id!),
      );

      if (response != null && response['success'] == true) {
        setState(() {
          post.isLiked = response['data']['liked'] ?? !wasLiked;
          post.likesCount = response['data']['likes_count'] ?? oldLikesCount;
        });
      } else {
        // Revert on failure
        setState(() {
          post.isLiked = wasLiked;
          post.likesCount = oldLikesCount;
        });
        showToast(
          title: 'Error',
          description: 'Failed to like post',
        );
      }
    } catch (e) {
      print('❌ Saved: Error toggling like: $e');
      showToast(
        title: 'Error',
        description: 'Failed to like post',
      );
    }
  }

  Future<void> _unsavePost(Post post) async {
    try {
      print('📱 Saved: Unsaving post ${post.id}');

      final response = await api<PostApiService>(
        (request) => request.toggleSave(post.id!),
      );

      if (response != null && response['success'] == true) {
        showToast(
          title: 'Success',
          description: 'Post removed from saved',
        );
        // Refresh the list
        setState(() {});
      } else {
        showToast(
          title: 'Error',
          description: 'Failed to unsave post',
        );
      }
    } catch (e) {
      print('❌ Saved: Error unsaving post: $e');
      showToast(
        title: 'Error',
        description: 'Failed to unsave post',
      );
    }
  }

  Future<void> _sharePost(Post post) async {
    try {
      print('📱 Saved: Sharing post ${post.id}');
      showToast(
        title: 'Share',
        description: 'Sharing functionality coming soon!',
      );
    } catch (e) {
      print('❌ Saved: Error sharing post: $e');
      showToast(
        title: 'Error',
        description: 'Failed to share post',
      );
    }
  }
}
