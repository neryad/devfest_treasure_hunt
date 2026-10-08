# GDG Brand Rebrand Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Rebrand the DevFest Treasure Hunt app from its custom dark navy/purple palette to the official GDG (Google Developer Groups) brand colors, maintaining dark theme while adopting Google's color identity.

**Architecture:** Update the centralized `AppColors` palette in `app_theme.dart` to map GDG core colors (Blue #4285F4, Green #34A853, Yellow #F9AB00, Red #EA4335), halftones, and pastels. All downstream UI files reference `AppColors.*` constants, so updating the source-of-truth propagates changes automatically. A few files with hardcoded color values need manual updates.

**Tech Stack:** Flutter/Dart, Material 3

---

## Color Mapping

### AppColors → GDG Brand

| Old Constant | Old Value | New Value | GDG Role |
|---|---|---|---|
| `background` | `#0A0E21` | `#1E1E1E` | Dark neutral |
| `backgroundGradientTop` | `#141B3F` | `#2D2D2D` | Dark neutral lighter |
| `surface` | `#171E44` | `#2D2D2D` | Dark surface |
| `surfaceAlt` | `#20285A` | `#3C4043` | Dark surface elevated |
| `primary` | `#7C6CFF` | `#4285F4` | GDG Blue |
| `primarySoft` | `#9B8FFF` | `#57CAFF` | Halftone Blue |
| `secondary` | `#00E0C6` | `#34A853` | GDG Green |
| `amber` | `#FFB020` | `#F9AB00` | GDG Yellow |
| `danger` | `#FF6B6B` | `#EA4335` | GDG Red |
| `success` | `#4CD964` | `#34A853` | GDG Green |
| `textPrimary` | `#F2F4FF` | `#FFFFFF` | Clean white |
| `textSecondary` | `#AAB2D9` | `#B0B0B0` | Neutral gray |

### ColorScheme Mapping

| Scheme Slot | Old | New |
|---|---|---|
| `primary` | `#7C6CFF` | `#4285F4` |
| `onPrimary` | white | white |
| `secondary` | `#00E0C6` | `#34A853` |
| `onSecondary` | `#06231F` | `#FFFFFF` |
| `tertiary` | `#FFB020` | `#F9AB00` |
| `onTertiary` | `#2B1A00` | `#1E1E1E` |
| `surface` | `#171E44` | `#2D2D2D` |
| `onSurface` | `#F2F4FF` | `#FFFFFF` |
| `error` | `#FF6B6B` | `#EA4335` |
| `onError` | white | white |

### Hardcoded Colors to Update

| File | Old Value | New Value | Context |
|---|---|---|---|
| `app_theme.dart` | `Color(0x222A3A75)` | `Color(0x33FFFFFF)` | Card border |
| `app_theme.dart` | `Color(0x224A5BCF)` | `Color(0x33FFFFFF)` | Input border + divider |
| `welcome_screen.dart` | `Color(0xFF3B2FBF)` | `Color(0xFF1A5FC9)` | Brand logo gradient end |
| `leaderboard_screen.dart` | `Color(0xFFCDD3E6)` | `Color(0xFFB0B0B0)` | Silver medal |
| `leaderboard_screen.dart` | `Color(0xFFB47927)` | `Color(0xFFC17900)` | Bronze medal |
| `completion_screen.dart` | `Color(0xFF2A1B00)` | `Color(0xFF3D2E00)` | Gradient start |
| `completion_screen.dart` | `Color(0xFF8A5A00)` | `Color(0xFFB8860B)` | Trophy gradient end |
| `treasure_found_modal.dart` | `Color(0xFFB76E00)` | `Color(0xFFB8860B)` | Modal gradient end |

---

## File Map

| # | File | Change Type |
|---|---|---|
| 1 | `lib/core/theme/app_theme.dart` | Core palette + theme config |
| 2 | `lib/ui/screens/welcome/welcome_screen.dart` | Hardcoded gradient color |
| 3 | `lib/ui/screens/home/home_shell.dart` | `Colors.white`/`Colors.black87` (minor) |
| 4 | `lib/ui/screens/discovery/treasure_found_modal.dart` | Hardcoded gradient color |
| 5 | `lib/ui/screens/leaderboard/leaderboard_screen.dart` | Medal hardcoded colors |
| 6 | `lib/ui/screens/completion/completion_screen.dart` | Gradient hardcoded colors |
| 7 | `lib/ui/screens/admin/admin_dashboard_screen.dart` | No changes needed (uses AppColors only) |

---

### Task 1: Update AppColors palette and AppTheme in `app_theme.dart`

**Files:**
- Modify: `lib/core/theme/app_theme.dart` (entire file)

- [ ] **Step 1: Replace the `AppColors` class with GDG brand colors**

```dart
import 'package:flutter/material.dart';

/// GDG (Google Developer Groups) official brand palette.
abstract final class AppColors {
  static const background = Color(0xFF1E1E1E);
  static const backgroundGradientTop = Color(0xFF2D2D2D);
  static const surface = Color(0xFF2D2D2D);
  static const surfaceAlt = Color(0xFF3C4043);
  static const primary = Color(0xFF4285F4);
  static const primarySoft = Color(0xFF57CAFF);
  static const secondary = Color(0xFF34A853);
  static const amber = Color(0xFFF9AB00);
  static const danger = Color(0xFFEA4335);
  static const success = Color(0xFF34A853);
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFB0B0B0);
}
```

- [ ] **Step 2: Update the `AppTheme.dark()` method**

Replace the entire `AppTheme` class with:

```dart
abstract final class AppTheme {
  static ThemeData dark() {
    final scheme = ColorScheme.dark(
      primary: AppColors.primary,
      onPrimary: Colors.white,
      secondary: AppColors.secondary,
      onSecondary: Colors.white,
      tertiary: AppColors.amber,
      onTertiary: AppColors.background,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      error: AppColors.danger,
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: Color(0x33FFFFFF)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: AppColors.primary),
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        hintStyle: const TextStyle(color: AppColors.textSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0x33FFFFFF)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primarySoft,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontSize: 11),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceAlt,
        contentTextStyle: const TextStyle(color: AppColors.textPrimary),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dividerTheme: const DividerThemeData(color: Color(0x33FFFFFF)),
    );
  }
}
```

- [ ] **Step 3: Run `flutter analyze` to verify no errors**

Run: `flutter analyze`
Expected: No errors (warnings acceptable)

- [ ] **Step 4: Commit**

```bash
git add lib/core/theme/app_theme.dart
git commit -m "refactor: rebrand AppColors to GDG official palette"
```

---

### Task 2: Update hardcoded colors in Welcome Screen

**Files:**
- Modify: `lib/ui/screens/welcome/welcome_screen.dart:157`

- [ ] **Step 1: Update brand logo gradient end color**

In `_BrandLogo`, change the gradient `colors` list. The old gradient goes from `AppColors.primary` to `Color(0xFF3B2FBF)`. Replace `Color(0xFF3B2FBF)` with `Color(0xFF1A5FC9)` (darker GDG blue):

```dart
gradient: const LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [AppColors.primary, Color(0xFF1A5FC9)],
),
```

- [ ] **Step 2: Run `flutter analyze`**

Run: `flutter analyze`
Expected: No errors

- [ ] **Step 3: Commit**

```bash
git add lib/ui/screens/welcome/welcome_screen.dart
git commit -m "refactor: update welcome screen gradient to GDG blue"
```

---

### Task 3: Update hardcoded colors in Home Shell

**Files:**
- Modify: `lib/ui/screens/home/home_shell.dart:51,67`

- [ ] **Step 1: Update icon color in bottom sheet**

The `CircleAvatar` for QR scanner uses `Colors.white` (fine, keep it). The keyboard icon uses `Colors.black87` on secondary background — with GDG Green `#34A853`, dark text still works. No functional change needed, but let's verify by reading the file and confirming the contrast is acceptable.

No code changes needed here — `Colors.white` and `Colors.black87` are functional colors, not brand colors.

- [ ] **Step 2: Commit (no-op, skip if no changes)**

If no changes were made, skip this commit.

---

### Task 4: Update hardcoded colors in Treasure Found Modal

**Files:**
- Modify: `lib/ui/screens/discovery/treasure_found_modal.dart:92`

- [ ] **Step 1: Update modal gradient end color**

Change the amber gradient from `[AppColors.amber, Color(0xFFB76E00)]` to `[AppColors.amber, Color(0xFFB8860B)]`:

```dart
gradient: const LinearGradient(
  colors: [AppColors.amber, Color(0xFFB8860B)],
),
```

- [ ] **Step 2: Run `flutter analyze`**

Run: `flutter analyze`
Expected: No errors

- [ ] **Step 3: Commit**

```bash
git add lib/ui/screens/discovery/treasure_found_modal.dart
git commit -m "refactor: update treasure modal gradient to GDG yellow"
```

---

### Task 5: Update hardcoded colors in Leaderboard Screen

**Files:**
- Modify: `lib/ui/screens/leaderboard/leaderboard_screen.dart:57-58`

- [ ] **Step 1: Update medal colors**

Replace the silver and bronze medal colors:

```dart
final medal = switch (position) {
  1 => const Icon(Icons.emoji_events_rounded, color: AppColors.amber),
  2 => const Icon(Icons.workspace_premium_rounded, color: Color(0xFFB0B0B0)),
  3 => const Icon(Icons.workspace_premium_rounded, color: Color(0xFFC17900)),
  _ => Text(
      '$position',
      style: const TextStyle(
        fontWeight: FontWeight.w800,
        color: AppColors.textSecondary,
      ),
    ),
};
```

- [ ] **Step 2: Run `flutter analyze`**

Run: `flutter analyze`
Expected: No errors

- [ ] **Step 3: Commit**

```bash
git add lib/ui/screens/leaderboard/leaderboard_screen.dart
git commit -m "refactor: update leaderboard medal colors"
```

---

### Task 6: Update hardcoded colors in Completion Screen

**Files:**
- Modify: `lib/ui/screens/completion/completion_screen.dart:26,158`

- [ ] **Step 1: Update background gradient start color**

Change the gradient from `[Color(0xFF2A1B00), AppColors.backgroundGradientTop]` to `[Color(0xFF3D2E00), AppColors.backgroundGradientTop]`:

```dart
gradient: const LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [Color(0xFF3D2E00), AppColors.backgroundGradientTop],
),
```

- [ ] **Step 2: Update trophy gradient end color**

Change the trophy gradient from `[AppColors.amber, Color(0xFF8A5A00)]` to `[AppColors.amber, Color(0xFFB8860B)]`:

```dart
gradient: const LinearGradient(
  colors: [AppColors.amber, Color(0xFFB8860B)],
),
```

- [ ] **Step 3: Run `flutter analyze`**

Run: `flutter analyze`
Expected: No errors

- [ ] **Step 4: Commit**

```bash
git add lib/ui/screens/completion/completion_screen.dart
git commit -m "refactor: update completion screen gradients to GDG palette"
```

---

### Task 7: Final verification and build check

- [ ] **Step 1: Run full static analysis**

Run: `flutter analyze`
Expected: No errors

- [ ] **Step 2: Run build to verify compilation**

Run: `flutter build web --release`
Expected: Build succeeds with no errors

- [ ] **Step 3: Visual smoke test**

Verify the app runs and key screens display correctly:
- Welcome screen shows GDG blue primary, dark neutral background
- Home dashboard shows blue CTA buttons, green/amber stat accents
- Leaderboard shows updated medal colors
- Completion screen shows updated gradients
- Bottom navigation uses GDG blue selected state

- [ ] **Step 4: Commit any final fixes (if needed)**

```bash
git add -A
git commit -m "chore: GDG brand rebrand verification"
```
