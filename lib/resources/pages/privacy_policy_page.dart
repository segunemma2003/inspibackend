import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

class PrivacyPolicyPage extends NyStatefulWidget {
  static RouteView path = ("/privacy-policy", (_) => PrivacyPolicyPage());

  PrivacyPolicyPage({super.key})
      : super(child: () => _PrivacyPolicyPageState());
}

class _PrivacyPolicyPageState extends NyPage<PrivacyPolicyPage> {
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
          "Privacy Policy",
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
            _buildSection(
              "Information We Collect",
              [
                "• Profile information (name, username, bio, profile picture)",
                "• Content you create (posts, stories, comments, messages)",
                "• Media files (photos, videos, audio) you upload",
                "• Usage data (time spent, features used, interactions)",
                "• Device information (device type, operating system)",
                "• Location data (if you choose to share your location)",
                "• Contact information (if you connect your contacts)",
              ],
            ),
            _buildSection(
              "How We Use Your Information",
              [
                "• To provide and improve our social media platform",
                "• To personalize your feed and recommendations",
                "• To enable social features (likes, comments, sharing)",
                "• To send you notifications about activity",
                "• To ensure platform safety and security",
                "• To provide customer support",
                "• To analyze usage patterns and improve our service",
              ],
            ),
            _buildSection(
              "Information Sharing",
              [
                "• Your public posts are visible to other users as intended",
                "• We may share data with service providers who help us operate",
                "• We may share information if required by law",
                "• We never sell your personal data to third parties",
                "• Your private messages remain private between participants",
              ],
            ),
            _buildSection(
              "Your Rights",
              [
                "• Access and download your data",
                "• Delete your account and associated data",
                "• Control who can see your content",
                "• Opt out of certain data processing",
                "• Request correction of inaccurate information",
                "• Export your content and data",
              ],
            ),
            _buildSection(
              "Data Security",
              [
                "• We use industry-standard encryption to protect your data",
                "• Regular security audits and updates",
                "• Limited access to personal information",
                "• Secure data centers and infrastructure",
                "• Incident response procedures in place",
              ],
            ),
            _buildSection(
              "Children's Privacy",
              [
                "• Our platform is not intended for children under 13",
                "• We do not knowingly collect data from children under 13",
                "• Parents can contact us to remove their child's information",
                "• We encourage parental supervision of teen users",
              ],
            ),
            _buildSection(
              "Contact Us",
              [
                "For privacy questions or concerns:",
                "Email: privacy@inspirtag.com",
                "Address: Privacy Team, Inspirtag Inc.",
                "Last updated: January 2024",
              ],
            ),
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
          "Privacy Policy",
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 8),
        Text(
          "Your privacy is important to us. This policy explains how we collect, use, and protect your information on our social media platform.",
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
            height: 1.5,
          ),
        ),
        SizedBox(height: 16),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Color(0xFF00BFFF).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Color(0xFF00BFFF).withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Color(0xFF00BFFF), size: 20),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  "This policy applies to all users of Inspirtag, our social media platform for creators and influencers.",
                  style: TextStyle(
                    color: Color(0xFF00BFFF),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 16),
        ...items.map((item) => Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text(
                item,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
              ),
            )),
        SizedBox(height: 24),
      ],
    );
  }
}
