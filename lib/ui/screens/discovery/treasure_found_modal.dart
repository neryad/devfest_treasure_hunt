import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../domain/use_cases/discover_treasure_use_case.dart';
import '../completion/completion_screen.dart';

/// Shared feedback after a scan/code attempt:
/// success opens the treasure-found modal, failures show a SnackBar.
Future<void> handleDiscoveryResult(
  BuildContext context,
  DiscoverTreasureResult result,
) async {
  if (result.failure != null) {
    final message = switch (result.failure!) {
      DiscoverFailure.treasureNotFound =>
        'Tesoro no encontrado. Verifica el código o el QR.',
      DiscoverFailure.notActive =>
        'No disponible todavía: este tesoro está desactivado.',
      DiscoverFailure.alreadyDiscovered =>
        '¡Ya descubriste este tesoro!',
      DiscoverFailure.participantNotFound =>
        'Necesitas registrarte antes de descubrir tesoros.',
    };
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
    return;
  }

  await showTreasureFoundModal(context, result);

  if (result.completed && context.mounted) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const CompletionScreen()),
    );
  }
}

Future<void> showTreasureFoundModal(
  BuildContext context,
  DiscoverTreasureResult result,
) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => TreasureFoundDialog(result: result),
  );
}

class TreasureFoundDialog extends StatefulWidget {
  const TreasureFoundDialog({super.key, required this.result});

  final DiscoverTreasureResult result;

  @override
  State<TreasureFoundDialog> createState() => _TreasureFoundDialogState();
}

class _TreasureFoundDialogState extends State<TreasureFoundDialog> {
  bool _revealed = false;

  @override
  Widget build(BuildContext context) {
    final result = widget.result;
    final treasure = result.treasure!;
    final clue = result.clue ?? '';

    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: AppColors.amber, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.4, end: 1),
              duration: const Duration(milliseconds: 600),
              curve: Curves.elasticOut,
              builder: (_, scale, child) =>
                  Transform.scale(scale: scale, child: child),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [AppColors.amber, Color(0xFFB76E00)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.amber.withValues(alpha: 0.5),
                      blurRadius: 40,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  size: 56,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '¡Tesoro encontrado!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              treasure.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 500),
              opacity: _revealed ? 1 : 0.15,
              child: Card(
                color: AppColors.surfaceAlt,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.tips_and_updates_rounded,
                            size: 18,
                            color: AppColors.secondary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _revealed ? 'Pista desbloqueada' : 'Pista',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: AppColors.secondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        clue,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textPrimary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (!_revealed) {
                    setState(() => _revealed = true);
                    return;
                  }
                  Navigator.of(context).pop();
                },
                child: Text(_revealed
                    ? (result.completed
                        ? 'Ver mi resultado final'
                        : '¡A por el siguiente!')
                    : 'Revelar pista'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}