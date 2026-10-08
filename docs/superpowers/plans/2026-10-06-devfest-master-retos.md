# DevFest Master Retos Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement the approved 8-medal DevFest Master challenge model with soft scoring, real challenge content, Startup mini-game, Security riddle flow, Community code validation, and points-based ranking.

**Architecture:** Keep the existing Flutter layered architecture: UI -> AppController -> use cases -> repositories -> MockLocalDataSource. Reuse the existing `GymChallenge`, `Attempt`, `CompleteChallengeUseCase`, `ChallengeScreen`, and mock repositories instead of creating a parallel challenge system.

**Tech Stack:** Flutter, Dart, Material 3, `flutter_test`, existing local mock data source, `shared_preferences` persistence.

---

## File Structure

Existing files to modify:

- `lib/domain/entities/gym_challenge.dart`: add `miniGame` challenge type and optional `targetScore`.
- `lib/domain/entities/treasure_item.dart`: serialize and deserialize `targetScore`.
- `lib/domain/use_cases/complete_challenge_use_case.dart`: replace 5-minute cooldown scoring with soft attempt bonuses and 8-medal completion bonus.
- `lib/data/repositories/mock_app_repository.dart`: include participant points in leaderboard entries and sort by points first.
- `lib/data/datasources/mock_data.dart`: align the 8 gyms with the approved design and set 100 base points.
- `lib/state/app_controller.dart`: expose challenge result clearing and keep local participant state in sync with points/medals/status.
- `lib/ui/screens/challenge/challenge_screen.dart`: route mini-game and social/riddle challenge types to appropriate UI states.
- `lib/ui/screens/leaderboard/leaderboard_screen.dart`: show points prominently in ranking.

New files to create:

- `lib/ui/screens/challenge/startup_mini_game.dart`: simple tap-to-jump runner-style mini-game for Startup.
- `test/use_cases/complete_challenge_use_case_test.dart`: scoring, attempts, invalid answers, completion bonus.
- `test/use_cases/leaderboard_points_test.dart`: points-first ranking behavior.
- `test/widgets/startup_mini_game_test.dart`: verifies the mini-game calls completion when reaching target score.

Do not change Firebase migration or storage architecture in this plan.

---

### Task 1: Add Mini-Game Challenge Metadata

**Files:**
- Modify: `lib/domain/entities/gym_challenge.dart`
- Modify: `lib/domain/entities/treasure_item.dart`
- Test: `flutter test test/use_cases/complete_challenge_use_case_test.dart`

- [ ] **Step 1: Update `ChallengeType` and `GymChallenge`**

Edit `lib/domain/entities/gym_challenge.dart` so it contains this complete shape:

```dart
enum ChallengeType {
  qr,
  trivia,
  riddle,
  code,
  completion,
  social,
  miniGame,
}

class GymChallenge {
  const GymChallenge({
    required this.type,
    this.question,
    this.options,
    this.correctAnswer,
    this.hint,
    this.codeSnippet,
    this.timeLimitSeconds = 60,
    this.points = 100,
    this.targetScore,
  });

  final ChallengeType type;
  final String? question;
  final List<String>? options;
  final String? correctAnswer;
  final String? hint;
  final String? codeSnippet;
  final int timeLimitSeconds;
  final int points;
  final int? targetScore;

  bool get hasTimer => type == ChallengeType.trivia || type == ChallengeType.code;
  bool get requiresInput => type == ChallengeType.riddle || type == ChallengeType.social;
  bool get hasOptions => options != null && options!.isNotEmpty;
  bool get isMiniGame => type == ChallengeType.miniGame;
}
```

- [ ] **Step 2: Persist `targetScore` in `TreasureItem.toJson()`**

In `lib/domain/entities/treasure_item.dart`, add `targetScore` inside the nested challenge map:

```dart
'challenge': challenge != null
    ? {
        'type': challenge!.type.name,
        'question': challenge!.question,
        'options': challenge!.options,
        'correctAnswer': challenge!.correctAnswer,
        'hint': challenge!.hint,
        'codeSnippet': challenge!.codeSnippet,
        'timeLimitSeconds': challenge!.timeLimitSeconds,
        'points': challenge!.points,
        'targetScore': challenge!.targetScore,
      }
    : null,
```

- [ ] **Step 3: Restore `targetScore` in `TreasureItem.fromJson()`**

In the `GymChallenge(...)` constructor inside `fromJson`, add:

```dart
targetScore: json['challenge']['targetScore'] as int?,
```

- [ ] **Step 4: Run analyzer**

Run: `flutter analyze`

Expected: no analyzer errors related to `ChallengeType.miniGame` or `targetScore`.

- [ ] **Step 5: Commit**

Only commit if the user has explicitly requested commits for the execution session.

```bash
git add lib/domain/entities/gym_challenge.dart lib/domain/entities/treasure_item.dart
git commit -m "feat: add mini-game challenge metadata"
```

---

### Task 2: Implement Soft Scoring Rules

**Files:**
- Modify: `lib/domain/use_cases/complete_challenge_use_case.dart`
- Test: `test/use_cases/complete_challenge_use_case_test.dart`

- [ ] **Step 1: Create failing scoring tests**

Create `test/use_cases/complete_challenge_use_case_test.dart` with these tests:

```dart
import 'package:devfest_treasure_hunt/data/datasources/mock_local_data_source.dart';
import 'package:devfest_treasure_hunt/data/repositories/mock_app_repository.dart';
import 'package:devfest_treasure_hunt/domain/entities/participant.dart';
import 'package:devfest_treasure_hunt/domain/use_cases/complete_challenge_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late MockLocalDataSource dataSource;
  late MockAppRepository repository;
  late CompleteChallengeUseCase useCase;

  setUp(() async {
    dataSource = MockLocalDataSource(seedData: false);
    await dataSource.initialize();
    repository = MockAppRepository(dataSource);
    useCase = CompleteChallengeUseCase(
      treasureRepository: repository,
      participantRepository: repository,
      attemptRepository: repository,
    );
  });

  Future<String> createParticipant() async {
    final participant = await repository.createParticipant(
      id: 'participant-test',
      name: 'Test User',
      nickname: 'tester',
      startedAt: DateTime.now(),
    );
    return participant.id;
  }

  test('awards base points plus first attempt bonus', () async {
    final participantId = await createParticipant();

    final result = await useCase.execute(
      participantId: participantId,
      gymId: 'gym-android',
      answer: 'AndroidManifest.xml',
    );

    expect(result.isSuccess, isTrue);
    expect(result.pointsEarned, 130);

    final participant = await repository.getParticipant(participantId);
    expect(participant!.points, 130);
    expect(participant.medals, 1);
  });

  test('awards second attempt bonus after one wrong answer', () async {
    final participantId = await createParticipant();

    final wrong = await useCase.execute(
      participantId: participantId,
      gymId: 'gym-android',
      answer: 'build.gradle',
    );
    expect(wrong.failure, ChallengeFailure.invalidAnswer);

    final correct = await useCase.execute(
      participantId: participantId,
      gymId: 'gym-android',
      answer: 'AndroidManifest.xml',
    );

    expect(correct.isSuccess, isTrue);
    expect(correct.pointsEarned, 115);
  });

  test('awards no attempt bonus after two wrong answers', () async {
    final participantId = await createParticipant();

    await useCase.execute(
      participantId: participantId,
      gymId: 'gym-android',
      answer: 'wrong one',
    );
    await useCase.execute(
      participantId: participantId,
      gymId: 'gym-android',
      answer: 'wrong two',
    );

    final correct = await useCase.execute(
      participantId: participantId,
      gymId: 'gym-android',
      answer: 'AndroidManifest.xml',
    );

    expect(correct.isSuccess, isTrue);
    expect(correct.pointsEarned, 100);
  });

  test('does not apply cooldown after wrong answer', () async {
    final participantId = await createParticipant();

    final wrong = await useCase.execute(
      participantId: participantId,
      gymId: 'gym-cloud',
      answer: 'Compute Engine',
    );
    expect(wrong.failure, ChallengeFailure.invalidAnswer);

    final correct = await useCase.execute(
      participantId: participantId,
      gymId: 'gym-cloud',
      answer: 'Firestore',
    );

    expect(correct.isSuccess, isTrue);
    expect(correct.failure, isNull);
  });

  test('adds completion bonus when eighth medal is completed', () async {
    final participantId = await createParticipant();
    final participant = await repository.getParticipant(participantId);
    await repository.updateParticipant(
      participant!.copyWith(
        discoveredTreasureIds: const [
          'gym-android',
          'gym-ia',
          'gym-security',
          'gym-web',
          'gym-startup',
          'gym-speaker',
          'gym-community',
        ],
        medals: 7,
        points: 700,
      ),
    );

    final result = await useCase.execute(
      participantId: participantId,
      gymId: 'gym-cloud',
      answer: 'Firestore',
    );

    expect(result.isSuccess, isTrue);
    expect(result.completed, isTrue);
    expect(result.pointsEarned, 230);

    final completed = await repository.getParticipant(participantId);
    expect(completed!.status, ParticipantStatus.completed);
    expect(completed.points, 930);
  });
}
```

- [ ] **Step 2: Run the new test and verify it fails**

Run: `flutter test test/use_cases/complete_challenge_use_case_test.dart`

Expected: failures because current code still uses 5-minute cooldown and existing seed answers/points do not match the new rules.

- [ ] **Step 3: Update `CompleteChallengeUseCase` constants**

In `lib/domain/use_cases/complete_challenge_use_case.dart`, replace the cooldown constant with scoring constants:

```dart
static const baseCompletionPoints = 100;
static const firstAttemptBonus = 30;
static const secondAttemptBonus = 15;
static const allMedalsBonus = 100;
```

- [ ] **Step 4: Remove cooldown rejection from `execute()`**

Delete the block that starts with:

```dart
// 4. Check cooldown
final lastAttempt = await _attemptRepository.getLastAttempt(participantId, gymId);
```

Do not return `ChallengeFailure.cooldownActive` for wrong answers in this MVP.

- [ ] **Step 5: Calculate attempt bonus before saving the successful participant**

Replace the point calculation block with:

```dart
final attemptsBeforeCorrect = await _attemptRepository.getAttemptCount(
  participantId,
  gymId,
);
final basePoints = gym.challenge?.points ?? gym.pointValue;
final attemptBonus = switch (attemptsBeforeCorrect) {
  0 => firstAttemptBonus,
  1 => secondAttemptBonus,
  _ => 0,
};
```

Place this after answer validation and before constructing the updated participant. `attemptsBeforeCorrect` includes previous wrong attempts because the current correct attempt is saved just before this block.

- [ ] **Step 6: Apply all-medals bonus**

Replace the existing `pointsForGym` / `updatedParticipant` block with:

```dart
final updatedTreasures = [...participant.discoveredTreasureIds, gymId];
final newMedals = updatedTreasures.length;
final allTreasures = await _treasureRepository.getTreasures();
final allCompleted = newMedals >= allTreasures.length;
final completionBonus = allCompleted ? allMedalsBonus : 0;
final pointsEarned = basePoints + attemptBonus + completionBonus;
final updatedParticipant = participant.copyWith(
  discoveredTreasureIds: updatedTreasures,
  points: participant.points + pointsEarned,
  medals: newMedals,
);
```

Delete the later duplicate `allTreasures` and `allCompleted` declaration.

- [ ] **Step 7: Return `pointsEarned`**

Update the success result call:

```dart
return ChallengeResult.success(
  gym: gym,
  pointsEarned: pointsEarned,
  totalPoints: updatedParticipant.points,
  medals: newMedals,
  completed: allCompleted,
);
```

- [ ] **Step 8: Run the new use case tests**

Run: `flutter test test/use_cases/complete_challenge_use_case_test.dart`

Expected: all tests pass.

- [ ] **Step 9: Commit**

Only commit if the user has explicitly requested commits for the execution session.

```bash
git add lib/domain/use_cases/complete_challenge_use_case.dart test/use_cases/complete_challenge_use_case_test.dart
git commit -m "feat: score challenges with soft attempt bonuses"
```

---

### Task 3: Update DevFest Master Challenge Content

**Files:**
- Modify: `lib/data/datasources/mock_data.dart`
- Test: `test/use_cases/complete_challenge_use_case_test.dart`

- [ ] **Step 1: Replace `MockData.buildTreasures()` with approved 8-medal content**

Use exactly 8 `TreasureItem`s with these ids and answers:

```dart
static List<TreasureItem> buildTreasures() {
  return [
    TreasureItem(
      id: 'gym-android',
      title: 'Gimnasio Android',
      description: 'Debug Droid: demuestra dominio de Android y Kotlin.',
      code: 'ANDROID-MASTER',
      qrValue: 'DEVFEST-GYM-ANDROID',
      clue: 'Debug Droid conquistado. El siguiente lider espera en otro track.',
      locationDescription: 'Stand Android / KMP',
      iconKey: 'android',
      order: 1,
      challengeType: ChallengeType.code,
      challenge: const GymChallenge(
        type: ChallengeType.code,
        question: 'Que archivo declara permisos como CAMERA o INTERNET en Android?',
        options: ['AndroidManifest.xml', 'pubspec.yaml', 'MainActivity.kt', 'settings.gradle'],
        correctAnswer: 'AndroidManifest.xml',
        codeSnippet: '<uses-permission android:name="android.permission.CAMERA" />',
        points: 100,
      ),
      gymName: 'Debug Droid',
      track: 'android',
      pointValue: 100,
    ),
    TreasureItem(
      id: 'gym-ia',
      title: 'Gimnasio IA',
      description: 'Prompt Master: responde preguntas de la charla de Carmelo.',
      code: 'IA-MASTER',
      qrValue: 'DEVFEST-GYM-IA',
      clue: 'Prompt Master conquistado. La IA premia a quien escucha con atencion.',
      locationDescription: 'Sala principal / charla IA',
      iconKey: 'brain',
      order: 2,
      challengeType: ChallengeType.trivia,
      challenge: const GymChallenge(
        type: ChallengeType.trivia,
        question: 'Segun la charla, que diferencia mejor describe un flujo agentic frente a un prompt simple?',
        options: [
          'Puede planificar pasos y usar herramientas',
          'Siempre responde mas rapido',
          'No necesita contexto',
          'Solo funciona sin internet',
        ],
        correctAnswer: 'Puede planificar pasos y usar herramientas',
        timeLimitSeconds: 60,
        points: 100,
      ),
      gymName: 'Prompt Master',
      track: 'ia',
      pointValue: 100,
    ),
    TreasureItem(
      id: 'gym-security',
      title: 'Gimnasio Security',
      description: 'The Hidden Exploit: encuentra pistas fisicas y descifra el codigo final.',
      code: 'SECURE2026',
      qrValue: 'DEVFEST-GYM-SECURITY',
      clue: 'The Hidden Exploit conquistado. El codigo final fue SECURE2026.',
      locationDescription: 'QRs escondidos en el venue',
      iconKey: 'shield',
      order: 3,
      challengeType: ChallengeType.riddle,
      challenge: const GymChallenge(
        type: ChallengeType.riddle,
        question: 'Une los fragmentos encontrados en los QR fisicos e introduce el codigo final.',
        hint: 'Los fragmentos forman una sola palabra con el ano del evento.',
        correctAnswer: 'SECURE2026',
        points: 100,
      ),
      gymName: 'The Hidden Exploit',
      track: 'security',
      pointValue: 100,
    ),
    TreasureItem(
      id: 'gym-web',
      title: 'Gimnasio Web',
      description: 'Pixel Perfect: resuelve un reto visual de UI y accesibilidad.',
      code: 'WEB-MASTER',
      qrValue: 'DEVFEST-GYM-WEB',
      clue: 'Pixel Perfect conquistado. Una buena UI tambien se mide por accesibilidad.',
      locationDescription: 'Area Web / UX',
      iconKey: 'globe',
      order: 4,
      challengeType: ChallengeType.trivia,
      challenge: const GymChallenge(
        type: ChallengeType.trivia,
        question: 'Que opcion es mas semantica para una navegacion principal en HTML?',
        options: ['<nav>', '<div>', '<span>', '<section>'],
        correctAnswer: '<nav>',
        timeLimitSeconds: 60,
        points: 100,
      ),
      gymName: 'Pixel Perfect',
      track: 'web',
      pointValue: 100,
    ),
    TreasureItem(
      id: 'gym-startup',
      title: 'Gimnasio Startup',
      description: 'Runway Rush: sobrevive al caos de una startup.',
      code: 'STARTUP-MASTER',
      qrValue: 'DEVFEST-GYM-STARTUP',
      clue: 'Runway Rush conquistado. Llegaste al millon narrativo antes de quedarte sin runway.',
      locationDescription: 'Area emprendimiento / networking',
      iconKey: 'rocket',
      order: 5,
      challengeType: ChallengeType.miniGame,
      challenge: const GymChallenge(
        type: ChallengeType.miniGame,
        question: 'Evita bugs, churn y errores de deploy hasta alcanzar la meta.',
        correctAnswer: 'RUNWAY-CLEARED',
        points: 100,
        targetScore: 100,
      ),
      gymName: 'Runway Rush',
      track: 'startup',
      pointValue: 100,
    ),
    TreasureItem(
      id: 'gym-cloud',
      title: 'Gimnasio Cloud',
      description: 'Scale the Cloud: responde arquitectura cloud y Firebase.',
      code: 'CLOUD-MASTER',
      qrValue: 'DEVFEST-GYM-CLOUD',
      clue: 'Scale the Cloud conquistado. La arquitectura escala mejor cuando es simple.',
      locationDescription: 'Area Cloud / Firebase',
      iconKey: 'cloud',
      order: 6,
      challengeType: ChallengeType.trivia,
      challenge: const GymChallenge(
        type: ChallengeType.trivia,
        question: 'Que servicio de Firebase usarias para guardar datos sincronizados de participantes?',
        options: ['Firestore', 'Crashlytics', 'Remote Config', 'Cloud Messaging'],
        correctAnswer: 'Firestore',
        timeLimitSeconds: 60,
        points: 100,
      ),
      gymName: 'Scale the Cloud',
      track: 'cloud',
      pointValue: 100,
    ),
    TreasureItem(
      id: 'gym-speaker',
      title: 'Gimnasio Speaker',
      description: 'Hall of Voices: demuestra que estuviste atento a las charlas.',
      code: 'SPEAKER-MASTER',
      qrValue: 'DEVFEST-GYM-SPEAKER',
      clue: 'Hall of Voices conquistado. Las mejores pistas salieron del escenario.',
      locationDescription: 'Sala principal',
      iconKey: 'mic',
      order: 7,
      challengeType: ChallengeType.trivia,
      challenge: const GymChallenge(
        type: ChallengeType.trivia,
        question: 'Que debes hacer para responder mejor las preguntas del Gimnasio Speaker?',
        options: ['Escuchar las charlas', 'Adivinar rapido', 'Buscar el QR mas cercano', 'Cerrar la app'],
        correctAnswer: 'Escuchar las charlas',
        timeLimitSeconds: 60,
        points: 100,
      ),
      gymName: 'Hall of Voices',
      track: 'speaker',
      pointValue: 100,
    ),
    TreasureItem(
      id: 'gym-community',
      title: 'Gimnasio Comunidad',
      description: 'Community Signal: completa el reto social y canjea el codigo recibido por DM.',
      code: 'COMMUNITY-SIGNAL',
      qrValue: 'DEVFEST-GYM-COMMUNITY',
      clue: 'Community Signal conquistado. La comunidad tambien se construye compartiendo.',
      locationDescription: 'Instagram / area comunidad',
      iconKey: 'people',
      order: 8,
      challengeType: ChallengeType.social,
      challenge: const GymChallenge(
        type: ChallengeType.social,
        question: 'Sube una selfie o story del evento, etiqueta a GDG Santo Domingo y envia evidencia por DM. Escribe aqui el codigo que recibas.',
        hint: 'Si Instagram falla, staff puede validar presencialmente y darte el codigo.',
        correctAnswer: 'COMMUNITY-SIGNAL',
        points: 100,
      ),
      gymName: 'Community Signal',
      track: 'community',
      pointValue: 100,
    ),
  ];
}
```

- [ ] **Step 2: Update seeded participant points**

In `MockData.buildSeedParticipants()`, ensure full-completion seeded users have points near the new model. Use these values:

```dart
points: 900,
medals: 8,
```

For partial participants, set points to roughly `medals * 100` plus small variation. Examples:

```dart
points: 645,
medals: 6,
```

```dart
points: 515,
medals: 5,
```

```dart
points: 730,
medals: 7,
```

- [ ] **Step 3: Run scoring tests**

Run: `flutter test test/use_cases/complete_challenge_use_case_test.dart`

Expected: pass with the exact answers from the updated mock data.

- [ ] **Step 4: Commit**

Only commit if the user has explicitly requested commits for the execution session.

```bash
git add lib/data/datasources/mock_data.dart
git commit -m "feat: seed approved DevFest Master challenges"
```

---

### Task 4: Rank by Points, Then Medals, Then Time

**Files:**
- Modify: `lib/data/repositories/mock_app_repository.dart`
- Test: `test/use_cases/leaderboard_points_test.dart`
- Potentially update: `test/use_cases/leaderboard_use_case_test.dart`

- [ ] **Step 1: Create failing points ranking test**

Create `test/use_cases/leaderboard_points_test.dart`:

```dart
import 'package:devfest_treasure_hunt/data/datasources/mock_local_data_source.dart';
import 'package:devfest_treasure_hunt/data/repositories/mock_app_repository.dart';
import 'package:devfest_treasure_hunt/domain/use_cases/leaderboard_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late MockLocalDataSource dataSource;
  late MockAppRepository repository;
  late LeaderboardUseCase useCase;

  setUp(() async {
    dataSource = MockLocalDataSource(seedData: false);
    await dataSource.initialize();
    repository = MockAppRepository(dataSource);
    useCase = LeaderboardUseCase(repository);
  });

  Future<void> addParticipant({
    required String id,
    required String name,
    required int points,
    required List<String> discovered,
    required int minutesAgo,
  }) async {
    final participant = await repository.createParticipant(
      id: id,
      name: name,
      nickname: name.toLowerCase(),
      startedAt: DateTime.now().subtract(Duration(minutes: minutesAgo)),
    );
    await repository.updateParticipant(
      participant.copyWith(
        points: points,
        medals: discovered.length,
        discoveredTreasureIds: discovered,
      ),
    );
  }

  test('sorts by points desc before medal count and elapsed time', () async {
    await addParticipant(
      id: 'p1',
      name: 'Ana',
      points: 300,
      discovered: ['gym-android', 'gym-web', 'gym-cloud'],
      minutesAgo: 5,
    );
    await addParticipant(
      id: 'p2',
      name: 'Pedro',
      points: 430,
      discovered: ['gym-android', 'gym-web'],
      minutesAgo: 20,
    );

    final board = await useCase.execute();

    expect(board.first.participantId, 'p2');
    expect(board.first.points, 430);
  });
}
```

- [ ] **Step 2: Run the new test and verify it fails**

Run: `flutter test test/use_cases/leaderboard_points_test.dart`

Expected: fail because current leaderboard does not copy points and sorts by discovered count first.

- [ ] **Step 3: Include `points` in leaderboard entries**

In `lib/data/repositories/mock_app_repository.dart`, update the `LeaderboardEntry` construction:

```dart
return LeaderboardEntry(
  participantId: p.id,
  name: p.name,
  nickname: p.nickname,
  discoveredCount: p.discoveredCount,
  totalTreasures: totalTreasures,
  elapsed: elapsed,
  status: p.status,
  points: p.points,
);
```

Also include `points: entries[i].points` in the second `LeaderboardEntry` constructor where positions are assigned.

- [ ] **Step 4: Update sort order**

Replace the sort block with:

```dart
entries.sort((a, b) {
  if (a.points != b.points) {
    return b.points.compareTo(a.points);
  }
  if (a.discoveredCount != b.discoveredCount) {
    return b.discoveredCount.compareTo(a.discoveredCount);
  }
  return a.elapsed.compareTo(b.elapsed);
});
```

- [ ] **Step 5: Update existing leaderboard tests**

In `test/use_cases/leaderboard_use_case_test.dart`, set `points` in helper `add()`:

```dart
int? points,
```

Then inside `copyWith`:

```dart
points: points ?? discovered.length * 100,
medals: discovered.length,
```

Update test names if needed so they reflect the new ranking rule: points first, then medals, then elapsed.

- [ ] **Step 6: Run leaderboard tests**

Run: `flutter test test/use_cases/leaderboard_points_test.dart test/use_cases/leaderboard_use_case_test.dart`

Expected: all leaderboard tests pass.

- [ ] **Step 7: Commit**

Only commit if the user has explicitly requested commits for the execution session.

```bash
git add lib/data/repositories/mock_app_repository.dart test/use_cases/leaderboard_points_test.dart test/use_cases/leaderboard_use_case_test.dart
git commit -m "feat: rank participants by challenge points"
```

---

### Task 5: Add Startup Mini-Game UI

**Files:**
- Create: `lib/ui/screens/challenge/startup_mini_game.dart`
- Modify: `lib/ui/screens/challenge/challenge_screen.dart`
- Test: `test/widgets/startup_mini_game_test.dart`

- [ ] **Step 1: Create mini-game widget test**

Create `test/widgets/startup_mini_game_test.dart`:

```dart
import 'package:devfest_treasure_hunt/ui/screens/challenge/startup_mini_game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('calls onCompleted when target score is reached', (tester) async {
    var completed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: StartupMiniGame(
          targetScore: 3,
          onCompleted: () => completed = true,
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('startup-game-tap-zone')));
    await tester.tap(find.byKey(const Key('startup-game-tap-zone')));
    await tester.tap(find.byKey(const Key('startup-game-tap-zone')));

    expect(completed, isTrue);
  });
}
```

- [ ] **Step 2: Run the mini-game test and verify it fails**

Run: `flutter test test/widgets/startup_mini_game_test.dart`

Expected: fail because `StartupMiniGame` does not exist.

- [ ] **Step 3: Create `StartupMiniGame`**

Create `lib/ui/screens/challenge/startup_mini_game.dart`:

```dart
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class StartupMiniGame extends StatefulWidget {
  const StartupMiniGame({
    super.key,
    required this.targetScore,
    required this.onCompleted,
  });

  final int targetScore;
  final VoidCallback onCompleted;

  @override
  State<StartupMiniGame> createState() => _StartupMiniGameState();
}

class _StartupMiniGameState extends State<StartupMiniGame> {
  int _score = 0;
  bool _completed = false;

  void _advance() {
    if (_completed) return;
    setState(() => _score += 1);
    if (_score + 1 >= widget.targetScore) {
      _completed = true;
      widget.onCompleted();
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_score / widget.targetScore).clamp(0.0, 1.0);
    return InkWell(
      key: const Key('startup-game-tap-zone'),
      onTap: _advance,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.surfaceAlt),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.rocket_launch_rounded, size: 56, color: AppColors.primary),
            const SizedBox(height: 16),
            const Text(
              'Runway Rush',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Toca para esquivar bugs, churn y errores de deploy.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            LinearProgressIndicator(value: progress),
            const SizedBox(height: 12),
            Text(
              'Runway: $_score / ${widget.targetScore}',
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Route mini-game challenge type in `ChallengeScreen`**

In `lib/ui/screens/challenge/challenge_screen.dart`, import the widget:

```dart
import 'startup_mini_game.dart';
```

Before the generic question/options UI, add this branch in `build()` after the result/cooldown checks:

```dart
if (challenge?.isMiniGame == true) {
  return Scaffold(
    appBar: AppBar(
      title: Text(gym.gymName ?? gym.title),
      leading: IconButton(
        icon: const Icon(Icons.close_rounded),
        onPressed: () => Navigator.of(context).pop(),
      ),
    ),
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: StartupMiniGame(
          targetScore: challenge?.targetScore ?? 100,
          onCompleted: () {
            _selectedAnswer = challenge?.correctAnswer ?? 'RUNWAY-CLEARED';
            _handleSubmit();
          },
        ),
      ),
    ),
  );
}
```

- [ ] **Step 5: Run mini-game widget test**

Run: `flutter test test/widgets/startup_mini_game_test.dart`

Expected: pass.

- [ ] **Step 6: Commit**

Only commit if the user has explicitly requested commits for the execution session.

```bash
git add lib/ui/screens/challenge/startup_mini_game.dart lib/ui/screens/challenge/challenge_screen.dart test/widgets/startup_mini_game_test.dart
git commit -m "feat: add Startup mini-game challenge"
```

---

### Task 6: Improve Challenge Screen for Riddle and Social Codes

**Files:**
- Modify: `lib/ui/screens/challenge/challenge_screen.dart`
- Test: `test/widgets/app_flow_test.dart`

- [ ] **Step 1: Update input hint by challenge type**

In the `TextField` decoration for `challenge?.requiresInput == true`, replace the static hint text with:

```dart
hintText: challenge?.type == ChallengeType.social
    ? 'Escribe el codigo recibido por DM...'
    : 'Escribe tu respuesta o codigo final...',
```

- [ ] **Step 2: Show challenge hint when present**

After the question card and before options/input, add:

```dart
if (challenge?.hint != null) ...[
  Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.warning.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      challenge!.hint!,
      style: const TextStyle(
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w600,
      ),
    ),
  ),
  const SizedBox(height: 20),
],
```

- [ ] **Step 3: Disable submit when no answer is available**

Find the submit button and set `onPressed` to null when needed:

```dart
final canSubmit = challenge?.hasOptions == true
    ? _selectedAnswer != null
    : !challenge!.requiresInput || _textController.text.trim().isNotEmpty;
```

Use `onPressed: canSubmit ? _handleSubmit : null`.

- [ ] **Step 4: Run widget flow tests**

Run: `flutter test test/widgets/app_flow_test.dart`

Expected: existing app flow tests pass. If tests reference old treasure ids like `treasure-001`, update them to current ids such as `gym-android`.

- [ ] **Step 5: Commit**

Only commit if the user has explicitly requested commits for the execution session.

```bash
git add lib/ui/screens/challenge/challenge_screen.dart test/widgets/app_flow_test.dart
git commit -m "feat: improve code-based challenge input"
```

---

### Task 7: Show Points in Leaderboard UI

**Files:**
- Modify: `lib/ui/screens/leaderboard/leaderboard_screen.dart`
- Test: `flutter test test/widgets/app_flow_test.dart`

- [ ] **Step 1: Find leaderboard row widget**

Open `lib/ui/screens/leaderboard/leaderboard_screen.dart` and locate where each `LeaderboardEntry` displays name, discovered count, and elapsed time.

- [ ] **Step 2: Add points label to each row**

Add this `Text` near the medal/progress display for each entry:

```dart
Text(
  '${entry.points} pts',
  style: const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w900,
    color: AppColors.primary,
  ),
),
```

- [ ] **Step 3: Make discovered count secondary**

Ensure the row still shows medallas, but visually below points:

```dart
Text(
  '${entry.discoveredCount}/${entry.totalTreasures} medallas',
  style: const TextStyle(
    fontSize: 12,
    color: AppColors.textSecondary,
  ),
),
```

- [ ] **Step 4: Run app flow tests**

Run: `flutter test test/widgets/app_flow_test.dart`

Expected: pass.

- [ ] **Step 5: Commit**

Only commit if the user has explicitly requested commits for the execution session.

```bash
git add lib/ui/screens/leaderboard/leaderboard_screen.dart
git commit -m "feat: show points in leaderboard"
```

---

### Task 8: Final Verification

**Files:**
- Verify all changed files.

- [ ] **Step 1: Run analyzer**

Run: `flutter analyze`

Expected: no issues.

- [ ] **Step 2: Run all unit and widget tests**

Run: `flutter test`

Expected: all tests pass.

- [ ] **Step 3: Manually verify core flows**

Run: `flutter run -d chrome`

Manual checklist:

- Register participant.
- Complete Android challenge with first-attempt answer and see +130 points.
- Fail one Cloud answer, retry immediately, then see +115 points.
- Complete Security by entering `SECURE2026`.
- Complete Startup mini-game by reaching the target score.
- Complete Community by entering `COMMUNITY-SIGNAL`.
- Open leaderboard and verify ranking uses points.

- [ ] **Step 4: Review diff**

Run: `git diff -- lib test docs/superpowers/plans/2026-10-06-devfest-master-retos.md`

Expected: only intended implementation and tests are changed.

---

## Spec Coverage Review

- 8 medals are covered in Task 3.
- Soft attempts and ranking points are covered in Tasks 2 and 4.
- Startup mini-game is covered in Task 5.
- Security final code flow is covered as a riddle/code challenge in Task 3 and UI input improvements in Task 6.
- Community DM code flow is covered as a social/code challenge in Task 3 and Task 6.
- Staff fallback codes are represented as `code` values in each `TreasureItem`.
- No Firebase or production admin panel work is included because the approved design only needs the current app/MVP behavior.
