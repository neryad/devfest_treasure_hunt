import 'dart:math';

import 'package:devfest_treasure_hunt/data/datasources/mock_local_data_source.dart';
import 'package:devfest_treasure_hunt/data/repositories/mock_app_repository.dart';
import 'package:devfest_treasure_hunt/state/app_controller.dart';
import 'package:devfest_treasure_hunt/state/app_scope.dart';
import 'package:devfest_treasure_hunt/ui/screens/challenge/challenge_screen.dart';
import 'package:devfest_treasure_hunt/ui/screens/challenge/pixel_perfect_mini_game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

List<int> _targetsForSeed(int seed, int rounds) {
  final random = Random(seed);
  return List.generate(rounds, (_) {
    random.nextDouble();
    random.nextDouble();
    random.nextDouble();
    final target = random.nextInt(16);
    for (var index = 0; index < 16; index++) {
      if (index == target) continue;
      for (var channel = 0; channel < 3; channel++) {
        random.nextDouble();
        random.nextBool();
      }
    }
    return target;
  });
}

Future<void> _chooseColor(
  WidgetTester tester,
  int index, {
  required bool isLastRound,
}) async {
  await tester.pump(const Duration(milliseconds: 2500));
  await tester.pump();
  await tester.tap(find.byKey(Key('pixel-game-tile-$index')));
  await tester.pump();
  if (!isLastRound) {
    await tester.pump(const Duration(milliseconds: 1100));
  }
}

void main() {
  testWidgets('moves from memorizing to the 16-color selection grid', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: PixelPerfectMiniGame(random: Random(7), onCompleted: (_) {}),
      ),
    );

    expect(find.byKey(const Key('pixel-game-memorize')), findsOneWidget);
    expect(find.text('Memoriza el color exacto…'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 2500));
    await tester.pump();

    expect(find.byKey(const Key('pixel-game-grid')), findsOneWidget);
    expect(find.text('¿Qué tono coincide con el original?'), findsOneWidget);
    for (var index = 0; index < 16; index++) {
      expect(find.byKey(Key('pixel-game-tile-$index')), findsOneWidget);
    }
  });

  testWidgets('five correct colors out of ten earn the medal', (tester) async {
    const seed = 11;
    final targets = _targetsForSeed(seed, 10);
    int? completedHits;
    await tester.pumpWidget(
      MaterialApp(
        home: PixelPerfectMiniGame(
          random: Random(seed),
          onCompleted: (hits) => completedHits = hits,
        ),
      ),
    );

    for (var round = 0; round < 10; round++) {
      final target = targets[round];
      final pick = round < 5 ? target : (target == 0 ? 1 : 0);
      await _chooseColor(tester, pick, isLastRound: round == 9);
    }

    expect(completedHits, 5);
    expect(find.text('5/10'), findsOneWidget);
  });

  testWidgets('fewer than five correct colors allows retry', (tester) async {
    const seed = 19;
    final targets = _targetsForSeed(seed, 10);
    await tester.pumpWidget(
      MaterialApp(
        home: PixelPerfectMiniGame(random: Random(seed), onCompleted: (_) {}),
      ),
    );

    for (var round = 0; round < 10; round++) {
      final target = targets[round];
      final pick = round < 4 ? target : (target == 0 ? 1 : 0);
      await _chooseColor(tester, pick, isLastRound: round == 9);
    }

    expect(find.text('Te faltaron aciertos'), findsOneWidget);
    await tester.tap(find.byKey(const Key('pixel-game-retry')));
    await tester.pump();
    expect(find.byKey(const Key('pixel-game-memorize')), findsOneWidget);
    expect(find.text('Te faltaron aciertos'), findsNothing);
  });

  testWidgets('the Web gym opens Pixel Perfect instead of a trivia', (
    tester,
  ) async {
    final dataSource = MockLocalDataSource(seedData: false);
    await dataSource.initialize();
    final repository = MockAppRepository(dataSource);
    final controller = AppController(
      treasureRepository: repository,
      participantRepository: repository,
      leaderboardRepository: repository,
      eventRepository: repository,
      attemptRepository: repository,
      enableElapsedTicker: false,
    );
    addTearDown(controller.dispose);
    await controller.initialize();
    await controller.startParticipant(name: 'Nery', nickname: 'pixel_player');
    final web = controller.treasures.firstWhere((item) => item.id == 'gym-web');

    await tester.pumpWidget(
      AppScope(
        controller: controller,
        child: MaterialApp(home: ChallengeScreen(gym: web)),
      ),
    );
    await tester.pump();

    expect(find.text('Pixel Perfect'), findsOneWidget);
    expect(find.byType(PixelPerfectMiniGame), findsOneWidget);
    expect(find.text('Enviar respuesta'), findsNothing);

    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });
}
