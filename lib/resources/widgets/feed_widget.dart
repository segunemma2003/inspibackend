import 'package:flutter/material.dart';
import 'package:nylo_framework/metro/ny_cli.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '/app/models/post.dart';
import '/app/models/category.dart';
import '/app/networking/post_api_service.dart';
import '/app/networking/category_api_service.dart';
import '/app/networking/auth_api_service.dart';
import '/config/cache.dart';
import '/resources/widgets/smart_media_widget.dart';

class Feed extends StatefulWidget {
  const Feed({super.key});

  @override
  createState() => _FeedState();
}

class _FeedState extends NyState<Feed> {
  List<Category> _categories = [];
  String _selectedCategory = 'ALL';
  int _refreshTrigger = 0;

  // Store posts locally for immediate UI updates
  Map<int, Post> _postsCache = {};

  // Pagination state
  bool _hasMorePages = true;
  int _currentPage = 1;
  int _lastPage = 1;

  @override
  get init => () async {
        await _loadInitialData();
      };

  Future<void> _loadInitialData() async {
    try {
      await api<AuthApiService>(
        (request) => request.getCurrentUser(),
        cacheKey: CacheConfig.currentUserKey,
        cacheDuration: CacheConfig.userProfileCache,
      );

      await _loadCategories();
      await _loadFeedPosts(1,
          forceRefresh: true); // Load initial feed posts with force refresh
    } catch (e) {
      showToast(title: 'Error', description: 'Failed to load data: $e');
    }
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await api<CategoryApiService>(
        (request) => request.getCategories(),
        cacheKey: CacheConfig.categoriesKey,
        cacheDuration: CacheConfig.categoriesCache,
      );

      if (categories != null) {
        print('📱 Feed: Loaded ${categories.length} categories');
        setState(() {
          _categories = categories;
        });
      }
    } catch (e) {
      showToast(title: 'Error', description: 'Failed to load categories: $e');
    }
  }

  Future<List<Post>> _loadFeedPosts(int page,
      {bool forceRefresh = false}) async {
    try {
      print(
          '📱 Feed: Loading posts (page: $page, category: $_selectedCategory, forceRefresh: $forceRefresh)');

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

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeaderSection(),
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
      padding: EdgeInsets.only(top: 50, bottom: 20),
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

  Widget _buildCategorySection() {
    final allCategories = [
      'ALL',
      ..._categories
          .map((cat) => cat.name ?? '')
          .where((name) => name.isNotEmpty)
    ];

    return Container(
      height: 50,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: allCategories.length,
        itemBuilder: (context, index) {
          final category = allCategories[index];
          final isSelected = category == _selectedCategory;

          return Container(
            margin: EdgeInsets.only(right: 12),
            child: ElevatedButton(
              onPressed: () => _onCategorySelected(category),
              style: ElevatedButton.styleFrom(
                backgroundColor: isSelected ? Color(0xFF00BFFF) : Colors.white,
                side: BorderSide(color: Color(0xFF00BFFF), width: 1),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                elevation: 0,
              ),
              child: Text(
                category,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_not_supported_outlined,
                size: 80, color: Colors.grey[400]),
            SizedBox(height: 20),
            Text(
              _selectedCategory == 'ALL'
                  ? 'No posts yet'
                  : 'No posts in $_selectedCategory category',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              _selectedCategory == 'ALL'
                  ? 'Be the first to share something amazing!'
                  : 'Try selecting a different category or check back later.',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostCard(Post post) {
    // Use cached post if available for real-time updates
    final displayPost = _postsCache[post.id] ?? post;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundImage: displayPost.user?.profilePicture != null
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
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayPost.user?.fullName ?? 'Unknown User',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    Text(
                      displayPost.user?.username ?? '',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ),
              if (displayPost.category != null)
                GestureDetector(
                  onTap: () => routeTo('/tags'),
                  child: Container(
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
                ),
            ],
          ),
          SizedBox(height: 16),
          if (displayPost.caption != null && displayPost.caption!.isNotEmpty)
            Text(displayPost.caption!, style: TextStyle(fontSize: 14)),
          SizedBox(height: 16),
          if (displayPost.mediaUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SmartMediaWidget(
                post: displayPost,
                height: 300,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(
                displayPost.isLiked == true
                    ? Icons.favorite
                    : Icons.favorite_border,
                '${displayPost.likesCount ?? 0}',
                color:
                    displayPost.isLiked == true ? Colors.red : Colors.grey[600],
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
            ],
          ),
        ],
      ),
    );
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
