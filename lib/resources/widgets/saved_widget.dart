import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

class Saved extends StatefulWidget {
  const Saved({super.key});

  @override
  createState() => _SavedState();
}

class _SavedState extends NyState<Saved> {
  @override
  get init => () {};

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7), // Light grey background
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 40),

              // Logo Section
              _buildLogoSection(),

              const SizedBox(height: 40),

              // Main Content Card
              Expanded(
                child: _buildSavedCard(),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    return Column(
      children: [
        // Logo image - Fixed asset loading
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              'logo.png', // Fixed path
              width: 80,
              height: 80,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.image_not_supported,
                  size: 40,
                  color: Colors.grey[400],
                );
              },
            ).localAsset(),
          ),
        ),

        const SizedBox(height: 16),

        // App name with colors - matching inspirtag branding
        RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: 'inspi',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFFF69B4), // Pink
                  letterSpacing: -0.5,
                  fontFamily: 'Roboto',
                ),
              ),
              TextSpan(
                text: 'r',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFFFD700), // Yellow
                  letterSpacing: -0.5,
                  fontFamily: 'Roboto',
                ),
              ),
              TextSpan(
                text: 'tag',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF00BFFF), // Blue
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

  Widget _buildSavedCard() {
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
            // Header Section
            Row(
              children: [
                // Small bookmark icon with gradient border
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFFF69B4), // Pink
                        Color(0xFFFFD700), // Yellow
                        Color(0xFF9ACD32), // Green
                        Color(0xFF00BFFF), // Blue
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
                      Icons.bookmark_border_outlined,
                      color: Colors.grey[700],
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Title and count
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Saved',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF7B68EE), // Purple color from image
                          fontFamily: 'Roboto',
                        ),
                      ),
                      Text(
                        '0 inspirations saved',
                        style: TextStyle(
                          fontSize: 16,
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

            const Spacer(),

            // Empty State
            Center(
              child: Column(
                children: [
                  // Large bookmark icon with gradient border
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFFF69B4), // Pink
                          Color(0xFFFFD700), // Yellow
                          Color(0xFF9ACD32), // Green
                          Color(0xFF00BFFF), // Blue
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(17),
                        color: Colors.white,
                      ),
                      child: Icon(
                        Icons.bookmark_border_outlined,
                        color: Colors.grey[600],
                        size: 50,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  Text(
                    'No saved posts',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                      fontFamily: 'Roboto',
                    ),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    'Start saving posts you love for\ninspiration!',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w400,
                      height: 1.4,
                      fontFamily: 'Roboto',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const Spacer(),
          ],
        ),
      ),
    );
  }
}
