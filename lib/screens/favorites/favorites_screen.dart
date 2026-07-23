// lib/screens/favorites/favorites_screen.dart
// Grid of liked/favorite videos with tap-to-play.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/video_item.dart';
import '../../providers/feed_provider.dart';
import '../feed/feed_screen.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favAsync = ref.watch(favoritesProvider);
    final l10n     = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text('❤️  ${l10n.favorites}'),
        backgroundColor: AppTheme.surface,
      ),
      body: favAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.accent, strokeWidth: 2),
        ),
        error: (e, _) => Center(
          child: Text('Hata: $e', style: const TextStyle(color: Colors.white54)),
        ),
        data: (videos) {
          if (videos.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🤍', style: TextStyle(fontSize: 56)),
                  const SizedBox(height: 12),
                  Text(
                    l10n.noVideos,
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.noVideosDesc,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.45), fontSize: 13),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(2),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 9 / 16,
              crossAxisSpacing: 2,
              mainAxisSpacing: 2,
            ),
            itemCount: videos.length,
            itemBuilder: (ctx, i) => _FavoriteTile(
              video: videos[i],
              onTap: () => _openVideo(ctx, videos, i, ref),
            ),
          );
        },
      ),
    );
  }

  void _openVideo(BuildContext ctx, List<VideoItem> videos, int startIndex, WidgetRef ref) async {
    ref.read(isFeedTabActiveProvider.notifier).state = false;

    await Navigator.push(
      ctx,
      MaterialPageRoute(
        builder: (_) => FeedScreen(
          initialVideos: videos,
          initialIndex: startIndex,
        ),
      ),
    );

    ref.read(isFeedTabActiveProvider.notifier).state = true;
  }
}

// -----------------------------------------------------------------------
// Favorite tile
// -----------------------------------------------------------------------
class _FavoriteTile extends StatelessWidget {
  final VideoItem video;
  final VoidCallback onTap;

  const _FavoriteTile({required this.video, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _ThumbnailImage(video: video),

          Positioned(
            bottom: 4, right: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                video.formattedDuration,
                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
              ),
            ),
          ),

          const Positioned(
            top: 4, right: 4,
            child: Icon(Icons.favorite_rounded, color: AppTheme.liked, size: 16),
          ),
        ],
      ),
    );
  }
}

class _ThumbnailImage extends ConsumerWidget {
  final VideoItem video;
  const _ThumbnailImage({required this.video});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<dynamic>(
      future: ref.read(galleryServiceProvider).getThumbnail(video),
      builder: (ctx, snap) {
        if (snap.hasData && snap.data != null) {
          return Image.memory(snap.data!, fit: BoxFit.cover);
        }
        return Container(color: const Color(0xFF1A1A1A));
      },
    );
  }
}
