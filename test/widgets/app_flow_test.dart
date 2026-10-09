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
        child: const MaterialApp(home: SessionGate()),
      ),
    );
    await tester.pump();
  }

  Future<void> registerDemoUser(WidgetTester tester) async {
    await tester.ensureVisible(find.widgetWithText(TextFormField, 'Tu Nombre'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Tu Nombre'),
      'Demo User',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nickname / Alias para el Ranking'),
      'demo_user',
    );
    await tester.tap(find.text('¡Comenzar aventura!'));
    await tester.pumpAndSettle();
  }

  testWidgets('welcome → register → dashboard shows 0/8', (tester) async {
    await pumpApp(tester);

    expect(find.text('DevFest Master'), findsOneWidget);
    expect(find.text('¡Comenzar aventura!'), findsOneWidget);

    await registerDemoUser(tester);

    expect(find.text('Tu aventura'), findsOneWidget);
    expect(find.text('0 de 8 medallas conseguidas'), findsOneWidget);
    expect(find.text('Introducir código'), findsOneWidget);
  });

  testWidgets('dashboard reflects discoveries in any order', (tester) async {
    await pumpApp(tester);
    await registerDemoUser(tester);

    // Discover outer-of-order treasures through the controller.
    final first = await controller.grantMedal(
      participantId: controller.participant!.id,
      gymId: 'gym-speaker',
    );
    expect(first, StaffActionResult.success);
    await tester.pump();

    expect(find.text('1 de 8 medallas conseguidas'), findsOneWidget);

    await controller.grantMedal(
      participantId: controller.participant!.id,
      gymId: 'gym-ia',
    );
    await tester.pump();

    expect(find.text('2 de 8 medallas conseguidas'), findsOneWidget);

    // The inactive treasure must be rejected.
    await controller.setTreasureActive('gym-security', false);
    final result = await controller.discoverByTreasureId('gym-security');
    expect(result.failure, DiscoverFailure.notActive);
    await tester.pump();

    expect(find.text('2 de 8 medallas conseguidas'), findsOneWidget);
  });

  testWidgets('DevMaster combines dashboard and gym collection', (
    tester,
  ) async {
    await pumpApp(tester);
    await registerDemoUser(tester);

    expect(find.text('DevMaster'), findsWidgets);
    expect(find.text('Inicio'), findsNothing);
    expect(find.text('DevDex'), findsNothing);
    expect(find.text('Retos'), findsNothing);
    expect(find.text('Pistas'), findsNothing);
    expect(find.text('8 Gimnasios Tecnológicos'), findsOneWidget);
    expect(find.text('Ranking'), findsOneWidget);
  });
}
