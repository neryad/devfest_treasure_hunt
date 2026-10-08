# DevFest Master — MVP Extendido Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Evolve the Treasure Hunt MVP into "DevFest Master" with 8 themed gyms, challenge types, a challenge screen with timer, attempt/cooldown system, and Pokédex-style progress.

**Architecture:** Extend existing clean architecture (Domain → Data → State → UI). Add new entities (`GymChallenge`, `Attempt`), expand `TreasureItem` with challenge fields, update use cases for challenge validation and cooldown logic, and add new UI screens (challenge screen, Pokédex view).

**Tech Stack:** Flutter/Dart, Material 3, existing clean architecture

---

## Feature Scope

| # | Feature | Description |
|---|---------|-------------|
| 1 | 8 Gimnasios temáticos | Rename treasures to gyms with tech tracks (Android, IA, Cloud, etc.) |
| 2 | Tipos de reto | trivia, riddle, code, completion, social — each with challenge data |
| 3 | Pantalla de reto con timer | 60s countdown for trivia, answer selection UI |
| 4 | Sistema de intentos + cooldown | Track attempts, 5-min cooldown on wrong answer |
| 5 | Progreso tipo Pokédex | 8 badge slots with visual state (empty/earned) |

---

## File Map

| # | File | Change Type | Description |
|---|------|-------------|-------------|
| 1 | `lib/domain/entities/gym_challenge.dart` | **Create** | ChallengeType enum + GymChallenge entity |
| 2 | `lib/domain/entities/attempt.dart` | **Create** | Attempt entity for tracking answers |
| 3 | `lib/domain/entities/treasure_item.dart` | **Modify** | Add challenge fields to TreasureItem |
| 4 | `lib/domain/entities/participant.dart` | **Modify** | Add points, avatar, level fields |
| 5 | `lib/domain/entities/leaderboard_entry.dart` | **Modify** | Add points field |
| 6 | `lib/domain/repositories/attempt_repository.dart` | **Create** | Interface for attempt storage |
| 7 | `lib/domain/use_cases/complete_challenge_use_case.dart` | **Create** | Challenge validation + cooldown + points |
| 8 | `lib/data/datasources/app_data_source.dart` | **Modify** | Add attempt storage methods |
| 9 | `lib/data/datasources/mock_data.dart` | **Modify** | 8 themed gyms with challenge data |
| 10 | `lib/data/datasources/mock_local_data_source.dart` | **Modify** | Implement attempt storage |
| 11 | `lib/data/repositories/mock_app_repository.dart` | **Modify** | Implement AttemptRepository |
| 12 | `lib/state/app_controller.dart` | **Modify** | Add challenge state, cooldown timer, points |
| 13 | `lib/ui/screens/challenge/challenge_screen.dart` | **Create** | Challenge UI with timer |
| 14 | `lib/ui/screens/pokedex/pokedex_screen.dart` | **Create** | 8-badge Pokédex view |
| 15 | `lib/ui/screens/home/home_dashboard.dart` | **Modify** | Replace treasure count with Pokédex preview |
| 16 | `lib/ui/screens/treasures/treasures_screen.dart` | **Modify** | Rename to "Gimnasios" with new types |
| 17 | `lib/ui/screens/home/home_shell.dart` | **Modify** | Update navigation labels |
| 18 | `lib/ui/screens/welcome/welcome_screen.dart` | **Modify** | Update copy for DevFest Master theme |
| 19 | `lib/main.dart` | **Modify** | Wire AttemptRepository |
| 20 | `lib/app/app.dart` | **Modify** | Update app title |

---

## Task Details

### Task 1: Create GymChallenge entity and ChallengeType enum

**Files:**
- Create: `lib/domain/entities/gym_challenge.dart`

**Content:**

```dart
enum ChallengeType {
  qr,          // Simple QR scan (no challenge screen)
  trivia,      // Multiple choice question, 60s timer
  riddle,      // Text riddle, answer is a code
  code,        // Code snippet question, multiple choice
  completion,  // Real-world action, admin verifies
  social,      // Social interaction required
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
    this.points = 10,
  });

  final ChallengeType type;
  final String? question;
  final List<String>? options;
  final String? correctAnswer;
  final String? hint;
  final String? codeSnippet;
  final int timeLimitSeconds;
  final int points;

  bool get hasTimer => type == ChallengeType.trivia || type == ChallengeType.code;
  bool get requiresInput => type == ChallengeType.riddle;
  bool get hasOptions => options != null && options!.isNotEmpty;
}
```

- [ ] **Step 1: Create the file**
- [ ] **Step 2: Run `flutter analyze`**
- [ ] **Step 3: Commit** — `git add -A && git commit -m "feat: add GymChallenge entity and ChallengeType enum"`

---

### Task 2: Create Attempt entity

**Files:**
- Create: `lib/domain/entities/attempt.dart`

**Content:**

```dart
class Attempt {
  const Attempt({
    required this.id,
    required this.participantId,
    required this.gymId,
    required this.answeredAt,
    required this.correct,
    this.answer,
  });

  final String id;
  final String participantId;
  final String gymId;
  final DateTime answeredAt;
  final bool correct;
  final String? answer;

  Map<String, dynamic> toJson() => {
        'id': id,
        'participantId': participantId,
        'gymId': gymId,
        'answeredAt': answeredAt.toIso8601String(),
        'correct': correct,
        'answer': answer,
      };

  factory Attempt.fromJson(Map<String, dynamic> json) => Attempt(
        id: json['id'] as String,
        participantId: json['participantId'] as String,
        gymId: json['gymId'] as String,
        answeredAt: DateTime.parse(json['answeredAt'] as String),
        correct: json['correct'] as bool,
        answer: json['answer'] as String?,
      );

  static List<Attempt> listFromJson(String json) =>
      (jsonDecode(json) as List).map((e) => Attempt.fromJson(e)).toList();

  static String listToJson(List<Attempt> items) =>
      jsonEncode(items.map((e) => e.toJson()).toList());
}
```

- [ ] **Step 1: Create the file**
- [ ] **Step 2: Run `flutter analyze`**
- [ ] **Step 3: Commit** — `git add -A && git commit -m "feat: add Attempt entity for challenge tracking"`

---

### Task 3: Extend TreasureItem with challenge and gym fields

**Files:**
- Modify: `lib/domain/entities/treasure_item.dart`

**Changes:**

Add these fields to `TreasureItem`:
```dart
import 'gym_challenge.dart';

// Add to constructor and fields:
final ChallengeType challengeType;
final GymChallenge? challenge;
final String? gymName;      // Display name: "Gimnasio Cloud"
final String? track;        // Tech track: "cloud", "android", etc.
final int pointValue;       // Points awarded (difficulty-based)
```

Update `copyWith` to include new fields. Update `toJson`/`fromJson` to serialize them.

- [ ] **Step 1: Add imports and new fields**
- [ ] **Step 2: Update copyWith**
- [ ] **Step 3: Update toJson/fromJson**
- [ ] **Step 4: Run `flutter analyze`**
- [ ] **Step 5: Commit** — `git add -A && git commit -m "feat: extend TreasureItem with challenge and gym fields"`

---

### Task 4: Extend Participant with points, avatar, level

**Files:**
- Modify: `lib/domain/entities/participant.dart`

**Changes:**

Add these fields:
```dart
final int points;           // Total points earned
final int medals;           // Number of gyms completed
final String? avatarEmoji;  // 😎 / 🦊 / 🐉
```

Add computed getter:
```dart
String get level {
  if (medals >= 8) return 'DevFest Master';
  if (medals >= 7) return 'Lead Engineer';
  if (medals >= 5) return 'Senior Dev';
  if (medals >= 3) return 'Developer';
  return 'Aprendiz Tech';
}
```

Update `copyWith`, `toJson`, `fromJson`.

- [ ] **Step 1: Add new fields and getter**
- [ ] **Step 2: Update copyWith**
- [ ] **Step 3: Update toJson/fromJson**
- [ ] **Step 4: Run `flutter analyze`**
- [ ] **Step 5: Commit** — `git add -A && git commit -m "feat: extend Participant with points, medals, avatar, and level"`

---

### Task 5: Extend LeaderboardEntry with points

**Files:**
- Modify: `lib/domain/entities/leaderboard_entry.dart`

**Changes:**

Add field:
```dart
final int points;
```

Update constructor and add to the class. Points should be used as primary sort (desc) before time.

- [ ] **Step 1: Add points field**
- [ ] **Step 2: Update constructor**
- [ ] **Step 3: Run `flutter analyze`**
- [ ] **Step 4: Commit** — `git add -A && git commit -m "feat: add points to LeaderboardEntry"`

---

### Task 6: Create AttemptRepository interface

**Files:**
- Create: `lib/domain/repositories/attempt_repository.dart`

**Content:**

```dart
import '../entities/attempt.dart';

abstract class AttemptRepository {
  Future<List<Attempt>> getAttempts(String participantId);
  Future<List<Attempt>> getAttemptsForGym(String participantId, String gymId);
  Future<void> saveAttempt(Attempt attempt);
  Future<int> getAttemptCount(String participantId, String gymId);
  Future<Attempt?> getLastAttempt(String participantId, String gymId);
}
```

- [ ] **Step 1: Create the file**
- [ ] **Step 2: Run `flutter analyze`**
- [ ] **Step 3: Commit** — `git add -A && git commit -m "feat: add AttemptRepository interface"`

---

### Task 7: Extend AppDataSource with attempt methods

**Files:**
- Modify: `lib/data/datasources/app_data_source.dart`

**Changes:**

Add to the abstract class:
```dart
Future<List<Attempt>> loadAttempts();
Future<void> saveAttempt(Attempt attempt);
```

- [ ] **Step 1: Add methods**
- [ ] **Step 2: Run `flutter analyze`**
- [ ] **Step 3: Commit** — `git add -A && git commit -m "feat: extend AppDataSource with attempt storage"`

---

### Task 8: Implement attempt storage in MockLocalDataSource

**Files:**
- Modify: `lib/data/datasources/mock_local_data_source.dart`

**Changes:**

Add `_attempts` list, storage key, and implement `loadAttempts()`/`saveAttempt()`. Add to `reset()`.

- [ ] **Step 1: Add _attempts field and storage key**
- [ ] **Step 2: Implement loadAttempts() and saveAttempt()**
- [ ] **Step 3: Update reset()**
- [ ] **Step 4: Run `flutter analyze`**
- [ ] **Step 5: Commit** — `git add -A && git commit -m "feat: implement attempt storage in MockLocalDataSource"`

---

### Task 9: Implement AttemptRepository in MockAppRepository

**Files:**
- Modify: `lib/data/repositories/mock_app_repository.dart`

**Changes:**

Add `implements AttemptRepository` and implement all methods using the data source.

- [ ] **Step 1: Add AttemptRepository to implements clause**
- [ ] **Step 2: Implement all 5 methods**
- [ ] **Step 3: Run `flutter analyze`**
- [ ] **Step 4: Commit** — `git add -A && git commit -m "feat: implement AttemptRepository in MockAppRepository"`

---

### Task 10: Create CompleteChallengeUseCase

**Files:**
- Create: `lib/domain/use_cases/complete_challenge_use_case.dart`

**Content:**

```dart
import '../../core/utils/id_generator.dart';
import '../entities/attempt.dart';
import '../entities/treasure_item.dart';
import '../repositories/attempt_repository.dart';
import '../repositories/participant_repository.dart';
import '../repositories/treasure_repository.dart';

enum ChallengeFailure {
  participantNotFound,
  gymNotFound,
  notActive,
  alreadyCompleted,
  cooldownActive,
  invalidAnswer,
}

class ChallengeResult {
  const ChallengeResult.success({
    required this.gym,
    required this.pointsEarned,
    required this.totalPoints,
    required this.medals,
    this.completed = false,
  }) : failure = null;

  const ChallengeResult.failure(this.failure, {this.cooldownRemaining});

  final ChallengeFailure? failure;
  final TreasureItem? gym;
  final int? pointsEarned;
  final int? totalPoints;
  final int? medals;
  final bool completed;
  final Duration? cooldownRemaining;

  bool get isSuccess => failure == null;
}

class CompleteChallengeUseCase {
  CompleteChallengeUseCase({
    required TreasureRepository treasureRepository,
    required ParticipantRepository participantRepository,
    required AttemptRepository attemptRepository,
  })  : _treasureRepository = treasureRepository,
        _participantRepository = participantRepository,
        _attemptRepository = attemptRepository;

  final TreasureRepository _treasureRepository;
  final ParticipantRepository _participantRepository;
  final AttemptRepository _attemptRepository;

  static const cooldownDuration = Duration(minutes: 5);

  Future<ChallengeResult> execute({
    required String participantId,
    required String gymId,
    required String answer,
  }) async {
    // 1. Validate participant
    final participant = await _participantRepository.getParticipant(participantId);
    if (participant == null) {
      return ChallengeResult.failure(ChallengeFailure.participantNotFound);
    }

    // 2. Validate gym
    final gym = await _treasureRepository.getTreasure(gymId);
    if (gym == null) {
      return ChallengeResult.failure(ChallengeFailure.gymNotFound);
    }
    if (!gym.isActive) {
      return ChallengeResult.failure(ChallengeFailure.notActive);
    }

    // 3. Check if already completed
    if (participant.discoveredTreasureIds.contains(gymId)) {
      return ChallengeResult.failure(ChallengeFailure.alreadyCompleted);
    }

    // 4. Check cooldown
    final lastAttempt = await _attemptRepository.getLastAttempt(participantId, gymId);
    if (lastAttempt != null && !lastAttempt.correct) {
      final elapsed = DateTime.now().difference(lastAttempt.answeredAt);
      if (elapsed < cooldownDuration) {
        final remaining = cooldownDuration - elapsed;
        return ChallengeResult.failure(
          ChallengeFailure.cooldownActive,
          cooldownRemaining: remaining,
        );
      }
    }

    // 5. Validate answer
    final correct = _validateAnswer(gym, answer);

    // 6. Record attempt
    final attempt = Attempt(
      id: IdGenerator.discoveryId(),
      participantId: participantId,
      gymId: gymId,
      answeredAt: DateTime.now(),
      correct: correct,
      answer: answer,
    );
    await _attemptRepository.saveAttempt(attempt);

    if (!correct) {
      return ChallengeResult.failure(ChallengeFailure.invalidAnswer);
    }

    // 7. Award points and mark as discovered
    final updatedTreasures = [...participant.discoveredTreasureIds, gymId];
    final newMedals = updatedTreasures.length;
    final updatedParticipant = participant.copyWith(
      discoveredTreasureIds: updatedTreasures,
      points: participant.points + (gym.challenge?.points ?? gym.pointValue),
      medals: newMedals,
    );

    if (newMedals >= await _treasureRepository.getTreasures().then((t) => t.length)) {
      // All gyms completed
      await _participantRepository.updateParticipant(
        updatedParticipant.copyWith(
          status: ParticipantStatus.completed,
          completedAt: DateTime.now(),
        ),
      );
      return ChallengeResult.success(
        gym: gym,
        pointsEarned: gym.challenge?.points ?? gym.pointValue,
        totalPoints: updatedParticipant.points,
        medals: newMedals,
        completed: true,
      );
    }

    await _participantRepository.updateParticipant(updatedParticipant);

    return ChallengeResult.success(
      gym: gym,
      pointsEarned: gym.challenge?.points ?? gym.pointValue,
      totalPoints: updatedParticipant.points,
      medals: newMedals,
    );
  }

  bool _validateAnswer(TreasureItem gym, String answer) {
    final challenge = gym.challenge;
    if (challenge == null) return true; // QR-only gyms auto-pass
    if (challenge.correctAnswer == null) return true;
    return answer.trim().toLowerCase() == challenge.correctAnswer!.trim().toLowerCase();
  }
}
```

- [ ] **Step 1: Create the file**
- [ ] **Step 2: Run `flutter analyze`**
- [ ] **Step 3: Commit** — `git add -A && git commit -m "feat: add CompleteChallengeUseCase with cooldown and points"`

---

### Task 11: Update mock data — 8 themed gyms

**Files:**
- Modify: `lib/data/datasources/mock_data.dart`

**Changes:**

Replace the 10 generic treasures with 8 themed gyms:

```dart
static List<TreasureItem> buildTreasures() {
  return [
    TreasureItem(
      id: 'gym-android',
      title: 'Gimnasio Android',
      description: 'Demuestra que dominas Android, Kotlin y Jetpack Compose.',
      code: 'ANDROID-MASTER',
      qrValue: 'DEVFEST-GYM-ANDROID',
      clue: 'Busca el QR junto al stand de Android.',
      locationDescription: 'Stand de Android / KMP',
      iconKey: 'android',
      order: 1,
      isActive: true,
      challengeType: ChallengeType.code,
      challenge: GymChallenge(
        type: ChallengeType.code,
        question: '¿Qué herramienta de KMP convierte Flow y coroutines en algo idiomático para Swift?',
        options: ['SKIE', 'KotlinNatives', 'SwiftBridge', 'CoroutinesKit'],
        correctAnswer: 'SKIE',
        hint: 'Escuche la charla de KMP para saber la respuesta.',
        codeSnippet: 'fun fetchData(): Flow<Data> = flow { ... }',
        points: 15,
      ),
      gymName: 'Gimnasio Android',
      track: 'android',
      pointValue: 15,
    ),
    // ... 7 more gyms
  ];
}
```

**The 8 Gyms:**

| # | Gym | Track | Challenge Type | Points |
|---|-----|-------|---------------|--------|
| 1 | Gimnasio Android | android | code | 15 |
| 2 | Gimnasio IA & Agentes | ia | trivia | 20 |
| 3 | Gimnasio Cloud | cloud | trivia | 15 |
| 4 | Gimnasio Seguridad | security | riddle | 20 |
| 5 | Gimnasio Web & UX | web | trivia | 15 |
| 6 | Gimnasio Emprendimiento | startup | trivia | 10 |
| 7 | Gimnasio Speaker | speaker | trivia | 15 |
| 8 | Gimnasio Comunidad | community | qr | 10 |

- [ ] **Step 1: Replace buildTreasures() with 8 gyms**
- [ ] **Step 2: Update buildSeedParticipants() to use gym IDs**
- [ ] **Step 3: Update event name/description**
- [ ] **Step 4: Run `flutter analyze`**
- [ ] **Step 5: Commit** — `git add -A && git commit -m "feat: replace treasures with 8 themed DevFest Master gyms"`

---

### Task 12: Wire AttemptRepository in main.dart and app.dart

**Files:**
- Modify: `lib/main.dart`
- Modify: `lib/app/app.dart`

**Changes:**

Add `AttemptRepository` to the dependency graph:
```dart
final attemptRepository = MockAppRepository(dataSource);
// Pass to AppController
final controller = AppController(
  treasureRepository: attemptRepository,
  participantRepository: attemptRepository,
  leaderboardRepository: attemptRepository,
  eventRepository: attemptRepository,
  attemptRepository: attemptRepository,  // NEW
);
```

- [ ] **Step 1: Update main.dart dependencies**
- [ ] **Step 2: Update AppController constructor**
- [ ] **Step 3: Run `flutter analyze`**
- [ ] **Step 4: Commit** — `git add -A && git commit -m "feat: wire AttemptRepository in dependency graph"`

---

### Task 13: Update AppController with challenge state

**Files:**
- Modify: `lib/state/app_controller.dart`

**Changes:**

Add to AppController:
```dart
// New fields
final AttemptRepository _attemptRepository;
ChallengeResult? _lastChallengeResult;
bool _isOnCooldown = false;
Duration _cooldownRemaining = Duration.zero;

// New getters
ChallengeResult? get lastChallengeResult => _lastChallengeResult;
bool get isOnCooldown => _isOnCooldown;
Duration get cooldownRemaining => _cooldownRemaining;

// New actions
Future<void> submitChallenge(String gymId, String answer) async { ... }
void clearChallengeResult() { _lastChallengeResult = null; }
```

Update `discoverByCode` and `discoverByQrValue` to handle QR-only gyms (auto-pass) vs challenge gyms (redirect to challenge screen).

- [ ] **Step 1: Add new fields and constructor param**
- [ ] **Step 2: Implement submitChallenge()**
- [ ] **Step 3: Update discover methods for challenge flow**
- [ ] **Step 4: Run `flutter analyze`**
- [ ] **Step 5: Commit** — `git add -A && git commit -m "feat: add challenge state and submitChallenge to AppController"`

---

### Task 14: Create ChallengeScreen

**Files:**
- Create: `lib/ui/screens/challenge/challenge_screen.dart`

**Content:**

A full-screen challenge UI with:
- Gym name and track badge at top
- Challenge type indicator
- Timer (60s countdown) for trivia/code
- Question display
- Option buttons (trivia/code) or text input (riddle)
- Submit button
- Cooldown overlay when timer expires or wrong answer
- Success animation (medal earned)

- [ ] **Step 1: Create the screen widget**
- [ ] **Step 2: Implement timer logic**
- [ ] **Step 3: Implement answer submission**
- [ ] **Step 4: Add cooldown UI**
- [ ] **Step 5: Add success/error states**
- [ ] **Step 6: Run `flutter analyze`**
- [ ] **Step 7: Commit** — `git add -A && git commit -m "feat: create ChallengeScreen with timer and answer UI"`

---

### Task 15: Create PokédexScreen

**Files:**
- Create: `lib/ui/screens/pokedex/pokedex_screen.dart`

**Content:**

A grid of 8 gym badges:
- Each badge shows gym icon, name, and status
- Earned badges: colored with GDG palette, checkmark overlay
- Locked badges: grayed out with lock icon
- Tap earned badge → shows gym details
- Tap locked badge → shows challenge info

- [ ] **Step 1: Create the screen widget**
- [ ] **Step 2: Build badge grid**
- [ ] **Step 3: Add earned/locked states**
- [ ] **Step 4: Add detail view on tap**
- [ ] **Step 5: Run `flutter analyze`**
- [ ] **Step 6: Commit** — `git add -A && git commit -m "feat: create PokédexScreen with 8 gym badges"`

---

### Task 16: Update HomeDashboard with Pokédex preview

**Files:**
- Modify: `lib/ui/screens/home/home_dashboard.dart`

**Changes:**

Replace the treasure count section with a mini Pokédex preview:
- Show 8 small badge circles (earned = colored, locked = gray)
- Show level title (e.g., "Senior Dev")
- Show points total
- Keep stat cards but update labels (medals instead of remaining)

- [ ] **Step 1: Replace treasure count with badge row**
- [ ] **Step 2: Add level display**
- [ ] **Step 3: Update stat cards**
- [ ] **Step 4: Run `flutter analyze`**
- [ ] **Step 5: Commit** — `git add -A && git commit -m "feat: update HomeDashboard with Pokédex preview"`

---

### Task 17: Update TreasuresScreen to Gimnasios

**Files:**
- Modify: `lib/ui/screens/treasures/treasures_screen.dart`

**Changes:**

Rename the screen and update display:
- Title: "Mis Gimnasios"
- Show gym name, track badge, challenge type icon
- Status: earned (green check) vs available (blue) vs locked (gray)
- Points display per gym
- Tap available gym → navigate to ChallengeScreen

- [ ] **Step 1: Update screen title and section headers**
- [ ] **Step 2: Add track badge and challenge type icons**
- [ ] **Step 3: Add points display**
- [ ] **Step 4: Update tap navigation to ChallengeScreen**
- [ ] **Step 5: Run `flutter analyze`**
- [ ] **Step 6: Commit** — `git add -A && git commit -m "feat: update TreasuresScreen to Gimnasios with challenge types"`

---

### Task 18: Update HomeShell navigation

**Files:**
- Modify: `lib/ui/screens/home/home_shell.dart`

**Changes:**

- Tab 2 label: "Tesoros" → "Gimnasios"
- Tab 3 label: "Pistas" → "Retos"
- FAB: "Encontrar tesoro" → "Escanear QR"

- [ ] **Step 1: Update tab labels**
- [ ] **Step 2: Update FAB text**
- [ ] **Step 3: Run `flutter analyze`**
- [ ] **Step 4: Commit** — `git add -A && git commit -m "feat: update navigation labels for DevFest Master"`

---

### Task 19: Update WelcomeScreen for DevFest Master theme

**Files:**
- Modify: `lib/ui/screens/welcome/welcome_screen.dart`

**Changes:**

- Title: "DevFest Master"
- Subtitle: "Conquista los 8 Gimnasios Tecnológicos"
- Description: Update to match the Pokédex narrative
- Start button: "Comenzar aventura"
- Add avatar selection (emoji: 😎 🦊 🐉)

- [ ] **Step 1: Update title and subtitle**
- [ ] **Step 2: Update description text**
- [ ] **Step 3: Add avatar picker**
- [ ] **Step 4: Run `flutter analyze`**
- [ ] **Step 5: Commit** — `git add -A && git commit -m "feat: update WelcomeScreen for DevFest Master theme"`

---

### Task 20: Update app title and branding

**Files:**
- Modify: `lib/app/app.dart`

**Changes:**

```dart
title: 'DevFest Master',
```

- [ ] **Step 1: Update MaterialApp title**
- [ ] **Step 2: Run `flutter analyze`**
- [ ] **Step 3: Commit** — `git add -A && git commit -m "feat: rename app to DevFest Master"`

---

### Task 21: Final verification

- [ ] **Step 1: Run `flutter analyze`**
- [ ] **Step 2: Run `flutter build web --release`**
- [ ] **Step 3: Visual smoke test**
  - Welcome screen shows "DevFest Master" with avatar picker
  - Home shows 8 badge previews with level
  - Gimnasios screen shows 8 gyms with types
  - Tapping a gym navigates to ChallengeScreen
  - Timer counts down, answer submission works
  - Cooldown displays correctly
  - Pokédex shows earned/locked badges
  - Leaderboard sorts by points
- [ ] **Step 4: Commit final fixes if needed**
