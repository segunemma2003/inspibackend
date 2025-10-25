import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

class CommunityGuidelinesPage extends NyStatefulWidget {
  static RouteView path =
      ("/community-guidelines", (_) => CommunityGuidelinesPage());

  CommunityGuidelinesPage({super.key})
      : super(child: () => _CommunityGuidelinesPageState());
}

class _CommunityGuidelinesPageState extends NyPage<CommunityGuidelinesPage> {
  @override
  Widget view(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Guidelines'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Community Guidelines',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Welcome to our community! These guidelines help ensure a positive experience for everyone.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 30),
            _buildSection(
              'Be Respectful',
              'Treat all community members with respect and kindness. No harassment, bullying, or hate speech.',
            ),
            _buildSection(
              'Share Authentic Content',
              'Post original content and give credit when sharing others\' work. No spam or misleading content.',
            ),
            _buildSection(
              'Keep It Safe',
              'No content that promotes violence, illegal activities, or harmful behavior.',
            ),
            _buildSection(
              'Respect Privacy',
              'Don\'t share personal information about others without permission.',
            ),
            _buildSection(
              'Follow the Law',
              'All content must comply with local laws and regulations.',
            ),
            const SizedBox(height: 30),
            const Text(
              'Violations of these guidelines may result in content removal or account suspension.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
