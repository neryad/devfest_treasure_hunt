import 'package:devfest_treasure_hunt/data/datasources/mock_local_data_source.dart';
import 'package:devfest_treasure_hunt/data/repositories/mock_app_repository.dart';
import 'package:devfest_treasure_hunt/state/app_controller.dart';
import 'package:devfest_treasure_hunt/state/app_scope.dart';
import 'package:devfest_treasure_hunt/ui/screens/admin/admin_login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppController controller;

  setUp(() async {
    final dataSource = MockLocalDataSource(seedData: false);
    await dataSource.initialize();
    final repo = MockAppRepository(dataSource);
    controller = AppController(
      treasureRepository: repo,
      participantRepository: repo,
      leaderboardRepository: repo,
      eventRepository: repo,
      resetStore: dataSource.reset,
      attemptRepository: repo,
      enableElapsedTicker: false,
    );
    await controller.initialize();
  });

  tearDown(() => controller.dispose());

  Future<void> pumpAdmin(WidgetTester tester) async {
    await tester.pumpWidget(
      AppScope(
        controller: controller,
        child: const MaterialApp(home: AdminLoginScreen()),
      ),
    );
    await tester.pump();
  }

  testWidgets('requires shared admin credentials before showing dashboard', (
    tester,
  ) async {
    await pumpAdmin(tester);

    expect(find.text('Acceso Staff'), findsWidgets);
    expect(find.text('Panel Staff'), findsNothing);

    await tester.enterText(find.widgetWithText(TextField, 'Usuario'), 'admin');
    await tester.enterText(
      find.widgetWithText(TextField, 'Contraseña'),
      'wrong',
    );
    await tester.tap(find.text('Entrar'));
    await tester.pump();

    expect(find.text('Credenciales inválidas'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextField, 'Contraseña'),
      'CafecitoConCodigo!2026',
    );
    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();

    expect(find.text('Panel Staff'), findsOneWidget);
  });
}
