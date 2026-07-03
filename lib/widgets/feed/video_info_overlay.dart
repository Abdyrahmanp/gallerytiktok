// lib/widgets/feed/video_info_overlay.dart
// Bottom-left overlay: video title, date, duration.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/video_item.dart';

class VideoInfoOverlay extends StatelessWidget {
  final VideoItem video;

  const VideoInfoOverlay({super.key, required this.video});

  @override
  Widget build(BuildContext context) {
    final dateStr = video.createdAt != null
        ? DateFormat('dd MMM yyyy', 'tr').format(video.createdAt!)
        : '';

    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 80, bottom: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date badge
          if (dateStr.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.45),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.calendar_today_rounded, color: Colors.white60, size: 12),
                  const SizedBox(width: 5),
                  Text(
                    dateStr,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 8),

          // Video title
          Text(
            video.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              shadows: [
                Shadow(blurRadius: 6, color: Colors.black87),
                Shadow(blurRadius: 12, color: Colors.black54),
              ],
            ),
          ),

          const SizedBox(height: 6),

          // Duration + resolution row
          Row(
            children: [
              _MetaBadge(
                icon: Icons.timer_outlined,
                label: video.formattedDuration,
              ),
              const SizedBox(width: 8),
              if (video.width != null && video.height != null)
                _MetaBadge(
                  icon: Icons.photo_size_select_large_outlined,
                  label: '${video.width}×${video.height}',
                ),
            ],
          ),

          const SizedBox(height: 4),

          // Swipe hint (shown at bottom)
          const _SwipeHint(),
        ],
      ),
    );
  }
}

class _MetaBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white54, size: 11),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white60, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _SwipeHint extends StatelessWidget {
  const _SwipeHint();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        children: [
          const Icon(Icons.keyboard_arrow_up_rounded, color: Colors.white38, size: 16),
          const SizedBox(width: 2),
          Text(
            'Sonraki video',
            style: TextStyle(
              color: Colors.white.withOpacity(0.35),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
