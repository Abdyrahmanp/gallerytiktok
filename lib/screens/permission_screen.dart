// lib/screens/permission_screen.dart
// Explains why permissions are needed and requests them.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/feed_provider.dart';

class PermissionScreen extends ConsumerStatefulWidget {
  const PermissionScreen({super.key});

  @override
  ConsumerState<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends ConsumerState<PermissionScreen> {
  bool _isRequesting = false;

  Future<void> _requestAccess() async {
    setState(() => _isRequesting = true);
    final service = ref.read(galleryServiceProvider);
    final granted = await service.requestPermission();
    if (mounted) {
      setState(() => _isRequesting = false);
      ref.read(permissionGrantedProvider.notifier).state = granted;
      if (!granted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Uygulamanın çalışması için galeri erişimine izin vermelisiniz.'),
            backgroundColor: AppTheme.liked,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon with glow/gradient representation
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppTheme.accent.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.accent.withValues(alpha: 0.3), width: 2),
                ),
                child: const Center(
                  child: Icon(
                    Icons.video_library_rounded,
                    color: AppTheme.accent,
                    size: 48,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              const Text(
                'Galerini Yeniden Keşfet',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              
              Text(
                'Nostaljik Reel, yerel galerindeki unutulmuş videoları TikTok tarzı dikey akışla karşına çıkarır. Başlamak için galeri erişim iznine ihtiyacımız var.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 14,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              if (_isRequesting)
                const CircularProgressIndicator(color: AppTheme.accent)
              else
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _requestAccess,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 4,
                    ),
                    child: const Text(
                      'Galeriye Erişim İzni Ver',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
