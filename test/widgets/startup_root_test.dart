import 'package:devfest_treasure_hunt/app/app.dart';
import 'package:devfest_treasure_hunt/data/datasources/mock_local_data_source.dart';
import 'package:devfest_treasure_hunt/data/repositories/mock_app_repository.dart';
import 'package:devfest_treasure_hunt/ui/screens/admin/admin_login_screen.dart';
import 'package:flutter_test/flutter_test.dart';

Future<AppDependencies> _deps({bool offline = false}) async {
  final ds = MockLocalDataSource(seedData: false);
  await ds.initialize();
  return AppDependencies(
    repository: MockAppRepository(ds),
    resetStore: ds.reset,
    offline: offline,
  );
}

void main() {
  testWidgets('shows error screen with retry when connection fails', (
    tester,
  ) async {
    await tester.pumpWidget(
      DevFestRoot(
        connect: () async => throw Exception('network down'),
        connectOffline: () => _deps(offline: true),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No se pudo conectar con el evento'), findsOneWidget);
    expect(find.text('Continuar sin conexión'), findsOneWidget);
    expect(find.text('¡Comenzar aventura!'), findsNothing);
    expect(find.textContaining('Sin conexión —'), findsNothing);
  });

  testWidgets('retry reconnects after a transient failure', (tester) async {
    var attempts = 0;
    await tester.pumpWidget(
      DevFestRoot(
        connect: () async {
          attempts++;
          if (attempts == 1) throw Exception('network down');
          return _deps();
        },
        connectOffline: () => _deps(offline: true),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('No se pudo conectar con el evento'), findsOneWidget);

    await tester.tap(find.text('Reintentar'));
    await tester.pumpAndSettle();

    expect(attempts, 2);
    expect(find.text('¡Comenzar aventura!'), findsOneWidget);
  });

  testWidgets('admin panel route can read the app scope', (tester) async {
    await tester.pumpWidget(
      DevFestRoot(connect: _deps, connectOffline: () => _deps(offline: true)),
    );
    await tester.pumpAndSettle();
    expect(find.text('¡Comenzar aventura!'), findsOneWidget);

    await tester.ensureVisible(find.text('Panel de Administración (Demo)'));
    await tester.pump();
    await tester.tap(find.text('Panel de Administración (Demo)'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(AdminLoginScreen), findsOneWidget);
  });
}
