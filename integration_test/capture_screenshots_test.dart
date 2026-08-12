import 'package:devfest_treasure_hunt/core/theme/app_theme.dart';
import 'package:devfest_treasure_hunt/data/datasources/mock_local_data_source.dart';
import 'package:devfest_treasure_hunt/data/repositories/mock_app_repository.dart';
import 'package:devfest_treasure_hunt/state/app_controller.dart';
import 'package:devfest_treasure_hunt/state/app_scope.dart';
import 'package:devfest_treasure_hunt/ui/screens/admin/admin_dashboard_screen.dart';
import 'package:devfest_treasure_hunt/ui/screens/root/session_gate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// Drives the real app UI and captures screenshots for the README.
///
/// Run with:
///   flutter drive --driver=test_driver/integration_test.dart \
///     --target=integration_test/capture_screenshots_test.dart -d <device>
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('capture demo screenshots', (tester) async {
    // Build a controller with the elapsed ticker disabled so pumpAndSettle
    // is deterministic; uses an in-memory data source (clean state).
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

    await tester.pumpWidget(
      AppScope(
        controller: controller,
        child: MaterialApp(theme: AppTheme.dark(), home: const SessionGate()),
      ),
    );
    await tester.pump();

    Future<void> shot(String name) async {
      await binding.takeScreenshot(name);
    }

    // 01 · Welcome
    await shot('01-welcome');

    // 02 · Registro
    await tester.ensureVisible(find.text('Comenzar aventura'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Comenzar aventura'));
    await tester.pumpAndSettle();
    await shot('02-registro');

    // 03 · Home dashboard (0/10)
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Nombre'), 'Demo');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Nickname / Alias'), 'demo');
    await tester.tap(find.text('Iniciar aventura'));
    await tester.pumpAndSettle();
    await shot('03-home');

    // 04 · Bottom sheet "Encontrar tesoro"
    await tester.tap(find.text('Encontrar tesoro'));
    await tester.pumpAndSettle();
    await shot('04-encontrar-tesoro');

    // 05 · Scanner demo
    await tester.tap(find.text('Escanear QR'));
    await tester.pumpAndSettle();
    await shot('05-scanner-demo');

    // 06 · Tesoro encontrado · 07 · Pista
    await tester.tap(find.text('Tesoro #01 · El Punto de Encuentro'));
    await tester.pumpAndSettle();
    await shot('06-tesoro-encontrado');
    await tester.tap(find.text('Revelar pista'));
    await tester.pumpAndSettle();
    await shot('07-pista-desbloqueada');
    await tester.tap(find.text('¡A por el siguiente!'));
    await tester.pumpAndSettle();

    // Back to the home shell.
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    // 08 · Mis tesoros
    await tester.tap(find.text('Tesoros'));
    await tester.pumpAndSettle();
    await shot('08-mis-tesoros');

    // 09 · Mis pistas
    await tester.tap(find.text('Pistas'));
    await tester.pumpAndSettle();
    await shot('09-mis-pistas');

    // 10 · Ranking
    await tester.tap(find.text('Ranking'));
    await tester.pumpAndSettle();
    await shot('10-ranking');

    // 11 · Admin demo
    await tester.tap(find.byIcon(Icons.admin_panel_settings_rounded));
    await tester.pumpAndSettle();
    await shot('11-admin');

    // 12 · Admin: desactivar Tesoro #03
    final tile03 =
        find.widgetWithText(ListTile, 'Tesoro #03 · El Rincón del Café');
    await tester.ensureVisible(tile03);
    await tester.pumpAndSettle();
    await tester.tap(find.descendant(of: tile03, matching: find.byType(Switch)));
    await tester.pumpAndSettle();
    await shot('12-admin-inactivo');
    // Re-activar para que el reto quede completable.
    await tester.tap(find.descendant(of: tile03, matching: find.byType(Switch)));
    await tester.pumpAndSettle();

    // 13 · Código manual con tesoro desactivado (snackbar de error)
    final adminContext =
        tester.element(find.byType(AdminDashboardScreen));
    Navigator.of(adminContext).pop();
    await tester.pumpAndSettle();
    await controller.setTreasureActive('treasure-003', false);
    await tester.tap(find.text('Encontrar tesoro'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Introducir código'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'DEVFEST-003');
    await tester.tap(find.text('Validar tesoro'));
    await tester.pumpAndSettle();
    await shot('13-no-disponible');
    await controller.setTreasureActive('treasure-003', true);
    // Dismiss snackbar.
    ScaffoldMessenger.of(tester.element(find.byType(TextField)))
        .hideCurrentSnackBar();
    await tester.pumpAndSettle();

    // 14 · Código manual exitoso (fuera de orden) — Tesoro #03 reactivado.
    await tester.enterText(find.byType(TextField), 'DEVFEST-003');
    await tester.tap(find.text('Validar tesoro'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Revelar pista'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('¡A por el siguiente!'));
    await tester.pumpAndSettle();

    // Descubre los 7 tesoros restantes vía controller y completa con el
    // último por QR para capturar la pantalla de finalización.
    await controller.discoverByTreasureId('treasure-002');
    await controller.discoverByTreasureId('treasure-004');
    await controller.discoverByTreasureId('treasure-005');
    await controller.discoverByTreasureId('treasure-006');
    await controller.discoverByTreasureId('treasure-007');
    await controller.discoverByTreasureId('treasure-008');
    await controller.discoverByTreasureId('treasure-009');
    // Encontrar #10 por QR demo → pantalla de finalización.
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Encontrar tesoro'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Escanear QR'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tesoro #10 · El Hall de los Campeones'));
    await tester.pumpAndSettle();
    await shot('14-reto-completado');
    await tester.tap(find.text('Revelar pista'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ver mi resultado final'));
    await tester.pumpAndSettle();
    await shot('15-finalizacion');
  });
}