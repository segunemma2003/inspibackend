import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:nylo_framework/nylo_framework.dart';
import 'package:file_picker/file_picker.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:video_player/video_player.dart';
import '../../app/controllers/create_post_controller.dart';
import '../../app/networking/post_api_service.dart';
import '../widgets/user_search_widget.dart';

class CreatePostPage extends NyStatefulWidget {
  static const path = '/create-post';

  CreatePostPage({super.key}) : super(child: () => _CreatePostPageState());
}

class _CreatePostPageState extends NyPage<CreatePostPage> {
  final _formKey = GlobalKey<FormState>();
  final _captionController = TextEditingController();
  final _tagController = TextEditingController();
  final _controller = CreatePostController();
  final List<String> _tags = [];
  List<Map<String, dynamic>> _taggedUsers = [];
  File? _mediaFile;
  bool _isLoading = false;
  bool _isVideo = false;
  VideoPlayerController? _videoController;
  Uint8List? _videoThumbnail;

  @override
  void dispose() {
    _captionController.dispose();
    _tagController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _pickMedia() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.media,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final filePath = result.files.single.path!;
        final file = File(filePath);
        final isVideo = _isVideoFile(filePath);

        await _videoController?.dispose();

        if (isVideo) {
          final thumbnail = await VideoThumbnail.thumbnailData(
            video: filePath,
            imageFormat: ImageFormat.JPEG,
            quality: 50,
          );

          _videoController = VideoPlayerController.file(file);
          await _videoController?.initialize();

          setState(() {
            _mediaFile = file;
            _isVideo = true;
            _videoThumbnail = thumbnail;
          });
        } else {
          setState(() {
            _mediaFile = file;
            _isVideo = false;
            _videoThumbnail = null;
          });
        }
      }
    } catch (e) {
      print('Error picking media: $e');
      showToast(title: 'Error', description: 'Failed to pick media file');
    }
  }

  bool _isVideoFile(String path) {
    final ext = path.split('.').last.toLowerCase();
    return ['mp4', 'mov', 'avi', 'mkv', 'webm'].contains(ext);
  }

  String _getMimeType(String path) {
    final ext = path.split('.').last.toLowerCase();
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'mp4':
        return 'video/mp4';
      case 'mov':
        return 'video/quicktime';
      case 'avi':
        return 'video/x-msvideo';
      case 'mkv':
        return 'video/x-matroska';
      default:
        return 'application/octet-stream';
    }
  }

  void _addTag() {
    if (_tagController.text.trim().isNotEmpty) {
      setState(() {
        _tags.add(_tagController.text.trim());
        _tagController.clear();
      });
    }
  }

  void _handleCaptionChange(String text) {
    setState(() {});
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  Future<void> _submitPost() async {
    if (!_formKey.currentState!.validate() || _mediaFile == null) return;

    setState(() => _isLoading = true);

    try {
      final filename = _mediaFile!.path.split('/').last;
      final contentType = _getMimeType(_mediaFile!.path);
      final fileSize = await _mediaFile!.length();

      print('📱 CreatePost: Presigned URL Request Data:');
      print('📱 CreatePost: - filename: "$filename"');
      print('📱 CreatePost: - contentType: "$contentType"');
      print(
          '📱 CreatePost: - fileSize: $fileSize bytes (${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB)');
      print('📱 CreatePost: - filePath: "${_mediaFile!.path}"');

      final uploadUrlResponse = await PostApiService().getUploadUrl(
        filename: filename,
        contentType: contentType,
        fileSize: fileSize,
      );

      if (uploadUrlResponse == null) {
        print(
            '❌ CreatePost: Failed to get upload URL - Response: $uploadUrlResponse');
        throw Exception('Failed to get upload URL');
      }

      print('📱 CreatePost: Presigned URL API Response:');
      print('📱 CreatePost: - Response: $uploadUrlResponse');

      final uploadResponse = await _controller.uploadToS3(
        file: _mediaFile!,
        uploadUrl: uploadUrlResponse['upload_url'],
        fields: Map<String, String>.from(uploadUrlResponse['fields']),
      );

      if (!uploadResponse) {
        throw Exception('Failed to upload file');
      }

      final post = await PostApiService().createPost(
        caption: _captionController.text,
        media: uploadUrlResponse['file_url'],
        categoryId: 1, // Replace with actual category selection
        tags: _tags,
        taggedUsers: _taggedUsers.map((user) => user['id'] as int).toList(),
      );

      if (post != null) {
        Navigator.pop(context, true); // Return success
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text('Failed to create post: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildPlaceholder() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.add_photo_alternate, size: 50, color: Colors.grey),
          SizedBox(height: 8),
          Text('Tap to add photo/video'),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    return Image.file(
      _mediaFile!,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
    );
  }

  Widget _buildVideoPreview() {
    return Stack(
      fit: StackFit.expand,
      children: [
        _videoThumbnail != null
            ? Positioned.fill(
                child: Image.memory(
                  _videoThumbnail!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              )
            : Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.black26,
              ),
        const Center(
          child: Icon(
            Icons.play_circle_fill,
            size: 60,
            color: Colors.white70,
          ),
        ),
        if (_videoController != null)
          Positioned(
            bottom: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _formatDuration(_videoController!.value.duration),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget view(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Post'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _submitPost,
            child: const Text('Post'),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    GestureDetector(
                      onTap: _pickMedia,
                      child: Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: _mediaFile == null
                            ? _buildPlaceholder()
                            : _isVideo
                                ? _buildVideoPreview()
                                : _buildImagePreview(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _captionController,
                      decoration: const InputDecoration(
                        labelText: 'Write a caption...',
                        hintText: 'You can mention users with @username',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      onChanged: _handleCaptionChange,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a caption';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _tagController,
                      decoration: InputDecoration(
                        labelText: 'Add tags',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: _addTag,
                        ),
                      ),
                      onFieldSubmitted: (_) => _addTag(),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: _tags
                          .map((tag) => Chip(
                                label: Text(tag),
                                onDeleted: () => _removeTag(tag),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Tag People',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
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
                  ],
                ),
              ),
            ),
    );
  }
}
