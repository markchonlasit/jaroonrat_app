import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '/services/auth_service.dart';
import '/---Inspect---/inspectfire.dart';
import '/---audit---/audit_fire_detail.dart';

class FirePage extends StatefulWidget {
  const FirePage({super.key,});
  final int categoryId = 0; // กำหนดเป็น 0 สำหรับหน้าถังดับเพลิง
  

  @override
  State<FirePage> createState() => _FirePageState();
}

class _FirePageState extends State<FirePage> {
  bool isLoading = true;
  String errorMessage = '';
  List<Map<String, dynamic>> fireList = [];

  // --- ตัวแปรสำหรับ SearchBar และ Filter ใหม่ ---
  String keyword = '';
  String? selectedType ;
  int? selectedActive = -1; // -1 = ทั้งหมด, 1 = ใช้งาน, 0 = ไม่ใช้งาน
  DateTime? selectedDate;
  bool showFilter = false;

  final String apiUrl = 'https://api.jaroonrat.com/safetyaudit/api/assetlist/0';

  @override
  void initState() {
    super.initState();
    fetchFire();
  }

  Future<void> fetchFire() async {
    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer ${AuthService.token}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          fireList = List<Map<String, dynamic>>.from(data['asset'] ?? []);
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'โหลดข้อมูลไม่สำเร็จ (${response.statusCode})';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ได้';
        isLoading = false;
      });
    }
  }

  // --- 📍 เพิ่มเมธอด _dropdownDecoration ตามที่คุณระบุ ---
  InputDecoration _dropdownDecoration() {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      filled: true,
      fillColor: Colors.grey.shade100,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.grey, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
    );
  }

  // --- 📍 เพิ่มเมธอด _searchBar ตามที่คุณระบุ (แทนที่อันเดิม) ---
  Widget _searchBar(List assets) {
    final types = assets
        .map((e) => e['type']?.toString())
        .where((e) => e != null && e.isNotEmpty)
        .toSet()
        .toList();

    if (!types.contains("ทั้งหมด")) {
      types.insert(0, "ทั้งหมด");
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 300),
            crossFadeState: showFilter ? CrossFadeState.showFirst : CrossFadeState.showSecond,
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
                  Row(
                    children: [
                      if (widget.categoryId == 0 || widget.categoryId == 1)
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: selectedType,
                            hint: const Text("เลือกประเภท"),
                            items: types
                                .map((type) => DropdownMenuItem(
                                      value: type,
                                      child: Text(type!),
                                    ))
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
                            DropdownMenuItem(value: -1, child: Text("เลือกสถานะ")),
                            DropdownMenuItem(value: 1, child: Text("ใช้งาน")),
                            DropdownMenuItem(value: 0, child: Text("ไม่ได้ใช้งาน")),
                          ],
                          onChanged: (v) => setState(() => selectedActive = v),
                          decoration: _dropdownDecoration(),
                        ),
                      ),
                    ],
                  ),
                  if (widget.categoryId == 0) ...[
                    const SizedBox(height: 12),
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
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_month, color: Colors.grey, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              selectedDate == null
                                  ? "เลือกวันหมดอายุ"
                                  : "${selectedDate!.day.toString().padLeft(2, '0')}/${selectedDate!.month.toString().padLeft(2, '0')}/${selectedDate!.year + 543}",
                              style: const TextStyle(fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() => showFilter = false);
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
                              selectedType = null;
                              selectedActive = -1;
                              selectedDate = null;
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

  // --- ส่วนอื่นๆ คงเดิมตามที่คุณส่งมา ---

  Widget _chip(String text, {Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color ?? Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      ),
    );
  }

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
        child: Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _summaryCard(int total, int filtered) {
    const icon = Icons.fire_extinguisher;
    const color = Colors.red;
    const categoryName = 'ถังดับเพลิง';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'รายการ$categoryName',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    filtered == total ? 'จำนวนทั้งหมด $total รายการ' : 'แสดง $filtered จาก $total รายการ',
                    style: const TextStyle(fontSize: 14, color: Colors.black),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: color, width: 2),
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
              ),
              child: const Row(
                children: [
                  Icon(icon, size: 24, color: color),
                  SizedBox(width: 8),
                  Text(
                    categoryName,
                    style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _assetCard(dynamic item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              const Icon(Icons.fire_extinguisher, size: 46, color: Colors.red),
              const SizedBox(height: 8),
              _chip('${item['branch'] ?? '-'}', color: Colors.blue.shade50),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _chip('${item['name'] ?? '-'}', color: const Color.fromARGB(255, 235, 235, 235)),
                const SizedBox(height: 8),
                Builder(
                  builder: (context) {
                    final type = item['type']?.toString().toLowerCase() ?? '';
                    final Map<String, Color> typeColors = {
                      'dry': Colors.blue.shade200,
                      'เขียว': Colors.green.shade200,
                      'แดง': Colors.red.shade200,
                      'เงิน': Colors.grey.shade400,
                    };
                    return _chip('ประเภท ${item['type'] ?? '-'}', color: typeColors[type] ?? Colors.grey.shade200);
                  },
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 18, color: Colors.red),
                    const SizedBox(width: 4),
                    Expanded(child: Text(item['location'] ?? '-', style: const TextStyle(fontSize: 14))),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 18, color: Colors.orange),
                    const SizedBox(width: 4),
                    Expanded(
                        child: Text(
                          // เช็คว่า item['expdate'] เป็น null หรือว่างไหม
                          (item['expdate'] != null &&
                                  item['expdate'].toString().isNotEmpty)
                              ? "วันหมดอายุ ${item['expdate'].toString().split(' ')[0]}"
                              : "วันหมดอายุ -", // ถ้าเป็น null ให้แสดง -
                          style: const TextStyle(fontSize: 15),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
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
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: item['active'] == 1 ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              _actionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AuditFireDetailPage(
                        assetId: item['id'] as int,
                        assetName: (item['name'] ?? '').toString(),
                        assetType: (item['type'] ?? '').toString(),
                      
                      ),
                      ),
                  );
                },
                icon: Icons.history,
                label: 'ประวัติ',
                color: Colors.red,
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 📍 ปรับปรุงส่วน Logic กรองข้อมูลให้ใช้ตัวแปรใหม่
    final List<Map<String, dynamic>> filteredList = fireList.where((item) {
      final name = (item['name'] ?? '').toString().toLowerCase();
      final branch = (item['branch'] ?? '').toString().toLowerCase();
      final location = (item['location'] ?? '').toString().toLowerCase();
      final type = (item['type'] ?? '').toString().toLowerCase();
      final active = item['active'] as int?;
      final expdateStr =  item['expdate']?.toString();

      final matchKeyword = keyword.isEmpty || name.contains(keyword.toLowerCase()) || branch.contains(keyword.toLowerCase()) || location.contains(keyword.toLowerCase());
      final matchType = selectedType == null || selectedType == "ทั้งหมด" || type == selectedType?.toLowerCase();
      final matchActive = selectedActive == -1 || active == selectedActive;
      

      bool matchDate = true;
      if (selectedDate != null) {
              // ❌ ถ้า expdate เป็น null ไม่ต้องแสดง
              if (expdateStr == null || expdateStr.isEmpty) {
                matchDate = false;
              } else {
                try {
                  final parts = expdateStr.split(' ')[0].split('/');

                  final buddhistYear = int.parse(parts[2]);
                  final christianYear = buddhistYear - 543; // แปลง พ.ศ. -> ค.ศ.

                  final date = DateTime(
                    christianYear,
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
            }

            return matchKeyword && matchType && matchActive && matchDate;
          }).toList();
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.red,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('ถังดับเพลิงทั้งหมด', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.red))
          : Column(
              children: [
                _summaryCard(fireList.length, filteredList.length),
                const SizedBox(height: 10),
                _searchBar(fireList), // 📍 เรียกใช้ SearchBar ใหม่ที่นี่
                Expanded(
                  child: filteredList.isEmpty
                      ? const Center(child: Text("ไม่พบข้อมูลอุปกรณ์"))
                      : ListView.builder(
                          itemCount: filteredList.length,
                          padding: const EdgeInsets.only(bottom: 20),
                          itemBuilder: (context, index) {
                            final item = filteredList[index];
                            return InkWell(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => InspectFirePage(
                                    assetId: item['id'] as int,
                                    assetName: (item['name'] ?? '').toString(),
                                  ),
                                ),
                              ),
                              child: _assetCard(item),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}