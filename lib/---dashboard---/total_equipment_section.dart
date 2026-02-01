import 'package:flutter/material.dart';

/// =========================
/// 🔹 TOTAL EQUIPMENT
/// =========================
class TotalEquipmentSection extends StatelessWidget {
  const TotalEquipmentSection({super.key});

  @override
  Widget build(BuildContext context) {
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
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        /// 🔹 SUMMARY BOX
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.black),
          ),
          child: const Row(
            children: [
              Expanded(
                child: _SummaryItem(
                  icon: Icons.check_circle,
                  iconColor: Colors.green,
                  value: 0,
                  label: 'ปกติ',
                ),
              ),
              Expanded(
                child: _SummaryItem(
                  icon: Icons.cancel,
                  iconColor: Colors.red,
                  value: 0,
                  label: 'ไม่ปกติ',
                ),
              ),
              Expanded(
                child: _SummaryItem(
                  icon: Icons.schedule,
                  iconColor: Colors.orange,
                  value: 0,
                  label: 'รอตรวจ',
                ),
              ),
              Expanded(
                child: _SummaryItem(
                  icon: Icons.build,
                  iconColor: Color(0xFF0047AB),
                  value: 0,
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
class _SummaryItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final int value;
  final String label;

  const _SummaryItem({
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
        const SizedBox(height: 4),
        Text(
          '$value',
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