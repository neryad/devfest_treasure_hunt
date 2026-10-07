import 'package:devfest_treasure_hunt/data/datasources/mock_local_data_source.dart';
import 'package:devfest_treasure_hunt/data/repositories/mock_app_repository.dart';
import 'package:devfest_treasure_hunt/state/app_controller.dart';
import 'package:devfest_treasure_hunt/state/app_scope.dart';
import 'package:devfest_treasure_hunt/ui/screens/admin/admin_dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late MockAppRepository repository;
  late AppController controller;

  setUp(() async {
    final dataSource = MockLocalDataSource(seedData: false);
    await dataSource.initialize();
    repository = MockAppRepository(dataSource);
    await repository.createParticipant(
      id: 'participant-admin-ui',
      name: 'Admin UI',
      nickname: 'admin_ui',
      startedAt: DateTime.now(),
    );
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
    controller.signInAdmin('admin', 'devfest2026');
  });

  tearDown(() => controller.dispose());

  testWidgets('staff can grant a medal from participant detail', (
    tester,
  ) async {
    await tester.pumpWidget(
      AppScope(
        controller: controller,
        child: const MaterialApp(home: AdminDashboardScreen()),
      ),
    );
    await tester.pump();

    await tester.scrollUntilVisible(
      find.byKey(const Key('admin-participant-search')),
      500,
    );
    await tester.enterText(
      find.byKey(const Key('admin-participant-search')),
      'admin_ui',
    );
    await tester.pump();
    await tester.tap(find.text('Admin UI (admin_ui)'));
    await tester.pumpAndSettle();

    expect(find.text('Detalle de participante'), findsOneWidget);

    await tester.tap(find.text('Otorgar Android'));
    await tester.pumpAndSettle();

    final updated = await repository.getParticipant('participant-admin-ui');
    expect(updated!.discoveredTreasureIds, contains('gym-android'));
    expect(updated.points, 100);
    expect(find.textContaining('1/8 medallas'), findsOneWidget);
  });

  testWidgets('staff can see gym manual codes and qr values', (tester) async {
    await tester.pumpWidget(
      AppScope(
        controller: controller,
        child: const MaterialApp(home: AdminDashboardScreen()),
      ),
    );
    await tester.pump();

    expect(
      find.textContaining('Codigo manual: ANDROID-MASTER'),
      findsOneWidget,
    );
    expect(find.textContaining('QR: DEVFEST-GYM-ANDROID'), findsOneWidget);
  });

  testWidgets('staff can copy ranking csv from the ranking section', (
    tester,
  ) async {
    await tester.pumpWidget(
      AppScope(
        controller: controller,
        child: const MaterialApp(home: AdminDashboardScreen()),
      ),
    );
    await tester.pump();

    expect(find.text('Copiar ranking CSV'), findsOneWidget);
  });
}
