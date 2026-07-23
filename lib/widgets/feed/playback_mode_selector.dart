// lib/widgets/feed/playback_mode_selector.dart
// Top-center mode switcher chip.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/feed_provider.dart';

class PlaybackModeSelector extends ConsumerWidget {
  const PlaybackModeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(playbackModeProvider);

    return GestureDetector(
      onTap: () => _showModeSheet(context, ref, mode),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(mode.icon, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 6),
            Text(
              mode.label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white70, size: 16),
          ],
        ),
      ),
    );
  }

  void _showModeSheet(BuildContext context, WidgetRef ref, PlaybackMode current) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _ModeSheet(currentMode: current, ref: ref),
    );
  }
}

class _ModeSheet extends StatelessWidget {
  final PlaybackMode currentMode;
  final WidgetRef ref;

  const _ModeSheet({required this.currentMode, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text(
              'Oynatma Modu',
              style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
          ...PlaybackMode.values.map(
            (mode) => ListTile(
              leading: Text(mode.icon, style: const TextStyle(fontSize: 22)),
              title: Text(mode.label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
              trailing: currentMode == mode
                  ? const Icon(Icons.check_circle_rounded, color: AppTheme.accent, size: 22)
                  : const SizedBox.shrink(),
              onTap: () {
                HapticFeedback.selectionClick();
                Navigator.pop(context);
                ref.read(playbackModeProvider.notifier).setMode(mode);
                ref.read(feedProvider.notifier).initialize();
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
