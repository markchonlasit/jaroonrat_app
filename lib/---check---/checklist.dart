import 'package:flutter/material.dart';
import '/services/api_services.dart';
import 'package:flutter/cupertino.dart';
import '/---check---/fire.dart' as fire;
import '/---check---/ball.dart'; 
import '/---check---/fhc.dart';
import '/---check---/alarm.dart';
import '/---check---/sand.dart';
import '/---check---/eyewash.dart';
import '/---check---/light.dart';

class checklistPage extends StatelessWidget {
  const checklistPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      /// =========================
      /// 🔹 APP BAR
      /// =========================
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

      /// =========================
      /// 🔹 BODY
      /// =========================
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 30),

            /// 🔹 ดึงข้อมูลจาก API
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
                      const SizedBox(height: 30),

                      Expanded(
                        child: ListView.builder(
                          itemCount: categories.length,
                          itemBuilder: (context, index) {
                            final item = categories[index];
                            final int id = item['id'];

                            return InkWell(
                              onTap: () {
                                if (id == 0) {
                                  // 🔥 ถังดับเพลิง
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const fire.FirePage(),
                                    ),
                                  );
                                } else if (id == 1) {
                                  // 🧯 ลูกบอลดับเพลิง
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const BallPage(),
                                    ),
                                  );
                                } else if (id == 2) {
                                  // 🚒 FHC
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const FhcPage(),
                                    ),
                                  );
                                }
                                else if (id == 3) {
                                  // 🚨 สัญญาณเตือนภัย
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const AlarmPage(),
                                    ),
                                  );
                                }
                                else if (id == 4) {
                                  // 🏖️ ทรายดับเพลิง
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const SandPage(),
                                    ),
                                  );
                                }
                                else if (id == 6) {
                                  // 🚰 ที่ล้างตา
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const EyewashPage(),
                                    ),
                                  );
                                }
                                else if (id == 7) {
                                  // 💡 ไฟฉุกเฉิน
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const LightPage(),
                                    ),
                                  );
                                }
                              },
                              child: _EquipmentItem(
                                icon: _getIconByCategory(id),
                                title: item['name'],
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

  /// =========================
  /// 🔹 ICON ตามประเภทอุปกรณ์
  /// =========================
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

  /// =========================
  /// 🔹 สีตามประเภทอุปกรณ์
  /// =========================
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

/// =========================
/// 🔹 HEADER CARD
/// =========================
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

/// =========================
/// 🔹 EQUIPMENT ITEM (เดิม)
/// =========================
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 48, color: borderColor),
          const SizedBox(width: 18),
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              title,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
