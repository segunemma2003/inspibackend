import 'dart:io';
import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:file_picker/file_picker.dart';
import '/app/networking/user_api_service.dart';
import '/app/networking/auth_api_service.dart';
import '/app/networking/search_api_service.dart';
import '/app/models/user.dart';
import '/app/services/auth_service.dart';

class EditProfilePage extends NyStatefulWidget {
  static RouteView path = ("/edit-profile", (_) => EditProfilePage());

  EditProfilePage({super.key}) : super(child: () => _EditProfilePageState());
}

class _EditProfilePageState extends NyPage<EditProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _professionController = TextEditingController();

  // Profile picture
  PlatformFile? _selectedProfilePicture;
  String? _currentProfilePictureUrl;
  bool _isUploadingPicture = false;

  // User data
  User? _currentUser;
  bool _isLoadingUser = false;
  bool _isSaving = false;

  // Interests
  List<String> _availableInterests = [];
  List<String> _selectedInterests = [];
  bool _isLoadingInterests = false;

  @override
  get init => () async {
        await _debugAuthData();
        await _loadUserData();
        await _loadInterests();
      };

  Future<void> _debugAuthData() async {
    try {
      print('🔍 EditProfile: Debugging Auth data...');
      final authData = await Auth.data();
      print('🔍 EditProfile: Raw Auth.data(): $authData');
      print('🔍 EditProfile: Auth data type: ${authData.runtimeType}');
      if (authData != null) {
        print('🔍 EditProfile: Auth data keys: ${authData.keys}');
        if (authData.containsKey('user')) {
          print('🔍 EditProfile: User data: ${authData['user']}');
          print(
              '🔍 EditProfile: User data type: ${authData['user'].runtimeType}');
        }
        if (authData.containsKey('token')) {
          print('🔍 EditProfile: Token: ${authData['token']}');
        }
      }
    } catch (e) {
      print('❌ EditProfile: Error debugging auth data: $e');
    }
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoadingUser = true);

    try {
      print('🔄 EditProfile: Loading user data...');

      // First try to get user data from AuthService (cached data)
      final cachedUserData = await AuthService.instance.getUserProfile();
      print('📱 EditProfile: Cached user data: $cachedUserData');
      print(
          '📱 EditProfile: Cached user data type: ${cachedUserData.runtimeType}');
      if (cachedUserData != null) {
        print('📱 EditProfile: Cached user data keys: ${cachedUserData.keys}');
        print('📱 EditProfile: Name field: ${cachedUserData['name']}');
        print(
            '📱 EditProfile: Full name field: ${cachedUserData['full_name']}');
        print('📱 EditProfile: Username field: ${cachedUserData['username']}');
      }

      if (cachedUserData != null) {
        _populateUserData(cachedUserData);
        print('✅ EditProfile: Populated from cache');
      }

      // Then fetch fresh data from API
      print('🌐 EditProfile: Fetching fresh data from API...');
      final response = await api<AuthApiService>(
        (request) => request.getCurrentUser(),
      );

      print('📡 EditProfile: API response: $response');
      print('📡 EditProfile: Response type: ${response.runtimeType}');

      if (response != null) {
        // Handle different response structures
        User? user;
        if (response is User) {
          user = response;
          print('✅ EditProfile: Response is User object');
        } else if (response is Map<String, dynamic>) {
          print('📋 EditProfile: Response is Map, keys: ${response.keys}');
          if (response.containsKey('data') &&
              response['data'] is Map<String, dynamic>) {
            final data = response['data'];
            if (data.containsKey('user') &&
                data['user'] is Map<String, dynamic>) {
              user = User.fromJson(data['user']);
              print('✅ EditProfile: Created user from response.data.user');
            } else {
              user = User.fromJson(data);
              print('✅ EditProfile: Created user from response.data');
            }
          } else if (response.containsKey('user') &&
              response['user'] is Map<String, dynamic>) {
            user = User.fromJson(response['user']);
            print('✅ EditProfile: Created user from response.user');
          } else {
            user = User.fromJson(response);
            print('✅ EditProfile: Created user from response directly');
          }
        }

        if (user != null) {
          setState(() {
            _currentUser = user;
          });
          _populateUserData({
            'full_name': user.fullName,
            'username': user.username,
            'bio': user.bio,
            'profession': user.profession,
            'profile_picture': user.profilePicture,
            'interests': user.interests,
          });
          print(
              '✅ EditProfile: User data loaded successfully: ${user.fullName}');
        } else {
          print('❌ EditProfile: Failed to create user object');
        }
      } else {
        print('❌ EditProfile: API response is null');
      }
    } catch (e, stackTrace) {
      print('❌ EditProfile: Error loading user data: $e');
      print('📍 EditProfile: Stack trace: $stackTrace');
      showToast(title: 'Error', description: 'Failed to load profile data');
    } finally {
      setState(() => _isLoadingUser = false);
    }
  }

  void _populateUserData(Map<String, dynamic> userData) {
    print('🔄 EditProfile: Populating form with data: $userData');

    // First create and store the User object (same as profile widget)
    try {
      final user = User.fromJson(userData);
      print(
          '🔄 EditProfile: Created user object - name: ${user.name}, fullName: ${user.fullName}');
      setState(() {
        _currentUser = user;
      });
      print('✅ EditProfile: User set in state: ${_currentUser?.fullName}');
    } catch (e) {
      print('Error parsing cached user data: $e');
      // Fallback: create user with basic info
      setState(() {
        final user = User();
        user.id = userData['id'];
        user.fullName =
            userData['full_name']?.toString() ?? userData['name']?.toString();
        user.username = userData['username']?.toString();
        user.email = userData['email']?.toString();
        user.bio = userData['bio']?.toString();
        user.profession = userData['profession']?.toString();
        user.profilePicture = userData['profile_picture']?.toString();
        user.interests = userData['interests'] is List
            ? List<String>.from(userData['interests'])
            : null;
        _currentUser = user;
      });
    }

    // Then populate the form controllers
    setState(() {
      _nameController.text = userData['full_name']?.toString() ??
          userData['name']?.toString() ??
          '';
      _usernameController.text = userData['username']?.toString() ?? '';
      _bioController.text = userData['bio']?.toString() ?? '';
      _professionController.text = userData['profession']?.toString() ?? '';
      _currentProfilePictureUrl = userData['profile_picture']?.toString();

      if (userData['interests'] != null) {
        if (userData['interests'] is List) {
          _selectedInterests = List<String>.from(userData['interests']);
        } else if (userData['interests'] is String) {
          _selectedInterests = [userData['interests']];
        }
      }
    });

    print(
        '✅ EditProfile: Form populated - Name: ${_nameController.text}, Username: ${_usernameController.text}');
  }

  Future<void> _loadInterests() async {
    setState(() => _isLoadingInterests = true);

    try {
      final response = await api<SearchApiService>(
        (request) => request.getInterests(),
      );

      if (response != null) {
        setState(() {
          _availableInterests = List<String>.from(response);
        });
      }
    } catch (e) {
      print('Error loading interests: $e');
    } finally {
      setState(() => _isLoadingInterests = false);
    }
  }

  @override
  Widget view(BuildContext context) {
    print(
        '🎨 EditProfile: Building UI - currentUser: ${_currentUser?.fullName}');
    print(
        '🎨 EditProfile: Building UI - form values: name="${_nameController.text}", username="${_usernameController.text}"');
    print(
        '🎨 EditProfile: Building UI - currentUser is null: ${_currentUser == null}');

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 30),
                      _buildEditProfileCard(),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back,
                size: 20,
                color: Colors.black87,
              ),
            ),
          ),
          const Spacer(),
          const Text(
            'Edit Profile',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: _isSaving ? null : _saveProfile,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: _isSaving
                    ? null
                    : const LinearGradient(
                        colors: [Color(0xFFFF69B4), Color(0xFF9C27B0)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                color: _isSaving ? Colors.grey[400] : null,
                borderRadius: BorderRadius.circular(20),
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'SAVE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditProfileCard() {
    if (_isLoadingUser) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF69B4)),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Section
        Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: const LinearGradient(
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
                margin: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                ),
                child: Icon(
                  Icons.edit,
                  color: Colors.grey[700],
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Edit Profile',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF7B68EE),
                      fontFamily: 'Roboto',
                    ),
                  ),
                  Text(
                    'Update your profile information',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Roboto',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 30),

        // Profile Picture Section
        Center(
          child: Column(
            children: [
              Stack(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: const BoxDecoration(
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
                      margin: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: ClipOval(
                        child: _buildProfileImage(),
                      ),
                    ),
                  ),
                  if (_isUploadingPicture)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withOpacity(0.5),
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: _isUploadingPicture ? null : _pickProfilePicture,
                child: Text(
                  _isUploadingPicture ? 'Uploading...' : 'Change profile photo',
                  style: TextStyle(
                    fontSize: 14,
                    color: _isUploadingPicture
                        ? Colors.grey
                        : const Color(0xFF7B68EE),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 30),

        // Form Fields
        _buildTextField(
          label: 'Full Name *',
          controller: _nameController,
          icon: Icons.person_outline,
        ),

        const SizedBox(height: 20),

        _buildTextField(
          label: 'Username *',
          controller: _usernameController,
          icon: Icons.alternate_email,
        ),

        const SizedBox(height: 20),

        _buildTextField(
          label: 'Profession',
          controller: _professionController,
          icon: Icons.work_outline,
        ),

        const SizedBox(height: 20),

        _buildTextField(
          label: 'Bio',
          controller: _bioController,
          icon: Icons.description_outlined,
          maxLines: 4,
        ),

        const SizedBox(height: 24),

        // Interests Section
        _buildInterestsSection(),

        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildProfileImage() {
    if (_selectedProfilePicture != null) {
      return Image.file(
        File(_selectedProfilePicture!.path!),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    } else if (_currentProfilePictureUrl != null) {
      return Image.network(
        _currentProfilePictureUrl!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[200],
            child: Icon(
              Icons.person,
              size: 50,
              color: Colors.grey[400],
            ),
          );
        },
      );
    } else {
      return Container(
        color: Colors.grey[200],
        child: Icon(
          Icons.person,
          size: 50,
          color: Colors.grey[400],
        ),
      );
    }
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    int maxLines = 1,
  }) {
    print(
        '🎨 EditProfile: _buildTextField "$label" - value: "${controller.text}"');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(
                icon,
                color: Colors.grey[500],
                size: 20,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              hintText: 'Enter ${label.replaceAll('*', '').trim()}...',
              hintStyle: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInterestsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Interests',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        if (_isLoadingInterests)
          const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF69B4)),
            ),
          )
        else
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select your interests (tap to toggle)',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _availableInterests.map((interest) {
                    final isSelected = _selectedInterests.contains(interest);
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedInterests.remove(interest);
                          } else {
                            _selectedInterests.add(interest);
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFFF69B4).withOpacity(0.1)
                              : Colors.white,
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFFFF69B4)
                                : Colors.grey[300]!,
                            width: isSelected ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          interest,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w400,
                            color: isSelected
                                ? const Color(0xFFFF69B4)
                                : Colors.grey[700],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                if (_selectedInterests.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Selected: ${_selectedInterests.length} interests',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }

  Future<void> _pickProfilePicture() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final file = result.files.single;

        // Check file size (5MB limit for profile pictures)
        if (file.size > 5 * 1024 * 1024) {
          showToast(
              title: 'File Too Large',
              description: 'Please select an image smaller than 5MB');
          return;
        }

        setState(() {
          _selectedProfilePicture = file;
        });
      }
    } catch (e) {
      print('Error picking profile picture: $e');
      showToast(title: 'Error', description: 'Failed to pick image');
    }
  }

  Future<void> _saveProfile() async {
    // Validate required fields
    if (_nameController.text.trim().isEmpty ||
        _usernameController.text.trim().isEmpty) {
      showToast(title: 'Error', description: 'Name and username are required');
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Update profile
      final response = await api<UserApiService>(
        (request) => request.updateProfile(
          fullName: _nameController.text.trim(),
          username: _usernameController.text.trim(),
          bio: _bioController.text.trim(),
          profession: _professionController.text.trim(),
          profilePicture: _selectedProfilePicture != null
              ? File(_selectedProfilePicture!.path!)
              : null, // Only pass File if there's a new picture
          interests: _selectedInterests,
        ),
      );

      if (response != null && response['success'] == true) {
        showToast(
            title: 'Success', description: 'Profile updated successfully!');
        Navigator.of(context).pop();
      } else {
        throw Exception('Failed to update profile');
      }
    } catch (e) {
      print('Error saving profile: $e');
      showToast(title: 'Error', description: 'Failed to update profile');
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    _professionController.dispose();
    super.dispose();
  }
}
