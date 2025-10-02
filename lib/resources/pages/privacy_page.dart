import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

class PrivacyPage extends NyStatefulWidget {
  static RouteView path = ("/privacy", (_) => PrivacyPage());

  PrivacyPage({super.key}) : super(child: () => _PrivacyPageState());
}

class _PrivacyPageState extends NyPage<PrivacyPage> {
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

            // Privacy Content
            Expanded(
              child: _buildPrivacyContent(),
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
            'PRIVACY POLICY',
            style: TextStyle(
              fontSize: 18,
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

        const SizedBox(height: 8),

        Text(
          'Last updated: December 2024',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildPrivacyContent() {
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 24.0),
      children: [
        // Introduction
        _buildSection(
          'Introduction',
          Icons.info_outline,
          'At inspirtag, we are committed to protecting your privacy and ensuring the security of your personal information. This Privacy Policy explains how we collect, use, and safeguard your data when you use our beauty and wellness platform.',
        ),

        SizedBox(height: 20),

        // Information We Collect
        _buildSection(
          'Information We Collect',
          Icons.data_usage,
          'We collect information you provide directly to us, such as when you create an account, update your profile, book appointments, or communicate with us. This may include your name, email address, phone number, location, photos, and preferences.',
        ),

        SizedBox(height: 20),

        // How We Use Information
        _buildSection(
          'How We Use Your Information',
          Icons.settings,
          'We use your information to provide and improve our services, connect you with beauty professionals, process bookings, send notifications, and enhance your user experience. We may also use aggregated data for analytics and service improvement.',
        ),

        SizedBox(height: 20),

        // Information Sharing
        _buildSection(
          'Information Sharing',
          Icons.share,
          'We do not sell your personal information. We may share your information with beauty professionals you choose to connect with, service providers who assist us, or when required by law. Your profile information is only shared with your consent.',
        ),

        SizedBox(height: 20),

        // Data Security
        _buildSection(
          'Data Security',
          Icons.security,
          'We implement appropriate security measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction. However, no method of transmission over the internet is 100% secure.',
        ),

        SizedBox(height: 20),

        // Your Rights
        _buildSection(
          'Your Rights',
          Icons.account_balance,
          'You have the right to access, update, or delete your personal information. You can manage your privacy settings in your account, opt out of certain communications, and request data portability. Contact us to exercise these rights.',
        ),

        SizedBox(height: 20),

        // Contact Information
        _buildContactSection(),

        SizedBox(height: 32),

        // Agreement
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Color(0xFF00BFFF).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Color(0xFF00BFFF).withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.check_circle,
                color: Color(0xFF00BFFF),
                size: 24,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'By using inspirtag, you agree to this Privacy Policy and our Terms of Service.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 20),
      ],
    );
  }

  Widget _buildSection(String title, IconData icon, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Color(0xFF00BFFF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: Color(0xFF00BFFF),
                size: 18,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContactSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Color(0xFFFF69B4).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.contact_support,
                color: Color(0xFFFF69B4),
                size: 18,
              ),
            ),
            SizedBox(width: 12),
            Text(
              'Contact Us',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'If you have any questions about this Privacy Policy or our privacy practices, please contact us:',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
              ),
              SizedBox(height: 12),
              _buildContactItem(Icons.email, 'privacy@inspirtag.com'),
              _buildContactItem(Icons.phone, '+1 (555) 123-4567'),
              _buildContactItem(Icons.location_on, 'San Francisco, CA'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactItem(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            icon,
            color: Color(0xFFFF69B4),
            size: 16,
          ),
          SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}
