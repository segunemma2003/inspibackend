import 'package:flutter/material.dart';
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
  int _refreshTrigger = 0; // Used to force refresh

  @override
  get init => () async {
        await _loadInitialData();
      };

  Future<void> _loadInitialData() async {
    try {
      // Load current user (for authentication check)
      await api<AuthApiService>(
        (request) => request.getCurrentUser(),
        cacheKey: CacheConfig.currentUserKey,
        cacheDuration: CacheConfig.userProfileCache,
      );

      // Load categories
      await _loadCategories();
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

  Future<List<Post>> _loadFeedPosts(int page) async {
    try {
      print(
          '📱 Feed: Loading posts (page: $page, category: $_selectedCategory)');

      // Build query parameters
      List<String>? categoryFilter;

      // Add category filter if not "ALL"
      if (_selectedCategory != 'ALL') {
        Category? selectedCat;
        for (var cat in _categories) {
          if (cat.name?.trim() == _selectedCategory.trim()) {
            selectedCat = cat;
            break;
          }
        }

        if (selectedCat != null && selectedCat.id != null) {
          categoryFilter = [selectedCat.id.toString()];
          print(
              '📱 Feed: Filtering by category: ${selectedCat.name} (ID: ${selectedCat.id})');
        }
      }

      final feedResponse = await api<PostApiService>(
        (request) => request.getFeed(
          perPage: 20,
          page: page,
          categories: categoryFilter,
        ),
      );

      if (feedResponse != null && feedResponse['success'] == true) {
        final List<dynamic> postsData = feedResponse['data']['data'] ?? [];
        final List<Post> posts =
            postsData.map((json) => Post.fromJson(json)).toList();

        final currentPage = feedResponse['data']['current_page'] ?? 1;
        final lastPage = feedResponse['data']['last_page'] ?? 1;

        print(
            '📱 Feed: Loaded ${posts.length} posts (page $currentPage of $lastPage)');

        // Return empty list if no more posts (this stops pagination)
        if (posts.isEmpty) {
          print('📱 Feed: No posts found, stopping pagination');
        }

        return posts;
      } else {
        throw Exception('Failed to load feed posts');
      }
    } catch (e) {
      print('❌ Feed: Error loading posts: $e');
      showToast(title: 'Error', description: 'Failed to load posts: $e');
      return [];
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
              stateName: 'feed_list',
              crossAxisCount: 1,
              child: (context, post) => _buildPostCard(post as Post),
              data: (int iteration) async {
                print('📱 Feed: NyPullToRefresh iteration: $iteration');

                // IMPORTANT: iteration starts at 1 for first load, not 0
                // So we need to use iteration directly as the page number
                int page = iteration;

                return await _loadFeedPosts(page);
              },
              empty: _buildEmptyState(),
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
              onPressed: () {
                print('📱 Feed: Category selected: $category');
                setState(() {
                  _selectedCategory = category;
                  _refreshTrigger++; // Change key to force widget rebuild
                });
              },
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
                      post.user?.name ?? 'Unknown User',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    Text(
                      post.user?.username ?? '',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ),
              if (post.category != null)
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
                          post.category!.name?.toLowerCase() ?? '',
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
          if (post.caption != null && post.caption!.isNotEmpty)
            Text(post.caption!, style: TextStyle(fontSize: 14)),
          SizedBox(height: 16),
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
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
            ],
          ),
        ],
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
          Text(label,
              style: TextStyle(color: color ?? Colors.grey[600], fontSize: 12)),
        ],
      ),
    );
  }

  Future<void> _toggleLike(Post post) async {
    try {
      final wasLiked = post.isLiked ?? false;
      final oldLikesCount = post.likesCount ?? 0;

      setState(() {
        post.isLiked = !wasLiked;
        post.likesCount = wasLiked ? oldLikesCount - 1 : oldLikesCount + 1;
      });

      final response =
          await api<PostApiService>((request) => request.toggleLike(post.id!));

      if (response != null && response['success'] == true) {
        setState(() {
          post.isLiked = response['data']['liked'] ?? !wasLiked;
          post.likesCount = response['data']['likes_count'] ?? oldLikesCount;
        });
      } else {
        setState(() {
          post.isLiked = wasLiked;
          post.likesCount = oldLikesCount;
        });
      }
    } catch (e) {
      print('❌ Feed: Error toggling like: $e');
    }
  }

  Future<void> _toggleSave(Post post) async {
    try {
      final wasSaved = post.isSaved ?? false;
      final oldSavesCount = post.savesCount ?? 0;

      setState(() {
        post.isSaved = !wasSaved;
        post.savesCount = wasSaved ? oldSavesCount - 1 : oldSavesCount + 1;
      });

      final response =
          await api<PostApiService>((request) => request.toggleSave(post.id!));

      if (response != null && response['success'] == true) {
        setState(() {
          post.isSaved = response['data']['saved'] ?? !wasSaved;
          post.savesCount = response['data']['saves_count'] ?? oldSavesCount;
        });
      } else {
        setState(() {
          post.isSaved = wasSaved;
          post.savesCount = oldSavesCount;
        });
      }
    } catch (e) {
      print('❌ Feed: Error toggling save: $e');
    }
  }
}
