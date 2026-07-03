// lib/providers/feed_provider.dart
// Riverpod providers for the video feed state.

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_constants.dart';
import '../data/datasources/local_preferences_datasource.dart';
import '../data/models/video_item.dart';
import '../services/gallery_service.dart';

// -----------------------------------------------------------------------
// Service providers
// -----------------------------------------------------------------------

final localPrefsProvider = Provider<LocalPreferencesDatasource>(
  (_) => LocalPreferencesDatasource(),
);

final galleryServiceProvider = Provider<GalleryService>(
  (ref) => GalleryService(ref.read(localPrefsProvider)),
);

// -----------------------------------------------------------------------
// Permission state
// -----------------------------------------------------------------------

final permissionGrantedProvider = StateProvider<bool>((ref) => false);

// -----------------------------------------------------------------------
// Playback mode provider
// -----------------------------------------------------------------------

final playbackModeProvider = StateNotifierProvider<PlaybackModeNotifier, PlaybackMode>(
  (ref) => PlaybackModeNotifier(ref.read(localPrefsProvider)),
);

class PlaybackModeNotifier extends StateNotifier<PlaybackMode> {
  final LocalPreferencesDatasource _prefs;

  PlaybackModeNotifier(this._prefs) : super(_prefs.getPlaybackMode());

  Future<void> setMode(PlaybackMode mode) async {
    await _prefs.setPlaybackMode(mode);
    state = mode;
  }
}

// -----------------------------------------------------------------------
// Feed state
// -----------------------------------------------------------------------

class FeedState {
  final List<VideoItem> videos;
  final bool isLoading;
  final bool hasMore;
  final int currentPage;
  final String? error;

  const FeedState({
    this.videos = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.currentPage = 0,
    this.error,
  });

  FeedState copyWith({
    List<VideoItem>? videos,
    bool? isLoading,
    bool? hasMore,
    int? currentPage,
    String? error,
  }) {
    return FeedState(
      videos: videos ?? this.videos,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      error: error,
    );
  }
}

final feedProvider = StateNotifierProvider<FeedNotifier, FeedState>(
  (ref) => FeedNotifier(
    ref.read(galleryServiceProvider),
    ref.read(localPrefsProvider),
    ref,
  ),
);

class FeedNotifier extends StateNotifier<FeedState> {
  final GalleryService _galleryService;
  final LocalPreferencesDatasource _prefs;
  final Ref _ref;

  FeedNotifier(this._galleryService, this._prefs, this._ref)
      : super(const FeedState());

  Future<void> initialize() async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, videos: [], currentPage: 0, hasMore: true);
    await _loadPage(0);
  }

  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;
    final nextPage = state.currentPage + 1;
    await _loadPage(nextPage);
  }

  Future<void> _loadPage(int page) async {
    try {
      final mode = _ref.read(playbackModeProvider);
      final newVideos = await _galleryService.loadVideos(
        mode: mode,
        page: page,
        pageSize: AppConstants.paginationBatchSize,
      );

      final hasMore = newVideos.length >= AppConstants.paginationBatchSize;

      if (page == 0) {
        state = FeedState(
          videos: newVideos,
          isLoading: false,
          hasMore: hasMore,
          currentPage: 0,
        );
      } else {
        // Merge, avoid duplicates
        final existingIds = state.videos.map((v) => v.id).toSet();
        final unique = newVideos.where((v) => !existingIds.contains(v.id)).toList();
        state = state.copyWith(
          videos: [...state.videos, ...unique],
          isLoading: false,
          hasMore: hasMore,
          currentPage: page,
        );
      }
    } catch (e) {
      debugPrint('[FeedNotifier] Error: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void hideVideo(String id) {
    _prefs.hideVideo(id);
    state = state.copyWith(
      videos: state.videos.where((v) => v.id != id).toList(),
    );
  }

  void removeFromFeed(String id) {
    state = state.copyWith(
      videos: state.videos.where((v) => v.id != id).toList(),
    );
  }
}

// -----------------------------------------------------------------------
// Liked video IDs provider (reactive set)
// -----------------------------------------------------------------------

final likedIdsProvider = StateNotifierProvider<LikedIdsNotifier, Set<String>>(
  (ref) => LikedIdsNotifier(ref.read(localPrefsProvider)),
);

class LikedIdsNotifier extends StateNotifier<Set<String>> {
  final LocalPreferencesDatasource _prefs;

  LikedIdsNotifier(this._prefs) : super(_prefs.getLikedVideoIds());

  Future<void> toggle(String id) async {
    await _prefs.toggleLike(id);
    state = _prefs.getLikedVideoIds();
  }

  bool isLiked(String id) => state.contains(id);
}

// -----------------------------------------------------------------------
// Mute state (global, shared across videos)
// -----------------------------------------------------------------------

final isMutedProvider = StateProvider<bool>((ref) {
  return ref.read(localPrefsProvider).getMuteByDefault();
});

// -----------------------------------------------------------------------
// Current feed index
// -----------------------------------------------------------------------

final currentFeedIndexProvider = StateProvider<int>((ref) => 0);

// -----------------------------------------------------------------------
// Favorites (liked videos feed)
// -----------------------------------------------------------------------

final favoritesProvider = FutureProvider<List<VideoItem>>((ref) async {
  final svc = ref.read(galleryServiceProvider);
  // Re-compute when liked IDs change
  ref.watch(likedIdsProvider);
  return svc.loadLikedVideos();
});
