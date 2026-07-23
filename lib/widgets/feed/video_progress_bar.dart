// lib/widgets/feed/video_progress_bar.dart
// Interactive video progress bar with drag scrubbing and remaining time countdown.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import '../../providers/feed_provider.dart';

class VideoProgressBar extends ConsumerStatefulWidget {
  final VideoPlayerController controller;

  const VideoProgressBar({super.key, required this.controller});

  @override
  ConsumerState<VideoProgressBar> createState() => _VideoProgressBarState();
}

class _VideoProgressBarState extends ConsumerState<VideoProgressBar> {
  bool _isDragging = false;
  double _dragValue = 0.0; // 0.0 to 1.0

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerUpdate);
  }

  @override
  void didUpdateWidget(covariant VideoProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onControllerUpdate);
      widget.controller.addListener(_onControllerUpdate);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerUpdate);
    super.dispose();
  }

  void _onControllerUpdate() {
    if (!_isDragging && mounted) {
      setState(() {});
    }
  }

  String _formatCountdown(Duration remaining) {
    final negative = remaining.isNegative;
    final abs = remaining.abs();
    final m = abs.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = abs.inSeconds.remainder(60).toString().padLeft(2, '0');
    return negative ? '-00:00' : '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final value = widget.controller.value;
    if (!value.isInitialized) return const SizedBox.shrink();

    final accentIdx = ref.watch(accentColorIndexProvider);
    final accentColor = kAccentPalette[accentIdx];

    final duration = value.duration;
    final position = value.position;
    final remaining = duration - position;

    final progress = (duration.inMilliseconds > 0)
        ? (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0)
        : 0.0;

    final currentProgress = _isDragging ? _dragValue : progress;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              // Scrubbing Slider
              Expanded(
                child: SizedBox(
                  height: 18,
                  child: SliderTheme(
                    data: SliderThemeData(
                      trackHeight: 3,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                      overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                      activeTrackColor: accentColor,
                      inactiveTrackColor: Colors.white24,
                      thumbColor: accentColor,
                      overlayColor: accentColor.withValues(alpha: 0.2),
                    ),
                    child: Slider(
                      value: currentProgress,
                      onChangeStart: (_) {
                        setState(() => _isDragging = true);
                      },
                      onChanged: (val) {
                        setState(() => _dragValue = val);
                      },
                      onChangeEnd: (val) async {
                        final targetMs = (val * duration.inMilliseconds).round();
                        await widget.controller.seekTo(Duration(milliseconds: targetMs));
                        setState(() => _isDragging = false);
                      },
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Countdown Timer
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.timer_outlined, color: accentColor, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      _formatCountdown(remaining),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
