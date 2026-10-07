import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class StartupErrorScreen extends StatelessWidget {
  const StartupErrorScreen({
    super.key,
    required this.onRetry,
    this.onOffline,
    this.message = 'No se pudo conectar con el evento',
  });

  final VoidCallback onRetry;
  final VoidCallback? onOffline;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.cloud_off_rounded,
                  size: 72,
                  color: AppColors.textMuted,
                ),
                const SizedBox(height: 20),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Revisa tu conexión a internet e intenta de nuevo.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.5,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 28),
                ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Reintentar'),
                ),
                if (onOffline != null) ...[
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: onOffline,
                    child: const Text(
                      'Continuar sin conexión',
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
