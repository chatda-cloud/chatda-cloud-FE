import 'package:flutter_riverpod/flutter_riverpod.dart';

// 임시 시작 데이터
final _initialLostItems = [
  {
    'id': 1, 'title': '검정색 가죽 지갑', 'desc': '신분증과 카드가 들어있는 검정색 지갑입니다.',
    'location': '강남역 2번 출구', 'date': '2026년 03월 20일', 'tags': ['지갑', '가죽', '검정색', '+1']
  },
  {
    'id': 2, 'title': 'iPhone 15 Pro', 'desc': '티타늄 블루 색상의 아이폰 15 프로입니다.',
    'location': '홍대입구역 9번 출구', 'date': '2026년 03월 21일', 'tags': ['핸드폰', '스마트폰', 'iPhone', '+1']
  },
  {
    'id': 3, 'title': '무선 이어폰', 'desc': '에어팟 프로 2세대입니다.',
    'location': '스타벅스 강남점', 'date': '2026년 03월 19일', 'tags': ['이어폰', '무선', '흰색', '+2']
  },
];

final _initialFoundItems = [
  {
    'id': 4, 'title': '가죽 지갑', 'desc': '검정색 가죽 지갑을 주웠습니다.',
    'location': '강남역 3번 출구', 'date': '2026년 03월 20일', 'tags': ['지갑', '가죽', '검정색', '+1']
  },
  {
    'id': 5, 'title': '스마트폰', 'desc': '아이폰으로 보이는 스마트폰을 발견했습니다.',
    'location': '홍대입구역 근처 카페', 'date': '2026년 03월 21일', 'tags': ['핸드폰', '스마트폰', 'iPhone', '+1']
  },
  {
    'id': 6, 'title': '파란색 백팩', 'desc': '노스페이스 파란색 백팩',
    'location': '신촌역 1번 출구', 'date': '2026년 03월 22일', 'tags': ['가방', '백팩', '파란색', '+1']
  },
];

class ItemsNotifier extends StateNotifier<Map<String, List<Map<String, dynamic>>>> {
  ItemsNotifier() : super({'lost': _initialLostItems, 'found': _initialFoundItems});

  void addLostItem(Map<String, dynamic> item) {
    final newItem = Map<String, dynamic>.from(item);
    newItem['id'] = DateTime.now().millisecondsSinceEpoch;
    state = {
      ...state,
      'lost': [newItem, ...state['lost']!],
    };
  }

  void addFoundItem(Map<String, dynamic> item) {
    final newItem = Map<String, dynamic>.from(item);
    newItem['id'] = DateTime.now().millisecondsSinceEpoch;
    state = {
      ...state,
      'found': [newItem, ...state['found']!],
    };
  }

  void removeLostItem(int id) {
    state = {
      ...state,
      'lost': state['lost']!.where((item) => item['id'] != id).toList(),
    };
  }

  void removeFoundItem(int id) {
    state = {
      ...state,
      'found': state['found']!.where((item) => item['id'] != id).toList(),
    };
  }

  void updateLostItem(int id, Map<String, dynamic> updatedData) {
    state = {
      ...state,
      'lost': state['lost']!.map((item) => item['id'] == id ? { ...item, ...updatedData } : item).toList(),
    };
  }

  void updateFoundItem(int id, Map<String, dynamic> updatedData) {
    state = {
      ...state,
      'found': state['found']!.map((item) => item['id'] == id ? { ...item, ...updatedData } : item).toList(),
    };
  }
}

final itemsProvider = StateNotifierProvider<ItemsNotifier, Map<String, List<Map<String, dynamic>>>>((ref) {
  return ItemsNotifier();
});
