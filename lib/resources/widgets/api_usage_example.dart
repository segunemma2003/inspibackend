import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '/config/cache.dart';
import '/app/models/user.dart';
import '/app/models/post.dart';
import '/app/models/category.dart';
import '/app/networking/auth_api_service.dart';
import '/app/networking/user_api_service.dart';
import '/app/networking/post_api_service.dart';
import '/app/networking/business_api_service.dart';
import '/app/networking/notification_api_service.dart';
import '/app/networking/category_api_service.dart';

/// Example widget showing how to use the comprehensive API services
/// with caching for optimal performance
class ApiUsageExample extends NyStatefulWidget {
  ApiUsageExample({super.key});

  @override
  State<ApiUsageExample> createState() => _ApiUsageExampleState();
}

class _ApiUsageExampleState extends NyState<ApiUsageExample> {
  List<Post> posts = [];
  User? currentUser;
  List<Category> categories = [];
  bool _isLoading = false;

  @override
  get init => () async {
        await _loadInitialData();
      };

  /// Load initial data with caching
  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);

    try {
      // Load user feed with caching
      final feedResponse = await api<PostApiService>(
        (request) => request.getFeed(perPage: 20, page: 1),
        cacheKey: CacheConfig.userFeedKey,
        cacheDuration: CacheConfig.userFeedCache,
      );

      // Load current user with caching
      currentUser = await api<AuthApiService>(
        (request) => request.getCurrentUser(),
        cacheKey: CacheConfig.currentUserKey,
        cacheDuration: CacheConfig.userProfileCache,
      );

      // Load categories with long-term caching
      categories = await api<CategoryApiService>(
            (request) => request.getCategories(),
            cacheKey: CacheConfig.categoriesKey,
            cacheDuration: CacheConfig.categoriesCache,
          ) ??
          [];

      if (feedResponse != null && feedResponse['success'] == true) {
        final List<dynamic> postsData = feedResponse['data']['data'] ?? [];
        posts = postsData.map((json) => Post.fromJson(json)).toList();
      }
    } catch (e) {
      showToast(title: 'Error', description: 'Failed to load data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Create a new post
  Future<void> _createPost() async {
    try {
      final newPost = await api<PostApiService>(
        (request) => request.createPost(
          caption: "Check out this amazing hairstyle! #hair #beauty",
          media: "path/to/media/file.jpg",
          categoryId: categories.isNotEmpty ? (categories.first.id ?? 1) : 1,
          tags: ["hair", "beauty", "style"],
          location: "New York, NY",
        ),
      );

      if (newPost != null) {
        setState(() {
          posts.insert(0, newPost);
        });
        showToast(title: 'Success', description: "Post created successfully!");

        // Clear feed cache to refresh
        await cache().clear(CacheConfig.userFeedKey);
      }
    } catch (e) {
      showToast(title: 'Error', description: 'Failed to create post: $e');
    }
  }

  /// Like/Unlike a post
  Future<void> _toggleLike(Post post) async {
    try {
      final response = await api<PostApiService>(
        (request) => request.toggleLike(post.id ?? 0),
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

  /// Search users by interests
  Future<void> _searchUsersByInterests(List<String> interests) async {
    try {
      final response = await api<UserApiService>(
        (request) => request.searchUsersByInterests(
          interests: interests,
          perPage: 20,
        ),
        cacheKey: "users_by_interests_${interests.join('_')}",
        cacheDuration: CacheConfig.searchResultsCache,
      );

      if (response != null) {
        // Handle search results
        print('Found ${response['data']?.length ?? 0} users');
      }
    } catch (e) {
      showToast(title: 'Error', description: 'Search failed: $e');
    }
  }

  /// Get business accounts with caching
  Future<void> _loadBusinessAccounts() async {
    try {
      final response = await api<BusinessApiService>(
        (request) => request.getBusinessAccounts(
          type: "hair",
          perPage: 20,
        ),
        cacheKey: CacheConfig.businessAccountsKey,
        cacheDuration: CacheConfig.businessAccountsCache,
      );

      if (response != null) {
        // Handle business accounts
        print('Found ${response['data']?.length ?? 0} business accounts');
      }
    } catch (e) {
      showToast(
          title: 'Error', description: 'Failed to load business accounts: $e');
    }
  }

  /// Get notifications with caching
  Future<void> _loadNotifications() async {
    try {
      final response = await api<NotificationApiService>(
        (request) => request.getNotifications(
          perPage: 20,
          isRead: false,
        ),
        cacheKey: "notifications_unread",
        cacheDuration: CacheConfig.notificationCountCache,
      );

      if (response != null) {
        // Handle notifications
        print('Found ${response['data']?.length ?? 0} unread notifications');
      }
    } catch (e) {
      showToast(
          title: 'Error', description: 'Failed to load notifications: $e');
    }
  }

  /// Clear cache for better performance
  Future<void> _clearCache() async {
    await CacheConfig.clearAllCache();
    showToast(title: 'Success', description: "Cache cleared successfully!");
  }

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Usage Example'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadInitialData,
          ),
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: _clearCache,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadInitialData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // User info
                  if (currentUser != null)
                    Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: currentUser?.profilePicture != null
                              ? NetworkImage(currentUser!.profilePicture!)
                              : null,
                          child: currentUser?.profilePicture == null
                              ? const Icon(Icons.person)
                              : null,
                        ),
                        title: Text(currentUser?.name ?? 'Unknown'),
                        subtitle: Text(currentUser?.email ?? ''),
                        trailing: Text(
                            '${currentUser?.interests?.length ?? 0} interests'),
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Categories
                  if (categories.isNotEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Categories',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              children: categories
                                  .map((category) => Chip(
                                        label: Text(category.name ?? ''),
                                        backgroundColor: category.color != null
                                            ? Color(int.parse(category.color!
                                                .replaceFirst('#', '0xFF')))
                                            : null,
                                      ))
                                  .toList(),
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Posts
                  if (posts.isNotEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Posts',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            ...posts.take(3).map((post) => ListTile(
                                  leading: post.mediaUrl != null
                                      ? Image.network(post.mediaUrl!,
                                          width: 50,
                                          height: 50,
                                          fit: BoxFit.cover)
                                      : const Icon(Icons.image),
                                  title: Text(post.caption ?? ''),
                                  subtitle:
                                      Text('${post.likesCount ?? 0} likes'),
                                  trailing: IconButton(
                                    icon: Icon(
                                      post.isLiked == true
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: post.isLiked == true
                                          ? Colors.red
                                          : null,
                                    ),
                                    onPressed: () => _toggleLike(post),
                                  ),
                                )),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Action buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: _createPost,
                        child: const Text('Create Post'),
                      ),
                      ElevatedButton(
                        onPressed: () =>
                            _searchUsersByInterests(['Hair Styling', 'Beauty']),
                        child: const Text('Search Users'),
                      ),
                      ElevatedButton(
                        onPressed: _loadBusinessAccounts,
                        child: const Text('Business'),
                      ),
                      ElevatedButton(
                        onPressed: _loadNotifications,
                        child: const Text('Notifications'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadInitialData,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
