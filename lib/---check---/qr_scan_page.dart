import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '/---Inspect---/inspectfire.dart';
import '/---Inspect---/inspectball.dart';
import '/---Inspect---/inspectfhc.dart';
import '/---Inspect---/inspectalarm.dart';
import '/---Inspect---/inspectsand.dart';
import '/---Inspect---/inspecteyewash.dart';
import '/---Inspect---/inspectlight.dart';

class QrScanPage extends StatefulWidget {
  const QrScanPage({super.key});

  @override
  State<QrScanPage> createState() => _QrScanPageState();
}

class _QrScanPageState extends State<QrScanPage> {
  final MobileScannerController controller = MobileScannerController();
  bool isScanned = false;

  void handleQr(String code) {
    if (isScanned) return;
    isScanned = true;

    try {
      final parts = code.split('|');

      if (parts.length < 2) {
        _showError("QR ไม่ถูกต้อง");
        isScanned = false;
        return;
      }

      final int type = int.parse(parts[0]);
      final int assetId = int.parse(parts[1]);
      final String assetName =
          parts.length > 2 ? parts[2] : "Device";

      Widget page;

      switch (type) {
        case 0:
          page = InspectFirePage(
              assetId: assetId, assetName: assetName);
          break;
        case 1:
          page = InspectBallPage(
              assetId: assetId, assetName: assetName);
          break;
        case 2:
          page = InspectfhcPage(
              assetId: assetId, assetName: assetName);
          break;
        case 3:
          page = InspectAlarmPage(
              assetId: assetId, assetName: assetName);
          break;
        case 4:
          page = InspectSandPage(
              assetId: assetId, assetName: assetName);
          break;
        case 6:
          page = InspectEyewashPage(
              assetId: assetId, assetName: assetName);
          break;
        case 7:
          page = InspectLightPage(
              assetId: assetId, assetName: assetName);
          break;
        default:
          _showError("ไม่พบประเภทอุปกรณ์");
          isScanned = false;
          return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => page),
      ).then((_) {
        isScanned = false;
      });

    } catch (e) {
      _showError("QR ไม่ถูกต้อง");
      isScanned = false;
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("สแกน QR"),
        backgroundColor: Colors.red,
      ),
      body: MobileScanner(
        controller: controller,
        onDetect: (capture) {
          final barcode = capture.barcodes.first;
          final String? code = barcode.rawValue;

          if (code != null) {
            handleQr(code);
          }
        },
      ),
    );
  }
}