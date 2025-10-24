import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:flutter_app/app/networking/post_api_service.dart';
import 'package:flutter_app/app/models/post.dart';
import 'package:flutter_app/app/networking/user_api_service.dart'; // Re-add UserApiService
import 'package:flutter_app/app/models/user.dart'; // Re-add User model
import '/resources/widgets/smart_media_widget.dart';
import '/app/services/firebase_messaging_service.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  createState() => _ProfileState();
}

class _ProfileState extends NyState<Profile> {
  bool _isSidebarOpen = false;
  int _selectedTabIndex = 0;
  User? _currentUser;
  int _refreshTrigger = 0;

  // User content categories
  Map<String, int> _userCategories = {};
  bool _isLoadingCategories = false;

  @override
  get init => () async {
        await _loadUserData(); // Ensure user data is loaded on init
      };

  Future<void> _loadUserData() async {
    try {
      print('🔄 Profile: Loading user data...');

      final user = await api<UserApiService>((request) =>
          request.fetchCurrentUser()); // Fetch user via UserApiService

      if (user != null) {
        setState(() {
          _currentUser = user;
        });
        print('✅ Profile: User loaded successfully: ${_currentUser?.fullName}');
      } else {
        print('❌ Profile: Failed to load user data');
      }
    } catch (e, stackTrace) {
      print('❌ Profile: Error loading user data: $e');
      print('📍 Profile: Stack trace: $stackTrace');
    }
  }

  Future<List<Post>> _loadUserPosts(int page,
      {bool forceRefresh = false}) async {
    if (_currentUser?.id == null) {
      print('❌ Profile: Cannot load user posts - user ID is null');
      return [];
    }

    try {
      print(
          '📱 Profile: Loading user posts for user ${_currentUser!.id} (page: $page, forceRefresh: $forceRefresh)');

      final response = await api<PostApiService>(
        (request) {
          final creatorsFilter = [_currentUser!.id.toString()];
          print(
              '📱 Profile: Sending getFeed with creators: $creatorsFilter, page: $page, perPage: 20, forceRefresh: $forceRefresh');
          return request.getFeed(
            perPage: 20,
            page: page,
            creators: creatorsFilter,
            forceRefresh: forceRefresh,
          );
        },
      );

      if (response != null && response['success'] == true) {
        final List<dynamic> postsData = response['data']['data'] ?? [];
        final List<Post> posts =
            postsData.map((json) => Post.fromJson(json)).toList();

        print('📱 Profile: Loaded ${posts.length} user posts');

        // Load categories on first page (only if not forcing refresh as the categories are from the posts themselves)
        if (page == 1 && posts.isNotEmpty) {
          _loadUserCategories(posts);
        }

        return posts;
      } else {
        throw Exception('Failed to load user posts');
      }
    } catch (e) {
      print('❌ Profile: Error loading user posts: $e');
      return [];
    }
  }

  Future<List<Post>> _loadLikedPosts(int page) async {
    try {
      print('❤️ Profile: Loading liked posts (page: $page)');

      final response = await api<PostApiService>(
        (request) => request.getLikedPosts(page: page, perPage: 20),
      );

      if (response != null && response['success'] == true) {
        final List<dynamic> postsData = response['data']['data'] ?? [];
        final List<Post> posts =
            postsData.map((json) => Post.fromJson(json)).toList();

        print('❤️ Profile: Loaded ${posts.length} liked posts');
        return posts;
      } else {
        throw Exception('Failed to load liked posts');
      }
    } catch (e) {
      print('❌ Profile: Error loading liked posts: $e');
      return [];
    }
  }

  Future<List<Post>> _loadSavedPosts(int page) async {
    try {
      print('📚 Profile: Loading saved posts (page: $page)');

      final response = await api<PostApiService>(
        (request) => request.getSavedPosts(page: page, perPage: 20),
      );

      if (response != null && response['success'] == true) {
        final List<dynamic> postsData = response['data']['data'] ?? [];
        final List<Post> posts =
            postsData.map((json) => Post.fromJson(json)).toList();

        print('📚 Profile: Loaded ${posts.length} saved posts');
        return posts;
      } else {
        throw Exception('Failed to load saved posts');
      }
    } catch (e) {
      print('❌ Profile: Error loading saved posts: $e');
      return [];
    }
  }

  void _loadUserCategories(List<Post> posts) {
    setState(() => _isLoadingCategories = true);

    try {
      final Map<String, int> categories = {};
      for (final post in posts) {
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

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(),
                Expanded(
                  child: NyPullToRefresh.grid(
                    key: ValueKey(_getStateNameForTab()),
                    stateName: _getStateNameForTab(),
                    crossAxisCount: 3,
                    mainAxisSpacing: 2,
                    crossAxisSpacing: 2,
                    padding: EdgeInsets.zero,
                    header: _buildProfileHeader(), // Header content here
                    child: (context, post) => _buildPostItem(post as Post),
                    data: (int iteration) async {
                      print(
                          '📱 Profile: Loading posts - tab: $_selectedTabIndex, page: $iteration');

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
          if (_isSidebarOpen) _buildSidebarOverlay(),
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
        _buildUserCategoriesSection(),
        const SizedBox(height: 30),
        _buildTabBar(),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      child: Row(
        children: [
          const Icon(Icons.arrow_back, size: 24, color: Colors.black),
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
            onTap: () => routeTo('/edit-profile'),
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
            child: const Icon(Icons.menu, size: 24, color: Colors.black),
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
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          Text(
            _currentUser?.bio ?? 'add your bio on edit profile',
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
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.0),
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary),
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
          // const Text(
          //   'Content Categories',
          //   style: TextStyle(
          //     fontSize: 18,
          //     fontWeight: FontWeight.bold,
          //     color: Colors.black87,
          //   ),
          // ),
          const SizedBox(height: 6),
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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(25), // Equivalent to 10% opacity
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
        mainAxisAlignment: MainAxisAlignment.center,
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
                          SmartMediaWidget(
                            post: post,
                            width: double.infinity,
                            height: 400,
                            fit: BoxFit.contain,
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
    );
  }

  Widget _buildSidebarOverlay() {
    return Container(
      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
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
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFFF69B4), Color(0xFF00BFFF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius:
                        BorderRadius.only(topRight: Radius.circular(20)),
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
                                color: Theme.of(context)
                                    .colorScheme
                                    .surface
                                    .withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close,
                                  color: Colors.white, size: 20),
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
                              color: Theme.of(context)
                                  .colorScheme
                                  .surface
                                  .withOpacity(0.2),
                            ),
                            child: const Icon(Icons.person,
                                color: Colors.white, size: 24),
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
                                    color: Theme.of(context)
                                        .colorScheme
                                        .surface
                                        .withOpacity(0.8),
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
                      _buildSidebarItem(Icons.home_outlined, 'Feed', '/base'),
                      _buildSidebarItem(Icons.person_outline, 'Edit Profile',
                          '/edit-profile'),
                      _buildSidebarItem(
                          Icons.settings_outlined, 'Settings', '/settings'),
                      _buildSidebarItem(Icons.notifications_outlined,
                          'Notifications', '/notifications'),

                      // Policy and Support Section
                      const SizedBox(height: 16),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Legal & Support',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      _buildSidebarItem(Icons.privacy_tip_outlined,
                          'Privacy Policy', '/privacy-policy'),
                      _buildSidebarItem(Icons.description_outlined,
                          'Terms of Service', '/terms-of-service'),
                      _buildSidebarItem(Icons.rule_outlined,
                          'Community Guidelines', '/community-guidelines'),
                      _buildSidebarItem(Icons.help_center_outlined,
                          'Help Center', '/help-center'),
                      _buildSidebarItem(Icons.support_agent_outlined,
                          'Contact Support', '/support'),
                      _buildSidebarItem(
                          Icons.info_outline, 'About Us', '/about'),

                      // Debug section
                      const SizedBox(height: 16),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Debug',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildDebugNotificationButton(),

                      const SizedBox(height: 16),
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

  Widget _buildDebugNotificationButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            try {
              // Import FirebaseMessagingService
              final messagingService = FirebaseMessagingService();

              // Test local notification
              await messagingService.testLocalNotification();

              // Show debug info
              await messagingService.debugNotificationSetup();

              showToast(
                title: "Debug Test",
                description: "Check console for notification debug info",
              );
            } catch (e) {
              showToast(
                title: "Debug Error",
                description: "Error testing notifications: $e",
                style: ToastNotificationStyleType.danger,
              );
            }
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(Icons.bug_report_outlined,
                    color: Colors.orange[600], size: 20),
                const SizedBox(width: 12),
                const Text(
                  'Test Notifications',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSidebarItem(IconData icon, String title, route,
      {bool isDestructive = false}) {
    Color iconColor = isDestructive ? Colors.red : Colors.grey[600]!;
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
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconColor.withAlpha(25), // Equivalent to 10% opacity
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                    ),
                  ),
                ),
                Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
