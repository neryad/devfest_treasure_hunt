import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/treasure_icons.dart';
import '../../../domain/entities/treasure_item.dart';
import '../../../state/app_scope.dart';
import 'treasure_found_modal.dart';

/// Discovery by QR. Two modes coexist for demo purposes:
/// - Camera: real scanning through `mobile_scanner`.
/// - Simulate: pick a treasure from a list (for simulators / no camera).
///
/// The seam towards any future scanner implementation is `discoverByQrValue`:
/// whatever produces a raw QR string ends in the same `discoverTreasure` rule.
class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  MobileScannerController? _controller;
  bool _usingCamera = false;
  bool _handling = false;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      formats: const [BarcodeFormat.qrCode],
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _handleValue(String value) async {
    if (_handling) return;
    _handling = true;
    final controller = AppScope.read(context);
    final result = await controller.discoverByQrValue(value);
    if (!mounted) {
      _handling = false;
      return;
    }
    await handleDiscoveryResult(context, result);
    _handling = false;
    if (mounted && _usingCamera) {
      // Unpause UI (noDuplicates already throttles detected codes).
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escanear QR'),
        actions: [
          SegmentedButton<bool>(
            style: SegmentedButton.styleFrom(
              selectedBackgroundColor: AppColors.primary,
              selectedForegroundColor: Colors.white,
              foregroundColor: AppColors.textSecondary,
              visualDensity: VisualDensity.compact,
            ),
            segments: const [
              ButtonSegment(
                value: false,
                icon: Icon(Icons.videocam_rounded, size: 16),
                label: Text('Demo'),
              ),
              ButtonSegment(
                value: true,
                icon: Icon(Icons.camera_alt_rounded, size: 16),
                label: Text('Cámara'),
              ),
            ],
            selected: {_usingCamera},
            onSelectionChanged: (selection) {
              setState(() => _usingCamera = selection.first);
            },
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SafeArea(
        child: _usingCamera ? _buildCamera() : _buildDemoPicker(),
      ),
    );
  }

  Widget _buildCamera() {
    return MobileScanner(
      controller: _controller,
      onDetect: (capture) {
        final value = capture.barcodes
            .map((b) => b.rawValue)
            .whereType<String>()
            .firstOrNull;
        if (value != null && value.trim().isNotEmpty) {
          _handleValue(value.trim());
        }
      },
      overlayBuilder: (context, constraints) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 32),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'Encuadra el QR de un tesoro',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: 240,
                height: 240,
                child: CustomPaint(
                  painter: _QrFramePainter(),
                ),
              ),
              const Spacer(),
              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDemoPicker() {
    final controller = AppScope.of(context);
    final treasures = controller.treasures;

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: treasures.length + 1,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        if (index == 0) {
          return const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text(
              'Modo demo · simula apuntar el QR a un tesoro',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          );
        }
        final treasure = treasures[index - 1];
        final status = controller.statusOf(treasure);
        final discovered = status == TreasureStatus.discovered;
        return Card(
          child: ListTile(
            leading: Icon(
              discovered
                  ? Icons.check_circle_rounded
                  : treasureIconForKey(treasure.iconKey),
              color: discovered ? AppColors.success : AppColors.primarySoft,
            ),
            title: Text(treasure.title),
            subtitle: Text(
              treasure.qrValue,
              style: const TextStyle(
                fontFamily: 'monospace',
                letterSpacing: 1,
              ),
            ),
            trailing: const Icon(Icons.qr_code_2_rounded, color: AppColors.amber),
            enabled: !discovered,
            onTap: discovered
                ? null
                : () => _handleValue(treasure.qrValue),
          ),
        );
      },
    );
  }
}

class _QrFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    const corner = 34.0;
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(16),
    );
    canvas.drawRRect(rect, paint);
    paint.strokeWidth = 5;
    final corners = [
      Rect.fromLTWH(0, 0, corner, corner),
      Rect.fromLTWH(size.width - corner, 0, corner, corner),
      Rect.fromLTWH(0, size.height - corner, corner, corner),
      Rect.fromLTWH(size.width - corner, size.height - corner, corner, corner),
    ];
    for (final c in corners) {
      canvas.drawArc(
        c,
        _startFor(c, size),
        _sweepFor(c, size),
        false,
        paint,
      );
    }
  }

  double _startFor(Rect c, Size size) {
    if (c.left == 0 && c.top == 0) return 0;
    if (c.right == size.width && c.top == 0) return 1.57;
    if (c.left == 0) return 3.14;
    return 4.71;
  }

  double _sweepFor(Rect c, Size size) => 1.57;

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}