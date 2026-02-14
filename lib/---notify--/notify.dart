import 'package:flutter/material.dart';
import '/services/api_services.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  List<dynamic> assets = [];
  List<dynamic> filteredAssets = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchAssets();
  }

  /// =========================
  /// 🔹 ดึงข้อมูล API
  /// =========================
  Future<void> fetchAssets() async {
    try {
      final response = await ApiService.getAssetexpdate(0);

      setState(() {
        assets = response['asset'];
        filteredAssets = assets;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
    }
  }

  /// =========================
  /// 🔹 แปลงวันที่ พ.ศ. → DateTime
  /// =========================
  DateTime parseThaiDate(String dateStr) {
    final parts = dateStr.split(" ")[0].split("/");
    int day = int.parse(parts[0]);
    int month = int.parse(parts[1]);
    int year = int.parse(parts[2]) - 543; // แปลง พ.ศ.
    return DateTime(year, month, day);
  }

  /// =========================
  /// 🔹 คำนวณสถานะ
  /// =========================
  String getStatus(String expdate) {
    DateTime exp = parseThaiDate(expdate);
    DateTime now = DateTime.now();

    if (exp.isBefore(now)) {
      return "หมดอายุ";
    }

    final diff = exp.difference(now).inDays;

    if (diff <= 365) {
      return "ใกล้หมดอายุ";
    }

    return "ใช้งานได้";
  }

  Color getStatusColor(String expdate) {
    final status = getStatus(expdate);

    switch (status) {
      case "หมดอายุ":
        return Colors.red.shade200;
      case "ใกล้หมดอายุ":
        return Colors.orange.shade200;
      default:
        return Colors.green.shade200;
    }
  }

  /// =========================
  /// 🔹 ค้นหา
  /// =========================
  void search(String keyword) {
    setState(() {
      filteredAssets = assets.where((item) {
        return item['name'].toString().toLowerCase().contains(
          keyword.toLowerCase(),
        );
      }).toList();
    });
  }

  /// =========================
  /// 🔹 นับจำนวนสถานะ
  /// =========================
  int countStatus(String status) {
    return assets.where((item) => getStatus(item['expdate']) == status).length;
  }

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
          'หน้าหลัก',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          /// 🔹 Summary
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _statusBox(
                  "ใกล้หมดอายุ",
                  countStatus("ใกล้หมดอายุ"),
                  Colors.orange,
                ),
                _statusBox("ใช้งานได้", countStatus("ใช้งานได้"), Colors.green),
                _statusBox("หมดอายุ", countStatus("หมดอายุ"), Colors.red),
              ],
            ),
          ),

          /// 🔹 Search
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TextField(
              onChanged: search,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: "ค้นหา...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          /// 🔹 List
          Expanded(
            child: ListView.builder(
              itemCount: filteredAssets.length,
              itemBuilder: (context, index) {
                final item = filteredAssets[index];
                final status = getStatus(item['expdate']);

                return Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start, // ให้ไอคอนอยู่ด้านบนเสมอ
                    children: [
                      /// 🔹 ฝั่งซ้าย: Icon และ Status
                      Column(
                        children: [
                          const Icon(
                            Icons.fire_extinguisher,
                            size: 50,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 8),
                          _chip(
                            '${item['branch']}',
                            color: Colors.blue.shade100,
                          ), // JRPE
                          const SizedBox(height: 4),
                          // _chip(
                          //   item['active'] == 1 ? "active" : "inactive",
                          //   color: item['active'] == 1
                          //       ? Colors.green.shade300
                          //       : Colors.red.shade300,
                          // ),
                        ],
                      ),
                      const SizedBox(width: 20),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _chip(
                              '${item['name']}',
                              color: const Color.fromARGB(255, 212, 211, 211),
                            ),
                            const SizedBox(height: 6),
                            _chip(
                              'ประเภท ${item['type']}',
                              color: Colors.amber.shade200,
                            ),
                            const SizedBox(height: 6),

                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  size: 20,
                                  color: Colors.red,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    item['location'] ?? '-',
                                    style: const TextStyle(fontSize: 15),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
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
                                    // ตรวจสอบก่อนว่ามีข้อมูลไหม แล้วค่อย split เอาเฉพาะส่วนวันที่หน้าช่องว่าง
                                    "วันหมดอายุ ${item['expdate'] != null ? item['expdate'].toString().split(' ')[0] : '-'}",
                                    style: const TextStyle(fontSize: 15),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                          ],
                        ),
                      ),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: status == "หมดอายุ"
                              ? Colors.red
                              : status == "ใกล้หมดอายุ"
                              ? Colors.orange
                              : Colors.green,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          status,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBox(String title, int count, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(title),
          const SizedBox(height: 6),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
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

  Widget _statusBoxWithIcon(String title, int count, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        color: Colors.white,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
              const SizedBox(height: 4),
              Text('$count', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}
