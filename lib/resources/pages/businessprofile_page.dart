import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

class BusinessprofilePage extends NyStatefulWidget {
  static RouteView path = ("/businessprofile", (_) => BusinessprofilePage());

  BusinessprofilePage({super.key})
      : super(child: () => _BusinessprofilePageState());
}

class _BusinessprofilePageState extends NyPage<BusinessprofilePage> {
  @override
  get init => () {};

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [

                _buildTopBar(),

                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 20),

                        _buildProfilePicture(),

                        const SizedBox(height: 20),

                        _buildNameAndTitle(),

                        const SizedBox(height: 20),

                        _buildBookNowButton(),

                        const SizedBox(height: 30),

                        _buildBusinessInfo(),

                        const SizedBox(height: 20),

                        _buildSocialMediaIcons(),

                        const SizedBox(height: 30),

                        _buildLikesSection(),

                        const SizedBox(height: 20),

                        _buildPostsGrid(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
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
              child: Icon(
                Icons.arrow_back,
                size: 20,
                color: Colors.black87,
              ),
            ),
          ),

          Expanded(
            child: Center(
              child: Text(
                'Business Account',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),
          ),

          Container(width: 36),
        ],
      ),
    );
  }

  Widget _buildProfilePicture() {
    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey[200],
      ),
      child: ClipOval(
        child: Container(
          color: Colors.grey[300],
          child: Icon(
            Icons.person,
            size: 80,
            color: Colors.grey[500],
          ),
        ),
      ),
    );
  }

  Widget _buildNameAndTitle() {
    return Column(
      children: [
        Text(
          'Sarah Johnson',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Senior Hair Stylist',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildBookNowButton() {
    return Container(
      width: 200,
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          showToastSuccess(
              title: "Book Now", description: "Booking system opened");
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF00BFFF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 0,
        ),
        child: Text(
          'BOOK NOW',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  Widget _buildBusinessInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          Text(
            'Serenity Hair Salon',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Unit 2 Mustafa House, 1 Portesbery\nRoad, Camberley, Surrey, GU15 3TA',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '01232045678',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSocialMediaIcons() {
    final socialIcons = [
      {'color': Color(0xFFE4405F), 'icon': Icons.camera_alt}, // Instagram
      {'color': Color(0xFF1877F2), 'icon': Icons.facebook}, // Facebook
      {'color': Color(0xFF000000), 'icon': Icons.close}, // X/Twitter
      {'color': Color(0xFF0077B5), 'icon': Icons.work}, // LinkedIn
      {'color': Color(0xFF25D366), 'icon': Icons.phone}, // WhatsApp
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: socialIcons.map((social) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 8),
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: social['color'] as Color,
            shape: BoxShape.circle,
          ),
          child: Icon(
            social['icon'] as IconData,
            color: Colors.white,
            size: 24,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLikesSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.favorite,
          color: Colors.red,
          size: 24,
        ),
        SizedBox(width: 8),
        Text(
          '26 likes',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildPostsGrid() {

    final posts = [
      {'id': 0, 'hasMultiple': true, 'hasVideo': false},
      {'id': 1, 'hasMultiple': false, 'hasVideo': false},
      {'id': 2, 'hasMultiple': false, 'hasVideo': true},
      {'id': 3, 'hasMultiple': false, 'hasVideo': false},
      {'id': 4, 'hasMultiple': false, 'hasVideo': false},
      {'id': 5, 'hasMultiple': false, 'hasVideo': false},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
          childAspectRatio: 1,
        ),
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          return _buildPostItem(post);
        },
      ),
    );
  }

  Widget _buildPostItem(Map<String, dynamic> post) {

    final gradients = [
      [Colors.blue[200]!, Colors.green[200]!],
      [Colors.orange[200]!, Colors.pink[200]!],
      [Colors.purple[200]!, Colors.blue[200]!],
      [Colors.green[200]!, Colors.teal[200]!],
      [Colors.pink[200]!, Colors.purple[200]!],
      [Colors.teal[200]!, Colors.blue[200]!],
    ];

    final gradientIndex = post['id'] % gradients.length;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        gradient: LinearGradient(
          colors: gradients[gradientIndex],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [

          Container(
            width: double.infinity,
            height: double.infinity,
            child: Icon(
              Icons.image,
              color: Colors.white.withOpacity(0.7),
              size: 30,
            ),
          ),

          if (post['hasVideo'] == true)
            Positioned(
              top: 8,
              right: 8,
              child: Icon(
                Icons.play_circle_filled,
                color: Colors.white,
                size: 20,
              ),
            ),

          if (post['hasMultiple'] == true)
            Positioned(
              top: 8,
              right: 8,
              child: Icon(
                Icons.copy,
                color: Colors.white,
                size: 16,
              ),
            ),
        ],
      ),
    );
  }
}
