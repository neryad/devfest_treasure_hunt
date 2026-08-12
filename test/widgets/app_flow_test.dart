import 'package:devfest_treasure_hunt/data/datasources/mock_local_data_source.dart';
import 'package:devfest_treasure_hunt/data/repositories/mock_app_repository.dart';
import 'package:devfest_treasure_hunt/domain/use_cases/discover_treasure_use_case.dart';
import 'package:devfest_treasure_hunt/state/app_controller.dart';
import 'package:devfest_treasure_hunt/state/app_scope.dart';
import 'package:devfest_treasure_hunt/ui/screens/root/session_gate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppController controller;

  setUp(() async {
    final dataSource = MockLocalDataSource();
    await dataSource.initialize();
    final repo = MockAppRepository(dataSource);
    controller = AppController(
      treasureRepository: repo,
      participantRepository: repo,
      leaderboardRepository: repo,
      eventRepository: repo,
      resetStore: dataSource.reset,
      enableElapsedTicker: false,
    );
    await controller.initialize();
  });

  tearDown(() {
    controller.dispose();
  });

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(
      AppScope(
        controller: controller,
        child: const MaterialApp(
          home: SessionGate(),
        ),
      ),
    );
    await tester.pump();
  }

  Future<void> registerDemoUser(WidgetTester tester) async {
    await tester.ensureVisible(find.text('Comenzar aventura'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Comenzar aventura'));
    await tester.pumpAndSettle();

    expect(find.text('Registro de participante'), findsOneWidget);

    await tester.enterText(
        find.widgetWithText(TextFormField, 'Nombre'), 'Demo User');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Nickname / Alias'), 'demo_user');
    await tester.tap(find.text('Iniciar aventura'));
    await tester.pumpAndSettle();
  }

  testWidgets('welcome → register → dashboard shows 0/10', (tester) async {
    await pumpApp(tester);

    expect(find.text('DevFest 2026'), findsOneWidget);
    expect(find.text('Treasure Hunt'), findsOneWidget);
    expect(find.text('Comenzar aventura'), findsOneWidget);

    await registerDemoUser(tester);

    expect(find.text('Tu aventura'), findsOneWidget);
    expect(find.text('0 / 10 encontrados'), findsOneWidget);
    expect(find.text('Encontrar tesoro'), findsOneWidget);
  });

  testWidgets('dashboard reflects discoveries in any order', (tester) async {
    await pumpApp(tester);
    await registerDemoUser(tester);

    // Discover outer-of-order treasures through the controller.
    final first = await controller.discoverByTreasureId('treasure-007');
    expect(first.isSuccess, isTrue);
    await tester.pump();

    expect(find.text('1 / 10 encontrados'), findsOneWidget);

    await controller.discoverByTreasureId('treasure-002');
    await tester.pump();

    expect(find.text('2 / 10 encontrados'), findsOneWidget);

    // The inactive treasure must be rejected.
    final result =
        await controller.discoverByTreasureId('treasure-003');
    expect(result.failure, DiscoverFailure.notActive);
    await tester.pump();

    expect(find.text('2 / 10 encontrados'), findsOneWidget);
  });

  testWidgets('clues tab unlocks when a treasure is discovered', (tester) async {
    await pumpApp(tester);
    await registerDemoUser(tester);

    await controller.discoverByTreasureId('treasure-001');
    await tester.pump();

    await tester.tap(find.text('Pistas'));
    await tester.pumpAndSettle();

    expect(find.text('1 de 10 pistas desbloqueadas'), findsOneWidget);
  });
}