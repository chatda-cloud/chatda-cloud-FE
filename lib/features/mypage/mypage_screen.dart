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
      body: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            // 상단 테마 컬러 헤더
            Container(
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top, bottom: 20),
              color: Theme.of(context).primaryColor,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('마이페이지', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: const Icon(Icons.settings, color: Colors.white),
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.person, color: Colors.white, size: 36),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(userInfo.name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                                  const SizedBox(width: 8),
                                  InkWell(
                                    onTap: () {
                                      Navigator.push(context, MaterialPageRoute(builder: (_) => const MyPageEditScreen()));
                                    },
                                    borderRadius: BorderRadius.circular(4),
                                    child: const Padding(
                                      padding: EdgeInsets.all(4.0),
                                      child: Icon(Icons.edit, color: Colors.white, size: 16),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(userInfo.email, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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
      padding: const EdgeInsets.all(16),
      children: lostItems.map((item) => _buildItemCardWithActions(
        title: item['title'] as String,
        desc: item['desc'] as String,
        location: item['location'] as String,
        date: item['date'] as String,
        tags: item['tags'] as List<String>,
        type: '분실물',
        color: Colors.redAccent,
        onEdit: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => RegisterLostItemScreen(editItem: item)));
        },
        onDelete: () => _deleteItem(item, isLost: true),
      )).toList(),
    );
  }

  Widget _buildMyFoundItemsTab(BuildContext context, List<Map<String, dynamic>> foundItems) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: foundItems.map((item) => _buildItemCardWithActions(
        title: item['title'] as String,
        desc: item['desc'] as String,
        location: item['location'] as String,
        date: item['date'] as String,
        tags: item['tags'] as List<String>,
        type: '습득물',
        color: Colors.green,
        onEdit: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => RegisterFoundItemScreen(editItem: item)));
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
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Color(0xFF2563EB), width: 1.5)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: const Color(0xFF2563EB).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                      child: const Text('매칭 성공', style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                    Text('2026-04-05', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 12),
                const Text('내 분실물 ↔ 타인의 습득물 매칭', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                Text('분실: 검정색 가죽 지갑', style: TextStyle(color: Colors.grey.shade700, fontSize: 14)),
                Text('습득: 가죽 지갑 (강남역 3번 출구)', style: TextStyle(color: Colors.grey.shade700, fontSize: 14)),
              ],
            ),
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
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            Text(desc, style: TextStyle(color: Colors.grey.shade700, fontSize: 14)),
            const SizedBox(height: 16),
            _buildIconText(Icons.location_on_outlined, location),
            const SizedBox(height: 6),
            _buildIconText(Icons.calendar_today_outlined, date),
            const SizedBox(height: 16),
            Row(
              children: [
                ...tags.map((tag) => Container(
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(tag, style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
                    )),
              ],
            ),
            const SizedBox(height: 16),
            Text(type, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('수정'),
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: const Color(0xFF2563EB),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text('삭제'),
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: Colors.redAccent,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconText(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade500),
        const SizedBox(width: 8),
        Text(text, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
      ],
    );
  }
}
