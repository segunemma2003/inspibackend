import 'package:flutter/material.dart';
import 'package:flutter_app/app/models/user.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:flutter_app/app/networking/post_api_service.dart';
import '/app/models/post.dart';
import '/app/networking/user_api_service.dart';

class OtherProfile extends NyStatefulWidget {
  final User user;

  OtherProfile({super.key, required this.user});

  @override
  createState() => _OtherProfileState();
}

class _OtherProfileState extends NyState<OtherProfile> {
  List<Post> _userPosts = [];
  bool _isLoadingPosts =
      false; // Start as false, only set to true when actually loading
  bool _hasMoreUserPosts = true;
  int _currentUserPostsPage = 1;
  bool _isLoadingFollow = false;

  // Store follower count separately to handle updates
  int _followersCount = 0;

  @override
  get init => () async {
        print(
            '📱 OtherProfile: Initializing with user: ${widget.user.username} (ID: ${widget.user.id})');

        // Initialize follower count
        _followersCount = widget.user.followersCount ?? 0;

        // Check if user is already being followed
        await _checkFollowingStatus();

        print('📱 OtherProfile: About to load user posts...');
        await _loadUserPosts(1);
        print('📱 OtherProfile: User posts loading completed');
      };

  Future<void> _checkFollowingStatus() async {
    try {
      if (widget.user.id != null) {
        // Use the isFollowed field from the User model
        print(
            '📱 OtherProfile: User isFollowed status: ${widget.user.isFollowed}');
        // No need to set state here as we'll use widget.user.isFollowed directly
      }
    } catch (e) {
      print('❌ OtherProfile: Error checking following status: $e');
    }
  }

  @override
  void dispose() {
    print('📱 OtherProfile: Disposing widget, pausing any playing videos');
    super.dispose();
  }

  Future<List<Post>> _loadUserPosts(int page,
      {bool forceRefresh = false}) async {
    if (!_hasMoreUserPosts && page > 1) return [];

    print('📱 OtherProfile: Starting _loadUserPosts for page $page');

    // Only show loading indicator for the first page
    if (page == 1) {
      setState(() {
        _isLoadingPosts = true;
      });
    }

    try {
      if (widget.user.id == null) {
        print('❌ OtherProfile: User ID is null, cannot load posts');
        setState(() {
          _isLoadingPosts = false;
        });
        return [];
      }

      print(
          '📱 OtherProfile: Loading posts for user ${widget.user.id}, page: $page');

      final response = await api<PostApiService>(
        (request) => request.getPostsByUser(
          userId: widget.user.id!,
          page: page,
          perPage: 12,
          forceRefresh: forceRefresh,
        ),
      );

      print('📱 OtherProfile: API response received');

      if (response != null && response['success'] == true) {
        final data = response['data'];
        final List<dynamic> postsData = data['data'] ?? [];
        final List<Post> newPosts =
            postsData.map((json) => Post.fromJson(json)).toList();

        print('📱 OtherProfile: Loaded ${newPosts.length} posts');

        setState(() {
          if (page == 1) {
            _userPosts = newPosts;
          } else {
            _userPosts.addAll(newPosts);
          }
          _currentUserPostsPage = data['current_page'] ?? page;
          _hasMoreUserPosts = _currentUserPostsPage < (data['last_page'] ?? 1);
          _isLoadingPosts = false;
        });

        return newPosts;
      } else {
        print(
            "❌ OtherProfile: Error loading user posts: ${response?['message']}");
        setState(() {
          _isLoadingPosts = false;
        });
        return [];
      }
    } catch (e) {
      print("❌ OtherProfile: Error loading user posts: $e");
      setState(() {
        _isLoadingPosts = false;
      });
      return [];
    }
  }

  @override
  Widget view(BuildContext context) {
    print(
        '📱 OtherProfile: Building view for user ${widget.user.username} (ID: ${widget.user.id})');
    print('📱 OtherProfile: Current posts count: ${_userPosts.length}');
    print('📱 OtherProfile: Is loading posts: $_isLoadingPosts');

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context),
            Expanded(
              child: NyPullToRefresh.grid(
                key: ValueKey('other_profile_${widget.user.id}'),
                stateName: 'other_profile_${widget.user.id}',
                crossAxisCount: 3,
                mainAxisSpacing: 2,
                crossAxisSpacing: 2,
                padding: EdgeInsets.zero,
                header: _buildProfileHeader(context),
                child: (context, post) => _buildPostItem(post as Post),
                data: (int iteration) async {
                  print(
                      '📱 OtherProfile: Loading posts - iteration: $iteration');
                  return await _loadUserPosts(iteration,
                      forceRefresh: iteration == 1);
                },
                empty: _buildEmptyState(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[200]!,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios, size: 20),
            onPressed: () => Navigator.of(context).pop(),
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.user.username ?? 'Profile',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.more_vert, size: 24),
            onPressed: () {
              _showOptionsMenu(context);
            },
          ),
        ],
      ),
    );
  }

  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.share_outlined),
              title: Text('Share Profile'),
              onTap: () {
                Navigator.pop(context);
                // Implement share functionality
              },
            ),
            ListTile(
              leading: Icon(Icons.block_outlined),
              title: Text('Block User'),
              onTap: () {
                Navigator.pop(context);
                // Implement block functionality
              },
            ),
            ListTile(
              leading: Icon(Icons.report_outlined),
              title: Text('Report User'),
              onTap: () {
                Navigator.pop(context);
                // Implement report functionality
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        _buildProfilePicture(),
        const SizedBox(height: 20),
        _buildNameAndBio(),
        const SizedBox(height: 30),
        _buildUserStats(),
        const SizedBox(height: 30),
        _buildActionButtons(context),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildProfilePicture() {
    return Container(
      width: 120,
      height: 120,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            Color(0xFFFF69B4),
            Color(0xFFFFD700),
            Color(0xFF9ACD32),
            Color(0xFF00BFFF),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Container(
        margin: const EdgeInsets.all(3),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
        ),
        child: ClipOval(
          child: widget.user.profilePicture != null &&
                  widget.user.profilePicture!.isNotEmpty
              ? Image.network(
                  widget.user.profilePicture!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child:
                          Icon(Icons.person, size: 60, color: Colors.grey[400]),
                    );
                  },
                )
              : Container(
                  color: Colors.grey[200],
                  child: Icon(Icons.person, size: 60, color: Colors.grey[400]),
                ),
        ),
      ),
    );
  }

  Widget _buildNameAndBio() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          Text(
            widget.user.fullName ?? widget.user.name ?? 'Unknown User',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '@${widget.user.username ?? 'unknown'}',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          Flexible(
            child: Text(
              widget.user.bio ?? 'No bio available',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserStats() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Posts', widget.user.postsCount ?? _userPosts.length),
          _buildStatItem('Followers', _followersCount),
          _buildStatItem('Following', widget.user.followingCount ?? 0),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, int count) {
    return Column(
      children: [
        Text(
          _formatCount(count),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: ElevatedButton(
              onPressed: _isLoadingFollow ? null : _toggleFollow,
              style: ElevatedButton.styleFrom(
                backgroundColor: (widget.user.isFollowed ?? false)
                    ? Colors.grey[200]
                    : Theme.of(context).colorScheme.primary,
                foregroundColor: (widget.user.isFollowed ?? false)
                    ? Colors.black87
                    : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: (widget.user.isFollowed ?? false)
                      ? BorderSide(color: Colors.grey[300]!, width: 1)
                      : BorderSide.none,
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
                elevation: 0,
              ),
              child: _isLoadingFollow
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          (widget.user.isFollowed ?? false)
                              ? Colors.black54
                              : Colors.white,
                        ),
                      ),
                    )
                  : Text(
                      (widget.user.isFollowed ?? false)
                          ? 'Following'
                          : 'Follow',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: OutlinedButton(
              onPressed: () {
                // Navigate to message page
                print('📱 Message button tapped');
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black87,
                side: BorderSide(color: Colors.grey[300]!, width: 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                'Message',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostItem(Post post) {
    return AspectRatio(
      aspectRatio: 1.0, // Square items
      child: GestureDetector(
        onTap: () {
          print('📱 OtherProfile: Post tapped: ${post.id}');
          // Navigate to post detail page
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(4),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: post.mediaUrl != null
                    ? (post.mediaType == 'video'
                        ? Image.network(
                            post.thumbnailUrl ?? post.mediaUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[300],
                                child: const Icon(Icons.videocam,
                                    color: Colors.white, size: 30),
                              );
                            },
                          )
                        : Image.network(
                            post.mediaUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[300],
                                child: const Icon(Icons.image,
                                    color: Colors.white, size: 30),
                              );
                            },
                          ))
                    : Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          gradient: LinearGradient(
                            colors: [Colors.blue[200]!, Colors.green[200]!],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: const Icon(Icons.image,
                            color: Colors.white, size: 30),
                      ),
              ),
              // Video indicator
              if (post.mediaType == 'video')
                const Positioned(
                  top: 8,
                  right: 8,
                  child: Icon(Icons.play_circle_filled,
                      color: Colors.white, size: 20),
                ),
              // Likes indicator
              if (post.likesCount != null && post.likesCount! > 0)
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.7),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.favorite,
                            color: Colors.white, size: 12),
                        const SizedBox(width: 2),
                        Text(
                          '${post.likesCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_photo_alternate, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No posts yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'When ${widget.user.username ?? 'this user'} shares photos and videos, you\'ll see them here.',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _toggleFollow() async {
    if (widget.user.id == null) {
      showToast(
        title: "Error",
        description: "Unable to follow user",
        style: ToastNotificationStyleType.danger,
      );
      return;
    }

    final bool wasFollowing = widget.user.isFollowed ?? false;
    final int previousFollowersCount = _followersCount;

    // Optimistic UI update
    setState(() {
      _isLoadingFollow = true;
      widget.user.isFollowed = !wasFollowing;
      _followersCount =
          wasFollowing ? _followersCount - 1 : _followersCount + 1;
    });

    try {
      Map<String, dynamic>? response;

      if (wasFollowing) {
        response = await api<UserApiService>(
          (request) => request.unfollowUser(widget.user.id!),
        );
      } else {
        response = await api<UserApiService>(
          (request) => request.followUser(widget.user.id!),
        );
      }

      setState(() {
        _isLoadingFollow = false;
      });

      if (response != null && response['success'] == true) {
        // Update the widget.user object if needed
        widget.user.followersCount = _followersCount;

        showToast(
          title: "Success",
          description: response['message'] ??
              (wasFollowing ? "Unfollowed successfully" : "Following"),
          style: ToastNotificationStyleType.success,
        );
      } else {
        // Revert on failure
        setState(() {
          widget.user.isFollowed = wasFollowing;
          _followersCount = previousFollowersCount;
        });

        showToast(
          title: "Error",
          description: response?['message'] ??
              "Failed to ${wasFollowing ? 'unfollow' : 'follow'} user",
          style: ToastNotificationStyleType.danger,
        );
      }
    } catch (e) {
      print("❌ Error toggling follow status: $e");

      // Revert on error
      setState(() {
        _isLoadingFollow = false;
        widget.user.isFollowed = wasFollowing;
        _followersCount = previousFollowersCount;
      });

      showToast(
        title: "Error",
        description: "Network error. Please try again.",
        style: ToastNotificationStyleType.danger,
      );
    }
  }
}
