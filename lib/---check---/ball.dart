import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '/services/auth_service.dart';
import '/---Inspect---/inspectball.dart';
import '/---audit---/audit_ball_detail.dart';

class BallPage extends StatefulWidget {
  const BallPage({super.key});

  @override
  State<BallPage> createState() => _BallPageState();
}

class _BallPageState extends State<BallPage> {
  bool isLoading = true;
  String errorMessage = '';

  List<Map<String, dynamic>> fireList = [];

  String keyword = '';
  int typeFilter = 0;
  int statusFilter = 0;

  DateTime? selectedExpDate;

  final String apiUrl =
      'https://api.jaroonrat.com/safetyaudit/api/assetlist/1';

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

        fireList = List<Map<String, dynamic>>.from(
          data['asset'] ?? [],
        );
      } else {
        errorMessage = 'โหลดข้อมูลไม่สำเร็จ (${response.statusCode})';
      }
    } catch (e) {
      errorMessage = 'ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ได้';
    }

    setState(() => isLoading = false);
  }

  // ===== แปลง ค.ศ. → พ.ศ. =====
  String formatThaiDate(DateTime date) {
    final year = date.year + 543;
    return "${date.day}/${date.month}/$year";
  }

  DateTime? parseApiDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return null;
    try {
      return DateTime.parse(dateStr);
    } catch (_) {
      return null;
    }
  }

  // ⭐ selector เลือกวันหมดอายุ (แก้ไขสีให้เป็นธีม Ball)
  Widget _expDateSelector() {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: selectedExpDate ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
          // ✅ เปลี่ยนสีตัวปฏิทินที่เด้งขึ้นมาให้เป็นสีน้ำเงิน
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: Color.fromARGB(255, 5, 47, 233), 
                ),
              ),
              child: child!,
            );
          },
        );

        if (picked != null) {
          setState(() => selectedExpDate = picked);
        }
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          // ✅ เปลี่ยนพื้นหลังให้เป็นสีน้ำเงินอ่อนๆ
          color: const Color.fromARGB(255, 5, 47, 233).withValues(alpha: .08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today,
              // ✅ เปลี่ยนไอคอนเป็นสีน้ำเงิน
              color: Color.fromARGB(255, 5, 47, 233),
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                selectedExpDate == null
                    ? "เลือกวันหมดอายุ"
                    : "หมดอายุ: ${formatThaiDate(selectedExpDate!)}",
                style: const TextStyle(
                  // ✅ เปลี่ยนข้อความเป็นสีน้ำเงิน
                  color: Color.fromARGB(255, 5, 47, 233),
                  fontSize: 15,
                ),
              ),
            ),
            if (selectedExpDate != null)
              GestureDetector(
                onTap: () => setState(() => selectedExpDate = null),
                child: const Icon(
                  Icons.close,
                  // ✅ เปลี่ยนไอคอนกากบาทเป็นสีน้ำเงิน
                  color: Color.fromARGB(255, 5, 47, 233),
                  size: 20,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getColorByType(String type) {
    switch (type.toLowerCase()) {
      case 'เขียว':
        return Colors.green;
      case 'แดง':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _countBar(int total, int filtered) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: const Color.fromARGB(255, 5, 47, 233).withValues(alpha: .08),
      child: Text(
        filtered == total
            ? "อุปกรณ์ทั้งหมด $total รายการ"
            : "แสดง $filtered จากทั้งหมด $total รายการ",
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Color.fromARGB(255, 5, 47, 233),
        ),
      ),
    );
  }

  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
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
    );
  }

  Widget _typeButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _typeButton("ทั้งหมด", 0),
          _typeButton("เขียว", 1),
          _typeButton("แดง", 2),
        ],
      ),
    );
  }

  Widget _typeButton(String text, int value) {
    final selected = typeFilter == value;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => typeFilter = value),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: selected
                ? const Color.fromARGB(255, 5, 47, 233)
                : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color.fromARGB(255, 5, 47, 233)),
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              color: selected
                  ? Colors.white
                  : const Color.fromARGB(255, 5, 47, 233),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _statusButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _statusButton("ทั้งหมด", 0),
          _statusButton("ใช้งานอยู่", 1),
          _statusButton("ไม่พร้อมใช้งาน", 2),
        ],
      ),
    );
  }

  Widget _statusButton(String text, int value) {
    final selected = statusFilter == value;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => statusFilter = value),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: selected
                ? const Color.fromARGB(255, 5, 47, 233)
                : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color.fromARGB(255, 5, 47, 233)),
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected
                  ? Colors.white
                  : const Color.fromARGB(255, 5, 47, 233),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> filteredList = fireList.where((item) {
      final name = (item['name'] ?? '').toString().toLowerCase();
      final location = (item['location'] ?? '').toString().toLowerCase();
      final branch = (item['branch'] ?? '').toString().toLowerCase();
      final type = (item['type'] ?? '').toString().toLowerCase();
      final active = item['active'];

      final search = keyword.toLowerCase();

      final matchKeyword = search.isEmpty ||
          name.contains(search) ||
          location.contains(search) ||
          branch.contains(search);

      final matchType = typeFilter == 0
          ? true
          : typeFilter == 1
              ? type == 'เขียว'
              : type == 'แดง';

      final matchStatus = statusFilter == 0
          ? true
          : statusFilter == 1
              ? active == 1
              : active != 1;

      final expDate = parseApiDate(item['expdate']);
      final matchExpDate = selectedExpDate == null ||
          (expDate != null &&
              expDate.year == selectedExpDate!.year &&
              expDate.month == selectedExpDate!.month &&
              expDate.day == selectedExpDate!.day);

      return matchKeyword && matchType && matchStatus && matchExpDate;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 5, 47, 233),
        title: const Text(
          'ลูกบอลดับเพลิงทั้งหมด',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AuditBallDetailPage(
                    auditedAssetIds: [],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _countBar(fireList.length, filteredList.length),
                _searchBar(),
                const SizedBox(height: 8),
                _typeButtons(),
                const SizedBox(height: 8),
                _statusButtons(),
                const SizedBox(height: 8),
                _expDateSelector(),
                const SizedBox(height: 8),
                Expanded(
                  child: filteredList.isEmpty
                      ? const Center(child: Text('ไม่พบข้อมูล'))
                      : ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: filteredList.length,
                          itemBuilder: (context, index) {
                            final item = filteredList[index];
                            final expDate = parseApiDate(item['expdate']);

                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => InspectBallPage(
                                      assetId: item['id'] as int,
                                      assetName: (item['name'] ?? '-').toString(),
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                margin: const EdgeInsets.all(12),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: const Color.fromARGB(255, 5, 47, 233),
                                    width: 2,
                                  ),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.sports_baseball,
                                      color: _getColorByType(
                                          (item['type'] ?? '').toString()),
                                      size: 40,
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            (item['name'] ?? '-').toString(),
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text('ID: ${item['id']}'),
                                          Text('สาขา: ${item['branch']}'),
                                          Text(
                                            'วันหมดอายุ: ${expDate != null ? formatThaiDate(expDate) : '-'}',
                                          ),
                                          Text('สถานที่: ${item['location']}'),
                                          Text(
                                            'ประเภทสีของลูกบอล: ${item['type']}',
                                            style: TextStyle(
                                              color: _getColorByType(
                                                  (item['type'] ?? '')
                                                      .toString()),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Row(
                                            children: [
                                              Icon(
                                                item['active'] == 1
                                                    ? Icons.check_circle
                                                    : Icons.cancel,
                                                size: 16,
                                                color: item['active'] == 1
                                                    ? Colors.green
                                                    : Colors.red,
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                item['active'] == 1
                                                    ? 'ใช้งานอยู่'
                                                    : 'ไม่พร้อมใช้งาน',
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}