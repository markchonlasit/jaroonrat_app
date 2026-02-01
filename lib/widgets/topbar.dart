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
  Size get preferredSize => const Size.fromHeight(48);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF0047AB),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.person, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            username,
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
      centerTitle: true,
      actions: [
        PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'profile') onProfile();
            if (value == 'logout') onLogout();
          },
          itemBuilder: (_) => const [
            PopupMenuItem(
              value: 'profile',
              child: Text('บัญชีผู้ใช้'),
            ),
            PopupMenuItem(
              value: 'logout',
              child: Text('ออกจากระบบ'),
            ),
          ],
        ),
      ],
    );
  }
}