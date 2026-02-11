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
        future: ApiService.getAssetList(widget.categoryId),
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
            return e['name'].toString().toLowerCase().contains(
              keyword.toLowerCase(),
            );
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
              _searchBar(),

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
            Icon(icon, size: 36, color: color),

            const SizedBox(width: 12),

            /// 🔹 TEXT SUMMARY
            Expanded(
              child: Text(
                'รายการ${widget.categoryName}ทั้งหมด\nจำนวนทั้งหมด $total',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            /// 🔹 CATEGORY TAG
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                border: Border.all(color: color),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                widget.categoryName,
                style: TextStyle(color: color, fontWeight: FontWeight.w500),
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
  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: (v) => setState(() => keyword = v),
              decoration: InputDecoration(
                hintText: 'ค้นหา',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          _squareIcon(Icons.build),
          const SizedBox(width: 8),
          _squareIcon(Icons.tune),
        ],
      ),
    );
  }

  Widget _squareIcon(IconData icon) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        border: Border.all(),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon),
    );
  }

  /// =========================
  /// ASSET CARD (ไม่ overflow)
  /// =========================
  Widget _assetCard(dynamic item, bool fireAsset) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            _getIconByCategory(widget.categoryId),
            size: 46,
            color: _getColorByCategory(widget.categoryId),
          ),
          const SizedBox(width: 12),

          /// =========================
          /// CONTENT
          /// =========================
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// 🔹 ชื่ออุปกรณ์ (บรรทัดที่ 1)
                _chip(
                  '${item['name']}',
                  color: const Color.fromARGB(255, 212, 211, 211),
                ),

                const SizedBox(height: 6),

                /// 🔹 ประเภทอุปกรณ์ (บรรทัดที่ 2)
                if (fireAsset)
                  _chip('ประเภท ${item['type']}', color: Colors.amber.shade200),

                const SizedBox(height: 8),

                /// 🔹 LOCATION
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.red),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        item['location'] ?? '-',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          /// =========================
          /// ACTION BUTTONS
          /// =========================
          Column(
            children: [
              /// 🔹 ดูรายละเอียด
              SizedBox(
                width: 90,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EquipmentViewPage(assetId: item['id']),
                      ),
                    );
                  },
                  icon: const Icon(Icons.visibility, size: 14),
                  label: const Text(
                    'รายละเอียด',
                    style: TextStyle(fontSize: 11),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 6,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 6),

              /// 🔹 แก้ไข (Popup)
              SizedBox(
                width: 90,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final updated = await showEditAssetDialog(
                      context,
                      item['id'], // Map<String, dynamic> ของ asset
                    );

                    if (updated == true) {
                      setState(() {
                        // reload list หรือ FutureBuilder
                      });
                    }
                  },

                  icon: const Icon(Icons.edit, size: 14),
                  label: const Text('แก้ไข', style: TextStyle(fontSize: 11)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 6,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
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
      child: Text(text, style: const TextStyle(fontSize: 12)),
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
