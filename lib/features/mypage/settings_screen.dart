import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/login_screen.dart';
import 'notification_settings_screen.dart';
import 'mypage_edit_screen.dart';
import '../../providers/user_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/chatda_dialog.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userInfo = ref.watch(userProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('설정', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 사용자 프로필 요약
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: userInfo.profileImageUrl != null && userInfo.profileImageUrl!.isNotEmpty
                          ? ClipOval(child: Image.network(userInfo.profileImageUrl!, fit: BoxFit.cover))
                          : const Icon(Icons.person, size: 50, color: Color(0xFF2563EB)),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${userInfo.name.isEmpty ? '사용자' : userInfo.name}님', 
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // 설정 메뉴 그룹 (애플 스타일 둥근 컨테이너 안의 리스트)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 2)),
                  ],
                ),
                child: Column(
                  children: [
                    _buildSettingsTile(
                      title: '정보 수정',
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const MyPageEditScreen()));
                      },
                    ),
                    _buildDivider(),
                    _buildSettingsTile(
                      title: '알림 설정',
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationSettingsScreen()));
                      },
                    ),
                    _buildDivider(),
                    _buildSettingsTile(
                      title: '로그아웃',
                      onTap: () async {
                        await ref.read(authProvider.notifier).logout();
                        if (!context.mounted) return;
                        Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                          (route) => false,
                        );
                      },
                    ),
                    _buildDivider(),
                    _buildSettingsTile(
                      title: '회원 탈퇴',
                      textColor: Colors.redAccent,
                      onTap: () {
                        ChatdaDialog.showConfirm(
                          context: context,
                          title: '회원 탈퇴',
                          message: '정말로 탈퇴하시겠습니까?\n등록된 모든 데이터가 삭제되며\n복구할 수 없습니다.',
                          confirmText: '탈퇴',
                          onConfirm: () {
                            Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                              MaterialPageRoute(builder: (_) => const LoginScreen()),
                              (route) => false,
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, thickness: 1, color: Colors.grey.shade100, indent: 16, endIndent: 16);
  }

  Widget _buildSettingsTile({required String title, required VoidCallback onTap, Color textColor = Colors.black87}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w500)),
            Icon(Icons.arrow_forward_ios, color: Colors.grey.shade400, size: 16),
          ],
        ),
      ),
    );
  }
}
