import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/snack_bar_utils.dart';
import '../../../domain/use_cases/discover_treasure_use_case.dart';
import '../../../state/app_scope.dart';
import '../challenge/challenge_navigation.dart';
import 'treasure_found_modal.dart';

/// Alternative to scanning: type the treasure code manually.
/// It runs exactly the same `discoverTreasure` rule as the QR path.
class ManualCodeScreen extends StatefulWidget {
  const ManualCodeScreen({super.key});

  @override
  State<ManualCodeScreen> createState() => _ManualCodeScreenState();
}

class _ManualCodeScreenState extends State<ManualCodeScreen> {
  final _controller = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit([String? value]) async {
    if (_submitting) return;
    final code = (value ?? _controller.text).trim();
    if (code.isEmpty) return;
    setState(() => _submitting = true);
    final app = AppScope.read(context);
    try {
      final result = await app.discoverByCode(code);
      if (!mounted) return;
      if (result.failure == DiscoverFailure.requiresChallenge &&
          result.treasure != null) {
        await openChallenge(context, result.treasure!);
      } else {
        await handleDiscoveryResult(context, result);
      }
    } catch (_) {
      if (mounted) showNetworkError(context);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final examples = app.treasures
        .where((t) => t.isActive)
        .take(4)
        .map((t) => t.code)
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Introduce el código')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.keyboard_rounded,
                size: 64,
                color: AppColors.primarySoft,
              ),
              const SizedBox(height: 16),
              const Text(
                '¿Tienes un código impreso?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Escribe el código manual del gimnasio.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _controller,
                textCapitalization: TextCapitalization.characters,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  letterSpacing: 2,
                  fontSize: 18,
                ),
                decoration: const InputDecoration(
                  labelText: 'Código del gimnasio',
                  hintText: 'DEVFEST-001',
                  prefixIcon: Icon(Icons.password_rounded),
                ),
                onSubmitted: _submit,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _submitting ? null : () => _submit(_controller.text),
                icon: _submitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.search_rounded),
                label: const Text('Validar gimnasio'),
              ),
              const SizedBox(height: 24),
              const Text(
                'Códigos de ejemplo',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final code in examples)
                    ActionChip(
                      label: Text(
                        code,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          letterSpacing: 1,
                        ),
                      ),
                      onPressed: () => _submit(code),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
