import 'package:flutter/material.dart';
import '/services/api_services.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:intl/intl.dart';

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

    /// ✅ default = เดือนปีปัจจุบัน
    final now = DateTime.now();
    selectedMonth = int.parse(
      "${now.year}${now.month.toString().padLeft(2, '0')}",
    );

    _fetchInitialData();
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

    final picked = await showMonthPicker(
      context: context,
      initialDate: DateTime(initialYear, initialMonth),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      /// ✅ แปลงเป็น yyyyMM เช่น Nov 2025 -> 202511
      final formatted = int.parse(
        "${picked.year}${picked.month.toString().padLeft(2, '0')}",
      );

      setState(() {
        selectedMonth = formatted;
      });

      _fetchDashboardData();
    }
  }

  String _formatDisplayMonth(int value) {
    final year = int.parse(value.toString().substring(0, 4));
    final month = int.parse(value.toString().substring(4));
    final date = DateTime(year, month);

    return DateFormat.yMMMM('en_US').format(date);
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
                  flex: 2,
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
                  flex: 1,
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
                          color: Colors.grey.shade300,
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
      value: value,
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

  Widget _noTypeBox() => Container(
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
