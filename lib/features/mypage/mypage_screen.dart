import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/items_provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/chatda_dialog.dart';
import 'mypage_edit_screen.dart';
import 'settings_screen.dart';
import '../auth/login_screen.dart';
import '../register/register_lost_item_screen.dart';
import '../register/register_found_item_screen.dart';

class MyPageScreen extends ConsumerStatefulWidget {
  const MyPageScreen({super.key});

  @override
  ConsumerState<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends ConsumerState<MyPageScreen> {

  @override
  Widget build(BuildContext context) {
    final userInfo = ref.watch(userProvider);
    final items = ref.watch(itemsProvider);
    final myLostItems = items['lost']!;
    final myFoundItems = items['found']!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('마이페이지', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(Icons.settings_outlined, color: Colors.grey.shade700),
            onPressed: () {
              Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            // 프로필 카드
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade100),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFF6B8EFF).withOpacity(0.15),
                            const Color(0xFFA5B4FC).withOpacity(0.15),
                          ],
                        ),
                        border: Border.all(color: const Color(0xFF2563EB).withOpacity(0.3), width: 2),
                      ),
                      child: const Icon(Icons.person, color: Color(0xFF2563EB), size: 30),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(userInfo.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                          const SizedBox(height: 3),
                          Text(userInfo.email, style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(builder: (_) => const MyPageEditScreen()));
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2563EB).withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.edit_outlined, color: Color(0xFF2563EB), size: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // 탭바
            Container(
              color: Colors.white,
              child: TabBar(
                labelColor: const Color(0xFF2563EB),
                unselectedLabelColor: Colors.grey,
                indicatorColor: const Color(0xFF2563EB),
                labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                tabs: [
                  Tab(text: '분실물 (${myLostItems.length})'),
                  Tab(text: '습득물 (${myFoundItems.length})'),
                  const Tab(text: '매칭 (1)'),
                ],
              ),
            ),
            Expanded(
              child: Container(
                color: const Color(0xFFF8FAFC),
                child: TabBarView(
                  children: [
                    _buildMyLostItemsTab(context, myLostItems),
                    _buildMyFoundItemsTab(context, myFoundItems),
                    _buildMyMatchingTab(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyLostItemsTab(BuildContext context, List<Map<String, dynamic>> lostItems) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
      children: lostItems.map((item) => _buildItemCardWithActions(
        title: item['title'] as String,
        desc: item['desc'] as String,
        location: item['location'] as String,
        date: item['date'] as String,
        tags: item['tags'] as List<String>,
        type: '분실물',
        color: const Color(0xFFEF4444),
        onEdit: () {
          Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(builder: (_) => RegisterLostItemScreen(editItem: item)));
        },
        onDelete: () => _deleteItem(item, isLost: true),
      )).toList(),
    );
  }

  Widget _buildMyFoundItemsTab(BuildContext context, List<Map<String, dynamic>> foundItems) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
      children: foundItems.map((item) => _buildItemCardWithActions(
        title: item['title'] as String,
        desc: item['desc'] as String,
        location: item['location'] as String,
        date: item['date'] as String,
        tags: item['tags'] as List<String>,
        type: '습득물',
        color: const Color(0xFF22C55E),
        onEdit: () {
          Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(builder: (_) => RegisterFoundItemScreen(editItem: item)));
        },
        onDelete: () => _deleteItem(item, isLost: false),
      )).toList(),
    );
  }

  void _deleteItem(Map<String, dynamic> item, {required bool isLost}) {
    ChatdaDialog.showConfirm(
      context: context,
      title: '삭제 확인',
      message: '정말로 이 항목을 삭제하시겠습니까?\n이 작업은 되돌릴 수 없습니다.',
      confirmText: '삭제',
      onConfirm: () {
        if (isLost) {
          ref.read(itemsProvider.notifier).removeLostItem(item['id'] as int);
        } else {
          ref.read(itemsProvider.notifier).removeFoundItem(item['id'] as int);
        }
        ChatdaDialog.showSuccess(
          context: context,
          message: '항목이 삭제되었습니다.',
        );
      },
    );
  }

  Widget _buildMyMatchingTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF2563EB).withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFF2563EB).withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
                    child: const Text('매칭 성공', style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                  Text('2026-04-05', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 14),
              const Text('내 분실물 ↔ 타인의 습득물 매칭', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF1E293B))),
              const SizedBox(height: 10),
              Text('분실: 검정색 가죽 지갑', style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
              const SizedBox(height: 4),
              Text('습득: 가죽 지갑 (강남역 3번 출구)', style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildItemCardWithActions({
    required String title,
    required String desc,
    required String location,
    required String date,
    required List<String> tags,
    required String type,
    required Color color,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Color(0xFF1E293B)))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(type, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(desc, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
          const SizedBox(height: 14),
          _buildIconText(Icons.location_on_outlined, location),
          const SizedBox(height: 6),
          _buildIconText(Icons.calendar_today_outlined, date),
          const SizedBox(height: 14),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: tags.map((tag) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Text(tag, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            )).toList(),
          ),
          const SizedBox(height: 16),
          Divider(height: 1, color: Colors.grey.shade100),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onEdit,
                  icon: Icon(Icons.edit_outlined, size: 16, color: const Color(0xFF2563EB).withOpacity(0.8)),
                  label: Text('수정', style: TextStyle(color: const Color(0xFF2563EB).withOpacity(0.9), fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(color: const Color(0xFF2563EB).withOpacity(0.25)),
                    backgroundColor: const Color(0xFF2563EB).withOpacity(0.04),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onDelete,
                  icon: Icon(Icons.delete_outline, size: 16, color: const Color(0xFFEF4444).withOpacity(0.8)),
                  label: Text('삭제', style: TextStyle(color: const Color(0xFFEF4444).withOpacity(0.9), fontWeight: FontWeight.w600)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(color: const Color(0xFFEF4444).withOpacity(0.25)),
                    backgroundColor: const Color(0xFFEF4444).withOpacity(0.04),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIconText(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 15, color: Colors.grey.shade400),
        const SizedBox(width: 8),
        Text(text, style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
      ],
    );
  }
}
