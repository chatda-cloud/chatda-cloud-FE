import 'package:dio/dio.dart';
import 'api_client.dart';

/// 인증 관련 API 호출을 담당하는 서비스
class AuthService {
  final ApiClient _client = ApiClient();

  /// 회원가입
  Future<Map<String, dynamic>> signup({
    required String email,
    required String password,
    required String username,
    String? gender,
    String? birthDate,
  }) async {
    final response = await _client.mainDio.post(
      '/api/auth/signup',
      data: {
        'email': email,
        'password': password,
        'username': username,
        if (gender != null) 'gender': gender,
        if (birthDate != null) 'birthDate': birthDate,
      },
    );
    return response.data ?? {};
  }

  /// 로그인 → 토큰 저장
  Future<Map<String, dynamic>> signin({
    required String email,
    required String password,
  }) async {
    final response = await _client.mainDio.post(
      '/api/auth/signin',
      data: {
        'email': email,
        'password': password,
      },
    );
    final data = response.data ?? {};

    // 토큰 저장
    if (data['accessToken'] != null && data['refreshToken'] != null) {
      await _client.saveTokens(
        accessToken: data['accessToken'],
        refreshToken: data['refreshToken'],
      );
    }
    return data;
  }

  /// 소셜 로그인 (Google, Kakao 등)
  Future<Map<String, dynamic>> socialExchange({
    required String provider,
    required String code,
  }) async {
    final response = await _client.mainDio.post(
      '/api/auth/exchange',
      data: {
        'provider': provider,
        'code': code,
      },
    );
    final data = response.data ?? {};

    // 토큰 저장
    if (data['accessToken'] != null && data['refreshToken'] != null) {
      await _client.saveTokens(
        accessToken: data['accessToken'],
        refreshToken: data['refreshToken'],
      );
    }
    return data;
  }

  /// 로그아웃
  Future<void> logout() async {
    try {
      await _client.mainDio.delete('/api/auth/logout');
    } catch (_) {
      // 서버 에러여도 로컬 토큰은 삭제
    } finally {
      await _client.clearTokens();
    }
  }

  /// 비밀번호 재설정 요청 (이메일 전송)
  Future<Map<String, dynamic>> requestPasswordReset({required String email}) async {
    final response = await _client.mainDio.post(
      '/api/auth/pwreset/request',
      data: {'email': email},
    );
    return response.data ?? {};
  }

  /// 비밀번호 재설정 확인
  Future<void> confirmPasswordReset({
    required String token,
    required String newPassword,
  }) async {
    await _client.mainDio.post(
      '/api/auth/pwreset/confirm',
      data: {
        'token': token,
        'newPassword': newPassword,
      },
    );
  }

  /// 토큰 유효성 확인 (me API 호출)
  Future<bool> validateToken() async {
    try {
      final hasToken = await _client.hasValidToken();
      if (!hasToken) return false;

      await _client.mainDio.get('/api/users/me');
      return true;
    } catch (_) {
      return false;
    }
  }
}
