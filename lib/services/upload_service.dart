import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'api_client.dart';

/// Presigned URL을 사용한 S3 이미지 업로드 + AI 태깅 전체 플로우를 담당하는 서비스
///
/// 플로우:
/// 1. Lambda POST /presigned-url → presignedUrl, s3Key 수령
/// 2. S3 PUT {presignedUrl} → 이미지 바이너리 업로드 (Authorization 없이)
/// 3. ECS POST /api/items/{itemId}/process-tags → AI 태깅 시작
/// 4. ECS GET /api/items/{itemId}/tags → 태깅 결과 폴링
class UploadService {
  final ApiClient _client = ApiClient();

  /// Step 1: Lambda에서 Presigned URL 발급
  Future<Map<String, dynamic>> getPresignedUrl({
    required int itemId,
    required String filename,
    String contentType = 'image/jpeg',
  }) async {
    final response = await _client.lambdaDio.post(
      '/presigned-url',
      data: {
        'itemId': itemId,
        'filename': filename,
        'contentType': contentType,
      },
    );
    return response.data ?? {};
  }

  /// Step 2: S3에 이미지 직접 업로드 (Authorization 없이!)
  Future<void> uploadToS3({
    required String presignedUrl,
    required Uint8List imageBytes,
    String contentType = 'image/jpeg',
  }) async {
    await _client.rawDio.put(
      presignedUrl,
      data: Stream.fromIterable(imageBytes.map((e) => [e])),
      options: Options(
        headers: {
          'Content-Type': contentType,
          'Content-Length': imageBytes.length,
        },
      ),
    );
  }

  /// Step 3: AI 태깅 처리 요청
  Future<void> processTags({
    required int itemId,
    required String s3Key,
  }) async {
    await _client.mainDio.post(
      '/api/items/$itemId/process-tags',
      data: {'s3Key': s3Key},
    );
  }

  /// Step 4: 태깅 결과 조회
  Future<Map<String, dynamic>> getTags(int itemId) async {
    final response = await _client.mainDio.get('/api/items/$itemId/tags');
    return response.data ?? {};
  }

  /// Step 4 (폴링): 태깅 완료까지 2초 간격으로 폴링 (최대 30초)
  Future<Map<String, dynamic>> pollTagResults(int itemId) async {
    const maxAttempts = 15; // 2초 × 15 = 30초
    for (int i = 0; i < maxAttempts; i++) {
      await Future.delayed(const Duration(seconds: 2));
      try {
        final result = await getTags(itemId);
        // features가 비어있지 않거나 hasVector가 true면 완료
        final features = result['features'] as List? ?? [];
        final hasVector = result['hasVector'] as bool? ?? false;
        if (features.isNotEmpty || hasVector) {
          return result;
        }
      } catch (_) {
        // 아직 처리 중일 수 있으므로 계속 폴링
      }
    }
    // 타임아웃 시에도 마지막으로 한번 더 조회
    return await getTags(itemId);
  }

  /// 전체 플로우를 한번에 실행하는 convenience 메서드
  ///
  /// 1. presigned URL 발급
  /// 2. S3 업로드
  /// 3. AI 태깅 요청
  /// 4. 태깅 결과 폴링
  ///
  /// 반환: TagsResponse { itemId, category, features[], hasVector, imageUrl }
  Future<Map<String, dynamic>> uploadImageAndTag({
    required int itemId,
    required String filename,
    required Uint8List imageBytes,
    String contentType = 'image/jpeg',
  }) async {
    // Step 1: Presigned URL 발급
    final presignedData = await getPresignedUrl(
      itemId: itemId,
      filename: filename,
      contentType: contentType,
    );
    final presignedUrl = presignedData['presignedUrl'] as String;
    final s3Key = presignedData['s3Key'] as String;

    // Step 2: S3 업로드
    await uploadToS3(
      presignedUrl: presignedUrl,
      imageBytes: imageBytes,
      contentType: contentType,
    );

    // Step 3: AI 태깅 요청
    await processTags(itemId: itemId, s3Key: s3Key);

    // Step 4: 태깅 결과 폴링
    return await pollTagResults(itemId);
  }
}
