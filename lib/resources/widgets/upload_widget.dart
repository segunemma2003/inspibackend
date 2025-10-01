import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';

class Upload extends StatefulWidget {
  const Upload({super.key});

  @override
  createState() => _UploadState();
}

class _UploadState extends NyState<Upload> {
  @override
  get init => () {};

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 40),

              // Logo Section
              _buildLogoSection(),

              const SizedBox(height: 40),

              // Title Section
              _buildTitleSection(),

              const SizedBox(height: 40),

              // Drop Zone
              _buildDropZone(),

              const SizedBox(height: 20), // Changed from Spacer to fixed height

              // File Support Info
              _buildFileSupportInfo(),

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

        // App name with colors
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
                  fontFamily: 'Roboto', // Added font family
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

  Widget _buildTitleSection() {
    return Column(
      children: [
        // Main title
        RichText(
          textAlign: TextAlign.center,
          text: const TextSpan(
            children: [
              TextSpan(
                text: 'Share Your ',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                  fontFamily: 'Roboto',
                ),
              ),
              TextSpan(
                text: 'Transfor',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFFD700),
                  fontFamily: 'Roboto',
                ),
              ),
              TextSpan(
                text: 'mation',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF9ACD32),
                  fontFamily: 'Roboto',
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Tagline
        Text(
          'Inspire others with your style journey',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
            fontWeight: FontWeight.w400,
            fontFamily: 'Roboto',
          ),
        ),
      ],
    );
  }

  Widget _buildDropZone() {
    return Container(
      width: double.infinity,
      height: 300, // Fixed height instead of Expanded
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey[300]!,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(16),
        color: Colors.grey[50], // Added subtle background
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Image icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF69B4).withOpacity(0.1),
                  border: Border.all(color: const Color(0xFFFF69B4), width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.image,
                  color: Color(0xFFFF69B4),
                  size: 30,
                ),
              ),
              const SizedBox(width: 20),
              // Video icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFF00BFFF).withOpacity(0.1),
                  border: Border.all(color: const Color(0xFF00BFFF), width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.videocam,
                  color: Color(0xFF00BFFF),
                  size: 30,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Drop text
          Text(
            'Drop your transformation here',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
              fontFamily: 'Roboto',
            ),
          ),

          const SizedBox(height: 16),

          // Or text
          Text(
            'or',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontFamily: 'Roboto',
            ),
          ),

          const SizedBox(height: 24),

          // Choose File Button
          Container(
            height: 50,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF69B4), Color(0xFF9C27B0)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF69B4).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () {
                // Add file picker functionality here
                _pickFile();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.upload,
                    color: Colors.white,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Choose File',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Roboto',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileSupportInfo() {
    return Text(
      'Supports images and videos up to 10MB',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 12,
        color: Colors.grey[500],
        fontFamily: 'Roboto',
      ),
    );
  }

  // File picker method - you'll need to add file_picker dependency
  void _pickFile() async {
    try {
      showToastSuccess(title: "Choose File", description: "File picker opened");

      // TODO: Implement actual file picker
      // Example:
      // FilePickerResult? result = await FilePicker.platform.pickFiles(
      //   type: FileType.media,
      //   allowMultiple: false,
      //   allowedExtensions: null,
      // );
      //
      // if (result != null) {
      //   // Handle selected file
      // }
    } catch (e) {
      print("sa");
    }
  }
}
