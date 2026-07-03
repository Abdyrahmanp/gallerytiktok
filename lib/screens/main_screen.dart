// lib/screens/main_screen.dart
// Shell screen managing the bottom navigation bar.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'feed/feed_screen.dart';
import 'favorites/favorites_screen.dart';
import 'settings/settings_screen.dart';
import '../core/theme/app_theme.dart';
import '../providers/feed_provider.dart';

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
    // If we're on the FeedScreen, make sure we use transparent status/navigation bar styling
    final isFeedActive = _currentIndex == 0;

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
                color: isFeedActive ? Colors.white.withOpacity(0.08) : Colors.white.withOpacity(0.05),
                width: 0.5,
              ),
            ),
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            backgroundColor: isFeedActive ? Colors.black.withOpacity(0.95) : AppTheme.surface,
            selectedItemColor: AppTheme.accent,
            unselectedItemColor: AppTheme.textMuted,
            selectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
            unselectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
            onTap: (index) {
              if (index != _currentIndex) {
                HapticFeedback.selectionClick();
                setState(() {
                  _currentIndex = index;
                });
                
                // Mute/pause control when switching tabs
                if (index != 0) {
                  // If we're leaving the feed screen, let's pause video playback by triggering an empty index or notifying.
                  // Since feed page items check didUpdateWidget/isActive, indexing or local state works well.
                  ref.read(currentFeedIndexProvider.notifier).state = -1;
                } else {
                  // Re-active current page playback
                  ref.read(currentFeedIndexProvider.notifier).state = 0;
                  ref.read(feedProvider.notifier).initialize();
                }
              }
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.movie_outlined),
                activeIcon: Icon(Icons.movie_rounded),
                label: 'Keşfet',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.favorite_outline_rounded),
                activeIcon: Icon(Icons.favorite_rounded),
                label: 'Favoriler',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings_outlined),
                activeIcon: Icon(Icons.settings_rounded),
                label: 'Ayarlar',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
