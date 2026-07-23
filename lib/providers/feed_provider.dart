// lib/providers/feed_provider.dart
// Riverpod providers for the video feed state.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager/photo_manager.dart';
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
// Tab and Hidden ID state providers (fully reactive)
// -----------------------------------------------------------------------

final isFeedTabActiveProvider = StateProvider<bool>((ref) => true);

final hiddenIdsProvider = StateNotifierProvider<HiddenIdsNotifier, Set<String>>(
  (ref) => HiddenIdsNotifier(ref.read(localPrefsProvider)),
);

class HiddenIdsNotifier extends StateNotifier<Set<String>> {
  final LocalPreferencesDatasource _prefs;

  HiddenIdsNotifier(this._prefs) : super(_prefs.getHiddenVideoIds());

  Future<void> hide(String id) async {
    await _prefs.hideVideo(id);
    state = _prefs.getHiddenVideoIds();
  }

  Future<void> unhide(String id) async {
    await _prefs.unhideVideo(id);
    state = _prefs.getHiddenVideoIds();
  }

  bool isHidden(String id) => state.contains(id);
}

// -----------------------------------------------------------------------
// Selected album IDs (empty = show all)
// -----------------------------------------------------------------------

final selectedAlbumIdsProvider =
    StateNotifierProvider<SelectedAlbumNotifier, Set<String>>(
  (ref) => SelectedAlbumNotifier(ref.read(localPrefsProvider)),
);

class SelectedAlbumNotifier extends StateNotifier<Set<String>> {
  final LocalPreferencesDatasource _prefs;

  SelectedAlbumNotifier(this._prefs) : super(_prefs.getSelectedAlbumIds());

  Future<void> setAlbums(Set<String> ids) async {
    await _prefs.setSelectedAlbumIds(ids);
    state = ids;
  }

  Future<void> selectAll() async {
    await _prefs.setSelectedAlbumIds({});
    state = {};
  }
}

// -----------------------------------------------------------------------
// App Locale provider
// -----------------------------------------------------------------------

final appLocaleProvider = StateNotifierProvider<AppLocaleNotifier, Locale>(
  (ref) {
    final code = ref.read(localPrefsProvider).getAppLocale();
    return AppLocaleNotifier(ref.read(localPrefsProvider), Locale(code));
  },
);

class AppLocaleNotifier extends StateNotifier<Locale> {
  final LocalPreferencesDatasource _prefs;

  AppLocaleNotifier(this._prefs, Locale initial) : super(initial);

  Future<void> setLocale(String languageCode) async {
    await _prefs.setAppLocale(languageCode);
    state = Locale(languageCode);
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
    ref,
  ),
);

class FeedNotifier extends StateNotifier<FeedState> {
  final GalleryService _galleryService;
  final Ref _ref;

  List<AssetEntity> _allAssets = [];

  FeedNotifier(this._galleryService, this._ref)
      : super(const FeedState());

  Future<void> initialize() async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, videos: [], currentPage: 0, hasMore: true);

    try {
      final selectedAlbumIds = _ref.read(selectedAlbumIdsProvider);
      final allRawAssets = await _galleryService.getAllVideoAssets(
        albumIds: selectedAlbumIds.isEmpty ? null : selectedAlbumIds,
      );
      final hiddenIds = _ref.read(hiddenIdsProvider);

      var filteredAssets = allRawAssets.where((a) => !hiddenIds.contains(a.id)).toList();

      final mode = _ref.read(playbackModeProvider);
      if (mode == PlaybackMode.shuffle) {
        filteredAssets.shuffle();
      } else if (mode == PlaybackMode.chronologicalAsc) {
        filteredAssets.sort((a, b) => a.createDateTime.compareTo(b.createDateTime));
      } else if (mode == PlaybackMode.chronologicalDesc) {
        filteredAssets.sort((a, b) => b.createDateTime.compareTo(a.createDateTime));
      }

      _allAssets = filteredAssets;
      await _loadPage(0);
    } catch (e) {
      debugPrint('[FeedNotifier] Error initializing: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;
    final nextPage = state.currentPage + 1;
    await _loadPage(nextPage);
  }

  Future<void> _loadPage(int page) async {
    try {
      state = state.copyWith(isLoading: true);
      const pageSize = AppConstants.paginationBatchSize;
      final start = page * pageSize;

      if (start >= _allAssets.length) {
        state = state.copyWith(isLoading: false, hasMore: false);
        return;
      }

      var end = (page + 1) * pageSize;
      if (end > _allAssets.length) end = _allAssets.length;

      final pageAssets = _allAssets.sublist(start, end);
      final newVideos = pageAssets.map(VideoItem.fromAsset).toList();
      final hasMore = end < _allAssets.length;

      if (page == 0) {
        state = FeedState(
          videos: newVideos,
          isLoading: false,
          hasMore: hasMore,
          currentPage: 0,
        );
      } else {
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
      debugPrint('[FeedNotifier] Error loading page $page: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void hideVideo(String id) {
    _ref.read(hiddenIdsProvider.notifier).hide(id);
    _allAssets.removeWhere((a) => a.id == id);
    state = state.copyWith(
      videos: state.videos.where((v) => v.id != id).toList(),
    );
  }

  void removeFromFeed(String id) {
    _allAssets.removeWhere((a) => a.id == id);
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

  Future<void> like(String id) async {
    if (!state.contains(id)) {
      await _prefs.likeVideo(id);
      state = _prefs.getLikedVideoIds();
    }
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
  ref.watch(likedIdsProvider);
  return svc.loadLikedVideos();
});

// -----------------------------------------------------------------------
// Video Fit Mode: auto / cover / contain
// -----------------------------------------------------------------------

/// 0 = auto (portrait→cover, landscape→contain)
/// 1 = always cover
/// 2 = always contain
final videoFitModeProvider = StateNotifierProvider<VideoFitModeNotifier, int>(
  (ref) => VideoFitModeNotifier(ref.read(localPrefsProvider)),
);

class VideoFitModeNotifier extends StateNotifier<int> {
  final LocalPreferencesDatasource _prefs;

  VideoFitModeNotifier(this._prefs)
      : super(_prefs.getVideoFitCover() ? 1 : 0);

  Future<void> setMode(int mode) async {
    // Persist: 0=auto, 1=cover, 2=contain
    await _prefs.setVideoFitCover(mode == 1);
    state = mode;
  }
}

// Keep old provider for backward compat
final videoFitCoverProvider = StateNotifierProvider<VideoFitNotifier, bool>(
  (ref) => VideoFitNotifier(ref.read(localPrefsProvider)),
);

class VideoFitNotifier extends StateNotifier<bool> {
  final LocalPreferencesDatasource _prefs;

  VideoFitNotifier(this._prefs) : super(_prefs.getVideoFitCover());

  Future<void> setFitCover(bool cover) async {
    await _prefs.setVideoFitCover(cover);
    state = cover;
  }
}

// -----------------------------------------------------------------------
// Accent Color Index
// -----------------------------------------------------------------------

final accentColorIndexProvider = StateNotifierProvider<AccentColorNotifier, int>(
  (ref) => AccentColorNotifier(ref.read(localPrefsProvider)),
);

class AccentColorNotifier extends StateNotifier<int> {
  final LocalPreferencesDatasource _prefs;

  AccentColorNotifier(this._prefs) : super(_prefs.getAccentColorIndex());

  Future<void> setIndex(int index) async {
    await _prefs.setAccentColorIndex(index);
    state = index;
  }
}

// Palette of choosable accent colors
const List<Color> kAccentPalette = [
  Color(0xFFFF3B5C), // Neon Red (default)
  Color(0xFF4CC9F0), // Neon Cyan
  Color(0xFFFFD60A), // Gold
  Color(0xFFBF5AF2), // Purple
  Color(0xFF30D158), // Mint Green
];
