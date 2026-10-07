# Admin Community Signal Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a Staff Panel flow to validate Community Signal evidence and grant the Community medal.

**Architecture:** Reuse the existing admin participant detail bottom sheet and existing `AppController.grantMedal` method. Add a special `Validar Community Signal` action only when `gym-community` is missing, confirm the action in a dialog, then refresh the bottom sheet state.

**Tech Stack:** Flutter, Dart, `flutter_test`, existing `AppController`/`AppScope` state.

---

## File Structure

- Modify: `lib/ui/screens/admin/admin_dashboard_screen.dart`
  - Responsibility: Staff Panel UI and participant detail actions.
  - Change: show a highlighted Community Signal validation action and confirmation dialog.
- Modify: `test/widgets/admin_dashboard_test.dart`
  - Responsibility: widget-level Staff Panel tests.
  - Change: add a test for validating Community Signal from participant detail.
- Create: `docs/superpowers/specs/2026-10-07-admin-community-signal-design.md`
  - Responsibility: document the approved scope.

---

### Task 1: Community Signal Staff Action

**Files:**
- Modify: `test/widgets/admin_dashboard_test.dart`
- Modify: `lib/ui/screens/admin/admin_dashboard_screen.dart`

- [ ] **Step 1: Write failing widget test**

Append this test inside `main()` in `test/widgets/admin_dashboard_test.dart`:

```dart
  testWidgets('staff can validate community signal from participant detail', (
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

    expect(find.text('Validar Community Signal'), findsOneWidget);

    await tester.tap(find.text('Validar Community Signal'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Validar evidencia'));
    await tester.pumpAndSettle();

    final updated = await repository.getParticipant('participant-admin-ui');
    expect(updated!.discoveredTreasureIds, contains('gym-community'));
    expect(updated.points, 100);
    expect(find.textContaining('1/8 medallas'), findsOneWidget);
    expect(find.text('Validar Community Signal'), findsNothing);
  });
```

- [ ] **Step 2: Run widget test to verify it fails**

Run:

```bash
flutter test test/widgets/admin_dashboard_test.dart
```

Expected: FAIL because `Validar Community Signal` is not rendered yet.

- [ ] **Step 3: Add highlighted action and remove duplicate generic Community button**

In `lib/ui/screens/admin/admin_dashboard_screen.dart`, inside `_showParticipantDetail`, after `missing` is created, add:

```dart
            final missingCommunity = missing
                .where((t) => t.id == 'gym-community')
                .firstOrNull;
```

Because `firstOrNull` is not available, instead use this local helper code:

```dart
            TreasureItem? missingCommunity;
            for (final treasure in missing) {
              if (treasure.id == 'gym-community') {
                missingCommunity = treasure;
                break;
              }
            }
```

In the detail `Column`, after the `Ajustar puntos` button and before the `SizedBox(height: 16)`, add:

```dart
                    if (missingCommunity != null) ...[
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: FilledButton.icon(
                          onPressed: () => _confirmCommunitySignal(
                            context,
                            participant.id,
                            setSheetState,
                          ),
                          icon: const Icon(Icons.groups_rounded),
                          label: const Text('Validar Community Signal'),
                        ),
                      ),
                    ],
```

Update the generic missing-medal loop so it skips `gym-community`:

```dart
                        for (final treasure in missing)
                          if (treasure.id != 'gym-community')
                            OutlinedButton(
                              onPressed: () async {
                                await controller.grantMedal(
                                  participantId: participant.id,
                                  gymId: treasure.id,
                                );
                                setSheetState(() {});
                              },
                              child: Text(
                                'Otorgar ${_adminGymLabel(treasure.track, treasure.gymName ?? treasure.title)}',
                              ),
                            ),
```

- [ ] **Step 4: Add confirmation dialog helper**

Add this method to `_ParticipantsListBodyState` before `_adminGymLabel`:

```dart
  Future<void> _confirmCommunitySignal(
    BuildContext context,
    String participantId,
    StateSetter setSheetState,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Validar Community Signal',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          'Confirma que staff reviso la evidencia y otorgara la medalla Comunidad.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Validar evidencia'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    await AppScope.read(context).grantMedal(
      participantId: participantId,
      gymId: 'gym-community',
    );
    setSheetState(() {});
  }
```

- [ ] **Step 5: Run widget test to verify it passes**

Run:

```bash
flutter test test/widgets/admin_dashboard_test.dart
```

Expected: PASS.

---

### Task 2: Final Verification

**Files:**
- Modify: `lib/ui/screens/admin/admin_dashboard_screen.dart`
- Modify: `test/widgets/admin_dashboard_test.dart`
- Create: `docs/superpowers/specs/2026-10-07-admin-community-signal-design.md`

- [ ] **Step 1: Format changed Dart files**

Run:

```bash
dart format lib/ui/screens/admin/admin_dashboard_screen.dart test/widgets/admin_dashboard_test.dart
```

Expected: formatting completes successfully.

- [ ] **Step 2: Run related tests**

Run:

```bash
flutter test test/widgets/admin_dashboard_test.dart test/state/admin_controller_test.dart
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

Expected: only intended Community Signal files and docs are modified or untracked.
