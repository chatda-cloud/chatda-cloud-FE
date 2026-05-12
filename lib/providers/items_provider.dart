import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/user_service.dart';
import '../services/item_service.dart';

class ItemsNotifier extends StateNotifier<Map<String, List<Map<String, dynamic>>>> {
  final UserService _userService = UserService();
  final ItemService _itemService = ItemService();

  ItemsNotifier() : super({'lost': [], 'found': []});

  /// API에서 내 분실물/습득물 목록 로드
  Future<void> loadMyItems() async {
    try {
      final lostData = await _userService.getMyLostItems();
      final foundData = await _userService.getMyFoundItems();
      state = {
        'lost': lostData.map((e) => _normalizeItem(e, 'lost')).toList(),
        'found': foundData.map((e) => _normalizeItem(e, 'found')).toList(),
      };
    } catch (_) {
      // API 실패 시 빈 상태 유지
    }
  }

  /// API 응답을 UI에서 사용하는 형식으로 정규화
  Map<String, dynamic> _normalizeItem(dynamic raw, String type) {
    final item = Map<String, dynamic>.from(raw as Map);
    return {
      'id': item['id'] ?? item['item_id'] ?? 0,
      'title': item['item_name'] ?? item['title'] ?? '',
      'desc': item['raw_text'] ?? item['desc'] ?? item['description'] ?? '',
      'location': item['location'] ?? '',
      'date': _formatDate(item, type),
      'tags': _extractTags(item),
      'imageUrl': item['image_url'] ?? item['imageUrl'],
      'type': type,
      // 원본 데이터도 보존
      ...item,
    };
  }

  String _formatDate(Map<String, dynamic> item, String type) {
    if (item['date'] != null) return item['date'].toString();
    if (type == 'lost') {
      final start = item['date_start'];
      if (start != null) {
        try {
          final dt = DateTime.parse(start.toString());
          return '${dt.year}년 ${dt.month.toString().padLeft(2, '0')}월 ${dt.day.toString().padLeft(2, '0')}일';
        } catch (_) {
          return start.toString();
        }
      }
    } else {
      final foundDate = item['found_date'];
      if (foundDate != null) {
        try {
          final dt = DateTime.parse(foundDate.toString());
          return '${dt.year}년 ${dt.month.toString().padLeft(2, '0')}월 ${dt.day.toString().padLeft(2, '0')}일';
        } catch (_) {
          return foundDate.toString();
        }
      }
    }
    return '';
  }

  List<String> _extractTags(Map<String, dynamic> item) {
    if (item['tags'] is List) {
      return List<String>.from(item['tags']);
    }
    // features 필드에서 추출 (TagsResponse 형식)
    if (item['features'] is List) {
      return List<String>.from(item['features']);
    }
    final category = item['category'] as String?;
    if (category != null) return [category];
    return [];
  }

  // ─── 아이템 추가 (API 호출 후 로컬 상태 업데이트) ───

  Future<int?> addLostItem(Map<String, dynamic> item) async {
    try {
      final result = await _itemService.createLostItem(
        itemName: item['title'] ?? item['item_name'] ?? '',
        dateStart: item['dateStart'] ?? DateTime.now().toIso8601String(),
        dateEnd: item['dateEnd'] ?? DateTime.now().toIso8601String(),
        location: item['location'] ?? '',
        rawText: item['desc'] ?? item['raw_text'],
      );
      final newItemId = result['id'] ?? result['item_id'];

      // 로컬 상태에 추가
      final normalized = _normalizeItem({...item, 'id': newItemId, ...result}, 'lost');
      state = {
        ...state,
        'lost': [normalized, ...state['lost']!],
      };
      return newItemId as int?;
    } catch (_) {
      return null;
    }
  }

  Future<int?> addFoundItem(Map<String, dynamic> item) async {
    try {
      final result = await _itemService.createFoundItem(
        itemName: item['title'] ?? item['item_name'] ?? '',
        foundDate: item['foundDate'] ?? DateTime.now().toIso8601String(),
        location: item['location'] ?? '',
        rawText: item['desc'] ?? item['raw_text'],
      );
      final newItemId = result['id'] ?? result['item_id'];

      final normalized = _normalizeItem({...item, 'id': newItemId, ...result}, 'found');
      state = {
        ...state,
        'found': [normalized, ...state['found']!],
      };
      return newItemId as int?;
    } catch (_) {
      return null;
    }
  }

  // ─── 아이템 삭제 ───

  Future<bool> removeLostItem(int id) async {
    try {
      await _itemService.deleteLostItem(id);
      state = {
        ...state,
        'lost': state['lost']!.where((item) => item['id'] != id).toList(),
      };
      return true;
    } catch (_) {
      // API 실패해도 로컬에서는 삭제
      state = {
        ...state,
        'lost': state['lost']!.where((item) => item['id'] != id).toList(),
      };
      return false;
    }
  }

  Future<bool> removeFoundItem(int id) async {
    try {
      await _itemService.deleteFoundItem(id);
      state = {
        ...state,
        'found': state['found']!.where((item) => item['id'] != id).toList(),
      };
      return true;
    } catch (_) {
      state = {
        ...state,
        'found': state['found']!.where((item) => item['id'] != id).toList(),
      };
      return false;
    }
  }

  // ─── 아이템 수정 ───

  Future<bool> updateLostItem(int id, Map<String, dynamic> updatedData) async {
    try {
      await _itemService.updateLostItem(
        id,
        itemName: updatedData['title'],
        location: updatedData['location'],
        rawText: updatedData['desc'],
      );
      state = {
        ...state,
        'lost': state['lost']!.map((item) => item['id'] == id ? { ...item, ...updatedData } : item).toList(),
      };
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateFoundItem(int id, Map<String, dynamic> updatedData) async {
    try {
      await _itemService.updateFoundItem(
        id,
        itemName: updatedData['title'],
        location: updatedData['location'],
        rawText: updatedData['desc'],
      );
      state = {
        ...state,
        'found': state['found']!.map((item) => item['id'] == id ? { ...item, ...updatedData } : item).toList(),
      };
      return true;
    } catch (_) {
      return false;
    }
  }
}

final itemsProvider = StateNotifierProvider<ItemsNotifier, Map<String, List<Map<String, dynamic>>>>((ref) {
  return ItemsNotifier();
});
