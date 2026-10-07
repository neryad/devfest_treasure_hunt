import 'package:devfest_treasure_hunt/data/datasources/mock_local_data_source.dart';
import 'package:devfest_treasure_hunt/data/repositories/mock_app_repository.dart';
import 'package:devfest_treasure_hunt/domain/entities/participant.dart';
import 'package:devfest_treasure_hunt/domain/entities/treasure_item.dart';
import 'package:devfest_treasure_hunt/state/app_controller.dart';
import 'package:devfest_treasure_hunt/state/app_scope.dart';
import 'package:devfest_treasure_hunt/ui/screens/root/session_gate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _FlakyRepository extends MockAppRepository {
  _FlakyRepository(super.dataSource);

  bool failStaticLoad = false;
  bool orphanCurrent = false;

  @override
  Future<List<TreasureItem>> getTreasures() async {
    if (failStaticLoad) throw Exception('network down');
    return super.getTreasures();
  }

  @override
  Future<Participant?> getParticipant(String id) async {
    if (orphanCurrent) return null;
    return super.getParticipant(id);
  }
}

AppController _controller(_FlakyRepository repo, MockLocalDataSource ds) =>
    AppController(
      treasureRepository: repo,
      participantRepository: repo,
      leaderboardRepository: repo,
      eventRepository: repo,
      resetStore: ds.reset,
      attemptRepository: repo,
      enableElapsedTicker: false,
    );

void main() {
  testWidgets('initialize failure shows retry instead of infinite splash', (
    tester,
  ) async {
    final ds = MockLocalDataSource(seedData: false);
    await ds.initialize();
    final repo = _FlakyRepository(ds)..failStaticLoad = true;
    final controller = _controller(repo, ds);
    addTearDown(controller.dispose);

    await controller.initialize();
    expect(controller.initFailed, isTrue);

    await tester.pumpWidget(
      AppScope(
        controller: controller,
        child: const MaterialApp(home: SessionGate()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('No se pudo conectar con el evento'), findsOneWidget);

    repo.failStaticLoad = false;
    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();

    expect(controller.initFailed, isFalse);
    expect(find.text('¡Comenzar aventura!'), findsOneWidget);
  });

  test('orphaned session id is cleared and flagged', () async {
    final ds = MockLocalDataSource(seedData: false);
    await ds.initialize();
    final repo = _FlakyRepository(ds);
    await repo.createParticipant(
      id: 'participant-x',
      name: 'X',
      nickname: 'x',
      startedAt: DateTime.now(),
    );
    await repo.setCurrentParticipantId('participant-x');
    repo.orphanCurrent = true;

    final controller = _controller(repo, ds);
    addTearDown(controller.dispose);
    await controller.initialize();

    expect(controller.hasParticipant, isFalse);
    expect(controller.sessionExpired, isTrue);
    expect(await repo.getCurrentParticipantId(), isNull);
  });

  testWidgets('welcome shows a notice after an expired session', (
    tester,
  ) async {
    final ds = MockLocalDataSource(seedData: false);
    await ds.initialize();
    final repo = _FlakyRepository(ds);
    await repo.createParticipant(
      id: 'participant-x',
      name: 'X',
      nickname: 'x',
      startedAt: DateTime.now(),
    );
    await repo.setCurrentParticipantId('participant-x');
    repo.orphanCurrent = true;

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

    expect(
      find.text('Tu sesión anterior ya no existe — regístrate de nuevo.'),
      findsOneWidget,
    );
  });
}
