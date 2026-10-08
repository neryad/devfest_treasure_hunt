import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:devfest_treasure_hunt/data/datasources/mock_local_data_source.dart';
import 'package:devfest_treasure_hunt/data/repositories/mock_app_repository.dart';
import 'package:devfest_treasure_hunt/state/app_controller.dart';
import 'package:devfest_treasure_hunt/state/app_scope.dart';
import 'package:devfest_treasure_hunt/ui/screens/challenge/challenge_screen.dart';
import 'package:devfest_treasure_hunt/ui/screens/treasures/treasures_screen.dart';

const _unavailableMessage =
    'No disponible todavía: este gimnasio está desactivado.';

AppController _controller(MockAppRepository repo, MockLocalDataSource ds) =>
    AppController(
      treasureRepository: repo,
      participantRepository: repo,
      leaderboardRepository: repo,
      eventRepository: repo,
      resetStore: ds.reset,
      attemptRepository: repo,
      enableElapsedTicker: false,
    );

Future<void> _pumpScreen(WidgetTester tester, AppController controller) async {
  await tester.pumpWidget(
    AppScope(
      controller: controller,
      child: const MaterialApp(
        home: Scaffold(body: TreasuresScreen()),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('tap on a deactivated gym shows snackbar without navigating', (
    tester,
  ) async {
    final ds = MockLocalDataSource(seedData: false);
    await ds.initialize();
    final repo = MockAppRepository(ds);
    final controller = _controller(repo, ds);
    addTearDown(controller.dispose);
    await controller.initialize();

    await repo.setTreasureActive('gym-android', false);

    await _pumpScreen(tester, controller);

    await tester.tap(find.text('Gimnasio #01'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text(_unavailableMessage), findsOneWidget);
    expect(find.byType(ChallengeScreen), findsNothing);
  });

  testWidgets('tap on an active gym opens the challenge screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final ds = MockLocalDataSource(seedData: false);
    await ds.initialize();
    final repo = MockAppRepository(ds);
    final controller = _controller(repo, ds);
    addTearDown(controller.dispose);
    await controller.initialize();

    await _pumpScreen(tester, controller);

    await tester.tap(find.text('Gimnasio #01'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(ChallengeScreen), findsOneWidget);
  });

  testWidgets('pull to refresh marks a deactivated gym as unavailable', (
    tester,
  ) async {
    final ds = MockLocalDataSource(seedData: false);
    await ds.initialize();
    final repo = MockAppRepository(ds);
    final controller = _controller(repo, ds);
    addTearDown(controller.dispose);
    await controller.initialize();

    await _pumpScreen(tester, controller);

    await repo.setTreasureActive('gym-android', false);
    await tester
        .widget<RefreshIndicator>(find.byType(RefreshIndicator))
        .onRefresh();
    await tester.pumpAndSettle();

    expect(find.text('No disponible'), findsOneWidget);
  });
}
