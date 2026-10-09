import 'package:devfest_treasure_hunt/ui/screens/information/information_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows game rules, creator, credits, and opens social links', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    Uri? openedUri;
    await tester.pumpWidget(
      MaterialApp(
        home: InformationScreen(
          repositoryAvailableAt: DateTime(2020),
          linkOpener: (uri) async {
            openedUri = uri;
            return true;
          },
        ),
      ),
    );

    expect(find.text('Información y reglas'), findsOneWidget);
    expect(find.byKey(const Key('information-app-icon')), findsOneWidget);
    expect(find.text('Cómo jugar'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Tipos de retos'),
      300,
      scrollable: find.byType(Scrollable),
    );
    expect(find.text('Tipos de retos'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Puntos y reglas'),
      300,
      scrollable: find.byType(Scrollable),
    );
    expect(find.text('Puntos y reglas'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text(
        'El ganador será quien complete los ocho gimnasios con la mayor puntuación.',
      ),
      300,
      scrollable: find.byType(Scrollable),
    );
    expect(
      find.text(
        'En caso de empate, gana quien haya completado los ocho primero.',
      ),
      findsOneWidget,
    );

    await tester.scrollUntilVisible(
      find.byKey(const Key('info-open-feedback')),
      500,
      scrollable: find.byType(Scrollable),
    );
    await tester.tap(find.byKey(const Key('info-open-feedback')));
    await tester.pump();
    expect(
      openedUri,
      Uri.parse(
        'https://docs.google.com/forms/d/e/1FAIpQLSeKLBT0vCD3AFrohM0BsSczxC-WicESU04z3HLXInMmx4YCng/viewform?usp=publish-editor',
      ),
    );

    await tester.scrollUntilVisible(
      find.text('Dayern Gomez'),
      500,
      scrollable: find.byType(Scrollable),
    );
    expect(find.text('Dayern Gomez'), findsOneWidget);
    expect(find.text('@neryad · Mobile Developer'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.byKey(const Key('info-project-repository')),
      200,
      scrollable: find.byType(Scrollable),
    );
    await tester.tap(find.byKey(const Key('info-project-repository')));
    await tester.pump();
    expect(
      openedUri,
      Uri.parse('https://github.com/neryad/devfest_treasure_hunt'),
    );

    await tester.scrollUntilVisible(
      find.byKey(const Key('info-creator-github')),
      200,
      scrollable: find.byType(Scrollable),
    );
    await tester.tap(find.byKey(const Key('info-creator-github')));
    await tester.pump();
    expect(openedUri, Uri.parse('https://github.com/neryad'));

    await tester.ensureVisible(find.byKey(const Key('info-creator-x')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('info-creator-x')));
    await tester.pump();
    expect(openedUri, Uri.parse('https://x.com/NeryadG'));

    await tester.ensureVisible(find.byKey(const Key('info-creator-instagram')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('info-creator-instagram')));
    await tester.pump();
    expect(openedUri, Uri.parse('https://www.instagram.com/neryad_dev/'));

    await tester.scrollUntilVisible(
      find.text('Hecho con amor, por y para la comunidad.'),
      300,
      scrollable: find.byType(Scrollable),
    );
    expect(
      find.text('Hecho con amor, por y para la comunidad.'),
      findsOneWidget,
    );
  });

  testWidgets('shows the project repository when its release time arrives', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final releaseAt = DateTime.now().add(const Duration(seconds: 10));
    await tester.pumpWidget(
      MaterialApp(home: InformationScreen(repositoryAvailableAt: releaseAt)),
    );

    await tester.scrollUntilVisible(
      find.text('Dayern Gomez'),
      500,
      scrollable: find.byType(Scrollable),
    );
    await tester.pump();
    expect(find.byKey(const Key('info-project-repository')), findsNothing);

    await tester.pump(const Duration(seconds: 11));
    expect(find.byKey(const Key('info-project-repository')), findsOneWidget);
  });
}
