import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/user_service.dart';

class AppNotification {
  final String id;
  final String title;
  final String body;
  final String time;
  final Map<String, dynamic>? data;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.time,
    this.data,
  });
}

class NotificationNotifier extends StateNotifier<List<AppNotification>> {
  final UserService _userService = UserService();

  NotificationNotifier() : super([]);

  Future<void> loadNotifications() async {
    try {
      final matches = await _userService.getMyMatches();
      
      final notifications = matches.map((m) {
        final score = (m['similarity_score'] as num?)?.toDouble() ?? 0.0;
        final percent = (score * 100).toInt();
        final myItem = m['lost_item_title'] ?? '내 분실물';
        final cpItem = m['found_item_title'] ?? '유사 습득물';
        
        return AppNotification(
          id: m['id'].toString(),
          title: '[스마트 매칭] 새로운 유사 항목 발견!',
          body: '내 "$myItem"와 ${percent}% 일치하는 "$cpItem"이 발견되었습니다. 지금 확인해보세요.',
          time: _formatTime(m['created_at']),
          data: m,
        );
      }).toList();

      state = [
        ...notifications,
        AppNotification(
          id: 'welcome',
          title: '회원가입을 환영합니다.',
          body: 'Chatda 서비스에 가입해 주셔서 감사합니다.',
          time: '최근',
        ),
      ];
    } catch (_) {
      // API 실패 시 웰컴 메시지만 표시
      state = [
        AppNotification(
          id: 'welcome',
          title: '회원가입을 환영합니다.',
          body: 'Chatda 서비스에 가입해 주셔서 감사합니다.',
          time: '최근',
        ),
      ];
    }
  }

  void removeNotification(String id) {
    state = state.where((n) => n.id != id).toList();
  }

  String _formatTime(dynamic createdAt) {
    if (createdAt == null) return '방금 전';
    try {
      final dt = DateTime.parse(createdAt.toString());
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
      if (diff.inHours < 24) return '${diff.inHours}시간 전';
      return '${diff.inDays}일 전';
    } catch (_) {
      return '최근';
    }
  }
}

final notificationProvider = StateNotifierProvider<NotificationNotifier, List<AppNotification>>((ref) {
  return NotificationNotifier();
});
