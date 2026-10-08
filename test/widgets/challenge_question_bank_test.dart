import 'package:devfest_treasure_hunt/data/datasources/mock_local_data_source.dart';
import 'package:devfest_treasure_hunt/data/repositories/mock_app_repository.dart';
import 'package:devfest_treasure_hunt/domain/utils/challenge_question_selector.dart';
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
    final assigned = ChallengeQuestionSelector.select(
      participantId: controller.participant!.id,
      gymId: gym.id,
      bank: gym.challenge!.questionBank,
    )!;

    await tester.pumpWidget(
      AppScope(
        controller: controller,
        child: MaterialApp(home: ChallengeScreen(gym: gym)),
      ),
    );
    await tester.pump();

    expect(find.text(assigned.question), findsOneWidget);
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
}
