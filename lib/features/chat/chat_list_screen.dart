import 'package:flutter/material.dart';
import 'chat_detail_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // 하드코딩된 더미 채팅 데이터
  final List<Map<String, dynamic>> _allChatData = [
    {
      'name': '습득자(익명)',
      'item': '검정색 가죽 지갑',
      'lastMsg': '네, 내일 오후 2시에 강남역 3번 출구에서 뵐게요.',
      'time': '오후 8:43',
      'unread': 1,
    },
    {
      'name': '분실자(익명)',
      'item': '무선 이어폰',
      'lastMsg': '보관장소에 맡겨주셔서 감사합니다!',
      'time': '어제',
      'unread': 0,
    },
    {
      'name': '습득자(익명)',
      'item': 'iPhone 15 Pro',
      'lastMsg': '혹시 배경화면이 고양이 사진인가요?',
      'time': '3월 21일',
      'unread': 0,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredData = _allChatData.where((chat) {
      final title = chat['item'] as String;
      final name = chat['name'] as String;
      final query = _searchQuery.toLowerCase();
      return title.toLowerCase().contains(query) || name.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(fontSize: 16),
                decoration: const InputDecoration(
                  hintText: '채팅방 검색...',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: false,
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                  isDense: true,
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              )
            : const Text('채팅', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _isSearching = false;
                  _searchController.clear();
                  _searchQuery = '';
                } else {
                  _isSearching = true;
                }
              });
            },
          ),
        ],
      ),
      body: filteredData.isEmpty
          ? const Center(child: Text('검색 결과가 없습니다.', style: TextStyle(color: Colors.grey)))
          : ListView.separated(
              padding: const EdgeInsets.only(bottom: 120), // 하단 바 뒤로 컨텐츠가 스크롤되도록 하단 여백 추가
              itemCount: filteredData.length,
              separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey.shade200),
              itemBuilder: (context, index) {
                final chat = filteredData[index];
                final unread = chat['unread'] as int;

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.blue.shade100,
                    child: const Icon(Icons.person, color: Colors.blue, size: 32),
                  ),
                  title: Row(
                    children: [
                      Text(chat['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(4)),
                        child: Text(chat['item'] as String, style: TextStyle(fontSize: 10, color: Colors.grey.shade700)),
                      ),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: Text(chat['lastMsg'] as String, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey.shade600)),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min, // 추가해서 Overflow 방지
                    children: [
                      Text(chat['time'] as String, style: TextStyle(color: unread > 0 ? Colors.blue : Colors.grey.shade500, fontSize: 12, fontWeight: unread > 0 ? FontWeight.bold : FontWeight.normal)),
                      if (unread > 0)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.all(5),
                          decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                          child: Text('$unread', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                        )
                    ],
                  ),
                  onTap: () {
                    Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(builder: (_) => ChatDetailScreen(
                      counterpartName: chat['name'] as String,
                      itemName: chat['item'] as String,
                    )));
                  },
                );
              },
            ),
    );
  }
}

