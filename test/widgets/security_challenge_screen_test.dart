import 'package:devfest_treasure_hunt/ui/screens/challenge/security_challenge_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('scanned fragments assemble the security code in any order', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    const payloads = ['CU', 'SECURITY:1:SE', 'RE', '26', '20'];
    var nextPayload = 0;
    var completed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: SecurityChallengeScreen(
          scannerBuilder: (_, onDetected) => Center(
            child: ElevatedButton(
              key: const Key('test-security-qr'),
              onPressed: () => onDetected(payloads[nextPayload++]),
              child: const Text('Detectar'),
            ),
          ),
          onCompleted: () async => completed = true,
        ),
      ),
    );

    for (var index = 0; index < payloads.length; index++) {
      await tester.tap(find.byKey(const Key('security-scan-fragment')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('test-security-qr')));
      await tester.pumpAndSettle();
    }

    expect(find.text('5 de 5 fragmentos'), findsOneWidget);
    expect(find.text('SECURE2026'), findsOneWidget);
    final completeButton = tester.widget<FilledButton>(
      find.byKey(const Key('security-complete')),
    );
    expect(completeButton.onPressed, isNotNull);

    await tester.tap(find.byKey(const Key('security-complete')));
    await tester.pump();
    expect(completed, isTrue);
  });

  testWidgets('duplicate and unrelated QR values are ignored', (tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    const payloads = ['SE', 'SE', 'NOT-SECURITY'];
    var nextPayload = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: SecurityChallengeScreen(
          scannerBuilder: (_, onDetected) => Center(
            child: ElevatedButton(
              key: const Key('test-security-qr'),
              onPressed: () => onDetected(payloads[nextPayload++]),
              child: const Text('Detectar'),
            ),
          ),
          onCompleted: () async {},
        ),
      ),
    );

    for (var index = 0; index < payloads.length; index++) {
      await tester.tap(find.byKey(const Key('security-scan-fragment')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('test-security-qr')));
      await tester.pumpAndSettle();
    }

    expect(find.text('1 de 5 fragmentos'), findsOneWidget);
    expect(find.text('SE'), findsWidgets);
    final completeButton = tester.widget<FilledButton>(
      find.byKey(const Key('security-complete')),
    );
    expect(completeButton.onPressed, isNull);
  });
}
