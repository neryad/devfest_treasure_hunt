# Admin Manual Points Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Let staff adjust a participant's points from the Staff Panel using a positive or negative delta.

**Architecture:** Add the point adjustment as a staff operation on `AppController`, using the existing `ParticipantRepository.updateParticipant` and leaderboard reload path. Add a small dialog in the existing participant detail bottom sheet; the dialog parses an integer delta, previews the resulting total, and calls the controller method.

**Tech Stack:** Flutter, Dart, `flutter_test`, existing `AppController`/`AppScope` state.

---

## File Structure

- Modify: `lib/state/app_controller.dart`
  - Responsibility: central state and staff actions.
  - Change: add `adjustParticipantPoints(participantId, delta)` that clamps total points to zero, saves participant, reloads ranking, and notifies listeners.
- Modify: `test/state/admin_controller_test.dart`
  - Responsibility: controller-level staff behavior tests.
  - Change: add tests for positive adjustment, negative adjustment, zero clamp, and missing participant.
- Modify: `lib/ui/screens/admin/admin_dashboard_screen.dart`
  - Responsibility: Staff Panel UI and participant detail bottom sheet.
  - Change: add `Ajustar puntos` button and dialog in participant detail.
- Modify: `test/widgets/admin_dashboard_test.dart`
  - Responsibility: widget-level Staff Panel tests.
  - Change: add a test that opens participant detail, applies `+50`, and sees updated points.

---

### Task 1: Controller Point Adjustment

**Files:**
- Modify: `test/state/admin_controller_test.dart`
- Modify: `lib/state/app_controller.dart`

- [ ] **Step 1: Write failing controller tests**

Append these tests inside `main()` in `test/state/admin_controller_test.dart`:

```dart
  test('staff can add points manually and refresh ranking', () async {
    final participant = await repository.createParticipant(
      id: 'participant-points-add',
      name: 'Points Add',
      nickname: 'points_add',
      startedAt: DateTime.now(),
    );
    await controller.initialize();

    final adjusted = await controller.adjustParticipantPoints(
      participantId: participant.id,
      delta: 50,
    );

    expect(adjusted, isTrue);
    final updated = await repository.getParticipant(participant.id);
    expect(updated!.points, 50);
    expect(controller.participants.single.points, 50);
    expect(controller.leaderboard.single.points, 50);
  });

  test('staff can subtract points manually', () async {
    final participant = await repository.createParticipant(
      id: 'participant-points-subtract',
      name: 'Points Subtract',
      nickname: 'points_subtract',
      startedAt: DateTime.now(),
    );
    await controller.initialize();
    await controller.adjustParticipantPoints(
      participantId: participant.id,
      delta: 80,
    );

    final adjusted = await controller.adjustParticipantPoints(
      participantId: participant.id,
      delta: -30,
    );

    expect(adjusted, isTrue);
    final updated = await repository.getParticipant(participant.id);
    expect(updated!.points, 50);
    expect(controller.leaderboard.single.points, 50);
  });

  test('manual point adjustment cannot reduce total below zero', () async {
    final participant = await repository.createParticipant(
      id: 'participant-points-clamp',
      name: 'Points Clamp',
      nickname: 'points_clamp',
      startedAt: DateTime.now(),
    );
    await controller.initialize();

    final adjusted = await controller.adjustParticipantPoints(
      participantId: participant.id,
      delta: -100,
    );

    expect(adjusted, isTrue);
    final updated = await repository.getParticipant(participant.id);
    expect(updated!.points, 0);
    expect(controller.leaderboard.single.points, 0);
  });

  test('manual point adjustment fails for missing participant', () async {
    expect(
      await controller.adjustParticipantPoints(
        participantId: 'missing-participant',
        delta: 50,
      ),
      isFalse,
    );
    expect(controller.participants, isEmpty);
    expect(controller.leaderboard, isEmpty);
  });
```

- [ ] **Step 2: Run controller tests to verify they fail**

Run:

```bash
flutter test test/state/admin_controller_test.dart
```

Expected: FAIL because `adjustParticipantPoints` is not defined.

- [ ] **Step 3: Implement controller method**

In `lib/state/app_controller.dart`, add this method after `grantMedal` and before `resetDemo`:

```dart
  Future<bool> adjustParticipantPoints({
    required String participantId,
    required int delta,
  }) async {
    final participant = await _participantRepository.getParticipant(
      participantId,
    );
    if (participant == null) return false;

    final updatedPoints = (participant.points + delta).clamp(0, 1 << 31);
    final updated = participant.copyWith(points: updatedPoints);

    await _participantRepository.updateParticipant(updated);
    if (_participant?.id == participantId) {
      _participant = updated;
    }
    await _reloadLeaderboard();
    notifyListeners();
    return true;
  }
```

- [ ] **Step 4: Run controller tests to verify they pass**

Run:

```bash
flutter test test/state/admin_controller_test.dart
```

Expected: PASS.

---

### Task 2: Staff Panel Point Adjustment Dialog

**Files:**
- Modify: `test/widgets/admin_dashboard_test.dart`
- Modify: `lib/ui/screens/admin/admin_dashboard_screen.dart`

- [ ] **Step 1: Write failing widget test**

Append this test inside `main()` in `test/widgets/admin_dashboard_test.dart`:

```dart
  testWidgets('staff can adjust participant points from detail', (
    tester,
  ) async {
    await tester.pumpWidget(
      AppScope(
        controller: controller,
        child: const MaterialApp(home: AdminDashboardScreen()),
      ),
    );
    await tester.pump();

    await tester.scrollUntilVisible(
      find.byKey(const Key('admin-participant-search')),
      500,
    );
    await tester.enterText(
      find.byKey(const Key('admin-participant-search')),
      'admin_ui',
    );
    await tester.pump();
    await tester.tap(find.text('Admin UI (admin_ui)'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Ajustar puntos'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('admin-points-delta')), '50');
    await tester.pump();
    await tester.tap(find.text('Aplicar ajuste'));
    await tester.pumpAndSettle();

    expect(find.textContaining('50 pts'), findsOneWidget);
  });
```

- [ ] **Step 2: Run widget tests to verify the new test fails**

Run:

```bash
flutter test test/widgets/admin_dashboard_test.dart
```

Expected: FAIL because `Ajustar puntos` is not rendered yet.

- [ ] **Step 3: Add point adjustment button to participant detail**

In `lib/ui/screens/admin/admin_dashboard_screen.dart`, inside the participant detail `Column`, after the points/medals `Text` and before the `SizedBox(height: 16)`, add:

```dart
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: OutlinedButton.icon(
                        onPressed: () => _showPointAdjustmentDialog(
                          context,
                          participant.id,
                          participant.points,
                          setSheetState,
                        ),
                        icon: const Icon(Icons.add_chart_rounded),
                        label: const Text('Ajustar puntos'),
                      ),
                    ),
```

- [ ] **Step 4: Add point adjustment dialog helper**

In `_ParticipantsListBodyState`, add this method after `_showParticipantDetail`:

```dart
  Future<void> _showPointAdjustmentDialog(
    BuildContext context,
    String participantId,
    int currentPoints,
    StateSetter setSheetState,
  ) async {
    final deltaController = TextEditingController();
    String? error;
    int delta = 0;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          final newTotal = (currentPoints + delta).clamp(0, 1 << 31);
          return AlertDialog(
            backgroundColor: AppColors.surface,
            title: const Text(
              'Ajustar puntos',
              style: TextStyle(color: AppColors.textPrimary),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Puntos actuales: $currentPoints',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 12),
                TextField(
                  key: const Key('admin-points-delta'),
                  controller: deltaController,
                  keyboardType: const TextInputType.numberWithOptions(
                    signed: true,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Ajuste (+/-)',
                    errorText: error,
                  ),
                  onChanged: (value) {
                    setDialogState(() {
                      error = null;
                      delta = int.tryParse(value.trim()) ?? 0;
                    });
                  },
                ),
                const SizedBox(height: 12),
                Text(
                  'Nuevo total: $newTotal',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () async {
                  final parsed = int.tryParse(deltaController.text.trim());
                  if (parsed == null) {
                    setDialogState(() {
                      error = 'Introduce un numero entero';
                    });
                    return;
                  }
                  await AppScope.read(context).adjustParticipantPoints(
                    participantId: participantId,
                    delta: parsed,
                  );
                  setSheetState(() {});
                  if (dialogContext.mounted) {
                    Navigator.of(dialogContext).pop();
                  }
                },
                child: const Text('Aplicar ajuste'),
              ),
            ],
          );
        },
      ),
    );

    deltaController.dispose();
  }
```

- [ ] **Step 5: Run widget tests to verify they pass**

Run:

```bash
flutter test test/widgets/admin_dashboard_test.dart
```

Expected: PASS.

---

### Task 3: Final Verification

**Files:**
- Modify: `lib/state/app_controller.dart`
- Modify: `lib/ui/screens/admin/admin_dashboard_screen.dart`
- Modify: `test/state/admin_controller_test.dart`
- Modify: `test/widgets/admin_dashboard_test.dart`
- Create: `docs/superpowers/specs/2026-10-07-admin-manual-points-design.md`

- [ ] **Step 1: Format changed files**

Run:

```bash
dart format lib/state/app_controller.dart lib/ui/screens/admin/admin_dashboard_screen.dart test/state/admin_controller_test.dart test/widgets/admin_dashboard_test.dart
```

Expected: formatting completes successfully.

- [ ] **Step 2: Run related tests**

Run:

```bash
flutter test test/state/admin_controller_test.dart test/widgets/admin_dashboard_test.dart test/widgets/admin_ranking_csv_test.dart
```

Expected: PASS.

- [ ] **Step 3: Run full test suite**

Run:

```bash
flutter test
```

Expected: PASS.

- [ ] **Step 4: Inspect status**

Run:

```bash
git status --short
```

Expected: only intended manual points files and docs are modified or untracked.
