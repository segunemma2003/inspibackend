import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_app/resources/pages/base_navigation_hub.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';
import '/app/networking/post_api_service.dart';
import '/app/networking/category_api_service.dart';
import '/app/models/category.dart';

class Upload extends StatefulWidget {
  const Upload({super.key});

  @override
  createState() => _UploadState();
}

class _UploadState extends NyState<Upload> {
  // File handling
  PlatformFile? _selectedFile;
  bool _isUploading = false;
  bool _isUploadComplete = false;
  String? _uploadedFileUrl;
  double _uploadProgress = 0.0;
  String _uploadStatus = '';

  // Video player
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;

  // Form state
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _captionController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  bool _isSubmitting = false;

  // Categories
  List<Category> _categories = [];
  Category? _selectedCategory;

  @override
  get init => () async {
        await _loadCategories();
      };

  @override
  void dispose() {
    _captionController.dispose();
    _locationController.dispose();
    _tagsController.dispose();
    _disposeVideoController();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await api<CategoryApiService>(
        (request) => request.getCategories(),
      );

      if (categories != null) {
        setState(() {
          _categories = categories;
        });
        print('📱 Upload: Loaded ${_categories.length} categories');
      }
    } catch (e) {
      print('❌ Upload: Error loading categories: $e');
      showToast(title: 'Error', description: 'Failed to load categories');
    }
  }

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _selectedFile == null
            ? _buildInitialUploadView()
            : _buildFilePreviewAndForm(),
      ),
    );
  }

  Widget _buildInitialUploadView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          const SizedBox(height: 40),
          _buildLogoSection(),
          const SizedBox(height: 40),
          _buildTitleSection(),
          const SizedBox(height: 40),
          _buildDropZone(),
          const SizedBox(height: 20),
          _buildFileSupportInfo(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildFilePreviewAndForm() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Top bar with back button
          _buildTopBar(),

          // File preview section
          _buildFilePreview(),

          // Status indicator
          _buildStatusIndicator(),

          // Show upload progress if uploading
          if (_isUploading) _buildUploadProgress(),

          // Show form after upload is complete
          if (_isUploadComplete)
            _buildPostForm()
          else if (!_isUploading)
            _buildUploadButton(),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              setState(() {
                _selectedFile = null;
                _isUploadComplete = false;
                _uploadedFileUrl = null;
                _uploadProgress = 0.0;
                _uploadStatus = '';
                _captionController.clear();
                _locationController.clear();
                _tagsController.clear();
                _selectedCategory = null;
              });
              _disposeVideoController();
            },
            icon: const Icon(Icons.arrow_back),
          ),
          const Expanded(
            child: Text(
              'Create Post',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildFilePreview() {
    if (_selectedFile == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(16),
      constraints: const BoxConstraints(
        maxHeight: 400,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[100],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: _isImageFile(_selectedFile!)
            ? Image.file(
                File(_selectedFile!.path!),
                fit: BoxFit.contain,
                width: double.infinity,
              )
            : _buildVideoPreview(),
      ),
    );
  }

  Widget _buildVideoPreview() {
    if (_videoController != null && _isVideoInitialized) {
      return Container(
        width: double.infinity,
        color: Colors.black,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Video player
            Center(
              child: AspectRatio(
                aspectRatio: _videoController!.value.aspectRatio,
                child: VideoPlayer(_videoController!),
              ),
            ),
            // Play/Pause overlay
            Center(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    if (_videoController!.value.isPlaying) {
                      _videoController!.pause();
                    } else {
                      _videoController!.play();
                    }
                  });
                },
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _videoController!.value.isPlaying
                        ? Icons.pause
                        : Icons.play_arrow,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
            ),
            // Video info overlay
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _selectedFile!.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatFileSize(_selectedFile!.size),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      // Fallback for when video is not initialized
      return Container(
        width: double.infinity,
        height: 300,
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              color: Colors.white,
            ),
            const SizedBox(height: 16),
            const Text(
              'Loading video preview...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                _selectedFile!.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildStatusIndicator() {
    if (_selectedFile == null) return const SizedBox.shrink();

    final fileSize = _selectedFile!.size;
    final fileSizeMB = fileSize / (1024 * 1024);

    IconData statusIcon;
    Color statusColor;
    Color bgColor;
    Color borderColor;
    String statusText;

    if (_isSubmitting) {
      // Creating post
      statusIcon = Icons.cloud_upload;
      statusColor = Colors.blue[700]!;
      bgColor = Colors.blue[50]!;
      borderColor = Colors.blue[200]!;
      statusText = 'Creating your post...';
    } else if (_isUploadComplete) {
      // Upload complete, ready to create post
      statusIcon = Icons.check_circle;
      statusColor = Colors.green[700]!;
      bgColor = Colors.green[50]!;
      borderColor = Colors.green[200]!;
      statusText =
          'File uploaded successfully! Fill in the details to create your post.';
    } else if (_isUploading) {
      // Currently uploading
      statusIcon = Icons.upload_file;
      statusColor = Colors.orange[700]!;
      bgColor = Colors.orange[50]!;
      borderColor = Colors.orange[200]!;
      statusText = _uploadStatus.isNotEmpty
          ? _uploadStatus
          : 'Uploading file to cloud storage...';
    } else {
      // File selected, ready to upload
      statusIcon = Icons.cloud_upload_outlined;
      statusColor = Colors.teal[700]!;
      bgColor = Colors.teal[50]!;
      borderColor = Colors.teal[200]!;
      statusText =
          'File selected (${fileSizeMB.toStringAsFixed(1)} MB). Ready to upload to cloud.';
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 2),
      ),
      child: Row(
        children: [
          Icon(
            statusIcon,
            color: statusColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
                if (_isUploading && _uploadProgress > 0) ...[
                  const SizedBox(height: 8),
                  Text(
                    '${(_uploadProgress * 100).toInt()}% complete',
                    style: TextStyle(
                      fontSize: 12,
                      color: statusColor.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadProgress() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Uploading to Cloud',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: _uploadProgress,
            backgroundColor: Colors.grey[200],
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF69B4)),
            minHeight: 8,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(_uploadProgress * 100).toInt()}%',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Flexible(
                child: Text(
                  _uploadStatus,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUploadButton() {
    if (_selectedFile == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(16),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isUploading ? null : _uploadFile,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF69B4),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          disabledBackgroundColor: Colors.grey[400],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_upload,
              color: Colors.white,
              size: 20,
            ),
            SizedBox(width: 12),
            Text(
              'Upload to Cloud',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostForm() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Post Details',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // Caption field
            _buildTextField(
              controller: _captionController,
              label: 'Caption *',
              hint: 'Write a caption for your post...',
              maxLines: 4,
              required: true,
            ),
            const SizedBox(height: 16),

            // Category dropdown
            _buildCategoryDropdown(),
            const SizedBox(height: 16),

            // Tags field
            _buildTextField(
              controller: _tagsController,
              label: 'Tags',
              hint: 'hair, beauty, style (comma separated)',
            ),
            const SizedBox(height: 16),

            // Location field
            _buildTextField(
              controller: _locationController,
              label: 'Location',
              hint: 'Add location...',
            ),
            const SizedBox(height: 24),

            // Submit button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitPost,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF69B4),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  disabledBackgroundColor: Colors.grey[400],
                ),
                child: _isSubmitting
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Creating Post...',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      )
                    : const Text(
                        'Create Post',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    bool required = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: required
              ? (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'This field is required';
                  }
                  return null;
                }
              : null,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[500]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFFF69B4), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Category *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<Category>(
          value: _selectedCategory,
          decoration: InputDecoration(
            hintText: 'Select a category',
            hintStyle: TextStyle(color: Colors.grey[500]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFFF69B4), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          validator: (value) {
            if (value == null) {
              return 'Please select a category';
            }
            return null;
          },
          items: _categories.map((category) {
            return DropdownMenuItem<Category>(
              value: category,
              child: Text(category.name ?? 'Unknown Category'),
            );
          }).toList(),
          onChanged: (Category? value) {
            setState(() {
              _selectedCategory = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildLogoSection() {
    return Column(
      children: [
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
              'logo.png',
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
        RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: 'inspi',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFFF69B4),
                  letterSpacing: -0.5,
                  fontFamily: 'Roboto',
                ),
              ),
              TextSpan(
                text: 'r',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFFFD700),
                  letterSpacing: -0.5,
                  fontFamily: 'Roboto',
                ),
              ),
              TextSpan(
                text: 'tag',
                style: TextStyle(
                  fontSize: 28,
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

  Widget _buildTitleSection() {
    return Column(
      children: [
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
      height: 300,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey[300]!,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(16),
        color: Colors.grey[50],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF69B4).withValues(alpha: 0.1),
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
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFF00BFFF).withValues(alpha: 0.1),
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
          Text(
            'or',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontFamily: 'Roboto',
            ),
          ),
          const SizedBox(height: 24),
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
                  color: const Color(0xFFFF69B4).withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: _pickFile,
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
      'Supports images and videos of any size',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 12,
        color: Colors.grey[500],
        fontFamily: 'Roboto',
      ),
    );
  }

  // File picker and video player methods
  Future<void> _initializeVideoPlayer(PlatformFile file) async {
    await _disposeVideoController();

    final videoExtensions = ['mp4', 'mov', 'avi', 'mkv', 'webm', 'm4v'];
    final isVideo = videoExtensions.contains(file.extension?.toLowerCase());

    if (isVideo && file.path != null) {
      try {
        _videoController = VideoPlayerController.file(File(file.path!));
        await _videoController!.initialize();

        setState(() {
          _isVideoInitialized = true;
        });

        print('📹 Video player initialized for: ${file.name}');
      } catch (e) {
        print('❌ Error initializing video player: $e');
        setState(() {
          _isVideoInitialized = false;
        });
      }
    } else {
      setState(() {
        _isVideoInitialized = false;
      });
    }
  }

  Future<void> _disposeVideoController() async {
    if (_videoController != null) {
      await _videoController!.dispose();
      _videoController = null;
      setState(() {
        _isVideoInitialized = false;
      });
    }
  }

  void _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.media,
        allowMultiple: false,
        allowedExtensions: null,
      );

      if (result != null && result.files.single.path != null) {
        final file = result.files.single;

        setState(() {
          _selectedFile = file;
          _uploadStatus = 'File selected';
        });

        await _initializeVideoPlayer(file);

        print('📁 Selected file: ${file.name}');
        print(
            '📁 File size: ${file.size} bytes (${(file.size / 1024 / 1024).toStringAsFixed(2)} MB)');
        print('📁 File extension: ${file.extension}');
        print('📁 File path: ${file.path}');
      }
    } catch (e) {
      print('Error picking file: $e');
      showToast(title: 'Error', description: 'Failed to pick file');
    }
  }

  // Upload methods - Always use presigned URL
  Future<void> _uploadFile() async {
    if (_selectedFile == null) return;

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
      _uploadStatus = 'Preparing upload...';
    });

    try {
      final fileSize = _selectedFile!.size;
      final fileSizeMB = fileSize / (1024 * 1024);

      print('📁 File: ${_selectedFile!.name}');
      print('📁 Size: ${fileSizeMB.toStringAsFixed(2)} MB');
      print('📤 Upload: Using presigned URL upload for all files');

      await _uploadWithPresignedUrl();
    } catch (e) {
      print('❌ Upload: Upload failed: $e');
      setState(() {
        _isUploading = false;
        _uploadStatus = 'Upload failed';
      });

      String errorMessage = 'Failed to upload file';
      if (e.toString().contains('network')) {
        errorMessage = 'Network error. Please check your connection';
      } else if (e.toString().contains('timeout')) {
        errorMessage = 'Request timed out. Please try again';
      }

      showToast(
        title: 'Upload Failed',
        description: errorMessage,
        style: ToastNotificationStyleType.danger,
      );
    }
  }

  Future<void> _uploadWithPresignedUrl() async {
    try {
      setState(() {
        _uploadStatus = 'Getting upload URL...';
      });

      print('📤 Upload: Getting presigned URL from API...');

      final filename = _selectedFile!.name;
      final contentType = _getContentType(_selectedFile!);
      final fileSize = _selectedFile!.size;

      print('📤 Upload: Presigned URL Request Data:');
      print('📤 Upload: - filename: "$filename"');
      print('📤 Upload: - contentType: "$contentType"');
      print(
          '📤 Upload: - fileSize: $fileSize bytes (${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB)');

      // Step 1: Get upload URL from API
      print('🔵 REQUEST: getUploadUrl()');
      print('  - filename: $filename');
      print('  - contentType: $contentType');
      print(
          '  - fileSize: $fileSize (${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB)');

      final uploadUrlResponse = await api<PostApiService>(
        (request) => request.getUploadUrl(
          filename: filename,
          contentType: contentType,
          fileSize: fileSize,
        ),
      );

      if (uploadUrlResponse == null || uploadUrlResponse['success'] != true) {
        print(
            '❌ Upload: Failed to get upload URL - Response: $uploadUrlResponse');
        throw Exception('Failed to get upload URL from server');
      }

      print('📤 Upload: Presigned URL API Response received');

      final uploadData = uploadUrlResponse['data'];
      final uploadMethod = uploadData['upload_method'] ?? 'presigned';
      final filePath = uploadData['file_path'];

      print('📤 Upload: Upload method: "$uploadMethod"');
      print('📤 Upload: File path: "$filePath"');

      if (uploadMethod == 'chunked') {
        // For very large files, use chunked upload
        await _uploadChunkedFile(filePath);
      } else {
        // For regular files, use presigned URL upload
        await _uploadDirectToS3(uploadData);
      }

      setState(() {
        _uploadedFileUrl = filePath;
        _isUploadComplete = true;
        _uploadStatus = 'Upload complete';
        _isUploading = false;
      });

      print('✅ Upload: File uploaded successfully!');
      showToast(
        title: 'Success',
        description: 'File uploaded successfully!',
        style: ToastNotificationStyleType.success,
      );
    } catch (e) {
      print('❌ Presigned Upload: Failed: $e');
      setState(() {
        _isUploading = false;
        _uploadStatus = 'Upload failed';
      });
      rethrow;
    }
  }

  Future<void> _uploadDirectToS3(Map<String, dynamic> uploadData) async {
    final uploadUrl = uploadData['upload_url'].toString();
    final file = File(_selectedFile!.path!);
    final contentType =
        uploadData['content_type'] ?? _getContentType(_selectedFile!);

    setState(() {
      _uploadStatus = 'Uploading to cloud storage...';
    });

    print('🔵 UPLOAD: Direct to S3 with Content-Type');
    print('  - URL: $uploadUrl');
    print('  - Content-Type: $contentType');
    print('  - File size: ${file.lengthSync()} bytes');

    int maxRetries = 3;

    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        print('📤 Upload: Attempt $attempt of $maxRetries');

        // Read the entire file into memory
        final bytes = await file.readAsBytes();

        setState(() {
          _uploadStatus = 'Uploading file...';
          _uploadProgress = 0.3;
        });

        // Create request with proper headers
        final request = http.Request('PUT', Uri.parse(uploadUrl));
        request.headers['Content-Type'] = contentType;
        request.bodyBytes = bytes;

        final streamedResponse = await request.send().timeout(
          const Duration(minutes: 5),
          onTimeout: () {
            throw TimeoutException('Upload timed out');
          },
        );

        setState(() {
          _uploadProgress = 0.9;
        });

        final response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode == 200) {
          print('✅ Upload: File uploaded to S3 successfully!');
          setState(() {
            _uploadStatus = 'Upload successful';
            _uploadProgress = 1.0;
          });
          return; // Success!
        } else {
          print('❌ Upload: S3 returned status ${response.statusCode}');
          print('❌ Upload: Response: ${response.body}');
          print('❌ Upload: Headers sent: Content-Type: $contentType');
          throw Exception(
              'S3 upload failed with status ${response.statusCode}');
        }
      } catch (e) {
        print('❌ Upload: Attempt $attempt failed: $e');

        if (attempt < maxRetries) {
          final waitSeconds = attempt * 2;
          print('🔄 Upload: Retrying in $waitSeconds seconds...');

          setState(() {
            _uploadStatus = 'Retrying... (Attempt ${attempt + 1}/$maxRetries)';
            _uploadProgress = 0.0;
          });

          await Future.delayed(Duration(seconds: waitSeconds));
        } else {
          print('❌ Upload: All $maxRetries attempts failed');
          rethrow;
        }
      }
    }
  }

  Future<void> _uploadChunkedFile(String filePath) async {
    try {
      setState(() {
        _uploadStatus = 'Preparing chunked upload...';
      });

      print('📤 Upload: Using chunked upload method');

      const chunkSize = 5 * 1024 * 1024; // 5MB chunks
      final totalChunks = (_selectedFile!.size / chunkSize).ceil();

      // Step 2: Get chunked upload URLs
      final chunkedResponse = await api<PostApiService>(
        (request) => request.getChunkedUploadUrl(
          filename: _selectedFile!.name,
          contentType: _getContentType(_selectedFile!),
          totalSize: _selectedFile!.size,
          chunkSize: chunkSize,
        ),
      );

      if (chunkedResponse == null || chunkedResponse['success'] != true) {
        throw Exception('Failed to get chunked upload URLs');
      }

      final chunkData = chunkedResponse['data'];
      final chunkUrls = chunkData['chunk_urls'] as List;

      print('📤 Upload: Total chunks: $totalChunks');

      // Step 3: Upload each chunk
      final file = File(_selectedFile!.path!);
      for (int i = 0; i < totalChunks; i++) {
        final chunkStart = i * chunkSize;
        final chunkEnd = (i + 1) * chunkSize > _selectedFile!.size
            ? _selectedFile!.size
            : (i + 1) * chunkSize;

        final chunk = file.readAsBytesSync().sublist(chunkStart, chunkEnd);
        final chunkUrl = chunkUrls[i]['upload_url'];

        setState(() {
          _uploadStatus = 'Uploading chunk ${i + 1} of $totalChunks...';
          _uploadProgress = i / totalChunks;
        });

        print('📤 Upload: Uploading chunk ${i + 1}/$totalChunks');

        final request = http.Request('PUT', Uri.parse(chunkUrl));
        request.headers['Content-Type'] = _getContentType(_selectedFile!);
        request.bodyBytes = chunk;

        final response = await request.send();
        if (response.statusCode != 200) {
          final errorBody = await response.stream.bytesToString();
          print('❌ Upload: Chunk ${i + 1} failed: ${response.statusCode}');
          print('❌ Upload: Error: $errorBody');
          throw Exception('Failed to upload chunk ${i + 1}');
        }

        print('✅ Upload: Chunk ${i + 1}/$totalChunks uploaded');
      }

      setState(() {
        _uploadStatus = 'Finalizing upload...';
        _uploadProgress = 0.95;
      });

      // Step 4: Complete chunked upload
      print('🔵 REQUEST: completeChunkedUpload()');
      print('  - filePath: $filePath');
      print('  - totalChunks: $totalChunks');

      final completeResponse = await api<PostApiService>(
        (request) => request.completeChunkedUpload(
          filePath: filePath,
          totalChunks: totalChunks,
        ),
      );

      print('🟢 RESPONSE: completeChunkedUpload()');
      print(
          '  - Status: ${completeResponse?['success'] == true ? 'Success' : 'Failed'}');
      print('  - Message: ${completeResponse?['message'] ?? 'No message'}');

      if (completeResponse == null || completeResponse['success'] != true) {
        throw Exception('Failed to complete chunked upload');
      }

      print('✅ Upload: Chunked upload completed successfully!');
      setState(() {
        _uploadStatus = 'Upload complete';
        _uploadProgress = 1.0;
      });
    } catch (e) {
      print('❌ Chunked Upload: Failed: $e');
      rethrow;
    }
  }

  Future<void> _submitPost() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCategory == null) {
      showToast(
        title: 'Error',
        description: 'Please select a category',
        style: ToastNotificationStyleType.warning,
      );
      return;
    }

    if (_captionController.text.trim().isEmpty) {
      showToast(
        title: 'Error',
        description: 'Please enter a caption',
        style: ToastNotificationStyleType.warning,
      );
      return;
    }

    if (!_isUploadComplete || _uploadedFileUrl == null) {
      showToast(
        title: 'Error',
        description: 'File upload not completed',
        style: ToastNotificationStyleType.warning,
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
      _uploadStatus = 'Creating post...';
    });

    try {
      final tags = _tagsController.text
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList();

      print('📝 Upload: Creating post from S3...');
      print('📝 Upload: File path: $_uploadedFileUrl');
      print(
          '📝 Upload: Category: ${_selectedCategory!.name} (ID: ${_selectedCategory!.id})');
      print('📝 Upload: Caption: ${_captionController.text.trim()}');
      print('📝 Upload: Tags: $tags');
      print('📝 Upload: Location: ${_locationController.text.trim()}');

      print('🔵 REQUEST: createPostFromS3()');
      print('  - filePath: $_uploadedFileUrl');
      print('  - caption: ${_captionController.text.trim()}');
      print(
          '  - categoryId: ${_selectedCategory!.id} (${_selectedCategory!.name})');
      print('  - tags: ${tags.isNotEmpty ? tags : 'None'}');
      print(
          '  - location: ${_locationController.text.trim().isNotEmpty ? _locationController.text.trim() : 'Not provided'}');

      final response = await api<PostApiService>(
        (request) => request.createPostFromS3(
          filePath: _uploadedFileUrl!,
          caption: _captionController.text.trim(),
          categoryId: _selectedCategory!.id!,
          tags: tags.isNotEmpty ? tags : null,
          location: _locationController.text.trim().isNotEmpty
              ? _locationController.text.trim()
              : null,
        ),
      );

      print('🟢 RESPONSE: createPostFromS3()');
      print(
          '  - Status: ${response?['success'] == true ? 'Success' : 'Failed'}');
      print('  - Message: ${response?['message'] ?? 'No message'}');
      if (response?['data'] != null) {
        print('  - Post ID: ${response?['data']?['id'] ?? 'Not provided'}');
        print(
            '  - Media URL: ${response?['data']?['media_url'] ?? 'Not provided'}');
      }

      if (response != null && response['success'] == true) {
        print('✅ Upload: Post created successfully!');

        showToast(
          title: 'Success',
          description: 'Post created successfully!',
          style: ToastNotificationStyleType.success,
        );

        // Wait a moment for the toast to show
        await Future.delayed(const Duration(milliseconds: 500));

        // Navigate back to feed tab
        if (mounted) {
          // First pop the current screen
          Navigator.of(context).pop(true);

          // Then navigate to the BaseNavigationHub with feed tab selected using Nylo's routeTo
          routeTo(BaseNavigationHub.path,
              navigationType: NavigationType.pushAndRemoveUntil, tabIndex: 0);
        }
      } else {
        throw Exception(
            'Failed to create post: ${response?['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      print('❌ Upload: Submit error: $e');

      String errorMessage = 'Failed to create post';
      if (e.toString().contains('network')) {
        errorMessage = 'Network error. Please check your connection';
      } else if (e.toString().contains('timeout')) {
        errorMessage = 'Request timed out. Please try again';
      } else if (e.toString().contains('unauthorized')) {
        errorMessage = 'Session expired. Please sign in again';
      } else if (e.toString().contains('validation')) {
        errorMessage = 'Invalid data. Please check your inputs';
      }

      showToast(
        title: 'Error',
        description: errorMessage,
        style: ToastNotificationStyleType.danger,
      );
    } finally {
      setState(() {
        _isSubmitting = false;
        _uploadStatus = '';
      });
    }
  }

  // Helper methods
  bool _isImageFile(PlatformFile file) {
    final extension = file.extension?.toLowerCase();
    return ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(extension);
  }

  String _getContentType(PlatformFile file) {
    final extension = file.extension?.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'mp4':
        return 'video/mp4';
      case 'mov':
        return 'video/quicktime';
      case 'avi':
        return 'video/x-msvideo';
      case 'mkv':
        return 'video/x-matroska';
      case 'webm':
        return 'video/webm';
      case 'm4v':
        return 'video/x-m4v';
      default:
        return 'application/octet-stream';
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
