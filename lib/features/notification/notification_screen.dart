import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final List<Map<String, String>> _notifications = [
    {
      'id': '1',
      'title': '[스마트 매칭] 새로운 유사 항목 발견!',
      'body': '잃어버린 "검정색 가죽 지갑"과 일치할 가능성이 높은 습득물이 등록되었습니다. 지금 확인해보세요.',
      'time': '방금 전',
    },
    {
      'id': '2',
      'title': '회원가입을 환영합니다.',
      'body': 'Chatda 서비스에 가입해 주셔서 감사합니다.',
      'time': '1일 전',
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('알림', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
        centerTitle: false,
      ),
      body: SafeArea(
        child: _notifications.isEmpty 
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.notifications_none, size: 48, color: Colors.grey.shade400),
                  ),
                  const SizedBox(height: 24),
                  Text('알림이 없습니다.', style: TextStyle(color: Colors.grey.shade600, fontSize: 16)),
                ],
              ),
            )
          : ListView.separated(
              itemCount: _notifications.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final noti = _notifications[index];
                return Dismissible(
                  key: Key(noti['id']!),
                  background: Container(
                    color: Colors.redAccent,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    setState(() {
                      _notifications.removeAt(index);
                    });
                  },
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.shade50,
                      child: const Icon(Icons.notifications_active, color: Color(0xFF2563EB), size: 20),
                    ),
                    title: Text(noti['title']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 6),
                        Text(noti['body']!, style: TextStyle(color: Colors.grey.shade700, fontSize: 13, height: 1.3)),
                        const SizedBox(height: 6),
                        Text(noti['time']!, style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
                      ],
                    ),
                  ),
                );
              },
            ),
      ),
    );
  }
}
