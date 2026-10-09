import 'dart:math';

import 'package:devfest_treasure_hunt/data/datasources/mock_local_data_source.dart';
import 'package:devfest_treasure_hunt/data/repositories/mock_app_repository.dart';
import 'package:devfest_treasure_hunt/state/app_controller.dart';
import 'package:devfest_treasure_hunt/state/app_scope.dart';
import 'package:devfest_treasure_hunt/ui/screens/challenge/challenge_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders the participant assigned question and its metadata', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

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
    await controller.startParticipant(name: 'Nery', nickname: 'bank_test');

    final gym = controller.treasures.firstWhere(
      (item) => item.id == 'gym-android',
    );
    final shuffled = List.of(gym.challenge!.questionBank)..shuffle(Random(17));
    final assigned = shuffled.first;

    await tester.pumpWidget(
      AppScope(
        controller: controller,
        child: MaterialApp(
          home: ChallengeScreen(gym: gym, random: Random(17)),
        ),
      ),
    );
    await tester.pump();

    expect(find.text(assigned.question), findsOneWidget);
    expect(find.text('Pregunta 1 de 4'), findsOneWidget);
    expect(find.text(assigned.hint!), findsNothing);
    for (final option in assigned.options) {
      expect(find.text(option), findsOneWidget);
    }
    if (assigned.codeSnippet != null) {
      expect(find.text(assigned.codeSnippet!), findsOneWidget);
    }

    final wrong = assigned.options.firstWhere(
      (option) => option != assigned.correctAnswer,
    );
    await tester.tap(find.text(wrong));
    await tester.pump();
    await tester.tap(find.text('Enviar respuesta'));
    await tester.pumpAndSettle();

    expect(find.text('Respuesta Incorrecta'), findsOneWidget);
    expect(find.text('Pista: ${assigned.hint}'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });

  testWidgets('the whole challenge scrolls on a phone-sized viewport', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

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
    await controller.startParticipant(name: 'Nery', nickname: 'mobile_test');

    final gym = controller.treasures.firstWhere(
      (item) => item.id == 'gym-android',
    );
    final shuffled = List.of(gym.challenge!.questionBank)..shuffle(Random(17));
    final assigned = shuffled.first;

    await tester.pumpWidget(
      AppScope(
        controller: controller,
        child: MaterialApp(
          home: ChallengeScreen(gym: gym, random: Random(17)),
        ),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text(assigned.question), findsOneWidget);
    final questionCounterTop = tester
        .getTopLeft(find.text('Pregunta 1 de 4'))
        .dy;

    await tester.fling(
      find.byKey(const Key('challenge-screen-scroll')),
      const Offset(0, -500),
      1000,
    );
    await tester.pumpAndSettle();

    expect(find.text('Enviar respuesta'), findsOneWidget);
    final challengeScrollable = find
        .descendant(
          of: find.byKey(const Key('challenge-screen-scroll')),
          matching: find.byType(Scrollable),
        )
        .first;
    expect(
      tester.state<ScrollableState>(challengeScrollable).position.pixels,
      greaterThan(0),
    );
    expect(
      tester.getTopLeft(find.text('Pregunta 1 de 4')).dy,
      lessThan(questionCounterTop),
    );
    expect(
      tester.getBottomRight(find.text('Enviar respuesta')).dy,
      lessThan(640),
    );
    expect(tester.takeException(), isNull);
  });
}
