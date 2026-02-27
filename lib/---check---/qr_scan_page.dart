import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import '/services/auth_service.dart';

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

  // ยิง API เพื่อรู้ type จาก assetId
  Future<void> openFromAssetId(int assetId) async {
    try {
      final res = await http.get(
        Uri.parse('https://api.jaroonrat.com/safetyaudit/api/asset/$assetId'),
        headers: {
          'Authorization': 'Bearer ${AuthService.token}',
        },
      );

      if (!mounted) return; // ⭐ กัน context พังหลัง await

      if (res.statusCode != 200) {
        _showError("ไม่พบอุปกรณ์");
        isScanned = false;
        return;
      }

      final data = jsonDecode(res.body);

      final int type = data['type'];
      final String assetName = data['name'] ?? "Device";

      Widget page;

      switch (type) {
        case 0:
          page = InspectFirePage(assetId: assetId, assetName: assetName);
          break;
        case 1:
          page = InspectBallPage(assetId: assetId, assetName: assetName);
          break;
        case 2:
          page = InspectfhcPage(assetId: assetId, assetName: assetName);
          break;
        case 3:
          page = InspectAlarmPage(assetId: assetId, assetName: assetName);
          break;
        case 4:
          page = InspectSandPage(assetId: assetId, assetName: assetName);
          break;
        case 6:
          page = InspectEyewashPage(assetId: assetId, assetName: assetName);
          break;
        case 7:
          page = InspectLightPage(assetId: assetId, assetName: assetName);
          break;
        default:
          _showError("ไม่พบประเภทอุปกรณ์");
          isScanned = false;
          return;
      }

      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => page),
      );

      if (!mounted) return;
      isScanned = false; // กลับมาหน้านี้แล้วสแกนใหม่ได้

    } catch (e) {
      if (!mounted) return;
      _showError("ไม่สามารถโหลดข้อมูลอุปกรณ์");
      isScanned = false;
    }
  }

  void handleQr(String code) {
    if (isScanned) return;
    isScanned = true;

    try {
      final int assetId = int.parse(code);
      openFromAssetId(assetId);
    } catch (_) {
      _showError("QR ไม่ถูกต้อง");
      isScanned = false;
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("สแกน QR"),
        backgroundColor: Colors.cyan,
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