import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

class HelpCenterPage extends NyStatefulWidget {
  static RouteView path = ("/help-center", (_) => HelpCenterPage());

  HelpCenterPage({super.key}) : super(child: () => _HelpCenterPageState());
}

class _HelpCenterPageState extends NyPage<HelpCenterPage> {
  @override
  get init => () {};

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Help Center",
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            SizedBox(height: 32),
            _buildSearchBar(),
            SizedBox(height: 32),
            _buildCategorySection(),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Help Center",
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 8),
        Text(
          "Find answers to common questions and get help with using Inspirtag.",
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: "Search for help...",
          prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Popular Topics",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 24),
        _buildHelpCategory(
          "Getting Started",
          "Learn the basics of using Inspirtag",
          Icons.play_circle_outline,
          Color(0xFF00BFFF),
          [
            "How to create your first post",
            "Setting up your profile",
            "Understanding the feed",
            "Following other users",
          ],
        ),
        _buildHelpCategory(
          "Account & Profile",
          "Manage your account and profile settings",
          Icons.person_outline,
          Color(0xFFFF69B4),
          [
            "Changing your profile picture",
            "Updating your bio",
            "Account privacy settings",
            "Deleting your account",
          ],
        ),
        _buildHelpCategory(
          "Creating Content",
          "Tips for creating engaging posts",
          Icons.camera_alt_outlined,
          Color(0xFF9ACD32),
          [
            "Photo and video tips",
            "Using hashtags effectively",
            "Tagging other users",
            "Stories vs posts",
          ],
        ),
        _buildHelpCategory(
          "Privacy & Safety",
          "Keep your account secure and private",
          Icons.security_outlined,
          Color(0xFFFF6B35),
          [
            "Blocking and reporting users",
            "Private vs public accounts",
            "Data and privacy settings",
            "Staying safe online",
          ],
        ),
        _buildHelpCategory(
          "Troubleshooting",
          "Fix common issues and problems",
          Icons.build_outlined,
          Color(0xFF8E44AD),
          [
            "App not loading properly",
            "Can't upload photos/videos",
            "Notifications not working",
            "Login issues",
          ],
        ),
        _buildHelpCategory(
          "Business Features",
          "Tools for creators and businesses",
          Icons.business_outlined,
          Color(0xFFE67E22),
          [
            "Business account setup",
            "Analytics and insights",
            "Promoting your content",
            "Monetization options",
          ],
        ),
        SizedBox(height: 32),
        _buildContactSection(),
      ],
    );
  }

  Widget _buildHelpCategory(String title, String description, IconData icon,
      Color color, List<String> topics) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        subtitle: Text(
          description,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: topics
                  .map((topic) => Padding(
                        padding: EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Icon(Icons.arrow_forward_ios,
                                size: 12, color: Colors.grey[400]),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                topic,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Color(0xFF00BFFF).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFF00BFFF).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.support_agent, color: Color(0xFF00BFFF), size: 24),
              SizedBox(width: 12),
              Text(
                "Still need help?",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            "Our support team is here to help you with any questions or issues.",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Navigate to contact support
                  },
                  icon: Icon(Icons.email, size: 18),
                  label: Text("Email Support"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF00BFFF),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Navigate to FAQ
                  },
                  icon: Icon(Icons.help_outline, size: 18),
                  label: Text("View FAQ"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Color(0xFF00BFFF),
                    side: BorderSide(color: Color(0xFF00BFFF)),
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
