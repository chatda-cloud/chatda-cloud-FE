import 'api_client.dart';

/// 사용자 관련 API 호출을 담당하는 서비스
class UserService {
  final ApiClient _client = ApiClient();

  /// 내 정보 조회
  Future<Map<String, dynamic>> getMe() async {
    final response = await _client.mainDio.get('/api/users/me');
    return response.data ?? {};
  }

  /// 닉네임 변경
  Future<Map<String, dynamic>> updateUsername(String username) async {
    final response = await _client.mainDio.patch(
      '/api/users/me/username',
      data: {'username': username},
    );
    return response.data ?? {};
  }

  /// 프로필 이미지 변경
  Future<Map<String, dynamic>> updateProfileImage(String profileImageUrl) async {
    final response = await _client.mainDio.patch(
      '/api/users/me/profile-image',
      data: {'profile_image_url': profileImageUrl},
    );
    return response.data ?? {};
  }

  /// 내 분실물 목록 조회
  Future<List<dynamic>> getMyLostItems() async {
    final response = await _client.mainDio.get('/api/users/me/lost-items');
    final data = response.data;
    if (data is List) return data;
    if (data is Map && data['data'] is List) return data['data'];
    if (data is Map && data['items'] is List) return data['items'];
    return [];
  }

  /// 내 습득물 목록 조회
  Future<List<dynamic>> getMyFoundItems() async {
    final response = await _client.mainDio.get('/api/users/me/found-items');
    final data = response.data;
    if (data is List) return data;
    if (data is Map && data['data'] is List) return data['data'];
    if (data is Map && data['items'] is List) return data['items'];
    return [];
  }

  /// 내 매칭 목록 조회
  Future<List<dynamic>> getMyMatches() async {
    final response = await _client.mainDio.get('/api/users/me/matches');
    final data = response.data;
    if (data is List) return data;
    if (data is Map && data['data'] is List) return data['data'];
    if (data is Map && data['matches'] is List) return data['matches'];
    return [];
  }
}
