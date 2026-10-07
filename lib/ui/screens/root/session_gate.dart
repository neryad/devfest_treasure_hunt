import 'package:flutter/material.dart';

import '../../../state/app_scope.dart';
import '../home/home_shell.dart';
import '../welcome/welcome_screen.dart';
import 'splash_screen.dart';
import 'startup_error_screen.dart';

/// Decides where the app starts: splash while loading, error + retry when
/// initialization failed, Welcome (no participant) or Home (session exists).
class SessionGate extends StatelessWidget {
  const SessionGate({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);

    if (controller.initializing) {
      return const SplashScreen();
    }
    if (controller.initFailed) {
      return StartupErrorScreen(onRetry: controller.initialize);
    }
    if (!controller.hasParticipant) {
      return const WelcomeScreen();
    }
    return const HomeScreen();
  }
}
