import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '/app/models/post.dart';

class SmartMediaWidget extends StatefulWidget {
  final Post post;
  final double? height;
  final double? width;
  final BoxFit fit;
  final VoidCallback? onExpand; // Callback when media is tapped to expand

  const SmartMediaWidget({
    super.key,
    required this.post,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
    this.onExpand,
  });

  @override
  State<SmartMediaWidget> createState() => _SmartMediaWidgetState();

  static void pauseAllVideos() {
    _SmartMediaWidgetState.pauseAllVideos();
  }
}

class _SmartMediaWidgetState extends State<SmartMediaWidget> {
  final Map<int, VideoPlayerController?> _videoControllers = {};
  final Map<int, bool> _videoInitialized = {};
  final Map<int, bool> _videoPlaying = {};
  final Map<int, bool> _hasError = {};
  int _currentPage = 0;
  bool _isVisible = false;

  static final Set<VideoPlayerController> _allVideoControllers =
      <VideoPlayerController>{};

  List<String> get _mediaUrls => widget.post.getMediaUrls();

  @override
  void initState() {
    super.initState();
    _initializeAllVideos();
  }

  @override
  void didUpdateWidget(SmartMediaWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.post.id != widget.post.id) {
      _disposeAllVideos();
      _initializeAllVideos();
    }
  }

  @override
  void dispose() {
    _disposeAllVideos();
    super.dispose();
  }

  void _disposeAllVideos() {
    _videoControllers.forEach((index, controller) {
      if (controller != null) {
        controller.pause();
        _unregisterVideoController(controller);
        controller.dispose();
      }
    });
    _videoControllers.clear();
    _videoInitialized.clear();
    _videoPlaying.clear();
    _hasError.clear();
  }

  static void pauseAllVideos() {
    print(
        '🎥 SmartMediaWidget: Pausing all videos globally (${_allVideoControllers.length} controllers)');
    for (var controller in _allVideoControllers) {
      if (controller.value.isInitialized) {
        print(
            '🎥 SmartMediaWidget: Pausing controller: ${controller.hashCode}');
        controller.pause();
      }
    }
  }

  void _registerVideoController(VideoPlayerController controller) {
    _allVideoControllers.add(controller);
    print(
        '🎥 SmartMediaWidget: Registered controller: ${controller.hashCode} (total: ${_allVideoControllers.length})');
  }

  void _unregisterVideoController(VideoPlayerController controller) {
    _allVideoControllers.remove(controller);
    print(
        '🎥 SmartMediaWidget: Unregistered controller: ${controller.hashCode} (total: ${_allVideoControllers.length})');
  }

  void _initializeAllVideos() {
    for (int i = 0; i < _mediaUrls.length; i++) {
      if (_isVideoUrl(_mediaUrls[i])) {
        _videoInitialized[i] = false;
        _videoPlaying[i] = false;
        _hasError[i] = false;
        _initializeVideo(i, _mediaUrls[i]);
      }
    }
  }

  void _initializeVideo(int index, String url) {
    if (_videoControllers[index] != null) return;

    final controller = VideoPlayerController.networkUrl(
      Uri.parse(url),
      videoPlayerOptions: VideoPlayerOptions(
        mixWithOthers: true,
        allowBackgroundPlayback: false,
      ),
    );

    controller.setLooping(true);
    _videoControllers[index] = controller;
    _registerVideoController(controller);

    controller.initialize().then((_) {
      if (mounted) {
        setState(() {
          _videoInitialized[index] = true;
        });
        // Auto-play if visible and is current page
        if (_isVisible && _currentPage == index) {
          _playVideo(index);
        }
      }
    }).catchError((error) {
      print('Video initialization error for index $index: $error');
      if (mounted) {
        setState(() {
          _hasError[index] = true;
        });
      }
    });
  }

  bool _isVideoUrl(String url) {
    final lowerUrl = url.toLowerCase();
    final mediaType = widget.post.mediaType?.toLowerCase();
    
    return mediaType == 'video' ||
        mediaType == 'mixed' ||
        lowerUrl.contains('.mp4') ||
        lowerUrl.contains('.mov') ||
        lowerUrl.contains('.avi') ||
        lowerUrl.contains('.webm') ||
        lowerUrl.contains('.mkv');
  }

  bool _isVideo(int index) {
    if (index >= _mediaUrls.length) return false;
    return _isVideoUrl(_mediaUrls[index]);
  }

  void _onVisibilityChanged(VisibilityInfo info) {
    final isVisible = info.visibleFraction > 0.5;

    if (isVisible != _isVisible) {
      if (mounted) {
        setState(() {
          _isVisible = isVisible;
        });
      }

      // Pause all videos first
      for (int i = 0; i < _mediaUrls.length; i++) {
        if (_isVideo(i)) {
          _pauseVideo(i);
        }
      }

      // Play video on current page if visible
      if (isVisible && _isVideo(_currentPage)) {
        _playVideo(_currentPage);
      }
    }
  }

  void _playVideo(int index) {
    final controller = _videoControllers[index];
    if (controller != null && !_videoPlaying[index]! && _videoInitialized[index]!) {
      controller.play();
      if (mounted) {
        setState(() {
          _videoPlaying[index] = true;
        });
      }
    }
  }

  void _pauseVideo(int index) {
    final controller = _videoControllers[index];
    if (controller != null && _videoPlaying[index] == true) {
      controller.pause();
      if (mounted) {
        setState(() {
          _videoPlaying[index] = false;
        });
      }
    }
  }

  void _toggleVideoPlayback(int index) {
    if (_videoPlaying[index] == true) {
      _pauseVideo(index);
    } else {
      _playVideo(index);
    }
  }

  void _onPageChanged(int page) {
    // Pause current video
    if (_isVideo(_currentPage)) {
      _pauseVideo(_currentPage);
    }

    setState(() {
      _currentPage = page;
    });

    // Play new page video if visible
    if (_isVisible && _isVideo(page)) {
      _playVideo(page);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaUrls = _mediaUrls;
    
    if (mediaUrls.isEmpty) {
      return _buildErrorWidget('No media available');
    }

    // Single media - use existing behavior for backward compatibility
    if (mediaUrls.length == 1) {
      return VisibilityDetector(
        key: Key('media_${widget.post.id}_0'),
        onVisibilityChanged: _onVisibilityChanged,
        child: _isVideo(0)
            ? _buildVideoWidget(0, mediaUrls[0])
            : _buildImageWidget(0, mediaUrls[0]),
      );
    }

    // Multiple media - use carousel
    return VisibilityDetector(
      key: Key('media_${widget.post.id}'),
      onVisibilityChanged: _onVisibilityChanged,
      child: Column(
        children: [
          Expanded(
            child: PageView.builder(
              itemCount: mediaUrls.length,
              onPageChanged: _onPageChanged,
              controller: PageController(),
              itemBuilder: (context, index) {
                return _isVideo(index)
                    ? _buildVideoWidget(index, mediaUrls[index])
                    : _buildImageWidget(index, mediaUrls[index]);
              },
            ),
          ),
          // Page indicator dots
          if (mediaUrls.length > 1)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  mediaUrls.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentPage == index
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

  Widget _buildVideoWidget(int index, String url) {
    if (_hasError[index] == true) {
      return _buildErrorWidget('Failed to load video');
    }

    final controller = _videoControllers[index];
    final isInitialized = _videoInitialized[index] == true;
    final isPlaying = _videoPlaying[index] == true;

    if (!isInitialized || controller == null) {
      return _buildVideoThumbnail(index, url);
    }

    return GestureDetector(
      onTap: () => _toggleVideoPlayback(index),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            height: widget.height ?? 400,
            width: widget.width ?? double.infinity,
            color: Colors.black,
            child: FittedBox(
              fit: widget.fit,
              child: SizedBox(
                width: controller.value.size.width,
                height: controller.value.size.height,
                child: VideoPlayer(controller),
              ),
            ),
          ),
          if (!isPlaying)
            Container(
              height: widget.height ?? 400,
              width: widget.width ?? double.infinity,
              color: Colors.black26,
              child: Center(
                child: Icon(
                  Icons.play_arrow,
                  size: 64,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ),
          Positioned(
            bottom: 12,
            right: 12,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _formatDuration(controller.value.duration),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoThumbnail(int index, String url) {
    // Try to get thumbnail from metadata or use first video thumbnail
    final thumbnailUrl = widget.post.thumbnailUrl;
    
    if (thumbnailUrl != null && index == 0) {
      return Container(
        height: widget.height ?? 400,
        width: widget.width ?? double.infinity,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CachedNetworkImage(
              imageUrl: thumbnailUrl,
              fit: widget.fit,
              height: widget.height ?? 400,
              width: widget.width ?? double.infinity,
              placeholder: (context, url) => _buildLoadingWidget(),
              errorWidget: (context, url, error) => _buildLoadingWidget(),
              maxHeightDiskCache: 1920,
              maxWidthDiskCache: 1080,
            ),
            Container(
              color: Colors.black26,
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 3,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return _buildLoadingWidget();
  }

  Widget _buildImageWidget(int index, String url) {
    return GestureDetector(
      onTap: widget.onExpand,
      child: Container(
        height: widget.height ?? 400,
        width: widget.width ?? double.infinity,
        child: CachedNetworkImage(
          imageUrl: url,
          fit: widget.fit,
          height: widget.height ?? 400,
          width: widget.width ?? double.infinity,
          placeholder: (context, url) => _buildLoadingWidget(),
          errorWidget: (context, url, error) =>
              _buildErrorWidget('Failed to load image'),
          maxHeightDiskCache: 1920,
          maxWidthDiskCache: 1080,
          filterQuality: FilterQuality.high,
        ),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Container(
      height: widget.height ?? 400,
      width: widget.width ?? double.infinity,
      color: Colors.grey[100],
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF69B4)),
          strokeWidth: 2.5,
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
    return Container(
      height: widget.height ?? 400,
      width: widget.width ?? double.infinity,
      color: Colors.grey[100],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.grey[400],
            ),
            SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }
}