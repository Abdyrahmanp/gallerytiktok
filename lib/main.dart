// lib/main.dart
// Application entry point. Initializes Hive database, checks permissions,
// and sets up Riverpod state management.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:photo_manager/photo_manager.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'providers/feed_provider.dart';
import 'screens/main_screen.dart';
import 'screens/permission_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize Turkish date formatting locale
  await initializeDateFormatting('tr', null);

  // 2. Initialize Hive and open storage boxes
  await Hive.initFlutter();
  await Hive.openBox<bool>(AppConstants.likedVideosBox);
  await Hive.openBox<bool>(AppConstants.hiddenVideosBox);
  await Hive.openBox<dynamic>(AppConstants.settingsBox);

  // 3. Check current permission status
  bool isGranted = false;
  try {
    final permissionState = await PhotoManager.getPermissionState(
      requestOption: const PermissionRequestOption(),
    );
    isGranted = permissionState.isAuth;
  } catch (e) {
    debugPrint('PhotoManager getPermissionState failed or unsupported platform: $e');
    // On unsupported platforms (e.g. Linux desktop), default to true to allow UI review
    isGranted = true;
  }

  // 4. Set up system UI overlays
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(
    ProviderScope(
      overrides: [
        permissionGrantedProvider.overrideWith((ref) => isGranted),
      ],
      child: const NostalgicReelApp(),
    ),
  );
}

class NostalgicReelApp extends ConsumerWidget {
  const NostalgicReelApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPermissionGranted = ref.watch(permissionGrantedProvider);

    return MaterialApp(
      title: 'Nostaljik Reel',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: isPermissionGranted ? const MainScreen() : const PermissionScreen(),
    );
  }
}
