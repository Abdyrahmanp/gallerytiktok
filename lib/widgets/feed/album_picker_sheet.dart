// lib/widgets/feed/album_picker_sheet.dart
// Bottom sheet allowing user to filter videos by gallery album/folder.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager/photo_manager.dart';
import '../../core/l10n/app_localizations.dart';
import '../../providers/feed_provider.dart';

class AlbumPickerSheet extends ConsumerStatefulWidget {
  const AlbumPickerSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const AlbumPickerSheet(),
    );
  }

  @override
  ConsumerState<AlbumPickerSheet> createState() => _AlbumPickerSheetState();
}

class _AlbumPickerSheetState extends ConsumerState<AlbumPickerSheet> {
  List<AssetPathEntity> _albums = [];
  bool _isLoading = true;
  late Set<String> _tempSelectedIds;

  @override
  void initState() {
    super.initState();
    _tempSelectedIds = Set.from(ref.read(selectedAlbumIdsProvider));
    _loadAlbums();
  }

  Future<void> _loadAlbums() async {
    final service = ref.read(galleryServiceProvider);
    final albums = await service.getAlbums();
    if (mounted) {
      setState(() {
        _albums = albums;
        _isLoading = false;
      });
    }
  }

  void _toggleAlbum(String id) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_tempSelectedIds.contains(id)) {
        _tempSelectedIds.remove(id);
      } else {
        _tempSelectedIds.add(id);
      }
    });
  }

  void _selectAll() {
    HapticFeedback.selectionClick();
    setState(() {
      _tempSelectedIds.clear();
    });
  }

  Future<void> _apply() async {
    HapticFeedback.mediumImpact();
    await ref.read(selectedAlbumIdsProvider.notifier).setAlbums(_tempSelectedIds);
    ref.read(feedProvider.notifier).initialize();
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final accentIdx = ref.watch(accentColorIndexProvider);
    final accentColor = kAccentPalette[accentIdx];

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF141416),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: Colors.white12)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          const SizedBox(height: 12),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Title & Select All
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.folder_special_rounded, color: accentColor, size: 22),
                    const SizedBox(width: 10),
                    Text(
                      l10n.selectFolder,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: _selectAll,
                  child: Text(
                    l10n.allAlbums,
                    style: TextStyle(
                      color: _tempSelectedIds.isEmpty ? accentColor : Colors.white60,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white10, height: 20),

          // Content
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white54),
                  )
                : ListView.builder(
                    itemCount: _albums.length,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemBuilder: (context, index) {
                      final album = _albums[index];
                      final isSelected = album.isAll
                          ? _tempSelectedIds.isEmpty
                          : _tempSelectedIds.contains(album.id);

                      return FutureBuilder<int>(
                        future: album.assetCountAsync,
                        builder: (context, countSnapshot) {
                          final count = countSnapshot.data ?? 0;

                          return InkWell(
                            onTap: () {
                              if (album.isAll) {
                                _selectAll();
                              } else {
                                _toggleAlbum(album.id);
                              }
                            },
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected ? accentColor.withValues(alpha: 0.15) : Colors.transparent,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isSelected ? accentColor.withValues(alpha: 0.5) : Colors.transparent,
                                ),
                              ),
                              child: Row(
                                children: [
                                  // Album Icon / Thumbnail
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      album.isAll ? Icons.video_collection_rounded : Icons.folder_rounded,
                                      color: isSelected ? accentColor : Colors.white60,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 14),

                                  // Album Title & Count
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          album.isAll ? l10n.allAlbums : album.name,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                            fontSize: 15,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '$count ${l10n.videos}',
                                          style: const TextStyle(
                                            color: Colors.white54,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Checkbox
                                  Icon(
                                    isSelected
                                        ? Icons.check_circle_rounded
                                        : Icons.radio_button_unchecked_rounded,
                                    color: isSelected ? accentColor : Colors.white24,
                                    size: 24,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),

          // Apply Button
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _apply,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    l10n.selectFolder,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
