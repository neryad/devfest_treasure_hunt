import 'package:devfest_treasure_hunt/core/utils/snack_bar_utils.dart';
import 'package:devfest_treasure_hunt/data/datasources/mock_local_data_source.dart';
import 'package:devfest_treasure_hunt/data/repositories/mock_app_repository.dart';
import 'package:devfest_treasure_hunt/domain/entities/attempt.dart';
import 'package:devfest_treasure_hunt/domain/entities/participant.dart';
import 'package:devfest_treasure_hunt/domain/entities/treasure_item.dart';
import 'package:devfest_treasure_hunt/state/app_controller.dart';
import 'package:devfest_treasure_hunt/state/app_scope.dart';
import 'package:devfest_treasure_hunt/ui/screens/challenge/challenge_screen.dart';
import 'package:devfest_treasure_hunt/ui/screens/discovery/manual_code_screen.dart';
import 'package:devfest_treasure_hunt/ui/screens/root/session_gate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _FlakyRepository extends MockAppRepository {
  _FlakyRepository(super.dataSource);

  bool throwOnCreate = false;
  bool throwOnGetByCode = false;
  bool throwOnSaveAttempt = false;

  @override
  Future<Participant> createParticipant({
    required String id,
    required String name,
    required String nickname,
    required DateTime startedAt,
  }) async {
    if (throwOnCreate) throw Exception('network down');
    return super.createParticipant(
      id: id,
      name: name,
      nickname: nickname,
      startedAt: startedAt,
    );
  }

  @override
  Future<TreasureItem?> getByCode(String code) async {
    if (throwOnGetByCode) throw Exception('network down');
    return super.getByCode(code);
  }

  @override
  Future<void> saveAttempt(Attempt attempt) async {
    if (throwOnSaveAttempt) throw Exception('network down');
    return super.saveAttempt(attempt);
  }
}

AppController _controller(_FlakyRepository repo, MockLocalDataSource ds) =>
    AppController(
      treasureRepository: repo,
      participantRepository: repo,
      leaderboardRepository: repo,
      eventRepository: repo,
      attemptRepository: repo,
      enableElapsedTicker: false,
    );

void main() {
  testWidgets('registration failure shows snackbar and re-enables button', (
    tester,
  ) async {
    final ds = MockLocalDataSource(seedData: false);
    await ds.initialize();
    final repo = _FlakyRepository(ds)..throwOnCreate = true;
    final controller = _controller(repo, ds);
    addTearDown(controller.dispose);
    await controller.initialize();

    await tester.pumpWidget(
      AppScope(
        controller: controller,
        child: const MaterialApp(home: SessionGate()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Tu Nombre'),
      'Nery',
    );
    await tester.enterText(
      find.widgetWithText(
        TextFormField,
        'Nickname / Alias para el Ranking',
      ),
      'nery',
    );
    await tester.ensureVisible(find.text('¡Comenzar aventura!'));
    await tester.pump();
    await tester.tap(find.text('¡Comenzar aventura!'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text(networkErrorMessage), findsOneWidget);

    final button = tester.widget<ElevatedButton>(
      find
          .ancestor(
            of: find.text('¡Comenzar aventura!'),
            matching: find.byType(ElevatedButton),
          )
          .first,
    );
    expect(button.onPressed, isNotNull);
  });

  testWidgets('manual code failure shows snackbar and re-enables button', (
    tester,
  ) async {
    final ds = MockLocalDataSource(seedData: false);
    await ds.initialize();
    final repo = _FlakyRepository(ds)..throwOnGetByCode = true;
    final controller = _controller(repo, ds);
    addTearDown(controller.dispose);
    await controller.initialize();
    await controller.startParticipant(name: 'Nery', nickname: 'nery');

    await tester.pumpWidget(
      AppScope(
        controller: controller,
        child: const MaterialApp(home: ManualCodeScreen()),
      ),
    );
    await tester.pump();

    await tester.enterText(find.byType(TextField), 'ANDROID-MASTER');
    await tester.tap(find.text('Validar gimnasio'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text(networkErrorMessage), findsOneWidget);

    final button = tester.widget<ElevatedButton>(
      find.byType(ElevatedButton).first,
    );
    expect(button.onPressed, isNotNull);
  });

  testWidgets('challenge submit failure shows snackbar and re-enables form', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final ds = MockLocalDataSource();
    await ds.initialize();
    final repo = _FlakyRepository(ds)..throwOnSaveAttempt = true;
    final controller = _controller(repo, ds);
    addTearDown(controller.dispose);
    await controller.initialize();
    await controller.startParticipant(name: 'Nery', nickname: 'nery_challenge');

    final gym = controller.treasures.firstWhere(
      (t) => t.challenge?.hasOptions == true,
    );
    await tester.pumpWidget(
      AppScope(
        controller: controller,
        child: MaterialApp(home: ChallengeScreen(gym: gym)),
      ),
    );
    await tester.pump();

    await tester.tap(find.text(gym.challenge!.options!.first));
    await tester.pump();
    await tester.tap(find.text('Enviar respuesta'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text(networkErrorMessage), findsOneWidget);
    expect(find.text('Enviar respuesta'), findsOneWidget);

    final button = tester.widget<ElevatedButton>(
      find
          .ancestor(
            of: find.text('Enviar respuesta'),
            matching: find.byType(ElevatedButton),
          )
          .first,
    );
    expect(button.onPressed, isNotNull);

    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  });
}
