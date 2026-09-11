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
                const Text(
                  'DevFest Master',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Text(
                  'Conquista los 8 Gimnasios',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
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
                        const Text(
                          'Conquista los 8 Gimnasios Tecnológicos del DevFest y conviértete en DevFest Master.',
                          style: TextStyle(
                            fontSize: 15,
                            color: AppColors.textPrimary,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const _HowItWorksRow(
                          icon: Icons.qr_code_scanner_rounded,
                          text: 'Escanea el QR del gimnasio o introduce el código para '
                              'acceder al reto.',
                        ),
                        const SizedBox(height: 12),
                        const _HowItWorksRow(
                          icon: Icons.tips_and_updates_rounded,
                          text: 'Resuelve el reto: trivia, acertijo o código. ¡Gana puntos y medallas!',
                        ),
                        const SizedBox(height: 12),
                        const _HowItWorksRow(
                          icon: Icons.emoji_events_rounded,
                          text: 'Completa los 8 gimnasios y alcanza el título de DevFest Master.',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const SizedBox(height: 16),
                const Text(
                  'Elige tu avatar',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                const _AvatarPicker(),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    StatusPill(
                      label: '8 Gimnasios',
                      color: AppColors.amber,
                      icon: Icons.explore_rounded,
                    ),
                    SizedBox(width: 10),
                    StatusPill(
                      label: '6 tipos de reto',
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
                  label: const Text('¡Comenzar aventura!'),
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
            colors: [AppColors.primary, Color(0xFF1A5FC9)],
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

class _AvatarPicker extends StatefulWidget {
  const _AvatarPicker();

  @override
  State<_AvatarPicker> createState() => _AvatarPickerState();
}

class _AvatarPickerState extends State<_AvatarPicker> {
  String _selected = '😎';
  static const _avatars = ['😎', '🦊', '🐉'];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: _avatars.map((emoji) {
        final isSelected = emoji == _selected;
        return GestureDetector(
          onTap: () => setState(() => _selected = emoji),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.15)
                  : AppColors.surface,
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.surfaceAlt,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Text(
              emoji,
              style: const TextStyle(fontSize: 32),
            ),
          ),
        );
      }).toList(),
    );
  }
}