import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/open_external_link.dart';

typedef InformationLinkOpener = Future<bool> Function(Uri uri);

class InformationScreen extends StatelessWidget {
  const InformationScreen({super.key, this.linkOpener});

  final InformationLinkOpener? linkOpener;

  static final _scheduleDayOne = Uri.parse(
    'https://devfest.gdgsantodomingo.org/schedule?day=1',
  );
  static final _scheduleDayTwo = Uri.parse(
    'https://devfest.gdgsantodomingo.org/schedule?day=2',
  );
  static final _codeOfConduct = Uri.parse(
    'https://devfest.gdgsantodomingo.org/code-of-conduct',
  );
  static final _gdgInstagram = Uri.parse(
    'https://www.instagram.com/gdgsantodomingo/',
  );
  static final _gdgLinkedIn = Uri.parse(
    'https://www.linkedin.com/company/gdgsantodomingo/',
  );
  static final _github = Uri.parse('https://github.com/neryad');
  static final _projectRepository = Uri.parse(
    'https://github.com/neryad/devfest_treasure_hunt',
  );
  static final _linkedIn = Uri.parse(
    'https://www.linkedin.com/in/dayern-gomez',
  );
  static final _youtube = Uri.parse('https://www.youtube.com/@neryad');
  static final _x = Uri.parse('https://x.com/NeryadG');
  static final _instagram = Uri.parse('https://www.instagram.com/neryad_dev/');
  static final _feedback = Uri.parse(
    'https://docs.google.com/forms/d/e/1FAIpQLSeKLBT0vCD3AFrohM0BsSczxC-WicESU04z3HLXInMmx4YCng/viewform?usp=publish-editor',
  );

  Future<void> _open(BuildContext context, Uri uri) async {
    final open = linkOpener ?? openExternalLink;
    final opened = await open(uri);
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No pudimos abrir este enlace.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Información y reglas')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
              children: [
                const _IntroCard(),
                const SizedBox(height: 24),
                const _SectionTitle(
                  icon: Icons.route_rounded,
                  title: 'Cómo jugar',
                ),
                const SizedBox(height: 10),
                const _HowToPlayCard(),
                const SizedBox(height: 24),
                const _SectionTitle(
                  icon: Icons.extension_rounded,
                  title: 'Tipos de retos',
                ),
                const SizedBox(height: 10),
                const _ChallengeTypesCard(),
                const SizedBox(height: 24),
                const _SectionTitle(
                  icon: Icons.rule_rounded,
                  title: 'Puntos y reglas',
                ),
                const SizedBox(height: 10),
                const _RulesCard(),
                const SizedBox(height: 24),
                const _SectionTitle(
                  icon: Icons.event_rounded,
                  title: 'DevFest Santo Domingo 2026',
                ),
                const SizedBox(height: 10),
                _LinksCard(
                  children: [
                    _LinkTile(
                      key: const Key('info-schedule-day-one'),
                      icon: Icons.calendar_today_rounded,
                      title: 'Agenda · Día 1',
                      onTap: () => _open(context, _scheduleDayOne),
                    ),
                    _LinkTile(
                      icon: Icons.event_available_rounded,
                      title: 'Agenda · Día 2',
                      onTap: () => _open(context, _scheduleDayTwo),
                    ),
                    _LinkTile(
                      icon: Icons.gavel_rounded,
                      title: 'Código de conducta',
                      onTap: () => _open(context, _codeOfConduct),
                    ),
                    _LinkTile(
                      icon: Icons.camera_alt_outlined,
                      title: 'GDG Santo Domingo · Instagram',
                      onTap: () => _open(context, _gdgInstagram),
                    ),
                    _LinkTile(
                      icon: Icons.groups_rounded,
                      title: 'GDG Santo Domingo · LinkedIn',
                      onTap: () => _open(context, _gdgLinkedIn),
                      showDivider: false,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _FeedbackCard(onPressed: () => _open(context, _feedback)),
                const SizedBox(height: 24),
                _CreatorCard(
                  onGithub: () => _open(context, _github),
                  onProjectRepository: () => _open(context, _projectRepository),
                  onLinkedIn: () => _open(context, _linkedIn),
                  onYoutube: () => _open(context, _youtube),
                  onX: () => _open(context, _x),
                  onInstagram: () => _open(context, _instagram),
                ),
                const SizedBox(height: 20),
                const _CommunityThanks(),
                const SizedBox(height: 18),
                const Text(
                  'DevFest Master · Versión 1.0.0',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IntroCard extends StatelessWidget {
  const _IntroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF174EA6), Color(0xFF4285F4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(18)),
            child: Image(
              key: Key('information-app-icon'),
              image: AssetImage('web/icons/Icon-512.png'),
              width: 78,
              height: 78,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Conviértete en DevFest Master',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Explora los ocho gimnasios tecnológicos, supera sus retos y colecciona todas las medallas.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, height: 1.4),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primarySoft),
        const SizedBox(width: 9),
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 19,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _HowToPlayCard extends StatelessWidget {
  const _HowToPlayCard();

  @override
  Widget build(BuildContext context) {
    return const _ContentCard(
      child: Column(
        children: [
          _NumberedStep(
            number: '1',
            title: 'Encuentra un gimnasio',
            description: 'Escanea su QR o introduce el código indicado.',
          ),
          _NumberedStep(
            number: '2',
            title: 'Completa el reto',
            description:
                'Resuelve la trivia, el acertijo, la misión o el minijuego.',
          ),
          _NumberedStep(
            number: '3',
            title: 'Colecciona la medalla',
            description:
                'Conquista los ocho gimnasios para convertirte en DevFest Master.',
            showDivider: false,
          ),
        ],
      ),
    );
  }
}

class _ChallengeTypesCard extends StatelessWidget {
  const _ChallengeTypesCard();

  @override
  Widget build(BuildContext context) {
    return const _ContentCard(
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _TypeChip(Icons.quiz_rounded, 'Trivia'),
          _TypeChip(Icons.code_rounded, 'Código'),
          _TypeChip(Icons.sports_esports_rounded, 'Minijuego'),
          _TypeChip(Icons.qr_code_2_rounded, 'Exploración QR'),
          _TypeChip(Icons.psychology_alt_rounded, 'Acertijo'),
          _TypeChip(Icons.groups_rounded, 'Misión social'),
        ],
      ),
    );
  }
}

class _RulesCard extends StatelessWidget {
  const _RulesCard();

  @override
  Widget build(BuildContext context) {
    return const _ContentCard(
      child: Column(
        children: [
          _RuleLine('Cada gimnasio entrega una sola medalla.'),
          _RuleLine('Tu progreso se guarda automáticamente.'),
          _RuleLine('Algunos retos seleccionan preguntas al azar.'),
          _RuleLine('Cada gimnasio otorga 100 puntos base.'),
          _RuleLine('Sin errores: +30 puntos; con un error: +15 puntos.'),
          _RuleLine(
            'Pixel Perfect: 5 de 10 para la medalla y +10 puntos por cada acierto adicional.',
          ),
          _RuleLine('Completar los ocho gimnasios concede +100 puntos.'),
          _RuleLine(
            'Si un QR o un reto falla, solicita ayuda al staff.',
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _FeedbackCard extends StatelessWidget {
  const _FeedbackCard({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.primary.withValues(alpha: 0.12),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: Icon(Icons.rate_review_rounded, color: Colors.white),
                ),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tu experiencia importa',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Ayúdanos a mejorar DevFest Master. Completar la encuesta toma menos de dos minutos.',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              key: const Key('info-open-feedback'),
              onPressed: onPressed,
              icon: const Icon(Icons.open_in_new_rounded),
              label: const Text('Cuéntanos tu experiencia'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreatorCard extends StatelessWidget {
  const _CreatorCard({
    required this.onGithub,
    required this.onProjectRepository,
    required this.onLinkedIn,
    required this.onYoutube,
    required this.onX,
    required this.onInstagram,
  });

  final VoidCallback onGithub;
  final VoidCallback onProjectRepository;
  final VoidCallback onLinkedIn;
  final VoidCallback onYoutube;
  final VoidCallback onX;
  final VoidCallback onInstagram;

  @override
  Widget build(BuildContext context) {
    return _ContentCard(
      child: Column(
        children: [
          ClipOval(
            child: Image.network(
              'https://avatars.githubusercontent.com/u/20806101?s=192&v=4',
              width: 92,
              height: 92,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const ColoredBox(
                color: AppColors.primary,
                child: SizedBox(
                  width: 92,
                  height: 92,
                  child: Center(
                    child: Text(
                      'NG',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Dayern Gomez',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 21,
              fontWeight: FontWeight.w900,
            ),
          ),
          const Text(
            '@neryad · Mobile Developer',
            style: TextStyle(
              color: AppColors.primarySoft,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Desarrollador de software apasionado por crear experiencias que conectan tecnología y comunidad.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, height: 1.45),
          ),
          const SizedBox(height: 12),
          const Text(
            '“Edad de senior, corazón de junior y curiosidad de trainee.”',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.amberSoft,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              _SocialButton(
                key: const Key('info-creator-github'),
                icon: Icons.code_rounded,
                label: 'GitHub',
                onPressed: onGithub,
              ),
              _SocialButton(
                icon: Icons.business_center_rounded,
                label: 'LinkedIn',
                onPressed: onLinkedIn,
              ),
              _SocialButton(
                icon: Icons.smart_display_rounded,
                label: 'YouTube',
                onPressed: onYoutube,
              ),
              _SocialButton(
                key: const Key('info-creator-x'),
                icon: Icons.alternate_email_rounded,
                label: 'X',
                onPressed: onX,
              ),
              _SocialButton(
                key: const Key('info-creator-instagram'),
                icon: Icons.camera_alt_outlined,
                label: 'Instagram',
                onPressed: onInstagram,
              ),
            ],
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            key: const Key('info-project-repository'),
            onPressed: onProjectRepository,
            icon: const Icon(Icons.folder_open_rounded, size: 18),
            label: const Text('Código fuente de DevFest Master'),
          ),
          const SizedBox(height: 14),
          const Text(
            'Desarrollado con Flutter y Firebase.',
            style: TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _CommunityThanks extends StatelessWidget {
  const _CommunityThanks();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Icon(Icons.favorite_rounded, color: AppColors.dangerSoft, size: 30),
        SizedBox(height: 8),
        Text(
          'Hecho con amor, por y para la comunidad.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: 6),
        Text(
          'Gracias al equipo de GDG Santo Domingo y a Eury Pérez por la oportunidad y la confianza.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textSecondary, height: 1.4),
        ),
      ],
    );
  }
}

class _ContentCard extends StatelessWidget {
  const _ContentCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(padding: const EdgeInsets.all(18), child: child),
    );
  }
}

class _NumberedStep extends StatelessWidget {
  const _NumberedStep({
    required this.number,
    required this.title,
    required this.description,
    this.showDivider = true,
  });

  final String number;
  final String title;
  final String description;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primary,
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    description,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (showDivider)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(height: 1),
          ),
      ],
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip(this.icon, this.label);

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 18, color: AppColors.primarySoft),
      label: Text(label),
      backgroundColor: AppColors.surfaceAlt,
      side: const BorderSide(color: AppColors.border),
    );
  }
}

class _RuleLine extends StatelessWidget {
  const _RuleLine(this.text, {this.isLast = false});

  final String text;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(
              Icons.check_circle_rounded,
              size: 18,
              color: AppColors.successSoft,
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

class _LinksCard extends StatelessWidget {
  const _LinksCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(child: Column(children: children));
  }
}

class _LinkTile extends StatelessWidget {
  const _LinkTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.showDivider = true,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: AppColors.primarySoft),
          title: Text(title),
          trailing: const Icon(Icons.open_in_new_rounded, size: 18),
          onTap: onTap,
        ),
        if (showDivider) const Divider(height: 1, indent: 56),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 44),
        padding: const EdgeInsets.symmetric(horizontal: 14),
      ),
      icon: Icon(icon, size: 18),
      label: Text(label),
    );
  }
}
