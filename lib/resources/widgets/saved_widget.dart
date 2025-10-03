import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '/app/networking/post_api_service.dart';
import '/app/models/post.dart';
import '/resources/widgets/smart_media_widget.dart';

class Saved extends StatefulWidget {
  const Saved({super.key});

  @override
  createState() => _SavedState();
}

class _SavedState extends NyState<Saved> {
  List<Post> _savedPosts = [];
  bool _isLoading = false;
  int _currentPage = 1;
  bool _hasMorePosts = true;
  final ScrollController _scrollController = ScrollController();

  @override
  get init => () async {
        await _loadSavedPosts();
        _scrollController.addListener(_onScroll);
      };

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoading &&
        _hasMorePosts) {
      _loadMorePosts();
    }
  }

  Future<void> _loadSavedPosts({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _currentPage = 1;
        _hasMorePosts = true;
        _savedPosts.clear();
      });
    }

    setState(() => _isLoading = true);

    try {
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
          if (refresh) {
            _savedPosts = newPosts;
          } else {
            _savedPosts.addAll(newPosts);
          }
          _hasMorePosts = newPosts.length == 20;
          _currentPage++;
        });
      }
    } catch (e) {
      print('Error loading saved posts: $e');
      showToast(title: 'Error', description: 'Failed to load saved posts');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadMorePosts() async {
    await _loadSavedPosts();
  }

  Future<void> _unsavePost(Post post) async {
    try {
      final response = await api<PostApiService>(
        (request) => request.toggleSave(post.id!),
      );

      if (response != null && response['success'] == true) {
        setState(() {
          _savedPosts.removeWhere((p) => p.id == post.id);
        });
        showToast(title: 'Success', description: 'Post removed from saved');
      }
    } catch (e) {
      print('Error unsaving post: $e');
      showToast(title: 'Error', description: 'Failed to unsave post');
    }
  }

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Logo Section
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'logo.png',
                width: 60,
                height: 60,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.image_not_supported,
                    size: 30,
                    color: Colors.grey[400],
                  );
                },
              ).localAsset(),
            ),
          ),
          const SizedBox(height: 12),

          // App Name
          RichText(
            text: const TextSpan(
              children: [
                TextSpan(
                  text: 'inspi',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFFF69B4),
                    letterSpacing: -0.5,
                    fontFamily: 'Roboto',
                  ),
                ),
                TextSpan(
                  text: 'r',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFFFD700),
                    letterSpacing: -0.5,
                    fontFamily: 'Roboto',
                  ),
                ),
                TextSpan(
                  text: 'tag',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF00BFFF),
                    letterSpacing: -0.5,
                    fontFamily: 'Roboto',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Saved Posts Title
          const Text(
            'Saved Posts',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading && _savedPosts.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF69B4)),
        ),
      );
    }

    if (_savedPosts.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () => _loadSavedPosts(refresh: true),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _savedPosts.length + (_hasMorePosts ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _savedPosts.length) {
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF69B4)),
                ),
              ),
            );
          }

          final post = _savedPosts[index];
          return _buildPostCard(post);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bookmark_border,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Saved Posts',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Posts you save will appear here',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard(Post post) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post Header (User info)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // User Avatar
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: post.user?.profilePicture != null
                      ? NetworkImage(post.user!.profilePicture!)
                      : null,
                  child: post.user?.profilePicture == null
                      ? Icon(
                          Icons.person,
                          color: Colors.grey[400],
                          size: 20,
                        )
                      : null,
                ),
                const SizedBox(width: 12),

                // User Name and Time
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.user?.fullName ??
                            post.user?.username ??
                            'Unknown User',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        '@${post.user?.username ?? 'unknown'}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),

                // Unsave Button
                GestureDetector(
                  onTap: () => _unsavePost(post),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.bookmark,
                      color: Colors.red[400],
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Post Media
          if (post.mediaUrl != null)
            Container(
              width: double.infinity,
              height: 300,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(16),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(16),
                ),
                child: SmartMediaWidget(
                  post: post,
                  height: 300,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),

          // Post Caption
          if (post.caption != null && post.caption!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                post.caption!,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),
            ),

          // Post Stats and Actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Likes
                Row(
                  children: [
                    Icon(
                      Icons.favorite_border,
                      size: 20,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${post.likesCount ?? 0}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),

                // Category
                if (post.category != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF69B4).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      post.category!.name ?? 'Category',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFFFF69B4),
                      ),
                    ),
                  ),

                const Spacer(),

                // Saved indicator
                Icon(
                  Icons.bookmark,
                  size: 16,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
