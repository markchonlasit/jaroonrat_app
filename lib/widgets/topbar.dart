import 'package:flutter/material.dart';

class TopBar extends StatelessWidget implements PreferredSizeWidget {
  final String username;
  final VoidCallback onProfile;
  final VoidCallback onLogout;

  const TopBar({
    super.key,
    required this.username,
    required this.onProfile,
    required this.onLogout,
  });

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 4,
      backgroundColor: const Color(0xFF0047AB),
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          // 🔹 รูปด้านซ้าย (แก้ path ตามโปรเจคคุณ)
          Image.asset(
            'images/logo-circle.png',
            height: 32,
          ),

          const Spacer(),

          // 🔹 username ด้านขวา
          Row(
            children: [
              const Icon(
                Icons.account_circle,
                color: Colors.white,
                size: 22,
              ),
              const SizedBox(width: 6),
              Text(
                username,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: PopupMenuButton<String>(
            icon: const Icon(
              Icons.menu,
              color: Colors.white,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onSelected: (value) {
              if (value == 'profile') onProfile();
              if (value == 'logout') onLogout();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person, size: 18, color: Colors.blueAccent),
                    SizedBox(width: 8),
                    Text('บัญชีผู้ใช้'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 18, color: Colors.redAccent),
                    SizedBox(width: 8),
                    Text('ออกจากระบบ'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}