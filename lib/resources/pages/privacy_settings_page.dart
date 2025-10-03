import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

class PrivacySettingsPage extends NyStatefulWidget {
  static RouteView path = ("/privacy-settings", (_) => PrivacySettingsPage());

  PrivacySettingsPage({super.key})
      : super(child: () => _PrivacySettingsPageState());
}

class _PrivacySettingsPageState extends NyPage<PrivacySettingsPage> {
  bool _isPrivateAccount = false;
  bool _allowTagging = true;
  bool _allowComments = true;
  bool _allowDirectMessages = true;
  bool _showOnlineStatus = true;
  bool _allowSearchByEmail = false;
  bool _allowSearchByPhone = false;
  bool _showActivityStatus = true;
  bool _allowStoryResharing = true;

  bool _isLoading = false;
  bool _isSaving = false;

  @override
  get init => () async {
        await _loadPrivacySettings();
      };

  Future<void> _loadPrivacySettings() async {
    setState(() => _isLoading = true);

    try {
      // Load current privacy settings from API
      // This would be implemented based on your API structure
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call

      // For now, using default values
      setState(() {
        _isPrivateAccount = false;
        _allowTagging = true;
        _allowComments = true;
        _allowDirectMessages = true;
        _showOnlineStatus = true;
        _allowSearchByEmail = false;
        _allowSearchByPhone = false;
        _showActivityStatus = true;
        _allowStoryResharing = true;
      });
    } catch (e) {
      print('Error loading privacy settings: $e');
      showToast(title: 'Error', description: 'Failed to load privacy settings');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Color(0xFFFF69B4)),
                      ),
                    )
                  : SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          children: [
                            const SizedBox(height: 30),
                            _buildLogoSection(),
                            const SizedBox(height: 30),
                            _buildPrivacySettingsCard(),
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
            'Privacy Settings',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: _isSaving ? null : _savePrivacySettings,
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

  Widget _buildLogoSection() {
    return Column(
      children: [
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
        RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: 'inspi',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFFF69B4),
                  letterSpacing: -0.5,
                  fontFamily: 'Roboto',
                ),
              ),
              TextSpan(
                text: 'r',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFFFD700),
                  letterSpacing: -0.5,
                  fontFamily: 'Roboto',
                ),
              ),
              TextSpan(
                text: 'tag',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF00BFFF),
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

  Widget _buildPrivacySettingsCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
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
                      Icons.lock_outline,
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
                        'Privacy Settings',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF7B68EE),
                          fontFamily: 'Roboto',
                        ),
                      ),
                      Text(
                        'Control who can see your content',
                        style: TextStyle(
                          fontSize: 16,
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

            const SizedBox(height: 40),

            // Account Privacy Section
            _buildSectionHeader('Account Privacy'),
            const SizedBox(height: 16),

            _buildPrivacyToggle(
              title: 'Private Account',
              subtitle: 'Only approved followers can see your posts',
              value: _isPrivateAccount,
              onChanged: (value) => setState(() => _isPrivateAccount = value),
              icon: Icons.lock,
            ),

            const SizedBox(height: 32),

            // Interactions Section
            _buildSectionHeader('Interactions'),
            const SizedBox(height: 16),

            _buildPrivacyToggle(
              title: 'Allow Tagging',
              subtitle: 'Others can tag you in their posts',
              value: _allowTagging,
              onChanged: (value) => setState(() => _allowTagging = value),
              icon: Icons.local_offer,
            ),

            const SizedBox(height: 16),

            _buildPrivacyToggle(
              title: 'Allow Comments',
              subtitle: 'Others can comment on your posts',
              value: _allowComments,
              onChanged: (value) => setState(() => _allowComments = value),
              icon: Icons.comment,
            ),

            const SizedBox(height: 16),

            _buildPrivacyToggle(
              title: 'Allow Direct Messages',
              subtitle: 'Others can send you direct messages',
              value: _allowDirectMessages,
              onChanged: (value) =>
                  setState(() => _allowDirectMessages = value),
              icon: Icons.message,
            ),

            const SizedBox(height: 32),

            // Discoverability Section
            _buildSectionHeader('Discoverability'),
            const SizedBox(height: 16),

            _buildPrivacyToggle(
              title: 'Allow Search by Email',
              subtitle: 'Others can find you using your email',
              value: _allowSearchByEmail,
              onChanged: (value) => setState(() => _allowSearchByEmail = value),
              icon: Icons.email,
            ),

            const SizedBox(height: 16),

            _buildPrivacyToggle(
              title: 'Allow Search by Phone',
              subtitle: 'Others can find you using your phone number',
              value: _allowSearchByPhone,
              onChanged: (value) => setState(() => _allowSearchByPhone = value),
              icon: Icons.phone,
            ),

            const SizedBox(height: 32),

            // Activity Section
            _buildSectionHeader('Activity'),
            const SizedBox(height: 16),

            _buildPrivacyToggle(
              title: 'Show Online Status',
              subtitle: 'Others can see when you\'re online',
              value: _showOnlineStatus,
              onChanged: (value) => setState(() => _showOnlineStatus = value),
              icon: Icons.circle,
            ),

            const SizedBox(height: 16),

            _buildPrivacyToggle(
              title: 'Show Activity Status',
              subtitle: 'Others can see your last activity',
              value: _showActivityStatus,
              onChanged: (value) => setState(() => _showActivityStatus = value),
              icon: Icons.access_time,
            ),

            const SizedBox(height: 16),

            _buildPrivacyToggle(
              title: 'Allow Story Resharing',
              subtitle: 'Others can reshare your stories',
              value: _allowStoryResharing,
              onChanged: (value) =>
                  setState(() => _allowStoryResharing = value),
              icon: Icons.share,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
        fontFamily: 'Roboto',
      ),
    );
  }

  Widget _buildPrivacyToggle({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
  }) {
    return Container(
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF7B68EE),
            activeTrackColor: const Color(0xFF7B68EE).withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  Future<void> _savePrivacySettings() async {
    setState(() => _isSaving = true);

    try {
      // Save privacy settings via API
      // This would be implemented based on your API structure
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call

      showToast(
          title: 'Success',
          description: 'Privacy settings updated successfully!');
    } catch (e) {
      print('Error saving privacy settings: $e');
      showToast(
          title: 'Error', description: 'Failed to update privacy settings');
    } finally {
      setState(() => _isSaving = false);
    }
  }
}
