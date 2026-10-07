# Firebase Firestore MVP Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add an optional Firebase/Firestore data source for centralized event data while preserving the existing app behavior.

**Architecture:** Keep the repository and UI layers unchanged by implementing `FirebaseDataSource implements AppDataSource`. Initialize Firebase from checked-in Flutter options, seed event/gym data from `MockData` when Firestore is empty, and wire `buildAppDependencies` to try Firebase first with local fallback.

**Tech Stack:** Flutter, Dart, Firebase Core, Cloud Firestore, existing repository/data-source architecture.

---

## File Structure

- Modify: `pubspec.yaml`
  - Add `firebase_core` and `cloud_firestore`.
- Create: `lib/firebase_options.dart`
  - Flutter Firebase web config for project `devfest-master`.
- Create: `lib/data/datasources/firebase_data_source.dart`
  - Implements `AppDataSource` against Firestore.
- Modify: `lib/app/app.dart`
  - Try Firebase data source first, fallback to local data source on initialization failure.
- Modify: `docs/FIREBASE_MIGRATION.md`
  - Update with current Firestore MVP status and operational rules.
- Create: `docs/superpowers/specs/2026-10-07-firebase-firestore-mvp-design.md`
  - Captures approved scope.

---

### Task 1: Add Firebase Dependencies And Options

**Files:**
- Modify: `pubspec.yaml`
- Create: `lib/firebase_options.dart`

- [ ] **Step 1: Add dependencies**

Run:

```bash
flutter pub add firebase_core cloud_firestore
```

Expected: `pubspec.yaml` and `pubspec.lock` update with Firebase packages.

- [ ] **Step 2: Create Firebase options**

Create `lib/firebase_options.dart` with the web configuration for `devfest-master` and a default options switch that supports web.

- [ ] **Step 3: Run dependency resolution check**

Run:

```bash
flutter pub get
```

Expected: completes successfully.

---

### Task 2: Implement FirebaseDataSource

**Files:**
- Create: `lib/data/datasources/firebase_data_source.dart`

- [ ] **Step 1: Implement Firestore data source**

Create a class `FirebaseDataSource implements AppDataSource` with:

- `initialize()` seeds `events/devfest-2026` and treasures if missing.
- `loadEvent()` reads event document.
- `loadTreasures()` reads ordered treasures.
- `saveTreasures()` writes treasures by document id.
- `loadParticipants()` reads participants.
- `saveParticipant()` upserts participant by id.
- `loadDiscoveries()` reads flat `discoveries` collection.
- `saveDiscovery()` upserts discovery by id.
- `loadAttempts()` reads flat `attempts` collection.
- `saveAttempt()` upserts attempt by id.
- `getCurrentParticipantId()` and `setCurrentParticipantId()` use `SharedPrefsLocalStorage`, because current participant is device/session state.
- `reset()` clears participants, discoveries and attempts, and restores seeded treasures.

- [ ] **Step 2: Run analyzer via tests**

Run:

```bash
flutter test test/state/admin_controller_test.dart
```

Expected: compiles and passes, even though tests still use mock data source.

---

### Task 3: Wire Firebase With Local Fallback

**Files:**
- Modify: `lib/app/app.dart`

- [ ] **Step 1: Update app dependency factory**

In `buildAppDependencies`, create `SharedPrefsLocalStorage`, try `FirebaseDataSource(storage: storage)`, and return `MockAppRepository(firebaseDataSource)` if initialization succeeds. If any exception occurs, initialize and return `MockLocalDataSource(storage: storage)`.

- [ ] **Step 2: Run app tests**

Run:

```bash
flutter test
```

Expected: PASS.

---

### Task 4: Document Operational Rules

**Files:**
- Modify: `docs/FIREBASE_MIGRATION.md`

- [ ] **Step 1: Update Firebase migration doc**

Add a section for the current MVP:

- Project: `devfest-master`
- Firestore location: `nam5`
- App uses Firebase first with local fallback.
- Staff does not edit questions/responses.
- QR values are generated and printed externally.
- Ranking is client-calculated for now.
- Before production, replace test-mode Firestore rules with restricted rules.

- [ ] **Step 2: Run final verification**

Run:

```bash
flutter test
```

Expected: PASS.

- [ ] **Step 3: Try web build**

Run:

```bash
flutter build web
```

Expected: build succeeds.

- [ ] **Step 4: Inspect git status**

Run:

```bash
git status --short
```

Expected: only intended Firebase files, docs, and pubspec/lock are modified.
