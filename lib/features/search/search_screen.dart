import 'package:flutter/material.dart';
import '../match/match_detail_screen.dart';
import '../../common/widgets/item_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  int _selectedTab = 0; // 0: 전체, 1: 분실물, 2: 습득물
  bool _isGrid = true; // 피드백에 따라 습득물 위주의 그리드 뷰를 기본으로 설정

  final List<String> _popularTags = ['가방', '스마트폰', '지갑', '이어폰', '카드/신분증', '우산', '의류'];
  String _selectedTag = '';
  String _searchQuery = '';
  String _filterCategory = ''; // 검색 필터의 카테고리 상태 추가

  void _showFilterSheet() {
    String tempCategory = _filterCategory;
    DateTime? tempStartDate;
    DateTime? tempEndDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          return Container(
            padding: EdgeInsets.only(
              left: 20, right: 20, top: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('검색 필터', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    TextButton(
                      // 초기화 기능 구현
                      onPressed: () {
                        setSheetState(() {
                          tempCategory = '';
                          tempStartDate = null;
                          tempEndDate = null;
                        });
                      },
                      child: const Text('초기화', style: TextStyle(color: Colors.grey)),
                    )
                  ],
                ),
                const SizedBox(height: 12),
                const Text('카테고리', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: ['전자기기', '지갑', '가방', '기타'].map((c) => FilterChip(
                    label: Text(c),
                    selected: tempCategory == c,
                    selectedColor: Colors.blue.shade100,
                    checkmarkColor: Colors.blue.shade700,
                    onSelected: (selected) {
                      setSheetState(() {
                        tempCategory = selected ? c : '';
                      });
                    },
                  )).toList(),
                ),
                const SizedBox(height: 16),
                const Text('기간', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final date = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime.now());
                          if (date != null) setSheetState(() => tempStartDate = date);
                        }, 
                        icon: const Icon(Icons.calendar_today, size: 16), 
                        label: Text(tempStartDate != null ? '${tempStartDate!.month}.${tempStartDate!.day}' : '시작일'),
                      )
                    ),
                    const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('~')),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final date = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime.now());
                          if (date != null) setSheetState(() => tempEndDate = date);
                        }, 
                        icon: const Icon(Icons.calendar_today, size: 16), 
                        label: Text(tempEndDate != null ? '${tempEndDate!.month}.${tempEndDate!.day}' : '종료일'),
                      )
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('지역/장소', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const TextField(
                  decoration: InputDecoration(
                    hintText: '장소 검색 (예: 강남역)',
                    prefixIcon: Icon(Icons.location_on_outlined),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Navigator.pop(context); // 시트 닫기
                    setState(() {
                      _filterCategory = tempCategory; // 필터 상태 업데이트
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('필터가 적용되었습니다.')),
                    );
                  },
                  child: const Text('적용하기', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          );
        }
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('탐색', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: false,
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isGrid ? Icons.view_list_rounded : Icons.grid_view_rounded),
            onPressed: () => setState(() => _isGrid = !_isGrid),
            tooltip: '보기 방식 변경',
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterSheet,
            tooltip: '필터',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 검색바 및 추천 태그, 탭 컨트롤
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    onChanged: (val) => setState(() => _searchQuery = val),
                    decoration: InputDecoration(
                      hintText: '물건 이름, 설명, 태그로 검색...',
                      prefixIcon: const Icon(Icons.search),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // 추천 태그 영역
                  SizedBox(
                    height: 32,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _popularTags.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final tag = _popularTags[index];
                        final isSelected = _selectedTag == tag;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedTag = isSelected ? '' : tag;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.blue.shade600 : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              '#$tag',
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.grey.shade700,
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSegmentedControl(),
                ],
              ),
            ),
            
            // 리스트/그리드 영역
            Expanded(
              child: _buildItemList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemList() {
    // 임시 데이터. 다양한 태그 포함
    final List<Map<String, dynamic>> allItems = [];
    if (_selectedTab == 0 || _selectedTab == 1) {
      allItems.add({'type': 'lost', 'title': '검정색 가죽 지갑', 'desc': '신분증과 카드가 들어있습니다.', 'loc': '강남역 2번 출구', 'date': '03.20', 'time': '10분 전', 'tags': ['지갑', '카드/신분증'], 'match': 100});
      allItems.add({'type': 'lost', 'title': 'iPhone 15 Pro', 'desc': '티타늄 블루', 'loc': '홍대입구역', 'date': '03.21', 'time': '1시간 전', 'tags': ['스마트폰'], 'match': 95});
      allItems.add({'type': 'lost', 'title': '무선 이어폰', 'desc': '에어팟 2세대', 'loc': '강남역', 'date': '03.19', 'time': '2시간 전', 'tags': ['이어폰'], 'match': 0});
      allItems.add({'type': 'lost', 'title': '나이키 맨투맨', 'desc': '파란색 L사이즈', 'loc': '신도림역', 'date': '03.22', 'time': '1일 전', 'tags': ['의류'], 'match': 0});
      allItems.add({'type': 'lost', 'title': '갈색 백팩', 'desc': '노트북이 들어있어요', 'loc': '서울역', 'date': '03.18', 'time': '2일 전', 'tags': ['가방'], 'match': 0});
    }
    if (_selectedTab == 0 || _selectedTab == 2) {
      allItems.add({'type': 'found', 'title': '가죽 지갑', 'desc': '가죽 지갑 주웠습니다.', 'loc': '강남역 3번 출구', 'date': '03.20', 'time': '5분 전', 'tags': ['지갑'], 'match': 0});
      allItems.add({'type': 'found', 'title': '스마트폰', 'desc': '화면 금간 아이폰', 'loc': '홍대입구역', 'date': '03.21', 'time': '1시간 전', 'tags': ['스마트폰'], 'match': 0});
      allItems.add({'type': 'found', 'title': '투명 우산', 'desc': '편의점 우산', 'loc': '사당역', 'date': '03.22', 'time': '3시간 전', 'tags': ['우산'], 'match': 0});
      allItems.add({'type': 'found', 'title': '학생증 카드', 'desc': '한국대 학생증 잃어버리신분', 'loc': '강남역 버스정류장', 'date': '03.23', 'time': '1일 전', 'tags': ['카드/신분증'], 'match': 0});
      allItems.add({'type': 'found', 'title': '소니 노이즈캔슬링', 'desc': '헤드폰 습득', 'loc': '신촌역', 'date': '03.24', 'time': '3일 전', 'tags': ['이어폰'], 'match': 0});
    }

    // 태그 필터링
    List<Map<String, dynamic>> items = allItems;
    if (_selectedTag.isNotEmpty) {
      items = items.where((item) => (item['tags'] as List).contains(_selectedTag)).toList();
    }
    
    // 텍스트 검색 필터링
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.trim().toLowerCase();
      items = items.where((item) {
        final titleMatch = (item['title'] as String).toLowerCase().contains(q);
        final descMatch = (item['desc'] as String).toLowerCase().contains(q);
        return titleMatch || descMatch;
      }).toList();
    }
    
    // 상세 카테고리 필터링
    if (_filterCategory.isNotEmpty) {
      items = items.where((item) {
        if (_filterCategory == '전자기기') {
          return (item['tags'] as List).contains('스마트폰') || (item['tags'] as List).contains('이어폰');
        } else if (_filterCategory == '지갑') {
          return (item['tags'] as List).contains('지갑');
        } else if (_filterCategory == '가방') {
          return (item['tags'] as List).contains('가방');
        } else if (_filterCategory == '기타') {
          return !(item['tags'] as List).any((t) => ['스마트폰', '이어폰', '지갑', '가방'].contains(t));
        }
        return true;
      }).toList();
    }

    if (items.isEmpty) return const Center(child: Text('해당 조건의 물건이 없습니다.', style: TextStyle(color: Colors.grey)));

    if (_isGrid) {
      return GridView.builder(
        padding: const EdgeInsets.all(16.0),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 220, // 카드의 최대 가로 크기를 제한하여 넓은 화면에서 늘어짐 방지
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.75, // 가로세로 비율 유지
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return ItemGridCard(item: item);
        },
      );
    } else {
      return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          if (item['type'] == 'lost') {
            return LostItemCard(
              title: item['title'], desc: item['desc'], location: item['loc'], 
              date: item['date'], time: item['time'], tags: List<String>.from(item['tags']), matchPercent: item['match']
            );
          } else {
            return FoundItemCard(
              title: item['title'], desc: item['desc'], location: item['loc'], 
              date: item['date'], time: item['time'], tags: List<String>.from(item['tags'])
            );
          }
        },
      );
    }
  }

  // --- 기존 세그먼트 UI 재활용 ---
  Widget _buildSegmentedControl() {
    return Container(
      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _buildTabButton(0, '전체'),
          _buildTabButton(1, '분실물'),
          _buildTabButton(2, '습득물'),
        ],
      ),
    );
  }

  Widget _buildTabButton(int index, String title) {
    final isSelected = _selectedTab == index;
    Color getSelectedColor() {
      if (index == 1) return Colors.redAccent;
      if (index == 2) return Colors.green;
      return Theme.of(context).primaryColor;
    }

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTab = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? getSelectedColor() : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            boxShadow: isSelected ? [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))] : null,
          ),
          alignment: Alignment.center,
          child: Text(title, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? Colors.white : Colors.grey.shade600)),
        ),
      ),
    );
  }
}
