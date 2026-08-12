import 'package:devfest_treasure_hunt/core/theme/app_theme.dart';
import 'package:devfest_treasure_hunt/data/datasources/mock_local_data_source.dart';
import 'package:devfest_treasure_hunt/data/repositories/mock_app_repository.dart';
import 'package:devfest_treasure_hunt/state/app_controller.dart';
import 'package:devfest_treasure_hunt/state/app_scope.dart';
import 'package:devfest_treasure_hunt/ui/screens/root/session_gate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// Captures only the completion screens (14 and 15) with a minimal UI flow.
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('capture completion screenshots', (tester) async {
    final dataSource = MockLocalDataSource();
    await dataSource.initialize();
    final repo = MockAppRepository(dataSource);
    final controller = AppController(
      treasureRepository: repo,
      participantRepository: repo,
      leaderboardRepository: repo,
      eventRepository: repo,
      resetStore: dataSource.reset,
      enableElapsedTicker: false,
    );
    await controller.initialize();

    // Prepare a nearly-finished participant (9/10) without extra UI.
    await controller.setTreasureActive('treasure-003', true);
    await controller.startParticipant(name: 'Demo', nickname: 'demo');
    for (final id in [
      'treasure-001',
      'treasure-002',
      'treasure-003',
      'treasure-004',
      'treasure-005',
      'treasure-006',
      'treasure-007',
      'treasure-008',
      'treasure-009',
    ]) {
      await controller.discoverByTreasureId(id);
    }

    await tester.pumpWidget(
      AppScope(
        controller: controller,
        child: MaterialApp(theme: AppTheme.dark(), home: const SessionGate()),
      ),
    );
    await tester.pumpAndSettle();

    // Find the last treasure through the QR demo → completion.
    await tester.tap(find.text('Encontrar tesoro'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Escanear QR'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tesoro #10 · El Hall de los Campeones'));
    await tester.pumpAndSettle();
    await binding.takeScreenshot('14-reto-completado');
    await tester.tap(find.text('Revelar pista'));
    await tester.pumpAndSettle();
    await binding.takeScreenshot('14b-reto-completado-pista');
    await tester.tap(find.text('Ver mi resultado final'));
    await tester.pumpAndSettle();
    await binding.takeScreenshot('15-finalizacion');
  });
}