import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

class TermsPage extends NyStatefulWidget {
  static RouteView path = ("/terms", (_) => TermsPage());

  TermsPage({super.key}) : super(child: () => _TermsPageState());
}

class _TermsPageState extends NyPage<TermsPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  get init => () {};

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 30),
                      _buildLogoSection(),
                      const SizedBox(height: 30),
                      _buildTermsCard(),
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
            'Terms & Conditions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const Spacer(),
          const SizedBox(width: 36), // Balance the back button
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

  Widget _buildTermsCard() {
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
                      Icons.description_outlined,
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
                        'Terms & Conditions',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF7B68EE),
                          fontFamily: 'Roboto',
                        ),
                      ),
                      Text(
                        'Last updated: ${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}',
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

            const SizedBox(height: 32),

            _buildTermsContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildTermsContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSection(
          '1. Acceptance of Terms',
          'By accessing and using Inspiritag ("the Service"), you accept and agree to be bound by the terms and provision of this agreement. If you do not agree to abide by the above, please do not use this service.\n\nThis agreement complies with the laws and regulations of China, Singapore, Japan, South Korea, Malaysia, Thailand, Indonesia, Philippines, Vietnam, and other Asian jurisdictions where our service is available.',
        ),

        _buildSection(
          '2. Service Description',
          'Inspiritag is a social media platform focused on beauty, hair styling, wellness, and lifestyle content sharing. Users can:\n\n• Share photos and videos of their transformations\n• Connect with beauty professionals and enthusiasts\n• Discover trends and inspiration\n• Book services from verified professionals\n• Participate in community discussions\n\nWe reserve the right to modify, suspend, or discontinue the service at any time with reasonable notice.',
        ),

        _buildSection(
          '3. User Registration and Account Security',
          'To use certain features of our service, you must register for an account. You agree to:\n\n• Provide accurate, current, and complete information\n• Maintain the security of your password and account\n• Accept responsibility for all activities under your account\n• Notify us immediately of any unauthorized use\n• Use only one account per person\n\nWe reserve the right to suspend or terminate accounts that violate these terms or applicable laws.',
        ),

        _buildSection(
          '4. Content Guidelines and User Conduct',
          'Users must comply with local laws and our community guidelines. Prohibited content includes:\n\n• Illegal, harmful, or offensive material\n• Content that violates intellectual property rights\n• Spam, misleading information, or fraudulent content\n• Content promoting violence, discrimination, or hate speech\n• Adult content or content inappropriate for minors\n• Content that violates cultural sensitivities in Asian markets\n\nWe reserve the right to remove content and suspend accounts for violations.',
        ),

        _buildSection(
          '5. Data Protection and Privacy (GDPR/PDPA Compliance)',
          'We are committed to protecting your personal data in accordance with:\n\n• China\'s Personal Information Protection Law (PIPL)\n• Singapore\'s Personal Data Protection Act (PDPA)\n• Japan\'s Act on Protection of Personal Information (APPI)\n• South Korea\'s Personal Information Protection Act (PIPA)\n• Malaysia\'s Personal Data Protection Act\n• Other applicable data protection laws\n\nYour data will be processed lawfully, fairly, and transparently. You have rights to access, correct, delete, and port your data. Please refer to our Privacy Policy for detailed information.',
        ),

        _buildSection(
          '6. Intellectual Property Rights',
          'Content Ownership:\n• You retain ownership of content you post\n• You grant us a license to use, display, and distribute your content\n• You represent that you have rights to all content you post\n• We respect intellectual property rights and respond to valid takedown requests\n\nPlatform Rights:\n• Inspiritag, our logo, and platform features are our intellectual property\n• Users may not copy, modify, or create derivative works without permission',
        ),

        _buildSection(
          '7. Business Services and Transactions',
          'For business accounts and service bookings:\n\n• Business users must provide accurate professional credentials\n• All transactions are subject to our payment terms\n• Refunds and cancellations follow our business policy\n• We facilitate but do not guarantee service quality\n• Disputes should be resolved directly between parties\n• We comply with local business registration requirements',
        ),

        _buildSection(
          '8. Age Restrictions and Parental Consent',
          'Age requirements vary by jurisdiction:\n\n• China: 14+ with parental consent, 18+ without\n• Singapore: 13+ with parental consent, 18+ without\n• Japan: 13+ with parental consent, 20+ without\n• South Korea: 14+ with parental consent, 19+ without\n• Other regions: 13+ with parental consent, 18+ without\n\nParental consent mechanisms are implemented where required by local law.',
        ),

        _buildSection(
          '9. Limitation of Liability',
          'To the maximum extent permitted by law:\n\n• We provide the service "as is" without warranties\n• We are not liable for indirect, incidental, or consequential damages\n• Our total liability is limited to the amount paid for services\n• We do not guarantee uninterrupted or error-free service\n• Users assume risks associated with user-generated content\n\nSome jurisdictions do not allow limitation of liability, so these limitations may not apply to you.',
        ),

        _buildSection(
          '10. Dispute Resolution',
          'Dispute resolution varies by jurisdiction:\n\n• China: Disputes resolved through arbitration in Beijing\n• Singapore: Singapore International Arbitration Centre\n• Japan: Japan Commercial Arbitration Association\n• South Korea: Korean Commercial Arbitration Board\n• Other regions: Arbitration in Singapore under SIAC rules\n\nUsers may also pursue remedies through local consumer protection agencies and courts where applicable.',
        ),

        _buildSection(
          '11. Regulatory Compliance',
          'We comply with local regulations including:\n\n• Content moderation requirements\n• Data localization where required\n• Business licensing and registration\n• Tax obligations and reporting\n• Anti-money laundering (AML) requirements\n• Know Your Customer (KYC) procedures for business accounts\n• Advertising and marketing regulations',
        ),

        _buildSection(
          '12. Termination',
          'Either party may terminate this agreement:\n\n• Users may delete their accounts at any time\n• We may suspend or terminate accounts for violations\n• Upon termination, your right to use the service ceases\n• We will retain data as required by law and delete as requested\n• Certain provisions survive termination (liability, intellectual property)',
        ),

        _buildSection(
          '13. Changes to Terms',
          'We may update these terms to reflect:\n\n• Changes in law or regulation\n• New features or services\n• Security or safety improvements\n• Clarifications based on user feedback\n\nUsers will be notified of material changes 30 days in advance. Continued use constitutes acceptance of updated terms.',
        ),

        _buildSection(
          '14. Contact Information',
          'For questions about these terms or our service:\n\nEmail: legal@inspiritag.com\nAddress: [Company Address]\nPhone: [Contact Number]\n\nFor region-specific inquiries:\n• China: china-support@inspiritag.com\n• Singapore: sg-support@inspiritag.com\n• Japan: japan-support@inspiritag.com\n• South Korea: korea-support@inspiritag.com',
        ),

        _buildSection(
          '15. Governing Law',
          'These terms are governed by the laws of Singapore, with specific provisions for:\n\n• Chinese users: Additional compliance with PRC laws\n• Japanese users: Compliance with Japanese consumer protection laws\n• Korean users: Compliance with Korean e-commerce laws\n• Other jurisdictions: Local consumer protection laws apply\n\nIn case of conflicts between local law and these terms, local law prevails.',
        ),

        const SizedBox(height: 24),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Important Notice',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'These terms are available in multiple languages. In case of discrepancies between language versions, the English version shall prevail, except where local law requires otherwise.\n\nBy using Inspiritag, you acknowledge that you have read, understood, and agree to be bound by these Terms and Conditions.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            fontFamily: 'Roboto',
          ),
        ),
        const SizedBox(height: 12),
        Text(
          content,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
            height: 1.6,
            fontFamily: 'Roboto',
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
