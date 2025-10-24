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

  // Static method to pause all videos globally
  static void pauseAllVideos() {
    _SmartMediaWidgetState.pauseAllVideos();
  }
}

class _SmartMediaWidgetState extends State<SmartMediaWidget> {
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  bool _isVideoPlaying = false;
  bool _isVisible = false;
  bool _hasError = false;

  // Static list to track all video controllers globally
  static final Set<VideoPlayerController> _allVideoControllers =
      <VideoPlayerController>{};

  @override
  void initState() {
    super.initState();
    _initializeVideoIfNeeded();
  }

  @override
  void dispose() {
    if (_videoController != null) {
      _videoController!.pause();
      _unregisterVideoController(_videoController!);
      _videoController!.dispose();
    }
    super.dispose();
  }

  // Static method to pause all videos globally
  static void pauseAllVideos() {
    print(
        '🎥 SmartMediaWidget: Pausing all videos globally (${_allVideoControllers.length} controllers)');
    for (var controller in _allVideoControllers) {
      if (controller != null && controller.value.isInitialized) {
        print(
            '🎥 SmartMediaWidget: Pausing controller: ${controller.hashCode}');
        controller.pause();
      }
    }
  }

  // Register video controller
  void _registerVideoController(VideoPlayerController controller) {
    _allVideoControllers.add(controller);
    print(
        '🎥 SmartMediaWidget: Registered controller: ${controller.hashCode} (total: ${_allVideoControllers.length})');
  }

  // Unregister video controller
  void _unregisterVideoController(VideoPlayerController controller) {
    _allVideoControllers.remove(controller);
    print(
        '🎥 SmartMediaWidget: Unregistered controller: ${controller.hashCode} (total: ${_allVideoControllers.length})');
  }

  void _initializeVideoIfNeeded() {
    if (_isVideo() && !_isVideoInitialized) {
      _videoController = VideoPlayerController.networkUrl(
        Uri.parse(widget.post.mediaUrl!),
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: true,
          allowBackgroundPlayback: false,
        ),
      );

      _videoController!.setLooping(true);

      // Register the video controller globally
      _registerVideoController(_videoController!);

      _videoController!.initialize().then((_) {
        if (mounted) {
          setState(() {
            _isVideoInitialized = true;
          });
        }
      }).catchError((error) {
        print('Video initialization error: $error');
        if (mounted) {
          setState(() {
            _hasError = true;
          });
        }
      });
    }
  }

  bool _isVideo() {
    final mediaType = widget.post.mediaType?.toLowerCase();
    final mediaUrl = widget.post.mediaUrl?.toLowerCase();

    return mediaType == 'video' ||
        mediaUrl?.contains('.mp4') == true ||
        mediaUrl?.contains('.mov') == true ||
        mediaUrl?.contains('.avi') == true ||
        mediaUrl?.contains('.webm') == true;
  }

  void _onVisibilityChanged(VisibilityInfo info) {
    final isVisible = info.visibleFraction > 0.5;

    if (isVisible != _isVisible) {
      if (mounted) {
        setState(() {
          _isVisible = isVisible;
        });
      }

      if (_isVideo() && _isVideoInitialized) {
        if (isVisible) {
          _playVideo();
        } else {
          _pauseVideo();
        }
      }
    }
  }

  void pauseVideo() {
    if (_isVideo() && _isVideoInitialized && _videoController != null) {
      print('🎥 SmartMediaWidget: Force pausing video');
      _videoController!.pause();
      if (mounted) {
        setState(() {
          _isVideoPlaying = false;
        });
      }
    }
  }

  // Method to force pause video (public method)
  void forcePauseVideo() {
    print('🎥 SmartMediaWidget: forcePauseVideo called');
    pauseVideo();
  }

  void _playVideo() {
    if (_videoController != null && !_isVideoPlaying) {
      _videoController!.play();
      if (mounted) {
        setState(() {
          _isVideoPlaying = true;
        });
      }
    }
  }

  void _pauseVideo() {
    if (_videoController != null && _isVideoPlaying) {
      _videoController!.pause();
      setState(() {
        _isVideoPlaying = false;
      });
    }
  }

  void _toggleVideoPlayback() {
    if (_isVideoPlaying) {
      _pauseVideo();
    } else {
      _playVideo();
    }
  }

  void _onVideoTap() {
    print('🎥 SmartMediaWidget: Video tapped, isPlaying: $_isVideoPlaying');

    // Always just toggle playback when video is tapped
    // The expand functionality should be handled by a separate expand button
    print('🎥 SmartMediaWidget: Toggling video playback');
    _toggleVideoPlayback();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.post.mediaUrl == null) {
      return _buildErrorWidget('No media available');
    }

    return VisibilityDetector(
      key: Key('media_${widget.post.id}'),
      onVisibilityChanged: _onVisibilityChanged,
      child: _isVideo() ? _buildVideoWidget() : _buildImageWidget(),
    );
  }

  Widget _buildVideoWidget() {
    if (_hasError) {
      return _buildErrorWidget('Failed to load video');
    }

    if (!_isVideoInitialized) {
      return _buildVideoThumbnail();
    }

    return GestureDetector(
      onTap: _onVideoTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Video player with consistent height
          Container(
            height: widget.height ?? 400,
            width: widget.width ?? double.infinity,
            color: Colors.black,
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _videoController!.value.size.width,
                height: _videoController!.value.size.height,
                child: VideoPlayer(_videoController!),
              ),
            ),
          ),

          // Play/pause overlay
          if (!_isVideoPlaying)
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

          // Video duration indicator
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
                _formatDuration(_videoController!.value.duration),
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

  Widget _buildVideoThumbnail() {
    if (widget.post.thumbnailUrl != null) {
      return Container(
        height: widget.height ?? 400,
        width: widget.width ?? double.infinity,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CachedNetworkImage(
              imageUrl: widget.post.thumbnailUrl!,
              fit: BoxFit.cover,
              height: widget.height ?? 400,
              width: widget.width ?? double.infinity,
              placeholder: (context, url) => _buildLoadingWidget(),
              errorWidget: (context, url, error) =>
                  _buildErrorWidget('Failed to load thumbnail'),
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

  Widget _buildImageWidget() {
    return GestureDetector(
      onTap: widget.onExpand,
      child: Container(
        height: widget.height ?? 400,
        width: widget.width ?? double.infinity,
        child: CachedNetworkImage(
          imageUrl: widget.post.mediaUrl!,
          fit: BoxFit.cover,
          height: widget.height ?? 400,
          width: widget.width ?? double.infinity,
          placeholder: (context, url) => _buildLoadingWidget(),
          errorWidget: (context, url, error) =>
              _buildErrorWidget('Failed to load image'),
          // High quality disk cache settings (Instagram uses 1080p)
          maxHeightDiskCache: 1920,
          maxWidthDiskCache: 1080,
          // Remove memory cache limits for best quality
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
