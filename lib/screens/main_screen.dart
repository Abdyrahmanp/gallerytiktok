// lib/screens/main_screen.dart
// Shell screen managing the bottom navigation bar.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/l10n/app_localizations.dart';
import '../core/theme/app_theme.dart';
import '../providers/feed_provider.dart';
import 'favorites/favorites_screen.dart';
import 'feed/feed_screen.dart';
import 'settings/settings_screen.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    FeedScreen(),
    FavoritesScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isFeedActive = _currentIndex == 0;
    final accentIdx   = ref.watch(accentColorIndexProvider);
    final accentColor = kAccentPalette[accentIdx];
    final l10n        = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: Colors.white.withAlpha(isFeedActive ? 18 : 10),
                width: 0.5,
              ),
            ),
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            backgroundColor: isFeedActive
                ? Colors.black.withAlpha(242)
                : AppTheme.surface,
            selectedItemColor: accentColor,
            unselectedItemColor: AppTheme.textMuted,
            selectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
            unselectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w400),
            onTap: (index) {
              if (index != _currentIndex) {
                HapticFeedback.selectionClick();
                setState(() => _currentIndex = index);
                ref.read(isFeedTabActiveProvider.notifier).state = (index == 0);
              }
            },
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.movie_filter_outlined),
                activeIcon: const Icon(Icons.movie_filter_rounded),
                label: l10n.discover,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.favorite_outline_rounded),
                activeIcon: const Icon(Icons.favorite_rounded),
                label: l10n.favorites,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.settings_outlined),
                activeIcon: const Icon(Icons.settings_rounded),
                label: l10n.settings,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
