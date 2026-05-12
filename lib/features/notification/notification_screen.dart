import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/notification_provider.dart';
import '../match/match_detail_screen.dart';

class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({super.key});

  @override
  ConsumerState<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(notificationProvider.notifier).loadNotifications());
  }

  @override
  Widget build(BuildContext context) {
    final notifications = ref.watch(notificationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('알림', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(notificationProvider.notifier).loadNotifications(),
          ),
        ],
      ),
      body: SafeArea(
        child: notifications.isEmpty 
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
              itemCount: notifications.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final noti = notifications[index];
                return Dismissible(
                  key: Key(noti.id),
                  background: Container(
                    color: Colors.redAccent,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    ref.read(notificationProvider.notifier).removeNotification(noti.id);
                  },
                  child: ListTile(
                    onTap: () {
                      if (noti.data != null) {
                        final m = noti.data!;
                        Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(builder: (_) => MatchDetailScreen(
                          matchId: m['id'] as int? ?? 0,
                          isAlreadyMatched: m['is_confirmed'] == true,
                          myItemTitle: m['lost_item_title'] ?? '내 분실물',
                          counterpartTitle: m['found_item_title'] ?? '유사 습득물',
                          similarityScore: (m['similarity_score'] as num?)?.toDouble() ?? 0.0,
                        )));
                      }
                    },
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.shade50,
                      child: const Icon(Icons.notifications_active, color: Color(0xFF2563EB), size: 20),
                    ),
                    title: Text(noti.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 6),
                        Text(noti.body, style: TextStyle(color: Colors.grey.shade700, fontSize: 13, height: 1.3)),
                        const SizedBox(height: 6),
                        Text(noti.time, style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
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
