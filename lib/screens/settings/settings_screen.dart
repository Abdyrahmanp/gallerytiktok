// lib/screens/settings/settings_screen.dart
// Expanded settings screen: language selector, playback, video fit (auto/cover/contain),
// theme color, hidden videos accordion, cache management, and about section.
// All section headers use real Flutter icons instead of emojis.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_manager/photo_manager.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/video_item.dart';
import '../../providers/feed_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n        = AppLocalizations.of(context);
    final isMuted     = ref.watch(isMutedProvider);
    final fitMode     = ref.watch(videoFitModeProvider);
    final accentIdx   = ref.watch(accentColorIndexProvider);
    final currentLoc  = ref.watch(appLocaleProvider);
    final accentColor = kAccentPalette[accentIdx];
    final prefs       = ref.watch(localPrefsProvider);
    final hiddenIds   = ref.watch(hiddenIdsProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.settings_rounded, color: accentColor, size: 18),
            ),
            const SizedBox(width: 10),
            Text(
              l10n.settings,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        children: [

          // ── 0. LANGUAGE SELECTOR ──────────────────────────────────
          _sectionHeader(Icons.language_rounded, l10n.language, accentColor),
          _card(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.selectLanguage,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _langTile(context, ref, code: 'tr', name: l10n.langTurkish, flag: '🇹🇷', current: currentLoc.languageCode, accent: accentColor),
                        const SizedBox(width: 8),
                        _langTile(context, ref, code: 'en', name: l10n.langEnglish, flag: '🇬🇧', current: currentLoc.languageCode, accent: accentColor),
                        const SizedBox(width: 8),
                        _langTile(context, ref, code: 'tk', name: l10n.langTurkmen, flag: '🇹🇲', current: currentLoc.languageCode, accent: accentColor),
                        const SizedBox(width: 8),
                        _langTile(context, ref, code: 'ru', name: l10n.langRussian, flag: '🇷🇺', current: currentLoc.languageCode, accent: accentColor),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          // ── 1. PLAYBACK ──────────────────────────────────────────
          _sectionHeader(Icons.play_circle_outline_rounded, l10n.playbackSettings, accentColor),
          _card(
            children: [
              _switchTile(
                icon: Icons.volume_off_rounded,
                iconColor: accentColor,
                title: l10n.muteByDefault,
                subtitle: l10n.muteByDefaultDesc,
                value: isMuted,
                accentColor: accentColor,
                onChanged: (val) async {
                  await prefs.setMuteByDefault(val);
                  ref.read(isMutedProvider.notifier).state = val;
                },
              ),
            ],
          ),

          const SizedBox(height: 22),

          // ── 2. VIDEO FIT ────────────────────────────────────────
          _sectionHeader(Icons.aspect_ratio_rounded, l10n.screenFit, accentColor),
          _card(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _fitOption(
                            label: l10n.fitAuto,
                            sublabel: l10n.fitAutoDesc,
                            icon: Icons.auto_awesome_rounded,
                            selected: fitMode == 0,
                            accentColor: accentColor,
                            onTap: () => ref.read(videoFitModeProvider.notifier).setMode(0),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _fitOption(
                            label: l10n.fitCover,
                            sublabel: l10n.fitCoverDesc,
                            icon: Icons.fit_screen_rounded,
                            selected: fitMode == 1,
                            accentColor: accentColor,
                            onTap: () => ref.read(videoFitModeProvider.notifier).setMode(1),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _fitOption(
                            label: l10n.fitContain,
                            sublabel: l10n.fitContainDesc,
                            icon: Icons.crop_free_rounded,
                            selected: fitMode == 2,
                            accentColor: accentColor,
                            onTap: () => ref.read(videoFitModeProvider.notifier).setMode(2),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          // ── 3. THEME COLOR ──────────────────────────────────────
          _sectionHeader(Icons.palette_rounded, l10n.themeColor, accentColor),
          _card(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.selectAccentColor,
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List.generate(kAccentPalette.length, (i) {
                        final color = kAccentPalette[i];
                        final selected = accentIdx == i;
                        final labels = [
                          l10n.colorRed,
                          l10n.colorCyan,
                          l10n.colorGold,
                          l10n.colorPurple,
                          l10n.colorGreen
                        ];
                        return GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            ref.read(accentColorIndexProvider.notifier).setIndex(i);
                          },
                          child: Column(
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: color,
                                  border: Border.all(
                                    color: selected ? Colors.white : Colors.transparent,
                                    width: 3,
                                  ),
                                  boxShadow: selected
                                      ? [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 14, spreadRadius: 2)]
                                      : [],
                                ),
                                child: selected
                                    ? const Icon(Icons.check_rounded, color: Colors.white, size: 20)
                                    : null,
                              ),
                              const SizedBox(height: 6),
                              Text(labels[i], style: TextStyle(color: selected ? Colors.white : Colors.white38, fontSize: 10)),
                            ],
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          // ── 4. HIDDEN VIDEOS ─────────────────────────────────────
          _sectionHeader(Icons.hide_source_rounded, '${l10n.hiddenVideos} (${hiddenIds.length})', accentColor),
          _card(
            children: [
              Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  shape: const Border(),
                  collapsedShape: const Border(),
                  iconColor: accentColor,
                  collapsedIconColor: Colors.white54,
                  leading: Icon(Icons.visibility_off_outlined, color: Colors.white54, size: 20),
                  title: Text(
                    hiddenIds.isEmpty ? l10n.noHiddenVideos : '${hiddenIds.length} ${l10n.hiddenVideos}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  children: hiddenIds.isEmpty
                      ? [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              l10n.noHiddenVideos,
                              style: const TextStyle(color: Colors.white38, fontSize: 13),
                            ),
                          ),
                        ]
                      : hiddenIds.map((id) => _HiddenVideoTile(id: id)).toList(),
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          // ── 5. CACHE & DATA ──────────────────────────────────────
          _sectionHeader(Icons.cleaning_services_rounded, l10n.clearCache, accentColor),
          _card(
            children: [
              ListTile(
                leading: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.delete_sweep_rounded, color: Colors.redAccent, size: 22),
                ),
                title: Text(l10n.clearCache, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                subtitle: Text(l10n.clearCacheDesc, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                trailing: const Icon(Icons.chevron_right_rounded, color: Colors.white30),
                onTap: () async {
                  HapticFeedback.mediumImpact();
                  final messenger = ScaffoldMessenger.of(context);
                  try {
                    final tempDir = await getTemporaryDirectory();
                    if (tempDir.existsSync()) {
                      tempDir.deleteSync(recursive: true);
                      await tempDir.create();
                    }
                    messenger.showSnackBar(
                      SnackBar(
                        content: Row(children: [
                          const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                          const SizedBox(width: 8),
                          Text(l10n.cacheCleared),
                        ]),
                        backgroundColor: const Color(0xFF1E1E1E),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  } catch (_) {
                    messenger.showSnackBar(
                      SnackBar(content: Text(l10n.cacheClearError)),
                    );
                  }
                },
              ),
            ],
          ),

          const SizedBox(height: 22),

          // ── 6. ABOUT ─────────────────────────────────────────────
          _sectionHeader(Icons.info_outline_rounded, l10n.about, accentColor),
          _card(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        gradient: LinearGradient(
                          colors: [accentColor, AppTheme.accentBlue],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [BoxShadow(color: accentColor.withValues(alpha: 0.35), blurRadius: 20, spreadRadius: 4)],
                      ),
                      child: const Icon(Icons.movie_filter_rounded, color: Colors.white, size: 36),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'My Reels',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        shadows: [Shadow(color: accentColor.withValues(alpha: 0.6), blurRadius: 12)],
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text('Versiyon 1.0.0', style: TextStyle(color: Colors.white38, fontSize: 12)),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: const Text(
                        '© 2026 My Reels  •  Tüm hakları saklıdır',
                        style: TextStyle(color: Colors.white30, fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────────

  Widget _langTile(BuildContext context, WidgetRef ref, {
    required String code,
    required String name,
    required String flag,
    required String current,
    required Color accent,
  }) {
    final isSelected = current == code;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          ref.read(appLocaleProvider.notifier).setLocale(code);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? accent.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? accent : Colors.white12,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Text(flag, style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 4),
              Text(
                name,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white60,
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(IconData icon, String title, Color accentColor) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Row(
        children: [
          Icon(icon, color: accentColor, size: 14),
          const SizedBox(width: 6),
          Text(
            title.toUpperCase(),
            style: TextStyle(
              color: accentColor,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.9,
            ),
          ),
        ],
      ),
    );
  }

  Widget _card({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }

  Widget _switchTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required Color accentColor,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      secondary: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(9),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.white38, fontSize: 12)),
      value: value,
      activeTrackColor: accentColor,
      onChanged: onChanged,
    );
  }

  Widget _fitOption({
    required String label,
    required String sublabel,
    required IconData icon,
    required bool selected,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected ? accentColor.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? accentColor : Colors.white12,
            width: selected ? 1.5 : 1,
          ),
          boxShadow: selected
              ? [BoxShadow(color: accentColor.withValues(alpha: 0.2), blurRadius: 10)]
              : [],
        ),
        child: Column(
          children: [
            Icon(icon, color: selected ? accentColor : Colors.white38, size: 22),
            const SizedBox(height: 6),
            Text(label, style: TextStyle(color: selected ? Colors.white : Colors.white60, fontWeight: FontWeight.w600, fontSize: 12)),
            const SizedBox(height: 2),
            Text(sublabel, style: TextStyle(color: selected ? accentColor.withValues(alpha: 0.8) : Colors.white30, fontSize: 9)),
          ],
        ),
      ),
    );
  }
}

// ── Hidden Video Tile ──────────────────────────────────────────────────────

class _HiddenVideoTile extends ConsumerWidget {
  final String id;
  const _HiddenVideoTile({required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final galleryService = ref.read(galleryServiceProvider);
    final l10n = AppLocalizations.of(context);

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
                await ref.read(hiddenIdsProvider.notifier).unhide(id);
                ref.read(feedProvider.notifier).initialize();
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
              borderRadius: BorderRadius.circular(8),
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
            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
          ),
          subtitle: Text(
            videoItem.formattedDuration,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
          trailing: TextButton.icon(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              await ref.read(hiddenIdsProvider.notifier).unhide(id);
              ref.read(feedProvider.notifier).initialize();
              messenger.showSnackBar(
                SnackBar(
                  content: Row(children: [
                    const Icon(Icons.visibility_rounded, color: Colors.white, size: 16),
                    const SizedBox(width: 8),
                    Text(l10n.videoRestored),
                  ]),
                  backgroundColor: const Color(0xFF1E1E1E),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            icon: const Icon(Icons.visibility_rounded, size: 16, color: AppTheme.accentBlue),
            label: Text(l10n.restore, style: const TextStyle(color: AppTheme.accentBlue, fontSize: 12)),
          ),
        );
      },
    );
  }
}
