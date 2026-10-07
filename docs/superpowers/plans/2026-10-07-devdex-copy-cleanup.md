# DevDex Copy Cleanup Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Remove legacy treasure-hunt wording from the visible demo flow and present the badge collection as DevDex.

**Architecture:** Keep internal class/entity names unchanged. Only update visible text and primary navigation in Home/Admin screens, plus widget tests that assert visible labels.

**Tech Stack:** Flutter, Dart, `flutter_test`.

---

## Task 1: Navigation And Home Copy

**Files:**
- Modify: `lib/ui/screens/home/home_shell.dart`
- Modify: `lib/ui/screens/home/home_dashboard.dart`
- Modify: `test/widgets/app_flow_test.dart`

- [ ] Hide `CluesScreen` from bottom navigation.
- [ ] Rename visible `Pokédex` labels to `DevDex`.
- [ ] Remove the `Mis pistas` quick action.
- [ ] Change Home quick action copy from treasure/pistas to gimnasio/medallas.
- [ ] Update affected widget tests.
- [ ] Run `flutter test test/widgets/app_flow_test.dart`.

## Task 2: Admin And DevDex Copy

**Files:**
- Modify: `lib/ui/screens/admin/admin_dashboard_screen.dart`
- Modify: `lib/ui/screens/pokedex/pokedex_screen.dart`
- Modify: `test/widgets/admin_dashboard_test.dart`

- [ ] Rename admin visible labels from tesoros to gimnasios/medallas.
- [ ] Rename Pokedex visible labels to DevDex where applicable.
- [ ] Run `flutter test test/widgets/admin_dashboard_test.dart`.

## Task 3: Verification

- [ ] Run `dart format` on changed Dart files.
- [ ] Run `flutter test`.
- [ ] Run `flutter build web`.
- [ ] Inspect `git status --short`.
