import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/match_service.dart';

/// 매칭 결과 목록을 관리하는 Provider
class MatchNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  final MatchService _matchService = MatchService();

  MatchNotifier() : super([]);

  /// 분실물의 유사도 매칭 목록 조회
  Future<void> loadSimilarity(int lostItemId) async {
    try {
      final result = await _matchService.getSimilarity(lostItemId);
      final matches = result['matches'] as List? ?? [];
      state = matches.map((m) => Map<String, dynamic>.from(m)).toList();
    } catch (_) {
      state = [];
    }
  }

  /// 매칭 수동 트리거
  Future<bool> triggerMatching(int lostItemId) async {
    try {
      await _matchService.triggerMatching(lostItemId);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// 매칭 확인
  Future<bool> confirmMatch(int matchId) async {
    try {
      await _matchService.confirmMatch(matchId, isConfirmed: true);
      // 상태에서 해당 매칭의 is_confirmed를 true로 업데이트
      state = state.map((m) {
        if (m['id'] == matchId) {
          return {...m, 'is_confirmed': true};
        }
        return m;
      }).toList();
      return true;
    } catch (_) {
      return false;
    }
  }
}

final matchProvider = StateNotifierProvider<MatchNotifier, List<Map<String, dynamic>>>((ref) {
  return MatchNotifier();
});
