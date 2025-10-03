import 'dart:io';
import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
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

  // Form controllers
  final TextEditingController _captionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();

  // Form data
  List<Category> _categories = [];
  Category? _selectedCategory;
  bool _isSubmitting = false;

  @override
  get init => () async {
        await _loadCategories();
      };

  @override
  void dispose() {
    _captionController.dispose();
    _locationController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final response = await api<CategoryApiService>(
        (request) => request.getCategories(),
      );

      if (response != null && response['success'] == true) {
        final List<dynamic> categoriesData = response['data'] ?? [];
        setState(() {
          _categories =
              categoriesData.map((json) => Category.fromJson(json)).toList();
        });
      }
    } catch (e) {
      print('Error loading categories: $e');
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

          // Upload progress or form
          if (_isUploading)
            _buildUploadProgress()
          else if (_isUploadComplete)
            _buildPostForm()
          else
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
                _captionController.clear();
                _locationController.clear();
                _tagsController.clear();
                _selectedCategory = null;
              });
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
          const SizedBox(width: 48), // Balance the back button
        ],
      ),
    );
  }

  Widget _buildFilePreview() {
    if (_selectedFile == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(16),
      height: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[100],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: _isImageFile(_selectedFile!)
            ? Image.file(
                File(_selectedFile!.path!),
                fit: BoxFit.cover,
                width: double.infinity,
              )
            : _buildVideoPreview(),
      ),
    );
  }

  Widget _buildVideoPreview() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.play_circle_filled,
            color: Colors.white,
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            _selectedFile!.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            _formatFileSize(_selectedFile!.size),
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
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
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Uploading...',
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
          ),
          const SizedBox(height: 8),
          Text(
            '${(_uploadProgress * 100).toInt()}%',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadButton() {
    return Container(
      margin: const EdgeInsets.all(16),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _uploadToS3,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF69B4),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Upload File',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
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
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
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
            label: 'Caption',
            hint: 'Write a caption for your post...',
            maxLines: 4,
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
            label: 'Location (Optional)',
            hint: 'Add location...',
          ),
          const SizedBox(height: 24),

          // Submit button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitPost,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _isSubmitting ? Colors.grey[400] : const Color(0xFFFF69B4),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
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
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
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
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[500]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFFF69B4)),
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
              borderSide: const BorderSide(color: Color(0xFFFF69B4)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
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
                  color: const Color(0xFFFF69B4).withOpacity(0.3),
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
      'Supports images and videos up to 50MB',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 12,
        color: Colors.grey[500],
        fontFamily: 'Roboto',
      ),
    );
  }

  // File picker method
  void _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.media,
        allowMultiple: false,
        allowedExtensions: null,
      );

      if (result != null && result.files.single.path != null) {
        final file = result.files.single;

        // Check file size (50MB limit)
        if (file.size > 50 * 1024 * 1024) {
          showToast(
              title: 'File Too Large',
              description: 'Please select a file smaller than 50MB');
          return;
        }

        setState(() {
          _selectedFile = file;
        });
      }
    } catch (e) {
      print('Error picking file: $e');
      showToast(title: 'Error', description: 'Failed to pick file');
    }
  }

  // S3 upload method
  Future<void> _uploadToS3() async {
    if (_selectedFile == null) return;

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    try {
      // Get presigned URL
      final uploadUrlResponse = await api<PostApiService>(
        (request) => request.getUploadUrl(
          filename: _selectedFile!.name,
          contentType: _getContentType(_selectedFile!),
          fileSize: _selectedFile!.size,
        ),
      );

      if (uploadUrlResponse == null || uploadUrlResponse['success'] != true) {
        throw Exception('Failed to get upload URL');
      }

      final uploadUrl = uploadUrlResponse['data']['upload_url'];
      final fileUrl = uploadUrlResponse['data']['file_url'];

      // Upload to S3
      final file = File(_selectedFile!.path!);
      final request = http.StreamedRequest('PUT', Uri.parse(uploadUrl));
      request.headers['Content-Type'] = _getContentType(_selectedFile!);
      request.contentLength = _selectedFile!.size;

      final stream = file.openRead();
      int uploaded = 0;

      stream.listen(
        (chunk) {
          uploaded += chunk.length;
          setState(() {
            _uploadProgress = uploaded / _selectedFile!.size;
          });
          request.sink.add(chunk);
        },
        onDone: () => request.sink.close(),
        onError: (error) => request.sink.addError(error),
      );

      final response = await request.send();

      if (response.statusCode == 200) {
        setState(() {
          _isUploading = false;
          _isUploadComplete = true;
          _uploadedFileUrl = fileUrl;
        });
        showToast(title: 'Success', description: 'File uploaded successfully!');
      } else {
        throw Exception('Upload failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Upload error: $e');
      setState(() {
        _isUploading = false;
      });
      showToast(title: 'Upload Failed', description: 'Please try again');
    }
  }

  // Submit post method
  Future<void> _submitPost() async {
    if (_uploadedFileUrl == null || _selectedCategory == null) {
      showToast(title: 'Error', description: 'Please select a category');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final tags = _tagsController.text
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList();

      final response = await api<PostApiService>(
        (request) => request.createPostFromS3(
          filePath: _uploadedFileUrl!,
          title: _captionController.text.trim().isNotEmpty
              ? _captionController.text.trim()
              : null,
          description: _captionController.text.trim().isNotEmpty
              ? _captionController.text.trim()
              : null,
          categoryId: _selectedCategory!.id!,
          tags: tags.isNotEmpty ? tags : null,
          location: _locationController.text.trim().isNotEmpty
              ? _locationController.text.trim()
              : null,
        ),
      );

      if (response != null && response['success'] == true) {
        showToast(title: 'Success', description: 'Post created successfully!');
        routeTo('/base'); // Navigate back to feed
      } else {
        throw Exception('Failed to create post');
      }
    } catch (e) {
      print('Submit error: $e');
      showToast(title: 'Error', description: 'Failed to create post');
    } finally {
      setState(() => _isSubmitting = false);
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
