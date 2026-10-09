import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/theme/app_theme.dart';

typedef SecurityScannerBuilder =
    Widget Function(BuildContext context, ValueChanged<String> onDetected);

class SecurityChallengeScreen extends StatefulWidget {
  const SecurityChallengeScreen({
    super.key,
    required this.onCompleted,
    this.validationCode = 'SECURE2026',
    this.scannerBuilder,
  });

  final Future<void> Function() onCompleted;
  final String validationCode;
  final SecurityScannerBuilder? scannerBuilder;

  @override
  State<SecurityChallengeScreen> createState() =>
      _SecurityChallengeScreenState();
}

class _SecurityChallengeScreenState extends State<SecurityChallengeScreen> {
  static const _expectedFragments = ['SE', 'CU', 'RE', '20', '26'];

  final Map<int, String> _foundFragments = {};
  bool _completing = false;

  String get _assembled => List.generate(
    _expectedFragments.length,
    (index) => _foundFragments[index] ?? '',
  ).join();

  bool get _isComplete =>
      _foundFragments.length == _expectedFragments.length &&
      _assembled == widget.validationCode.trim().toUpperCase();

  Future<void> _scanFragment() async {
    final value = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(
        builder: (_) =>
            _SecurityQrScanner(scannerBuilder: widget.scannerBuilder),
      ),
    );
    if (value != null && mounted) _acceptPayload(value);
  }

  Future<void> _enterFragment() async {
    var enteredValue = '';
    final value = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Ingresar fragmento'),
        content: TextField(
          key: const Key('security-fragment-field'),
          autofocus: true,
          textCapitalization: TextCapitalization.characters,
          decoration: const InputDecoration(
            hintText: 'Contenido del QR',
            prefixIcon: Icon(Icons.password_rounded),
          ),
          onChanged: (value) => enteredValue = value,
          onSubmitted: (value) => Navigator.pop(dialogContext, value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, enteredValue),
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
    if (value != null && mounted) _acceptPayload(value);
  }

  void _acceptPayload(String rawValue) {
    final value = rawValue.trim().toUpperCase();
    if (value.isEmpty) return;

    if (value == widget.validationCode.trim().toUpperCase()) {
      setState(() {
        for (var index = 0; index < _expectedFragments.length; index++) {
          _foundFragments[index] = _expectedFragments[index];
        }
      });
      _showMessage('¡Código completo encontrado! Ya puedes validarlo.');
      return;
    }

    final scanned = _parseFragment(value);
    if (scanned == null) {
      _showMessage('Este QR no pertenece a The Hidden Exploit.');
      return;
    }
    if (_foundFragments.containsKey(scanned.index)) {
      _showMessage('Ya habías encontrado este fragmento.');
      return;
    }

    setState(() => _foundFragments[scanned.index] = scanned.value);
    _showMessage(
      _isComplete
          ? '¡Frase completada! Valídala para reclamar la medalla.'
          : 'Fragmento agregado: ${_foundFragments.length}/${_expectedFragments.length}',
    );
  }

  _SecurityFragment? _parseFragment(String value) {
    var fragment = value;
    int? declaredIndex;
    final parts = value.split(':');
    if (parts.length == 3 && parts.first == 'SECURITY') {
      declaredIndex = int.tryParse(parts[1]);
      fragment = parts[2].trim();
    }

    final index = _expectedFragments.indexOf(fragment);
    if (index < 0) return null;
    if (declaredIndex != null && declaredIndex != index + 1) return null;
    return _SecurityFragment(index, fragment);
  }

  Future<void> _complete() async {
    if (!_isComplete || _completing) return;
    setState(() => _completing = true);
    try {
      await widget.onCompleted();
    } finally {
      if (mounted) setState(() => _completing = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('The Hidden Exploit'),
        leading: IconButton(
          tooltip: 'Cerrar',
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.close_rounded),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: ListView(
              key: const Key('security-challenge-screen'),
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              children: [
                const _SecurityHero(),
                const SizedBox(height: 20),
                Text(
                  '${_foundFragments.length} de ${_expectedFragments.length} fragmentos',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.primarySoft,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: _foundFragments.length / _expectedFragments.length,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(99),
                  backgroundColor: AppColors.surfaceAlt,
                  color: _isComplete
                      ? AppColors.successSoft
                      : AppColors.primarySoft,
                ),
                const SizedBox(height: 20),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      children: [
                        const Text(
                          'Código en construcción',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Wrap(
                          key: const Key('security-fragment-slots'),
                          alignment: WrapAlignment.center,
                          spacing: 8,
                          runSpacing: 8,
                          children: List.generate(
                            _expectedFragments.length,
                            (index) => _FragmentSlot(
                              index: index,
                              value: _foundFragments[index],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: Text(
                            _assembled.isEmpty ? '••••••••••' : _assembled,
                            key: ValueKey(_assembled),
                            style: TextStyle(
                              color: _isComplete
                                  ? AppColors.successSoft
                                  : AppColors.textPrimary,
                              fontSize: 25,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                ElevatedButton.icon(
                  key: const Key('security-scan-fragment'),
                  onPressed: _completing ? null : _scanFragment,
                  icon: const Icon(Icons.qr_code_scanner_rounded),
                  label: const Text('Escanear fragmento'),
                ),
                const SizedBox(height: 10),
                TextButton.icon(
                  key: const Key('security-enter-fragment'),
                  onPressed: _completing ? null : _enterFragment,
                  icon: const Icon(Icons.keyboard_rounded),
                  label: const Text('Ingresar fragmento manualmente'),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  key: const Key('security-complete'),
                  onPressed: _isComplete && !_completing ? _complete : null,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(54),
                    backgroundColor: AppColors.success,
                  ),
                  icon: _completing
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.verified_rounded),
                  label: const Text('Validar frase y reclamar medalla'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SecurityHero extends StatelessWidget {
  const _SecurityHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7F1D1D), Color(0xFFEA4335)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Column(
        children: [
          Icon(Icons.security_rounded, size: 48, color: Colors.white),
          SizedBox(height: 10),
          Text(
            'Encuentra los QR ocultos',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Cada QR contiene una pieza. Escanéalas en cualquier orden y la app reconstruirá el código final.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, height: 1.4),
          ),
        ],
      ),
    );
  }
}

class _FragmentSlot extends StatelessWidget {
  const _FragmentSlot({required this.index, required this.value});

  final int index;
  final String? value;

  @override
  Widget build(BuildContext context) {
    final found = value != null;
    return AnimatedContainer(
      key: Key('security-fragment-$index'),
      duration: const Duration(milliseconds: 220),
      width: 58,
      height: 58,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: found
            ? AppColors.success.withValues(alpha: 0.18)
            : AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: found ? AppColors.successSoft : AppColors.border,
          width: found ? 2 : 1,
        ),
      ),
      child: Text(
        value ?? '?',
        style: TextStyle(
          color: found ? AppColors.successSoft : AppColors.textMuted,
          fontSize: 17,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _SecurityFragment {
  const _SecurityFragment(this.index, this.value);

  final int index;
  final String value;
}

class _SecurityQrScanner extends StatefulWidget {
  const _SecurityQrScanner({this.scannerBuilder});

  final SecurityScannerBuilder? scannerBuilder;

  @override
  State<_SecurityQrScanner> createState() => _SecurityQrScannerState();
}

class _SecurityQrScannerState extends State<_SecurityQrScanner> {
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
        title: const Text('Escanea una pista'),
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
                  border: Border.all(color: AppColors.dangerSoft, width: 4),
                ),
              ),
            ),
          ),
          const Positioned(
            left: 24,
            right: 24,
            bottom: 54,
            child: Text(
              'Busca los QR de The Hidden Exploit. Cada código agregará una pieza automáticamente.',
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
