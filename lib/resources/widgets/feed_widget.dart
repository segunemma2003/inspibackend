import 'package:flutter/material.dart';
import 'package:flutter_app/resources/pages/user_profile_page.dart';
import 'package:nylo_framework/metro/ny_cli.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:share_plus/share_plus.dart'; // Import for sharing functionality
import '/app/models/post.dart';
import '/app/models/category.dart';
import '/app/networking/post_api_service.dart';
import '/app/networking/category_api_service.dart';
import '/app/networking/auth_api_service.dart';
import '/app/services/auth_service.dart';
import '/config/cache.dart';
import '/resources/widgets/smart_media_widget.dart';
import '/resources/widgets/tagged_users_widget.dart';
import 'package:video_player/video_player.dart'; // Import VideoPlayerController

class Feed extends StatefulWidget {
  const Feed({super.key});

  @override
  createState() => _FeedState();
}

class _FeedState extends NyState<Feed> {
  List<Category> _categories = [];
  String _selectedCategory = 'ALL';
  int _refreshTrigger = 0;
  final TextEditingController _searchController =
      TextEditingController(); // Controller for search input
  String _searchQuery = ''; // State for search query

  // Store posts locally for immediate UI updates
  Map<int, Post> _postsCache = {};
  // Map to store active video controllers
  final Map<int, VideoPlayerController?> _activeVideoControllers = {};
  // Map to store SmartMediaWidget keys for direct access
  // final Map<int, GlobalKey> _smartMediaKeys = {};

  // Current user ID for profile click prevention
  int? _currentUserId;

  // Pagination state
  bool _hasMorePages = true;
  int _currentPage = 1;
  int _lastPage = 1;

  @override
  void dispose() {
    // Pause all videos globally using SmartMediaWidget
    print('🎥 Feed: Disposing feed widget, pausing all videos globally');
    SmartMediaWidget.pauseAllVideos();

    // Also pause and dispose local video controllers
    _activeVideoControllers.values.forEach((controller) {
      if (controller != null) {
        controller.pause();
        controller.dispose();
      }
    });
    _activeVideoControllers.clear();
    _searchController.dispose(); // Dispose search controller
    super.dispose();
  }

  @override
  get init => () async {
        print('📱 Feed: Initializing feed widget...');
        await _loadInitialData();
      };

  // Method to pause all videos when leaving the feed
  void pauseAllVideos() {
    print(
        '🎥 Feed: pauseAllVideos called, controllers: ${_activeVideoControllers.length}');
    _activeVideoControllers.values.forEach((controller) {
      if (controller != null && controller.value.isPlaying) {
        print('🎥 Feed: Pausing video controller');
        controller.pause();
      }
    });
  }

  // Override didChangeDependencies to pause videos when widget becomes inactive
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Pause videos when navigating away
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        print('🎥 Feed: Widget not mounted, pausing all videos');
        forcePauseAllVideos();
      }
    });
  }

  // Method to force pause all videos and clear controllers
  void forcePauseAllVideos() {
    print('🎥 Feed: forcePauseAllVideos called');
    // Use global video pausing from SmartMediaWidget
    SmartMediaWidget.pauseAllVideos();

    // Also pause and dispose local video controllers
    _activeVideoControllers.values.forEach((controller) {
      if (controller != null) {
        print(
            '🎥 Feed: Force pausing video controller: ${controller.hashCode}');
        controller.pause();
        controller.dispose();
      }
    });
    _activeVideoControllers.clear();
  }

  Future<void> _loadInitialData() async {
    try {
      print('📱 Feed: Starting _loadInitialData...');

      final currentUserResponse = await api<AuthApiService>(
        (request) => request.getCurrentUser(),
        cacheKey: CacheConfig.currentUserKey,
        cacheDuration: CacheConfig.userProfileCache,
      );

      print('👤 Feed: Current user response: $currentUserResponse');

      // Store current user ID for profile click prevention
      if (currentUserResponse != null) {
        final userData = currentUserResponse;
        if (userData != null && userData.id != null) {
          _currentUserId = userData.id;
          print('👤 Feed: Current user ID stored: $_currentUserId');
        }
      }

      print('📱 Feed: About to load categories...');
      await _loadCategories();
      print('📱 Feed: Categories loaded, now loading feed posts...');
      await _loadFeedPosts(1,
          forceRefresh: true); // Load initial feed posts with force refresh
    } catch (e) {
      print('❌ Feed: Error in _loadInitialData: $e');

      // Check if it's an authentication error
      if (e.toString().contains('401') ||
          e.toString().contains('Unauthorized')) {
        print(
            '🔑 Feed: Authentication error in initial data load, checking token validity...');

        // Check if token is expired
        final isExpired = await AuthService.instance.isTokenExpired();
        if (isExpired) {
          print(
              '🔑 Feed: Token is expired during initial load, logging out user...');
          showToast(
            title: 'Session Expired',
            description: 'Please sign in again',
            style: ToastNotificationStyleType.warning,
          );

          // Logout and redirect to sign in
          await AuthService.instance.logout();
          routeTo('/sign-in');
          return;
        }
      }

      showToast(title: 'Error', description: 'Failed to load data: $e');
    }
  }

  Future<void> _loadCategories() async {
    try {
      print('📱 Feed: Starting to load categories...');
      final categories = await api<CategoryApiService>(
        (request) => request.getCategories(),
        cacheKey: CacheConfig.categoriesKey,
        cacheDuration: CacheConfig.categoriesCache,
      );

      print('📱 Feed: Categories API response: $categories');

      if (categories != null) {
        print('📱 Feed: Loaded ${categories.length} categories');
        setState(() {
          _categories = categories;
        });
      } else {
        print('📱 Feed: Categories response is null');
      }
    } catch (e) {
      print('📱 Feed: Error loading categories: $e');
      showToast(title: 'Error', description: 'Failed to load categories: $e');
    }
  }

  Future<List<Post>> _loadFeedPosts(int page,
      {bool forceRefresh = false}) async {
    try {
      print(
          '📱 Feed: Loading posts (page: $page, category: $_selectedCategory, forceRefresh: $forceRefresh, query: $_searchQuery)');

      // Check if we've already reached the last page
      if (page > _lastPage && _lastPage > 0) {
        print(
            '📱 Feed: Already at last page ($_lastPage), returning empty list');
        return [];
      }

      List<String>? categoryFilter;

      if (_selectedCategory != 'ALL') {
        Category? selectedCat = _categories.firstWhereOrNull(
          (cat) => cat.name?.trim() == _selectedCategory.trim(),
        );

        if (selectedCat?.id != null) {
          categoryFilter = [selectedCat!.id.toString()];
          print(
              '📱 Feed: Filtering by category: ${selectedCat.name} (ID: ${selectedCat.id})');
        } else {
          print('⚠️ Feed: Selected category not found in categories list');
        }
      }

      final feedResponse = await api<PostApiService>(
        (request) => request.getFeed(
          perPage: 20,
          page: page,
          categories: categoryFilter,
          search: _searchQuery.isNotEmpty
              ? _searchQuery
              : null, // Pass search query
          forceRefresh: forceRefresh, // Pass forceRefresh here
        ),
      );

      if (feedResponse != null && feedResponse['success'] == true) {
        final List<dynamic> postsData = feedResponse['data']['data'] ?? [];
        final List<Post> posts =
            postsData.map((json) => Post.fromJson(json)).toList();

        // Cache posts for immediate UI updates
        for (var post in posts) {
          if (post.id != null) {
            _postsCache[post.id!] = post;
          }
        }

        // Update pagination state
        _currentPage = feedResponse['data']['current_page'] ?? page;
        _lastPage = feedResponse['data']['last_page'] ?? 1;
        _hasMorePages = _currentPage < _lastPage;

        print(
            '📱 Feed: Loaded ${posts.length} posts (page $_currentPage of $_lastPage)');
        print('📱 Feed: Has more pages: $_hasMorePages');

        // Return empty list if no posts to stop pagination
        if (posts.isEmpty) {
          print('📱 Feed: No posts found, stopping pagination');
          _hasMorePages = false;
        }

        return posts;
      } else {
        print('⚠️ Feed: Response not successful or null');
        throw Exception('Failed to load feed posts');
      }
    } catch (e) {
      print('❌ Feed: Error loading posts: $e');

      // Check if it's an authentication error
      if (e.toString().contains('401') ||
          e.toString().contains('Unauthorized')) {
        print(
            '🔑 Feed: Authentication error detected, checking token validity...');

        // Check if token is expired
        final isExpired = await AuthService.instance.isTokenExpired();
        if (isExpired) {
          print('🔑 Feed: Token is expired, logging out user...');
          showToast(
            title: 'Session Expired',
            description: 'Please sign in again',
            style: ToastNotificationStyleType.warning,
          );

          // Logout and redirect to sign in
          await AuthService.instance.logout();
          routeTo('/sign-in');
          return [];
        }
      }

      showToast(title: 'Error', description: 'Failed to load posts: $e');
      return [];
    }
  }

  void _onCategorySelected(String category) {
    print('📱 Feed: Category selected: $category');
    if (_selectedCategory != category) {
      setState(() {
        _selectedCategory = category;
        _refreshTrigger++;
        _postsCache.clear(); // Clear cache when changing category

        // Reset pagination state
        _hasMorePages = true;
        _currentPage = 1;
        _lastPage = 1;
      });
      print('📱 Feed: Refresh trigger updated to $_refreshTrigger');
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _refreshTrigger++; // Trigger refresh for search results
      _postsCache.clear();
      _hasMorePages = true;
      _currentPage = 1;
      _lastPage = 1;
    });
  }

  @override
  Widget view(BuildContext context) {
    print('📱 Feed: Building feed widget view...');
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeaderSection(),
          _buildSearchBar(), // Add search bar here
          _buildCategorySection(),
          Expanded(
            child: NyPullToRefresh.grid(
              key: ValueKey('feed_list_$_refreshTrigger'),
              stateName: 'feed_list_$_refreshTrigger',
              crossAxisCount: 1,
              child: (context, post) => _buildPostCard(post as Post),
              data: (int iteration) async {
                print('📱 Feed: NyPullToRefresh iteration: $iteration');
                return await _loadFeedPosts(iteration,
                    forceRefresh: true); // Force refresh on pull-to-refresh
              },
              empty: _buildEmptyState(),
              // These properties control when to load more
              transform: (data) => data, // Pass through the data as-is
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: EdgeInsets.only(
          top: 50, bottom: 0), // Adjust padding to accommodate search bar
      child: Column(
        children: [
          Image.asset(
            'logo.png',
            width: 80,
            height: 80,
            fit: BoxFit.contain,
          ).localAsset(),
          const SizedBox(height: 10),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'insp',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFFF69B4),
                    letterSpacing: -0.5,
                  ),
                ),
                TextSpan(
                  text: 'i',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFFFD700),
                    letterSpacing: -0.5,
                  ),
                ),
                TextSpan(
                  text: 'rtag',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF00BFFF),
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Search posts...',
          prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary, width: 1.5),
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
        ),
      ),
    );
  }

  Widget _buildCategorySection() {
    print(
        '📱 Feed: Building category section with ${_categories.length} categories');
    final allCategories = [
      'ALL',
      ..._categories
          .map((cat) => cat.name ?? '')
          .where((name) => name.isNotEmpty)
    ];
    print('📱 Feed: All categories: $allCategories');

    // Define the specific colors for categories
    final categoryColors = [
      Color(0xFF00C3F1), // #00C3F1
      Color(0xFFFD4CC0), // #FD4CC0
      Color(0xFFFFCF02), // #FFCF02
      Color(0xFFB5DA64), // #B5DA64
    ];

    return Container(
      height: 50,
      margin: EdgeInsets.only(bottom: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16),
        itemCount: allCategories.length,
        itemBuilder: (context, index) {
          final category = allCategories[index];
          final isSelected = _selectedCategory == category;

          // Get color for this category (cycle through colors)
          final categoryColor = categoryColors[index % categoryColors.length];

          return Padding(
            padding: EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) => _onCategorySelected(category),
              backgroundColor: isSelected ? categoryColor : Colors.grey[100],
              selectedColor: categoryColor,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: isSelected
                    ? BorderSide.none
                    : BorderSide(
                        color: categoryColor.withOpacity(0.3), width: 1),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.photo_library_outlined, size: 80, color: Colors.grey[300]),
          SizedBox(height: 16),
          Text('No posts yet',
              style: TextStyle(fontSize: 18, color: Colors.grey[600])),
          SizedBox(height: 8),
          Text('Be the first to share something!',
              style: TextStyle(color: Colors.grey[500])),
        ],
      ),
    );
  }

  Widget _buildPostCard(Post post) {
    // Use cached version if available (for optimistic updates)
    final displayPost = _postsCache[post.id] ?? post;

    return Container(
      margin: EdgeInsets.only(bottom: 20), // Remove left and right padding
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User info header
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                InkWell(
                  onTap: () {
                    print(
                        '👤 Tapping on user profile: ${displayPost.user?.id}');

                    // Check if this is the current user's own post
                    if (displayPost.user?.id != null &&
                        _currentUserId != null &&
                        displayPost.user!.id == _currentUserId) {
                      print(
                          '👤 This is your own post, not navigating to profile');
                      showToast(
                          title: "Profile",
                          description: "This is your own post!");
                      return;
                    }

                    if (displayPost.user?.id != null) {
                      print(
                          '👤 Navigating to user profile with ID: ${displayPost.user!.id}');
                      // Force pause all videos before navigation using global method
                      print(
                          '🎥 Feed: Force pausing all videos before navigation');
                      SmartMediaWidget.pauseAllVideos();
                      routeTo(UserProfilePage.path,
                          data: {'userId': displayPost.user!.id});
                    } else {
                      print('❌ User ID is null, cannot navigate to profile');
                    }
                  },
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundImage: displayPost.user?.profilePicture !=
                                null
                            ? NetworkImage(displayPost.user!.profilePicture!)
                            : null,
                        backgroundColor: Color(0xFF9ACD32),
                        child: displayPost.user?.profilePicture == null
                            ? Text(
                                displayPost.user?.fullName
                                        ?.substring(0, 1)
                                        .toUpperCase() ??
                                    'U',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14),
                              )
                            : null,
                      ),
                      // Show a small indicator for own posts
                      if (displayPost.user?.id != null &&
                          _currentUserId != null &&
                          displayPost.user!.id == _currentUserId)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 8,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            displayPost.user?.fullName ?? 'Unknown User',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          // Show "You" indicator for own posts
                          if (displayPost.user?.id != null &&
                              _currentUserId != null &&
                              displayPost.user!.id == _currentUserId)
                            Container(
                              margin: EdgeInsets.only(left: 6),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: Colors.blue.withOpacity(0.3)),
                              ),
                              child: Text(
                                'You',
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      Text(
                        displayPost.user?.username ?? '',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                if (displayPost.category != null)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Color(0xFFFF69B4),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('💄', style: TextStyle(fontSize: 12)),
                        SizedBox(width: 4),
                        Text(
                          displayPost.category!.name?.toLowerCase() ?? '',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // Caption
          if (displayPost.caption != null && displayPost.caption!.isNotEmpty)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(displayPost.caption!, style: TextStyle(fontSize: 14)),
            ),

          if (displayPost.caption != null && displayPost.caption!.isNotEmpty)
            SizedBox(height: 12),

          // Tagged Users
          if (displayPost.taggedUsers != null &&
              displayPost.taggedUsers!.isNotEmpty)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TaggedUsersChipsWidget(
                taggedUsers: displayPost.taggedUsers!,
                onUserTap: (user) {
                  // Navigate to user profile
                  Navigator.pushNamed(context, '/user-profile',
                      arguments: user.id);
                },
              ),
            ),

          // Media with proper aspect ratio and full width
          if (displayPost.mediaUrl != null)
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(0),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight:
                          400, // Limit video height to prevent overly long videos
                    ),
                    child: SmartMediaWidget(
                      post: displayPost,
                      width: double.infinity,
                      fit: BoxFit
                          .cover, // Use cover to prevent videos from appearing longer
                      onExpand: () =>
                          _openFullscreen(displayPost), // Add expand callback
                    ),
                  ),
                ),
                // Fullscreen button
                Positioned(
                  top: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: () => _openFullscreen(displayPost),
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        Icons.fullscreen,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),

          SizedBox(height: 12),

          // Action buttons
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(
                  displayPost.isLiked == true
                      ? Icons.favorite
                      : Icons.favorite_border,
                  '${displayPost.likesCount ?? 0}',
                  color: displayPost.isLiked == true
                      ? Colors.red
                      : Colors.grey[600],
                  onTap: () => _toggleLike(displayPost),
                ),
                _buildActionButton(
                  displayPost.isSaved == true
                      ? Icons.bookmark
                      : Icons.bookmark_border,
                  'Save',
                  color: displayPost.isSaved == true
                      ? Colors.blue
                      : Colors.grey[600],
                  onTap: () => _toggleSave(displayPost),
                ),
                _buildActionButton(
                  Icons.share, // Share icon
                  'Share',
                  color: Colors.grey[600],
                  onTap: () => _sharePost(displayPost), // Share functionality
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Share post functionality
  void _sharePost(Post post) async {
    if (post.mediaUrl != null) {
      await Share.share('Check out this post: ${post.mediaUrl}');
    } else if (post.caption != null) {
      await Share.share(post.caption!); // Share caption if no media
    }
  }

  Widget _buildActionButton(IconData icon, String label,
      {Color? color, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Icon(icon, color: color ?? Colors.grey[600], size: 22),
            SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    color: color ?? Colors.grey[600],
                    fontSize: 13,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  // Open fullscreen viewer
  void _openFullscreen(Post post) {
    print('🎥 Feed: Opening fullscreen for post ${post.id}');
    Duration? currentPosition;

    // Pause all currently playing videos before opening fullscreen
    _activeVideoControllers.values.forEach((controller) {
      if (controller != null && controller.value.isPlaying) {
        print('🎥 Feed: Pausing video controller before fullscreen');
        controller.pause();
      }
    });

    if (post.id != null &&
        _activeVideoControllers.containsKey(post.id) &&
        _activeVideoControllers[post.id!] != null) {
      currentPosition = _activeVideoControllers[post.id!]!.value.position;
      print('🎥 Feed: Captured current position: $currentPosition');
    }

    print('🎥 Feed: Showing fullscreen dialog');
    showDialog(
      context: context,
      barrierColor: Colors.black,
      builder: (context) =>
          _FullscreenMediaViewer(post: post, startPosition: currentPosition),
    ).then((_) {
      print('🎥 Feed: Fullscreen dialog closed, pausing all videos');
      // Pause all videos when fullscreen is closed
      pauseAllVideos();
    });
  }

  Future<void> _toggleLike(Post post) async {
    if (post.id == null) return;

    // OPTIMISTIC UPDATE: Update UI immediately
    final wasLiked = post.isLiked ?? false;
    final oldLikesCount = post.likesCount ?? 0;

    setState(() {
      post.isLiked = !wasLiked;
      post.likesCount = wasLiked ? oldLikesCount - 1 : oldLikesCount + 1;
      _postsCache[post.id!] = post;
    });

    // Then sync with backend in background
    try {
      final response =
          await api<PostApiService>((request) => request.toggleLike(post.id!));

      if (response != null && response['success'] == true) {
        // Update with actual server values
        setState(() {
          post.isLiked = response['data']['liked'] ?? !wasLiked;
          post.likesCount = response['data']['likes_count'] ?? post.likesCount;
          _postsCache[post.id!] = post;
        });
      } else {
        // Revert on failure
        setState(() {
          post.isLiked = wasLiked;
          post.likesCount = oldLikesCount;
          _postsCache[post.id!] = post;
        });
        showToast(
          title: 'Error',
          description: 'Failed to ${wasLiked ? 'unlike' : 'like'} post',
          style: ToastNotificationStyleType.warning,
        );
      }
    } catch (e) {
      print('❌ Feed: Error toggling like: $e');
      // Revert on error
      setState(() {
        post.isLiked = wasLiked;
        post.likesCount = oldLikesCount;
        _postsCache[post.id!] = post;
      });
      showToast(
        title: 'Error',
        description: 'Network error. Please try again.',
        style: ToastNotificationStyleType.danger,
      );
    }
  }

  Future<void> _toggleSave(Post post) async {
    if (post.id == null) return;

    // OPTIMISTIC UPDATE: Update UI immediately
    final wasSaved = post.isSaved ?? false;
    final oldSavesCount = post.savesCount ?? 0;

    setState(() {
      post.isSaved = !wasSaved;
      post.savesCount = wasSaved ? oldSavesCount - 1 : oldSavesCount + 1;
      _postsCache[post.id!] = post;
    });

    // Then sync with backend in background
    try {
      final response =
          await api<PostApiService>((request) => request.toggleSave(post.id!));

      if (response != null && response['success'] == true) {
        // Update with actual server values
        setState(() {
          post.isSaved = response['data']['saved'] ?? !wasSaved;
          post.savesCount = response['data']['saves_count'] ?? post.savesCount;
          _postsCache[post.id!] = post;
        });
      } else {
        // Revert on failure
        setState(() {
          post.isSaved = wasSaved;
          post.savesCount = oldSavesCount;
          _postsCache[post.id!] = post;
        });
        showToast(
          title: 'Error',
          description: 'Failed to ${wasSaved ? 'unsave' : 'save'} post',
          style: ToastNotificationStyleType.warning,
        );
      }
    } catch (e) {
      print('❌ Feed: Error toggling save: $e');
      // Revert on error
      setState(() {
        post.isSaved = wasSaved;
        post.savesCount = oldSavesCount;
        _postsCache[post.id!] = post;
      });
      showToast(
        title: 'Error',
        description: 'Network error. Please try again.',
        style: ToastNotificationStyleType.danger,
      );
    }
  }
}

// Fullscreen Media Viewer Widget
class _FullscreenMediaViewer extends StatefulWidget {
  final Post post;
  final Duration? startPosition;

  const _FullscreenMediaViewer({required this.post, this.startPosition});

  @override
  State<_FullscreenMediaViewer> createState() => _FullscreenMediaViewerState();
}

class _FullscreenMediaViewerState extends State<_FullscreenMediaViewer> {
  @override
  void dispose() {
    // Force pause all videos when disposing
    print('🎥 Feed: Disposing feed widget, force pausing all videos');
    // forcePauseAllVideos();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Media centered
          Center(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: SmartMediaWidget(
                post: widget.post,
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                fit: BoxFit.contain,
              ),
            ),
          ),

          // Close button
          Positioned(
            top: 40,
            right: 16,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ),

          // User info at bottom (optional)
          Positioned(
            bottom: 40,
            left: 16,
            right: 16,
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundImage: widget.post.user?.profilePicture != null
                        ? NetworkImage(widget.post.user!.profilePicture!)
                        : null,
                    backgroundColor: Color(0xFF9ACD32),
                    child: widget.post.user?.profilePicture == null
                        ? Text(
                            widget.post.user?.fullName
                                    ?.substring(0, 1)
                                    .toUpperCase() ??
                                'U',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12),
                          )
                        : null,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.post.user?.fullName ?? 'Unknown User',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14),
                        ),
                        if (widget.post.caption != null &&
                            widget.post.caption!.isNotEmpty)
                          Text(
                            widget.post.caption!,
                            style:
                                TextStyle(color: Colors.white70, fontSize: 12),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
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
  }
}
