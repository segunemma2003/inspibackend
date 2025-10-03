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

  const SmartMediaWidget({
    super.key,
    required this.post,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
  });

  @override
  State<SmartMediaWidget> createState() => _SmartMediaWidgetState();
}

class _SmartMediaWidgetState extends State<SmartMediaWidget> {
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;
  bool _isVideoPlaying = false;
  bool _isVisible = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeVideoIfNeeded();
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  void _initializeVideoIfNeeded() {
    if (_isVideo() && !_isVideoInitialized) {
      _videoController = VideoPlayerController.networkUrl(
        Uri.parse(widget.post.mediaUrl!),
      );

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
      setState(() {
        _isVisible = isVisible;
      });

      if (_isVideo() && _isVideoInitialized) {
        if (isVisible) {
          _playVideo();
        } else {
          _pauseVideo();
        }
      }
    }
  }

  void _playVideo() {
    if (_videoController != null && !_isVideoPlaying) {
      _videoController!.play();
      setState(() {
        _isVideoPlaying = true;
      });
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

  @override
  Widget build(BuildContext context) {
    if (widget.post.mediaUrl == null) {
      return _buildErrorWidget('No media available');
    }

    return VisibilityDetector(
      key: Key('media_${widget.post.id}'),
      onVisibilityChanged: _onVisibilityChanged,
      child: Container(
        height: widget.height,
        width: widget.width,
        child: _isVideo() ? _buildVideoWidget() : _buildImageWidget(),
      ),
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
      onTap: _toggleVideoPlayback,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Video player
          AspectRatio(
            aspectRatio: _videoController!.value.aspectRatio,
            child: VideoPlayer(_videoController!),
          ),

          // Play/pause overlay
          if (!_isVideoPlaying)
            Container(
              color: Colors.black26,
              child: Center(
                child: Icon(
                  Icons.play_arrow,
                  size: 60,
                  color: Colors.white,
                ),
              ),
            ),

          // Video duration indicator
          Positioned(
            bottom: 8,
            right: 8,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _formatDuration(_videoController!.value.duration),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoThumbnail() {
    // Show thumbnail while video is loading
    if (widget.post.thumbnailUrl != null) {
      return CachedNetworkImage(
        imageUrl: widget.post.thumbnailUrl!,
        fit: widget.fit,
        placeholder: (context, url) => _buildLoadingWidget(),
        errorWidget: (context, url, error) =>
            _buildErrorWidget('Failed to load thumbnail'),
      );
    }

    return _buildLoadingWidget();
  }

  Widget _buildImageWidget() {
    return CachedNetworkImage(
      imageUrl: widget.post.mediaUrl!,
      fit: widget.fit,
      placeholder: (context, url) => _buildLoadingWidget(),
      errorWidget: (context, url, error) =>
          _buildErrorWidget('Failed to load image'),
      memCacheWidth: 400, // Optimize memory usage
      memCacheHeight: 400,
    );
  }

  Widget _buildLoadingWidget() {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF69B4)),
          strokeWidth: 2,
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 40,
              color: Colors.grey[400],
            ),
            SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
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
