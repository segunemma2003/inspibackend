import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

class BusinessProfilePage extends NyStatefulWidget {
  static RouteView path = ("/business-profile", (_) => BusinessProfilePage());
  
  BusinessProfilePage({super.key}) : super(child: () => _BusinessProfilePageState());
}

class _BusinessProfilePageState extends NyPage<BusinessProfilePage> {
  @override
  get init => () {};

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [

              _buildTopBar(),

              const SizedBox(height: 20),

              _buildProfileSection(),

              const SizedBox(height: 20),

              _buildBusinessDetails(),

              const SizedBox(height: 20),

              _buildSocialMediaSection(),

              const SizedBox(height: 20),

              _buildImageGrid(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Business Account',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          Row(
            children: [

              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.edit, size: 14, color: Colors.grey[600]),
                    SizedBox(width: 4),
                    Text(
                      'EDIT',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 12),

              Icon(
                Icons.menu,
                size: 24,
                color: Colors.black,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection() {
    return Column(
      children: [

        CircleAvatar(
          radius: 60,
          backgroundColor: Colors.grey[200],
          child: Icon(
            Icons.person,
            size: 60,
            color: Colors.grey[400],
          ),
        ),

        const SizedBox(height: 16),

        Text(
          'Sarah Johnson',
          style: TextStyle(
            fontSize: 24,
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
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(height: 20),

        Container(
          width: 200,
          height: 45,
          child: ElevatedButton(
            onPressed: () {
              showToastSuccess(title: "Book Now", description: "Redirecting to booking system");
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF00BFFF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: Text(
              'BOOK NOW',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBusinessDetails() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Text(
            'Serenity Hair Salon',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),

          const SizedBox(height: 12),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.location_on,
                color: Colors.grey[600],
                size: 20,
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Unit 2 Mustafa House, 1 Portesbery Road, Camberley, Surrey, GU15 3TA',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Icon(
                Icons.phone,
                color: Colors.grey[600],
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                '01232045678',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSocialMediaSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSocialIcon(Icons.camera_alt, [Color(0xFFE1306C), Color(0xFFFD1D1D)]),
              _buildSocialIcon(Icons.facebook, [Color(0xFF1877F2)]),
              _buildSocialIcon(Icons.close, [Colors.black]),
              _buildSocialIcon(Icons.work, [Color(0xFF0077B5)]),
              _buildSocialIcon(Icons.chat, [Color(0xFF25D366)]),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.favorite,
                color: Colors.red,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                '26 likes',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon, List<Color> colors) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(colors: colors),
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: 20,
      ),
    );
  }

  Widget _buildImageGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 1,
        ),
        itemCount: 6,
        itemBuilder: (context, index) {
          return _buildGridItem(index);
        },
      ),
    );
  }

  Widget _buildGridItem(int index) {
    List<Color> colors = [
      Colors.blue[100]!,
      Colors.green[100]!,
      Colors.purple[100]!,
      Colors.orange[100]!,
      Colors.pink[100]!,
      Colors.teal[100]!,
    ];

    return Container(
      decoration: BoxDecoration(
        color: colors[index],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          Center(
            child: Icon(
              Icons.image,
              size: 40,
              color: Colors.grey[400],
            ),
          ),

          if (index == 0 || index == 2)
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(
                  index == 0 ? Icons.photo_library : Icons.play_arrow,
                  color: Colors.white,
                  size: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

