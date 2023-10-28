import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:ticket_scanner/provider/qr_code_information_provider.dart';

class QRCodeScanner extends ConsumerStatefulWidget {
  const QRCodeScanner({super.key});

  @override
  ConsumerState<QRCodeScanner> createState() => _QRCodeScannerState();
}

class _QRCodeScannerState extends ConsumerState<QRCodeScanner> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) => QRView(
    key: qrKey,
    onQRViewCreated: _onQRViewCreated,
  );

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      ref.read(qrCodeInformationProvider.notifier).state = scanData;
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
