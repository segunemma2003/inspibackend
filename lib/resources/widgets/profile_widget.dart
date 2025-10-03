import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '/app/services/auth_service.dart';
import '/app/networking/auth_api_service.dart';
import '/app/networking/post_api_service.dart';
import '/app/networking/user_api_service.dart';
import '/app/models/user.dart';
import '/app/models/post.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  createState() => _ProfileState();
}

class _ProfileState extends NyState<Profile> {
  bool _isSidebarOpen = false;
  int _selectedTabIndex = 0;
  User? _currentUser;

  // Posts data
  List<Post> _userPosts = [];
  List<Post> _likedPosts = [];
  List<Post> _savedPosts = [];
  bool _isLoadingPosts = false;

  // User content categories
  Map<String, int> _userCategories = {};
  bool _isLoadingCategories = false;

  // Pagination
  int _currentPage = 1;
  bool _hasMorePosts = true;
  final ScrollController _scrollController = ScrollController();

  @override
  get init => () async {
        await _debugAuthData();
        await _loadUserData();
        await _loadPosts();
        _scrollController.addListener(_onScroll);
      };

  Future<void> _debugAuthData() async {
    try {
      print('🔍 Profile: Debugging Auth data...');

      // Check if user is authenticated
      final isAuthenticated = await Auth.isAuthenticated();
      print('🔍 Profile: Is authenticated: $isAuthenticated');

      final authData = await Auth.data();
      print('🔍 Profile: Raw Auth.data(): $authData');
      print('🔍 Profile: Auth data type: ${authData.runtimeType}');

      if (authData != null) {
        print('🔍 Profile: Auth data keys: ${authData.keys}');
        if (authData.containsKey('user')) {
          print('🔍 Profile: User data: ${authData['user']}');
          print('🔍 Profile: User data type: ${authData['user'].runtimeType}');
          if (authData['user'] is Map) {
            final userData = authData['user'] as Map<String, dynamic>;
            print('🔍 Profile: User data keys: ${userData.keys}');
            print('🔍 Profile: User name: ${userData['name']}');
            print('🔍 Profile: User full_name: ${userData['full_name']}');
            print('🔍 Profile: User username: ${userData['username']}');
            print('🔍 Profile: User email: ${userData['email']}');
          }
        }
        if (authData.containsKey('token')) {
          print('🔍 Profile: Token exists: ${authData['token'] != null}');
        }
      } else {
        print('❌ Profile: Auth data is null - user not authenticated');
      }
    } catch (e) {
      print('❌ Profile: Error debugging auth data: $e');
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoadingPosts && _hasMorePosts) {
        _loadMorePosts();
      }
    }
  }

  Future<void> _loadUserData() async {
    try {
      print('🔄 Profile: Loading user data...');

      // First try to get user data from AuthService (cached data)
      final cachedUserData = await AuthService.instance.getUserProfile();
      print('📱 Profile: Cached user data: $cachedUserData');
      print('📱 Profile: Cached user data type: ${cachedUserData.runtimeType}');
      if (cachedUserData != null) {
        print('📱 Profile: Cached user data keys: ${cachedUserData.keys}');
        print('📱 Profile: Name field: ${cachedUserData['name']}');
        print('📱 Profile: Full name field: ${cachedUserData['full_name']}');
        print('📱 Profile: Username field: ${cachedUserData['username']}');
      }

      if (cachedUserData != null) {
        _populateUserData(cachedUserData);
        print('✅ Profile: Populated from cache');
        print('🔍 Profile: Cache populated user: ${_currentUser?.fullName}');
      }

      // Then fetch fresh data from API
      print('🌐 Profile: Fetching fresh data from API...');
      final response = await api<AuthApiService>(
        (request) => request.getCurrentUser(),
      );

      print('📡 Profile: API response: $response');
      print('📡 Profile: Response type: ${response.runtimeType}');

      if (response != null) {
        // Handle different response structures
        User? user;
        if (response is User) {
          user = response;
          print('✅ Profile: Response is User object');
        } else if (response is Map<String, dynamic>) {
          print('📋 Profile: Response is Map, keys: ${response.keys}');
          if (response.containsKey('data') &&
              response['data'] is Map<String, dynamic>) {
            final data = response['data'];
            if (data.containsKey('user') &&
                data['user'] is Map<String, dynamic>) {
              user = User.fromJson(data['user']);
              print('✅ Profile: Created user from response.data.user');
            } else {
              user = User.fromJson(data);
              print('✅ Profile: Created user from response.data');
            }
          } else if (response.containsKey('user') &&
              response['user'] is Map<String, dynamic>) {
            user = User.fromJson(response['user']);
            print('✅ Profile: Created user from response.user');
          } else {
            user = User.fromJson(response);
            print('✅ Profile: Created user from response directly');
          }
        }

        if (user != null) {
          setState(() {
            _currentUser = user;
          });
          print('✅ Profile: User data loaded successfully: ${user.fullName}');
          print(
              '🔍 Profile: User object - name: ${user.name}, fullName: ${user.fullName}, username: ${user.username}');
        } else {
          print('❌ Profile: Failed to create user object');
        }
      } else {
        print('❌ Profile: API response is null');
      }
    } catch (e, stackTrace) {
      print('❌ Profile: Error loading user data: $e');
      print('📍 Profile: Stack trace: $stackTrace');
      showToast(title: 'Error', description: 'Failed to load profile data');
    }
  }

  void _populateUserData(Map<String, dynamic> userData) {
    // Create a User object from cached data
    print('🔄 Profile: _populateUserData called with: $userData');
    try {
      final user = User.fromJson(userData);
      print(
          '🔄 Profile: Created user object - name: ${user.name}, fullName: ${user.fullName}');
      setState(() {
        _currentUser = user;
      });
      print('✅ Profile: User set in state: ${_currentUser?.fullName}');
    } catch (e) {
      print('Error parsing cached user data: $e');
      // Fallback: create user with basic info
      setState(() {
        final user = User();
        user.id = userData['id'];
        user.fullName =
            userData['full_name']?.toString() ?? userData['name']?.toString();
        user.username = userData['username']?.toString();
        user.email = userData['email']?.toString();
        user.bio = userData['bio']?.toString();
        user.profession = userData['profession']?.toString();
        user.profilePicture = userData['profile_picture']?.toString();
        user.interests = userData['interests'] is List
            ? List<String>.from(userData['interests'])
            : null;
        _currentUser = user;
      });
    }
  }

  Future<void> _loadUserCategories() async {
    setState(() => _isLoadingCategories = true);

    try {
      // Extract categories from user posts
      final Map<String, int> categories = {};
      for (final post in _userPosts) {
        if (post.category != null && post.category!.name != null) {
          final categoryName = post.category!.name!;
          categories[categoryName] = (categories[categoryName] ?? 0) + 1;
        }
      }

      setState(() {
        _userCategories = categories;
      });
    } catch (e) {
      print('Error processing user categories: $e');
    } finally {
      setState(() => _isLoadingCategories = false);
    }
  }

  Future<void> _loadPosts({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _currentPage = 1;
        _hasMorePosts = true;
        _userPosts.clear();
        _likedPosts.clear();
        _savedPosts.clear();
      });
    }

    setState(() => _isLoadingPosts = true);

    try {
      // Load different posts based on selected tab
      switch (_selectedTabIndex) {
        case 0: // User's posts
          await _loadUserPosts();
          break;
        case 1: // Liked posts
          await _loadLikedPosts();
          break;
        case 2: // Saved posts
          await _loadSavedPosts();
          break;
      }
    } catch (e) {
      print('Error loading posts: $e');
      showToast(title: 'Error', description: 'Failed to load posts');
    } finally {
      setState(() => _isLoadingPosts = false);
    }
  }

  Future<void> _loadUserPosts() async {
    if (_currentUser == null) return;

    final response = await api<UserApiService>(
      (request) => request.getUserProfile(_currentUser!.id!),
    );

    if (response != null && response['success'] == true) {
      final userData = response['data'];
      final List<dynamic> postsData = userData['posts'] ?? [];
      final List<Post> newPosts =
          postsData.map((json) => Post.fromJson(json)).toList();

      setState(() {
        if (_currentPage == 1) {
          _userPosts = newPosts;
        } else {
          _userPosts.addAll(newPosts);
        }
        _hasMorePosts = newPosts.length == 20;
        _currentPage++;
      });

      // Load categories after posts are loaded
      if (_currentPage == 2) {
        // Only on first load
        await _loadUserCategories();
      }
    }
  }

  Future<void> _loadLikedPosts() async {
    final response = await api<PostApiService>(
      (request) => request.getLikedPosts(
        page: _currentPage,
        perPage: 20,
      ),
    );

    if (response != null && response['success'] == true) {
      final List<dynamic> postsData = response['data']['data'] ?? [];
      final List<Post> newPosts =
          postsData.map((json) => Post.fromJson(json)).toList();

      setState(() {
        if (_currentPage == 1) {
          _likedPosts = newPosts;
        } else {
          _likedPosts.addAll(newPosts);
        }
        _hasMorePosts = newPosts.length == 20;
        _currentPage++;
      });
    }
  }

  Future<void> _loadSavedPosts() async {
    final response = await api<PostApiService>(
      (request) => request.getSavedPosts(
        page: _currentPage,
        perPage: 20,
      ),
    );

    if (response != null && response['success'] == true) {
      final List<dynamic> postsData = response['data']['data'] ?? [];
      final List<Post> newPosts =
          postsData.map((json) => Post.fromJson(json)).toList();

      setState(() {
        if (_currentPage == 1) {
          _savedPosts = newPosts;
        } else {
          _savedPosts.addAll(newPosts);
        }
        _hasMorePosts = newPosts.length == 20;
        _currentPage++;
      });
    }
  }

  Future<void> _loadMorePosts() async {
    await _loadPosts();
  }

  List<Post> get _currentPosts {
    switch (_selectedTabIndex) {
      case 0:
        return _userPosts;
      case 1:
        return _likedPosts;
      case 2:
        return _savedPosts;
      default:
        return [];
    }
  }

  @override
  Widget view(BuildContext context) {
    print('🎨 Profile: Building UI - currentUser: ${_currentUser?.fullName}');
    print('🎨 Profile: Building UI - username: ${_currentUser?.username}');
    print(
        '🎨 Profile: Building UI - currentUser is null: ${_currentUser == null}');
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(),
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        _buildProfilePicture(),
                        const SizedBox(height: 20),
                        _buildNameAndBio(),
                        const SizedBox(height: 30),
                        _buildUserCategoriesSection(),
                        const SizedBox(height: 30),
                        _buildTabBar(),
                        const SizedBox(height: 20),
                        _buildPostsGrid(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_isSidebarOpen) _buildSidebarOverlay(),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    print('🎨 Profile: _buildTopBar - username: ${_currentUser?.username}');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      child: Row(
        children: [
          const Icon(
            Icons.arrow_back,
            size: 24,
            color: Colors.black,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              _currentUser?.username ?? 'Profile',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              routeTo('/edit-profile');
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'EDIT',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () {
              setState(() {
                _isSidebarOpen = true;
              });
            },
            child: const Icon(
              Icons.menu,
              size: 24,
              color: Colors.black,
            ),
          ),
        ],
      ),
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
          child: _currentUser?.profilePicture != null
              ? Image.network(
                  _currentUser!.profilePicture!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      child: Icon(
                        Icons.person,
                        size: 60,
                        color: Colors.grey[400],
                      ),
                    );
                  },
                )
              : Container(
                  color: Colors.grey[200],
                  child: Icon(
                    Icons.person,
                    size: 60,
                    color: Colors.grey[400],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildNameAndBio() {
    print('🎨 Profile: _buildNameAndBio - fullName: ${_currentUser?.fullName}');
    print('🎨 Profile: _buildNameAndBio - username: ${_currentUser?.username}');
    print('🎨 Profile: _buildNameAndBio - bio: ${_currentUser?.bio}');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          Text(
            _currentUser?.fullName ?? 'User',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '@${_currentUser?.username ?? 'username'}',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _currentUser?.bio ??
                'Welcome to Inspiritag! Express yourself and inspire others.',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildUserCategoriesSection() {
    if (_isLoadingCategories) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.0),
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF69B4)),
          ),
        ),
      );
    }

    if (_userCategories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Content Categories',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _userCategories.entries.map((entry) {
              return _buildCategoryChip(entry.key, entry.value);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String category, int count) {
    final colors = [
      const Color(0xFFFF69B4),
      const Color(0xFFFFD700),
      const Color(0xFF9ACD32),
      const Color(0xFF00BFFF),
      const Color(0xFF9C27B0),
    ];

    final color = colors[category.hashCode % colors.length];

    return GestureDetector(
      onTap: () {
        // Show category posts in story-like format
        _showCategoryStory(category);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          border: Border.all(color: color, width: 1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              category,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count.toString(),
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCategoryStory(String category) {
    // Filter posts by category
    final categoryPosts =
        _userPosts.where((post) => post.category?.name == category).toList();

    if (categoryPosts.isEmpty) {
      showToast(
          title: 'No Posts', description: 'No posts found in this category');
      return;
    }

    // Show story-like view (you can implement a custom story viewer here)
    showToast(
        title: category,
        description: '${categoryPosts.length} posts in this category');
  }

  Widget _buildTabBar() {
    final tabs = [
      {'icon': Icons.grid_on, 'title': 'Posts', 'count': _userPosts.length},
      {'icon': Icons.favorite, 'title': 'Liked', 'count': _likedPosts.length},
      {
        'icon': Icons.bookmark_border,
        'title': 'Saved',
        'count': _savedPosts.length
      },
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
                  _currentPage = 1;
                  _hasMorePosts = true;
                });
                _loadPosts(refresh: true);
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
                child: Column(
                  children: [
                    Icon(
                      tab['icon'] as IconData,
                      color: isSelected ? Colors.black : Colors.grey[400],
                      size: 24,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${tab['count']}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.black : Colors.grey[400],
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

  Widget _buildPostsGrid() {
    if (_isLoadingPosts && _currentPosts.isEmpty) {
      return _buildSkeletonGrid();
    }

    if (_currentPosts.isEmpty) {
      return _buildEmptyState();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: [
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 2,
              mainAxisSpacing: 2,
              childAspectRatio: 1,
            ),
            itemCount: _currentPosts.length,
            itemBuilder: (context, index) {
              final post = _currentPosts[index];
              return _buildPostItem(post);
            },
          ),
          if (_isLoadingPosts && _currentPosts.isNotEmpty)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF69B4)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSkeletonGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
          childAspectRatio: 1,
        ),
        itemCount: 9,
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
          );
        },
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
        description = 'Share your first transformation!';
        icon = Icons.add_photo_alternate;
        break;
      case 1:
        message = 'No liked posts';
        description = 'Start liking posts you love!';
        icon = Icons.favorite_border;
        break;
      case 2:
        message = 'No saved posts';
        description = 'Save posts for inspiration!';
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
        children: [
          Icon(
            icon,
            size: 64,
            color: Colors.grey[400],
          ),
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
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPostItem(Post post) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: post.mediaUrl != null
                ? Image.network(
                    post.mediaUrl!,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: double.infinity,
                        height: double.infinity,
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.image,
                          color: Colors.white,
                          size: 30,
                        ),
                      );
                    },
                  )
                : Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      gradient: LinearGradient(
                        colors: [Colors.blue[200]!, Colors.green[200]!],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Icon(
                      Icons.image,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
          ),

          // Video indicator
          if (post.mediaType == 'video')
            const Positioned(
              top: 8,
              right: 8,
              child: Icon(
                Icons.play_circle_filled,
                color: Colors.white,
                size: 20,
              ),
            ),

          // Likes indicator
          if (post.likesCount != null && post.likesCount! > 0)
            Positioned(
              bottom: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.favorite,
                      color: Colors.white,
                      size: 12,
                    ),
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
    );
  }

  Widget _buildSidebarOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.6),
      child: Row(
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.85,
            height: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  spreadRadius: 5,
                  blurRadius: 15,
                  offset: Offset(-2, 0),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFFFF69B4),
                        Color(0xFF00BFFF),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Menu',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _isSidebarOpen = false;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.2),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _currentUser?.fullName ?? 'User',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  _currentUser?.username ?? 'username',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    children: [
                      _buildSidebarItem(Icons.home_outlined, 'Feed', '/base',
                          isHighlighted: true),
                      _buildSidebarItem(Icons.person_outline, 'Edit Profile',
                          '/edit-profile'),
                      _buildSidebarItem(
                          Icons.settings_outlined, 'Settings', '/settings'),
                      _buildSidebarItem(Icons.business_outlined,
                          'Business Profile', '/businessprofile'),
                      _buildSidebarItem(Icons.privacy_tip_outlined,
                          'Privacy Policy', '/privacy'),
                      _buildSidebarItem(Icons.description_outlined,
                          'Terms & Conditions', '/terms'),
                      _buildSidebarItem(
                          Icons.help_outline, 'Help & Support', '/support'),
                      _buildSidebarItem(
                          Icons.info_outline, 'About Us', '/about'),
                      const SizedBox(height: 20),
                      Divider(color: Colors.grey[200], height: 1),
                      const SizedBox(height: 8),
                      _buildSidebarItem(Icons.logout, 'Logout', '/logout',
                          isDestructive: true),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isSidebarOpen = false;
                });
              },
              child: Container(color: Colors.transparent),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(IconData icon, String title, String route,
      {bool isHighlighted = false, bool isDestructive = false}) {
    Color iconColor = isDestructive
        ? Colors.red
        : (isHighlighted ? const Color(0xFF00BFFF) : Colors.grey[600]!);
    Color textColor = isDestructive ? Colors.red : Colors.grey[800]!;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            setState(() {
              _isSidebarOpen = false;
            });
            routeTo(route);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: isHighlighted
                  ? const Color(0xFF00BFFF).withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight:
                          isHighlighted ? FontWeight.w600 : FontWeight.w500,
                      color: textColor,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey[400],
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
