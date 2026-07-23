// lib/main.dart
// Application entry point. Initializes Hive database, checks permissions,
// and sets up Riverpod state management with multi-language support.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:photo_manager/photo_manager.dart';

import 'core/constants/app_constants.dart';
import 'core/l10n/app_localizations.dart';
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
    final locale = ref.watch(appLocaleProvider);

    return MaterialApp(
      title: 'My Reels',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      locale: locale,
      supportedLocales: const [
        Locale('tr'),
        Locale('en'),
        Locale('tk'),
        Locale('ru'),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: isPermissionGranted ? const MainScreen() : const PermissionScreen(),
    );
  }
}
