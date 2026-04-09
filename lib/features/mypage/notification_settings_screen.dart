import 'package:flutter/material.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _pushNotifications = true;
  bool _matchAlerts = true;
  bool _chatAlerts = true;
  bool _marketingAlerts = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('알림 설정', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text('앱 알림', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('푸시 알림 허용', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('앱의 모든 푸시 알림을 켜거나 끕니다.'),
              value: _pushNotifications,
              activeColor: Colors.blue,
              onChanged: (val) => setState(() => _pushNotifications = val),
            ),
            const Divider(),
            const Padding(
              padding: EdgeInsets.only(top: 16.0, bottom: 8.0),
              child: Text('상세 알림', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('매칭 알림'),
              subtitle: const Text('내 물건과 유사한 물건이 등록될 때 알림을 받습니다.'),
              value: _matchAlerts,
              activeColor: Colors.blue,
              onChanged: !_pushNotifications ? null : (val) => setState(() => _matchAlerts = val),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('채팅 알림'),
              subtitle: const Text('새로운 채팅 메시지가 올 때 알림을 받습니다.'),
              value: _chatAlerts,
              activeColor: Colors.blue,
              onChanged: !_pushNotifications ? null : (val) => setState(() => _chatAlerts = val),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('혜택 및 이벤트 알림'),
              value: _marketingAlerts,
              activeColor: Colors.blue,
              onChanged: !_pushNotifications ? null : (val) => setState(() => _marketingAlerts = val),
            ),
          ],
        ),
      ),
    );
  }
}
