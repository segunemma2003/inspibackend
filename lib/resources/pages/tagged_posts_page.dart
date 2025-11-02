import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '/config/app_colors.dart';
import '/app/networking/post_api_service.dart';
import '/app/models/post.dart';
import '/resources/widgets/smart_media_widget.dart';

class TaggedPostsPage extends StatefulWidget {
  static RouteView path = ("/tagged-posts", (_) => TaggedPostsPage());
  const TaggedPostsPage({super.key});

  @override
  createState() => _TaggedPostsPageState();
}

class _TaggedPostsPageState extends NyState<TaggedPostsPage> {
  List<Post> _taggedPosts = [];
  bool _isLoading = true;
  bool _hasMore = true;
  int _currentPage = 1;

  @override
  get init => () async {
        await _loadTaggedPosts(1);
      };

  Future<void> _loadTaggedPosts(int page, {bool forceRefresh = false}) async {
    if (!_hasMore && page > 1) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await api<PostApiService>(
        (request) => request.getTaggedPosts(
          perPage: 20,
          page: page,
        ),
      );

      if (response != null && response['success'] == true) {
        final List<dynamic> postsData = response['data']['data'] ?? [];
        final List<Post> newPosts =
            postsData.map((json) => Post.fromJson(json)).toList();

        setState(() {
          if (page == 1) {
            _taggedPosts = newPosts;
          } else {
            _taggedPosts.addAll(newPosts);
          }
          _currentPage = response['data']['current_page'] ?? page;
          _hasMore = _currentPage < (response['data']['last_page'] ?? 1);
        });
      }
    } catch (e) {
      print("Error loading tagged posts: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundPrimary,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
        ),
        title: const Text(
          'Tagged Posts',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading && _taggedPosts.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _taggedPosts.isEmpty
              ? _buildEmptyState()
              : _buildPostsGrid(),
    );
  }

  Widget _buildPostsGrid() {
    return RefreshIndicator(
      onRefresh: () => _loadTaggedPosts(1, forceRefresh: true),
      child: GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
        ),
        itemCount: _taggedPosts.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _taggedPosts.length) {
            if (_hasMore) {
              _loadTaggedPosts(_currentPage + 1);
              return const Center(child: CircularProgressIndicator());
            }
            return const SizedBox.shrink();
          }

          final post = _taggedPosts[index];
          return _buildPostItem(post);
        },
      ),
    );
  }

  Widget _buildPostItem(Post post) {
    return GestureDetector(
      onTap: () {
        showToast(title: "Post", description: "Post ${post.id} tapped.");
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Stack(
          children: [
            SmartMediaWidget(
              post: post,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),

            Positioned(
              top: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.primaryPink.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.person_add,
                  color: Colors.white,
                  size: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_add, size: 80, color: AppColors.textTertiary),
            const SizedBox(height: 16),
            const Text(
              'No Tagged Posts',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'You haven\'t been tagged in any posts yet.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
