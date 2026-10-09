import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/snack_bar_utils.dart';
import '../../../core/utils/treasure_icons.dart';
import '../../../domain/entities/gym_challenge.dart';
import '../../../domain/entities/challenge_question.dart';
import '../../../domain/entities/treasure_item.dart';
import '../../../domain/use_cases/complete_challenge_use_case.dart';
import '../../../state/app_scope.dart';
import 'community_challenge_screen.dart';
import 'pixel_perfect_mini_game.dart';
import 'security_challenge_screen.dart';
import 'startup_mini_game.dart';

// class ChallengeScreen extends StatefulWidget {
//   const ChallengeScreen({super.key, required this.gym});

//   final TreasureItem gym;

//   @override
//   State<ChallengeScreen> createState() => _ChallengeScreenState();
// }

// class _ChallengeScreenState extends State<ChallengeScreen> {
//   int _secondsRemaining = 60;
//   Timer? _timer;
//   String? _selectedAnswer;
//   final _textController = TextEditingController();
//   ChallengeQuestion? _assignedQuestion;
//   bool _submitted = false;
//   bool _submitting = false;

//   TreasureItem get gym => widget.gym;
//   GymChallenge? get challenge => gym.challenge;

//   @override
//   void initState() {
//     super.initState();
//     if (challenge != null && challenge!.hasTimer) {
//       _secondsRemaining = challenge!.timeLimitSeconds;
//       _startTimer();
//     }
//     _assignQuestion();
//   }

//   @override
//   void dispose() {
//     _timer?.cancel();
//     _textController.dispose();
//     super.dispose();
//   }

//   void _startTimer() {
//     _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       if (_secondsRemaining <= 0) {
//         timer.cancel();
//         _handleSubmit(); // Auto-submit on timeout
//       } else {
//         setState(() => _secondsRemaining--);
//       }
//     });
//   }

//   void _assignQuestion() {
//     final controller = AppScope.read(context);
//     final participant = controller.participant;
//     if (participant == null || challenge == null) return;
//     if (challenge!.questionBank.isNotEmpty) {
//       _assignedQuestion = ChallengeQuestionSelector.select(
//         participantId: participant.id,
//         gymId: gym.id,
//         bank: challenge!.questionBank,
//       );
//     } else {
//       _assignedQuestion = ChallengeQuestion(
//         id: 'legacy',
//         question: challenge!.question ?? '',
//         options: challenge!.options ?? const [],
//         correctAnswer: challenge!.correctAnswer ?? '',
//         hint: challenge!.hint,
//         codeSnippet: challenge!.codeSnippet,
//       );
//     }
//   }

//   Future<void> _handleSubmit() async {
//     if (_submitted || _submitting) return;
//     _timer?.cancel();
//     setState(() {
//       _submitted = true;
//       _submitting = true;
//     });

//     final answer = _selectedAnswer ?? _textController.text;
//     final controller = AppScope.of(context);
//     try {
//       await controller.submitChallenge(gym.id, answer);
//     } catch (_) {
//       if (!mounted) return;
//       showNetworkError(context);
//       setState(() {
//         _submitted = false;
//         _submitting = false;
//       });
//     }
//   }

//   String _formatTime(int seconds) {
//     final m = seconds ~/ 60;
//     final s = seconds % 60;
//     return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
//   }

//   @override
//   Widget build(BuildContext context) {
//     final controller = AppScope.of(context);
//     final result = controller.lastChallengeResult;
//     final displayedQuestion = _assignedQuestion;
//     final displayedOptions = displayedQuestion?.options ?? const <String>[];
//     final displayedHint = displayedQuestion?.hint;
//     final displayedSnippet = displayedQuestion?.codeSnippet;
//     final canSubmit = displayedOptions.isNotEmpty
//         ? _selectedAnswer != null
//         : challenge?.requiresInput == true
//         ? _textController.text.trim().isNotEmpty
//         : true;

//     // Show result screen if submitted
//     if (_submitted && result != null) {
//       return _ResultScreen(
//         result: result,
//         gym: gym,
//         hint: challenge?.questionBank.isNotEmpty == true ? displayedHint : null,
//       );
//     }

//     // Show cooldown screen
//     if (controller.isOnCooldown) {
//       return _CooldownScreen(
//         cooldownRemaining: controller.cooldownRemaining,
//         gym: gym,
//       );
//     }

//     if (gym.id == 'gym-community') {
//       return CommunityChallengeScreen(
//         validationCode: challenge?.correctAnswer ?? 'COMMUNITY-SIGNAL',
//         onCompleted: () async {
//           _selectedAnswer = challenge?.correctAnswer ?? 'COMMUNITY-SIGNAL';
//           await _handleSubmit();
//         },
//       );
//     }

//     if (challenge?.isMiniGame == true) {
//       if (gym.id == 'gym-web') {
//         return Scaffold(
//           appBar: AppBar(
//             title: Text(gym.gymName ?? gym.title),
//             leading: IconButton(
//               icon: const Icon(Icons.close_rounded),
//               onPressed: () => Navigator.of(context).pop(),
//             ),
//           ),
//           body: PixelPerfectMiniGame(
//             targetScore: challenge?.targetScore ?? 100,
//             onCompleted: () {
//               _selectedAnswer = challenge?.correctAnswer ?? 'PIXEL-PERFECT';
//               _handleSubmit();
//             },
//           ),
//         );
//       }
//       return Scaffold(
//         appBar: AppBar(
//           title: Text(gym.gymName ?? gym.title),
//           leading: IconButton(
//             icon: const Icon(Icons.close_rounded),
//             onPressed: () => Navigator.of(context).pop(),
//           ),
//         ),
//         body: SafeArea(
//           child: Align(
//             alignment: Alignment.topCenter,
//             child: Padding(
//               padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
//               child: ConstrainedBox(
//                 constraints: const BoxConstraints(maxWidth: 640),
//                 child: StartupMiniGame(
//                   targetScore: challenge?.targetScore ?? 100,
//                   onCompleted: () {
//                     _selectedAnswer =
//                         challenge?.correctAnswer ?? 'RUNWAY-CLEARED';
//                     _handleSubmit();
//                   },
//                 ),
//               ),
//             ),
//           ),
//         ),
//       );
//     }

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(gym.gymName ?? gym.title),
//         leading: IconButton(
//           icon: const Icon(Icons.close_rounded),
//           onPressed: () => Navigator.of(context).pop(),
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             // Gym badge
//             Center(
//               child: Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   color: AppColors.primary.withValues(alpha: 0.15),
//                 ),
//                 child: Icon(
//                   _getTrackIcon(gym.track),
//                   size: 48,
//                   color: AppColors.primary,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 16),

//             // Challenge type label
//             Center(
//               child: Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 12,
//                   vertical: 6,
//                 ),
//                 decoration: BoxDecoration(
//                   color: AppColors.surfaceAlt,
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: Text(
//                   _getChallengeTypeName(challenge?.type ?? ChallengeType.qr),
//                   style: const TextStyle(
//                     fontSize: 12,
//                     fontWeight: FontWeight.w600,
//                     color: AppColors.textSecondary,
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),

//             // Timer (if applicable)
//             if (challenge?.hasTimer == true) ...[
//               Center(
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 20,
//                     vertical: 10,
//                   ),
//                   decoration: BoxDecoration(
//                     color: _secondsRemaining <= 10
//                         ? AppColors.danger.withValues(alpha: 0.15)
//                         : AppColors.surfaceAlt,
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Text(
//                     _formatTime(_secondsRemaining),
//                     style: TextStyle(
//                       fontSize: 32,
//                       fontWeight: FontWeight.w900,
//                       color: _secondsRemaining <= 10
//                           ? AppColors.danger
//                           : AppColors.textPrimary,
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 20),
//             ],

//             // Question
//             if (displayedQuestion?.question.isNotEmpty == true)
//               Card(
//                 child: Padding(
//                   padding: const EdgeInsets.all(20),
//                   child: Text(
//                     displayedQuestion!.question,
//                     style: const TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.w700,
//                       color: AppColors.textPrimary,
//                       height: 1.4,
//                     ),
//                   ),
//                 ),
//               ),
//             const SizedBox(height: 20),

//             // Legacy riddles need their hint to solve the challenge. Question
//             // banks reveal theirs only after a failed attempt.
//             if (challenge?.questionBank.isEmpty == true &&
//                 displayedHint != null) ...[
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: AppColors.amber.withValues(alpha: 0.12),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Text(
//                   displayedHint,
//                   style: const TextStyle(
//                     color: AppColors.textSecondary,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 20),
//             ],

//             // Code snippet (if applicable)
//             if (displayedSnippet != null)
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFF1E1E1E),
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(color: AppColors.surfaceAlt),
//                 ),
//                 child: Text(
//                   displayedSnippet,
//                   style: const TextStyle(
//                     fontFamily: 'monospace',
//                     fontSize: 14,
//                     color: AppColors.textPrimary,
//                   ),
//                 ),
//               ),
//             const SizedBox(height: 20),

//             // Options (trivia/code)
//             if (displayedOptions.isNotEmpty)
//               Expanded(
//                 child: ListView.separated(
//                   itemCount: displayedOptions.length,
//                   separatorBuilder: (_, _) => const SizedBox(height: 10),
//                   itemBuilder: (context, index) {
//                     final option = displayedOptions[index];
//                     final isSelected = _selectedAnswer == option;
//                     return InkWell(
//                       onTap: () => setState(() => _selectedAnswer = option),
//                       borderRadius: BorderRadius.circular(12),
//                       child: Container(
//                         padding: const EdgeInsets.all(16),
//                         decoration: BoxDecoration(
//                           color: isSelected
//                               ? AppColors.primary.withValues(alpha: 0.15)
//                               : AppColors.surface,
//                           borderRadius: BorderRadius.circular(12),
//                           border: Border.all(
//                             color: isSelected
//                                 ? AppColors.primary
//                                 : AppColors.surfaceAlt,
//                             width: isSelected ? 2 : 1,
//                           ),
//                         ),
//                         child: Text(
//                           option,
//                           style: TextStyle(
//                             fontSize: 15,
//                             fontWeight: isSelected
//                                 ? FontWeight.w700
//                                 : FontWeight.w500,
//                             color: isSelected
//                                 ? AppColors.primary
//                                 : AppColors.textPrimary,
//                           ),
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               ),

//             // Text input (riddle)
//             if (challenge?.requiresInput == true)
//               Expanded(
//                 child: TextField(
//                   controller: _textController,
//                   onChanged: (_) => setState(() {}),
//                   style: const TextStyle(color: AppColors.textPrimary),
//                   decoration: InputDecoration(
//                     hintText: challenge?.type == ChallengeType.social
//                         ? 'Escribe el codigo recibido por DM...'
//                         : 'Escribe tu respuesta o codigo final...',
//                     hintStyle: const TextStyle(color: AppColors.textSecondary),
//                     filled: true,
//                     fillColor: AppColors.surface,
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: BorderSide.none,
//                     ),
//                   ),
//                 ),
//               ),

//             const SizedBox(height: 16),

//             // Submit button
//             ElevatedButton(
//               onPressed: canSubmit && !_submitting ? _handleSubmit : null,
//               child: _submitting
//                   ? const SizedBox(
//                       width: 20,
//                       height: 20,
//                       child: CircularProgressIndicator(strokeWidth: 2),
//                     )
//                   : const Text('Enviar respuesta'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   IconData _getTrackIcon(String? track) {
//     switch (track) {
//       case 'android':
//         return Icons.phone_android_rounded;
//       case 'ia':
//         return Icons.psychology_rounded;
//       case 'cloud':
//         return Icons.cloud_rounded;
//       case 'security':
//         return Icons.shield_rounded;
//       case 'web':
//         return Icons.language_rounded;
//       case 'startup':
//         return Icons.rocket_launch_rounded;
//       case 'speaker':
//         return Icons.mic_rounded;
//       case 'community':
//         return Icons.people_rounded;
//       default:
//         return Icons.explore_rounded;
//     }
//   }

//   String _getChallengeTypeName(ChallengeType type) {
//     switch (type) {
//       case ChallengeType.qr:
//         return 'Escaneo QR';
//       case ChallengeType.trivia:
//         return 'Trivia Técnica';
//       case ChallengeType.riddle:
//         return 'Acertijo';
//       case ChallengeType.code:
//         return 'Reto de Código';
//       case ChallengeType.completion:
//         return 'Reto Presencial';
//       case ChallengeType.social:
//         return 'Reto Social';
//       case ChallengeType.miniGame:
//         return 'Mini Juego';
//     }
//   }
// }

// class _ResultScreen extends StatelessWidget {
//   const _ResultScreen({required this.result, required this.gym, this.hint});

//   final ChallengeResult result;
//   final TreasureItem gym;
//   final String? hint;

//   @override
//   Widget build(BuildContext context) {
//     final success = result.isSuccess;
//     final paused = !success && result.failure == ChallengeFailure.eventPaused;

//     return Scaffold(
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: success
//                 ? [
//                     AppColors.secondary.withValues(alpha: 0.2),
//                     AppColors.background,
//                   ]
//                 : [
//                     AppColors.danger.withValues(alpha: 0.2),
//                     AppColors.background,
//                   ],
//           ),
//         ),
//         child: SafeArea(
//           child: Center(
//             child: Padding(
//               padding: const EdgeInsets.all(28),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   // Icon / Medal
//                   TweenAnimationBuilder<double>(
//                     tween: Tween(begin: 0.3, end: 1),
//                     duration: const Duration(milliseconds: 700),
//                     curve: Curves.elasticOut,
//                     builder: (_, scale, child) =>
//                         Transform.scale(scale: scale, child: child),
//                     child: success
//                         ? Container(
//                             width: 150,
//                             height: 180,
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(24),
//                               border: Border.all(
//                                 color: AppColors.secondary.withValues(
//                                   alpha: 0.4,
//                                 ),
//                                 width: 1.5,
//                               ),
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: AppColors.secondary.withValues(
//                                     alpha: 0.35,
//                                   ),
//                                   blurRadius: 36,
//                                   spreadRadius: 2,
//                                   offset: const Offset(0, 6),
//                                 ),
//                               ],
//                             ),
//                             child: ClipRRect(
//                               borderRadius: BorderRadius.circular(22),
//                               child: Image.asset(
//                                 getMedalAssetPath(gym.track),
//                                 fit: BoxFit.cover,
//                                 errorBuilder: (_, _, _) => const Center(
//                                   child: Icon(
//                                     Icons.emoji_events_rounded,
//                                     size: 72,
//                                     color: AppColors.amber,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           )
//                         : Container(
//                             padding: const EdgeInsets.all(24),
//                             decoration: BoxDecoration(
//                               shape: BoxShape.circle,
//                               color: AppColors.danger.withValues(alpha: 0.15),
//                               border: Border.all(
//                                 color: AppColors.danger.withValues(alpha: 0.4),
//                                 width: 1.5,
//                               ),
//                             ),
//                             child: const Icon(
//                               Icons.close_rounded,
//                               size: 64,
//                               color: AppColors.danger,
//                             ),
//                           ),
//                   ),
//                   const SizedBox(height: 24),

//                   Text(
//                     success
//                         ? '¡Medalla Conquistada!'
//                         : paused
//                         ? 'Evento Pausado'
//                         : 'Respuesta Incorrecta',
//                     style: TextStyle(
//                       fontSize: 26,
//                       fontWeight: FontWeight.w900,
//                       color: success ? AppColors.secondary : AppColors.danger,
//                     ),
//                   ),
//                   const SizedBox(height: 8),

//                   if (success) ...[
//                     Text(
//                       '+${result.pointsEarned} puntos',
//                       style: const TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.w700,
//                         color: AppColors.amber,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       'Total: ${result.totalPoints} pts · ${result.medals} medallas',
//                       style: const TextStyle(
//                         fontSize: 14,
//                         color: AppColors.textSecondary,
//                       ),
//                     ),
//                   ] else if (paused)
//                     const Text(
//                       'Los descubrimientos están pausados temporalmente.',
//                       style: TextStyle(
//                         fontSize: 15,
//                         color: AppColors.textSecondary,
//                       ),
//                     )
//                   else ...[
//                     const Text(
//                       'La respuesta no es correcta.',
//                       style: TextStyle(
//                         fontSize: 15,
//                         color: AppColors.textSecondary,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     const Text(
//                       'Puedes intentarlo de nuevo inmediatamente.',
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: AppColors.textSecondary,
//                       ),
//                     ),
//                     if (hint != null) ...[
//                       const SizedBox(height: 16),
//                       Container(
//                         padding: const EdgeInsets.all(14),
//                         decoration: BoxDecoration(
//                           color: AppColors.amber.withValues(alpha: 0.12),
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: Text(
//                           'Pista: $hint',
//                           textAlign: TextAlign.center,
//                           style: const TextStyle(
//                             color: AppColors.textPrimary,
//                             fontWeight: FontWeight.w700,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ],

//                   const SizedBox(height: 32),

//                   ElevatedButton(
//                     onPressed: () {
//                       AppScope.of(context).clearChallengeResult();
//                       Navigator.of(context).pop();
//                     },
//                     child: Text(success ? 'Continuar' : 'Volver'),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _CooldownScreen extends StatelessWidget {
//   const _CooldownScreen({required this.cooldownRemaining, required this.gym});

//   final Duration cooldownRemaining;
//   final TreasureItem gym;

//   @override
//   Widget build(BuildContext context) {
//     final minutes = cooldownRemaining.inMinutes;
//     final seconds = cooldownRemaining.inSeconds.remainder(60);

//     return Scaffold(
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [
//               AppColors.danger.withValues(alpha: 0.15),
//               AppColors.background,
//             ],
//           ),
//         ),
//         child: SafeArea(
//           child: Center(
//             child: Padding(
//               padding: const EdgeInsets.all(28),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Icon(
//                     Icons.timer_off_rounded,
//                     size: 64,
//                     color: AppColors.danger,
//                   ),
//                   const SizedBox(height: 28),
//                   const Text(
//                     'Cooldown activo',
//                     style: TextStyle(
//                       fontSize: 28,
//                       fontWeight: FontWeight.w900,
//                       color: AppColors.textPrimary,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     'El Líder del Gimnasio te desafía de nuevo más tarde...',
//                     textAlign: TextAlign.center,
//                     style: const TextStyle(
//                       fontSize: 15,
//                       color: AppColors.textSecondary,
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 24,
//                       vertical: 12,
//                     ),
//                     decoration: BoxDecoration(
//                       color: AppColors.danger.withValues(alpha: 0.15),
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Text(
//                       '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
//                       style: const TextStyle(
//                         fontSize: 36,
//                         fontWeight: FontWeight.w900,
//                         color: AppColors.danger,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 32),
//                   ElevatedButton(
//                     onPressed: () {
//                       AppScope.of(context).clearChallengeResult();
//                       Navigator.of(context).pop();
//                     },
//                     child: const Text('Volver'),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
// import 'dart:async';

// import 'package:flutter/material.dart';

// import '../../../core/theme/app_theme.dart';
// import '../../../core/utils/snack_bar_utils.dart';
// import '../../../core/utils/treasure_icons.dart';
// import '../../../domain/entities/challenge_question.dart';
// import '../../../domain/entities/gym_challenge.dart';
// import '../../../domain/entities/treasure_item.dart';
// import '../../../domain/utils/challenge_question_selector.dart';
// import '../../../state/app_scope.dart';
// import 'community_challenge_screen.dart';
// import 'pixel_perfect_mini_game.dart';
// import 'startup_mini_game.dart';

/// Qué pantalla de juego usa cada reto. Agregar un juego nuevo es un
/// caso más en este enum y en [_ChallengeScreenState._buildGame].
enum _GameKind { community, security, pixelPerfect, startupInvaders, trivia }

class ChallengeScreen extends StatefulWidget {
  const ChallengeScreen({super.key, required this.gym, this.random});

  final TreasureItem gym;
  final Random? random;

  @override
  State<ChallengeScreen> createState() => _ChallengeScreenState();
}

class _ChallengeScreenState extends State<ChallengeScreen> {
  static const _defaultTimeSeconds = 60;
  static const _maxContentWidth = 640.0;

  int _secondsRemaining = _defaultTimeSeconds;
  Timer? _timer;
  String? _selectedAnswer;
  final _textController = TextEditingController();
  List<ChallengeQuestion> _assigned = const [];
  Set<String> _answeredIds = const {};
  bool _submitted = false;
  bool _submitting = false;

  TreasureItem get gym => widget.gym;
  GymChallenge? get challenge => gym.challenge;

  @override
  void initState() {
    super.initState();
    final c = challenge;
    if (c != null && c.hasTimer) {
      _secondsRemaining = c.timeLimitSeconds;
      _startTimer();
    }
    _assignQuestion();
    _loadProgress();
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
        _handleSubmit(); // Envío automático al terminar el tiempo
      } else {
        setState(() => _secondsRemaining--);
      }
    });
  }

  void _assignQuestion() {
    final controller = AppScope.read(context);
    final participant = controller.participant;
    final c = challenge;
    if (participant == null || c == null) return;

    if (c.questionBank.isNotEmpty) {
      _assigned = List<ChallengeQuestion>.of(c.questionBank)
        ..shuffle(widget.random ?? Random());
    } else {
      _assigned = [
        ChallengeQuestion(
          id: 'legacy',
          question: c.question ?? '',
          options: c.options ?? const [],
          correctAnswer: c.correctAnswer ?? '',
          hint: c.hint,
          codeSnippet: c.codeSnippet,
        ),
      ];
    }
  }

  Future<void> _loadProgress() async {
    final answered = await AppScope.read(context).answeredQuestionIds(gym.id);
    if (!mounted) return;
    setState(() => _answeredIds = answered);
  }

  ChallengeQuestion? get _currentQuestion {
    for (final question in _assigned) {
      if (!_answeredIds.contains(question.id)) return question;
    }
    return null;
  }

  int get _requiredQuestionCount {
    final c = challenge;
    if (c == null) return 0;
    if (c.questionBank.isEmpty) return 1;
    return min(c.questionsRequired, c.questionBank.length);
  }

  int get _answeredAssignedCount =>
      _assigned.where((question) => _answeredIds.contains(question.id)).length;

  Future<void> _handleSubmit({int? miniGameScore}) async {
    if (_submitted || _submitting) return;
    final currentQuestion = _currentQuestion;
    if (currentQuestion == null) return;
    _timer?.cancel();
    setState(() {
      _submitted = true;
      _submitting = true;
    });

    final answer = _selectedAnswer ?? _textController.text;
    final controller = AppScope.of(context);
    try {
      await controller.submitChallenge(
        gym.id,
        answer,
        questionId: currentQuestion.id,
        miniGameScore: miniGameScore,
      );
      if (!mounted) return;
      final result = controller.lastChallengeResult;
      if (result?.isProgress == true) {
        controller.clearChallengeResult();
        _textController.clear();
        setState(() {
          _answeredIds = result!.answeredQuestionIds;
          _submitted = false;
          _submitting = false;
          _selectedAnswer = null;
          final c = challenge;
          if (c != null && c.hasTimer) {
            _secondsRemaining = c.timeLimitSeconds;
            _startTimer();
          }
        });
      }
    } catch (_) {
      if (!mounted) return;
      showNetworkError(context);
      setState(() {
        _submitted = false;
        _submitting = false;
      });
    }
  }

  // ---------------------------------------------------------------------------
  // Routing
  // ---------------------------------------------------------------------------

  _GameKind _gameFor(TreasureItem gym) {
    if (gym.id == 'gym-community') return _GameKind.community;
    if (gym.id == 'gym-security') return _GameKind.security;
    if (challenge?.isMiniGame == true) {
      return gym.id == 'gym-web'
          ? _GameKind.pixelPerfect
          : _GameKind.startupInvaders;
    }
    return _GameKind.trivia;
  }

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final result = controller.lastChallengeResult;

    if (_submitted && result != null && !result.isProgress) {
      return _ResultScreen(
        result: result,
        gym: gym,
        hint: challenge?.questionBank.isNotEmpty == true
            ? _currentQuestion?.hint
            : null,
      );
    }

    if (controller.isOnCooldown) {
      return _CooldownScreen(
        cooldownRemaining: controller.cooldownRemaining,
        gym: gym,
      );
    }

    return _buildGame(_gameFor(gym));
  }

  Widget _buildGame(_GameKind kind) {
    switch (kind) {
      case _GameKind.community:
        return CommunityChallengeScreen(
          validationCode: challenge?.correctAnswer ?? 'COMMUNITY-SIGNAL',
          onCompleted: () async {
            _selectedAnswer = challenge?.correctAnswer ?? 'COMMUNITY-SIGNAL';
            await _handleSubmit();
          },
        );

      case _GameKind.security:
        return SecurityChallengeScreen(
          validationCode: challenge?.correctAnswer ?? 'SECURE2026',
          onCompleted: () async {
            _selectedAnswer = challenge?.correctAnswer ?? 'SECURE2026';
            await _handleSubmit();
          },
        );

      case _GameKind.pixelPerfect:
        return _shell(
          body: _constrained(
            PixelPerfectMiniGame(
              onCompleted: (correctAnswers) {
                _selectedAnswer = challenge?.correctAnswer ?? 'PIXEL-PERFECT';
                _handleSubmit(miniGameScore: correctAnswers);
              },
            ),
          ),
        );

      case _GameKind.startupInvaders:
        return _shell(
          body: SafeArea(
            child: _constrained(
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                child: StartupMiniGame(
                  targetScore: challenge?.targetScore ?? 100,
                  onCompleted: () {
                    _selectedAnswer =
                        challenge?.correctAnswer ?? 'RUNWAY-CLEARED';
                    _handleSubmit();
                  },
                ),
              ),
            ),
          ),
        );

      case _GameKind.trivia:
        return _shell(body: _buildTrivia());
    }
  }

  /// Scaffold común: AppBar con título y botón de cerrar.
  Widget _shell({required Widget body}) {
    return Scaffold(
      appBar: AppBar(
        title: Text(gym.gymName ?? gym.title),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: body,
    );
  }

  /// Centra el contenido y limita su ancho en web o tablet.
  Widget _constrained(Widget child) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _maxContentWidth),
        child: child,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Trivia / acertijo / código
  // ---------------------------------------------------------------------------

  Widget _buildTrivia() {
    final displayedQuestion = _currentQuestion;
    final displayedOptions = displayedQuestion?.options ?? const <String>[];
    final displayedHint = displayedQuestion?.hint;
    final displayedSnippet = displayedQuestion?.codeSnippet;
    final c = challenge;

    final canSubmit = displayedOptions.isNotEmpty
        ? _selectedAnswer != null
        : c?.requiresInput == true
        ? _textController.text.trim().isNotEmpty
        : true;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Insignia del gimnasio
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

          // Tipo de reto
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _getChallengeTypeName(c?.type ?? ChallengeType.qr),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Temporizador
          if (c?.hasTimer == true) ...[
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
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

          if (c?.questionBank.isNotEmpty == true &&
              _requiredQuestionCount > 0) ...[
            Center(
              child: Text(
                'Pregunta ${(_answeredAssignedCount + 1).clamp(1, _requiredQuestionCount)} de $_requiredQuestionCount',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primarySoft,
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Pregunta
          if (displayedQuestion?.question.isNotEmpty == true)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  displayedQuestion!.question,
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

          // Acertijos antiguos necesitan la pista para resolverse.
          // Los bancos de preguntas la muestran solo tras un fallo.
          if (c?.questionBank.isEmpty == true && displayedHint != null) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.amber.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                displayedHint,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Fragmento de código
          if (displayedSnippet != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.surfaceAlt),
              ),
              child: Text(
                displayedSnippet,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          const SizedBox(height: 20),

          // Opciones
          if (displayedOptions.isNotEmpty)
            Expanded(
              child: ListView.separated(
                itemCount: displayedOptions.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) =>
                    _buildOption(displayedOptions[index]),
              ),
            ),

          // Respuesta de texto
          if (c?.requiresInput == true)
            Expanded(
              child: TextField(
                key: gym.id == 'gym-speaker'
                    ? const Key('speaker-answer-field')
                    : null,
                controller: _textController,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: gym.id == 'gym-speaker'
                      ? 'Escribe el nombre completo del speaker...'
                      : c?.type == ChallengeType.social
                      ? 'Escribe el código recibido por DM...'
                      : 'Escribe tu respuesta o código final...',
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

          const SizedBox(height: 16),

          ElevatedButton(
            onPressed: canSubmit && !_submitting ? _handleSubmit : null,
            child: _submitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Enviar respuesta'),
          ),
        ],
      ),
    );
  }

  Widget _buildOption(String option) {
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
            color: isSelected ? AppColors.primary : AppColors.surfaceAlt,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          option,
          style: TextStyle(
            fontSize: 15,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
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
      case ChallengeType.miniGame:
        return 'Mini Juego';
    }
  }
}

class _ResultScreen extends StatelessWidget {
  const _ResultScreen({required this.result, required this.gym, this.hint});

  final ChallengeResult result;
  final TreasureItem gym;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    final success = result.isSuccess;
    final paused = !success && result.failure == ChallengeFailure.eventPaused;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: success
                ? [
                    AppColors.secondary.withValues(alpha: 0.2),
                    AppColors.background,
                  ]
                : [
                    AppColors.danger.withValues(alpha: 0.2),
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
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.3, end: 1),
                    duration: const Duration(milliseconds: 700),
                    curve: Curves.elasticOut,
                    builder: (_, scale, child) =>
                        Transform.scale(scale: scale, child: child),
                    child: success
                        ? Container(
                            width: 150,
                            height: 180,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: AppColors.secondary.withValues(
                                  alpha: 0.4,
                                ),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.secondary.withValues(
                                    alpha: 0.35,
                                  ),
                                  blurRadius: 36,
                                  spreadRadius: 2,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(22),
                              child: Image.asset(
                                getMedalAssetPath(gym.track),
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => const Center(
                                  child: Icon(
                                    Icons.emoji_events_rounded,
                                    size: 72,
                                    color: AppColors.amber,
                                  ),
                                ),
                              ),
                            ),
                          )
                        : Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.danger.withValues(alpha: 0.15),
                              border: Border.all(
                                color: AppColors.danger.withValues(alpha: 0.4),
                                width: 1.5,
                              ),
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              size: 64,
                              color: AppColors.danger,
                            ),
                          ),
                  ),
                  const SizedBox(height: 24),

                  Text(
                    success
                        ? '¡Medalla Conquistada!'
                        : paused
                        ? 'Evento Pausado'
                        : 'Respuesta Incorrecta',
                    style: TextStyle(
                      fontSize: 26,
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
                    if (result.performanceBonus > 0) ...[
                      const SizedBox(height: 4),
                      Text(
                        '+${result.performanceBonus} bonus de precisión',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primarySoft,
                        ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      'Total: ${result.totalPoints} pts · ${result.medals} medallas',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ] else if (paused)
                    const Text(
                      'Los descubrimientos están pausados temporalmente.',
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors.textSecondary,
                      ),
                    )
                  else ...[
                    const Text(
                      'La respuesta no es correcta.',
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Puedes intentarlo de nuevo inmediatamente.',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (hint != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.amber.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Pista: $hint',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
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
  const _CooldownScreen({required this.cooldownRemaining, required this.gym});

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
                  const Text(
                    'El Líder del Gimnasio te desafía de nuevo más tarde...',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
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
