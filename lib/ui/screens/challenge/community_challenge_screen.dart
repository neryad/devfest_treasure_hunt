import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_theme.dart';

typedef CommunityLinkOpener = Future<bool> Function(Uri uri);
typedef CommunityScannerBuilder =
    Widget Function(BuildContext context, ValueChanged<String> onDetected);

class CommunityChallengeScreen extends StatefulWidget {
  const CommunityChallengeScreen({
    super.key,
    required this.onCompleted,
    this.validationCode = 'COMMUNITY-SIGNAL',
    this.linkOpener,
    this.scannerBuilder,
  });

  static final communityUri = Uri.parse(
    'https://gdg.community.dev/gdg-santo-domingo/',
  );
  static final ticketsUri = Uri.parse(
    'https://gdg.community.dev/events/details/google-gdg-santo-domingo-presents-devfest-santo-domingo-2026/?code=general-df-sd-26',
  );

  final Future<void> Function() onCompleted;
  final String validationCode;
  final CommunityLinkOpener? linkOpener;
  final CommunityScannerBuilder? scannerBuilder;

  @override
  State<CommunityChallengeScreen> createState() =>
      _CommunityChallengeScreenState();
}

class _CommunityChallengeScreenState extends State<CommunityChallengeScreen> {
  bool _communityOpened = false;
  bool _joinedConfirmed = false;
  bool _ticketsOpened = false;
  bool _ticketsConfirmed = false;
  bool _openingLink = false;
  bool _completing = false;

  CommunityLinkOpener get _openLink =>
      widget.linkOpener ??
      (uri) => launchUrl(uri, mode: LaunchMode.externalApplication);

  Future<void> _launch(Uri uri, {required bool community}) async {
    if (_openingLink) return;
    setState(() => _openingLink = true);
    try {
      final opened = await _openLink(uri);
      if (!mounted) return;
      if (!opened) {
        _showMessage('No pudimos abrir el enlace. Inténtalo nuevamente.');
        return;
      }
      setState(() {
        if (community) {
          _communityOpened = true;
        } else {
          _ticketsOpened = true;
        }
      });
    } catch (_) {
      if (mounted) {
        _showMessage('No pudimos abrir el enlace. Inténtalo nuevamente.');
      }
    } finally {
      if (mounted) setState(() => _openingLink = false);
    }
  }

  Future<void> _scanQr() async {
    final value = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(
        builder: (_) =>
            _CommunityQrScanner(scannerBuilder: widget.scannerBuilder),
      ),
    );
    if (value != null && mounted) await _validateCode(value);
  }

  Future<void> _enterCode() async {
    var enteredCode = '';
    final value = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Código del staff'),
        content: TextField(
          key: const Key('community-code-field'),
          autofocus: true,
          textCapitalization: TextCapitalization.characters,
          decoration: const InputDecoration(
            hintText: 'Escribe el código del QR',
            prefixIcon: Icon(Icons.password_rounded),
          ),
          onChanged: (value) => enteredCode = value,
          onSubmitted: (code) => Navigator.pop(dialogContext, code),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, enteredCode),
            child: const Text('Validar'),
          ),
        ],
      ),
    );
    if (value != null && mounted) await _validateCode(value);
  }

  Future<void> _validateCode(String value) async {
    if (_completing) return;
    if (value.trim().toUpperCase() !=
        widget.validationCode.trim().toUpperCase()) {
      _showMessage('Ese no es el QR de validación. Pídele ayuda al staff.');
      return;
    }
    setState(() => _completing = true);
    await widget.onCompleted();
    if (mounted) setState(() => _completing = false);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final canOpenTickets = _joinedConfirmed;
    final canValidate = _joinedConfirmed && _ticketsConfirmed;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Signal'),
        leading: IconButton(
          tooltip: 'Cerrar',
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SafeArea(
        child: ListView(
          key: const Key('community-challenge-screen'),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            const _CommunityHero(),
            const SizedBox(height: 22),
            _ProgressHeader(
              completed: [
                _joinedConfirmed,
                _ticketsConfirmed,
                false,
              ].where((value) => value).length,
            ),
            const SizedBox(height: 14),
            _MissionStep(
              number: 1,
              title: 'Únete a GDG Santo Domingo',
              description:
                  'Abre la comunidad y pulsa Join. Después vuelve a esta pantalla.',
              completed: _joinedConfirmed,
              enabled: true,
              action: OutlinedButton.icon(
                key: const Key('community-open-join'),
                onPressed: _openingLink
                    ? null
                    : () => _launch(
                        CommunityChallengeScreen.communityUri,
                        community: true,
                      ),
                icon: const Icon(Icons.open_in_new_rounded),
                label: Text(
                  _communityOpened ? 'Abrir nuevamente' : 'Abrir comunidad',
                ),
              ),
              confirmation: _communityOpened
                  ? Material(
                      color: Colors.transparent,
                      child: CheckboxListTile(
                        key: const Key('community-confirm-join'),
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                        value: _joinedConfirmed,
                        onChanged: (value) =>
                            setState(() => _joinedConfirmed = value ?? false),
                        title: const Text('Confirmo que pulsé Join'),
                      ),
                    )
                  : null,
            ),
            const SizedBox(height: 12),
            _MissionStep(
              number: 2,
              title: 'Obtén tu entrada',
              description: 'Abre la página del DevFest y completa Get tickets.',
              completed: _ticketsConfirmed,
              enabled: canOpenTickets,
              lockedMessage: 'Completa primero el paso 1.',
              action: OutlinedButton.icon(
                key: const Key('community-open-tickets'),
                onPressed: canOpenTickets && !_openingLink
                    ? () => _launch(
                        CommunityChallengeScreen.ticketsUri,
                        community: false,
                      )
                    : null,
                icon: const Icon(Icons.confirmation_number_outlined),
                label: Text(
                  _ticketsOpened ? 'Abrir nuevamente' : 'Obtener entrada',
                ),
              ),
              confirmation: _ticketsOpened
                  ? Material(
                      color: Colors.transparent,
                      child: CheckboxListTile(
                        key: const Key('community-confirm-tickets'),
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                        value: _ticketsConfirmed,
                        onChanged: (value) =>
                            setState(() => _ticketsConfirmed = value ?? false),
                        title: const Text('Confirmo que obtuve mi entrada'),
                      ),
                    )
                  : null,
            ),
            const SizedBox(height: 12),
            _MissionStep(
              number: 3,
              title: 'Valida con el staff',
              description:
                  'Ve al booth de comunidad y muestra las dos confirmaciones. El staff te enseñará el QR privado.',
              completed: false,
              enabled: canValidate,
              lockedMessage: 'Completa los dos registros para continuar.',
              action: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton.icon(
                    key: const Key('community-scan-qr'),
                    onPressed: canValidate && !_completing ? _scanQr : null,
                    icon: _completing
                        ? const SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.qr_code_scanner_rounded),
                    label: const Text('Escanear QR del staff'),
                  ),
                  const SizedBox(height: 4),
                  TextButton(
                    key: const Key('community-enter-code'),
                    onPressed: canValidate && !_completing ? _enterCode : null,
                    child: const Text(
                      '¿Problemas con la cámara? Escribir código',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_outline_rounded, size: 15),
                SizedBox(width: 6),
                Flexible(
                  child: Text(
                    'No guardamos capturas ni datos de tus registros.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CommunityHero extends StatelessWidget {
  const _CommunityHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.secondary.withValues(alpha: 0.28),
            AppColors.surface,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.45)),
      ),
      child: const Column(
        children: [
          CircleAvatar(
            radius: 31,
            backgroundColor: AppColors.secondary,
            child: Icon(Icons.groups_rounded, color: Colors.white, size: 34),
          ),
          SizedBox(height: 14),
          Text(
            'Únete a la comunidad',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 23, fontWeight: FontWeight.w900),
          ),
          SizedBox(height: 7),
          Text(
            'Completa los registros, valida con nuestro staff y desbloquea la medalla Comunidad.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, height: 1.4),
          ),
        ],
      ),
    );
  }
}

class _ProgressHeader extends StatelessWidget {
  const _ProgressHeader({required this.completed});

  final int completed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Tu misión',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
          ),
        ),
        Text(
          '$completed de 3 pasos',
          key: const Key('community-progress'),
          style: const TextStyle(
            color: AppColors.successSoft,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _MissionStep extends StatelessWidget {
  const _MissionStep({
    required this.number,
    required this.title,
    required this.description,
    required this.completed,
    required this.enabled,
    required this.action,
    this.confirmation,
    this.lockedMessage,
  });

  final int number;
  final String title;
  final String description;
  final bool completed;
  final bool enabled;
  final Widget action;
  final Widget? confirmation;
  final String? lockedMessage;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: enabled ? 1 : 0.58,
      child: Container(
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: completed
                ? AppColors.success.withValues(alpha: 0.75)
                : AppColors.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: completed
                      ? AppColors.success
                      : enabled
                      ? AppColors.primary
                      : AppColors.surfaceAlt,
                  child: completed
                      ? const Icon(Icons.check_rounded, color: Colors.white)
                      : Text(
                          '$number',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
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
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            action,
            ?confirmation,
            if (!enabled && lockedMessage != null) ...[
              const SizedBox(height: 9),
              Text(
                lockedMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CommunityQrScanner extends StatefulWidget {
  const _CommunityQrScanner({this.scannerBuilder});

  final CommunityScannerBuilder? scannerBuilder;

  @override
  State<_CommunityQrScanner> createState() => _CommunityQrScannerState();
}

class _CommunityQrScannerState extends State<_CommunityQrScanner> {
  bool _handled = false;

  void _handleValue(String value) {
    if (_handled || value.trim().isEmpty) return;
    _handled = true;
    Navigator.of(context).pop(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Escanea el QR del staff'),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (widget.scannerBuilder case final builder?)
            builder(context, _handleValue)
          else
            MobileScanner(
              onDetect: (capture) {
                for (final barcode in capture.barcodes) {
                  final value = barcode.rawValue;
                  if (value != null) {
                    _handleValue(value);
                    break;
                  }
                }
              },
            ),
          Center(
            child: IgnorePointer(
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.successSoft, width: 4),
                ),
              ),
            ),
          ),
          const Positioned(
            left: 24,
            right: 24,
            bottom: 54,
            child: Text(
              'Apunta al código que te mostrará el staff después de revisar tus confirmaciones.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                shadows: [Shadow(color: Colors.black, blurRadius: 8)],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
