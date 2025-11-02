import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

class AboutPage extends NyStatefulWidget {
  static RouteView path = ("/about", (_) => AboutPage());

  AboutPage({super.key}) : super(child: () => _AboutPageState());
}

class _AboutPageState extends NyPage<AboutPage> {
  @override
  get init => () {};

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [

            _buildHeader(),

            const SizedBox(height: 20),

            _buildLogoSection(),

            const SizedBox(height: 30),

            Expanded(
              child: _buildAboutContent(),
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

          Text(
            'ABOUT US',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),

          SizedBox(width: 24),
        ],
      ),
    );
  }

  Widget _buildLogoSection() {
    return Column(
      children: [

        Image.asset(
          'logo.png',
          width: 80,
          height: 80,
          fit: BoxFit.contain,
        ).localAsset(),

        const SizedBox(height: 12),

        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'insp',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFFF69B4), // Bright pink
                  letterSpacing: -0.5,
                ),
              ),
              TextSpan(
                text: 'i',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFFFD700), // Yellow
                  letterSpacing: -0.5,
                ),
              ),
              TextSpan(
                text: 'rtag',
                style: TextStyle(
                  fontSize: 28,
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
          'Version 1.0.0',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildAboutContent() {
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 24.0),
      children: [

        _buildSection(
          'Our Mission',
          Icons.flag_outlined,
          'inspirtag is dedicated to connecting beauty and wellness professionals with clients who are passionate about self-care and transformation. We believe everyone deserves to feel confident and beautiful in their own skin.',
        ),

        SizedBox(height: 24),

        _buildSection(
          'What We Do',
          Icons.work_outline,
          'We provide a platform where beauty professionals can showcase their work, connect with clients, and build their businesses. Our community fosters creativity, inspiration, and meaningful connections.',
        ),

        SizedBox(height: 24),

        _buildFeaturesSection(),

        SizedBox(height: 24),

        _buildContactSection(),

        SizedBox(height: 24),

        _buildSocialSection(),

        SizedBox(height: 24),

        _buildPolicyLinksSection(),

        SizedBox(height: 32),

        Center(
          child: Text(
            '© 2024 inspirtag. All rights reserved.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
        ),

        SizedBox(height: 20),
      ],
    );
  }

  Widget _buildSection(String title, IconData icon, String description) {
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
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Text(
            description,
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

  Widget _buildFeaturesSection() {
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
                Icons.star_outline,
                color: Color(0xFFFF69B4),
                size: 18,
              ),
            ),
            SizedBox(width: 12),
            Text(
              'Key Features',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        _buildFeatureItem(Icons.search, 'Discover Professionals',
            'Find skilled beauty experts in your area'),
        _buildFeatureItem(Icons.bookmark, 'Save Inspirations',
            'Bookmark your favorite looks and professionals'),
        _buildFeatureItem(Icons.share, 'Share Transformations',
            'Showcase your beauty journey'),
        _buildFeatureItem(Icons.chat, 'Connect & Book',
            'Message and book appointments directly'),
      ],
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Color(0xFFFFD700).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: Color(0xFFFFD700),
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
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
              'Get In Touch',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        _buildContactItem(Icons.email, 'hello@inspirtag.com'),
        _buildContactItem(Icons.phone, '+1 (555) 123-4567'),
        _buildContactItem(Icons.location_on, 'San Francisco, CA'),
      ],
    );
  }

  Widget _buildContactItem(IconData icon, String text) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Color(0xFF00BFFF),
            size: 20,
          ),
          SizedBox(width: 12),
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

  Widget _buildSocialSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Color(0xFFFFD700).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.share,
                color: Color(0xFFFFD700),
                size: 18,
              ),
            ),
            SizedBox(width: 12),
            Text(
              'Follow Us',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildSocialButton(Icons.facebook, 'Facebook'),
            _buildSocialButton(Icons.camera_alt, 'Instagram'),
            _buildSocialButton(Icons.alternate_email, 'Twitter'),
            _buildSocialButton(Icons.linked_camera, 'TikTok'),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialButton(IconData icon, String platform) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Color(0xFF00BFFF).withOpacity(0.1),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Icon(
            icon,
            color: Color(0xFF00BFFF),
            size: 24,
          ),
        ),
        SizedBox(height: 8),
        Text(
          platform,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildPolicyLinksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Legal & Policies',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: [
            _buildPolicyLink('Privacy Policy', '/privacy-policy'),
            _buildPolicyLink('Terms of Service', '/terms-of-service'),
            _buildPolicyLink('Community Guidelines', '/community-guidelines'),
            _buildPolicyLink('Help Center', '/help-center'),
            _buildPolicyLink('Contact Support', '/support'),
          ],
        ),
      ],
    );
  }

  Widget _buildPolicyLink(String text, String route) {
    return GestureDetector(
      onTap: () => routeTo(route),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Color(0xFF00BFFF).withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Color(0xFF00BFFF).withOpacity(0.3)),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: Color(0xFF00BFFF),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
