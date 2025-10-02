import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '/app/models/post.dart';
import '/app/models/category.dart';
import '/app/models/user.dart';
import '/app/networking/post_api_service.dart';
import '/app/networking/category_api_service.dart';
import '/app/networking/auth_api_service.dart';
import '/config/cache.dart';

class Feed extends StatefulWidget {
  const Feed({super.key});

  @override
  createState() => _FeedState();
}

class _FeedState extends NyState<Feed> {
  List<Post> _feedItems = [];
  List<Category> _categories = [];
  String _selectedCategory = 'ALL';
  int _currentPage = 1;
  bool _hasMorePosts = true;
  bool _isLoadingMore = false;
  User? _currentUser;

  @override
  LoadingStyle get loadingStyle => LoadingStyle.skeletonizer(
        child: _buildSkeletonLoader(),
      );

  @override
  get init => () async {
        await _loadInitialData();
      };

  Future<void> _loadInitialData() async {
    try {
      // Load current user
      _currentUser = await api<AuthApiService>(
        (request) => request.getCurrentUser(),
        cacheKey: CacheConfig.currentUserKey,
        cacheDuration: CacheConfig.userProfileCache,
      );

      // Load categories
      await _loadCategories();

      // Load feed posts
      await _loadFeedPosts();
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
        setState(() {
          _categories = categories;
        });
      }
    } catch (e) {
      showToast(title: 'Error', description: 'Failed to load categories: $e');
    }
  }

  Future<void> _loadFeedPosts({bool isRefresh = false}) async {
    if (_isLoadingMore && !isRefresh) return;

    if (isRefresh) {
      _currentPage = 1;
      _hasMorePosts = true;
      _feedItems.clear();
    }

    setState(() => _isLoadingMore = true);

    try {
      final feedResponse = await api<PostApiService>(
        (request) => request.getFeed(perPage: 20, page: _currentPage),
        cacheKey: "feed_${_selectedCategory}_$_currentPage",
        cacheDuration: CacheConfig.userFeedCache,
      );

      if (feedResponse != null && feedResponse['data'] != null) {
        final newPosts = List<Post>.from(feedResponse['data']);
        setState(() {
          if (isRefresh) {
            _feedItems = newPosts;
          } else {
            _feedItems.addAll(newPosts);
          }
          _hasMorePosts = newPosts.length == 20;
          _currentPage++;
        });
      }
    } catch (e) {
      showToast(title: 'Error', description: 'Failed to load posts: $e');
    } finally {
      setState(() => _isLoadingMore = false);
    }
  }

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Logo and App Name Section
          _buildHeaderSection(),

          // Category Buttons
          _buildCategorySection(),

          // Feed Content
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => _loadFeedPosts(isRefresh: true),
              child: _buildFeedList(),
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
          // Logo image
          Image.asset(
            'logo.png',
            width: 80,
            height: 80,
            fit: BoxFit.contain,
          ).localAsset(),

          const SizedBox(height: 10),

          // App name with second 'i' in yellow and 'r' in blue
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'insp',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFFF69B4), // Bright pink
                    letterSpacing: -0.5,
                  ),
                ),
                TextSpan(
                  text: 'i',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFFFD700), // Yellow
                    letterSpacing: -0.5,
                  ),
                ),
                TextSpan(
                  text: 'rtag',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF00BFFF), // Blue
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
    // Add "ALL" category at the beginning
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
              onPressed: () {
                setState(() {
                  _selectedCategory = category;
                });
                _loadFeedPosts(isRefresh: true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isSelected ? Color(0xFF00BFFF) : Colors.white,
                side: BorderSide(
                  color: Color(0xFF00BFFF),
                  width: 1,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
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

  Widget _buildFeedList() {
    return ListView.builder(
      itemCount: _feedItems.length + (_hasMorePosts ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _feedItems.length) {
          return _buildLoadMoreIndicator();
        }

        final post = _feedItems[index];
        return _buildPostCard(post);
      },
    );
  }

  Widget _buildPostCard(Post post) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User info
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundImage: post.user?.profilePicture != null
                    ? NetworkImage(post.user!.profilePicture!)
                    : null,
                backgroundColor: Color(0xFF9ACD32),
                child: post.user?.profilePicture == null
                    ? Text(
                        post.user?.name?.substring(0, 1).toUpperCase() ?? 'U',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      )
                    : null,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.user?.name ?? 'Unknown User',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      post.user?.username ?? '',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              // Category tag
              if (post.category != null)
                GestureDetector(
                  onTap: () {
                    routeTo('/tags');
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Color(0xFFFF69B4), // Pink
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '💄', // Category emoji
                          style: TextStyle(fontSize: 12),
                        ),
                        SizedBox(width: 4),
                        Text(
                          post.category!.name?.toLowerCase() ?? '',
                          style: TextStyle(
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
          SizedBox(height: 16),
          // Content
          if (post.caption != null && post.caption!.isNotEmpty)
            Text(
              post.caption!,
              style: TextStyle(fontSize: 14),
            ),
          SizedBox(height: 16),
          // Media
          if (post.mediaUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                post.mediaUrl!,
                width: double.infinity,
                height: 300,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 300,
                    color: Colors.grey[300],
                    child: Icon(Icons.error, size: 50),
                  );
                },
              ),
            ),
          SizedBox(height: 16),
          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildActionButton(
                post.isLiked == true ? Icons.favorite : Icons.favorite_border,
                '${post.likesCount ?? 0}',
                color: post.isLiked == true ? Colors.red : Colors.grey[600],
                onTap: () => _toggleLike(post),
              ),
              _buildActionButton(
                post.isSaved == true ? Icons.bookmark : Icons.bookmark_border,
                'Save',
                color: post.isSaved == true ? Colors.blue : Colors.grey[600],
                onTap: () => _toggleSave(post),
              ),
              _buildActionButton(
                Icons.comment_outlined,
                '${post.commentsCount ?? 0}',
                color: Colors.grey[600],
                onTap: () {
                  // Navigate to comments
                },
              ),
              if (post.location != null)
                _buildActionButton(
                  Icons.location_on,
                  post.location!,
                  color: Colors.grey[600],
                  onTap: () {
                    // Show location details
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoadMoreIndicator() {
    if (!_hasMorePosts) return SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(16),
      child: _isLoadingMore
          ? Center(child: CircularProgressIndicator())
          : TextButton(
              onPressed: () => _loadFeedPosts(),
              child: Text('Load More'),
            ),
    );
  }

  Widget _buildActionButton(IconData icon, String label,
      {Color? color, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: color ?? Colors.grey[600], size: 20),
          SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color ?? Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // API Actions
  Future<void> _toggleLike(Post post) async {
    try {
      final response = await api<PostApiService>(
        (request) => request.toggleLike(post.id!),
      );

      if (response != null) {
        setState(() {
          post.isLiked = response['liked'];
          post.likesCount = response['likes_count'];
        });
      }
    } catch (e) {
      showToast(title: 'Error', description: 'Failed to like post: $e');
    }
  }

  Future<void> _toggleSave(Post post) async {
    try {
      final response = await api<PostApiService>(
        (request) => request.toggleSave(post.id!),
      );

      if (response != null) {
        setState(() {
          post.isSaved = response['saved'];
          post.savesCount = response['saves_count'];
        });
      }
    } catch (e) {
      showToast(title: 'Error', description: 'Failed to save post: $e');
    }
  }

  // Skeleton loader
  Widget _buildSkeletonLoader() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 8),
      itemCount: 5,
      itemBuilder: (context, index) => _buildSkeletonPostCard(),
    );
  }

  Widget _buildSkeletonPostCard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User info skeleton
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 16,
                      width: 120,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    SizedBox(height: 4),
                    Container(
                      height: 12,
                      width: 80,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          // Caption skeleton
          Container(
            height: 16,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          SizedBox(height: 8),
          Container(
            height: 16,
            width: 200,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          SizedBox(height: 16),
          // Media skeleton
          Container(
            height: 300,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          SizedBox(height: 16),
          // Actions skeleton
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(
                height: 24,
                width: 60,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              Container(
                height: 24,
                width: 60,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              Container(
                height: 24,
                width: 60,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
