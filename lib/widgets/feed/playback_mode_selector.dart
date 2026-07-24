// lib/widgets/feed/playback_mode_selector.dart
// Top-center mode switcher chip — uses real Flutter icons instead of emojis.

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
    final accentIdx = ref.watch(accentColorIndexProvider);
    final accentColor = kAccentPalette[accentIdx];

    return GestureDetector(
      onTap: () => _showModeSheet(context, ref, mode, accentColor),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
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
            Icon(mode.iconData, color: accentColor, size: 15),
            const SizedBox(width: 6),
            Text(
              mode.label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
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

  void _showModeSheet(BuildContext context, WidgetRef ref, PlaybackMode current, Color accent) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _ModeSheet(currentMode: current, ref: ref, accentColor: accent),
    );
  }
}

class _ModeSheet extends StatelessWidget {
  final PlaybackMode currentMode;
  final WidgetRef ref;
  final Color accentColor;

  const _ModeSheet({
    required this.currentMode,
    required this.ref,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 30,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.only(bottom: 4, left: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Oynatma Modu',
                style: TextStyle(
                  color: accentColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),

          const Divider(color: Colors.white10, height: 1),

          ...PlaybackMode.values.map(
            (mode) {
              final selected = currentMode == mode;
              return ListTile(
                leading: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: selected
                        ? accentColor.withValues(alpha: 0.18)
                        : Colors.white.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: selected ? accentColor.withValues(alpha: 0.4) : Colors.transparent,
                    ),
                  ),
                  child: Icon(
                    mode.iconData,
                    color: selected ? accentColor : Colors.white60,
                    size: 20,
                  ),
                ),
                title: Text(
                  mode.label,
                  style: TextStyle(
                    color: selected ? Colors.white : Colors.white70,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                trailing: selected
                    ? Icon(Icons.check_circle_rounded, color: accentColor, size: 22)
                    : const SizedBox.shrink(),
                onTap: () {
                  HapticFeedback.selectionClick();
                  Navigator.pop(context);
                  ref.read(playbackModeProvider.notifier).setMode(mode);
                  ref.read(feedProvider.notifier).initialize();
                },
              );
            },
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
