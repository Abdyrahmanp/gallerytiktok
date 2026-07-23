// lib/services/gallery_service.dart
// Core service: reads local video library via photo_manager.
// Handles pagination, sorting, album filtering, and hidden videos.

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
  // Fetch all video albums (folders)
  // ----------------------------------------------------------------
  Future<List<AssetPathEntity>> getAlbums() async {
    try {
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
      return albums;
    } catch (e) {
      debugPrint('[GalleryService] getAlbums error: $e');
      return [];
    }
  }

  // ----------------------------------------------------------------
  // Fetch video assets (optionally filtered by album IDs)
  // ----------------------------------------------------------------
  Future<List<AssetEntity>> getAllVideoAssets({Set<String>? albumIds}) async {
    try {
      final albums = await getAlbums();
      if (albums.isEmpty) return [];

      if (albumIds != null && albumIds.isNotEmpty) {
        final selectedAlbums = albums.where((a) => albumIds.contains(a.id)).toList();
        if (selectedAlbums.isEmpty) return [];

        final Map<String, AssetEntity> assetMap = {};
        for (final album in selectedAlbums) {
          final count = await album.assetCountAsync;
          final assets = await album.getAssetListRange(start: 0, end: count);
          for (final asset in assets) {
            assetMap[asset.id] = asset;
          }
        }
        return assetMap.values.toList();
      }

      // Default: all videos album (usually isAll = true)
      final allVideosAlbum = albums.firstWhere(
        (a) => a.isAll,
        orElse: () => albums.first,
      );

      final totalCount = await allVideosAlbum.assetCountAsync;
      final assets = await allVideosAlbum.getAssetListRange(
        start: 0,
        end: totalCount,
      );
      return assets;
    } catch (e) {
      debugPrint('[GalleryService] getAllVideoAssets error: $e');
      return [];
    }
  }

  // ----------------------------------------------------------------
  // Load all video assets (paginated) from gallery
  // ----------------------------------------------------------------
  Future<List<VideoItem>> loadVideos({
    required PlaybackMode mode,
    int page = 0,
    int pageSize = AppConstants.paginationBatchSize,
  }) async {
    try {
      final albums = await getAlbums();
      if (albums.isEmpty) return [];

      final allVideosAlbum = albums.firstWhere(
        (a) => a.isAll,
        orElse: () => albums.first,
      );

      final totalCount = await allVideosAlbum.assetCountAsync;
      final pmPage = _buildPageArgs(mode, page, pageSize, totalCount);

      final assets = await allVideosAlbum.getAssetListPaged(
        page: pmPage.page,
        size: pmPage.size,
      );

      final hiddenIds = _prefs.getHiddenVideoIds();
      final items = assets
          .where((a) => !hiddenIds.contains(a.id))
          .map(VideoItem.fromAsset)
          .toList();

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
