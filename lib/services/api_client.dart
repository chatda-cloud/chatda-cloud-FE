import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// 앱 전체에서 사용하는 Dio HTTP 클라이언트 관리 클래스.
/// ECS(메인 API)와 Lambda(Presigned URL) 두 개의 인스턴스를 제공합니다.
class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late final Dio mainDio;   // ECS 메인 API
  late final Dio lambdaDio; // Lambda Presigned URL
  late final Dio rawDio;    // S3 등 외부 URL 직접 호출용 (baseUrl 없음)

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // --dart-define으로 주입된 환경변수
  static const String _apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000',
  );
  static const String _lambdaBaseUrl = String.fromEnvironment(
    'LAMBDA_BASE_URL',
    defaultValue: 'https://localhost:3000',
  );

  ApiClient._internal() {
    // ECS 메인 API 클라이언트
    mainDio = Dio(BaseOptions(
      baseUrl: _apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ));

    // Bearer 토큰 자동 주입 + 401 자동 재발급 인터셉터
    mainDio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'access_token');
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          // 토큰 재발급 시도
          final refreshed = await _tryRefreshToken();
          if (refreshed) {
            // 원래 요청 재시도
            final token = await _storage.read(key: 'access_token');
            error.requestOptions.headers['Authorization'] = 'Bearer $token';
            try {
              final response = await mainDio.fetch(error.requestOptions);
              handler.resolve(response);
              return;
            } catch (e) {
              handler.next(error);
              return;
            }
          }
        }
        handler.next(error);
      },
    ));

    // Lambda Presigned URL 클라이언트
    lambdaDio = Dio(BaseOptions(
      baseUrl: _lambdaBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ));

    // S3 등 외부 직접 호출용 (baseUrl 없음)
    rawDio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 60),
    ));
  }

  /// 토큰 재발급
  Future<bool> _tryRefreshToken() async {
    try {
      final refreshToken = await _storage.read(key: 'refresh_token');
      if (refreshToken == null) return false;

      // 인터셉터를 우회하기 위해 새 Dio 인스턴스로 요청
      final tempDio = Dio(BaseOptions(baseUrl: _apiBaseUrl));
      final response = await tempDio.post(
        '/api/auth/token/reissue',
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data['accessToken'] != null) {
          await _storage.write(key: 'access_token', value: data['accessToken']);
        }
        if (data['refreshToken'] != null) {
          await _storage.write(key: 'refresh_token', value: data['refreshToken']);
        }
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  // ─── 토큰 관리 헬퍼 ───

  Future<void> saveTokens({required String accessToken, required String refreshToken}) async {
    await _storage.write(key: 'access_token', value: accessToken);
    await _storage.write(key: 'refresh_token', value: refreshToken);
  }

  Future<String?> getAccessToken() => _storage.read(key: 'access_token');
  Future<String?> getRefreshToken() => _storage.read(key: 'refresh_token');

  Future<void> clearTokens() async {
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
  }

  Future<bool> hasValidToken() async {
    final token = await _storage.read(key: 'access_token');
    return token != null && token.isNotEmpty;
  }
}
