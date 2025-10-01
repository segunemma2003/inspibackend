import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

class Feed extends StatefulWidget {
  const Feed({super.key});

  @override
  createState() => _FeedState();
}

class _FeedState extends NyState<Feed> {
  List<dynamic> _feedItems = [];
  String _selectedCategory = 'ALL';
  List<String> _categories = [
    'ALL',
    'HAIR',
    'FITNESS',
    'MAKEUP',
    'FASHION',
    'SKINCARE'
  ];

  @override
  LoadingStyle get loadingStyle => LoadingStyle.skeletonizer();

  @override
  get init => () async {
        // Simulate loading data
        await Future.delayed(Duration(seconds: 2));
        _feedItems = List.generate(
            10,
            (index) => {
                  'id': index,
                  'username': 'Anonymous',
                  'content':
                      'This is a sample post content for feed item $index',
                  'likes': index * 5,
                  'comments': index * 2,
                  'category': _categories[index % _categories.length],
                  'date': 'Sep 11',
                });
      };

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Logo and App Name Section
          _buildHeaderSection(),

          // Category Buttons
          _buildCategorySection(),

          // Feed Content
          Expanded(
            child: _buildFeedList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: EdgeInsets.only(top: 50, bottom: 20),
      child: Column(
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
      ),
    );
  }

  Widget _buildCategorySection() {
    return Container(
      height: 50,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = category == _selectedCategory;

          return Container(
            margin: EdgeInsets.only(right: 12),
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _selectedCategory = category;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isSelected ? Color(0xFF00BFFF) : Colors.white,
                side: BorderSide(
                  color: Color(0xFF00BFFF),
                  width: 1,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                elevation: 0,
              ),
              child: Text(
                category,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeedList() {
    return ListView.builder(
      itemCount: _feedItems.length,
      itemBuilder: (context, index) {
        final item = _feedItems[index];
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User info
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: Color(0xFF9ACD32), // Yellow-green gradient
                    child: Text(
                      item['username'][0].toUpperCase(),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['username'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          item['date'],
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Category tag
                  GestureDetector(
                    onTap: () {
                      routeTo('/tags');
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Color(0xFFFF69B4), // Pink
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '💄', // Hair emoji or category emoji
                            style: TextStyle(fontSize: 12),
                          ),
                          SizedBox(width: 4),
                          Text(
                            item['category'].toLowerCase(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              // Content
              Text(
                item['content'],
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 16),
              // Placeholder for image
              Container(
                width: double.infinity,
                height: 500,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(
                    Icons.image,
                    size: 50,
                    color: Colors.grey[400],
                  ),
                ),
              ),
              SizedBox(height: 16),
              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildActionButton(Icons.favorite_border, '${item['likes']}'),
                  _buildActionButton(Icons.bookmark_border, 'Save'),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButton(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[600], size: 20),
        SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
