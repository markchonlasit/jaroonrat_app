import 'package:flutter/material.dart';
import '/services/api_services.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<dynamic> assets = [];
  bool loading = true;

  // --- Search & Filter States ---
  String keyword = '';
  String? selectedType;
  int? selectedActive;
  DateTime? selectedDate;
  bool showFilter = false;
  String selectedStatusCategory = "ทั้งหมด"; // สำหรับ Filter จาก Status Box

  @override
  void initState() {
    super.initState();
    fetchAssets();
  }

  Future<void> fetchAssets() async {
    try {
      final response = await ApiService.getAssetexpdate(0);
      setState(() {
        assets = response['asset'] ?? [];
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
    }
  }

  // แปลงวันที่ "31/12/2567" เป็น DateTime
  DateTime parseThaiDate(String dateStr) {
    try {
      final parts = dateStr.split(" ")[0].split("/");
      int day = int.parse(parts[0]);
      int month = int.parse(parts[1]);
      int year = int.parse(parts[2]) - 543;
      return DateTime(year, month, day);
    } catch (e) {
      return DateTime(1900);
    }
  }

  // คำนวณสถานะจากวันหมดอายุ
  String getStatus(String? expdate) {
    if (expdate == null || expdate.isEmpty) return "ไม่มีวันหมดอายุ";
    DateTime exp = parseThaiDate(expdate);
    DateTime now = DateTime.now();
    if (exp.isBefore(now)) return "หมดอายุ";
    final diff = exp.difference(now).inDays;
    if (diff <= 365) return "ใกล้หมดอายุ";
    return "ใช้งานได้";
  }

  InputDecoration _dropdownDecoration() {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  /// =========================
  /// 🔹 นับจำนวนสถานะ
  /// =========================
  int countStatus(String status) {
    return assets.where((item) => getStatus(item['expdate']) == status).length;
  }

  @override
  Widget build(BuildContext context) {
    // 🔥 ส่วนการกรองข้อมูลหลัก
    final filtered = assets.where((item) {
      final name = item['name']?.toString().toLowerCase() ?? '';
      final location = item['location']?.toString().toLowerCase() ?? '';
      final branch = item['branch']?.toString().toLowerCase() ?? '';
      final type = item['type']?.toString().toLowerCase() ?? '';
      final active = item['active'];
      final expdateStr = item['expdate']?.toString() ?? '';
      final currentStatus = getStatus(expdateStr);

      final key = keyword.toLowerCase();

      // 1. ค้นหาจากคำค้น
      final matchKeyword =
          keyword.isEmpty ||
          name.contains(key) ||
          location.contains(key) ||
          branch.contains(key) ||
          type.contains(key);

      // 2. กรองตามประเภท
      final matchType =
          selectedType == null ||
          selectedType == "ทั้งหมด" ||
          type == selectedType?.toLowerCase();

      // 3. กรองตามสถานะ Active
      final matchActive =
          selectedActive == null ||
          selectedActive == -1 ||
          active == selectedActive;

      // 4. กรองจาก Status Box (ใกล้หมด/ใช้งานได้/หมดอายุ)
      final matchStatusCat =
          selectedStatusCategory == "ทั้งหมด" ||
          currentStatus == selectedStatusCategory;

      // 5. กรองตามวันที่เลือก
      bool matchDate = true;
      if (selectedDate != null) {
        if (expdateStr.isEmpty) {
          matchDate = false;
        } else {
          final d = parseThaiDate(expdateStr);
          matchDate =
              d.year == selectedDate!.year &&
              d.month == selectedDate!.month &&
              d.day == selectedDate!.day;
        }
      }

      return matchKeyword &&
          matchType &&
          matchActive &&
          matchDate &&
          matchStatusCat;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0047AB),
        elevation: 0,
        title: const Text(
          'หน้าหลัก',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                /// =========================
                /// 🔔 HEADER แบบในรูป
                /// =========================
                Container(
                  width: double.infinity,
                  color: Colors.white, // พื้นหลังเทาอ่อน
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.orange, width: 2),
                        color: Colors.white,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(
                            Icons.notifications_none,
                            color: Colors.orange,
                            size: 28,
                          ),
                          SizedBox(width: 10),
                          Text(
                            "ระบบแจ้งเตือนวันหมดอายุของถังดับเพลิง",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                _summaryCard(filtered.length),
                const SizedBox(height: 10),

                /// 🔹 Summary
                // ค้นหาส่วนใน build() -> Column -> Padding ที่มี Row ของ Status Box
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      _statusBoxWithIcon(
                        "ใกล้หมดอายุ",
                        countStatus(
                          "ใกล้หมดอายุ",
                        ), // แก้ให้ตรงกับ return ของ getStatus
                        Colors.orange,
                        Icons.warning_amber,
                        "ใกล้หมดอายุ",
                      ),
                      const SizedBox(width: 8),
                      _statusBoxWithIcon(
                        "ใช้งานได้",
                        countStatus("ใช้งานได้"),
                        Colors.green,
                        Icons.check_circle,
                        "ใช้งานได้",
                      ),
                      const SizedBox(width: 8),
                      _statusBoxWithIcon(
                        "หมดอายุ",
                        countStatus("หมดอายุ"),
                        Colors.red,
                        Icons.error,
                        "หมดอายุ",
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),
                _searchBar(assets),
                const SizedBox(height: 10),
                Expanded(
                  child: filtered.isEmpty
                      ? const Center(child: Text("ไม่พบรายการที่ค้นหา", style: TextStyle(fontSize: 16)))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) =>
                              _assetCard(filtered[index]),
                        ),
                ),
              ],
            ),
    );
  }

  /// =========================
  /// SUMMARY CARD (แบบในรูป)
  /// =========================
  Widget _summaryCard(int count) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white, // พื้นเทาอ่อน
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.black),
        ),
        child: Row(
          children: [
            /// 🔹 ฝั่งซ้าย (ข้อความ)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "รายการถังดับเพลิง",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "จำนวนทั้งหมด $count",
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ],
              ),
            ),

            /// 🔹 ปุ่มด้านขวา (แดง)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.red, width: 2),
                color: Colors.white,
              ),
              child: Row(
                children: const [
                  Icon(Icons.fire_extinguisher, color: Colors.red, size: 22),
                  SizedBox(width: 8),
                  Text(
                    "ถังดับเพลิง",
                    style: TextStyle(
                      color: Colors.red,
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
  /// SEARCH BAR & FILTER SECTION
  /// =========================
  Widget _searchBar(List assets) {
    // ดึงรายการประเภทอุปกรณ์ที่มีอยู่ในข้อมูลมาสร้าง Dropdown
    final types = assets
        .map((e) => e['type']?.toString())
        .where((e) => e != null && e.isNotEmpty)
        .toSet()
        .toList();

    types.insert(0, "ทั้งหมด");

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 🔍 ช่องค้นหา + ปุ่มตัวกรอง
          Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: (v) => setState(() => keyword = v),
                  decoration: InputDecoration(
                    hintText: 'ค้นหา',
                    prefixIcon: const Icon(Icons.search),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              /// 🔘 ปุ่มตัวกรอง
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    showFilter = !showFilter;
                  });
                },
                icon: Icon(
                  showFilter ? Icons.close : Icons.filter_list,
                  size: 18,
                ),
                label: Text(
                  showFilter ? "ปิด" : "ตัวกรอง",
                  style: const TextStyle(fontSize: 14),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0047AB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),

          /// =========================
          /// 🔽 เมนูตัวกรอง (พับได้)
          /// =========================
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 300),
            crossFadeState: showFilter
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: Container(
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade500),
              ),
              child: Column(
                children: [
                  /// ประเภท + สถานะการใช้งาน
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue:
                              selectedType, // เปลี่ยนจาก initialValue เป็น value
                          hint: const Text("เลือกประเภท"),
                          items: types
                              .map(
                                (type) => DropdownMenuItem(
                                  value: type,
                                  child: Text(type!),
                                ),
                              )
                              .toList(),
                          onChanged: (v) => setState(() => selectedType = v),
                          decoration: _dropdownDecoration(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          initialValue: selectedActive,
                          hint: const Text("เลือกสถานะ"),
                          items: const [
                            DropdownMenuItem(value: -1, child: Text("ทั้งหมด")),
                            DropdownMenuItem(value: 1, child: Text("ใช้งาน")),
                            DropdownMenuItem(
                              value: 0,
                              child: Text("ไม่ได้ใช้งาน"),
                            ),
                          ],
                          onChanged: (v) => setState(() => selectedActive = v),
                          decoration: _dropdownDecoration(),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  /// 📅 เลือกวันหมดอายุ (ในหน้า Notification มักจะเปิดให้เลือกเสมอ)
                  GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        locale: const Locale('th', 'TH'),
                        initialDate: selectedDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(3100),
                      );

                      if (picked != null) {
                        setState(() {
                          selectedDate = picked;
                        });
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_month,
                            color: Colors.grey,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            selectedDate == null
                                ? "เลือกวันหมดอายุ"
                                : "${selectedDate!.day.toString().padLeft(2, '0')}/"
                                      "${selectedDate!.month.toString().padLeft(2, '0')}/"
                                      "${selectedDate!.year + 543}",
                            style: const TextStyle(fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// ปุ่มค้นหา + ล้าง
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              showFilter = false; // ปิดหลังค้นหา
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0047AB),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text("ปิดตัวกรอง"),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              keyword = '';
                              selectedType = "ทั้งหมด";
                              selectedActive = -1;
                              selectedDate = null;
                              selectedStatusCategory = "ทั้งหมด";
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text("ล้างตัวกรอง"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            secondChild: const SizedBox(),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  /// 4. Card แสดงรายการ
  /// =========================
  /// ASSET CARD (ฉบับปรับปรุงตาม UI AssetListPage)
  /// =========================
  Widget _assetCard(dynamic item) {
    // คำนวณสถานะวันหมดอายุเพื่อใช้กำหนดสี Tag
    final status = getStatus(item['expdate']);
    final statusColor = status == "หมดอายุ"
        ? Colors.red
        : status == "ใกล้หมดอายุ"
        ? Colors.orange
        : Colors.green;

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
          /// 🔹 ส่วนที่ 1: Icon + สาขา (Branch)
          Column(
            children: [
              const Icon(
                Icons
                    .fire_extinguisher, // ในหน้าแจ้งเตือนส่วนใหญ่จะเป็นถังดับเพลิง
                size: 46,
                color: Colors.red,
              ),
              const SizedBox(height: 8),
              _chip('${item['branch']}', color: Colors.blue.shade100),
            ],
          ),

          const SizedBox(width: 16),

          /// 🔹 ส่วนที่ 2: ข้อมูลอุปกรณ์
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ชื่ออุปกรณ์
                _chip(
                  '${item['name']}',
                  color: const Color.fromARGB(255, 230, 230, 230),
                ),
                const SizedBox(height: 8),

                // ประเภทอุปกรณ์ (แสดง Chip สีตามประเภทเหมือนหน้า AssetListPage)
                if (item['type'] != null) ...[
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
                      return _chip('ประเภท ${item['type']}', color: chipColor);
                    },
                  ),
                  const SizedBox(height: 8),
                ],

                // สถานที่
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 18, color: Colors.red),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        item['location'] ?? '-',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // วันหมดอายุ
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 18, color: statusColor),
                    const SizedBox(width: 4),
                    Text(
                      (item['expdate'] != null &&
                              item['expdate'].toString().isNotEmpty)
                          ? "วันหมดอายุ ${item['expdate'].toString().split(' ')[0]}"
                          : "วันหมดอายุ -",
                      style: TextStyle(
                        fontSize: 14,
                        color: statusColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // สถานะการใช้งาน (Active/Inactive)
                Row(
                  children: [
                    Icon(
                      item['active'] == 1 ? Icons.check_circle : Icons.cancel,
                      color: item['active'] == 1 ? Colors.green : Colors.red,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      item['active'] == 1 ? 'ใช้งาน' : 'ไม่ได้ใช้งาน',
                      style: TextStyle(
                        fontSize: 13,
                        color: item['active'] == 1 ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          /// 🔹 ส่วนที่ 3: ป้ายสถานะวันหมดอายุ (ขวาสุด)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              status,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
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
      child: Text(text, style: const TextStyle(fontSize: 15)),
    );
  }

  Widget _statusBoxWithIcon(
    String title,
    int count,
    Color color,
    IconData icon,
    String statusKey,
  ) {
    // เช็คว่าสถานะนี้กำลังถูกเลือกอยู่หรือไม่
    bool isSelected = selectedStatusCategory == statusKey;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            // ถ้ากดตัวเดิมให้ล้างค่า (เป็น "ทั้งหมด") ถ้ากดตัวใหม่ให้เลือกตัวนั้น
            selectedStatusCategory = isSelected ? "ทั้งหมด" : statusKey;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20), // ปรับความโค้งให้มนขึ้น
            color: isSelected ? color : Colors.white, // ถ้าเลือกให้ใช้สีหลักเป็นพื้นหลัง
            border: Border.all(
              color: color ,
              width: 1.5,
            ),
            boxShadow: [
          
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // วงกลมไอคอน
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isSelected 
                      // ignore: deprecated_member_use
                      ? Colors.white.withOpacity(0.2) 
                      // ignore: deprecated_member_use
                      : color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon, 
                  color: isSelected ? Colors.white : color, 
                  size: 24
                ),
              ),
              const SizedBox(height: 12),
              // ชื่อสถานะ
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? Colors.white : Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 4),
              // ตัวเลขจำนวน
              Text(
                '$count',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}