import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

import '../../app/networking/auth_api_service.dart';
import '../../app/services/auth_service.dart';

class SettingsPage extends NyStatefulWidget {
  static RouteView path = ("/settings", (_) => SettingsPage());

  SettingsPage({super.key}) : super(child: () => _SettingsPageState());
}

class _SettingsPageState extends NyPage<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  bool _locationEnabled = true;
  bool _biometricEnabled = false;
  String _selectedLanguage = 'English';

  @override
  get init => () {};

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),

            const SizedBox(height: 20),

            // Logo Section
            _buildLogoSection(),

            const SizedBox(height: 30),

            // Settings Content
            Expanded(
              child: _buildSettingsContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back Button
          GestureDetector(
            onTap: () {
              routeTo('/base');
            },
            child: Icon(
              Icons.arrow_back,
              size: 24,
              color: Colors.black,
            ),
          ),
          // Title
          Text(
            'SETTINGS',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          // Empty space for alignment
          SizedBox(width: 24),
        ],
      ),
    );
  }

  Widget _buildLogoSection() {
    return Column(
      children: [
        // Logo image
        Image.asset(
          'logo.png',
          width: 60,
          height: 60,
          fit: BoxFit.contain,
        ).localAsset(),

        const SizedBox(height: 8),

        // App name with second 'i' in yellow and 'r' in blue
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'insp',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFFF69B4), // Bright pink
                  letterSpacing: -0.5,
                ),
              ),
              TextSpan(
                text: 'i',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFFFD700), // Yellow
                  letterSpacing: -0.5,
                ),
              ),
              TextSpan(
                text: 'rtag',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF00BFFF), // Blue
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsContent() {
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 24.0),
      children: [
        // Account Settings
        _buildSection(
          'Account',
          Icons.person_outline,
          [
            _buildSettingItem(
              Icons.edit_outlined,
              'Edit Profile',
              'Update your personal information',
              () => routeTo('/dashboard/edit-profile'),
            ),
            _buildSettingItem(
              Icons.security_outlined,
              'Privacy & Security',
              'Manage your privacy settings',
              () => routeTo('/privacy'),
            ),
            _buildSettingItem(
              Icons.language_outlined,
              'Language',
              _selectedLanguage,
              () => _showLanguageDialog(),
            ),
          ],
        ),

        SizedBox(height: 24),

        // Notifications
        _buildSection(
          'Notifications',
          Icons.notifications_outlined,
          [
            _buildSwitchItem(
              Icons.notifications_active,
              'Push Notifications',
              'Receive notifications about activities',
              _notificationsEnabled,
              (value) => setState(() => _notificationsEnabled = value),
            ),
            _buildSwitchItem(
              Icons.email_outlined,
              'Email Notifications',
              'Get updates via email',
              true,
              (value) {},
            ),
          ],
        ),

        SizedBox(height: 24),

        // App Settings
        _buildSection(
          'App Settings',
          Icons.settings_outlined,
          [
            _buildSwitchItem(
              Icons.dark_mode_outlined,
              'Dark Mode',
              'Switch to dark theme',
              _darkModeEnabled,
              (value) => setState(() => _darkModeEnabled = value),
            ),
            _buildSwitchItem(
              Icons.location_on_outlined,
              'Location Services',
              'Allow location-based features',
              _locationEnabled,
              (value) => setState(() => _locationEnabled = value),
            ),
            _buildSwitchItem(
              Icons.fingerprint_outlined,
              'Biometric Login',
              'Use fingerprint or face ID',
              _biometricEnabled,
              (value) => setState(() => _biometricEnabled = value),
            ),
          ],
        ),

        SizedBox(height: 24),

        // Legal & Policies
        _buildSection(
          'Legal & Policies',
          Icons.gavel_outlined,
          [
            _buildSettingItem(
              Icons.privacy_tip_outlined,
              'Privacy Policy',
              'How we collect and use your data',
              () => routeTo('/privacy-policy'),
            ),
            _buildSettingItem(
              Icons.description_outlined,
              'Terms of Service',
              'Terms and conditions of use',
              () => routeTo('/terms-of-service'),
            ),
            _buildSettingItem(
              Icons.rule_outlined,
              'Community Guidelines',
              'Community standards and rules',
              () => routeTo('/community-guidelines'),
            ),
            _buildSettingItem(
              Icons.copyright_outlined,
              'Intellectual Property',
              'Copyright and IP policies',
              () => routeTo('/intellectual-property-policy'),
            ),
            _buildSettingItem(
              Icons.security_outlined,
              'Online Safety Act',
              'Safety guidelines and reporting',
              () => routeTo('/online-safety-act'),
            ),
            _buildSettingItem(
              Icons.code_outlined,
              'Open Source Notice',
              'Open source licenses and credits',
              () => routeTo('/open-source-notice'),
            ),
          ],
        ),

        SizedBox(height: 24),

        // Support
        _buildSection(
          'Support',
          Icons.help_outline,
          [
            _buildSettingItem(
              Icons.help_center_outlined,
              'Help Center',
              'Get help and support',
              () => routeTo('/help-center'),
            ),
            _buildSettingItem(
              Icons.support_agent_outlined,
              'Contact Support',
              'Get in touch with our team',
              () => routeTo('/support'),
            ),
            _buildSettingItem(
              Icons.info_outline,
              'About Us',
              'Learn more about inspirtag',
              () => routeTo('/about'),
            ),
            _buildSettingItem(
              Icons.star_outline,
              'Rate App',
              'Rate us on the App Store',
              () =>
                  showToastSuccess(description: 'Thank you for your support!'),
            ),
          ],
        ),

        SizedBox(height: 32),

        // Logout Button
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red.withOpacity(0.3)),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _showLogoutDialog(),
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.logout,
                      color: Colors.red,
                      size: 20,
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Logout',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        SizedBox(height: 20),

        // Danger Zone
        _buildSection(
          'Danger Zone',
          Icons.warning_amber_outlined,
          [
            _buildSettingItem(
              Icons.delete_forever_outlined,
              'Delete Account',
              'Permanently delete your account and data',
              () => _showDeleteAccountDialog(),
              isDestructive: true,
            ),
          ],
        ),

        SizedBox(height: 40),
      ],
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children,
      {bool isDestructive = false}) {
    Color sectionColor = isDestructive ? Colors.red : Color(0xFF00BFFF);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: sectionColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: sectionColor,
                size: 18,
              ),
            ),
            SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildSettingItem(
      IconData icon, String title, String subtitle, VoidCallback onTap,
      {bool isDestructive = false}) {
    Color itemColor = isDestructive ? Colors.red : Color(0xFFFF69B4);
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[200]!),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: itemColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: itemColor,
                    size: 20,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
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

  Widget _buildSwitchItem(IconData icon, String title, String subtitle,
      bool value, ValueChanged<bool> onChanged) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: Colors.orange,
              size: 20,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Color(0xFF00BFFF),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption('English'),
            _buildLanguageOption('Spanish'),
            _buildLanguageOption('French'),
            _buildLanguageOption('German'),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(String language) {
    return ListTile(
      title: Text(language),
      trailing: _selectedLanguage == language
          ? Icon(Icons.check, color: Color(0xFF00BFFF))
          : null,
      onTap: () {
        setState(() {
          _selectedLanguage = language;
        });
        Navigator.pop(context);
        showToastSuccess(description: 'Language changed to $language');
      },
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Logout'),
        content: Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              routeTo('/sign-in');
            },
            child: Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Account'),
        content: Text(
            'Are you sure you want to permanently delete your account? This action is irreversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              showToastNotification(
                context,
                title: 'Deleting Account',
                description: 'Please wait...',
                style: ToastNotificationStyleType.info,
              );
              try {
                final response = await api<AuthApiService>(
                    (request) => request.deleteAccount());
                if (response != null && response['success'] == true) {
                  showToastNotification(
                    context,
                    title: 'Success',
                    description: 'Account deleted successfully.',
                    style: ToastNotificationStyleType.success,
                  );
                  await Future.delayed(Duration(milliseconds: 800));
                  AuthService.instance.clearAuth(); // Clear local auth data
                  routeTo('/sign-in',
                      navigationType: NavigationType
                          .pushAndForgetAll); // Redirect to sign-in
                } else {
                  showToastNotification(
                    context,
                    title: 'Error',
                    description:
                        response?['message'] ?? 'Failed to delete account.',
                    style: ToastNotificationStyleType.danger,
                  );
                }
              } catch (e) {
                showToastNotification(
                  context,
                  title: 'Error',
                  description: 'An error occurred: $e',
                  style: ToastNotificationStyleType.danger,
                );
              }
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
