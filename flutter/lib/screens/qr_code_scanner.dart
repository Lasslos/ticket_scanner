import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:ticket_scanner/util/logger.dart';
import 'package:vibration/vibration.dart';

Future<Barcode?> showScanDialog(BuildContext context) {
  final qrKey = GlobalKey<_QRCodeScannerState>();
  return showDialog<Barcode>(
    context: context,
    builder: (dialogContext) => Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16).copyWith(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'QR-Code scannen',
                style: Theme.of(dialogContext).textTheme.headlineSmall,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: QRCodeScanner(
                key: qrKey,
                onScan: (data) async {
                  Navigator.of(dialogContext).maybePop(data);
                  if ((await Vibration.hasVibrator())!) {
                    getLogger().d("Vibrating, data: ${data.code}");
                    await Vibration.vibrate(amplitude: 64, duration: 32);
                  }
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Abbrechen'),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

class QRCodeScanner extends ConsumerStatefulWidget {
  const QRCodeScanner({required this.onScan, super.key});

  final void Function(Barcode) onScan;

  @override
  ConsumerState<QRCodeScanner> createState() => _QRCodeScannerState();
}

class _QRCodeScannerState extends ConsumerState<QRCodeScanner> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? savedData;
  late QRViewController controller;

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller.pauseCamera();
    } else if (Platform.isIOS) {
      controller.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(
        height: 300,
        width: 300,

        child: QRView(
          key: qrKey,
          onQRViewCreated: _onQRViewCreated,
        ),
      ),
      if (savedData != null) ...[
        const SizedBox(height: 16),
        Text(savedData!.code ?? "Keine Daten"),
      ],
    ],
  );

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      if (savedData?.code != scanData.code) {
        setState(() {
          savedData = scanData;
        });
        widget.onScan(scanData);
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
