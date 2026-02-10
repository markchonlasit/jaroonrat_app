import 'package:flutter/material.dart';
import '/services/api_services.dart';

/// =========================
/// 🔹 TOTAL EQUIPMENT
/// =========================
class TotalEquipmentSection extends StatefulWidget {
  const TotalEquipmentSection({super.key});

  @override
  State<TotalEquipmentSection> createState() => _TotalEquipmentSectionState();
}

class _TotalEquipmentSectionState extends State<TotalEquipmentSection> {
  int normal = 0;
  int abnormal = 0;
  int pending = 0;
  int total = 0;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    try {
      final data = await ApiService.gettotalDashboard();
      setState(() {
        normal = data['normal'] ?? 0;
        abnormal = data['abnormal'] ?? 0;
        pending = data['pending'] ?? 0;
        total = data['total'] ?? 0;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Dashboard error: $e');
      isLoading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        /// 🔹 HEADER
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF0047AB),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Row(
            children: [
              
              Icon(Icons.bar_chart, color: Colors.white),
              SizedBox(width: 8),
              Text(
                'ผลรวมการตรวจสภาพของอุปกรณ์ทั้งหมดต่อเดือน',
                style: TextStyle(color: Colors.white , fontSize: 14 , fontWeight: FontWeight.bold ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        /// 🔹 SUMMARY BOX
        Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 241, 239, 239),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.black),
          ),
          child: Row(
            children: [
              Expanded(
                child: SummaryItem(
                  icon: Icons.check_circle,
                  iconColor: Colors.green,
                  value: normal,
                  label: 'ปกติ',
                ),
              ),
              Expanded(
                child: SummaryItem(
                  icon: Icons.cancel,
                  iconColor: Colors.red,
                  value: abnormal,
                  label: 'ไม่ปกติ',
                ),
              ),
              Expanded(
                child: SummaryItem(
                  icon: Icons.schedule,
                  iconColor: Colors.orange,
                  value: pending,
                  label: 'รอตรวจ',
                ),
              ),
              Expanded(
                child: SummaryItem(
                  icon: Icons.build,
                  iconColor: Color(0xFF0047AB),
                  value: total,
                  label: 'ทั้งหมด',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// =========================
/// 🔹 SUMMARY ITEM
/// =========================
class SummaryItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final int value;
  final String label;

  const SummaryItem({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: iconColor,
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(height: 6),
        Text(
          value.toString(),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}
