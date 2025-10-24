import 'package:flutter/material.dart';
import 'package:flutter_app/app/models/user.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:flutter_app/app/networking/post_api_service.dart'; // Assuming PostApiService is used for fetching posts
import '/config/app_colors.dart';
import '/app/models/post.dart';
import '/resources/widgets/smart_media_widget.dart'; // For video playback
import '/app/networking/user_api_service.dart'; // Import UserApiService

class OtherProfile extends NyStatefulWidget {
  final User user;

  OtherProfile({super.key, required this.user});

  @override
  createState() => _OtherProfileState();
}

class _OtherProfileState extends NyState<OtherProfile> {
  // Tab management
  int _selectedTabIndex = 0;
  int _refreshTrigger = 0;

  // For user's posts
  List<Post> _userPosts = [];
  List<Post> _likedPosts = [];
  List<Post> _savedPosts = [];
  bool _isFollowing = false; // New state to track following status

  @override
  get init => () async {
        print('👤 OtherProfile: Initializing with user: ${widget.user.id}');
        print('👤 OtherProfile: User name: ${widget.user.fullName}');
        print('👤 OtherProfile: User username: ${widget.user.username}');
        print(
            '👤 OtherProfile: User profile picture: ${widget.user.profilePicture}');
        print('👤 OtherProfile: User bio: ${widget.user.bio}');
        print('👤 OtherProfile: User posts count: ${widget.user.postsCount}');
        print(
            '👤 OtherProfile: User followers count: ${widget.user.followersCount}');
        print(
            '👤 OtherProfile: User following count: ${widget.user.followingCount}');

        // Check if current user is already following this user
        await _checkFollowStatus();
        await _loadUserPosts(1);
      };

  @override
  void dispose() {
    // Pause all videos when leaving the profile
    _pauseAllVideos();
    super.dispose();
  }

  /// Pause all videos in the profile
  void _pauseAllVideos() {
    // This will be handled by the SmartMediaWidget's own disposal
    // The SmartMediaWidget automatically pauses videos when disposed
  }

  /// Check if current user is following this user
  Future<void> _checkFollowStatus() async {
    if (widget.user.id == null) return;

    try {
      print(
          '👤 OtherProfile: Checking follow status for user ${widget.user.id}');

      // First check if the user object already has the isFollowed field
      if (widget.user.isFollowed != null) {
        print(
            '👤 OtherProfile: User object has isFollowed: ${widget.user.isFollowed}');
        setState(() {
          _isFollowing = widget.user.isFollowed!;
        });
        return;
      }

      // If not available in user object, make API call
      final userService = UserApiService();
      final isFollowing = await userService.isFollowingUser(widget.user.id!);

      print('👤 OtherProfile: API returned isFollowing: $isFollowing');

      setState(() {
        _isFollowing = isFollowing;
      });
    } catch (e) {
      print('❌ OtherProfile: Error checking follow status: $e');
      // Default to not following on error
      setState(() {
        _isFollowing = false;
      });
    }
  }

  Future<List<Post>> _loadUserPosts(int page,
      {bool forceRefresh = false}) async {
    try {
      print(
          '👤 OtherProfile: Loading user posts for user ID: ${widget.user.id}');

      final response = await api<PostApiService>(
        (request) => request.getFeed(
          page: page,
          perPage: 12,
          creators: [widget.user.id.toString()],
          forceRefresh: forceRefresh,
        ),
      );

      if (response != null && response['success'] == true) {
        final List<dynamic> postsData = response['data']['data'] ?? [];
        final List<Post> newPosts =
            postsData.map((json) => Post.fromJson(json)).toList();

        if (page == 1) {
          _userPosts = newPosts;
        } else {
          _userPosts.addAll(newPosts);
        }

        return newPosts;
      }
      return [];
    } catch (e) {
      print("Error loading user posts: $e");
      return [];
    }
  }

  Future<List<Post>> _loadLikedPosts(int page) async {
    try {
      print(
          '❤️ OtherProfile: Loading liked posts for user ID: ${widget.user.id}');

      // Based on API reference, we need to implement a specific endpoint for liked posts
      // For now, we'll use the general feed and filter client-side
      // TODO: Implement proper liked posts API endpoint
      final response = await api<PostApiService>(
        (request) => request.getFeed(
          page: page,
          perPage: 12,
        ),
      );

      if (response != null && response['success'] == true) {
        final List<dynamic> postsData = response['data']['data'] ?? [];
        // Filter posts that are liked by the current user
        final List<Post> allPosts =
            postsData.map((json) => Post.fromJson(json)).toList();
        final List<Post> likedPosts =
            allPosts.where((post) => post.isLiked == true).toList();

        if (page == 1) {
          _likedPosts = likedPosts;
        } else {
          _likedPosts.addAll(likedPosts);
        }

        return likedPosts;
      }
      return [];
    } catch (e) {
      print("Error loading liked posts: $e");
      return [];
    }
  }

  Future<List<Post>> _loadSavedPosts(int page) async {
    try {
      print(
          '📚 OtherProfile: Loading saved posts for user ID: ${widget.user.id}');

      // Based on API reference, we need to implement a specific endpoint for saved posts
      // For now, we'll use the general feed and filter client-side
      // TODO: Implement proper saved posts API endpoint
      final response = await api<PostApiService>(
        (request) => request.getFeed(
          page: page,
          perPage: 12,
        ),
      );

      if (response != null && response['success'] == true) {
        final List<dynamic> postsData = response['data']['data'] ?? [];
        // Filter posts that are saved by the current user
        final List<Post> allPosts =
            postsData.map((json) => Post.fromJson(json)).toList();
        final List<Post> savedPosts =
            allPosts.where((post) => post.isSaved == true).toList();

        if (page == 1) {
          _savedPosts = savedPosts;
        } else {
          _savedPosts.addAll(savedPosts);
        }

        return savedPosts;
      }
      return [];
    } catch (e) {
      print("Error loading saved posts: $e");
      return [];
    }
  }

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: NyPullToRefresh.grid(
                key: ValueKey(
                    'other_profile_${widget.user.id}_$_refreshTrigger'),
                stateName: _getStateNameForTab(),
                crossAxisCount: 3,
                mainAxisSpacing: 2,
                crossAxisSpacing: 2,
                padding: EdgeInsets.zero,
                header: _buildProfileHeader(),
                child: (context, post) => _buildPostItem(post as Post),
                data: (int iteration) async {
                  print(
                      '👤 OtherProfile: Loading posts - tab: $_selectedTabIndex, page: $iteration');

                  switch (_selectedTabIndex) {
                    case 0:
                      return await _loadUserPosts(iteration,
                          forceRefresh: true);
                    case 1:
                      return await _loadLikedPosts(iteration);
                    case 2:
                      return await _loadSavedPosts(iteration);
                    default:
                      return [];
                  }
                },
                empty: _buildEmptyState(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getStateNameForTab() {
    switch (_selectedTabIndex) {
      case 0:
        return 'other_user_posts_${widget.user.id}_$_refreshTrigger';
      case 1:
        return 'other_liked_posts_${widget.user.id}_$_refreshTrigger';
      case 2:
        return 'other_saved_posts_${widget.user.id}_$_refreshTrigger';
      default:
        return 'other_user_posts_${widget.user.id}_$_refreshTrigger';
    }
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const Icon(Icons.arrow_back,
                size: 24, color: AppColors.textPrimary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              widget.user.username ?? 'Profile',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _toggleFollow,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _isFollowing
                    ? AppColors.buttonSecondary
                    : AppColors.buttonPrimary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _isFollowing ? 'FOLLOWING' : 'FOLLOW',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _isFollowing ? AppColors.textPrimary : Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        const SizedBox(height: 20),
        _buildProfilePicture(),
        const SizedBox(height: 20),
        _buildNameAndBio(),
        const SizedBox(height: 30),
        _buildUserStats(),
        const SizedBox(height: 30),
        _buildTabBar(),
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
        gradient: AppColors.profileGradient,
      ),
      child: Container(
        margin: const EdgeInsets.all(3),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.backgroundPrimary,
        ),
        child: ClipOval(
          child: widget.user.profilePicture != null
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
              : Icon(Icons.person, size: 60, color: Colors.grey[400]),
        ),
      ),
    );
  }

  Widget _buildNameAndBio() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Text(
            widget.user.fullName ?? 'Unknown User',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '@${widget.user.username ?? ''}',
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          if (widget.user.bio != null && widget.user.bio!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              widget.user.bio!,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUserStats() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Posts', _userPosts.length),
          _buildStatItem('Followers', widget.user.followersCount ?? 0),
          _buildStatItem('Following', widget.user.followingCount ?? 0),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    final tabs = [
      {'icon': Icons.grid_on, 'title': 'Posts'},
      {'icon': Icons.favorite, 'title': 'Liked'},
      {'icon': Icons.bookmark_border, 'title': 'Saved'},
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: tabs.asMap().entries.map((entry) {
          int index = entry.key;
          Map<String, dynamic> tab = entry.value;
          bool isSelected = _selectedTabIndex == index;

          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTabIndex = index;
                  _refreshTrigger++;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color:
                          isSelected ? AppColors.tabActive : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      tab['icon'],
                      color: isSelected
                          ? AppColors.tabActive
                          : AppColors.tabInactive,
                      size: 24,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tab['title'],
                      style: TextStyle(
                        color: isSelected
                            ? AppColors.tabActive
                            : AppColors.tabInactive,
                        fontSize: 12,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStatItem(String label, int count) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Future<void> _toggleFollow() async {
    if (widget.user.id == null) return;

    final bool wasFollowing = _isFollowing;
    int currentFollowersCount = widget.user.followersCount ?? 0;

    // Optimistic UI update
    setState(() {
      _isFollowing = !wasFollowing;
      widget.user.isFollowed =
          !wasFollowing; // Update user object's isFollowed field
      if (wasFollowing) {
        widget.user.followersCount = currentFollowersCount - 1;
      } else {
        widget.user.followersCount = currentFollowersCount + 1;
      }
    });

    try {
      Map<String, dynamic>? response;
      if (wasFollowing) {
        // Use DELETE /api/users/{id}/unfollow
        response = await api<UserApiService>(
            (request) => request.delete("/users/${widget.user.id}/unfollow"));
      } else {
        // Use POST /api/users/{id}/follow
        response = await api<UserApiService>(
            (request) => request.post("/users/${widget.user.id}/follow"));
      }

      if (response != null && response['success'] == true) {
        showToast(
          title: "Success",
          description: response['message'] ??
              (wasFollowing ? "Unfollowed user" : "Followed user"),
        );
        // No need to update state here as optimistic update already happened
      } else {
        // Revert UI on API failure
        setState(() {
          _isFollowing = wasFollowing;
          widget.user.isFollowed = wasFollowing; // Revert isFollowed field
          widget.user.followersCount = currentFollowersCount; // Revert count
        });
        showToast(
          title: "Error",
          description: response?['message'] ??
              "Failed to ${wasFollowing ? 'unfollow' : 'follow'} user.",
          style: ToastNotificationStyleType.danger,
        );
      }
    } catch (e) {
      print("Error toggling follow status: $e");
      // Revert UI on error
      setState(() {
        _isFollowing = wasFollowing;
        widget.user.isFollowed = wasFollowing; // Revert isFollowed field
        widget.user.followersCount = currentFollowersCount; // Revert count
      });
      showToast(
        title: "Error",
        description: "Network error. Please try again.",
        style: ToastNotificationStyleType.danger,
      );
    }
  }

  Widget _buildPostItem(Post post) {
    return AspectRatio(
      aspectRatio: 1.0, // Square items
      child: GestureDetector(
        onTap: () => _showPostDetail(post),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(4),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: post.mediaUrl != null
                ? SmartMediaWidget(
                    post: post,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  )
                : Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      gradient: LinearGradient(
                        colors: [Colors.blue[200]!, Colors.green[200]!],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child:
                        const Icon(Icons.image, color: Colors.white, size: 30),
                  ),
          ),
        ),
      ),
    );
  }

  void _showPostDetail(Post post) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Close button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Post Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      children: [
                        // Media
                        if (post.mediaUrl != null)
                          Container(
                            width: double.infinity,
                            height: 300,
                            child: SmartMediaWidget(
                              post: post,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: 300,
                            ),
                          ),

                        // Post details
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // User info
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundImage:
                                        post.user?.profilePicture != null
                                            ? NetworkImage(
                                                post.user!.profilePicture!)
                                            : null,
                                    backgroundColor: AppColors.buttonPrimary,
                                    child: post.user?.profilePicture == null
                                        ? Text(
                                            post.user?.fullName
                                                    ?.substring(0, 1)
                                                    .toUpperCase() ??
                                                'U',
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold),
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          post.user?.fullName ?? 'Unknown User',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          '@${post.user?.username ?? 'unknown'}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Follow button
                                  ElevatedButton(
                                    onPressed: () {
                                      // Handle follow/unfollow
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.buttonPrimary,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                    child: const Text('Follow'),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 16),

                              // Caption
                              if (post.caption != null &&
                                  post.caption!.isNotEmpty)
                                Text(
                                  post.caption!,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    height: 1.5,
                                  ),
                                ),

                              const SizedBox(height: 16),

                              // Stats
                              Row(
                                children: [
                                  _buildPostStatItem(
                                      Icons.favorite, post.likesCount ?? 0),
                                  const SizedBox(width: 24),
                                  _buildPostStatItem(
                                      Icons.bookmark, post.savesCount ?? 0),
                                  const SizedBox(width: 24),
                                  _buildPostStatItem(
                                      Icons.comment, post.commentsCount ?? 0),
                                  const SizedBox(width: 24),
                                  _buildPostStatItem(Icons.share,
                                      0), // Post model doesn't have sharesCount
                                ],
                              ),

                              const SizedBox(height: 16),

                              // Actions
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      post.isLiked == true
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: post.isLiked == true
                                          ? Colors.red
                                          : Colors.grey[600],
                                    ),
                                    onPressed: () {
                                      // Handle like
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      post.isSaved == true
                                          ? Icons.bookmark
                                          : Icons.bookmark_border,
                                      color: post.isSaved == true
                                          ? Colors.blue
                                          : Colors.grey[600],
                                    ),
                                    onPressed: () {
                                      // Handle save
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.comment_outlined,
                                        color: Colors.grey[600]),
                                    onPressed: () {
                                      // Handle comment
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.share_outlined,
                                        color: Colors.grey[600]),
                                    onPressed: () {
                                      // Handle share
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPostStatItem(IconData icon, int count) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    String message;
    String description;
    IconData icon;

    switch (_selectedTabIndex) {
      case 0:
        message = 'No posts yet';
        description = 'This user hasn\'t shared anything yet!';
        icon = Icons.add_photo_alternate;
        break;
      case 1:
        message = 'No liked posts';
        description = 'This user hasn\'t liked any posts yet!';
        icon = Icons.favorite_border;
        break;
      case 2:
        message = 'No saved posts';
        description = 'This user hasn\'t saved any posts yet!';
        icon = Icons.bookmark_border;
        break;
      default:
        message = 'No content';
        description = 'No content available';
        icon = Icons.inbox;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: AppColors.textTertiary),
            const SizedBox(height: 16),
            Text(
              message,
              style:
                  const TextStyle(fontSize: 18, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(color: AppColors.textTertiary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
