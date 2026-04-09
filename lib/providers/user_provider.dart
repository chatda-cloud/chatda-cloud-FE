import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserInfo {
  final String email;
  final String name;
  final String phone;

  const UserInfo({
    required this.email,
    required this.name,
    required this.phone,
  });

  UserInfo copyWith({String? email, String? name, String? phone}) {
    return UserInfo(
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
    );
  }
}

class UserNotifier extends StateNotifier<UserInfo> {
  UserNotifier()
      : super(const UserInfo(
          email: 'demo@example.com',
          name: '데모 사용자',
          phone: '010-1234-5678',
        ));

  void updateUser({String? email, String? name, String? phone}) {
    state = state.copyWith(email: email, name: name, phone: phone);
  }
}

final userProvider = StateNotifierProvider<UserNotifier, UserInfo>((ref) {
  return UserNotifier();
});
