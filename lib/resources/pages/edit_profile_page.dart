import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

import 'package:flutter_app/app/models/user.dart';
import 'package:flutter_app/app/networking/user_api_service.dart';

import 'package:image_picker/image_picker.dart';
import 'dart:io'; // Required for File

class EditProfilePage extends NyStatefulWidget {
  static RouteView path = ("/edit-profile", (_) => EditProfilePage());

  EditProfilePage({super.key}) : super(child: () => _EditProfilePageState());
}

class _EditProfilePageState extends NyPage<EditProfilePage> {
  User? _currentUser;
  bool _isLoading = true;
  bool _isSaving = false;

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _professionController = TextEditingController();
  final TextEditingController _interestsController = TextEditingController();

  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  @override
  get init => () async {
        await _loadUserProfile();
      };

  Future<void> _loadUserProfile() async {
    try {
      final user = await api<UserApiService>(
        (request) => request.fetchCurrentUser(),
      );

      if (user != null && mounted) {
        print('✅ EditProfile: Fetched user data: ${user.toJson()}');
        setState(() {
          _currentUser = user;
          _fullNameController.text = user.fullName ?? '';
          print('✏️ EditProfile: Full Name: ${_fullNameController.text}');
          _usernameController.text = user.username ?? '';
          print('✏️ EditProfile: Username: ${_usernameController.text}');
          _bioController.text = user.bio ?? '';
          print('✏️ EditProfile: Bio: ${_bioController.text}');
          _professionController.text = user.profession ?? '';
          print('✏️ EditProfile: Profession: ${_professionController.text}');
          _interestsController.text = user.interests?.join(', ') ?? '';
          print('✏️ EditProfile: Interests: ${_interestsController.text}');
          _isLoading = false;
        });
      } else if (user == null) {
        print('❌ EditProfile: fetchCurrentUser returned null.');
        if (mounted) {
          setState(() => _isLoading = false);
          showToastNotification(
            context,
            title: 'Warning'.tr(),
            description: 'User data not found.',
            style: ToastNotificationStyleType.warning,
          );
        }
      }
    } catch (e) {
      print('❌ EditProfile: Error loading profile: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        showToastNotification(
          context,
          title: 'Error'.tr(),
          description: 'Failed to load profile: $e',
          style: ToastNotificationStyleType.danger,
        );
      }
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    _professionController.dispose();
    _interestsController.dispose();
    super.dispose();
  }

  @override
  Widget view(BuildContext context) {
    print('🔄 EditProfile: _isLoading is $_isLoading');
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Edit Profile'),
          centerTitle: true,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black, size: 24),
            onPressed: () => Navigator.of(context).pop(),
          ),
          titleTextStyle: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
        ),
        body: Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black, size: 24),
          onPressed: () => Navigator.of(context).pop(),
        ),
        titleTextStyle: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Profile Picture
            GestureDetector(
              onTap: () {
                _pickImage();
              },
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: _profileImage != null
                        ? FileImage(_profileImage!)
                        : (_currentUser?.profilePicture != null
                            ? NetworkImage(_currentUser!.profilePicture!)
                            : null),
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    child: _profileImage == null &&
                            _currentUser?.profilePicture == null
                        ? Text(
                            _currentUser?.fullName
                                    ?.substring(0, 1)
                                    .toUpperCase() ??
                                'U',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSecondary,
                              fontWeight: FontWeight.bold,
                              fontSize: 40,
                            ),
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.camera_alt,
                        color: Theme.of(context).colorScheme.onPrimary,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),

            // Divider for visual separation
            Divider(height: 1, thickness: 1, color: Colors.grey[200]),
            SizedBox(height: 30),

            // Full Name
            _buildTextField(
              controller: _fullNameController,
              label: 'Full Name',
              icon: Icons.person_outline,
            ),
            SizedBox(height: 15),

            // Username
            _buildTextField(
              controller: _usernameController,
              label: 'Username',
              icon: Icons.alternate_email,
              readOnly: true, // Make username non-editable
              fillColor: Theme.of(context)
                  .colorScheme
                  .surface, // Visual cue for non-editable
            ),
            SizedBox(height: 15),

            // Bio
            _buildTextField(
              controller: _bioController,
              label: 'Bio',
              icon: Icons.info_outline,
              maxLines: 3,
            ),
            SizedBox(height: 15),

            // Profession
            _buildTextField(
              controller: _professionController,
              label: 'Profession',
              icon: Icons.work_outline,
            ),
            SizedBox(height: 15),

            // Interests
            _buildTextField(
              controller: _interestsController,
              label: 'Interests (comma-separated)',
              icon: Icons.favorite_outline,
              hint: 'e.g., Fashion, Beauty, Makeup',
            ),
            SizedBox(height: 30),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isSaving
                      ? Colors.grey[400]
                      : Theme.of(context).colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                  foregroundColor: Colors.white, // Ensure text color is white
                ),
                child: _isSaving
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).colorScheme.onPrimary),
                        ),
                      )
                    : Text(
                        'Save Profile',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null && mounted) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    String? hint,
    bool readOnly = false,
    Color? fillColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: fillColor ??
            Theme.of(context).inputDecorationTheme.fillColor ??
            Theme.of(context).colorScheme.onSurface.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        readOnly: readOnly,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          hintStyle: Theme.of(context).inputDecorationTheme.hintStyle ??
              Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.grey[500]),
          labelStyle: Theme.of(context).inputDecorationTheme.labelStyle ??
              Theme.of(context)
                  .textTheme
                  .labelLarge
                  ?.copyWith(color: Colors.grey[700]),
          prefixIcon: Icon(icon, color: Colors.grey[600]),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary, width: 2),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: maxLines > 1 ? 16 : 12,
          ),
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);

    try {
      // Extract data from controllers
      final String? fullName = _fullNameController.text.trim().isEmpty
          ? null
          : _fullNameController.text.trim();
      final String? username = _usernameController.text.trim().isEmpty
          ? null
          : _usernameController.text.trim();
      final String? bio = _bioController.text.trim().isEmpty
          ? null
          : _bioController.text.trim();
      final String? profession = _professionController.text.trim().isEmpty
          ? null
          : _professionController.text.trim();
      final List<String>? interests = _interestsController.text.trim().isEmpty
          ? null
          : _interestsController.text
              .split(',')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList();

      final updatedUser = await api<UserApiService>(
        (request) => request.updateProfile(
          fullName: fullName,
          username: username,
          bio: bio,
          profession: profession,
          interests: interests,
          profilePicture: _profileImage,
        ),
      );

      print('🐛 EditProfile: Result of updateProfile API call: $updatedUser');
      print(
          '🐛 EditProfile: Checking if updatedUser is not null: ${updatedUser != null}');
      if (updatedUser != null && mounted) {
        showToastNotification(
          context,
          title: 'Success'.tr(),
          description: 'Profile updated successfully!',
          style: ToastNotificationStyleType.success,
        );

        // Small delay for toast visibility
        await Future.delayed(Duration(milliseconds: 800));

        // Go back to previous page
        if (mounted) {
          pop();
        }
      } else {
        if (mounted) {
          showToastNotification(
            context,
            title: 'Error'.tr(),
            description: 'Failed to update profile.',
            style: ToastNotificationStyleType.danger,
          );
        }
      }
    } catch (e) {
      print('❌ EditProfile: Error saving profile: $e');
      if (mounted) {
        showToastNotification(
          context,
          title: 'Error'.tr(),
          description: 'An error occurred: $e',
          style: ToastNotificationStyleType.danger,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}
