// test/widget_test.dart
// Basic smoke test for the Nostaljik Reel application.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nostalgic_reel/main.dart';
import 'package:nostalgic_reel/screens/permission_screen.dart';

void main() {
  testWidgets('App starts and displays permission screen by default', (WidgetTester tester) async {
    // Build our app under ProviderScope and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: NostalgicReelApp(),
      ),
    );

    // Verify that the PermissionScreen is shown because permission starts as false/unauthorized by default in tests.
    expect(find.byType(PermissionScreen), findsOneWidget);
    expect(find.text('Galerini Yeniden Keşfet'), findsOneWidget);
  });
}
