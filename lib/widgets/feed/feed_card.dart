// lib/widgets/feed/feed_card.dart
// A single full-screen video card: player + overlays.

import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/video_item.dart';
import 'video_player_widget.dart';
import 'side_action_panel.dart';
import 'video_info_overlay.dart';

class FeedCard extends StatelessWidget {
  final VideoItem video;
  final bool isActive;

  const FeedCard({
    super.key,
    required this.video,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // ── Video layer ──────────────────────────────────────
        VideoPlayerWidget(video: video, isActive: isActive),

        // ── Bottom gradient ──────────────────────────────────
        const Positioned.fill(
          child: DecoratedBox(decoration: BoxDecoration(gradient: AppTheme.bottomOverlay)),
        ),

        // ── Top gradient (for top bar) ───────────────────────
        const Positioned(
          top: 0, left: 0, right: 0,
          height: 100,
          child: DecoratedBox(decoration: BoxDecoration(gradient: AppTheme.topOverlay)),
        ),

        // ── Right side action panel ──────────────────────────
        Positioned(
          right: 0,
          bottom: 0,
          top: 0,
          child: SideActionPanel(video: video),
        ),

        // ── Bottom-left info ─────────────────────────────────
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: VideoInfoOverlay(video: video),
        ),
      ],
    );
  }
}
