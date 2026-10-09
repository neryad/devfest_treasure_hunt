import 'package:devfest_treasure_hunt/ui/screens/root/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('loading screen uses the DevFest Master app icon', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: SplashScreen()));

    expect(find.byKey(const Key('splash-app-icon')), findsOneWidget);
    expect(find.text('DevFest Master'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
