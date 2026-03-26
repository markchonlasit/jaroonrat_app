import 'package:flutter/material.dart';
import 'package:flutter_application_1/---login---/login.dart';
import 'package:flutter_application_1/---proflie---/proflie.dart';
import '/widgets/topbar.dart';
import '/services/auth_service.dart';
import 'equipment_section.dart';
import 'total_equipment_section.dart';
import 'branch.dart';
import '/---manage---/equipment_management.dart';
import '/---safety---/checklist.dart';
import '/---notify--/notify.dart';
import 'package:flutter/cupertino.dart';
import '/services/api_services.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late Future<Map<String, dynamic>> alertFuture;

  @override
  void initState() {
    super.initState();
    alertFuture = ApiService.getAlert();
  }

  // ✅ ฟังก์ชัน Refresh (อยู่ใน State เท่านั้น!)
  Future<void> _onRefresh() async {
    setState(() {
      alertFuture = ApiService.getAlert(); // โหลดใหม่
    });
  }

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
              builder: (_) => const ProfilePage(),
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

      // ✅ 👇 เพิ่ม RefreshIndicator ตรงนี้
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(), // สำคัญ!
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 120),
            child: Column(
              children: const [
                BranchCard(),
                SizedBox(height: 6),
                EquipmentSection(),
                SizedBox(height: 6),
                TotalEquipmentSection(),
              ],
            ),
          ),
        ),
      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: ActionButtonSection(alertFuture: alertFuture), // 👈 ส่งค่าไป
        ),
      ),
    );
  }
}

/// =========================
/// 🔹 ACTION BUTTON
/// =========================
class ActionButtonSection extends StatelessWidget {
  final Future<Map<String, dynamic>> alertFuture;

  const ActionButtonSection({super.key, required this.alertFuture});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            label: 'จัดการอุปกรณ์',
            icon: Icons.inventory_2,
            bgColor: Color(0xFFCFE8FF),
            iconColor: Color.fromARGB(221, 98, 147, 204),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => EquipmentManagementPage()),
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
                MaterialPageRoute(builder: (_) => ChecklistPage()),
              );
            },
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: FutureBuilder<Map<String, dynamic>>(
            future: alertFuture, // ✅ ใช้ตัวนี้แทน
            builder: (context, snapshot) {
              int badgeCount = 0;

              if (snapshot.hasData) {
                badgeCount = snapshot.data?['alert'] ?? 0;
              }

              return _ActionButton(
                label: 'แจ้งเตือนอุปกรณ์',
                icon: Icons.notifications,
                bgColor: const Color.fromARGB(255, 235, 227, 213),
                iconColor: Colors.orange,
                badge: badgeCount,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => NotificationPage()),
                  );
                },
              );
            },
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
  final VoidCallback? onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.bgColor,
    required this.iconColor,
    this.badge,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 75,
      child: Stack(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: Container(
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey),
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
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
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