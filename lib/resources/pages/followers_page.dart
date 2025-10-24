import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '../../app/networking/user_api_service.dart';
import '../../app/models/user.dart';

class FollowersPage extends NyStatefulWidget {
  static RouteView path = ("/followers", (_) => FollowersPage());

  FollowersPage({super.key}) : super(child: () => _FollowersPageState());
}

class _FollowersPageState extends NyPage<FollowersPage> {
  List<User> _followers = [];
  bool _isLoading = true;
  int _currentPage = 1;
  bool _hasMore = true;
  int? _userId;

  @override
  get init => () async {
        _userId = widget.data()['userId'];

        await _loadFollowers();
      };

  Future<void> _loadFollowers({bool refresh = false}) async {
    if (_userId == null) {
      // print('❌ FollowersPage: No userId provided');
      setState(() {
        _isLoading = false;
      });
      return;
    }

    if (refresh) {
      _currentPage = 1;
      _followers.clear();
      _hasMore = true;
    }

    if (!_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    print(
        '📱 FollowersPage: Loading followers for user $_userId, page $_currentPage');

    try {
      final response = await api<UserApiService>(
        (request) => request.getUserFollowers(
          _userId!,
          perPage: 20,
          page: _currentPage,
        ),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          print('⏰ FollowersPage: API call timed out');
          return null;
        },
      );

      print('📱 FollowersPage: API response: $response');

      if (response != null && response['success'] == true) {
        // Handle different response structures
        List<dynamic> followersData = [];

        if (response['data'] is Map && response['data']['data'] != null) {
          followersData = response['data']['data'] ?? [];
        } else if (response['data'] is List) {
          followersData = response['data'] ?? [];
        } else {
          print(
              '📱 FollowersPage: Unexpected response structure: ${response['data']}');
          followersData = [];
        }

        final List<User> newFollowers =
            followersData.map((json) => User.fromJson(json)).toList();

        print('📱 FollowersPage: Loaded ${newFollowers.length} followers');

        setState(() {
          if (refresh) {
            _followers = newFollowers;
          } else {
            _followers.addAll(newFollowers);
          }
          _currentPage++;
          _hasMore = newFollowers.length == 20;
          _isLoading = false;
        });
      } else {
        print('📱 FollowersPage: API returned unsuccessful response or null');
        print('📱 FollowersPage: Response: $response');
        setState(() {
          _isLoading = false;
          _hasMore = false; // Stop trying to load more
        });
      }
    } catch (e) {
      print('❌ FollowersPage: Error loading followers: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleFollow(User user) async {
    try {
      if (user.isFollowed == true) {
        await api<UserApiService>(
          (request) => request.unfollowUser(user.id!),
        );
        setState(() {
          user.isFollowed = false;
        });
      } else {
        await api<UserApiService>(
          (request) => request.followUser(user.id!),
        );
        setState(() {
          user.isFollowed = true;
        });
      }
    } catch (e) {
      print('❌ FollowersPage: Error toggling follow: $e');
    }
  }

  void _navigateToUserProfile(User user) {
    routeTo('/user-profile', data: {'userId': user.id});
  }

  Widget _buildFollowerItem(User follower) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: follower.profilePicture != null
            ? NetworkImage(follower.profilePicture!)
            : null,
        child: follower.profilePicture == null
            ? Text(follower.name?.substring(0, 1).toUpperCase() ?? '?')
            : null,
      ),
      title: Text(follower.fullName ?? follower.name ?? 'Unknown'),
      subtitle: Text('@${follower.username ?? ''}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
            onPressed: () => _toggleFollow(follower),
            style: ElevatedButton.styleFrom(
              backgroundColor: follower.isFollowed == true
                  ? Colors.grey[300]
                  : Theme.of(context).primaryColor,
              foregroundColor:
                  follower.isFollowed == true ? Colors.black : Colors.white,
            ),
            child: Text(
              follower.isFollowed == true ? 'Following' : 'Follow',
            ),
          ),
        ],
      ),
      onTap: () => _navigateToUserProfile(follower),
    );
  }

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Followers'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        automaticallyImplyLeading: true,
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadFollowers(refresh: true),
        child: _isLoading && _followers.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : _followers.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No followers yet',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'When someone follows this user, they\'ll appear here.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _followers.length + (_hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _followers.length) {
                        if (_isLoading) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      }
                      return _buildFollowerItem(_followers[index]);
                    },
                  ),
      ),
    );
  }
}
