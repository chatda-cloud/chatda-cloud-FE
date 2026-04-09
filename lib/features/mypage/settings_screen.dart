import 'package:flutter/material.dart';
import '../auth/login_screen.dart';
import 'notification_settings_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          children: [
            const SizedBox(height: 16),
            _buildSettingsTile(
              context, 
              icon: Icons.notifications_none, 
              title: '알림 설정', 
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationSettingsScreen()));
              }
            ),
            const Divider(),
            _buildSettingsTile(
              context,
              icon: Icons.logout,
              title: '로그아웃',
              textColor: Colors.black87,
              onTap: () {
                Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
            ),
            _buildSettingsTile(
              context,
              icon: Icons.person_remove_alt_1_outlined,
              title: '회원 탈퇴',
              textColor: Colors.redAccent,
              onTap: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('회원 탈퇴'),
                    content: const Text('정말로 탈퇴하시겠습니까? 등록된 모든 데이터가 삭제되며 복구할 수 없습니다.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('취소')),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                            (route) => false,
                          );
                        },
                        child: const Text('탈퇴', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTile(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap, Color textColor = Colors.black87}) {
    return ListTile(
      leading: Icon(icon, color: textColor == Colors.redAccent ? Colors.redAccent : Colors.grey.shade700),
      title: Text(title, style: TextStyle(color: textColor, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }
}
