// lib/screens/feed/feed_screen.dart
// The main TikTok-style vertical feed screen.
// Uses PageView.builder with vertical scroll physics for smooth snapping.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/feed_provider.dart';
import '../../data/models/video_item.dart';
import '../../widgets/feed/feed_card.dart';
import '../../widgets/feed/playback_mode_selector.dart';
import '../../widgets/feed/album_picker_sheet.dart';

class FeedScreen extends ConsumerStatefulWidget {
  final List<VideoItem>? initialVideos;
  final int initialIndex;

  const FeedScreen({
    super.key,
    this.initialVideos,
    this.initialIndex = 0,
  });

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  late final PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    if (widget.initialVideos == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(feedProvider.notifier).initialize();
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() => _currentIndex = index);

    if (widget.initialVideos == null) {
      ref.read(currentFeedIndexProvider.notifier).state = index;

      final videos = ref.read(feedProvider).videos;
      if (index >= videos.length - AppConstants.preloadCount) {
        ref.read(feedProvider.notifier).loadMore();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final feedState = ref.watch(feedProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        body: _buildBody(feedState),
      ),
    );
  }

  Widget _buildBody(FeedState feedState) {
    final videos = widget.initialVideos ?? feedState.videos;
    final hasMore = widget.initialVideos == null ? feedState.hasMore : false;
    final isLoading = widget.initialVideos == null ? feedState.isLoading : false;
    final error = widget.initialVideos == null ? feedState.error : null;
    final l10n = AppLocalizations.of(context);

    if (isLoading && videos.isEmpty) {
      return const _LoadingView();
    }

    if (error != null && videos.isEmpty) {
      return _ErrorView(
        error: error,
        onRetry: () {
          ref.read(feedProvider.notifier).initialize();
        },
      );
    }

    if (videos.isEmpty) {
      return const _EmptyView();
    }

    final isFeedTabActive = ref.watch(isFeedTabActiveProvider);
    final selectedAlbumIds = ref.watch(selectedAlbumIdsProvider);

    return Stack(
      children: [
        // ── Main vertical PageView ────────────────────────────
        PageView.builder(
          controller: _pageController,
          scrollDirection: Axis.vertical,
          physics: const PageScrollPhysics(parent: ClampingScrollPhysics()),
          onPageChanged: _onPageChanged,
          itemCount: videos.length + (hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= videos.length) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(strokeWidth: 1.5, color: Colors.white38),
                ),
              );
            }

            final video = videos[index];
            final isActive = (widget.initialVideos != null)
                ? (index == _currentIndex)
                : (isFeedTabActive && index == _currentIndex);

            return FeedCard(
              key: ValueKey(video.id),
              video: video,
              isActive: isActive,
            );
          },
        ),

        // ── Top overlay: App brand + Album selector + Mode selector ───
        if (widget.initialVideos == null)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              child: Builder(builder: (context) {
                final accentIdx = ref.watch(accentColorIndexProvider);
                final accentColor = kAccentPalette[accentIdx];

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Brand Logo
                    RichText(
                      text: TextSpan(
                        children: [
                          const TextSpan(
                            text: 'My',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                          TextSpan(
                            text: ' Reels',
                            style: TextStyle(
                              color: accentColor,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Controls Row (Album Selector + Playback Mode)
                    Row(
                      children: [
                        // Folder Selector Chip
                        GestureDetector(
                          onTap: () => AlbumPickerSheet.show(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: selectedAlbumIds.isNotEmpty ? accentColor : Colors.white24,
                              ),
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
                                Icon(
                                  selectedAlbumIds.isNotEmpty
                                      ? Icons.folder_special_rounded
                                      : Icons.folder_rounded,
                                  color: selectedAlbumIds.isNotEmpty ? accentColor : Colors.white70,
                                  size: 15,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  selectedAlbumIds.isEmpty
                                      ? l10n.allAlbums
                                      : '${selectedAlbumIds.length} ${l10n.selectFolder}',
                                  style: TextStyle(
                                    color: selectedAlbumIds.isNotEmpty ? accentColor : Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 3),
                                const Icon(Icons.arrow_drop_down_rounded, color: Colors.white70, size: 18),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        // Mode Selector Chip
                        const PlaybackModeSelector(),
                      ],
                    ),
                  ],
                );
              }),
            ),
          )
        else
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: CircleAvatar(
                backgroundColor: Colors.black.withValues(alpha: 0.55),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ),

        // ── Progress indicator (loading more) ────────────────
        if (isLoading && videos.isNotEmpty)
          const Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 1.5, color: Colors.white38),
              ),
            ),
          ),
      ],
    );
  }
}

// -----------------------------------------------------------------------
// State views
// -----------------------------------------------------------------------

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: AppTheme.accent, strokeWidth: 2),
          const SizedBox(height: 16),
          Text(
            l10n.loadingVideos,
            style: const TextStyle(color: Colors.white60, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, color: AppTheme.accent, size: 56),
            const SizedBox(height: 16),
            Text(
              l10n.galleryError,
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white54, fontSize: 13),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(l10n.retry),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎬', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text(
              l10n.noVideos,
              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.noVideosDesc,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
