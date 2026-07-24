// lib/widgets/feed/feed_card.dart
// A single full-screen video card: player, double-tap heart overlay, progress bar, side actions.
// Long-press hides all UI and pauses video (peek mode).

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/video_item.dart';
import '../../providers/feed_provider.dart';
import 'video_player_widget.dart';
import 'side_action_panel.dart';
import 'video_info_overlay.dart';
import 'video_progress_bar.dart';

class FeedCard extends ConsumerStatefulWidget {
  final VideoItem video;
  final bool isActive;

  const FeedCard({
    super.key,
    required this.video,
    required this.isActive,
  });

  @override
  ConsumerState<FeedCard> createState() => _FeedCardState();
}

class _FeedCardState extends ConsumerState<FeedCard> {
  VideoPlayerController? _controller;
  final List<_HeartPosition> _hearts = [];
  bool _isPeeking = false; // long-press peek mode: hide all UI

  void _handleDoubleTapDown(TapDownDetails details) {
    final pos = details.localPosition;
    HapticFeedback.heavyImpact();

    // Trigger like
    ref.read(likedIdsProvider.notifier).like(widget.video.id);

    // Spawn animated heart at tap position
    final heartId = DateTime.now().microsecondsSinceEpoch;
    setState(() {
      _hearts.add(_HeartPosition(id: heartId, position: pos));
    });

    // Heart lives for 2200ms (1 sec longer than before)
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (mounted) {
        setState(() {
          _hearts.removeWhere((h) => h.id == heartId);
        });
      }
    });
  }

  void _onPeekModeChanged(bool isPeeking) {
    if (mounted) setState(() => _isPeeking = isPeeking);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTapDown: _handleDoubleTapDown,
      onDoubleTap: () {}, // activate double-tap recognition
      child: Stack(
        fit: StackFit.expand,
        children: [
          // ── Video layer (also handles single tap + long press) ─────
          VideoPlayerWidget(
            video: widget.video,
            isActive: widget.isActive,
            onControllerReady: (ctrl) {
              if (mounted) setState(() => _controller = ctrl);
            },
            onPeekModeChanged: _onPeekModeChanged,
          ),

          // ── Floating Double-Tap Hearts ─────────────────────────────
          for (final heart in _hearts)
            Positioned(
              left: heart.position.dx - 40,
              top: heart.position.dy - 40,
              child: _buildHeart(),
            ),

          // ── UI Overlay (hidden in peek mode) ──────────────────────
          AnimatedOpacity(
            opacity: _isPeeking ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 180),
            child: IgnorePointer(
              ignoring: _isPeeking,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Bottom gradient
                  const Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(gradient: AppTheme.bottomOverlay),
                    ),
                  ),

                  // Top gradient (for top bar)
                  const Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 120,
                    child: DecoratedBox(
                      decoration: BoxDecoration(gradient: AppTheme.topOverlay),
                    ),
                  ),

                  // Right side action panel
                  Positioned(
                    right: 0,
                    bottom: 40,
                    top: 0,
                    child: SideActionPanel(video: widget.video),
                  ),

                  // Bottom-left info & Progress bar
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        VideoInfoOverlay(video: widget.video),
                        if (_controller != null)
                          VideoProgressBar(controller: _controller!),
                        const SizedBox(height: 8),
                      ],
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

  Widget _buildHeart() {
    return const Icon(
      Icons.favorite_rounded,
      color: AppTheme.liked,
      size: 80,
    )
        .animate()
        .scale(
          begin: const Offset(0.1, 0.1),
          end: const Offset(1.4, 1.4),
          duration: 400.ms,
          curve: Curves.elasticOut,
        )
        .then()
        .scale(
          begin: const Offset(1.4, 1.4),
          end: const Offset(1.1, 1.1),
          duration: 150.ms,
          curve: Curves.easeOut,
        )
        .shimmer(
          duration: 600.ms,
          color: Colors.white.withValues(alpha: 0.6),
          delay: 200.ms,
        )
        .fadeOut(delay: 1500.ms, duration: 500.ms)
        .moveY(begin: 0, end: -80, duration: 1800.ms, curve: Curves.easeOut);
  }
}

class _HeartPosition {
  final int id;
  final Offset position;
  _HeartPosition({required this.id, required this.position});
}
