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
    controller.signInAdmin('admin', 'CafecitoConCodigo!2026');
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

  testWidgets('staff can see gym manual codes', (tester) async {
    await tester.pumpWidget(
      AppScope(
        controller: controller,
        child: const MaterialApp(home: AdminDashboardScreen()),
      ),
    );
    await tester.pump();

    await tester.scrollUntilVisible(
      find.textContaining('Codigo manual: ANDROID-MASTER'),
      500,
    );
    expect(
      find.textContaining('Codigo manual: ANDROID-MASTER'),
      findsOneWidget,
    );
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

  testWidgets('staff can adjust participant points from detail', (
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

    await tester.tap(find.text('Ajustar puntos'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('admin-points-delta')), '50');
    await tester.pump();
    await tester.tap(find.text('Aplicar ajuste'));
    await tester.pumpAndSettle();

    expect(find.textContaining('50 pts'), findsOneWidget);
  });

  testWidgets('staff can validate community signal from participant detail', (
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

    expect(find.text('Validar Community Signal'), findsOneWidget);

    await tester.tap(find.text('Validar Community Signal'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Validar evidencia'));
    await tester.pumpAndSettle();

    final updated = await repository.getParticipant('participant-admin-ui');
    expect(updated!.discoveredTreasureIds, contains('gym-community'));
    expect(updated.points, 100);
    expect(find.textContaining('1/8 medallas'), findsOneWidget);
    expect(find.text('Validar Community Signal'), findsNothing);
  });

  testWidgets('staff sees reason when granting an inactive gym', (
    tester,
  ) async {
    await controller.setTreasureActive('gym-android', false);

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

    await tester.tap(find.text('Otorgar Android'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('No se pudo otorgar: gimnasio inactivo'), findsOneWidget);
  });

  testWidgets(
    'participant detail sheet closes when the participant disappears',
    (tester) async {
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

      await controller.resetDemo();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(tester.takeException(), isNull);
      expect(find.text('Detalle de participante'), findsNothing);
      expect(find.text('El participante ya no existe'), findsOneWidget);
    },
  );

  testWidgets('pull to refresh reloads participants and metrics', (
    tester,
  ) async {
    await tester.pumpWidget(
      AppScope(
        controller: controller,
        child: const MaterialApp(home: AdminDashboardScreen()),
      ),
    );
    await tester.pump();

    await repository.createParticipant(
      id: 'participant-refresh',
      name: 'Nuevo',
      nickname: 'nuevo',
      startedAt: DateTime.now(),
    );

    await tester
        .widget<RefreshIndicator>(find.byType(RefreshIndicator))
        .onRefresh();
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('Nuevo (nuevo)'), 500);
    expect(find.text('Nuevo (nuevo)'), findsOneWidget);
  });

  testWidgets('staff can pause and resume the event from the panel', (
    tester,
  ) async {
    await tester.pumpWidget(
      AppScope(
        controller: controller,
        child: const MaterialApp(home: AdminDashboardScreen()),
      ),
    );
    await tester.pump();

    expect(find.text('Estado del evento'), findsOneWidget);

    await tester.tap(find.byKey(const Key('admin-event-paused')));
    await tester.pumpAndSettle();
    expect(find.text('¿Pausar el evento?'), findsOneWidget);
    await tester.tap(find.text('Pausar'));
    await tester.pumpAndSettle();

    expect(controller.eventActive, isFalse);

    await tester.tap(find.byKey(const Key('admin-event-paused')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reanudar'));
    await tester.pumpAndSettle();

    expect(controller.eventActive, isTrue);
  });

  testWidgets('reset button is disabled when connected to Firestore', (
    tester,
  ) async {
    await tester.pumpWidget(
      AppScope(
        controller: controller,
        child: const MaterialApp(home: AdminDashboardScreen()),
      ),
    );
    await tester.pump();

    final button = tester.widget<IconButton>(
      find.widgetWithIcon(IconButton, Icons.restart_alt_rounded),
    );
    expect(button.onPressed, isNull);
  });

  testWidgets('reset stays disabled in offline mode until RESET is typed', (
    tester,
  ) async {
    final ds = MockLocalDataSource(seedData: false);
    await ds.initialize();
    final repo = MockAppRepository(ds);
    await repo.createParticipant(
      id: 'participant-offline',
      name: 'Offline',
      nickname: 'offline',
      startedAt: DateTime.now(),
    );
    final offlineController = AppController(
      treasureRepository: repo,
      participantRepository: repo,
      leaderboardRepository: repo,
      eventRepository: repo,
      resetStore: ds.reset,
      attemptRepository: repo,
      enableElapsedTicker: false,
      offline: true,
    );
    addTearDown(offlineController.dispose);
    await offlineController.initialize();

    await tester.pumpWidget(
      AppScope(
        controller: offlineController,
        child: const MaterialApp(home: AdminDashboardScreen()),
      ),
    );
    await tester.pump();

    final resetButton = tester.widget<IconButton>(
      find.widgetWithIcon(IconButton, Icons.restart_alt_rounded),
    );
    expect(resetButton.onPressed, isNotNull);

    await tester.tap(find.byIcon(Icons.restart_alt_rounded));
    await tester.pumpAndSettle();

    var confirmButton = tester.widget<TextButton>(
      find.widgetWithText(TextButton, 'Resetear'),
    );
    expect(confirmButton.onPressed, isNull);

    await tester.enterText(
      find.byKey(const Key('admin-reset-confirm')),
      'reset',
    );
    await tester.pump();
    confirmButton = tester.widget<TextButton>(
      find.widgetWithText(TextButton, 'Resetear'),
    );
    expect(confirmButton.onPressed, isNull);

    await tester.enterText(
      find.byKey(const Key('admin-reset-confirm')),
      'RESET',
    );
    await tester.pump();
    confirmButton = tester.widget<TextButton>(
      find.widgetWithText(TextButton, 'Resetear'),
    );
    expect(confirmButton.onPressed, isNotNull);
  });
}
