// lib/widgets/feed/feed_card.dart
// A single full-screen video card: player, double-tap heart overlay, progress bar, side actions.

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

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        setState(() {
          _hearts.removeWhere((h) => h.id == heartId);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTapDown: _handleDoubleTapDown,
      onDoubleTap: () {}, // empty callback to activate double tap
      child: Stack(
        fit: StackFit.expand,
        children: [
          // ── Video layer ──────────────────────────────────────
          VideoPlayerWidget(
            video: widget.video,
            isActive: widget.isActive,
            onControllerReady: (ctrl) {
              if (mounted) setState(() => _controller = ctrl);
            },
          ),

          // ── Floating Double-Tap Hearts ────────────────────────
          for (final heart in _hearts)
            Positioned(
              left: heart.position.dx - 40,
              top: heart.position.dy - 40,
              child: const Icon(
                Icons.favorite_rounded,
                color: AppTheme.liked,
                size: 80,
              )
                  .animate()
                  .scale(
                    begin: const Offset(0.2, 0.2),
                    end: const Offset(1.3, 1.3),
                    duration: 350.ms,
                    curve: Curves.elasticOut,
                  )
                  .fadeOut(delay: 500.ms, duration: 400.ms)
                  .moveY(begin: 0, end: -60, duration: 900.ms, curve: Curves.easeOut),
            ),

          // ── Bottom gradient ──────────────────────────────────
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(gradient: AppTheme.bottomOverlay),
            ),
          ),

          // ── Top gradient (for top bar) ───────────────────────
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 120,
            child: DecoratedBox(
              decoration: BoxDecoration(gradient: AppTheme.topOverlay),
            ),
          ),

          // ── Right side action panel ──────────────────────────
          Positioned(
            right: 0,
            bottom: 40,
            top: 0,
            child: SideActionPanel(video: widget.video),
          ),

          // ── Bottom-left info & Progress bar ─────────────────
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
    );
  }
}

class _HeartPosition {
  final int id;
  final Offset position;
  _HeartPosition({required this.id, required this.position});
}
