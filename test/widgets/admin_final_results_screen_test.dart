import 'package:devfest_treasure_hunt/data/datasources/mock_local_data_source.dart';
import 'package:devfest_treasure_hunt/data/repositories/mock_app_repository.dart';
import 'package:devfest_treasure_hunt/domain/entities/participant.dart';
import 'package:devfest_treasure_hunt/state/app_controller.dart';
import 'package:devfest_treasure_hunt/state/app_scope.dart';
import 'package:devfest_treasure_hunt/ui/screens/admin/admin_final_results_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late MockAppRepository repository;
  late AppController controller;

  setUp(() async {
    final dataSource = MockLocalDataSource(seedData: false);
    await dataSource.initialize();
    repository = MockAppRepository(dataSource);
    controller = AppController(
      treasureRepository: repository,
      participantRepository: repository,
      leaderboardRepository: repository,
      eventRepository: repository,
      resetStore: dataSource.reset,
      attemptRepository: repository,
      enableElapsedTicker: false,
    );
    await controller.initialize();
  });

  tearDown(() => controller.dispose());

  Future<void> pumpScreen(WidgetTester tester) => tester.pumpWidget(
    AppScope(
      controller: controller,
      child: const MaterialApp(home: AdminFinalResultsScreen()),
    ),
  );

  testWidgets('shows a placeholder while there are no finalists', (
    tester,
  ) async {
    await pumpScreen(tester);
    await tester.pump();

    expect(find.text('Aún no hay finalistas'), findsOneWidget);
    expect(find.byKey(const Key('admin-finalists-empty')), findsOneWidget);
  });

  testWidgets('shows the highest score and earliest finisher as leader', (
    tester,
  ) async {
    final startedAt = DateTime(2026, 10, 9, 8);
    final later = await repository.createParticipant(
      id: 'later',
      name: 'Later',
      nickname: 'later',
      startedAt: startedAt,
    );
    final earlier = await repository.createParticipant(
      id: 'earlier',
      name: 'Earlier',
      nickname: 'earlier',
      startedAt: startedAt,
    );
    const gyms = ['1', '2', '3', '4', '5', '6', '7', '8'];
    await repository.updateParticipant(
      later.copyWith(
        status: ParticipantStatus.completed,
        completedAt: DateTime(2026, 10, 10, 12),
        discoveredTreasureIds: gyms,
        medals: 8,
        points: 900,
      ),
    );
    await repository.updateParticipant(
      earlier.copyWith(
        status: ParticipantStatus.completed,
        completedAt: DateTime(2026, 10, 9, 16),
        discoveredTreasureIds: gyms,
        medals: 8,
        points: 900,
      ),
    );
    await controller.refresh();

    await pumpScreen(tester);
    await tester.pump();

    expect(find.text('Aún no hay finalistas'), findsNothing);
    expect(find.text('Earlier (earlier)'), findsOneWidget);
    expect(find.text('Later (later)'), findsOneWidget);
    expect(find.text('Ganador provisional'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('admin-finalist-earlier')),
        matching: find.text('#1'),
      ),
      findsOneWidget,
    );
  });
}
