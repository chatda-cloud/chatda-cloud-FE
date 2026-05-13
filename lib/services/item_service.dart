import 'package:dio/dio.dart';
import 'api_client.dart';

/// 아이템(분실물/습득물) CRUD API 호출을 담당하는 서비스
///
/// NOTE: 현재 API 스펙은 `multipart/form-data` 를 요구하므로 FormData 로 전송함.
/// 백엔드가 presigned URL 로직으로 변경되면 JSON body 방식으로 다시 바꿔야 함.
class ItemService {
  final ApiClient _client = ApiClient();

  // ─── 분실물 ───

  /// 분실물 등록 (multipart/form-data, 이미지는 presigned URL 로 별도 업로드)
  Future<Map<String, dynamic>> createLostItem({
    required String itemName,
    required String dateStart,
    required String dateEnd,
    required String location,
    String? rawText,
  }) async {
    final response = await _client.mainDio.post(
      '/api/items/lost',
      data: {
        'item_name': itemName,
        'category': '기타', // 필수 파라미터 기본값 설정
        'date_start': dateStart,
        'date_end': dateEnd,
        'location': location,
        if (rawText != null && rawText.isNotEmpty) 'raw_text': rawText,
      },
    );
    return response.data ?? {};
  }

  /// 분실물 상세 조회
  Future<Map<String, dynamic>> getLostItem(int itemId) async {
    final response = await _client.mainDio.get('/api/items/lost/$itemId');
    return response.data ?? {};
  }

  /// 분실물 수정
  Future<Map<String, dynamic>> updateLostItem(int itemId, {
    String? itemName,
    String? dateStart,
    String? dateEnd,
    String? location,
    String? rawText,
  }) async {
    final response = await _client.mainDio.put(
      '/api/items/lost/$itemId',
      data: {
        if (itemName != null) 'item_name': itemName,
        if (dateStart != null) 'date_start': dateStart,
        if (dateEnd != null) 'date_end': dateEnd,
        if (location != null) 'location': location,
        if (rawText != null) 'raw_text': rawText,
      },
    );
    return response.data ?? {};
  }

  /// 분실물 삭제
  Future<void> deleteLostItem(int itemId) async {
    await _client.mainDio.delete('/api/items/lost/$itemId');
  }

  // ─── 습득물 ───

  /// 습득물 등록 (multipart/form-data, 이미지는 presigned URL 로 별도 업로드)
  Future<Map<String, dynamic>> createFoundItem({
    required String itemName,
    required String foundDate,
    required String location,
    String? rawText,
  }) async {
    final response = await _client.mainDio.post(
      '/api/items/found',
      data: {
        'item_name': itemName,
        'category': '기타', // 필수 파라미터 기본값 설정
        'found_date': foundDate,
        'location': location,
        if (rawText != null && rawText.isNotEmpty) 'raw_text': rawText,
      },
    );
    return response.data ?? {};
  }

  /// 습득물 상세 조회
  Future<Map<String, dynamic>> getFoundItem(int itemId) async {
    final response = await _client.mainDio.get('/api/items/found/$itemId');
    return response.data ?? {};
  }

  /// 습득물 수정
  Future<Map<String, dynamic>> updateFoundItem(int itemId, {
    String? itemName,
    String? foundDate,
    String? location,
    String? rawText,
  }) async {
    final response = await _client.mainDio.put(
      '/api/items/found/$itemId',
      data: {
        if (itemName != null) 'item_name': itemName,
        if (foundDate != null) 'found_date': foundDate,
        if (location != null) 'location': location,
        if (rawText != null) 'raw_text': rawText,
      },
    );
    return response.data ?? {};
  }

  /// 습득물 삭제
  Future<void> deleteFoundItem(int itemId) async {
    await _client.mainDio.delete('/api/items/found/$itemId');
  }
}
