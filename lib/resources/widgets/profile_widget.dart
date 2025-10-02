import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '/app/services/auth_service.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  createState() => _ProfileState();
}

class _ProfileState extends NyState<Profile> {
  bool _isSidebarOpen = false;
  int _selectedTabIndex = 0;
  Map<String, dynamic>? _userData;

  @override
  get init => () async {
        await _loadUserData();
      };

  Future<void> _loadUserData() async {
    _userData = await AuthService.instance.getUserProfile();
    setState(() {});
  }

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // Top Bar
                _buildTopBar(),

                // Profile Content
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 20),

                        // Profile Picture
                        _buildProfilePicture(),

                        const SizedBox(height: 20),

                        // Name and Bio
                        _buildNameAndBio(),

                        const SizedBox(height: 30),

                        // Category Icons
                        _buildCategoryIcons(),

                        const SizedBox(height: 30),

                        // Tab Bar
                        _buildTabBar(),

                        const SizedBox(height: 20),

                        // Posts Grid
                        _buildPostsGrid(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Sidebar Overlay
          if (_isSidebarOpen) _buildSidebarOverlay(),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      child: Row(
        children: [
          // Back Button
          Icon(
            Icons.arrow_back,
            size: 24,
            color: Colors.black,
          ),

          const SizedBox(width: 16),

          // Username
          Expanded(
            child: Text(
              'sarah_johnson',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),

          // Edit Button
          GestureDetector(
            onTap: () {
              routeTo('/edit-profile');
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'EDIT',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Menu Button
          GestureDetector(
            onTap: () {
              setState(() {
                _isSidebarOpen = true;
              });
            },
            child: Icon(
              Icons.menu,
              size: 24,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfilePicture() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            Color(0xFFFF69B4),
            Color(0xFFFFD700),
            Color(0xFF9ACD32),
            Color(0xFF00BFFF),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Container(
        margin: EdgeInsets.all(3),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
        ),
        child: ClipOval(
          child: Image.asset(
            'assets/images/profile_placeholder.jpg',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey[200],
                child: Icon(
                  Icons.person,
                  size: 60,
                  color: Colors.grey[400],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildNameAndBio() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          Text(
            _userData?['name'] ?? _userData?['full_name'] ?? 'User',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '@${_userData?['username'] ?? 'username'}',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _userData?['bio'] ??
                'Welcome to Inspiritag! Express yourself and inspire others.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          // Logout Button
          ElevatedButton(
            onPressed: _logout,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[50],
              foregroundColor: Colors.red[700],
              side: BorderSide(color: Colors.red[300]!),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    // Show confirmation dialog
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await AuthService.instance.logout();
      showToast(title: 'Success', description: 'Logged out successfully');
      routeTo('/home');
    }
  }

  Widget _buildCategoryIcons() {
    final categories = [
      {'title': 'STYLE', 'color': Color(0xFFFF69B4)},
      {'title': 'HAIR', 'color': Color(0xFFFFD700)},
      {'title': 'NAILS', 'color': Color(0xFF9ACD32)},
      {'title': 'MAKE-UP', 'color': Color(0xFFFF8C00)},
      {'title': 'FITNESS', 'color': Color(0xFF00BFFF)},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: categories.map((category) {
          return Column(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: category['color'] as Color,
                ),
                child: Container(
                  margin: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: Icon(
                    _getCategoryIcon(category['title'] as String),
                    size: 20,
                    color: category['color'] as Color,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                category['title'] as String,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'STYLE':
        return Icons.checkroom;
      case 'HAIR':
        return Icons.face_retouching_natural;
      case 'NAILS':
        return Icons.pan_tool;
      case 'MAKE-UP':
        return Icons.palette;
      case 'FITNESS':
        return Icons.fitness_center;
      default:
        return Icons.category;
    }
  }

  Widget _buildTabBar() {
    final tabs = [
      {'icon': Icons.grid_on, 'title': 'Posts', 'isActive': true},
      {'icon': Icons.person_pin, 'title': 'Tagged', 'isActive': false},
      {'icon': Icons.bookmark_border, 'title': 'Saved', 'isActive': false},
    ];

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: tabs.asMap().entries.map((entry) {
          int index = entry.key;
          Map<String, dynamic> tab = entry.value;
          bool isSelected = _selectedTabIndex == index;

          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTabIndex = index;
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isSelected ? Colors.black : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Icon(
                  tab['icon'] as IconData,
                  color: isSelected ? Colors.black : Colors.grey[400],
                  size: 24,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPostsGrid() {
    // Sample post data
    final posts = List.generate(
        6,
        (index) => {
              'id': index,
              'hasVideo': index % 3 == 2,
              'hasMultiple': index % 4 == 0,
            });

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
          childAspectRatio: 1,
        ),
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          return _buildPostItem(post);
        },
      ),
    );
  }

  Widget _buildPostItem(Map<String, dynamic> post) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Stack(
        children: [
          // Placeholder image
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              gradient: LinearGradient(
                colors: [Colors.blue[200]!, Colors.green[200]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Icon(
              Icons.image,
              color: Colors.white.withOpacity(0.7),
              size: 30,
            ),
          ),

          // Video indicator
          if (post['hasVideo'] == true)
            Positioned(
              top: 8,
              right: 8,
              child: Icon(
                Icons.play_circle_filled,
                color: Colors.white,
                size: 20,
              ),
            ),

          // Multiple images indicator
          if (post['hasMultiple'] == true)
            Positioned(
              top: 8,
              right: 8,
              child: Icon(
                Icons.copy,
                color: Colors.white,
                size: 16,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSidebarOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.6),
      child: Row(
        children: [
          // Sidebar
          Container(
            width: MediaQuery.of(context).size.width * 0.85,
            height: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 5,
                  blurRadius: 15,
                  offset: Offset(-2, 0),
                ),
              ],
            ),
            child: Column(
              children: [
                // Sidebar Header
                Container(
                  padding: EdgeInsets.fromLTRB(24, 40, 24, 24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFFFF69B4),
                        Color(0xFF00BFFF),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Close button and title row
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Menu',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _isSidebarOpen = false;
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      // User info
                      Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.2),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Sarah Johnson',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  'sarah_johnson',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Menu Items
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    children: [
                      _buildSidebarItem(Icons.home_outlined, 'Feed', '/base',
                          isHighlighted: true),
                      _buildSidebarItem(Icons.person_outline, 'Edit Profile',
                          '/edit-profile'),
                      _buildSidebarItem(
                          Icons.settings_outlined, 'Settings', '/settings'),
                      _buildSidebarItem(Icons.business_outlined,
                          'Business Profile', '/businessprofile'),
                      _buildSidebarItem(Icons.privacy_tip_outlined,
                          'Privacy Policy', '/privacy'),
                      _buildSidebarItem(Icons.description_outlined,
                          'Terms & Conditions', '/terms'),
                      _buildSidebarItem(
                          Icons.help_outline, 'Help & Support', '/support'),
                      _buildSidebarItem(
                          Icons.info_outline, 'About Us', '/about'),

                      // Logout section
                      SizedBox(height: 20),
                      Divider(color: Colors.grey[200], height: 1),
                      SizedBox(height: 8),
                      _buildSidebarItem(Icons.logout, 'Logout', '/logout',
                          isDestructive: true),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Overlay to close sidebar
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isSidebarOpen = false;
                });
              },
              child: Container(color: Colors.transparent),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(IconData icon, String title, String route,
      {bool isHighlighted = false, bool isDestructive = false}) {
    Color iconColor = isDestructive
        ? Colors.red
        : (isHighlighted ? Color(0xFF00BFFF) : Colors.grey[600]!);
    Color textColor = isDestructive ? Colors.red : Colors.grey[800]!;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            setState(() {
              _isSidebarOpen = false;
            });
            // Navigate to route
            routeTo(route);
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: isHighlighted
                  ? Color(0xFF00BFFF).withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 20,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight:
                          isHighlighted ? FontWeight.w600 : FontWeight.w500,
                      color: textColor,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey[400],
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
