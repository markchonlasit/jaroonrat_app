import 'package:flutter/material.dart';
import '/services/api_services.dart';

class EquipmentViewPage extends StatelessWidget {
  final int assetId;

  const EquipmentViewPage({super.key, required this.assetId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0047AB),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'การจัดการข้อมูลของอุปกรณ์',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: ApiService.getAsset(assetId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _titleBar('รายละเอียดอุปกรณ์'),

                infoField(
                  icon: Icons.badge,
                  label: 'ชื่ออุปกรณ์',
                  value: data['name'] ?? '-',
                ),

                infoField(
                  icon: Icons.category,
                  label: 'ชนิดอุปกรณ์',
                  value: data['categoryname'] ?? '-',
                ),

                if (data['fireasset'] == true &&
                    data['firetype'] != null &&
                    data['firetype'].toString().isNotEmpty)
                  infoField(
                    icon: Icons.build,
                    label: 'ประเภทอุปกรณ์',
                    value: data['firetype'],
                  ),

                infoField(
                  icon: Icons.apartment,
                  label: 'สาขา',
                  value: data['branch'] ?? '-',
                ),

                infoField(
                  icon: Icons.location_on,
                  label: 'ตำแหน่ง',
                  value: data['location'] ?? '-',
                ),

                infoField(
                  icon: Icons.toggle_on,
                  label: 'สถานะ',
                  value: data['active'] == 1 ? 'active' : 'inactive',
                ),

                if (data['expdate'] != null && data['expdate'].toString().isNotEmpty)
                  infoField(
                    icon: Icons.schedule,
                    label: '',
                    value: data['expdate'],
                  ),

                const SizedBox(height: 20),
                _titleBar('การจัดการอุปกรณ์'),

                infoField(
                  icon: Icons.person,
                  label: 'ผู้สร้าง',
                  value: data['createby'] ?? '-',
                ),

                infoField(
                  icon: Icons.schedule,
                  label: 'เวลาที่สร้าง',
                  value: data['createdate'] ?? '-',
                ),

                infoField(
                  icon: Icons.person_outline,
                  label: 'ผู้แก้ไขล่าสุด',
                  value: data['lastupdate'] ?? '-',
                ),

                infoField(
                  icon: Icons.update,
                  label: 'เวลาแก้ไขล่าสุด',
                  value: data['lastdate'] ?? '-',
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// =========================
/// 🔹 TITLE BAR (แก้ตรงนี้)
/// =========================
Widget _titleBar(String text) {
  return Container(
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    decoration: BoxDecoration(
      color: const Color(0xFF0047AB),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min, // 👈 สำคัญ
      children: [
        const Icon(Icons.info_outline, color: Colors.white),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    ),
  );
}

Widget infoField({
  required IconData icon,
  required String label,
  required String value,
}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      color: Colors.grey.shade100,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.black),
    ),
    child: Row(
      children: [
        /// 🔹 ICON (กรอบฟ้า)
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: Colors.blue.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: Colors.blue),
        ),

        const SizedBox(width: 10),

        /// 🔹 LABEL
        Expanded(
          flex: 4,
          child: Text(
            '$label :',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),

        /// 🔹 VALUE (กล่องข้อมูล)
        Expanded(
          flex: 5,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.black),
            ),
            child: Text(
              value,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ),
      ],
    ),
  );
}
