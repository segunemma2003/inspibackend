import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '../../app/networking/user_api_service.dart';
import '../../app/models/user.dart';

class SearchUsersPage extends NyStatefulWidget {
  static RouteView path = ("/search-users", (_) => SearchUsersPage());

  SearchUsersPage({super.key}) : super(child: () => _SearchUsersPageState());
}

class _SearchUsersPageState extends NyPage<SearchUsersPage> {
  final TextEditingController _searchController = TextEditingController();
  List<User> _searchResults = [];
  List<User> _allUsers = [];
  bool _isSearching = false;
  bool _isLoading = true;
  String _lastQuery = '';
  int? _currentUserId;

  @override
  get init => () async {
        await _loadCurrentUser();
        await _loadAllUsers();
      };

  Future<void> _loadCurrentUser() async {
    try {
      final user =
          await api<UserApiService>((request) => request.fetchCurrentUser());
      if (user != null) {
        _currentUserId = user.id;
      }
    } catch (e) {
      print('❌ SearchUsersPage: Error loading current user: $e');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAllUsers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await api<UserApiService>(
        (request) => request.getUsers(
          perPage: 50, // Load more users initially
          page: 1,
        ),
      );

      if (response != null && response['success'] == true) {
        final List<dynamic> usersData = response['data']['data'] ?? [];
        final List<User> users =
            usersData.map((json) => User.fromJson(json)).toList();

        final filteredUsers =
            users.where((user) => user.id != _currentUserId).toList();

        setState(() {
          _allUsers = filteredUsers;
          _searchResults =
              filteredUsers; // Show all users initially (excluding current user)
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ SearchUsersPage: Error loading all users: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _searchUsers(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = _allUsers; // Show all users when search is empty
        _isSearching = false;
      });
      return;
    }

    if (query == _lastQuery) return;

    setState(() {
      _isSearching = true;
      _lastQuery = query;
    });

    final filteredUsers = _allUsers.where((user) {

      if (user.id == _currentUserId) return false;

      final name = user.fullName?.toLowerCase() ?? '';
      final username = user.username?.toLowerCase() ?? '';
      final searchQuery = query.toLowerCase();

      return name.contains(searchQuery) || username.contains(searchQuery);
    }).toList();

    setState(() {
      _searchResults = filteredUsers;
      _isSearching = false;
    });
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
      print('❌ SearchUsersPage: Error toggling follow: $e');
    }
  }

  void _navigateToUserProfile(User user) {
    routeTo('/user-profile', data: {'userId': user.id});
  }

  Widget _buildUserItem(User user) {

    final colors = [
      Color(0xFF00C3F1), // #00C3F1
      Color(0xFFFD4CC0), // #FD4CC0
      Color(0xFFFFCF02), // #FFCF02
      Color(0xFFB5DA64), // #B5DA64
    ];

    final userColor = colors[user.id.hashCode.abs() % colors.length];

    return ListTile(
      leading: CircleAvatar(
        backgroundImage: user.profilePicture != null
            ? NetworkImage(user.profilePicture!)
            : null,
        backgroundColor: userColor,
        child: user.profilePicture == null
            ? Text(user.name?.substring(0, 1).toUpperCase() ?? '?',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
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
              backgroundColor:
                  user.isFollowed == true ? Colors.grey[300] : userColor,
              foregroundColor:
                  user.isFollowed == true ? Colors.black : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(
              user.isFollowed == true ? 'Following' : 'Follow',
              style: TextStyle(fontWeight: FontWeight.w600),
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
        title: const Text('Search Users'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        automaticallyImplyLeading: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search users...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _isSearching
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              onChanged: (value) {
                Future.delayed(const Duration(milliseconds: 300), () {
                  if (_searchController.text == value) {
                    _searchUsers(value);
                  }
                });
              },
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _searchResults.isEmpty && _searchController.text.isNotEmpty
                    ? const Center(
                        child: Text(
                          'No users found',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          return _buildUserItem(_searchResults[index]);
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
