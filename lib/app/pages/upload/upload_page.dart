import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nylo_framework/nylo_framework.dart';
import '../../models/category.dart';
import '../../networking/post_api_service.dart';
import '../../providers/app_provider.dart';
import '../../services/location_service.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({Key? key}) : super(key: key);

  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends NyState<UploadPage> {
  final AppProvider _appProvider = AppProvider();
  final _formKey = GlobalKey<FormState>();
  final _captionController = TextEditingController();
  final _locationController = TextEditingController();
  final _tagController = TextEditingController();
  final PostApiService _postApiService = PostApiService();

  File? _mediaFile;
  List<String> _tags = [];
  Category? _selectedCategory;
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  Map<String, dynamic>? _currentPosition;
  bool _useCurrentLocation = true;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await LocationService().getCurrentLocation();
      setState(() {
        _currentPosition = position;
        if (_useCurrentLocation) {
          _updateLocationText();
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not get location: ${e.toString()}')),
      );
    }
  }

  void _updateLocationText() {
    if (_currentPosition != null) {
      final lat = _currentPosition!['latitude'] as double?;
      final lng = _currentPosition!['longitude'] as double?;
      if (lat != null && lng != null) {
        _locationController.text =
            '${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}';
      }
    }
  }

  Future<void> _pickMedia() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickMedia();

    if (pickedFile != null) {
      setState(() {
        _mediaFile = File(pickedFile.path);
      });
    }
  }

  void _addTag() {
    final tag = _tagController.text.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  Future<void> _submitPost() async {
    if (!_formKey.currentState!.validate() || _mediaFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    try {
      final result = await _postApiService.uploadWithPresignedUrl(
        file: _mediaFile!,
        onProgress: (progress) {
          setState(() {
            _uploadProgress = progress;
          });
        },
        caption: _captionController.text,
        categoryId:
            _selectedCategory?.id ?? 1, // Default category if none selected
        tags: _tags,
        location: _useCurrentLocation ? _locationController.text : null,
        mediaMetadata: {
          'width': 1080, // You can extract this from the actual file
          'height': 1920, // You can extract this from the actual file
        },
      );

      if (result?['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Post uploaded successfully!')),
          );
          Navigator.of(context).pop();
        }
      } else {
        throw Exception(result?['message'] ?? 'Failed to upload post');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_appProvider.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final theme = Theme.of(context);
    final categories = _appProvider.categories;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Post'),
        actions: [
          TextButton(
            onPressed: _isUploading ? null : _submitPost,
            child: _isUploading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      value: _uploadProgress > 0 ? _uploadProgress : null,
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(theme.primaryColor),
                    ),
                  )
                : const Text('Post', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
      body: _isUploading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    value: _uploadProgress > 0 ? _uploadProgress : null,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(theme.primaryColor),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Uploading... ${(_uploadProgress * 100).toStringAsFixed(1)}%',
                    style: theme.textTheme.titleMedium,
                  ),
                ],
              ),
            )
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
                          color: theme.cardColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: theme.dividerColor.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: _mediaFile == null
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_photo_alternate_outlined,
                                      size: 48, color: theme.hintColor),
                                  const SizedBox(height: 8),
                                  Text('Tap to add photo or video',
                                      style: theme.textTheme.bodyLarge
                                          ?.copyWith(color: theme.hintColor)),
                                ],
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  _mediaFile!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    TextFormField(
                      controller: _captionController,
                      maxLines: 3,
                      maxLength: 2000,
                      decoration: InputDecoration(
                        labelText: 'Caption',
                        hintText: 'What\'s on your mind?',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a caption';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    DropdownButtonFormField<Category>(
                      value: _selectedCategory,
                      decoration: InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: categories.map((category) {
                        return DropdownMenuItem<Category>(
                          value: category,
                          child: Row(
                            children: [
                              Text(category.icon ?? '📁'),
                              const SizedBox(width: 8),
                              Text(category.name ?? 'Unknown'),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (category) {
                        setState(() {
                          _selectedCategory = category;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a category';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: _tagController,
                          decoration: InputDecoration(
                            labelText: 'Tags',
                            hintText: 'Add a tag and press enter',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: _addTag,
                            ),
                          ),
                          onFieldSubmitted: (_) => _addTag(),
                        ),
                        if (_tags.isNotEmpty) ...{
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: _tags
                                .map((tag) => Chip(
                                      label: Text(tag),
                                      deleteIcon:
                                          const Icon(Icons.close, size: 16),
                                      onDeleted: () => _removeTag(tag),
                                    ))
                                .toList(),
                          ),
                        },
                      ],
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Checkbox(
                          value: _useCurrentLocation,
                          onChanged: (value) {
                            setState(() {
                              _useCurrentLocation = value ?? false;
                              if (_useCurrentLocation) {
                                _updateLocationText();
                              } else {
                                _locationController.clear();
                              }
                            });
                          },
                        ),
                        const Text('Use current location'),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.location_on),
                          onPressed: _getCurrentLocation,
                          tooltip: 'Refresh location',
                        ),
                      ],
                    ),

                    TextFormField(
                      controller: _locationController,
                      enabled: !_useCurrentLocation,
                      decoration: InputDecoration(
                        labelText: 'Location',
                        hintText: 'Enter a location',
                        prefixIcon: const Icon(Icons.location_on_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    ElevatedButton(
                      onPressed: _submitPost,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Upload Post'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    _captionController.dispose();
    _locationController.dispose();
    _tagController.dispose();
    super.dispose();
  }
}
