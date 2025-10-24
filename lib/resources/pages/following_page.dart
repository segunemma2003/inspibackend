import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '../../app/networking/user_api_service.dart';
import '../../app/models/user.dart';

class FollowingPage extends NyStatefulWidget {
  static RouteView path = ("/following", (_) => FollowingPage());

  FollowingPage({super.key}) : super(child: () => _FollowingPageState());
}

class _FollowingPageState extends NyPage<FollowingPage> {
  List<User> _following = [];
  bool _isLoading = true;
  int _currentPage = 1;
  bool _hasMore = true;
  int? _userId;

  @override
  get init => () async {
        _userId = widget.data()['userId'];

        await _loadFollowing();
      };

  Future<void> _loadFollowing({bool refresh = false}) async {
    if (_userId == null) {
      // print('❌ FollowingPage: No userId provided');
      setState(() {
        _isLoading = false;
      });
      return;
    }

    if (refresh) {
      _currentPage = 1;
      _following.clear();
      _hasMore = true;
    }

    if (!_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    print(
        '📱 FollowingPage: Loading following for user $_userId, page $_currentPage');

    try {
      print(
          '📱 FollowingPage: Making API call to getUserFollowing for user $_userId, page $_currentPage');

      final response = await api<UserApiService>(
        (request) => request.getUserFollowing(
          _userId!,
          perPage: 20,
          page: _currentPage,
        ),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          print('⏰ FollowingPage: API call timed out');
          return null;
        },
      );

      print('📱 FollowingPage: API response received: $response');
      print('📱 FollowingPage: Response type: ${response.runtimeType}');
      print('📱 FollowingPage: Response success: ${response?['success']}');
      print('📱 FollowingPage: Response data: ${response?['data']}');

      if (response != null && response['success'] == true) {
        // Handle different response structures
        List<dynamic> followingData = [];

        if (response['data'] is Map && response['data']['data'] != null) {
          followingData = response['data']['data'] ?? [];
        } else if (response['data'] is List) {
          followingData = response['data'] ?? [];
        } else {
          print(
              '📱 FollowingPage: Unexpected response structure: ${response['data']}');
          followingData = [];
        }

        final List<User> newFollowing =
            followingData.map((json) => User.fromJson(json)).toList();

        print('📱 FollowingPage: Loaded ${newFollowing.length} following');

        if (mounted) {
          setState(() {
            if (refresh) {
              _following = newFollowing;
            } else {
              _following.addAll(newFollowing);
            }
            _currentPage++;
            _hasMore = newFollowing.length == 20;
            _isLoading = false;
          });
        }
      } else {
        print('📱 FollowingPage: API returned unsuccessful response or null');
        print('📱 FollowingPage: Response: $response');

        // Try to clear cache and retry once
        if (_currentPage == 1) {
          print('📱 FollowingPage: Attempting to clear cache and retry...');
          try {
            await cache().clear('following_${_userId}_*');
            print('📱 FollowingPage: Cache cleared, retrying API call...');

            final retryResponse = await api<UserApiService>(
              (request) => request.getUserFollowing(
                _userId!,
                perPage: 20,
                page: _currentPage,
              ),
            ).timeout(
              const Duration(seconds: 5),
              onTimeout: () {
                print('⏰ FollowingPage: Retry API call timed out');
                return null;
              },
            );

            print('📱 FollowingPage: Retry response: $retryResponse');

            if (retryResponse != null && retryResponse['success'] == true) {
              List<dynamic> followingData = [];
              if (retryResponse['data'] is Map &&
                  retryResponse['data']['data'] != null) {
                followingData = retryResponse['data']['data'] ?? [];
              } else if (retryResponse['data'] is List) {
                followingData = retryResponse['data'] ?? [];
              }

              final List<User> newFollowing =
                  followingData.map((json) => User.fromJson(json)).toList();
              print(
                  '📱 FollowingPage: Retry loaded ${newFollowing.length} following');

              if (mounted) {
                setState(() {
                  _following = newFollowing;
                  _currentPage++;
                  _hasMore = newFollowing.length == 20;
                  _isLoading = false;
                });
              }
              return;
            }
          } catch (retryError) {
            print('❌ FollowingPage: Retry failed: $retryError');
          }
        }

        if (mounted) {
          setState(() {
            _isLoading = false;
            _hasMore = false; // Stop trying to load more
          });
        }
      }
    } catch (e) {
      print('❌ FollowingPage: Error loading following: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
      print('❌ FollowingPage: Error toggling follow: $e');
    }
  }

  void _navigateToUserProfile(User user) {
    routeTo('/user-profile', data: {'userId': user.id});
  }

  Widget _buildFollowingItem(User user) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: user.profilePicture != null
            ? NetworkImage(user.profilePicture!)
            : null,
        child: user.profilePicture == null
            ? Text(user.name?.substring(0, 1).toUpperCase() ?? '?')
            : null,
      ),
      title: Text(user.fullName ?? user.name ?? 'Unknown'),
      subtitle: Text('@${user.username ?? ''}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
            onPressed: () => _toggleFollow(user),
            style: ElevatedButton.styleFrom(
              backgroundColor: user.isFollowed == true
                  ? Colors.grey[300]
                  : Theme.of(context).primaryColor,
              foregroundColor:
                  user.isFollowed == true ? Colors.black : Colors.white,
            ),
            child: Text(
              user.isFollowed == true ? 'Following' : 'Follow',
            ),
          ),
        ],
      ),
      onTap: () => _navigateToUserProfile(user),
    );
  }

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Following'),
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
        onRefresh: () => _loadFollowing(refresh: true),
        child: _isLoading && _following.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : _following.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person_add_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Not following anyone yet',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'When this user follows someone, they\'ll appear here.',
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
                    itemCount: _following.length + (_hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _following.length) {
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
                      return _buildFollowingItem(_following[index]);
                    },
                  ),
      ),
    );
  }
}
