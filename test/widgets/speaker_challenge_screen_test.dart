import 'dart:math';

import 'package:devfest_treasure_hunt/data/datasources/mock_local_data_source.dart';
import 'package:devfest_treasure_hunt/data/repositories/mock_app_repository.dart';
import 'package:devfest_treasure_hunt/domain/entities/challenge_question.dart';
import 'package:devfest_treasure_hunt/domain/entities/gym_challenge.dart';
import 'package:devfest_treasure_hunt/state/app_controller.dart';
import 'package:devfest_treasure_hunt/state/app_scope.dart';
import 'package:devfest_treasure_hunt/ui/screens/challenge/challenge_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late MockLocalDataSource dataSource;
  late MockAppRepository repository;
  late AppController controller;

  setUp(() async {
    dataSource = MockLocalDataSource(seedData: false);
    await dataSource.initialize();
    repository = MockAppRepository(dataSource);
    controller = AppController(
      treasureRepository: repository,
      participantRepository: repository,
      leaderboardRepository: repository,
      eventRepository: repository,
      attemptRepository: repository,
      enableElapsedTicker: false,
    );
    await controller.initialize();
    await controller.startParticipant(
      name: 'Nery',
      nickname: 'hall_of_voices_test',
    );
  });

  tearDown(() => controller.dispose());

  test('Hall of Voices uses sixteen written-answer speaker riddles', () {
    final speakerGym = controller.treasures.firstWhere(
      (item) => item.id == 'gym-speaker',
    );
    final challenge = speakerGym.challenge!;

    expect(challenge.type, ChallengeType.riddle);
    expect(challenge.questionsRequired, 2);
    expect(challenge.questionBank, hasLength(16));
    expect(
      challenge.questionBank.every((question) => question.options.isEmpty),
      isTrue,
    );
  });

  testWidgets('participant writes two random names to earn Hall of Voices', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final speakerGym = controller.treasures.firstWhere(
      (item) => item.id == 'gym-speaker',
    );
    final shuffled = List<ChallengeQuestion>.of(
      speakerGym.challenge!.questionBank,
    )..shuffle(Random(71));

    await tester.pumpWidget(
      AppScope(
        controller: controller,
        child: MaterialApp(
          home: ChallengeScreen(gym: speakerGym, random: Random(71)),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Pregunta 1 de 2'), findsOneWidget);
    expect(find.text(shuffled.first.question), findsOneWidget);
    expect(find.byKey(const Key('speaker-answer-field')), findsOneWidget);
    expect(shuffled.first.options, isEmpty);

    await _writeAnswer(tester, shuffled.first.correctAnswer.toLowerCase());
    expect(find.text('Pregunta 2 de 2'), findsOneWidget);
    expect(find.text(shuffled[1].question), findsOneWidget);

    await _writeAnswer(tester, shuffled[1].correctAnswer);
    expect(find.text('¡Medalla Conquistada!'), findsOneWidget);

    final participant = await repository.getParticipant(
      controller.participant!.id,
    );
    expect(participant!.discoveredTreasureIds, contains('gym-speaker'));
  });
}

Future<void> _writeAnswer(WidgetTester tester, String answer) async {
  await tester.enterText(find.byKey(const Key('speaker-answer-field')), answer);
  await tester.pump();
  await tester.tap(find.text('Enviar respuesta'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
}
