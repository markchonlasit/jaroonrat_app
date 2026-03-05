import 'package:flutter/material.dart';
import '/services/api_services.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:fl_chart/fl_chart.dart';

class EquipmentSection extends StatefulWidget {
  const EquipmentSection({super.key});

  @override
  State<EquipmentSection> createState() => _EquipmentSectionState();
}

class _EquipmentSectionState extends State<EquipmentSection> {
  List<dynamic> categories = [];
  Map<String, dynamic> statusData = {
    "normal": 0,
    "abnormal": 0,
    "pending": 0,
    "total": 0,
  };

  int? selectedCategoryId;
  int selectedMonth = 0; // จะกำหนด default ตอน init
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    initializeDateFormatting('th_TH');

    final now = DateTime.now();
    selectedMonth = int.parse(
      "${now.year}${now.month.toString().padLeft(2, '0')}",
    );

    _fetchInitialData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final now = DateTime.now();
    selectedMonth = int.parse(
      "${now.year}${now.month.toString().padLeft(2, '0')}",
    );
  }

  Future<void> _fetchInitialData() async {
    try {
      final fetchedCategories = await ApiService.getCategory();
      if (fetchedCategories.isNotEmpty) {
        setState(() {
          categories = fetchedCategories;
          selectedCategoryId = fetchedCategories[0]['id'];
        });
        await _fetchDashboardData();
      }
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _fetchDashboardData() async {
    if (selectedCategoryId == null) return;
    setState(() => isLoading = true);
    try {
      final result = await ApiService.getCategoryDashboard(
        selectedCategoryId!,
        selectedMonth,
      );
      setState(() => statusData = result);
    } catch (e) {
      debugPrint("API Error: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  /// =========================
  /// 🔹 MONTH PICKER (month_picker_dialog)
  /// =========================
  Future<void> _pickMonthYear() async {
    final initialYear = int.parse(selectedMonth.toString().substring(0, 4));
    final initialMonth = int.parse(selectedMonth.toString().substring(4));

    final now = DateTime.now();

    final picked = await showMonthPicker(
      context: context,
      
      initialDate: DateTime(initialYear, initialMonth),
      firstDate: DateTime(2020),
      lastDate: DateTime(now.year, now.month),
    );

    if (picked != null) {
      final formatted = int.parse(
        "${picked.year}${picked.month.toString().padLeft(2, '0')}",
      );

      setState(() {
        selectedMonth = formatted;
      });

      await _fetchDashboardData();
    }
  }

  String _formatDisplayMonth(int value) {
    final year = int.parse(value.toString().substring(0, 4));
    final month = int.parse(value.toString().substring(4));
    final date = DateTime(year, month);

    // ✅ ดึงชื่อเดือนแบบเต็ม เช่น "กุมภาพันธ์"
    String monthName = DateFormat.MMMM('th_TH').format(date);

    // ✅ คำนวณปี พ.ศ.
    int thaiYear = year + 543;

    return "$monthName พ.ศ.$thaiYear";
  }

  /// =========================
  /// 🔹 pie graph
  /// =========================
  ///
  Color _getColorByName(String name) {
    switch (name.trim().toLowerCase()) {
      case 'dry':
        return Colors.blue;
      case 'เงิน':
        return Colors.grey;
      case 'แดง':
        return Colors.red;
      case 'เขียว':
        return Colors.green;
      default:
        return Colors.blueGrey; // fallback ถ้าไม่ตรงเงื่อนไข
    }
  }

  List<PieChartSectionData> _buildPieSections(List<dynamic> data) {
    // final total = statusData['total'] ?? 1;

    return List.generate(data.length, (index) {
      final item = data[index];
      final value = item['data'] ?? 0;
      final name = item['name'] ?? '';

      // final percentage = total == 0 ? 0 : ((value / total) * 100);

      return PieChartSectionData(
        color: _getColorByName(name), // 🔥 ใช้ตรงนี้แทน
        value: value.toDouble(),
        // title: '${percentage.toStringAsFixed(1)}%',
        title: '',
        radius: 40,
        titleStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    });
  }

  List<Widget> _buildLegend(List<dynamic> data) {
    final total = statusData['total'] ?? 1;

    return List.generate(data.length, (index) {
      final item = data[index];
      final value = item['data'] ?? 0;
      final name = item['name'] ?? '';

      final percentage = total == 0 ? 0 : ((value / total) * 100);

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: _getColorByName(name), // 🔥 ตรงนี้
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(name)),
            Text('${percentage.toStringAsFixed(1)}%'),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color.fromARGB(255, 241, 239, 239),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Colors.black),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _title('สรุปผลรวมการตรวจสภาพเเต่ละอุปกรณ์ต่อเดือน'),
            const SizedBox(height: 18),

            Row(
              children: [
                /// 🔹 Category Dropdown
                Expanded(
                  flex: 3,
                  child: _buildStyledDropdown<int>(
                    value: selectedCategoryId,
                    items: categories
                        .map(
                          (cat) => DropdownMenuItem<int>(
                            value: cat['id'],
                            child: Text(
                              cat['name'],
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      setState(() => selectedCategoryId = v);
                      _fetchDashboardData();
                    },
                    hint: "เลือกอุปกรณ์",
                  ),
                ),

                const SizedBox(width: 18),

                /// 🔹 Month Picker Button
                Expanded(
                  flex: 2,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: _pickMonthYear,
                    child: Container(
                      height: 60,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.grey.shade400,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _formatDisplayMonth(selectedMonth),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else ...[
              Row(
                children: [
                  _StatusBox(
                    'ปกติ',
                    statusData['normal'] ?? 0,
                    Colors.green,
                    icon: Icons.check_circle,
                  ),
                  _StatusBox(
                    'ไม่ปกติ',
                    statusData['abnormal'] ?? 0,
                    Colors.red,
                    icon: Icons.error,
                  ),
                  _StatusBox(
                    'รอตรวจ',
                    statusData['pending'] ?? 0,
                    Colors.orange,
                    icon: Icons.schedule,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _totalBox(statusData['total'] ?? 0),
              const SizedBox(height: 12),
              _noTypeBox(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStyledDropdown<T>({
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    required String hint,
  }) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      items: items,
      onChanged: onChanged,
      isExpanded: true,
      icon: const Icon(
        Icons.keyboard_arrow_down_rounded,
        size: 22,
        color: Colors.black54,
      ),
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Colors.black87,
      ),
      dropdownColor: Colors.white,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),

        /// ปกติ
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
        ),

        /// ตอน focus (ไม่เอาสีน้ำเงินเข้มแล้ว)
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade400, width: 1),
        ),
      ),
    );
  }

  Widget _title(String text) => Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: const Color(0xFF0047AB),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Row(
      children: [
        const Icon(Icons.bar_chart, color: Colors.white, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _totalBox(int total) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      color: Colors.blueAccent,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        const Icon(Icons.build, color: Colors.white),
        const SizedBox(width: 12),
        const Text(
          'จำนวนอุปกรณ์ทั้งหมด',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          '$total',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    ),
  );

  Widget _noTypeBox() {
    final pieData = statusData['piechart'];

    if (pieData == null || pieData.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Center(
          child: Text(
            'ไม่มีประเภทของอุปกรณ์ชนิดนี้',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          /// 🔹 Pie Chart
          Expanded(
            flex: 1,
            child: SizedBox(
              height: 120,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 30,
                  sections: _buildPieSections(pieData),
                ),
              ),
            ),
          ),

          const SizedBox(width: 20),

          /// 🔹 Legend
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: _buildLegend(pieData),
            ),
          ),
        ],
      ),
    );
  }
}

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
        height: 90,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 18),
                const SizedBox(width: 4),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '$value',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
