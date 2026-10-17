import 'package:devfest_treasure_hunt/app/app.dart';
import 'package:devfest_treasure_hunt/data/datasources/mock_local_data_source.dart';
import 'package:devfest_treasure_hunt/data/repositories/mock_app_repository.dart';
import 'package:flutter_test/flutter_test.dart';

Future<AppDependencies> _offlineDeps() async {
  final ds = MockLocalDataSource(seedData: false);
  await ds.initialize();
  return AppDependencies(
    repository: MockAppRepository(ds),
    resetStore: ds.reset,
    offline: true,
  );
}

void main() {
  testWidgets('offline choice enters local mode with persistent banner', (
    tester,
  ) async {
    await tester.pumpWidget(
      DevFestRoot(
        connect: () async => throw Exception('network down'),
        connectOffline: _offlineDeps,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Continuar sin conexión'));
    await tester.pumpAndSettle();

    expect(
      find.text('Demo local — los cambios solo se guardan aquí'),
      findsOneWidget,
    );
    expect(find.text('¡Comenzar aventura!'), findsOneWidget);
  });
}
