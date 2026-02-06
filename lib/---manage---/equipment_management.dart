import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '/services/api_services.dart';

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
        return Icons.fire_extinguisher;
      case 1:
        return Icons.sports_baseball;
      case 2:
        return Icons.local_fire_department;
      case 3:
        return Icons.warning_amber;
      case 4:
        return Icons.grain;
      case 6:
        return CupertinoIcons.drop_fill;
      case 7:
        return CupertinoIcons.lightbulb;
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
        return Colors.yellow;
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
