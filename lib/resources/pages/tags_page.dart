import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

class TagsPage extends NyStatefulWidget {
  static RouteView path = ("/tags", (_) => TagsPage());

  TagsPage({super.key}) : super(child: () => _TagsPageState());
}

class _TagsPageState extends NyPage<TagsPage> {
  List<Map<String, dynamic>> professionals = [
    {
      'name': 'Luis Rodriguez',
      'profession': 'HAIRSTYLIST',
      'image': 'https://via.placeholder.com/60x60/4CAF50/white?text=LR',
    },
    {
      'name': 'James Williams',
      'profession': 'PERSONAL TRAINER',
      'image': 'https://via.placeholder.com/60x60/2196F3/white?text=JW',
    },
    {
      'name': 'Claudia Hill',
      'profession': 'MAKE-UP ARTIST',
      'image': 'https://via.placeholder.com/60x60/E91E63/white?text=CH',
    },
    {
      'name': 'Maria Park',
      'profession': 'NAIL TECHNICIAN',
      'image': 'https://via.placeholder.com/60x60/9C27B0/white?text=MP',
    },
    {
      'name': 'Emma West',
      'profession': 'SKINCARE SPECIALIST',
      'image': 'https://via.placeholder.com/60x60/FF9800/white?text=EW',
    },
  ];

  List<Map<String, dynamic>> displayedProfessionals = [];

  @override
  get init => () {
        displayedProfessionals = List.from(professionals);
      };

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

            // Interactive Elements
            _buildInteractiveElements(),

            const SizedBox(height: 20),

            // Instructions
            _buildInstructions(),

            const SizedBox(height: 20),

            // Professionals List
            Expanded(
              child: _buildProfessionalsList(),
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
          // Back to Feed Button
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
            'TAGS',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          // Info and Notification Icons
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  // Show info dialog or navigate to info page
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('About TAGS'),
                      content: Text(
                          'Browse and discover professionals in your area. Swipe left to forget, swipe right to remember.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('OK'),
                        ),
                      ],
                    ),
                  );
                },
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[200],
                  ),
                  child: Center(
                    child: Text(
                      'i',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12),
              GestureDetector(
                onTap: () {
                  routeTo('/notification');
                },
                child: Stack(
                  children: [
                    Icon(
                      Icons.notifications,
                      size: 24,
                      color: Colors.black,
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
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
          width: 80,
          height: 80,
          fit: BoxFit.contain,
        ).localAsset(),

        const SizedBox(height: 10),

        // App name with second 'i' in yellow and 'r' in blue
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
      ],
    );
  }

  Widget _buildInteractiveElements() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        children: [
          // First button with text
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Color(0xFF00BFFF), width: 1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  'Subheading',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 12),
          // Second empty button
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Color(0xFF00BFFF), width: 1),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          SizedBox(width: 12),
          // Third solid button
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: Color(0xFF00BFFF),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Swipe Card',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(width: 8),
        Icon(Icons.keyboard_double_arrow_left,
            size: 16, color: Colors.grey[600]),
        SizedBox(width: 4),
        Text(
          'to Forget',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(width: 8),
        Container(
          width: 4,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey[600],
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 8),
        Text(
          'Swipe',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(width: 8),
        Icon(Icons.keyboard_double_arrow_right,
            size: 16, color: Colors.grey[600]),
        SizedBox(width: 4),
        Text(
          'to Remember',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildProfessionalsList() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 24.0),
      itemCount: displayedProfessionals.length,
      itemBuilder: (context, index) {
        final professional = displayedProfessionals[index];
        return _buildSwipeableCard(professional, index);
      },
    );
  }

  Widget _buildSwipeableCard(Map<String, dynamic> professional, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: Dismissible(
        key: Key(professional['name']),
        direction: DismissDirection.horizontal,
        onDismissed: (direction) {
          setState(() {
            displayedProfessionals.removeAt(index);
          });

          if (direction == DismissDirection.startToEnd) {
            // Swiped right - Remember
            showToastSuccess(
                description: "Remembered ${professional['name']}!");
          } else {
            // Swiped left - Forget
            showToastSuccess(description: "Forgot ${professional['name']}");
          }
        },
        background: Container(
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.only(left: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.close,
                color: Colors.white,
                size: 30,
              ),
              SizedBox(height: 8),
              Text(
                'FORGET',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        secondaryBackground: Container(
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.centerRight,
          padding: EdgeInsets.only(right: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.favorite,
                color: Colors.white,
                size: 30,
              ),
              SizedBox(height: 8),
              Text(
                'REMEMBER',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 3,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            children: [
              // Profile Picture
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.grey[200],
                child: Text(
                  professional['name'].split(' ').map((n) => n[0]).join(''),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              SizedBox(width: 16),
              // Name and Profession
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      professional['name'],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      professional['profession'],
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              // Menu Icon
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.more_vert,
                  size: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
