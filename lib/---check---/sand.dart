import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '/services/auth_service.dart';
import '/---Inspect---/inspectsand.dart';
import '/---audit---/audit_sand_detil.dart';

class SandPage extends StatefulWidget {
  const SandPage({super.key});

  @override
  State<SandPage> createState() => _SandPageState();
}

class _SandPageState extends State<SandPage> {
  bool isLoading = true;
  String errorMessage = '';
  List<Map<String, dynamic>> sandList = [];

  String keyword = '';
  int statusFilter = 0;

  DateTime? selectedDate; // ⭐ เพิ่ม

  final String apiUrl =
      'https://api.jaroonrat.com/safetyaudit/api/assetlist/4';

  @override
  void initState() {
    super.initState();
    fetchSand();
  }

  Future<void> fetchSand() async {
    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer ${AuthService.token}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data =
            json.decode(response.body);

        sandList = List<Map<String, dynamic>>.from(
          data['asset'] ?? [],
        );
      } else {
        errorMessage =
            'โหลดข้อมูลไม่สำเร็จ (${response.statusCode})';
      }
    } catch (e) {
      errorMessage = 'ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ได้';
    }

    setState(() => isLoading = false);
  }

  Widget _countBar(int total, int filtered) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: Colors.brown.withValues(alpha: 0.08),
      child: Text(
        filtered == total
            ? "อุปกรณ์ทั้งหมด $total รายการ"
            : "แสดง $filtered จากทั้งหมด $total รายการ",
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.brown,
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
            color: selected ? Colors.brown : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.brown),
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              color: selected ? Colors.white : Colors.brown,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  // ⭐ UI เลือกวันหมดอายุ (อยู่ใต้ filter)
  Widget _datePicker() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: selectedDate ?? DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
          );

          if (picked != null) {
            setState(() => selectedDate = picked);
          }
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.brown.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.calendar_today,
                  color: Colors.brown),
              const SizedBox(width: 10),
              Text(
                selectedDate == null
                    ? "เลือกวันหมดอายุ"
                    : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
              ),
              const Spacer(),
              if (selectedDate != null)
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () =>
                      setState(() => selectedDate = null),
                )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> filteredList =
        sandList.where((item) {
      final name =
          (item['name'] ?? '').toString().toLowerCase();
      final location =
          (item['location'] ?? '').toString().toLowerCase();
      final branch =
          (item['branch'] ?? '').toString().toLowerCase();
      final active = item['active'];
      final exp = item['expdate'] ?? '';

      final search = keyword.toLowerCase();

      final matchKeyword = search.isEmpty ||
          name.contains(search) ||
          location.contains(search) ||
          branch.contains(search);

      final matchStatus = statusFilter == 0
          ? true
          : statusFilter == 1
              ? active == 1
              : active != 1;

      final matchDate = selectedDate == null
          ? true
          : exp.toString().contains(
              "${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}");

      return matchKeyword && matchStatus && matchDate;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 121, 85, 72),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'ทรายซับสารเคมีทั้งหมด',
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AuditSandDetailPage(
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
                _countBar(sandList.length, filteredList.length),
                _searchBar(),
                const SizedBox(height: 8),
                _statusButtons(),
                const SizedBox(height: 8),
                _datePicker(), // ⭐ อยู่ใต้ filter ตามที่ขอ
                const SizedBox(height: 8),

                Expanded(
                  child: filteredList.isEmpty
                      ? const Center(child: Text('ไม่พบข้อมูล'))
                      : ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: filteredList.length,
                          itemBuilder: (context, index) {
                            final item = filteredList[index];

                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        InspectSandPage(
                                      assetId: item['id'] as int,
                                      assetName:
                                          (item['name'] ?? '-')
                                              .toString(),
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                margin: const EdgeInsets.all(12),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.circular(14),
                                  border: Border.all(
                                    color: Colors.brown,
                                    width: 2,
                                  ),
                                ),
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.brown.withValues(alpha: 0.08),
                                      ),
                                      child: const Icon(
                                        Icons.grain,
                                        color: Colors.brown,
                                        size: 26,
                                      ),
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
                                          Text('วันหมดอายุ: ${item['expdate'] ?? '-'}'),
                                          Text('สถานที่: ${item['location']}'),
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