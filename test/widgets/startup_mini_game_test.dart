import 'dart:math';

import 'package:devfest_treasure_hunt/ui/screens/challenge/startup_mini_game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  StartupMiniGame game({
    int targetScore = 100,
    int initialRunway = 100,
    VoidCallback? onCompleted,
    List<int> randomValues = const [2, 0, 1, 2],
  }) {
    return StartupMiniGame(
      targetScore: targetScore,
      initialRunway: initialRunway,
      onCompleted: onCompleted ?? () {},
      random: _SequenceRandom(randomValues),
    );
  }

  Finder enemiesInLane(int lane) => find.byWidgetPredicate((widget) {
    final key = widget.key;
    return key is ValueKey<String> &&
        key.value.startsWith('startup-game-enemy-$lane-');
  });

  testWidgets('moves the startup ship between lanes', (tester) async {
    await tester.pumpWidget(MaterialApp(home: game()));

    expect(find.text('¡Objetivo alineado! Dispara tu MVP'), findsOneWidget);

    await tester.tap(find.byKey(const Key('startup-game-move-left')));
    await tester.pump();
    final leftButton = tester.widget<OutlinedButton>(
      find.byKey(const Key('startup-game-move-left')),
    );
    expect(leftButton.onPressed, isNull);
    expect(find.text('¡Objetivo alineado! Dispara tu MVP'), findsOneWidget);

    await tester.tap(find.byKey(const Key('startup-game-move-right')));
    await tester.pump();
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
          random: _SequenceRandom(const [2, 0, 1, 2]),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('startup-game-fire')));
    await tester.pump();
    expect(find.byKey(const Key('startup-game-projectile')), findsOneWidget);
    expect(find.text('0/1'), findsOneWidget);

    final projectile = find.byKey(const Key('startup-game-projectile'));
    final startY = tester.getTopLeft(projectile).dy;
    await tester.pump(const Duration(milliseconds: 250));
    final laterY = tester.getTopLeft(projectile).dy;
    expect(laterY, lessThan(startY - 20));

    await tester.pump(const Duration(milliseconds: 350));
    expect(completed, isTrue);
    expect(find.text('1/1'), findsOneWidget);
  });

  testWidgets('enemy keeps moving while the MVP projectile is in flight', (
    tester,
  ) async {
    await tester.pumpWidget(MaterialApp(home: game()));

    final enemy = enemiesInLane(1);
    final startY = tester.getTopLeft(enemy).dy;

    await tester.tap(find.byKey(const Key('startup-game-fire')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.byKey(const Key('startup-game-projectile')), findsOneWidget);
    expect(tester.getTopLeft(enemy).dy, greaterThan(startY + 5));
  });

  testWidgets('a lane can contain two enemies and each shot removes one', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: game(randomValues: const [3, 0, 0, 1, 0])),
    );

    expect(enemiesInLane(0), findsNWidgets(2));
    expect(enemiesInLane(1), findsOneWidget);
    expect(enemiesInLane(2), findsOneWidget);

    final rightEnemy = enemiesInLane(2);
    await tester.tap(enemiesInLane(0).first);
    await tester.pump();
    await tester.tap(find.byKey(const Key('startup-game-fire')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    final duringShotY = tester.getTopLeft(rightEnemy).dy;
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.byKey(const Key('startup-game-enemy-0-1')), findsNothing);
    expect(enemiesInLane(0), findsOneWidget);
    expect(enemiesInLane(1), findsOneWidget);
    expect(enemiesInLane(2), findsOneWidget);
    expect(tester.getTopLeft(rightEnemy).dy, greaterThan(duringShotY + 5));

    final fireButton = tester.widget<ElevatedButton>(
      find.byKey(const Key('startup-game-fire')),
    );
    expect(fireButton.onPressed, isNotNull);
  });

  testWidgets('enemies in the same lane keep their vertical separation', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: game(randomValues: const [1, 0, 0])),
    );

    final upperEnemy = find.byKey(const Key('startup-game-enemy-0-0'));
    final lowerEnemy = find.byKey(const Key('startup-game-enemy-0-1'));
    expect(upperEnemy, findsOneWidget);
    expect(lowerEnemy, findsOneWidget);

    await tester.pump(const Duration(milliseconds: 4000));

    final separation =
        tester.getTopLeft(lowerEnemy).dy - tester.getTopLeft(upperEnemy).dy;
    expect(separation, greaterThanOrEqualTo(40));
  });

  testWidgets('missed enemy subtracts runway and advances to another threat', (
    tester,
  ) async {
    await tester.pumpWidget(MaterialApp(home: game(initialRunway: 40)));

    await tester.tap(find.byKey(const Key('startup-game-move-left')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('startup-game-miss-enemy')));
    await tester.pump();

    expect(find.text('20'), findsOneWidget);
    expect(find.textContaining('NO CASH'), findsOneWidget);
  });

  testWidgets('enemy moves downward toward the startup ship', (tester) async {
    await tester.pumpWidget(MaterialApp(home: game()));

    final enemy = enemiesInLane(1);
    final startY = tester.getTopLeft(enemy).dy;

    await tester.pump(const Duration(milliseconds: 900));

    final laterY = tester.getTopLeft(enemy).dy;
    expect(laterY, greaterThan(startY + 25));
  });

  testWidgets('shows retry state when runway reaches zero', (tester) async {
    await tester.pumpWidget(MaterialApp(home: game(initialRunway: 20)));

    await tester.tap(find.byKey(const Key('startup-game-move-left')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('startup-game-miss-enemy')));
    await tester.pump();

    expect(find.text('Te quedaste sin runway'), findsOneWidget);

    await tester.tap(find.text('Reintentar'));
    await tester.pump();

    expect(find.text('20'), findsOneWidget);
    expect(find.text('Te quedaste sin runway'), findsNothing);
  });
}

class _SequenceRandom implements Random {
  _SequenceRandom(this._values);

  final List<int> _values;
  int _index = 0;

  @override
  bool nextBool() => nextInt(2) == 0;

  @override
  double nextDouble() => nextInt(1000) / 1000;

  @override
  int nextInt(int max) {
    if (_index >= _values.length) return 0;
    return _values[_index++] % max;
  }
}
