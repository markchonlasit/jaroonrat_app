import 'package:flutter/material.dart';
import '/services/api_services.dart';
import 'equipment_qrcode.dart';
// อยู่โฟลเดอร์เดียวกัน
import 'equipment_list.dart';

class EquipmentManagementPage extends StatelessWidget {
  const EquipmentManagementPage({super.key});

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
        
        child: FutureBuilder<List<dynamic>>(
          future: ApiService.getCategory(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return const Center(child: Text('เกิดข้อผิดพลาดในการโหลดข้อมูล'));
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('ไม่พบข้อมูลอุปกรณ์'));
            }

            final List categories = snapshot.data!;

            /// ✅ ใช้ length เท่านั้น (จำนวนประเภทอุปกรณ์)
            final int total = categories.length;

            return Column(
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
                _HeaderCard(total: total),
                const SizedBox(height: 30),

                /// 🔹 LIST CATEGORY
                Expanded(
                  child: ListView.builder(
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final item = categories[index];

                      // ✅ ตรงกับ JSON ที่คุณส่งมา
                      final int categoryId = item['id'];
                      final String categoryName = item['name'];

                      return _EquipmentItem(
                        icon: _getIconByCategory(categoryId),
                        title: categoryName,
                        borderColor: _getColorByCategory(categoryId),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AssetListPage(
                                categoryId: categoryId,
                                categoryName: categoryName,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
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
        return Icons.fire_extinguisher; // ถังดับเพลิง
      case 1:
        return Icons.sports_baseball; // ลูกบอลดับเพลิง
      case 2:
        return Icons.fire_hydrant_alt; // ตู้น้ำดับเพลิง
      case 3:
        return Icons.warning_amber; // สัญญาณแจ้งเหตุ
      case 4:
        return Icons.grain; // ทรายซับสารเคมี
      case 6:
        return Icons.opacity; // 👈 อ่างล้างตา (ชัดกว่า drop)
      case 7:
        return Icons.lightbulb; // ไฟฉุกเฉิน
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
        return const Color(0xFF0047AB);
      case 2:
        return Colors.deepOrangeAccent;
      case 3:
        return Colors.amber;
      case 4:
        return Colors.brown;
      case 6:
        return Colors.blue; // อ่างล้างตา
      case 7:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}

/// =========================
/// 🔹 ITEM CARD
/// =========================
class _EquipmentItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color borderColor;
  final VoidCallback onTap;

  const _EquipmentItem({
    required this.icon,
    required this.title,
    required this.borderColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
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
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
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
          const Icon(Icons.assignment_outlined, color: Colors.blue, size: 36),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'การจัดการข้อมูลของอุปกรณ์',
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
