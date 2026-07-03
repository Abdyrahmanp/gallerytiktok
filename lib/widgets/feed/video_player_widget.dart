// lib/widgets/feed/video_player_widget.dart
// Single video player cell used inside the PageView.
// Handles: init, play/pause, mute, dispose lifecycle.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import '../../data/models/video_item.dart';
import '../../providers/feed_provider.dart';

class VideoPlayerWidget extends ConsumerStatefulWidget {
  final VideoItem video;
  final bool isActive; // true when this page is the current page

  const VideoPlayerWidget({
    super.key,
    required this.video,
    required this.isActive,
  });

  @override
  ConsumerState<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends ConsumerState<VideoPlayerWidget> {
  VideoPlayerController? _controller;
  bool _initialized = false;
  bool _showPlayIcon = false;

  @override
  void initState() {
    super.initState();
    if (widget.isActive) _initController();
  }

  @override
  void didUpdateWidget(covariant VideoPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      // Became active → initialize & play
      _initController();
    } else if (!widget.isActive && oldWidget.isActive) {
      // Became inactive → pause & release
      _disposeController();
    }
  }

  Future<void> _initController() async {
    if (widget.video.asset == null) return;

    final file = await widget.video.asset!.file;
    if (file == null || !mounted) return;

    _controller = VideoPlayerController.file(file);
    try {
      await _controller!.initialize();
      if (!mounted) {
        _controller?.dispose();
        return;
      }

      final isMuted = ref.read(isMutedProvider);
      await _controller!.setVolume(isMuted ? 0.0 : 1.0);
      await _controller!.setLooping(true);
      await _controller!.play();

      setState(() => _initialized = true);
    } catch (e) {
      debugPrint('[VideoPlayer] init error for ${widget.video.id}: $e');
    }
  }

  void _disposeController() {
    _controller?.pause();
    _controller?.dispose();
    _controller = null;
    if (mounted) setState(() => _initialized = false);
  }

  void _togglePlayPause() {
    if (_controller == null || !_initialized) return;
    setState(() => _showPlayIcon = true);

    if (_controller!.value.isPlaying) {
      _controller!.pause();
    } else {
      _controller!.play();
    }

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => _showPlayIcon = false);
    });
  }

  void _updateMute(bool muted) {
    _controller?.setVolume(muted ? 0.0 : 1.0);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen to global mute toggle
    ref.listen<bool>(isMutedProvider, (_, isMuted) => _updateMute(isMuted));

    return GestureDetector(
      onTap: _togglePlayPause,
      child: Container(
        color: Colors.black,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Video
            if (_initialized && _controller != null)
              _buildVideoFrame()
            else
              _buildThumbnail(),

            // Play/Pause overlay icon
            AnimatedOpacity(
              opacity: _showPlayIcon ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Center(
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    (_controller?.value.isPlaying ?? false)
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoFrame() {
    final controller = _controller!;
    return FittedBox(
      fit: BoxFit.cover,
      child: SizedBox(
        width: controller.value.size.width,
        height: controller.value.size.height,
        child: VideoPlayer(controller),
      ),
    );
  }

  Widget _buildThumbnail() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white30),
        strokeWidth: 1.5,
      ),
    );
  }
}
