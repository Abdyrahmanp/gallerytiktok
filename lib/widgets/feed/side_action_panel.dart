// lib/widgets/feed/side_action_panel.dart
// Right-side action panel: Like, Hide, Share, Mute.
// Buttons respond instantly with visual feedback; async ops run in background.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/constants/app_constants.dart';
import '../../core/l10n/app_localizations.dart';
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

  void _handleLike() {
    // Respond INSTANTLY — fire & forget the async toggle
    HapticFeedback.mediumImpact();
    setState(() => _heartAnimating = true);
    ref.read(likedIdsProvider.notifier).toggle(widget.video.id);
    Future.delayed(AppConstants.heartAnimDuration, () {
      if (mounted) setState(() => _heartAnimating = false);
    });
  }

  Future<void> _handleHide() async {
    HapticFeedback.lightImpact();
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

  void _handleShare() {
    // Respond instantly — share happens in background
    HapticFeedback.lightImpact();
    if (widget.video.asset == null) return;
    widget.video.asset!.file.then((file) {
      if (file == null) return;
      Share.shareXFiles([XFile(file.path)], text: 'My Reels 🎬');
    });
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
    final l10n    = AppLocalizations.of(context);

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
            label: isLiked ? l10n.liked : l10n.like,
            glowColor: isLiked ? AppTheme.liked : null,
            child: isLiked && _heartAnimating
                ? const Icon(
                    Icons.favorite_rounded,
                    color: AppTheme.liked,
                    size: 32,
                  )
                    .animate()
                    .scale(
                      begin: const Offset(0.8, 0.8),
                      end: const Offset(1.6, 1.6),
                      curve: Curves.elasticOut,
                      duration: 500.ms,
                    )
                    .then()
                    .scale(
                      begin: const Offset(1.6, 1.6),
                      end: const Offset(1.0, 1.0),
                      duration: 200.ms,
                    )
                : null,
          ),

          const SizedBox(height: 20),

          // Hide button
          _ActionButton(
            onTap: _handleHide,
            icon: Icons.visibility_off_rounded,
            color: Colors.white70,
            label: l10n.hide,
          ),

          const SizedBox(height: 20),

          // Share button
          _ActionButton(
            onTap: _handleShare,
            icon: Icons.share_rounded,
            color: Colors.white,
            label: l10n.share,
          ),

          const SizedBox(height: 20),

          // Mute button
          _ActionButton(
            onTap: _handleMute,
            icon: isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
            color: isMuted ? Colors.amber : Colors.white,
            label: isMuted ? l10n.mute : l10n.sound,
            glowColor: isMuted ? Colors.amber : null,
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------
// Reusable action button — responds instantly with press animation
// -----------------------------------------------------------------------

class _ActionButton extends StatefulWidget {
  final VoidCallback onTap;
  final IconData icon;
  final Color color;
  final String label;
  final Widget? child;
  final Color? glowColor;

  const _ActionButton({
    required this.onTap,
    required this.icon,
    required this.color,
    required this.label,
    this.child,
    this.glowColor,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressCtrl;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
      reverseDuration: const Duration(milliseconds: 200),
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(parent: _pressCtrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) => _pressCtrl.forward();
  void _onTapUp(TapUpDetails _) {
    _pressCtrl.reverse();
    widget.onTap();
  }
  void _onTapCancel() => _pressCtrl.reverse();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (_, child) => Transform.scale(
          scale: _scaleAnim.value,
          child: child,
        ),
        child: Column(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.38),
                shape: BoxShape.circle,
                border: Border.all(
                  color: widget.glowColor?.withValues(alpha: 0.4) ?? Colors.white12,
                  width: 0.8,
                ),
                boxShadow: widget.glowColor != null
                    ? [
                        BoxShadow(
                          color: widget.glowColor!.withValues(alpha: 0.3),
                          blurRadius: 12,
                          spreadRadius: 1,
                        ),
                      ]
                    : [],
              ),
              child: Center(
                child: widget.child ?? Icon(widget.icon, color: widget.color, size: 26),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w500,
                shadows: [Shadow(blurRadius: 4, color: Colors.black54)],
              ),
            ),
          ],
        ),
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
    final l10n = AppLocalizations.of(context);

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
          Text(
            l10n.hideVideoTitle,
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.hideVideoDesc,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white60, fontSize: 13),
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
                  child: Text(l10n.cancel),
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
                  child: Text(l10n.hide),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
