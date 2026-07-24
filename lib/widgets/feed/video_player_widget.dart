// lib/widgets/feed/video_player_widget.dart
// Single video player cell used inside the PageView.
// Handles: init, play/pause, mute, dispose lifecycle, long-press peek mode.

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import '../../data/models/video_item.dart';
import '../../providers/feed_provider.dart';

class VideoPlayerWidget extends ConsumerStatefulWidget {
  final VideoItem video;
  final bool isActive;
  final ValueChanged<VideoPlayerController?>? onControllerReady;
  /// Called when long-press starts/ends (peek mode: hide UI & pause)
  final ValueChanged<bool>? onPeekModeChanged;

  const VideoPlayerWidget({
    super.key,
    required this.video,
    required this.isActive,
    this.onControllerReady,
    this.onPeekModeChanged,
  });

  @override
  ConsumerState<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends ConsumerState<VideoPlayerWidget>
    with SingleTickerProviderStateMixin {
  VideoPlayerController? _controller;
  bool _initialized = false;
  bool _isInitializing = false;
  bool _showPauseIcon = false;
  bool _isPeeking = false; // long-press peek mode

  late final AnimationController _pauseIconController;

  @override
  void initState() {
    super.initState();
    _pauseIconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    if (widget.isActive) _initController();
  }

  @override
  void didUpdateWidget(covariant VideoPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _initController();
    } else if (!widget.isActive && oldWidget.isActive) {
      _disposeController();
    }
  }

  Future<void> _initController() async {
    if (_isInitializing || _initialized) return;
    if (widget.video.asset == null) return;
    _isInitializing = true;

    try {
      final file = await widget.video.asset!.file;
      if (file == null || !mounted) {
        _isInitializing = false;
        return;
      }

      final controller = VideoPlayerController.file(file);
      await controller.initialize();

      if (!mounted) {
        controller.dispose();
        _isInitializing = false;
        return;
      }

      final isMuted = ref.read(isMutedProvider);
      await controller.setVolume(isMuted ? 0.0 : 1.0);
      await controller.setLooping(true);
      await controller.play();

      _controller = controller;
      _isInitializing = false;

      if (mounted) {
        setState(() => _initialized = true);
        widget.onControllerReady?.call(_controller);
      }
    } catch (e) {
      _isInitializing = false;
      debugPrint('[VideoPlayer] init error for ${widget.video.id}: $e');
      // Retry once after a short delay
      if (mounted && widget.isActive) {
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted && widget.isActive) _initController();
      }
    }
  }

  void _disposeController() {
    _controller?.pause();
    widget.onControllerReady?.call(null);
    _controller?.dispose();
    _controller = null;
    _initialized = false;
    _isInitializing = false;
    if (mounted) setState(() {});
  }

  void _togglePlayPause() {
    if (_controller == null || !_initialized || _isPeeking) return;

    final isPlaying = _controller!.value.isPlaying;
    if (isPlaying) {
      _controller!.pause();
    } else {
      _controller!.play();
    }

    setState(() => _showPauseIcon = true);
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) setState(() => _showPauseIcon = false);
    });
  }

  void _startPeek() {
    if (_controller == null || !_initialized) return;
    setState(() => _isPeeking = true);
    _controller!.pause();
    widget.onPeekModeChanged?.call(true);
  }

  void _endPeek() {
    if (!_isPeeking) return;
    setState(() => _isPeeking = false);
    _controller?.play();
    widget.onPeekModeChanged?.call(false);
  }

  void _updateMute(bool muted) {
    _controller?.setVolume(muted ? 0.0 : 1.0);
  }

  @override
  void dispose() {
    _pauseIconController.dispose();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<bool>(isMutedProvider, (_, isMuted) => _updateMute(isMuted));

    return GestureDetector(
      onTap: _togglePlayPause,
      onLongPressStart: (_) => _startPeek(),
      onLongPressEnd: (_) => _endPeek(),
      onLongPressCancel: _endPeek,
      behavior: HitTestBehavior.opaque,
      child: Container(
        color: Colors.black,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Video or loading thumbnail
            if (_initialized && _controller != null)
              _buildVideoFrame()
            else
              _buildLoadingIndicator(),

            // Pause/Play icon overlay (only when not in peek mode)
            if (!_isPeeking)
              AnimatedOpacity(
                opacity: _showPauseIcon ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Center(
                  child: _buildPauseIcon(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoFrame() {
    final controller = _controller!;
    final fitMode = ref.watch(videoFitModeProvider);

    BoxFit fit;
    if (fitMode == 1) {
      // "Dikey Akışa Uygun" — fit width (fills screen width, maintains ratio)
      fit = BoxFit.fitWidth;
    } else if (fitMode == 2) {
      // "Tam Göster" — contain, no cropping
      fit = BoxFit.contain;
    } else {
      // Auto — always contain to avoid cropping any video
      fit = BoxFit.contain;
    }

    return FittedBox(
      fit: fit,
      child: SizedBox(
        width: controller.value.size.width,
        height: controller.value.size.height,
        child: VideoPlayer(controller),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 36,
            height: 36,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Colors.white.withValues(alpha: 0.35),
              ),
              strokeWidth: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPauseIcon() {
    final isPlaying = _controller?.value.isPlaying ?? false;
    return Container(
      width: 76,
      height: 76,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Icon(
        isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
        color: Colors.white,
        size: 38,
      ),
    )
        .animate(key: ValueKey(_showPauseIcon))
        .scale(
          begin: const Offset(0.6, 0.6),
          end: const Offset(1.0, 1.0),
          duration: 250.ms,
          curve: Curves.elasticOut,
        );
  }
}
