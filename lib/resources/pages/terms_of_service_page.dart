import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

class TermsOfServicePage extends NyStatefulWidget {
  static RouteView path = ("/terms-of-service", (_) => TermsOfServicePage());

  TermsOfServicePage({super.key})
      : super(child: () => _TermsOfServicePageState());
}

class _TermsOfServicePageState extends NyPage<TermsOfServicePage> {
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
          "Terms of Service",
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
              "Acceptance of Terms",
              [
                "By using Inspirtag, you agree to be bound by these Terms of Service.",
                "If you do not agree to these terms, please do not use our platform.",
                "We may update these terms from time to time, and continued use constitutes acceptance.",
              ],
            ),
            _buildSection(
              "User Accounts",
              [
                "• You must be at least 13 years old to create an account",
                "• You are responsible for maintaining account security",
                "• One account per person - no duplicate accounts",
                "• Provide accurate and current information",
                "• Notify us immediately of any unauthorized access",
              ],
            ),
            _buildSection(
              "Content Guidelines",
              [
                "• Respect intellectual property rights",
                "• No harassment, bullying, or hate speech",
                "• No spam, misleading, or deceptive content",
                "• No illegal activities or content",
                "• No impersonation of others",
                "• No sharing of private information without consent",
              ],
            ),
            _buildSection(
              "Prohibited Activities",
              [
                "• Creating fake accounts or bots",
                "• Attempting to hack or compromise the platform",
                "• Sharing malicious software or links",
                "• Violating any applicable laws or regulations",
                "• Interfering with other users' experience",
                "• Commercial use without permission",
              ],
            ),
            _buildSection(
              "Content Ownership",
              [
                "• You retain ownership of content you create",
                "• You grant us a license to display and distribute your content",
                "• You are responsible for content you post",
                "• We may remove content that violates our guidelines",
                "• You can delete your content at any time",
              ],
            ),
            _buildSection(
              "Privacy and Data",
              [
                "• We collect and use data as described in our Privacy Policy",
                "• You control your privacy settings",
                "• We implement security measures to protect your data",
                "• You can request data deletion",
                "• We comply with applicable data protection laws",
              ],
            ),
            _buildSection(
              "Account Termination",
              [
                "• We may suspend or terminate accounts for violations",
                "• You can delete your account at any time",
                "• Some content may remain visible after account deletion",
                "• We will provide notice before account termination when possible",
                "• Appeals process available for account actions",
              ],
            ),
            _buildSection(
              "Disclaimers",
              [
                "• We provide the service 'as is' without warranties",
                "• We are not responsible for third-party content",
                "• Use the platform at your own risk",
                "• We may experience downtime or technical issues",
                "• Features may change or be discontinued",
              ],
            ),
            _buildSection(
              "Limitation of Liability",
              [
                "• Our liability is limited to the maximum extent permitted by law",
                "• We are not liable for indirect or consequential damages",
                "• Total liability is limited to the amount you paid us",
                "• Some jurisdictions may not allow liability limitations",
              ],
            ),
            _buildSection(
              "Contact Information",
              [
                "For questions about these terms:",
                "Email: legal@inspirtag.com",
                "Address: Legal Department, Inspirtag Inc.",
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
          "Terms of Service",
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 8),
        Text(
          "These terms govern your use of Inspirtag, our social media platform. Please read them carefully.",
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
            color: Color(0xFFFF69B4).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Color(0xFFFF69B4).withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.gavel, color: Color(0xFFFF69B4), size: 20),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  "By using Inspirtag, you agree to these terms and our community guidelines.",
                  style: TextStyle(
                    color: Color(0xFFFF69B4),
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
