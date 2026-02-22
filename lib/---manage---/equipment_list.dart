import 'package:flutter/material.dart';
import '/services/api_services.dart';
import 'package:flutter/cupertino.dart';
import 'equipment_view.dart';
import 'equipment_edit.dart';

class AssetListPage extends StatefulWidget {
  final int categoryId;
  final String categoryName;

  const AssetListPage({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<AssetListPage> createState() => _AssetListPageState();
}

class _AssetListPageState extends State<AssetListPage> {
  String keyword = '';
  late Future<Map<String, dynamic>> _assetFuture;
  @override
  void initState() {
    super.initState();
    _assetFuture = ApiService.getAssetList(widget.categoryId);
  }

  String? selectedType;
  int? selectedActive;
  DateTime? selectedDate;

  InputDecoration _dropdownDecoration() {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      /// =========================
      /// APP BAR
      /// =========================
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

      /// =========================
      /// BODY
      /// =========================
      body: FutureBuilder<Map<String, dynamic>>(
        future: _assetFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('เกิดข้อผิดพลาดในการโหลดข้อมูล'));
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('ไม่พบข้อมูล'));
          }

          final data = snapshot.data!;
          final List assets = data['asset'] ?? [];
          final bool fireAsset = data['fireasset'] ?? false;

          final filtered = assets.where((e) {
            final name = e['name']?.toString().toLowerCase() ?? '';
            final location = e['location']?.toString().toLowerCase() ?? '';
            final type = e['type']?.toString();
            final active = e['active'];
            final expdateStr = e['expdate']?.toString();

            final matchKeyword =
                keyword.isEmpty ||
                name.contains(keyword.toLowerCase()) ||
                location.contains(keyword.toLowerCase());

            final matchType = selectedType == null || type == selectedType;

            final matchActive =
                selectedActive == null || active == selectedActive;

            bool matchDate = true;

            if (selectedDate != null && expdateStr != null) {
              try {
                final parts = expdateStr.split(' ')[0].split('/');
                final date = DateTime(
                  int.parse(parts[2]),
                  int.parse(parts[1]),
                  int.parse(parts[0]),
                );

                matchDate =
                    date.year == selectedDate!.year &&
                    date.month == selectedDate!.month &&
                    date.day == selectedDate!.day;
              } catch (_) {
                matchDate = false;
              }
            }

            return matchKeyword && matchType && matchActive && matchDate;
          }).toList();

          return Column(
            children: [
              /// =========================
              /// SUMMARY
              /// =========================
              _summaryCard(filtered.length),

              /// =========================
              /// SEARCH / FILTER
              /// =========================
              _searchBar(assets),

              /// =========================
              /// LIST
              /// =========================
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final item = filtered[index];
                    return _assetCard(item, fireAsset);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// =========================
  /// SUMMARY CARD
  /// =========================
  Widget _summaryCard(int total) {
    final icon = _getIconByCategory(widget.categoryId);
    final color = _getColorByCategory(widget.categoryId);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            /// 🔹 ICON ตามประเภทอุปกรณ์

            /// 🔹 TEXT SUMMARY
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'รายการ${widget.categoryName}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'จำนวนทั้งหมด $total',
                    style: TextStyle(fontSize: 14, color: Colors.black),
                  ),
                ],
              ),
            ),

            /// 🔹 CATEGORY TAG (pill with icon + label)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: color, width: 2),
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
              ),
              child: Row(
                children: [
                  Icon(icon, size: 30, color: color),
                  const SizedBox(width: 12),
                  Text(
                    widget.categoryName,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// =========================
  /// SEARCH BAR
  /// =========================
  Widget _searchBar(List assets) {
    final types = assets
        .map((e) => e['type']?.toString())
        .where((e) => e != null && e.isNotEmpty)
        .toSet()
        .toList();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          /// 🔎 ค้นหา name + location
          TextField(
            onChanged: (v) => setState(() => keyword = v),
            decoration: InputDecoration(
              hintText: 'ค้นหา ชื่อ / สถานที่',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          const SizedBox(height: 12),

          /// 📦 ประเภท + ✅ สถานะ
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: selectedType,
                  hint: const Text("เลือกประเภท"),
                  items: types
                      .map(
                        (type) =>
                            DropdownMenuItem(value: type, child: Text(type!)),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => selectedType = v),
                  decoration: _dropdownDecoration(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<int>(
                  value: selectedActive,
                  hint: const Text("เลือกสถานะ"),
                  items: const [
                    DropdownMenuItem(value: 1, child: Text("ใช้งาน")),
                    DropdownMenuItem(value: 0, child: Text("ไม่ได้ใช้งาน")),
                  ],
                  onChanged: (v) => setState(() => selectedActive = v),
                  decoration: _dropdownDecoration(),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: selectedDate ?? DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(3100),
              );

              if (picked != null) {
                setState(() => selectedDate = picked);
              }
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                selectedDate == null
                    ? "เลือกวันหมดอายุ"
                    : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// =========================
  /// ASSET CARD (ไม่ overflow)
  /// =========================
  Widget _assetCard(dynamic item, bool fireAsset) {
    // ฟอร์แมตวันที่ ตัดเอาเฉพาะส่วนแรกก่อนช่องว่าง

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 🔹 ส่วนที่ 1: [Icon] + JRPE + active/inactive
          Column(
            children: [
              Icon(
                _getIconByCategory(widget.categoryId),
                size: 46,
                color: _getColorByCategory(widget.categoryId),
              ),
              const SizedBox(height: 8),
              _chip('${item['branch']}', color: Colors.blue.shade100), // JRPE
              const SizedBox(height: 4),
              // _chip(
              //   item['active'] == 1 ? "active" : "inactive",
              //   color: item['active'] == 1
              //       ? Colors.green.shade300
              //       : Colors.grey.shade400, // เปลี่ยนเป็นสีเทาเมื่อ inactive
              // ),
            ],
          ),

          const SizedBox(width: 16),

          /// 🔹 ส่วนที่ 2: ข้อมูลอุปกรณ์ (ชื่อ, ประเภท, สถานที่, วันที่)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ชื่ออุปกรณ์
                _chip(
                  '${item['name']}',
                  color: const Color.fromARGB(255, 212, 211, 211),
                ),
                const SizedBox(height: 6),

                // ประเภทอุปกรณ์ (แสดงเฉพาะเมื่อเป็น fireAsset)
                if (fireAsset) ...[
                  Builder(
                    builder: (context) {
                      final type = item['type']?.toString().toLowerCase();

                      final Map<String, Color> typeColors = {
                        'dry': Colors.blue.shade200,
                        'เขียว': Colors.green.shade200,
                        'แดง': Colors.red.shade200,
                        'เงิน': Colors.grey.shade400,
                      };

                      final chipColor =
                          typeColors[type] ?? Colors.grey.shade200;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _chip('ประเภท ${item['type']}', color: chipColor),
                          const SizedBox(height: 8),
                        ],
                      );
                    },
                  ),
                ],

                // สถานที่
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 20, color: Colors.red),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        item['location'] ?? '-',
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                if (item['expdate'] != null) ...[
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 20,
                        color: Colors.orange,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          "วันหมดอายุ ${item['expdate'].toString().split(' ')[0]}",
                          style: const TextStyle(fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                ],
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      item['active'] == 1 ? Icons.check_circle : Icons.cancel,
                      color: item['active'] == 1 ? Colors.green : Colors.red,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      item['active'] == 1 ? 'ใช้งาน' : 'ไม่ได้ใช้งาน',
                      style: TextStyle(
                        color: item['active'] == 1 ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),

                // วันที่หมดอายุ (เพิ่มเข้ามาตาม Layout ใหม่)
              ],
            ),
          ),

          const SizedBox(width: 8),

          /// 🔹 ส่วนที่ 3: ACTION BUTTONS (รายละเอียด, แก้ไข)
          Column(
            children: [
              // ชื่ออุปกรณ์
              const SizedBox(height: 9),
              _actionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EquipmentViewPage(assetId: item['id']),
                    ),
                  );
                },
                icon: Icons.visibility,
                label: 'รายละเอียด',
                color: Colors.blue,
              ),
              const SizedBox(height: 3),
              _actionButton(
                onPressed: () async {
                  final updated = await showEditAssetDialog(
                    context,
                    item['id'],
                  );
                  if (updated == true) setState(() {});
                },
                icon: Icons.edit,
                label: 'แก้ไข',
                color: Colors.amber,
                textColor: Colors.black,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Helper สำหรับสร้างปุ่ม Action ให้โค้ดสะอาดขึ้น
  Widget _actionButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required Color color,
    Color textColor = Colors.white,
  }) {
    return SizedBox(
      width: 85,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: textColor,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String text, {Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color ?? Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: const TextStyle(fontSize: 15)),
    );
  }
}

IconData _getIconByCategory(int id) {
  switch (id) {
    case 0:
      return Icons.fire_extinguisher; // ถังดับเพลิง
    case 1:
      return Icons.sports_baseball; // ลูกบอลดับเพลิง
    case 2:
      return Icons.local_fire_department; // ตู้น้ำดับเพลิง
    case 3:
      return Icons.warning_amber; // สัญญาณแจ้งเหตุ
    case 4:
      return Icons.grain; // ทรายซับสารเคมี
    case 6:
      return CupertinoIcons.drop_fill; // 👈 อ่างล้างตา (ชัดกว่า drop)
    case 7:
      return Icons.lightbulb; // ไฟฉุกเฉิน
    default:
      return Icons.inventory_2;
  }
}

Color _getColorByCategory(int id) {
  switch (id) {
    case 0:
      return Colors.red;
    case 1:
      return Colors.orange;
    case 2:
      return Colors.deepOrange;
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
