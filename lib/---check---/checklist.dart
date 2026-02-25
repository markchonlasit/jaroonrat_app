import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '/services/api_services.dart';
import '/---check---/qr_scan_page.dart';

import '/---check---/fire.dart' as fire;
import '/---check---/ball.dart';
import '/---check---/fhc.dart';
import '/---check---/alarm.dart';
import '/---check---/sand.dart';
import '/---check---/eyewash.dart';
import '/---check---/light.dart';

class ChecklistPage extends StatelessWidget {
  const ChecklistPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      /// ================= APP BAR =================
      appBar: AppBar(
        backgroundColor: const Color(0xFF0047AB),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'หน้าหลัก',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      /// ================= BODY =================
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          children: [
            const SizedBox(height: 10),

            /// 🔥 ปุ่มสแกน QR (อยู่บนสุด)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0047AB),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const QrScanPage(),
                    ),
                  );
                },
                icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
                label: const Text(
                  "สแกน QR เพื่อเข้าถึงอุปกรณ์",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),

            const SizedBox(height: 25),

            /// 🔹 โหลดข้อมูลจาก API
            Expanded(
              child: FutureBuilder<List<dynamic>>(
                future: ApiService.getCategory(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return const Center(
                      child: Text('เกิดข้อผิดพลาดในการโหลดข้อมูล'),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('ไม่พบข้อมูลอุปกรณ์'));
                  }

                  final categories = snapshot.data!;
                  final total = categories.length;

                  return Column(
                    children: [
                      _HeaderCard(total: total),
                      const SizedBox(height: 25),

                      Expanded(
                        child: ListView.builder(
                          itemCount: categories.length,
                          itemBuilder: (context, index) {
                            final item = categories[index];
                            final int id = item['id'];
                            final String name = item['name'];

                            return InkWell(
                              onTap: () => _navigateToCategory(context, id),
                              child: _EquipmentItem(
                                icon: _getIconByCategory(id),
                                title: name,
                                borderColor: _getColorByCategory(id),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ================= NAVIGATION =================
  void _navigateToCategory(BuildContext context, int id) {
    final Map<int, Widget> pages = {
      0: const fire.FirePage(),
      1: const BallPage(),
      2: const FhcPage(),
      3: const AlarmPage(),
      4: const SandPage(),
      6: const EyewashPage(),
      7: const LightPage(),
    };

    if (pages.containsKey(id)) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => pages[id]!),
      );
    }
  }

  /// ================= ICON =================
  IconData _getIconByCategory(int id) {
    switch (id) {
      case 0:
        return Icons.fire_extinguisher;
      case 1:
        return Icons.sports_baseball;
      case 2:
        return Icons.fire_hydrant_alt;
      case 3:
        return Icons.warning_amber;
      case 4:
        return Icons.grain;
      case 6:
        return Icons.opacity;
      case 7:
        return Icons.flash_on;
      default:
        return Icons.inventory_2;
    }
  }

  /// ================= COLOR =================
  Color _getColorByCategory(int id) {
    switch (id) {
      case 0:
        return Colors.red;
      case 1:
        return const Color.fromARGB(255, 5, 47, 233);
      case 2:
        return Colors.deepOrangeAccent;
      case 3:
        return Colors.orange;
      case 4:
        return Colors.brown;
      case 6:
        return Colors.blue;
      case 7:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}

/// ================= HEADER =================
class _HeaderCard extends StatelessWidget {
  final int total;

  const _HeaderCard({required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black),
      ),
      child: Row(
        children: [
          const Icon(
            CupertinoIcons.checkmark_shield,
            color: Color(0xFF0047AB),
            size: 36,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'การตรวจสภาพของอุปกรณ์',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue),
            ),
            child: Row(
              children: [
                const Icon(Icons.sync, size: 16, color: Colors.blue),
                const SizedBox(width: 6),
                Text(
                  '$total รายการ',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// ================= ITEM =================
class _EquipmentItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color borderColor;

  const _EquipmentItem({
    required this.icon,
    required this.title,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      height: 100,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: Row(
        children: [
          Icon(icon, size: 48, color: borderColor),
          const SizedBox(width: 18),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}