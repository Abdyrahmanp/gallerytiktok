// lib/screens/feed/feed_screen.dart
// The main TikTok-style vertical feed screen.
// Uses PageView.builder with vertical scroll physics for smooth snapping.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/feed_provider.dart';
import '../../widgets/feed/feed_card.dart';
import '../../widgets/feed/playback_mode_selector.dart';

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  late final PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    // Kick off the first load once the widget tree is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(feedProvider.notifier).initialize();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() => _currentIndex = index);
    ref.read(currentFeedIndexProvider.notifier).state = index;

    final videos = ref.read(feedProvider).videos;
    // Preload next batch when near the end
    if (index >= videos.length - AppConstants.preloadCount) {
      ref.read(feedProvider.notifier).loadMore();
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
    if (feedState.isLoading && feedState.videos.isEmpty) {
      return const _LoadingView();
    }

    if (feedState.error != null && feedState.videos.isEmpty) {
      return _ErrorView(error: feedState.error!, onRetry: () {
        ref.read(feedProvider.notifier).initialize();
      });
    }

    if (feedState.videos.isEmpty) {
      return const _EmptyView();
    }

    return Stack(
      children: [
        // ── Main vertical PageView ────────────────────────────
        PageView.builder(
          controller: _pageController,
          scrollDirection: Axis.vertical,
          physics: const PageScrollPhysics(parent: ClampingScrollPhysics()),
          onPageChanged: _onPageChanged,
          itemCount: feedState.videos.length + (feedState.hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= feedState.videos.length) {
              // Loader at the bottom of the list
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(strokeWidth: 1.5, color: Colors.white38),
                ),
              );
            }

            final video = feedState.videos[index];
            // Only render active ±preloadCount items
            final isActive = (index - _currentIndex).abs() <= AppConstants.preloadCount;

            return FeedCard(
              key: ValueKey(video.id),
              video: video,
              isActive: index == _currentIndex,
            );
          },
        ),

        // ── Top overlay: App name + Mode selector ────────────
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // App brand
                RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: 'Nostaljik',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                        ),
                      ),
                      TextSpan(
                        text: ' Reel',
                        style: TextStyle(
                          color: AppTheme.accent,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),

                // Mode selector chip
                const PlaybackModeSelector(),
              ],
            ),
          ),
        ),

        // ── Progress indicator (loading more at bottom) ───────
        if (feedState.isLoading && feedState.videos.isNotEmpty)
          const Positioned(
            bottom: 80,
            left: 0, right: 0,
            child: Center(
              child: SizedBox(
                width: 20, height: 20,
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
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: AppTheme.accent, strokeWidth: 2),
          SizedBox(height: 16),
          Text(
            'Videolar yükleniyor...',
            style: TextStyle(color: Colors.white60, fontSize: 14),
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, color: AppTheme.accent, size: 56),
            const SizedBox(height: 16),
            const Text(
              'Galeri yüklenemedi',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
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
              label: const Text('Tekrar Dene'),
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎬', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            const Text(
              'Hiç video bulunamadı',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Galerinizde video yok veya tüm videolar gizlendi.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
