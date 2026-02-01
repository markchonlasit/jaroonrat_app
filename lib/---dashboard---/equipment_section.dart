import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

/// =========================
/// 🔹 EQUIPMENT SECTION
/// =========================
class EquipmentSection extends StatefulWidget {
  const EquipmentSection({super.key});

  @override
  State<EquipmentSection> createState() => _EquipmentSectionState();
}

class _EquipmentSectionState extends State<EquipmentSection> {
  final List<Map<String, dynamic>> devices = [
    {
      "name": "ถังดับเพลิง",
      "status": {"normal": 9, "abnormal": 5, "pending": 2, "total": 16},
      "types": [
        {"label": "ผงเคมีแห้ง", "value": 10},
        {"label": "คาร์บอนไดออกไซด์", "value": 4},
      ],
    },
    {
      "name": "ไฟฉุกเฉิน",
      "status": {"normal": 12, "abnormal": 1, "pending": 3, "total": 16},
    },
    {
      "name": "อราม",
      "status": {"normal": 8, "abnormal": 0, "pending": 1, "total": 9},
    },
    {
      "name": "อ่างล้างตา",
      "status": {"normal": 4, "abnormal": 1, "pending": 0, "total": 5},
    },
    {
      "name": "ทรายดับเพลิง",
      "status": {"normal": 6, "abnormal": 0, "pending": 0, "total": 6},
    },
  ];

  int selectedIndex = 0;
  bool loading = false;

  /// 🔹 รองรับ API ตอนเปลี่ยน select
  Future<void> _onDeviceChanged(int index) async {
    setState(() {
      selectedIndex = index;
      loading = true;
    });

    // 🔸 ตัวอย่าง: เรียก API
    // final result = await fetchDeviceSummary(devices[index]['name']);
    // setState(() {
    //   devices[index] = result;
    // });

    await Future.delayed(const Duration(milliseconds: 400)); // mock API
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final device = devices[selectedIndex];
    final status = device['status'];

    return Card(
      color: const Color.fromARGB(255, 240, 241, 241),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Colors.black),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            _title('สรุปผลรวมการตรวจสภาพเเต่ละอุปกรณ์ต่อเดือน'),
            const SizedBox(height: 8),

            /// 🔹 DROPDOWN
            DropdownButton<int>(
              value: selectedIndex,
              isExpanded: true,
              underline: const SizedBox(),
              items: List.generate(
                devices.length,
                (i) =>
                    DropdownMenuItem(value: i, child: Text(devices[i]['name'])),
              ),
              onChanged: (v) {
                if (v != null) _onDeviceChanged(v);
              },
            ),

            const SizedBox(height: 12),

            if (loading)
              const Padding(
                padding: EdgeInsets.all(12),
                child: CircularProgressIndicator(),
              )
            else ...[
              /// 🔹 STATUS
              Row(
                children: [
                  _StatusBox(
                    'ปกติ',
                    status['normal'],
                    Colors.green,
                    icon: Icons.check_circle,
                  ),
                  _StatusBox(
                    'ไม่ปกติ',
                    status['abnormal'],
                    Colors.red,
                    icon: Icons.error,
                  ),
                  _StatusBox(
                    'รอตรวจ',
                    status['pending'],
                    Colors.orange,
                    icon: Icons.schedule,
                  ),
                ],
              ),

              const SizedBox(height: 12),
              _totalBox(status['total']),
              const SizedBox(height: 12),

              /// 🔹 TYPE
              if (device.containsKey('types'))
                _donutChart(device['types'])
              else
                _noTypeBox(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _title(String text) => Container(
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: const Color(0xFF0047AB),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      children: [
        const Icon(Icons.bar_chart, color: Colors.white),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(color: Colors.white)),
      ],
    ),
  );

  Widget _totalBox(int total) => Card(
    color: Colors.blueAccent,
    child: ListTile(
      leading: const Icon(Icons.build, color: Colors.white),
      title: const Text(
        'จำนวนอุปกรณ์ทั้งหมด',
        style: TextStyle(color: Colors.white),
      ),
      trailing: Text(
        '$total',
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    ),
  );

  Widget _noTypeBox() => Container(
    padding: const EdgeInsets.symmetric(vertical: 24),
    width: double.infinity,
    decoration: BoxDecoration(
      border: Border.all(color: Colors.black),
      borderRadius: BorderRadius.circular(12),
    ),
    child: const Center(child: Text('ไม่มีประเภทของอุปกรณ์ชนิดนี้')),
  );

  Widget _donutChart(List types) {
    final colors = [Colors.orangeAccent, Colors.blue];
    final total = types.fold<int>(0, (s, t) => s + (t['value'] as int));

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            height: 90,
            child: PieChart(
              PieChartData(
                centerSpaceRadius: 10, // ✅ รู donut ชัด
                sectionsSpace: 2, // ✅ เว้นช่อง slice
                startDegreeOffset: -90, // ✅ เริ่มด้านบน (ดูสมดุล)
                sections: List.generate(types.length, (i) {
                  return PieChartSectionData(
                    value: (types[i]['value'] as int).toDouble(),
                    color: colors[i % colors.length],
                    title: '',
                  );
                }),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(types.length, (i) {
                final percent = ((types[i]['value'] / total) * 100)
                    .toStringAsFixed(1);
                return _LegendItem(
                  color: colors[i % colors.length],
                  label: types[i]['label'],
                  value: '$percent%',
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

/// =========================
/// 🔹 STATUS BOX (FIXED)
/// =========================
class _StatusBox extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final IconData icon;

  const _StatusBox(this.label, this.value, this.color, {required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 95,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.black),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.white, size: 18),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
            Text(
              '$value',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// =========================
/// 🔹 LEGEND ITEM
/// =========================
class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final String value;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(label)),
          Text(value),
        ],
      ),
    );
  }
}
