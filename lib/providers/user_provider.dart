import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/user_service.dart';

class UserInfo {
  final int? id;
  final String email;
  final String name;
  final String phone;
  final String? profileImageUrl;
  final String? gender;
  final String? birthDate;

  const UserInfo({
    this.id,
    required this.email,
    required this.name,
    required this.phone,
    this.profileImageUrl,
    this.gender,
    this.birthDate,
  });

  UserInfo copyWith({
    int? id,
    String? email,
    String? name,
    String? phone,
    String? profileImageUrl,
    String? gender,
    String? birthDate,
  }) {
    return UserInfo(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
    );
  }

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    // 백엔드 응답이 {"success": true, "data": {...}} 형태인 경우 대응
    final data = (json.containsKey('data') && json['data'] is Map)
        ? Map<String, dynamic>.from(json['data'] as Map)
        : json;

    // 백엔드에서 올 수 있는 다양한 이름 필드명 대응
    final name = data['username'] as String? ??
        data['name'] as String? ??
        data['nickname'] as String? ??
        data['display_name'] as String? ??
        '';

    // 프로필 이미지 필드명 대응
    final profileImageUrl = data['profile_image_url'] as String? ??
        data['profileImageUrl'] as String? ??
        data['avatar_url'] as String? ??
        data['profile_url'] as String?;

    return UserInfo(
      id: data['id'] as int?,
      email: data['email'] as String? ?? '',
      name: name,
      phone: data['phone'] as String? ?? '',
      profileImageUrl: profileImageUrl,
      gender: data['gender'] as String?,
      birthDate: data['birthDate'] as String? ?? data['birth_date'] as String?,
    );
  }
}

class UserNotifier extends StateNotifier<UserInfo> {
  final UserService _userService = UserService();

  UserNotifier()
      : super(const UserInfo(
          email: '',
          name: '',
          phone: '',
        ));

  /// API에서 내 정보 로드
  Future<void> loadMe() async {
    try {
      final data = await _userService.getMe();
      final newInfo = UserInfo.fromJson(data);
      // 서버 응답에 username 필드가 없거나 비어있으면 기존 로컬 name 유지
      // (서버 응답 키가 예상과 다를 때 이름이 사라지는 문제 방지)
      state = newInfo.copyWith(
        name: newInfo.name.isEmpty ? state.name : newInfo.name,
        email: newInfo.email.isEmpty ? state.email : newInfo.email,
        profileImageUrl: newInfo.profileImageUrl ?? state.profileImageUrl,
      );
    } catch (_) {
      // 실패 시 기존 상태 유지
    }
  }

  /// 로컬 상태 업데이트 (API 응답으로 바로 반영)
  void setUser(UserInfo user) {
    state = user;
  }

  void updateUser({String? name, String? phone}) {
    state = state.copyWith(name: name, phone: phone);
  }

  /// 닉네임 변경 (API 호출)
  Future<bool> updateUsername(String username) async {
    try {
      await _userService.updateUsername(username);
      state = state.copyWith(name: username);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// 프로필 이미지 변경 (API 호출)
  Future<bool> updateProfileImage(String profileImageUrl) async {
    try {
      await _userService.updateProfileImage(profileImageUrl);
      state = state.copyWith(profileImageUrl: profileImageUrl);
      return true;
    } catch (_) {
      return false;
    }
  }
}

final userProvider = StateNotifierProvider<UserNotifier, UserInfo>((ref) {
  return UserNotifier();
});
