import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/status_pill.dart';
import '../../../state/app_scope.dart';
import '../../admin_navigation.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _nicknameController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    final controller = AppScope.read(context);
    await controller.startParticipant(
      name: _nameController.text.trim(),
      nickname: _nicknameController.text.trim(),
    );
  }

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
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // --- BANNER HERO ---
                    const _BannerHero(),
                    const SizedBox(height: 20),

                    // --- TITLE & EVENT INFO ---
                    const Text(
                      'DevFest Master',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Conquista los 8 Gimnasios Tecnológicos',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primarySoft,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      event?.dateLabel ?? '9 · 10 de octubre — Biblioteca Nacional',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),

                    if (controller.sessionExpired) ...[
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.amber.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Tu sesión anterior ya no existe — regístrate de nuevo.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.amber,
                          ),
                        ),
                      ),
                    ],

                    // --- DIRECT REGISTRATION CARD ---
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'Regístrate para jugar',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Ingresa tu nombre y tu alias para competir en el ranking.',
                              style: TextStyle(
                                fontSize: 12.5,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 18),
                            TextFormField(
                              controller: _nameController,
                              textCapitalization: TextCapitalization.words,
                              decoration: const InputDecoration(
                                labelText: 'Tu Nombre',
                                hintText: 'Ej: Carlos Pérez',
                                prefixIcon: Icon(Icons.person_rounded, color: AppColors.primary),
                              ),
                              validator: (v) =>
                                  (v == null || v.trim().isEmpty) ? 'Ingresa tu nombre' : null,
                            ),
                            const SizedBox(height: 14),
                            TextFormField(
                              controller: _nicknameController,
                              decoration: const InputDecoration(
                                labelText: 'Nickname / Alias para el Ranking',
                                hintText: 'Ej: carlostech',
                                prefixIcon: Icon(Icons.alternate_email_rounded, color: AppColors.amber),
                              ),
                              validator: (v) =>
                                  (v == null || v.trim().isEmpty) ? 'Ingresa un alias' : null,
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              onPressed: _submitting ? null : _start,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 4,
                                shadowColor: AppColors.primary.withValues(alpha: 0.5),
                              ),
                              icon: _submitting
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.play_arrow_rounded, size: 24),
                              label: const Text(
                                '¡Comenzar aventura!',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // --- EVENT FEATURE PILLS ---
                    const Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        StatusPill(
                          label: '8 Gimnasios',
                          color: AppColors.amber,
                          icon: Icons.military_tech_rounded,
                        ),
                        StatusPill(
                          label: 'Trivia & Código',
                          color: AppColors.primarySoft,
                          icon: Icons.psychology_rounded,
                        ),
                        StatusPill(
                          label: 'Ranking en Vivo',
                          color: AppColors.secondary,
                          icon: Icons.leaderboard_rounded,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // --- ADMIN ACCESS ---
                    Center(
                      child: TextButton.icon(
                        onPressed: () => openAdminDemo(context),
                        icon: const Icon(Icons.admin_panel_settings_rounded, size: 18),
                        label: const Text('Panel de Administración (Demo)'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.textMuted,
                          textStyle: const TextStyle(fontSize: 12.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BannerHero extends StatelessWidget {
  const _BannerHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.35), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 28,
            spreadRadius: 2,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Image.asset(
            'assets/images/devfest_master_banner.png',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primary, Color(0xFF1A5FC9)],
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.explore_rounded,
                    size: 64,
                    color: Colors.white,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}