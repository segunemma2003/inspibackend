import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

class EditProfilePage extends NyStatefulWidget {
  static RouteView path = ("/edit-profile", (_) => EditProfilePage());

  EditProfilePage({super.key}) : super(child: () => _EditProfilePageState());
}

class _EditProfilePageState extends NyPage<EditProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool _isBusinessAccount = false;

  @override
  get init => () {
        // Initialize with sample data
        _nameController.text = "Sarah Johnson";
        _usernameController.text = "sarah_johnson";
        _bioController.text =
            "I love myself and whatever I want I receive and I don't listen to anyones opinion. Since then I have been happier, more fullfilled and peaceful. My advice would be do what you want, wear what you want and be who you want and then you will attract what you want.";
        _websiteController.text = "sarahjohnson.com";
        _phoneController.text = "+1 234 567 8900";
        _isBusinessAccount = true;
      };

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar
            _buildAppBar(context),

            // Content
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 30),

                      // Logo Section
                      _buildLogoSection(),

                      const SizedBox(height: 30),

                      // Edit Profile Card
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
          // Back Button
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

          // Title
          const Text(
            'Edit Profile',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),

          const Spacer(),

          // Save Button
          GestureDetector(
            onTap: _saveProfile,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF69B4), Color(0xFF9C27B0)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
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

  Widget _buildLogoSection() {
    return Column(
      children: [
        // Logo placeholder
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Image.asset(
            'logo.png',
            width: 80,
            height: 80,
            fit: BoxFit.contain,
          ).localAsset(),
        ),

        const SizedBox(height: 12),

        // App name with colors
        RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: 'inspi',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFFF69B4), // Pink
                  letterSpacing: -0.5,
                  fontFamily: 'Roboto',
                ),
              ),
              TextSpan(
                text: 'r',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFFFD700), // Yellow
                  letterSpacing: -0.5,
                  fontFamily: 'Roboto',
                ),
              ),
              TextSpan(
                text: 'tag',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF00BFFF), // Blue
                  letterSpacing: -0.5,
                  fontFamily: 'Roboto',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEditProfileCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Section
        Row(
          children: [
            // Profile icon with gradient border
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFFF69B4), // Pink
                    Color(0xFFFFD700), // Yellow
                    Color(0xFF9ACD32), // Green
                    Color(0xFF00BFFF), // Blue
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
            // Title
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
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
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
                  margin: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: ClipOval(
                    child: Container(
                      color: Colors.grey[200],
                      child: Icon(
                        Icons.person,
                        size: 50,
                        color: Colors.grey[400],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () {
                  showToastSuccess(
                      title: "Change Photo",
                      description: "Photo picker opened");
                },
                child: const Text(
                  'Change profile photo',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF7B68EE),
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
          label: 'Full Name',
          controller: _nameController,
          icon: Icons.person_outline,
        ),

        const SizedBox(height: 20),

        _buildTextField(
          label: 'Username',
          controller: _usernameController,
          icon: Icons.alternate_email,
        ),

        const SizedBox(height: 20),

        _buildTextField(
          label: 'Bio',
          controller: _bioController,
          icon: Icons.description_outlined,
          maxLines: 4,
        ),

        const SizedBox(height: 20),

        _buildTextField(
          label: 'Website',
          controller: _websiteController,
          icon: Icons.link,
        ),

        const SizedBox(height: 20),

        _buildTextField(
          label: 'Phone',
          controller: _phoneController,
          icon: Icons.phone_outlined,
        ),

        const SizedBox(height: 24),

        // Business Account Toggle
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF7B68EE).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.business,
                  color: Color(0xFF7B68EE),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Business Account',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'Get access to business features',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _isBusinessAccount,
                onChanged: (value) {
                  setState(() {
                    _isBusinessAccount = value;
                  });
                },
                activeColor: const Color(0xFF7B68EE),
              ),
            ],
          ),
        ),

        const SizedBox(height: 30),

        // Additional Options
        _buildOptionButton(
          icon: Icons.lock_outline,
          title: 'Privacy Settings',
          onTap: () {
            showToastSuccess(
                title: "Privacy Settings",
                description: "Navigate to privacy settings");
          },
        ),

        const SizedBox(height: 12),

        _buildOptionButton(
          icon: Icons.notifications_outlined,
          title: 'Notification Preferences',
          onTap: () {
            showToastSuccess(
                title: "Notifications",
                description: "Navigate to notification settings");
          },
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    int maxLines = 1,
  }) {
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
              hintText: 'Enter $label...',
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

  Widget _buildOptionButton({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF7B68EE).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF7B68EE),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
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
    );
  }

  void _saveProfile() {
    // Validate and save profile data
    if (_nameController.text.isEmpty || _usernameController.text.isEmpty) {
      showToastSuccess(description: "Name and username are required");
      return;
    }

    showToastSuccess(
        title: "Profile Updated",
        description: "Your profile has been successfully updated");

    // Navigate back or update state as needed
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    _websiteController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}
