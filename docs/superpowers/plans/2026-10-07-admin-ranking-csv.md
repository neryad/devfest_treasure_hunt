# Admin Ranking CSV Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a Staff Panel action that copies the current leaderboard as CSV to the clipboard.

**Architecture:** Put CSV formatting in a small helper file so it can be tested without widget internals. Keep the UI change inside the existing admin ranking card: add a button that builds CSV from `controller.leaderboard`, copies it with Flutter `Clipboard`, and shows a confirmation `SnackBar`.

**Tech Stack:** Flutter, Dart, `flutter/services.dart` Clipboard API, `flutter_test`.

---

## File Structure

- Create: `lib/ui/screens/admin/admin_ranking_csv.dart`
  - Responsibility: convert `List<LeaderboardEntry>` into CSV text and escape CSV cells.
- Create: `test/widgets/admin_ranking_csv_test.dart`
  - Responsibility: unit tests for headers, row content, and CSV escaping.
- Modify: `lib/ui/screens/admin/admin_dashboard_screen.dart`
  - Responsibility: render the Staff Panel and invoke clipboard copy from the Ranking section.
- Modify: `test/widgets/admin_dashboard_test.dart`
  - Responsibility: widget tests confirming the Staff Panel exposes the CSV copy action.

---

### Task 1: CSV Formatter

**Files:**
- Create: `test/widgets/admin_ranking_csv_test.dart`
- Create: `lib/ui/screens/admin/admin_ranking_csv.dart`

- [ ] **Step 1: Write failing formatter tests**

Create `test/widgets/admin_ranking_csv_test.dart` with:

```dart
import 'package:devfest_treasure_hunt/domain/entities/leaderboard_entry.dart';
import 'package:devfest_treasure_hunt/domain/entities/participant.dart';
import 'package:devfest_treasure_hunt/ui/screens/admin/admin_ranking_csv.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('builds ranking csv with headers and rows', () {
    final csv = buildAdminRankingCsv([
      const LeaderboardEntry(
        participantId: 'participant-1',
        name: 'Ada Lovelace',
        nickname: 'ada',
        discoveredCount: 8,
        totalTreasures: 8,
        elapsed: Duration(minutes: 42, seconds: 5),
        status: ParticipantStatus.completed,
        position: 1,
        points: 930,
      ),
    ]);

    expect(
      csv,
      'position,name,nickname,points,medals,total_medals,elapsed,status\n'
      '1,Ada Lovelace,ada,930,8,8,00:42:05,completed',
    );
  });

  test('escapes csv cells that contain commas quotes or line breaks', () {
    final csv = buildAdminRankingCsv([
      const LeaderboardEntry(
        participantId: 'participant-2',
        name: 'Grace, "Bug" Hopper',
        nickname: 'line\nbreak',
        discoveredCount: 3,
        totalTreasures: 8,
        elapsed: Duration(seconds: 7),
        status: ParticipantStatus.active,
        position: 2,
        points: 300,
      ),
    ]);

    expect(
      csv,
      'position,name,nickname,points,medals,total_medals,elapsed,status\n'
      '2,"Grace, ""Bug"" Hopper","line\nbreak",300,3,8,00:00:07,active',
    );
  });

  test('empty ranking csv contains only headers', () {
    expect(
      buildAdminRankingCsv(const []),
      'position,name,nickname,points,medals,total_medals,elapsed,status',
    );
  });
}
```

- [ ] **Step 2: Run formatter tests to verify they fail**

Run:

```bash
flutter test test/widgets/admin_ranking_csv_test.dart
```

Expected: FAIL because `admin_ranking_csv.dart` does not exist.

- [ ] **Step 3: Implement CSV formatter**

Create `lib/ui/screens/admin/admin_ranking_csv.dart` with:

```dart
import '../../../domain/entities/leaderboard_entry.dart';

const _headers = [
  'position',
  'name',
  'nickname',
  'points',
  'medals',
  'total_medals',
  'elapsed',
  'status',
];

String buildAdminRankingCsv(List<LeaderboardEntry> entries) {
  final rows = [
    _headers,
    for (final entry in entries)
      [
        entry.position.toString(),
        entry.name,
        entry.nickname,
        entry.points.toString(),
        entry.discoveredCount.toString(),
        entry.totalTreasures.toString(),
        entry.elapsedLabel,
        entry.status.name,
      ],
  ];

  return rows.map((row) => row.map(_escapeCsvCell).join(',')).join('\n');
}

String _escapeCsvCell(String value) {
  final escaped = value.replaceAll('"', '""');
  if (escaped.contains(',') || escaped.contains('"') || escaped.contains('\n')) {
    return '"$escaped"';
  }
  return escaped;
}
```

- [ ] **Step 4: Run formatter tests to verify they pass**

Run:

```bash
flutter test test/widgets/admin_ranking_csv_test.dart
```

Expected: PASS.

---

### Task 2: Staff Panel Copy Button

**Files:**
- Modify: `lib/ui/screens/admin/admin_dashboard_screen.dart`
- Modify: `test/widgets/admin_dashboard_test.dart`

- [ ] **Step 1: Write failing widget test for the copy action**

Append this test inside `main()` in `test/widgets/admin_dashboard_test.dart`:

```dart
  testWidgets('staff can copy ranking csv from the ranking section', (
    tester,
  ) async {
    await tester.pumpWidget(
      AppScope(
        controller: controller,
        child: const MaterialApp(home: AdminDashboardScreen()),
      ),
    );
    await tester.pump();

    expect(find.text('Copiar ranking CSV'), findsOneWidget);
  });
```

- [ ] **Step 2: Run widget tests to verify the new test fails**

Run:

```bash
flutter test test/widgets/admin_dashboard_test.dart
```

Expected: FAIL because the button is not rendered yet.

- [ ] **Step 3: Implement the copy button**

In `lib/ui/screens/admin/admin_dashboard_screen.dart`, add imports:

```dart
import 'package:flutter/services.dart';

import 'admin_ranking_csv.dart';
```

Replace `_AdminRanking` with:

```dart
class _AdminRanking extends StatelessWidget {
  const _AdminRanking();

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final top = controller.leaderboard.take(5).toList();

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: OutlinedButton.icon(
              onPressed: () => _copyRankingCsv(context),
              icon: const Icon(Icons.copy_rounded),
              label: const Text('Copiar ranking CSV'),
            ),
          ),
          for (final entry in top)
            ListTile(
              dense: true,
              leading: Text(
                '#${entry.position}',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  color: AppColors.amber,
                ),
              ),
              title: Text(
                '${entry.name} (${entry.nickname})',
                style: const TextStyle(fontSize: 14),
              ),
              trailing: Text(
                '${entry.discoveredCount}/${entry.totalTreasures} · '
                '${formatElapsed(entry.elapsed)}',
                style: const TextStyle(
                  fontSize: 12.5,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          if (top.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Sin datos'),
            ),
        ],
      ),
    );
  }

  Future<void> _copyRankingCsv(BuildContext context) async {
    final csv = buildAdminRankingCsv(AppScope.read(context).leaderboard);
    await Clipboard.setData(ClipboardData(text: csv));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ranking CSV copiado')),
    );
  }
}
```

- [ ] **Step 4: Run widget tests to verify they pass**

Run:

```bash
flutter test test/widgets/admin_dashboard_test.dart
```

Expected: PASS.

---

### Task 3: Final Verification

**Files:**
- Modify: `lib/ui/screens/admin/admin_dashboard_screen.dart`
- Create: `lib/ui/screens/admin/admin_ranking_csv.dart`
- Modify: `test/widgets/admin_dashboard_test.dart`
- Create: `test/widgets/admin_ranking_csv_test.dart`

- [ ] **Step 1: Format changed Dart files**

Run:

```bash
dart format lib/ui/screens/admin/admin_dashboard_screen.dart lib/ui/screens/admin/admin_ranking_csv.dart test/widgets/admin_dashboard_test.dart test/widgets/admin_ranking_csv_test.dart
```

Expected: formatting completes successfully.

- [ ] **Step 2: Run related tests**

Run:

```bash
flutter test test/widgets/admin_dashboard_test.dart test/widgets/admin_ranking_csv_test.dart test/state/admin_controller_test.dart
```

Expected: PASS.

- [ ] **Step 3: Inspect status**

Run:

```bash
git status --short
```

Expected: only intended admin CSV, docs, and prior admin files are modified or untracked.
