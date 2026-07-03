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
}
