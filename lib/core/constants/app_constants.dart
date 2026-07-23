// lib/core/constants/app_constants.dart

class AppConstants {
  // Hive box names
  static const String likedVideosBox = 'liked_videos';
  static const String hiddenVideosBox = 'hidden_videos';
  static const String settingsBox = 'settings';

  // Settings keys
  static const String playbackModeKey      = 'playback_mode';
  static const String muteByDefaultKey     = 'mute_by_default';
  static const String videoFitCoverKey     = 'video_fit_cover';
  static const String accentColorIndexKey  = 'accent_color_index';
  static const String selectedAlbumIdsKey  = 'selected_album_ids';
  static const String appLocaleKey         = 'app_locale';

  // Preload buffer: how many videos ahead/behind to keep alive
  static const int preloadCount = 2;

  // Max videos loaded at once in the page view controller
  static const int pageViewportCount = 5;

  // Pagination: how many videos to fetch per batch
  static const int paginationBatchSize = 30;

  // Animation durations
  static const Duration heartAnimDuration = Duration(milliseconds: 600);
  static const Duration overlayFadeDuration = Duration(milliseconds: 250);
}

enum PlaybackMode { shuffle, chronologicalAsc, chronologicalDesc }

extension PlaybackModeLabel on PlaybackMode {
  String get label {
    switch (this) {
      case PlaybackMode.shuffle:
        return 'Rastgele';
      case PlaybackMode.chronologicalAsc:
        return 'Eskiden Yeniye';
      case PlaybackMode.chronologicalDesc:
        return 'Yeniden Eskiye';
    }
  }

  String get icon {
    switch (this) {
      case PlaybackMode.shuffle:
        return '🔀';
      case PlaybackMode.chronologicalAsc:
        return '📅';
      case PlaybackMode.chronologicalDesc:
        return '🕰️';
    }
  }
}
