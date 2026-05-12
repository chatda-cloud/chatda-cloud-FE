import 'api_client.dart';

/// 매칭 관련 API 호출을 담당하는 서비스
class MatchService {
  final ApiClient _client = ApiClient();

  /// 분실물과 유사한 습득물 목록 조회
  Future<Map<String, dynamic>> getSimilarity(int lostItemId) async {
    final response = await _client.mainDio.get(
      '/api/items/lost/$lostItemId/similarity',
    );
    return response.data ?? {};
  }

  /// 매칭 수동 실행 (태깅 완료 후 호출)
  Future<Map<String, dynamic>> triggerMatching(int lostItemId) async {
    final response = await _client.mainDio.post(
      '/api/items/lost/$lostItemId/match',
    );
    return response.data ?? {};
  }

  /// 매칭 확인/거부
  Future<Map<String, dynamic>> confirmMatch(int matchId, {required bool isConfirmed}) async {
    final response = await _client.mainDio.patch(
      '/api/matches/$matchId/confirm',
      data: {'is_confirmed': isConfirmed},
    );
    return response.data ?? {};
  }
}
