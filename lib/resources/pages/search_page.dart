import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '/config/app_colors.dart';
import '/app/networking/post_api_service.dart';
import '/app/networking/user_api_service.dart';
import '/app/models/post.dart';
import '/app/models/user.dart';
import '/resources/widgets/smart_media_widget.dart';

class SearchPage extends StatefulWidget {
  static RouteView path = ("/search", (_) => SearchPage());
  const SearchPage({super.key});

  @override
  createState() => _SearchPageState();
}

class _SearchPageState extends NyState<SearchPage>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  late TabController _tabController;
  int _selectedTabIndex = 0;

  // Search results
  List<Post> _posts = [];
  List<User> _users = [];
  List<String> _trendingTags = [];
  List<User> _popularUsers = [];

  // Loading states
  bool _isLoadingPosts = false;
  bool _isLoadingUsers = false;
  bool _isLoadingTrending = false;

  // Search state
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTabIndex = _tabController.index;
      });
    });
    _loadTrendingData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadTrendingData() async {
    setState(() {
      _isLoadingTrending = true;
    });

    try {
      // Load trending searches
      final trendingResponse = await api<PostApiService>(
        (request) => request.get("/search/trending?limit=10"),
      );

      if (trendingResponse != null && trendingResponse['success'] == true) {
        setState(() {
          _trendingTags = List<String>.from(trendingResponse['data']
                      ['trending_tags']
                  ?.map((tag) => tag['name']) ??
              []);
          _popularUsers = (trendingResponse['data']['popular_users'] ?? [])
              .map((user) => User.fromJson(user))
              .toList();
        });
      }
    } catch (e) {
      print('Error loading trending data: $e');
    } finally {
      setState(() {
        _isLoadingTrending = false;
      });
    }
  }

  Future<void> _searchPosts(String query) async {
    if (query.isEmpty) return;

    setState(() {
      _isLoadingPosts = true;
    });

    try {
      final response = await api<PostApiService>(
        (request) => request.post("/search/posts", data: {
          'q': query,
          'per_page': 20,
          'sort_by': 'created_at',
          'sort_order': 'desc',
        }),
      );

      if (response != null && response['success'] == true) {
        final List<dynamic> postsData = response['data']['data'] ?? [];
        setState(() {
          _posts = postsData.map((json) => Post.fromJson(json)).toList();
        });
      }
    } catch (e) {
      print('Error searching posts: $e');
    } finally {
      setState(() {
        _isLoadingPosts = false;
      });
    }
  }

  Future<void> _searchUsers(String query) async {
    if (query.isEmpty) return;

    setState(() {
      _isLoadingUsers = true;
    });

    try {
      final response = await api<UserApiService>(
        (request) => request.post("/search/users", data: {
          'q': query,
          'per_page': 20,
          'sort_by': 'created_at',
          'sort_order': 'desc',
        }),
      );

      if (response != null && response['success'] == true) {
        final List<dynamic> usersData = response['data']['data'] ?? [];
        setState(() {
          _users = usersData.map((json) => User.fromJson(json)).toList();
        });
      }
    } catch (e) {
      print('Error searching users: $e');
    } finally {
      setState(() {
        _isLoadingUsers = false;
      });
    }
  }

  void _performSearch(String query) {
    if (query.trim().isEmpty) {
      setState(() {
        _hasSearched = false;
        _posts.clear();
        _users.clear();
      });
      return;
    }

    setState(() {
      _hasSearched = true;
    });

    switch (_selectedTabIndex) {
      case 0:
        _searchPosts(query);
        break;
      case 1:
        _searchUsers(query);
        break;
      case 2:
        _searchPosts(query); // For now, use posts for tags
        break;
    }
  }

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchHeader(),
            _buildTabBar(),
            Expanded(
              child: _hasSearched
                  ? _buildSearchResults()
                  : _buildTrendingContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.backgroundPrimary,
        border: Border(
          bottom: BorderSide(color: AppColors.borderLight, width: 1),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const Icon(Icons.arrow_back,
                size: 24, color: AppColors.textPrimary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.backgroundSecondary,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                decoration: const InputDecoration(
                  hintText: 'Search posts, users, tags...',
                  hintStyle: TextStyle(color: AppColors.textTertiary),
                  prefixIcon:
                      Icon(Icons.search, color: AppColors.textSecondary),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                style: const TextStyle(color: AppColors.textPrimary),
                onChanged: _performSearch,
                onSubmitted: _performSearch,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.backgroundPrimary,
        border: Border(
          bottom: BorderSide(color: AppColors.borderLight, width: 1),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorColor: AppColors.tabActive,
        labelColor: AppColors.tabActive,
        unselectedLabelColor: AppColors.tabInactive,
        tabs: const [
          Tab(text: 'Posts', icon: Icon(Icons.grid_on, size: 20)),
          Tab(text: 'Users', icon: Icon(Icons.people, size: 20)),
          Tab(text: 'Tags', icon: Icon(Icons.tag, size: 20)),
        ],
      ),
    );
  }

  Widget _buildTrendingContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTrendingSection(),
          const SizedBox(height: 24),
          _buildPopularUsersSection(),
        ],
      ),
    );
  }

  Widget _buildTrendingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Trending',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        if (_isLoadingTrending)
          const Center(child: CircularProgressIndicator())
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                _trendingTags.map((tag) => _buildTrendingChip(tag)).toList(),
          ),
      ],
    );
  }

  Widget _buildTrendingChip(String tag) {
    return GestureDetector(
      onTap: () {
        _searchController.text = tag;
        _performSearch(tag);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          gradient: AppColors.categoryGradient,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          '#$tag',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildPopularUsersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Popular Users',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        if (_popularUsers.isEmpty)
          const Center(child: Text('No popular users found'))
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _popularUsers.length,
            itemBuilder: (context, index) {
              final user = _popularUsers[index];
              return _buildUserCard(user);
            },
          ),
      ],
    );
  }

  Widget _buildUserCard(User user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          _buildUserAvatar(user),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.fullName ?? 'Unknown User',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '@${user.username ?? ''}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (user.bio != null && user.bio!.isNotEmpty)
                  Text(
                    user.bio!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textTertiary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => routeTo('/user-profile', data: {'userId': user.id}),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.buttonPrimary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                'View',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserAvatar(User user) {
    return Container(
      width: 50,
      height: 50,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppColors.profileGradient,
      ),
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.backgroundPrimary,
        ),
        child: ClipOval(
          child: user.profilePicture != null
              ? Image.network(
                  user.profilePicture!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppColors.backgroundTertiary,
                      child: const Icon(Icons.person,
                          size: 25, color: AppColors.textTertiary),
                    );
                  },
                )
              : Container(
                  color: AppColors.backgroundTertiary,
                  child: const Icon(Icons.person,
                      size: 25, color: AppColors.textTertiary),
                ),
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    switch (_selectedTabIndex) {
      case 0:
        return _buildPostsResults();
      case 1:
        return _buildUsersResults();
      case 2:
        return _buildTagsResults();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildPostsResults() {
    if (_isLoadingPosts) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_posts.isEmpty) {
      return _buildEmptyState(
          'No posts found', 'Try searching with different keywords');
    }

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: _posts.length,
      itemBuilder: (context, index) {
        final post = _posts[index];
        return _buildPostItem(post);
      },
    );
  }

  Widget _buildUsersResults() {
    if (_isLoadingUsers) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_users.isEmpty) {
      return _buildEmptyState(
          'No users found', 'Try searching with different keywords');
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _users.length,
      itemBuilder: (context, index) {
        final user = _users[index];
        return _buildUserCard(user);
      },
    );
  }

  Widget _buildTagsResults() {
    return _buildPostsResults(); // For now, show posts for tags
  }

  Widget _buildPostItem(Post post) {
    return GestureDetector(
      onTap: () {
        // Navigate to post detail
        showToast(title: "Post", description: "Post ${post.id} tapped.");
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.borderLight),
        ),
        child: SmartMediaWidget(
          post: post,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
      ),
    );
  }

  Widget _buildEmptyState(String title, String description) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: AppColors.textTertiary),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(
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
