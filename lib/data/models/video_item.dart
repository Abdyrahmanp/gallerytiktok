// lib/data/models/video_item.dart

import 'package:equatable/equatable.dart';
import 'package:photo_manager/photo_manager.dart';

class VideoItem extends Equatable {
  final String id;
  final String title;
  final DateTime? createdAt;
  final Duration? duration;
  final int? width;
  final int? height;
  final AssetEntity? asset; // nullable for Hive-restored items

  const VideoItem({
    required this.id,
    required this.title,
    this.createdAt,
    this.duration,
    this.width,
    this.height,
    this.asset,
  });

  factory VideoItem.fromAsset(AssetEntity asset) {
    return VideoItem(
      id: asset.id,
      title: asset.title ?? 'Video',
      createdAt: asset.createDateTime,
      duration: Duration(seconds: asset.duration),
      width: asset.width,
      height: asset.height,
      asset: asset,
    );
  }

  double get aspectRatio {
    if (width != null && height != null && height! > 0) {
      return width! / height!;
    }
    return 9 / 16; // default portrait
  }

  bool get isPortrait => aspectRatio < 1.0;

  String get formattedDuration {
    if (duration == null) return '--:--';
    final m = duration!.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = duration!.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  List<Object?> get props => [id];
}
