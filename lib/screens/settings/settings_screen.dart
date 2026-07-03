// lib/screens/settings/settings_screen.dart
// Settings screen for managing hidden videos and general options.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/feed_provider.dart';
import '../../data/models/video_item.dart';
import 'package:photo_manager/photo_manager.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMuted = ref.watch(isMutedProvider);
    final prefs = ref.watch(localPrefsProvider);
    final hiddenIds = prefs.getHiddenVideoIds();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('⚙️  Ayarlar'),
        backgroundColor: AppTheme.surface,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── PLAYBACK SETTINGS ──
          _buildSectionHeader('Oynatma Ayarları'),
          Card(
            color: AppTheme.cardSurface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Başlangıçta Sessize Al', style: TextStyle(color: Colors.white)),
                  subtitle: const Text('Uygulama açıldığında videolar sessiz başlasın', style: TextStyle(color: Colors.white70)),
                  value: isMuted,
                  activeColor: AppTheme.accent,
                  onChanged: (val) async {
                    await prefs.setMuteByDefault(val);
                    ref.read(isMutedProvider.notifier).state = val;
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── HIDDEN VIDEOS MANAGEMENT ──
          _buildSectionHeader('Gizlenen Videolar (${hiddenIds.length})'),
          if (hiddenIds.isEmpty)
            Card(
              color: AppTheme.cardSurface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(
                  child: Text(
                    'Gizlenmiş video bulunmuyor.',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                ),
              ),
            )
          else
            Card(
              color: AppTheme.cardSurface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: hiddenIds.length,
                separatorBuilder: (context, index) => const Divider(color: Colors.white10, height: 1),
                itemBuilder: (context, index) {
                  final id = hiddenIds.elementAt(index);
                  return _HiddenVideoTile(id: id);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: AppTheme.accentBlue,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _HiddenVideoTile extends ConsumerWidget {
  final String id;
  const _HiddenVideoTile({required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final galleryService = ref.read(galleryServiceProvider);

    return FutureBuilder<AssetEntity?>(
      future: AssetEntity.fromId(id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const ListTile(
            title: Text('Yükleniyor...', style: TextStyle(color: Colors.white60)),
            trailing: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }

        final asset = snapshot.data;
        if (asset == null) {
          return ListTile(
            title: const Text('Bilinmeyen Video', style: TextStyle(color: Colors.white30)),
            subtitle: Text('ID: $id', style: const TextStyle(color: Colors.white24, fontSize: 11)),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.liked),
              onPressed: () async {
                await ref.read(localPrefsProvider).unhideVideo(id);
                ref.read(feedProvider.notifier).initialize();
                // trigger redraw
                ref.invalidate(localPrefsProvider);
              },
            ),
          );
        }

        final videoItem = VideoItem.fromAsset(asset);

        return ListTile(
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: Colors.black26,
            ),
            clipBehavior: Clip.antiAlias,
            child: FutureBuilder<dynamic>(
              future: galleryService.getThumbnail(videoItem, width: 100, height: 100),
              builder: (context, snap) {
                if (snap.hasData && snap.data != null) {
                  return Image.memory(snap.data!, fit: BoxFit.cover);
                }
                return const Center(child: Icon(Icons.movie_outlined, color: Colors.white24));
              },
            ),
          ),
          title: Text(
            videoItem.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
          subtitle: Text(
            videoItem.formattedDuration,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
          trailing: TextButton.icon(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              await ref.read(localPrefsProvider).unhideVideo(id);
              ref.read(feedProvider.notifier).initialize();
              // Force state refresh of local prefs in this widget
              messenger.showSnackBar(
                const SnackBar(content: Text('Video akışa geri döndürüldü.')),
              );
            },
            icon: const Icon(Icons.visibility_rounded, size: 16, color: AppTheme.accentBlue),
            label: const Text('Geri Al', style: TextStyle(color: AppTheme.accentBlue)),
          ),
        );
      },
    );
  }
}
