// lib/data/datasources/local_preferences_datasource.dart
// Manages Hive boxes for liked/hidden video IDs and settings.

import 'package:hive_flutter/hive_flutter.dart';
import '../../core/constants/app_constants.dart';

class LocalPreferencesDatasource {
  // ---- Liked Videos ----
  Box<bool> get _likedBox => Hive.box<bool>(AppConstants.likedVideosBox);
  Box<bool> get _hiddenBox => Hive.box<bool>(AppConstants.hiddenVideosBox);
  Box<dynamic> get _settingsBox => Hive.box(AppConstants.settingsBox);

  Set<String> getLikedVideoIds() => _likedBox.keys.cast<String>().toSet();
  Set<String> getHiddenVideoIds() => _hiddenBox.keys.cast<String>().toSet();

  bool isLiked(String id) => _likedBox.get(id, defaultValue: false) ?? false;
  bool isHidden(String id) => _hiddenBox.get(id, defaultValue: false) ?? false;

  Future<void> likeVideo(String id) => _likedBox.put(id, true);
  Future<void> unlikeVideo(String id) => _likedBox.delete(id);
  Future<void> toggleLike(String id) =>
      isLiked(id) ? unlikeVideo(id) : likeVideo(id);

  Future<void> hideVideo(String id) => _hiddenBox.put(id, true);
  Future<void> unhideVideo(String id) => _hiddenBox.delete(id);

  // ---- Settings ----
  PlaybackMode getPlaybackMode() {
    final stored = _settingsBox.get(AppConstants.playbackModeKey);
    if (stored == null) return PlaybackMode.shuffle;
    return PlaybackMode.values.firstWhere(
      (m) => m.name == stored,
      orElse: () => PlaybackMode.shuffle,
    );
  }

  Future<void> setPlaybackMode(PlaybackMode mode) =>
      _settingsBox.put(AppConstants.playbackModeKey, mode.name);

  bool getMuteByDefault() =>
      _settingsBox.get(AppConstants.muteByDefaultKey, defaultValue: false) ?? false;

  Future<void> setMuteByDefault(bool value) =>
      _settingsBox.put(AppConstants.muteByDefaultKey, value);

  bool getVideoFitCover() =>
      _settingsBox.get(AppConstants.videoFitCoverKey, defaultValue: true) ?? true;

  Future<void> setVideoFitCover(bool value) =>
      _settingsBox.put(AppConstants.videoFitCoverKey, value);

  int getAccentColorIndex() =>
      _settingsBox.get(AppConstants.accentColorIndexKey, defaultValue: 0) ?? 0;

  Future<void> setAccentColorIndex(int index) =>
      _settingsBox.put(AppConstants.accentColorIndexKey, index);

  // Selected album IDs (empty = all albums)
  Set<String> getSelectedAlbumIds() {
    final stored = _settingsBox.get(AppConstants.selectedAlbumIdsKey);
    if (stored == null) return {};
    if (stored is List) return stored.cast<String>().toSet();
    return {};
  }

  Future<void> setSelectedAlbumIds(Set<String> ids) =>
      _settingsBox.put(AppConstants.selectedAlbumIdsKey, ids.toList());

  // App locale (default: system / 'tr')
  String getAppLocale() =>
      _settingsBox.get(AppConstants.appLocaleKey, defaultValue: 'tr') ?? 'tr';

  Future<void> setAppLocale(String locale) =>
      _settingsBox.put(AppConstants.appLocaleKey, locale);
}
