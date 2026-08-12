import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../state/app_scope.dart';
import '../welcome/welcome_screen.dart';
import '../home/home_shell.dart';

/// Decides where the app starts: shows a tiny brand splash while the
/// controller loads persisted state, then routes to Welcome (no participant)
/// or Home (participant from a previous session).
class SessionGate extends StatelessWidget {
  const SessionGate({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);

    if (controller.initializing) {
      return const _SplashLoading();
    }

    if (!controller.hasParticipant) {
      return const WelcomeScreen();
    }

    return const HomeScreen();
  }
}

class _SplashLoading extends StatelessWidget {
  const _SplashLoading();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.45),
                    blurRadius: 40,
                  ),
                ],
              ),
              child: const Icon(
                Icons.explore_rounded,
                size: 64,
                color: AppColors.primarySoft,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'DevFest Treasure Hunt',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}