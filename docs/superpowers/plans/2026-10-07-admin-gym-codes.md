# Admin Gym Codes Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Show each gym's manual code and QR value in the Staff Panel so staff has an event-day fallback without opening source files.

**Architecture:** Keep the existing `Gestion de tesoros` section as the single operational place for gym controls. Pass the full `TreasureItem` into `_TreasureRow` and render `code` plus `qrValue` in the row subtitle, without changing domain entities, repositories, or use cases.

**Tech Stack:** Flutter, Dart, `flutter_test`, existing `AppController`/`AppScope` state.

---

## File Structure

- Modify: `lib/ui/screens/admin/admin_dashboard_screen.dart`
  - Responsibility: render the Staff Panel and gym management rows.
  - Change: `_TreasureManagement` passes each `TreasureItem` into `_TreasureRow`; `_TreasureRow` displays title, discoveries, manual code, and QR value.
- Modify: `test/widgets/admin_dashboard_test.dart`
  - Responsibility: widget-level coverage for Staff Panel behavior.
  - Change: add a test asserting a seeded gym code and QR value are visible in the Staff Panel.

---

### Task 1: Show Manual Codes And QR Values

**Files:**
- Modify: `test/widgets/admin_dashboard_test.dart`
- Modify: `lib/ui/screens/admin/admin_dashboard_screen.dart`

- [ ] **Step 1: Write the failing widget test**

Append this test to `test/widgets/admin_dashboard_test.dart` inside `main()` after the existing test:

```dart
  testWidgets('staff can see gym manual codes and qr values', (tester) async {
    await tester.pumpWidget(
      AppScope(
        controller: controller,
        child: const MaterialApp(home: AdminDashboardScreen()),
      ),
    );
    await tester.pump();

    expect(find.textContaining('Codigo manual: ANDROID-MASTER'), findsOneWidget);
    expect(find.textContaining('QR: DEVFEST-GYM-ANDROID'), findsOneWidget);
  });
```

- [ ] **Step 2: Run the test to verify it fails**

Run:

```bash
flutter test test/widgets/admin_dashboard_test.dart
```

Expected: FAIL because the Staff Panel does not yet render `Codigo manual: ANDROID-MASTER` or `QR: DEVFEST-GYM-ANDROID`.

- [ ] **Step 3: Implement the minimal UI change**

In `lib/ui/screens/admin/admin_dashboard_screen.dart`, update `_TreasureManagement` so `_TreasureRow` receives the full treasure:

```dart
          for (final t in treasures)
            _TreasureRow(
              key: ValueKey(t.id),
              treasure: t,
              discoverCount: controller.participants
                  .where((p) => p.discoveredTreasureIds.contains(t.id))
                  .length,
              onChanged: (v) => controller.setTreasureActive(t.id, v),
            ),
```

Replace `_TreasureRow` with this implementation:

```dart
class _TreasureRow extends StatelessWidget {
  const _TreasureRow({
    super.key,
    required this.treasure,
    required this.discoverCount,
    required this.onChanged,
  });

  final TreasureItem treasure;
  final int discoverCount;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      leading: StatusPill(
        label: treasure.isActive ? 'Activo' : 'Inactivo',
        color: treasure.isActive ? AppColors.success : AppColors.danger,
        icon: treasure.isActive ? Icons.check_circle_rounded : Icons.lock_rounded,
      ),
      title: Text(treasure.title, style: const TextStyle(fontSize: 13.5)),
      subtitle: Text(
        'Descubrimientos: $discoverCount\n'
        'Codigo manual: ${treasure.code}\n'
        'QR: ${treasure.qrValue}',
        style: const TextStyle(fontSize: 12),
      ),
      trailing: Switch(
        value: treasure.isActive,
        onChanged: onChanged,
        activeTrackColor: AppColors.primary,
      ),
    );
  }
}
```

- [ ] **Step 4: Run the focused widget test**

Run:

```bash
flutter test test/widgets/admin_dashboard_test.dart
```

Expected: PASS.

- [ ] **Step 5: Run related admin/controller tests**

Run:

```bash
flutter test test/widgets/admin_dashboard_test.dart test/state/admin_controller_test.dart
```

Expected: PASS.

- [ ] **Step 6: Run formatting**

Run:

```bash
dart format lib/ui/screens/admin/admin_dashboard_screen.dart test/widgets/admin_dashboard_test.dart
```

Expected: files formatted successfully.

- [ ] **Step 7: Run final verification**

Run:

```bash
flutter test test/widgets/admin_dashboard_test.dart test/state/admin_controller_test.dart
```

Expected: PASS.
