// lib/services/gallery_service.dart
// Core service: reads local video library via photo_manager.
// Handles pagination, sorting, and filtering of hidden videos.

import 'package:flutter/foundation.dart';
import 'package:photo_manager/photo_manager.dart';
import '../core/constants/app_constants.dart';
import '../data/models/video_item.dart';
import '../data/datasources/local_preferences_datasource.dart';

class GalleryService {
  final LocalPreferencesDatasource _prefs;

  GalleryService(this._prefs);

  // ----------------------------------------------------------------
  // Permission
  // ----------------------------------------------------------------
  Future<bool> requestPermission() async {
    final result = await PhotoManager.requestPermissionExtend();
    return result.isAuth;
  }

  // ----------------------------------------------------------------
  // Load all video assets (paginated) from gallery
  // Returns a sorted, filtered list based on [mode].
  // ----------------------------------------------------------------
  Future<List<VideoItem>> loadVideos({
    required PlaybackMode mode,
    int page = 0,
    int pageSize = AppConstants.paginationBatchSize,
  }) async {
    try {
      // Fetch ALL video albums (including "Recents")
      final albums = await PhotoManager.getAssetPathList(
        type: RequestType.video,
        filterOption: FilterOptionGroup(
          videoOption: const FilterOption(
            durationConstraint: DurationConstraint(
              min: Duration(seconds: 1),
            ),
          ),
        ),
      );

      if (albums.isEmpty) return [];

      // Use the "All Videos" album (usually first / largest)
      final allVideosAlbum = albums.firstWhere(
        (a) => a.isAll,
        orElse: () => albums.first,
      );

      final totalCount = await allVideosAlbum.assetCountAsync;

      // Determine sort order for fetching
      final pmPage = _buildPageArgs(mode, page, pageSize, totalCount);

      final assets = await allVideosAlbum.getAssetListPaged(
        page: pmPage.page,
        size: pmPage.size,
      );

      final hiddenIds = _prefs.getHiddenVideoIds();

      // Map to VideoItem, filter hidden
      final items = assets
          .where((a) => !hiddenIds.contains(a.id))
          .map(VideoItem.fromAsset)
          .toList();

      // Apply shuffle client-side if needed
      if (mode == PlaybackMode.shuffle) {
        items.shuffle();
      }

      return items;
    } catch (e) {
      debugPrint('[GalleryService] loadVideos error: $e');
      return [];
    }
  }

  // ----------------------------------------------------------------
  // Load liked videos only
  // ----------------------------------------------------------------
  Future<List<VideoItem>> loadLikedVideos() async {
    final likedIds = _prefs.getLikedVideoIds();
    if (likedIds.isEmpty) return [];

    try {
      final futures = likedIds.map((id) async {
        final entity = await AssetEntity.fromId(id);
        if (entity == null) return null;
        return VideoItem.fromAsset(entity);
      });

      final results = await Future.wait(futures);
      return results.whereType<VideoItem>().toList();
    } catch (e) {
      debugPrint('[GalleryService] loadLikedVideos error: $e');
      return [];
    }
  }

  // ----------------------------------------------------------------
  // Fetch thumbnail for a video asset
  // ----------------------------------------------------------------
  Future<Uint8List?> getThumbnail(
    VideoItem item, {
    int width = 400,
    int height = 711,
  }) async {
    return item.asset?.thumbnailDataWithSize(
      ThumbnailSize(width, height),
      quality: 85,
    );
  }

  // ----------------------------------------------------------------
  // Private helpers
  // ----------------------------------------------------------------
  _PageArgs _buildPageArgs(
    PlaybackMode mode,
    int page,
    int pageSize,
    int totalCount,
  ) {
    // photo_manager always returns newest-first (desc createDate)
    // For chronologicalAsc (oldest first), we need to flip the page index
    if (mode == PlaybackMode.chronologicalAsc) {
      final totalPages = (totalCount / pageSize).ceil();
      final flippedPage = (totalPages - 1 - page).clamp(0, totalPages - 1);
      return _PageArgs(page: flippedPage, size: pageSize);
    }
    return _PageArgs(page: page, size: pageSize);
  }
}

class _PageArgs {
  final int page;
  final int size;
  const _PageArgs({required this.page, required this.size});
}
