import 'package:devfest_treasure_hunt/ui/screens/challenge/startup_mini_game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('moves the startup ship between lanes', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: StartupMiniGame(targetScore: 100, onCompleted: () {})),
    );

    expect(find.text('Carril: Centro'), findsOneWidget);

    await tester.tap(find.byKey(const Key('startup-game-move-left')));
    await tester.pump();
    expect(find.text('Carril: Izquierda'), findsOneWidget);
    final fireWhileMisaligned = tester.widget<ElevatedButton>(
      find.byKey(const Key('startup-game-fire')),
    );
    expect(fireWhileMisaligned.onPressed, isNull);
    expect(
      find.text('Muévete a la derecha para alinear el objetivo'),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('startup-game-move-right')));
    await tester.pump();
    expect(find.text('Carril: Centro'), findsOneWidget);
    expect(find.text('¡Objetivo alineado! Dispara tu MVP'), findsOneWidget);
  });

  testWidgets('projectile travels upward before awarding points', (
    tester,
  ) async {
    var completed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: StartupMiniGame(
          targetScore: 10,
          initialRunway: 40,
          onCompleted: () => completed = true,
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('startup-game-fire')));
    await tester.pump();
    expect(find.byKey(const Key('startup-game-projectile')), findsOneWidget);
    expect(find.text('0 / 1'), findsOneWidget);

    final projectile = find.byKey(const Key('startup-game-projectile'));
    final startY = tester.getTopLeft(projectile).dy;
    await tester.pump(const Duration(milliseconds: 250));
    final laterY = tester.getTopLeft(projectile).dy;
    expect(laterY, lessThan(startY - 20));

    await tester.pump(const Duration(milliseconds: 350));
    expect(completed, isTrue);
    expect(find.text('1 / 1'), findsOneWidget);
  });

  testWidgets('missed enemy subtracts runway and advances to another threat', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: StartupMiniGame(
          targetScore: 100,
          initialRunway: 40,
          onCompleted: () {},
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('startup-game-move-left')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('startup-game-miss-enemy')));
    await tester.pump();

    expect(find.text('20 / 40'), findsOneWidget);
    expect(find.textContaining('CHURN'), findsOneWidget);
  });

  testWidgets('enemy moves downward toward the startup ship', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: StartupMiniGame(targetScore: 100, onCompleted: () {})),
    );

    final enemy = find.byKey(const Key('startup-game-enemy'));
    final startY = tester.getTopLeft(enemy).dy;

    await tester.pump(const Duration(milliseconds: 900));

    final laterY = tester.getTopLeft(enemy).dy;
    expect(laterY, greaterThan(startY + 25));
  });

  testWidgets('shows retry state when runway reaches zero', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: StartupMiniGame(
          targetScore: 100,
          initialRunway: 20,
          onCompleted: () {},
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('startup-game-move-left')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('startup-game-miss-enemy')));
    await tester.pump();

    expect(find.text('Tu startup se quedó sin runway'), findsOneWidget);

    await tester.tap(find.text('Reintentar misión'));
    await tester.pump();

    expect(find.text('20 / 20'), findsOneWidget);
    expect(find.text('Tu startup se quedó sin runway'), findsNothing);
  });
}
