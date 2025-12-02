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
import 'user_search_widget.dart';

class Upload extends StatefulWidget {
  const Upload({super.key});

  @override
  createState() => _UploadState();
}

class _UploadState extends NyState<Upload> {

  PlatformFile? _selectedFile; // Keep for backward compatibility/single file preview
  List<PlatformFile> _selectedFiles = []; // New: Support multiple files
  int _currentPreviewIndex = 0; // Track which file is currently being previewed
  bool _isUploading = false;
  bool _isUploadComplete = false;
  bool _showLoadingOverlay = false;
  String? _uploadedFileUrl; // Keep for single file
  List<String> _uploadedFileUrls = []; // New: Support multiple file paths
  double _uploadProgress = 0.0;
  String _uploadStatus = '';
  int _currentUploadingFileIndex = 0; // Track which file is currently uploading

  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  final PageController _pageController = PageController();

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _captionController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  bool _isSubmitting = false;

  List<Category> _categories = [];
  Category? _selectedCategory;

  List<Map<String, dynamic>> _taggedUsers = [];

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
    _pageController.dispose();
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
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: _selectedFiles.isEmpty
                ? _buildInitialUploadView()
                : _buildFilePreviewAndForm(),
          ),
        ),
        if (_showLoadingOverlay) _buildLoadingOverlay(),
      ],
    );
  }

  Widget _buildLoadingOverlay() {
    return Stack(
      children: [
        const ModalBarrier(dismissible: false, color: Colors.black54),
        Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary),
          ),
        ),
      ],
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

          _buildTopBar(),

          _buildFilePreview(),

          _buildStatusIndicator(),

          if (_isUploading) _buildUploadProgress(),

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
                _selectedFiles.clear();
                _currentPreviewIndex = 0;
                _isUploadComplete = false;
                _uploadedFileUrl = null;
                _uploadedFileUrls.clear();
                _uploadProgress = 0.0;
                _uploadStatus = '';
                _captionController.clear();
                _locationController.clear();
                _tagsController.clear();
                _selectedCategory = null;
                _taggedUsers.clear();
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
    if (_selectedFiles.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(16),
      constraints: const BoxConstraints(
        maxHeight: 400,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[100],
      ),
      child: Stack(
        children: [
          // PageView for swiping between files
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: PageView.builder(
              controller: _pageController,
              itemCount: _selectedFiles.length,
              onPageChanged: (index) {
                setState(() {
                  _currentPreviewIndex = index;
                  _selectedFile = _selectedFiles[index];
                });
                _initializeVideoPlayer(_selectedFiles[index]);
              },
              itemBuilder: (context, index) {
                final file = _selectedFiles[index];
                return _buildSingleFilePreview(file);
              },
            ),
          ),
          // Remove button overlay
          if (_selectedFiles.length > 1)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => _removeFile(_currentPreviewIndex),
                  tooltip: 'Remove this file',
                ),
              ),
            ),
          // File counter indicator
          if (_selectedFiles.length > 1)
            Positioned(
              bottom: 8,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _selectedFiles.length,
                  (index) => Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentPreviewIndex == index
                          ? Colors.white
                          : Colors.white.withOpacity(0.4),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSingleFilePreview(PlatformFile file) {
    if (_isImageFile(file)) {
      return Image.file(
        File(file.path!),
        fit: BoxFit.contain,
        width: double.infinity,
      );
    } else {
      // For videos, show preview if it's the current file being viewed
      final isCurrentFile = _selectedFiles.indexOf(file) == _currentPreviewIndex;
      if (isCurrentFile && _selectedFile?.path == file.path) {
        return _buildVideoPreview();
      } else {
        // Show placeholder for other videos
        return Container(
          width: double.infinity,
          height: 300,
          color: Colors.black87,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.videocam, color: Colors.white, size: 48),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  file.name,
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
  }

  void _removeFile(int index) {
    if (index < 0 || index >= _selectedFiles.length) return;

    setState(() {
      _selectedFiles.removeAt(index);
      
      // Adjust preview index
      if (_selectedFiles.isEmpty) {
        _selectedFile = null;
        _currentPreviewIndex = 0;
        _disposeVideoController();
      } else {
        // If we removed the last item, go to previous
        if (_currentPreviewIndex >= _selectedFiles.length) {
          _currentPreviewIndex = _selectedFiles.length - 1;
        }
        _selectedFile = _selectedFiles[_currentPreviewIndex];
        _initializeVideoPlayer(_selectedFiles[_currentPreviewIndex]);
        
        // Update page controller if needed
        if (_pageController.hasClients) {
          _pageController.animateToPage(
            _currentPreviewIndex,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      }
      
      _uploadStatus = _selectedFiles.isEmpty
          ? 'No files selected'
          : '${_selectedFiles.length} file${_selectedFiles.length > 1 ? 's' : ''} selected';
    });
  }

  Widget _buildVideoPreview() {
    if (_videoController != null && _isVideoInitialized) {
      return Container(
        width: double.infinity,
        color: Colors.black,
        child: Stack(
          alignment: Alignment.center,
          children: [

            Center(
              child: AspectRatio(
                aspectRatio: _videoController!.value.aspectRatio,
                child: VideoPlayer(_videoController!),
              ),
            ),

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
    if (_selectedFiles.isEmpty) return const SizedBox.shrink();

    final totalSize = _selectedFiles.fold<int>(0, (sum, file) => sum + file.size);
    final totalSizeMB = totalSize / (1024 * 1024);

    IconData statusIcon;
    Color statusColor;
    Color bgColor;
    Color borderColor;
    String statusText;

    if (_isSubmitting) {

      statusIcon = Icons.cloud_upload;
      statusColor = Colors.blue[700]!;
      bgColor = Colors.blue[50]!;
      borderColor = Colors.blue[200]!;
      statusText = 'Creating your post...';
    } else if (_isUploadComplete) {

      statusIcon = Icons.check_circle;
      statusColor = Colors.green[700]!;
      bgColor = Colors.green[50]!;
      borderColor = Colors.green[200]!;
      if (_selectedFiles.length == 1) {
        statusText = 'File uploaded successfully! Fill in the details to create your post.';
      } else {
        statusText = '${_selectedFiles.length} files uploaded successfully! Fill in the details to create your post.';
      }
    } else if (_isUploading) {
      statusIcon = Icons.upload_file;
      statusColor = Colors.orange[700]!;
      bgColor = Colors.orange[50]!;
      borderColor = Colors.orange[200]!;
      if (_selectedFiles.length > 1) {
        statusText = _uploadStatus.isNotEmpty
            ? _uploadStatus
            : 'Uploading file ${_currentUploadingFileIndex + 1} of ${_selectedFiles.length} to cloud storage...';
      } else {
        statusText = _uploadStatus.isNotEmpty
            ? _uploadStatus
            : 'Uploading file to cloud storage...';
      }
    } else {

      statusIcon = Icons.cloud_upload_outlined;
      statusColor = Colors.teal[700]!;
      bgColor = Colors.teal[50]!;
      borderColor = Colors.teal[200]!;
      if (_selectedFiles.length == 1) {
        statusText = 'File selected (${totalSizeMB.toStringAsFixed(1)} MB). Ready to upload to cloud.';
      } else {
        statusText = '${_selectedFiles.length} files selected (${totalSizeMB.toStringAsFixed(1)} MB total). Ready to upload to cloud.';
      }
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
    if (_selectedFiles.isEmpty) return const SizedBox.shrink();

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

            _buildTextField(
              controller: _captionController,
              label: 'Caption *',
              hint: 'Write a caption for your post...',
              maxLines: 4,
              required: true,
            ),
            const SizedBox(height: 16),

            _buildCategoryDropdown(),
            const SizedBox(height: 16),

            _buildTextField(
              controller: _tagsController,
              label: 'Tags',
              hint: 'hair, beauty, style (comma separated)',
            ),
            const SizedBox(height: 16),

            _buildTextField(
              controller: _locationController,
              label: 'Location',
              hint: 'Add location...',
            ),
            const SizedBox(height: 16),

            const Text(
              'Tag People',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            UserSearchWidget(
              onUsersSelected: (users) {
                setState(() {
                  _taggedUsers = users;
                });
              },
              selectedUsers: _taggedUsers,
            ),
            const SizedBox(height: 24),

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
        Container(
          decoration: BoxDecoration(
            border: Border.all(
                color: Colors.black87, width: 1), // Match other form fields
            borderRadius: BorderRadius.circular(8),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(
              focusColor: Colors.blue.withOpacity(0.1),
              hoverColor: Colors.grey.withOpacity(0.1),
            ),
            child: DropdownButtonFormField<Category>(
              value: _selectedCategory,
              decoration: InputDecoration(
                hintText: 'Select a category',
                filled: true,
                fillColor: Colors.white,
                hintStyle: TextStyle(color: Colors.grey[500]),

                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none, // Remove error border as well
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
              dropdownColor: Colors.white, // Set dropdown background to white
              isExpanded: true,
              style: TextStyle(
                  color: Colors
                      .black), // Explicitly set text color for selected item
              items: _categories.map((category) {
                return DropdownMenuItem<Category>(
                  value: category,
                  child: Text(category.name ?? 'Unknown Category',
                      style: TextStyle(color: Colors.black)),
                );
              }).toList(),
              selectedItemBuilder: (BuildContext context) {
                return _categories.map<Widget>((Category category) {
                  return Text(category.name ?? 'Unknown Category',
                      style: TextStyle(color: Colors.black));
                }).toList();
              },
              onChanged: (Category? value) {
                setState(() {
                  _selectedCategory = value;
                });
              },
            ),
          ),
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
    setState(() {
      _showLoadingOverlay = true; // Show overlay when file picking starts
    });
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.media,
        allowMultiple: true, // Enable multiple file selection
        allowedExtensions: null,
      );

      if (result != null && result.files.isNotEmpty) {
        var files = result.files.where((f) => f.path != null).toList();
        
        if (files.isEmpty) {
          showToast(title: 'Error', description: 'No valid files selected');
          return;
        }

        // Limit to 10 files max
        if (files.length > 10) {
          showToast(
            title: 'Warning',
            description: 'Maximum 10 files allowed. Only first 10 will be used.',
          );
          files = files.take(10).toList();
        }

        setState(() {
          _selectedFiles = files;
          _selectedFile = files.first; // Keep first file for preview compatibility
          _currentPreviewIndex = 0; // Start at first file
          _uploadStatus = '${files.length} file${files.length > 1 ? 's' : ''} selected';
          _uploadedFileUrls = []; // Reset uploaded URLs
          _isUploadComplete = false;
        });

        // Initialize video player for first file if it's a video
        if (files.isNotEmpty) {
          await _initializeVideoPlayer(files.first);
        }

        print('📁 Selected ${files.length} file(s)');
        for (var file in files) {
          print('📁 - ${file.name} (${(file.size / 1024 / 1024).toStringAsFixed(2)} MB)');
        }
      } else {
        print('📁 File picking cancelled');
      }
    } catch (e) {
      print('Error picking file: $e');
      showToast(title: 'Error', description: 'Failed to pick file');
    } finally {
      setState(() {
        _showLoadingOverlay =
            false; // Hide overlay when file picking finishes or errors
      });
    }
  }

  Future<void> _uploadFile() async {
    if (_selectedFiles.isEmpty) return;

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
      _uploadStatus = 'Preparing upload...';
      _uploadedFileUrls = [];
      _currentUploadingFileIndex = 0;
    });

    try {
      print('📤 Upload: Starting upload for ${_selectedFiles.length} file(s)');

      // Step 1: Get all presigned URLs first (in parallel for better performance)
      setState(() {
        _uploadStatus = 'Getting upload URLs for all files...';
      });

      final List<Map<String, dynamic>> uploadDataList = [];
      
      // Get all presigned URLs
      for (int i = 0; i < _selectedFiles.length; i++) {
        final file = _selectedFiles[i];
        setState(() {
          _uploadStatus = 'Getting upload URL for file ${i + 1} of ${_selectedFiles.length}...';
        });

        final uploadUrlResponse = await api<PostApiService>(
          (request) => request.getUploadUrl(
            filename: file.name,
            contentType: _getContentType(file),
            fileSize: file.size,
          ),
        );

        if (uploadUrlResponse == null || uploadUrlResponse['success'] != true) {
          throw Exception('Failed to get upload URL for file ${i + 1}: ${file.name}');
        }

        uploadDataList.add({
          'file': file,
          'uploadData': uploadUrlResponse['data'],
          'fileIndex': i,
        });
      }

      print('✅ Upload: Got ${uploadDataList.length} presigned URLs');

      // Step 2: Upload all files sequentially (to avoid overwhelming the network)
      for (int i = 0; i < uploadDataList.length; i++) {
        final item = uploadDataList[i];
        final file = item['file'] as PlatformFile;
        final uploadData = item['uploadData'] as Map<String, dynamic>;
        final fileIndex = item['fileIndex'] as int;

        setState(() {
          _currentUploadingFileIndex = fileIndex;
          _uploadStatus = 'Uploading file ${fileIndex + 1} of ${_selectedFiles.length}: ${file.name}';
        });

        print('📤 Upload: File ${fileIndex + 1}/${_selectedFiles.length}: ${file.name}');
        
        final uploadMethod = uploadData['upload_method'] ?? 'direct';
        final filePath = uploadData['file_path'] as String;

        if (uploadMethod == 'chunked') {
          await _uploadChunkedFileToS3(file, filePath, fileIndex);
        } else {
          await _uploadDirectToS3ForFile(file, uploadData, fileIndex);
        }

        // Add file path to uploaded URLs list
        setState(() {
          _uploadedFileUrls.add(filePath);
          _uploadProgress = (fileIndex + 1) / _selectedFiles.length;
        });

        print('✅ Upload: File ${fileIndex + 1} uploaded: $filePath');
      }

      setState(() {
        _isUploadComplete = true;
        _uploadStatus = 'All files uploaded successfully!';
        _uploadProgress = 1.0;
      });

      print('✅ Upload: All ${_selectedFiles.length} file(s) uploaded successfully!');
      showToast(
        title: 'Success',
        description: '${_selectedFiles.length} file(s) uploaded successfully!',
        style: ToastNotificationStyleType.success,
      );
    } catch (e) {
      print('❌ Upload: Upload failed: $e');
      setState(() {
        _isUploading = false;
        _uploadStatus = 'Upload failed';
      });

      String errorMessage = 'Failed to upload files';
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

  // This method is now deprecated - presigned URLs are fetched in _uploadFile()
  // Keeping for backward compatibility if needed

  Future<void> _uploadDirectToS3ForFile(PlatformFile file, Map<String, dynamic> uploadData, int fileIndex) async {
    final uploadUrl = uploadData['upload_url'].toString();
    final fileObj = File(file.path!);
    final contentType = uploadData['content_type'] ?? _getContentType(file);

    setState(() {
      _uploadStatus = 'Uploading file ${fileIndex + 1} to cloud storage...';
    });

    final bytes = await fileObj.readAsBytes();
    
    // Update progress during upload
    final baseProgress = fileIndex / _selectedFiles.length;
    setState(() {
      _uploadProgress = baseProgress + 0.3 / _selectedFiles.length; // 30% of this file's progress
    });

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
      _uploadProgress = baseProgress + 0.9 / _selectedFiles.length; // 90% of this file's progress
    });

    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('S3 upload failed with status ${response.statusCode}');
    }

    setState(() {
      _uploadProgress = baseProgress + 1.0 / _selectedFiles.length; // 100% of this file's progress
    });
  }

  Future<void> _uploadChunkedFileToS3(PlatformFile file, String filePath, int fileIndex) async {
    const chunkSize = 5 * 1024 * 1024; // 5MB chunks
    final totalChunks = (file.size / chunkSize).ceil();

    final chunkedResponse = await api<PostApiService>(
      (request) => request.getChunkedUploadUrl(
        filename: file.name,
        contentType: _getContentType(file),
        totalSize: file.size,
        chunkSize: chunkSize,
      ),
    );

    if (chunkedResponse == null || chunkedResponse['success'] != true) {
      throw Exception('Failed to get chunked upload URLs');
    }

    final chunkData = chunkedResponse['data'];
    final chunkUrls = chunkData['chunk_urls'] as List;
    final fileObj = File(file.path!);
    final baseProgress = fileIndex / _selectedFiles.length;

    for (int i = 0; i < totalChunks; i++) {
      final chunkStart = i * chunkSize;
      final chunkEnd = (i + 1) * chunkSize > file.size
          ? file.size
          : (i + 1) * chunkSize;

      final chunk = fileObj.readAsBytesSync().sublist(chunkStart, chunkEnd);
      final chunkUrl = chunkUrls[i]['upload_url'];

      setState(() {
        _uploadStatus = 'Uploading file ${fileIndex + 1}, chunk ${i + 1} of $totalChunks...';
        _uploadProgress = baseProgress + ((i + 1) / totalChunks) / _selectedFiles.length;
      });

      final request = http.Request('PUT', Uri.parse(chunkUrl));
      request.headers['Content-Type'] = _getContentType(file);
      request.bodyBytes = chunk;

      final response = await request.send();
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to upload chunk ${i + 1}');
      }
    }

    final completeResponse = await api<PostApiService>(
      (request) => request.completeChunkedUpload(
        filePath: filePath,
        totalChunks: totalChunks,
      ),
    );

    if (completeResponse == null || completeResponse['success'] != true) {
      throw Exception('Failed to complete chunked upload');
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

        await _uploadChunkedFile(filePath);
      } else {

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

        final bytes = await file.readAsBytes();

        setState(() {
          _uploadStatus = 'Uploading file...';
          _uploadProgress = 0.3;
        });

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

    if (!_isUploadComplete || _uploadedFileUrls.isEmpty) {
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
      print('📝 Upload: File paths: $_uploadedFileUrls');
      print('📝 Upload: Number of files: ${_uploadedFileUrls.length}');
      print(
          '📝 Upload: Category: ${_selectedCategory!.name} (ID: ${_selectedCategory!.id})');
      print('📝 Upload: Caption: ${_captionController.text.trim()}');
      print('📝 Upload: Tags: $tags');
      print('📝 Upload: Location: ${_locationController.text.trim()}');

      print('🔵 REQUEST: createPostFromS3()');
      if (_uploadedFileUrls.length == 1) {
        // Single file - use filePath for backward compatibility
        print('  - filePath: ${_uploadedFileUrls.first}');
      } else {
        // Multiple files - use filePaths
        print('  - filePaths: $_uploadedFileUrls');
      }
      print('  - caption: ${_captionController.text.trim()}');
      print(
          '  - categoryId: ${_selectedCategory!.id} (${_selectedCategory!.name})');
      print('  - tags: ${tags.isNotEmpty ? tags : 'None'}');
      print(
          '  - location: ${_locationController.text.trim().isNotEmpty ? _locationController.text.trim() : 'Not provided'}');

      // Call createPostFromS3 with appropriate parameters
      Map<String, dynamic>? response;
      
      if (_uploadedFileUrls.length == 1) {
        // Single file - use filePath
        response = await api<PostApiService>(
          (request) => request.createPostFromS3(
            filePath: _uploadedFileUrls.first,
            caption: _captionController.text.trim(),
            categoryId: _selectedCategory!.id!,
            tags: tags.isNotEmpty ? tags : null,
            location: _locationController.text.trim().isNotEmpty
                ? _locationController.text.trim()
                : null,
            taggedUsers: _taggedUsers.map((user) => user['id'] as int).toList(),
          ),
        );
      } else {
        // Multiple files - call directly on service instance
        final service = PostApiService(buildContext: context);
        // Call with filePaths parameter
        // ignore: no_named_parameter
        response = await service.createPostFromS3(
          filePaths: _uploadedFileUrls,
          caption: _captionController.text.trim(),
          categoryId: _selectedCategory!.id!,
          tags: tags.isNotEmpty ? tags : null,
          location: _locationController.text.trim().isNotEmpty
              ? _locationController.text.trim()
              : null,
          taggedUsers: _taggedUsers.map((user) => user['id'] as int).toList(),
        );
      }

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

        await Future.delayed(const Duration(milliseconds: 500));

        if (!mounted) return;

        routeTo(
          BaseNavigationHub.path,
          navigationType: NavigationType.pushAndForgetAll,
          tabIndex: 0,
        );
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

      if (mounted) {
        showToast(
          title: 'Error',
          description: errorMessage,
          style: ToastNotificationStyleType.danger,
        );
      }
    } finally {

      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _uploadStatus = '';
        });
      }
    }
  }

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
