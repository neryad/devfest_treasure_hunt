import 'package:devfest_treasure_hunt/data/datasources/mock_local_data_source.dart';
import 'package:devfest_treasure_hunt/data/repositories/mock_app_repository.dart';
import 'package:devfest_treasure_hunt/state/app_controller.dart';
import 'package:devfest_treasure_hunt/state/app_scope.dart';
import 'package:devfest_treasure_hunt/ui/screens/challenge/challenge_screen.dart';
import 'package:devfest_treasure_hunt/ui/screens/challenge/community_challenge_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('guides the participant through links and staff QR', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final openedUris = <Uri>[];
    var completed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: CommunityChallengeScreen(
          linkOpener: (uri) async {
            openedUris.add(uri);
            return true;
          },
          scannerBuilder: (_, onDetected) => Center(
            child: ElevatedButton(
              key: const Key('test-valid-qr'),
              onPressed: () => onDetected('COMMUNITY-SIGNAL'),
              child: const Text('Leer QR'),
            ),
          ),
          onCompleted: () async => completed = true,
        ),
      ),
    );

    expect(find.text('Únete a la comunidad'), findsOneWidget);
    expect(find.text('0 de 3 pasos'), findsOneWidget);

    await tester.tap(find.byKey(const Key('community-open-join')));
    await tester.pump();
    expect(openedUris, [CommunityChallengeScreen.communityUri]);

    await tester.tap(find.byKey(const Key('community-confirm-join')));
    await tester.pump();
    expect(find.text('1 de 3 pasos'), findsOneWidget);

    await tester.tap(find.byKey(const Key('community-open-tickets')));
    await tester.pump();
    expect(openedUris.last, CommunityChallengeScreen.ticketsUri);

    await tester.tap(find.byKey(const Key('community-confirm-tickets')));
    await tester.pump();
    expect(find.text('2 de 3 pasos'), findsOneWidget);

    await tester.ensureVisible(find.byKey(const Key('community-scan-qr')));
    await tester.tap(find.byKey(const Key('community-scan-qr')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('test-valid-qr')));
    await tester.pumpAndSettle();

    expect(completed, isTrue);
  });

  testWidgets('rejects an invalid manual staff code', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    var completed = false;
    await tester.pumpWidget(
      MaterialApp(
        home: CommunityChallengeScreen(
          linkOpener: (_) async => true,
          onCompleted: () async => completed = true,
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('community-open-join')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('community-confirm-join')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('community-open-tickets')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('community-confirm-tickets')));
    await tester.pump();

    await tester.ensureVisible(find.byKey(const Key('community-enter-code')));
    await tester.tap(find.byKey(const Key('community-enter-code')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('community-code-field')),
      'CODIGO-INCORRECTO',
    );
    await tester.tap(find.text('Validar'));
    await tester.pumpAndSettle();

    expect(completed, isFalse);
    expect(
      find.text('Ese no es el QR de validación. Pídele ayuda al staff.'),
      findsOneWidget,
    );
  });

  testWidgets('the Community gym opens the guided mission', (tester) async {
    final dataSource = MockLocalDataSource(seedData: false);
    await dataSource.initialize();
    final repository = MockAppRepository(dataSource);
    final controller = AppController(
      treasureRepository: repository,
      participantRepository: repository,
      leaderboardRepository: repository,
      eventRepository: repository,
      attemptRepository: repository,
      enableElapsedTicker: false,
    );
    addTearDown(controller.dispose);
    await controller.initialize();
    await controller.startParticipant(name: 'Nery', nickname: 'community_test');
    final community = controller.treasures.firstWhere(
      (item) => item.id == 'gym-community',
    );

    await tester.pumpWidget(
      AppScope(
        controller: controller,
        child: MaterialApp(home: ChallengeScreen(gym: community)),
      ),
    );
    await tester.pump();

    expect(find.byType(CommunityChallengeScreen), findsOneWidget);
    expect(find.text('Únete a la comunidad'), findsOneWidget);
    expect(find.text('Enviar respuesta'), findsNothing);
  });
}
