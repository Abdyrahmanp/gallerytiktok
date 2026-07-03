// lib/widgets/feed/side_action_panel.dart
// Right-side action panel: Like, Hide, Share, Mute.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/video_item.dart';
import '../../providers/feed_provider.dart';

class SideActionPanel extends ConsumerStatefulWidget {
  final VideoItem video;
  final VoidCallback? onHide;

  const SideActionPanel({
    super.key,
    required this.video,
    this.onHide,
  });

  @override
  ConsumerState<SideActionPanel> createState() => _SideActionPanelState();
}

class _SideActionPanelState extends ConsumerState<SideActionPanel> {
  bool _heartAnimating = false;

  Future<void> _handleLike() async {
    HapticFeedback.mediumImpact();
    await ref.read(likedIdsProvider.notifier).toggle(widget.video.id);
    setState(() => _heartAnimating = true);
    await Future.delayed(AppConstants.heartAnimDuration);
    if (mounted) setState(() => _heartAnimating = false);
  }

  Future<void> _handleHide() async {
    HapticFeedback.lightImpact();
    // Show confirmation
    final confirm = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const _HideConfirmSheet(),
    );
    if (confirm == true) {
      ref.read(feedProvider.notifier).hideVideo(widget.video.id);
      widget.onHide?.call();
    }
  }

  Future<void> _handleShare() async {
    HapticFeedback.lightImpact();
    if (widget.video.asset == null) return;
    final file = await widget.video.asset!.file;
    if (file == null) return;
    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'Bak bu videoyu bulduk 🎬',
    );
  }

  void _handleMute() {
    HapticFeedback.selectionClick();
    final current = ref.read(isMutedProvider);
    ref.read(isMutedProvider.notifier).state = !current;
  }

  @override
  Widget build(BuildContext context) {
    final isLiked = ref.watch(likedIdsProvider).contains(widget.video.id);
    final isMuted = ref.watch(isMutedProvider);

    return Padding(
      padding: const EdgeInsets.only(right: 12, bottom: 80),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Like button
          _ActionButton(
            onTap: _handleLike,
            icon: isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            color: isLiked ? AppTheme.liked : Colors.white,
            label: isLiked ? 'Beğenildi' : 'Beğen',
            child: isLiked && _heartAnimating
                ? const Icon(
                    Icons.favorite_rounded,
                    color: AppTheme.liked,
                    size: 32,
                  ).animate().scale(
                      begin: const Offset(1, 1),
                      end: const Offset(1.5, 1.5),
                      curve: Curves.elasticOut,
                      duration: 600.ms,
                    )
                : null,
          ),

          const SizedBox(height: 20),

          // Hide button
          _ActionButton(
            onTap: _handleHide,
            icon: Icons.visibility_off_rounded,
            color: Colors.white70,
            label: 'Gizle',
          ),

          const SizedBox(height: 20),

          // Share button
          _ActionButton(
            onTap: _handleShare,
            icon: Icons.share_rounded,
            color: Colors.white,
            label: 'Paylaş',
          ),

          const SizedBox(height: 20),

          // Mute button
          _ActionButton(
            onTap: _handleMute,
            icon: isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
            color: isMuted ? Colors.amber : Colors.white,
            label: isMuted ? 'Sessiz' : 'Ses',
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------
// Reusable action button
// -----------------------------------------------------------------------

class _ActionButton extends StatelessWidget {
  final VoidCallback onTap;
  final IconData icon;
  final Color color;
  final String label;
  final Widget? child;

  const _ActionButton({
    required this.onTap,
    required this.icon,
    required this.color,
    required this.label,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.35),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white12, width: 0.5),
            ),
            child: Center(
              child: child ??
                  Icon(icon, color: color, size: 26)
                      .animate(target: 1)
                      .shimmer(duration: 0.ms),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w500,
              shadows: [Shadow(blurRadius: 4, color: Colors.black54)],
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------
// Hide confirmation bottom sheet
// -----------------------------------------------------------------------

class _HideConfirmSheet extends StatelessWidget {
  const _HideConfirmSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          const Icon(Icons.visibility_off_rounded, color: Colors.white54, size: 40),
          const SizedBox(height: 12),
          const Text(
            'Bu videoyu gizle?',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text(
            'Video akışında bir daha gösterilmeyecek. Bu işlem geri alınabilir (Ayarlar).',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white60, fontSize: 13),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context, false),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white24),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Vazgeç'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.liked,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Gizle'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
