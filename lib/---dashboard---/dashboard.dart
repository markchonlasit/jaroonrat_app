import 'package:flutter/material.dart';
import 'package:flutter_application_1/---login---/login.dart';
import 'package:flutter_application_1/---proflie---/proflie.dart';
import '/widgets/topbar.dart';
import '/services/auth_service.dart';
import 'equipment_section.dart';
import 'total_equipment_section.dart';
import 'branch.dart';
import '/---manage---/equipment_management.dart';
import '/---check---/checklist.dart';
import 'package:flutter/cupertino.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: TopBar(
        username: AuthService.username ?? '-',
        onProfile: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ProfilePage(), // 👈 จาก proflie.dart
            ),
          );
        },
        onLogout: () {
          AuthService.token = null;
          AuthService.username = null;

          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginPage()),
            (route) => false,
          );
        },
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 120),
          child: Column(
            children: const [
              BranchCard(),
              SizedBox(height: 12),
              EquipmentSection(),
              SizedBox(height: 12),
              TotalEquipmentSection(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 16), // 👈 เว้นขอบจอ
        child: Container(
          padding: const EdgeInsets.all(10), // 👈 ระยะด้านในกรอบ
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.black),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: const ActionButtonSection(),
        ),
      ),
    );
  }
}

/// =========================
/// 🔹 ACTION BUTTON
/// =========================
class ActionButtonSection extends StatelessWidget {
  const ActionButtonSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children:  [
        Expanded(
          child: _ActionButton(
            label: 'จัดการอุปกรณ์',
            icon: Icons.inventory_2,
            bgColor: Color(0xFFCFE8FF),
            iconColor: Color.fromARGB(221, 98, 147, 204),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EquipmentManagementPage(),
                ),
              );
            },
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: _ActionButton(
            label: 'ตรวจสอบอุปกรณ์',
            icon: CupertinoIcons.checkmark_shield,
            bgColor: Color.fromARGB(255, 210, 221, 248),
            iconColor: Color(0xFF0047AB),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => checklistPage(),
                ),
              );
            },
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: _ActionButton(
            label: 'แจ้งเตือนอุปกรณ์',
            icon: Icons.notifications,
            bgColor: Color.fromARGB(255, 235, 227, 213),
            iconColor: Colors.orange,
            badge: 0,
          ),
        ),
      ],
    );
  }
}

/// =========================
/// 🔹 ACTION BUTTON ITEM
/// =========================
class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color bgColor;
  final Color iconColor;
  final int? badge;
  final VoidCallback? onTap; // 👈 เพิ่ม

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.bgColor,
    required this.iconColor,
    this.badge,
    this.onTap, // 👈 เพิ่ม
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 75,
      child: Stack(
        children: [
          InkWell( // 👈 ครอบด้วย InkWell
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: Container(
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black26),
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 32, color: iconColor),
                    const SizedBox(height: 6),
                    Text(
                      label,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12 , fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ),

          if (badge != null)
            Positioned(
              top: 6,
              right: 6,
              child: CircleAvatar(
                radius: 11,
                backgroundColor: Colors.orange,
                child: Text(
                  '$badge',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}