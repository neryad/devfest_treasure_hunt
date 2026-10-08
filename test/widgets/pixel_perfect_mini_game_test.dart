import 'dart:math';

import 'package:devfest_treasure_hunt/data/datasources/mock_local_data_source.dart';
import 'package:devfest_treasure_hunt/data/repositories/mock_app_repository.dart';
import 'package:devfest_treasure_hunt/state/app_controller.dart';
import 'package:devfest_treasure_hunt/state/app_scope.dart';
import 'package:devfest_treasure_hunt/ui/screens/challenge/challenge_screen.dart';
import 'package:devfest_treasure_hunt/ui/screens/challenge/pixel_perfect_mini_game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

int _firstTargetForSeed(int seed) {
  final random = Random(seed);
  random.nextDouble();
  random.nextDouble();
  random.nextDouble();
  return random.nextInt(16);
}

void main() {
  testWidgets('moves from memorizing to the 16-color selection grid', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: PixelPerfectMiniGame(
          targetScore: 100,
          random: Random(7),
          onCompleted: () {},
        ),
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

  testWidgets('selecting the exact color completes the target score', (
    tester,
  ) async {
    const seed = 11;
    var completed = false;
    await tester.pumpWidget(
      MaterialApp(
        home: PixelPerfectMiniGame(
          targetScore: 10,
          random: Random(seed),
          onCompleted: () => completed = true,
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 2500));
    await tester.pump();

    await tester.tap(
      find.byKey(Key('pixel-game-tile-${_firstTargetForSeed(seed)}')),
    );
    await tester.pump();

    expect(completed, isTrue);
    expect(find.text('¡Exacto! +10 de validación'), findsOneWidget);
    expect(find.text('1/1'), findsOneWidget);
  });

  testWidgets('a wrong color consumes runway and allows retry', (tester) async {
    const seed = 19;
    final target = _firstTargetForSeed(seed);
    final wrong = target == 0 ? 1 : 0;
    await tester.pumpWidget(
      MaterialApp(
        home: PixelPerfectMiniGame(
          targetScore: 100,
          initialRunway: 20,
          random: Random(seed),
          onCompleted: () {},
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 2500));
    await tester.pump();

    await tester.tap(find.byKey(Key('pixel-game-tile-$wrong')));
    await tester.pump();

    expect(find.text('Te quedaste sin runway'), findsOneWidget);
    await tester.tap(find.byKey(const Key('pixel-game-retry')));
    await tester.pump();
    expect(find.byKey(const Key('pixel-game-memorize')), findsOneWidget);
    expect(find.text('Te quedaste sin runway'), findsNothing);
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
