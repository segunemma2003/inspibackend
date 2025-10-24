import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '/app/models/user.dart';
import '/app/models/post.dart';
import '/app/networking/user_api_service.dart';
import '/app/networking/post_api_service.dart';
import '/resources/widgets/smart_media_widget.dart';

class UserProfilePage extends NyStatefulWidget {
  static RouteView path = ('/user-profile', (context) => UserProfilePage());

  UserProfilePage({super.key}) : super(child: () => _UserProfilePageState());

  @override
  createState() => _UserProfilePageState();
}

class _UserProfilePageState extends NyPage<UserProfilePage> {
  User? _userProfile;
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;
  int? _userId;

  // Posts and follow functionality
  List<Post> _userPosts = [];
  bool _isLoadingFollow = false;
  int _followersCount = 0;

  // Tab functionality
  int _selectedTabIndex = 0;
  int _refreshTrigger = 0;

  @override
  get init => () async {
        // print('👤 UserProfilePage: Initializing...');

        // Get userId from route data
        final routeData = widget.data();
        // print('👤 UserProfilePage: Route data: $routeData');

        if (routeData != null && routeData is Map) {
          _userId = routeData['userId'];
        }

        // print('👤 UserProfilePage: Retrieved userId: $_userId');

        if (_userId == null) {
          // print('❌ UserProfilePage: User ID is null');
          setState(() {
            _hasError = true;
            _errorMessage = 'User ID not provided';
            _isLoading = false;
          });
          showToast(
            title: "Error",
            description: "User ID not provided",
            style: ToastNotificationStyleType.danger,
          );
          return;
        }

        await _loadUserProfile();
        if (_userProfile != null) {
          await _loadUserPosts(1);
        }
      };

  @override
  void dispose() {
    // Pause all videos when leaving the page
    SmartMediaWidget.pauseAllVideos();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    if (_userId == null) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Invalid user ID';
        _isLoading = false;
      });
      return;
    }

    // print('👤 UserProfilePage: Loading user profile for ID: $_userId');

    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
    });

    try {
      // print('👤 UserProfilePage: Calling getUser API...');

      final userResponse = await api<UserApiService>(
        (request) => request.getUser(_userId!),
      );

      // print('👤 UserProfilePage: API response received');
      // print('👤 UserProfilePage: Response type: ${userResponse.runtimeType}');

      if (userResponse != null) {
        // print(
        //     '👤 UserProfilePage: User profile loaded: ${userResponse.username}');
        // print('👤 UserProfilePage: User ID: ${userResponse.id}');
        // print(
        //     '👤 UserProfilePage: User posts count: ${userResponse.postsCount}');
        // print(
        //     '👤 UserProfilePage: User followers: ${userResponse.followersCount}');
        // print(
        //     '👤 UserProfilePage: User following: ${userResponse.followingCount}');

        setState(() {
          _userProfile = userResponse;
          _isLoading = false;
          _hasError = false;
          _followersCount = userResponse.followersCount ?? 0;
        });
      } else {
        // print('❌ UserProfilePage: User profile is null');
        setState(() {
          _hasError = true;
          _errorMessage = 'User not found';
          _isLoading = false;
        });

        showToast(
          title: "Error",
          description: "User not found",
          style: ToastNotificationStyleType.danger,
        );
      }
    } catch (e, stackTrace) {
      print("❌ UserProfilePage: Error loading user profile: $e");
      print("❌ UserProfilePage: Stack trace: $stackTrace");

      setState(() {
        _hasError = true;
        _errorMessage = 'Failed to load profile';
        _isLoading = false;
      });

      showToast(
        title: "Error",
        description: "Failed to load user profile. Please try again.",
        style: ToastNotificationStyleType.danger,
      );
    }
  }

  Future<List<Post>> _loadUserPosts(int page,
      {bool forceRefresh = false}) async {
    if (_userProfile?.id == null) {
      print('❌ UserProfilePage: Cannot load user posts - user ID is null');
      return [];
    }

    print(
        '📱 UserProfilePage: Loading user posts for user ${_userProfile!.id} (page: $page)');

    try {
      final response = await api<PostApiService>(
        (request) => request.getPostsByUser(
          userId: _userProfile!.id!,
          page: page,
          perPage: 12,
          forceRefresh: forceRefresh,
        ),
      );

      print('📱 UserProfilePage: API response received');

      if (response != null && response['success'] == true) {
        final data = response['data'];
        final List<dynamic> postsData = data['data'] ?? [];
        final List<Post> newPosts =
            postsData.map((json) => Post.fromJson(json)).toList();

        print('📱 UserProfilePage: Loaded ${newPosts.length} posts');

        setState(() {
          if (page == 1) {
            _userPosts = newPosts;
          } else {
            _userPosts.addAll(newPosts);
          }
        });

        return newPosts;
      } else {
        print(
            "❌ UserProfilePage: Error loading user posts: ${response?['message']}");
        return [];
      }
    } catch (e) {
      print("❌ UserProfilePage: Error loading user posts: $e");
      return [];
    }
  }

  Future<List<Post>> _loadLikedPosts(int page) async {
    if (_userProfile?.id == null) {
      print('❌ UserProfilePage: Cannot load liked posts - user ID is null');
      return [];
    }

    try {
      print(
          '❤️ UserProfilePage: Loading liked posts for user ${_userProfile!.id} (page: $page)');

      final response = await api<PostApiService>(
        (request) => request.getUserLikedPosts(
          userId: _userProfile!.id!,
          page: page,
          perPage: 20,
        ),
      );

      if (response != null && response['success'] == true) {
        final List<dynamic> postsData = response['data']['data'] ?? [];
        final List<Post> posts =
            postsData.map((json) => Post.fromJson(json)).toList();

        print('❤️ UserProfilePage: Loaded ${posts.length} liked posts');
        return posts;
      } else {
        print(
            "❌ UserProfilePage: Error loading liked posts: ${response?['message']}");
        return [];
      }
    } catch (e) {
      print("❌ UserProfilePage: Error loading liked posts: $e");
      return [];
    }
  }

  Future<List<Post>> _loadSavedPosts(int page) async {
    if (_userProfile?.id == null) {
      print('❌ UserProfilePage: Cannot load saved posts - user ID is null');
      return [];
    }

    try {
      print(
          '📚 UserProfilePage: Loading saved posts for user ${_userProfile!.id} (page: $page)');

      final response = await api<PostApiService>(
        (request) => request.getUserSavedPosts(
          userId: _userProfile!.id!,
          page: page,
          perPage: 20,
        ),
      );

      if (response != null && response['success'] == true) {
        final List<dynamic> postsData = response['data']['data'] ?? [];
        final List<Post> posts =
            postsData.map((json) => Post.fromJson(json)).toList();

        print('📚 UserProfilePage: Loaded ${posts.length} saved posts');
        return posts;
      } else {
        print(
            "❌ UserProfilePage: Error loading saved posts: ${response?['message']}");
        return [];
      }
    } catch (e) {
      print("❌ UserProfilePage: Error loading saved posts: $e");
      return [];
    }
  }

  String _getStateNameForTab() {
    switch (_selectedTabIndex) {
      case 0:
        return 'user_posts_$_refreshTrigger';
      case 1:
        return 'liked_posts_$_refreshTrigger';
      case 2:
        return 'saved_posts_$_refreshTrigger';
      default:
        return 'posts_$_refreshTrigger';
    }
  }

  Future<void> _toggleFollow() async {
    if (_userProfile?.id == null) {
      showToast(
        title: "Error",
        description: "Unable to follow user",
        style: ToastNotificationStyleType.danger,
      );
      return;
    }

    final bool wasFollowing = _userProfile?.isFollowed ?? false;
    final int previousFollowersCount = _followersCount;

    // Optimistic UI update
    setState(() {
      _isLoadingFollow = true;
      _userProfile!.isFollowed = !wasFollowing;
      _followersCount =
          wasFollowing ? _followersCount - 1 : _followersCount + 1;
    });

    try {
      Map<String, dynamic>? response;

      if (wasFollowing) {
        response = await api<UserApiService>(
          (request) => request.unfollowUser(_userProfile!.id!),
        );
      } else {
        response = await api<UserApiService>(
          (request) => request.followUser(_userProfile!.id!),
        );
      }

      setState(() {
        _isLoadingFollow = false;
      });

      if (response != null && response['success'] == true) {
        showToast(
          title: "Success",
          description: response['message'] ??
              (wasFollowing ? "Unfollowed successfully" : "Following"),
          style: ToastNotificationStyleType.success,
        );
      } else {
        // Revert on failure
        setState(() {
          _userProfile!.isFollowed = wasFollowing;
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
        _userProfile!.isFollowed = wasFollowing;
        _followersCount = previousFollowersCount;
      });

      showToast(
        title: "Error",
        description: "Network error. Please try again.",
        style: ToastNotificationStyleType.danger,
      );
    }
  }

  @override
  Widget view(BuildContext context) {
    print('👤 UserProfilePage: Building view');
    print('👤 UserProfilePage: Loading: $_isLoading, HasError: $_hasError');
    print('👤 UserProfilePage: User profile: ${_userProfile?.username}');

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context),
            Expanded(
              child: _buildBody(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingState(context);
    }

    if (_hasError) {
      return _buildErrorState(context);
    }

    if (_userProfile == null) {
      return _buildNotFoundState(context);
    }

    print('👤 UserProfilePage: Rendering profile content');
    return _buildProfileContent(context);
  }

  Widget _buildLoadingState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Loading profile...',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red[300],
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Unable to Load Profile',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Something went wrong',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadUserProfile,
              icon: Icon(Icons.refresh),
              label: Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotFoundState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person_off_outlined,
                size: 48,
                color: Colors.grey[400],
              ),
            ),
            SizedBox(height: 20),
            Text(
              'User Not Found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'This user may have been deleted or does not exist',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: Icon(Icons.arrow_back),
              label: Text('Go Back'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black87,
                side: BorderSide(color: Colors.grey[300]!),
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              _userProfile?.username ?? 'Profile',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
          if (_userProfile != null) _buildFollowButton(context),
        ],
      ),
    );
  }

  Widget _buildFollowButton(BuildContext context) {
    return GestureDetector(
      onTap: _isLoadingFollow ? null : _toggleFollow,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: (_userProfile?.isFollowed ?? false)
              ? Colors.grey[200]
              : Theme.of(context).colorScheme.primary,
          border: Border.all(
            color: (_userProfile?.isFollowed ?? false)
                ? Colors.grey[300]!
                : Colors.transparent,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: _isLoadingFollow
            ? SizedBox(
                height: 16,
                width: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    (_userProfile?.isFollowed ?? false)
                        ? Colors.black54
                        : Colors.white,
                  ),
                ),
              )
            : Text(
                (_userProfile?.isFollowed ?? false) ? 'Following' : 'Follow',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: (_userProfile?.isFollowed ?? false)
                      ? Colors.black87
                      : Colors.white,
                ),
              ),
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context) {
    return Column(
      children: [
        _buildProfileHeader(context),
        Expanded(
          child: NyPullToRefresh.grid(
            key: ValueKey(_getStateNameForTab()),
            stateName: _getStateNameForTab(),
            crossAxisCount: 3,
            mainAxisSpacing: 2,
            crossAxisSpacing: 2,
            padding: EdgeInsets.zero,
            child: (context, post) => _buildPostItem(post as Post),
            data: (int iteration) async {
              print(
                  '📱 UserProfilePage: Loading posts - tab: $_selectedTabIndex, iteration: $iteration');

              switch (_selectedTabIndex) {
                case 0:
                  return await _loadUserPosts(iteration, forceRefresh: true);
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
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
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
          child: _userProfile?.profilePicture != null &&
                  _userProfile!.profilePicture!.isNotEmpty
              ? Image.network(
                  _userProfile!.profilePicture!,
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _userProfile?.fullName ?? _userProfile?.name ?? 'Unknown User',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '@${_userProfile?.username ?? 'unknown'}',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          Text(
            _userProfile?.bio ?? 'No bio available',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
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
          _buildStatItem(
              'Posts', _userProfile?.postsCount ?? _userPosts.length),
          _buildStatItem('Followers', _followersCount),
          _buildStatItem('Following', _userProfile?.followingCount ?? 0),
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
                      color: isSelected ? Colors.black : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Icon(
                  tab['icon'] as IconData,
                  color: isSelected ? Colors.black : Colors.grey[400],
                  size: 24,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
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
    String message;
    String description;
    IconData icon;

    switch (_selectedTabIndex) {
      case 0:
        message = 'No posts yet';
        description =
            'When ${_userProfile?.username ?? 'this user'} shares photos and videos, you\'ll see them here.';
        icon = Icons.add_photo_alternate;
        break;
      case 1:
        message = 'No liked posts';
        description =
            '${_userProfile?.username ?? 'This user'} hasn\'t liked any posts yet.';
        icon = Icons.favorite_border;
        break;
      case 2:
        message = 'No saved posts';
        description =
            '${_userProfile?.username ?? 'This user'} hasn\'t saved any posts yet.';
        icon = Icons.bookmark_border;
        break;
      default:
        message = 'No content';
        description = 'Nothing to show here';
        icon = Icons.inbox;
    }

    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showPostDetail(Post post) {
    print(
        '📱 UserProfilePage: Showing post detail for post ${post.id}, mediaType: ${post.mediaType}');
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

                const Divider(),

                // Content
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
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
                                backgroundImage: post.user?.profilePicture !=
                                        null
                                    ? NetworkImage(post.user!.profilePicture!)
                                    : null,
                                backgroundColor: const Color(0xFF9ACD32),
                                child: post.user?.profilePicture == null
                                    ? Text(
                                        post.user?.name
                                                ?.substring(0, 1)
                                                .toUpperCase() ??
                                            'U',
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
                              // Category tag
                              if (post.category != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFF69B4),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    post.category!.name ?? '',
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

                        // Media
                        if (post.mediaUrl != null)
                          Container(
                            width: double.infinity,
                            height: 400,
                            child: post.mediaType == 'video'
                                ? SmartMediaWidget(
                                    post: post,
                                  )
                                : Image.network(
                                    post.mediaUrl!,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.grey[200],
                                        child:
                                            const Icon(Icons.image, size: 50),
                                      );
                                    },
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

                        // Location
                        if (post.location != null && post.location!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: Row(
                              children: [
                                Icon(Icons.location_on,
                                    size: 16, color: Colors.grey[600]),
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

                        // Stats
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Icon(Icons.favorite, size: 16, color: Colors.red),
                              const SizedBox(width: 4),
                              Text(
                                '${post.likesCount ?? 0} likes',
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(width: 16),
                              Icon(Icons.bookmark,
                                  size: 16, color: Colors.blue),
                              const SizedBox(width: 4),
                              Text(
                                '${post.savesCount ?? 0} saves',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    ).then((_) {
      // Pause videos when modal is dismissed
      SmartMediaWidget.pauseAllVideos();
    });
  }
}
