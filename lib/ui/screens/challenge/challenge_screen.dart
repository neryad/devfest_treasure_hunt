import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/gym_challenge.dart';
import '../../../domain/entities/treasure_item.dart';
import '../../../domain/use_cases/complete_challenge_use_case.dart';
import '../../../state/app_scope.dart';

class ChallengeScreen extends StatefulWidget {
  const ChallengeScreen({super.key, required this.gym});

  final TreasureItem gym;

  @override
  State<ChallengeScreen> createState() => _ChallengeScreenState();
}

class _ChallengeScreenState extends State<ChallengeScreen> {
  int _secondsRemaining = 60;
  Timer? _timer;
  String? _selectedAnswer;
  final _textController = TextEditingController();
  bool _submitted = false;

  TreasureItem get gym => widget.gym;
  GymChallenge? get challenge => gym.challenge;

  @override
  void initState() {
    super.initState();
    if (challenge != null && challenge!.hasTimer) {
      _secondsRemaining = challenge!.timeLimitSeconds;
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _textController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining <= 0) {
        timer.cancel();
        _handleSubmit(); // Auto-submit on timeout
      } else {
        setState(() => _secondsRemaining--);
      }
    });
  }

  void _handleSubmit() {
    if (_submitted) return;
    _timer?.cancel();
    setState(() => _submitted = true);

    final answer = _selectedAnswer ?? _textController.text;
    final controller = AppScope.of(context);
    controller.submitChallenge(gym.id, answer);
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final result = controller.lastChallengeResult;

    // Show result screen if submitted
    if (_submitted && result != null) {
      return _ResultScreen(result: result, gym: gym);
    }

    // Show cooldown screen
    if (controller.isOnCooldown) {
      return _CooldownScreen(
        cooldownRemaining: controller.cooldownRemaining,
        gym: gym,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(gym.gymName ?? gym.title),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Gym badge
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: 0.15),
                ),
                child: Icon(
                  _getTrackIcon(gym.track),
                  size: 48,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Challenge type label
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _getChallengeTypeName(challenge?.type ?? ChallengeType.qr),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Timer (if applicable)
            if (challenge?.hasTimer == true) ...[
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: _secondsRemaining <= 10
                        ? AppColors.danger.withValues(alpha: 0.15)
                        : AppColors.surfaceAlt,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _formatTime(_secondsRemaining),
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: _secondsRemaining <= 10
                          ? AppColors.danger
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Question
            if (challenge?.question != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    challenge!.question!,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      height: 1.4,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 20),

            // Code snippet (if applicable)
            if (challenge?.codeSnippet != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.surfaceAlt),
                ),
                child: Text(
                  challenge!.codeSnippet!,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            const SizedBox(height: 20),

            // Options (trivia/code)
            if (challenge?.hasOptions == true)
              Expanded(
                child: ListView.separated(
                  itemCount: challenge!.options!.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final option = challenge!.options![index];
                    final isSelected = _selectedAnswer == option;
                    return InkWell(
                      onTap: () => setState(() => _selectedAnswer = option),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary.withValues(alpha: 0.15)
                              : AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.surfaceAlt,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Text(
                          option,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

            // Text input (riddle)
            if (challenge?.requiresInput == true)
              Expanded(
                child: TextField(
                  controller: _textController,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Escribe tu respuesta...',
                    hintStyle: const TextStyle(color: AppColors.textSecondary),
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

            // Hint
            if (challenge?.hint != null && !_submitted)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  '💡 ${challenge!.hint}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Submit button
            ElevatedButton(
              onPressed: (_selectedAnswer != null || challenge?.requiresInput == true)
                  ? _handleSubmit
                  : null,
              child: const Text('Enviar respuesta'),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getTrackIcon(String? track) {
    switch (track) {
      case 'android':
        return Icons.phone_android_rounded;
      case 'ia':
        return Icons.psychology_rounded;
      case 'cloud':
        return Icons.cloud_rounded;
      case 'security':
        return Icons.shield_rounded;
      case 'web':
        return Icons.language_rounded;
      case 'startup':
        return Icons.rocket_launch_rounded;
      case 'speaker':
        return Icons.mic_rounded;
      case 'community':
        return Icons.people_rounded;
      default:
        return Icons.explore_rounded;
    }
  }

  String _getChallengeTypeName(ChallengeType type) {
    switch (type) {
      case ChallengeType.qr:
        return 'Escaneo QR';
      case ChallengeType.trivia:
        return 'Trivia Técnica';
      case ChallengeType.riddle:
        return 'Acertijo';
      case ChallengeType.code:
        return 'Reto de Código';
      case ChallengeType.completion:
        return 'Reto Presencial';
      case ChallengeType.social:
        return 'Reto Social';
    }
  }
}

class _ResultScreen extends StatelessWidget {
  const _ResultScreen({required this.result, required this.gym});

  final ChallengeResult result;
  final TreasureItem gym;

  @override
  Widget build(BuildContext context) {
    final success = result.isSuccess;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: success
                ? [AppColors.secondary.withValues(alpha: 0.2), AppColors.background]
                : [AppColors.danger.withValues(alpha: 0.2), AppColors.background],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.3, end: 1),
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.elasticOut,
                    builder: (_, scale, child) =>
                        Transform.scale(scale: scale, child: child),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: success
                            ? AppColors.secondary.withValues(alpha: 0.15)
                            : AppColors.danger.withValues(alpha: 0.15),
                      ),
                      child: Icon(
                        success ? Icons.check_rounded : Icons.close_rounded,
                        size: 64,
                        color: success ? AppColors.secondary : AppColors.danger,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  Text(
                    success ? '¡Correcto!' : 'Incorrecto',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: success ? AppColors.secondary : AppColors.danger,
                    ),
                  ),
                  const SizedBox(height: 8),

                  if (success) ...[
                    Text(
                      '+${result.pointsEarned} puntos',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.amber,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Total: ${result.totalPoints} pts · ${result.medals} medallas',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ] else ...[
                    const Text(
                      'La respuesta no es correcta.',
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Intenta de nuevo en 5 minutos.',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),

                  ElevatedButton(
                    onPressed: () {
                      AppScope.of(context).clearChallengeResult();
                      Navigator.of(context).pop();
                    },
                    child: Text(success ? 'Continuar' : 'Volver'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CooldownScreen extends StatelessWidget {
  const _CooldownScreen({
    required this.cooldownRemaining,
    required this.gym,
  });

  final Duration cooldownRemaining;
  final TreasureItem gym;

  @override
  Widget build(BuildContext context) {
    final minutes = cooldownRemaining.inMinutes;
    final seconds = cooldownRemaining.inSeconds.remainder(60);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.danger.withValues(alpha: 0.15),
              AppColors.background,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.timer_off_rounded,
                    size: 64,
                    color: AppColors.danger,
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'Cooldown activo',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'El Líder del Gimnasio te desafía de nuevo más tarde...',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.danger.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: AppColors.danger,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () {
                      AppScope.of(context).clearChallengeResult();
                      Navigator.of(context).pop();
                    },
                    child: const Text('Volver'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
