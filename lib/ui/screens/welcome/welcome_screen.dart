import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/status_pill.dart';
import '../../../state/app_scope.dart';
import '../../admin_navigation.dart';
import '../setup/participant_setup_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final event = controller.event;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.backgroundGradientTop, AppColors.background],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _BrandLogo(),
                const SizedBox(height: 20),
                Text(
                  event?.name ?? 'DevFest',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Text(
                  'Treasure Hunt',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  event?.dateLabel ?? '',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event?.description ??
                              'Encuentra todos los tesoros escondidos.',
                          style: const TextStyle(
                            fontSize: 15,
                            color: AppColors.textPrimary,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const _HowItWorksRow(
                          icon: Icons.qr_code_scanner_rounded,
                          text: 'Escanea los QR o introduce los códigos para '
                              'descubrirlos.',
                        ),
                        const SizedBox(height: 12),
                        const _HowItWorksRow(
                          icon: Icons.tips_and_updates_rounded,
                          text: 'Cada tesoro desbloquea una pista hacia otro.',
                        ),
                        const SizedBox(height: 12),
                        const _HowItWorksRow(
                          icon: Icons.emoji_events_rounded,
                          text: 'Encuentra todos antes que los demás y podrás '
                              'ganar el premio.',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    StatusPill(
                      label: '${controller.totalTreasures} tesoros',
                      color: AppColors.amber,
                      icon: Icons.explore_rounded,
                    ),
                    const SizedBox(width: 10),
                    const StatusPill(
                      label: 'Sin orden obligatorio',
                      color: AppColors.secondary,
                      icon: Icons.alt_route_rounded,
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const ParticipantSetupScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.flag_rounded),
                  label: const Text('Comenzar aventura'),
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: () => openAdminDemo(context),
                  icon: const Icon(Icons.admin_panel_settings_rounded),
                  label: const Text('Demo · Panel admin'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BrandLogo extends StatelessWidget {
  const _BrandLogo();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, Color(0xFF3B2FBF)],
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.5),
              blurRadius: 36,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Icon(
          Icons.explore_rounded,
          size: 72,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _HowItWorksRow extends StatelessWidget {
  const _HowItWorksRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 22, color: AppColors.primarySoft),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13.5,
              color: AppColors.textSecondary,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}