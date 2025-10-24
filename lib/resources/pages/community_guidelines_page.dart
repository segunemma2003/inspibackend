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
          "Community Guidelines",
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
              "Be Respectful",
              [
                "• Treat everyone with kindness and respect",
                "• No harassment, bullying, or intimidation",
                "• No hate speech or discriminatory language",
                "• Respect different opinions and perspectives",
                "• Be constructive in your feedback",
              ],
            ),
            _buildSection(
              "Content Standards",
              [
                "• Share original content or give proper credit",
                "• No spam, misleading, or deceptive content",
                "• No illegal activities or content",
                "• No graphic violence or disturbing imagery",
                "• No adult content (keep it family-friendly)",
                "• No sharing of private information",
              ],
            ),
            _buildSection(
              "Safety First",
              [
                "• Report harmful or inappropriate content",
                "• Don't share personal information publicly",
                "• Be cautious when meeting people in person",
                "• Protect your mental health and well-being",
                "• Take breaks from social media when needed",
              ],
            ),
            _buildSection(
              "Authenticity",
              [
                "• Be yourself - no fake accounts or impersonation",
                "• Don't buy followers or engagement",
                "• Be honest about sponsored content",
                "• Use your real identity",
                "• Don't create multiple accounts to circumvent restrictions",
              ],
            ),
            _buildSection(
              "Intellectual Property",
              [
                "• Respect copyright and trademark laws",
                "• Don't use others' content without permission",
                "• Give credit when sharing others' work",
                "• Don't steal or plagiarize content",
                "• Report copyright violations",
              ],
            ),
            _buildSection(
              "Commercial Use",
              [
                "• Follow our advertising guidelines",
                "• Disclose sponsored partnerships",
                "• Don't spam with promotional content",
                "• Respect other users' feeds",
                "• Use appropriate hashtags for business content",
              ],
            ),
            _buildSection(
              "Reporting and Enforcement",
              [
                "• Report violations using our reporting tools",
                "• We review all reports promptly",
                "• Violations may result in content removal or account restrictions",
                "• Repeat violations may lead to account suspension",
                "• Appeals process available for enforcement actions",
              ],
            ),
            _buildSection(
              "Positive Community",
              [
                "• Support and encourage other creators",
                "• Share knowledge and helpful tips",
                "• Celebrate diversity and inclusion",
                "• Help newcomers learn the platform",
                "• Contribute to a positive environment",
              ],
            ),
            _buildSection(
              "Contact Us",
              [
                "For questions about community guidelines:",
                "Email: community@inspirtag.com",
                "Report content: Use the report button on posts",
                "Appeal decisions: community@inspirtag.com",
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
          "Community Guidelines",
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 8),
        Text(
          "Help us create a positive, safe, and inspiring community for all creators and users.",
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
            color: Color(0xFF9ACD32).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Color(0xFF9ACD32).withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.favorite, color: Color(0xFF9ACD32), size: 20),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  "These guidelines help maintain a welcoming environment for everyone in our community.",
                  style: TextStyle(
                    color: Color(0xFF9ACD32),
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
