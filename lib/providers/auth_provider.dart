import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../services/api_client.dart';

/// 인증 상태
class AuthState {
  final bool isLoggedIn;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.isLoggedIn = false,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({bool? isLoggedIn, bool? isLoading, String? error}) {
    return AuthState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService = AuthService();

  AuthNotifier() : super(const AuthState());

  /// 로그인
  Future<bool> signin({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _authService.signin(email: email, password: password);
      state = state.copyWith(isLoggedIn: true, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _parseError(e));
      return false;
    }
  }

  /// 회원가입
  Future<bool> signup({
    required String email,
    required String password,
    required String username,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _authService.signup(email: email, password: password, username: username);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _parseError(e));
      return false;
    }
  }

  /// 소셜 로그인
  Future<bool> socialLogin({required String provider, required String code}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _authService.socialExchange(provider: provider, code: code);
      state = state.copyWith(isLoggedIn: true, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _parseError(e));
      return false;
    }
  }

  /// 로그아웃
  Future<void> logout() async {
    await _authService.logout();
    state = const AuthState(isLoggedIn: false);
  }

  /// 저장된 토큰으로 자동 로그인 시도
  Future<bool> tryAutoLogin() async {
    try {
      final isValid = await _authService.validateToken();
      state = state.copyWith(isLoggedIn: isValid);
      return isValid;
    } catch (_) {
      state = state.copyWith(isLoggedIn: false);
      return false;
    }
  }

  /// 비밀번호 재설정 요청
  Future<bool> requestPasswordReset(String email) async {
    try {
      await _authService.requestPasswordReset(email: email);
      return true;
    } catch (e) {
      state = state.copyWith(error: _parseError(e));
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  String _parseError(dynamic e) {
    print('AuthError: $e'); 
    
    // Dio 통신 에러인 경우 서버가 보낸 실제 응답(JSON) 확인
    if (e.runtimeType.toString() == 'DioException' || e.runtimeType.toString() == '_DioException') {
      try {
        final dioError = e as dynamic; // DioException 타입 (import 안되어 있으므로 dynamic 처리)
        final responseData = dioError.response?.data;
        print('Response Data: $responseData'); // 터미널에 서버 응답 출력
        
        if (responseData != null) {
          // FastAPI 422 Validation Error 처리
          if (responseData is Map && responseData.containsKey('detail')) {
            final detail = responseData['detail'];
            if (detail is List && detail.isNotEmpty) {
              final firstError = detail[0];
              final field = firstError['loc']?.last ?? '알 수 없는 필드';
              final msg = firstError['msg'] ?? '입력값이 올바르지 않습니다.';
              return '입력 오류 [$field]: $msg';
            } else if (detail is String) {
              return detail;
            }
          }
          if (responseData is Map && responseData.containsKey('message')) {
            return responseData['message'].toString();
          }
          return '오류 내용:\n$responseData';
        }
      } catch (_) {}
    }
    
    return '오류 발생: $e';
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
