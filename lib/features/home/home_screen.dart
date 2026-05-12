import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/user_service.dart';
import '../match/match_detail_screen.dart';
import '../notification/notification_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final VoidCallback onNavigateToRegisterLost;
  final VoidCallback onNavigateToRegisterFound;

  const HomeScreen({
    super.key,
    required this.onNavigateToRegisterLost,
    required this.onNavigateToRegisterFound,
  });

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _isExpanded = false;
  List<Map<String, dynamic>> _matches = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMatches();
  }

  Future<void> _loadMatches() async {
    try {
      final userService = UserService();
      final matchData = await userService.getMyMatches();
      if (mounted) {
        setState(() {
          _matches = matchData.map((e) => Map<String, dynamic>.from(e as Map)).toList();
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/home.png', width: 40, height: 40, fit: BoxFit.contain),
            const SizedBox(width: 8),
            const Text('Chatda', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
          ],
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, size: 28),
            onPressed: () {
              Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(builder: (_) => const NotificationScreen()));
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        bottom: false, // 하단 바 뒤로 컨텐츠가 스크롤되도록 하단 안전 영역 제거
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: const Row(
                children: [
                  Icon(Icons.auto_awesome, color: Colors.blue),
                  SizedBox(width: 8),
                  Text('나의 매칭 추천 현황', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _matches.isEmpty
                      ? const Center(child: Text('추천되는 매칭이 없습니다.', style: TextStyle(color: Colors.grey)))
                      : ListView(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                          children: [
                            ..._buildMatchCards(),
                            if (_matches.length > 5) // 5개 이상일 경우 더보기 제공 (필요시)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0, bottom: 24.0),
                                child: OutlinedButton(
                                  onPressed: () {
                                    setState(() {
                                      _isExpanded = !_isExpanded;
                                    });
                                  },
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    side: BorderSide(color: Colors.grey.shade300),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(_isExpanded ? '접기' : '더보기', style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.bold)),
                                      Icon(_isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: Colors.grey.shade700),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildMatchCards() {
    // 0.7 이상 필터링 및 내림차순 정렬
    final filtered = _matches.where((m) {
      final score = (m['similarity_score'] as num?)?.toDouble() ?? 0.0;
      return score >= 0.7;
    }).toList();

    filtered.sort((a, b) {
      final sa = (a['similarity_score'] as num?)?.toDouble() ?? 0.0;
      final sb = (b['similarity_score'] as num?)?.toDouble() ?? 0.0;
      return sb.compareTo(sa);
    });

    final displayList = _isExpanded ? filtered : filtered.take(5).toList();

    return displayList.map((match) {
      final matchId = match['id'] as int? ?? 0;
      final score = (match['similarity_score'] as num?)?.toDouble() ?? 0.0;
      final percent = (score * 100).toInt();
      final myTitle = match['lost_item_title'] ?? '내 분실물';
      final cpTitle = match['found_item_title'] ?? '유사 습득물';
      final isConfirmed = match['is_confirmed'] == true;

      return _buildVerticalMatchCard(
        title: cpTitle,
        desc: '등록하신 정보와 일치하는 습득물이 있습니다.',
        location: match['found_item_location'] ?? '알 수 없음',
        time: match['created_at'] != null ? match['created_at'].toString().split('T').first : '최근',
        matchPercent: percent,
        onTap: () => Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(builder: (_) => MatchDetailScreen(
          matchId: matchId,
          isAlreadyMatched: isConfirmed,
          myItemTitle: myTitle,
          counterpartTitle: cpTitle,
          similarityScore: score,
        ))),
      );
    }).toList();
  }

  Widget _buildVerticalMatchCard({
    required String title,
    required String desc,
    required String location,
    required String time,
    required int matchPercent,
    required VoidCallback onTap,
  }) {
    final bool isHighMatch = matchPercent >= 80;
    final Color badgeColor = isHighMatch ? Colors.blue.shade600 : Colors.orange.shade600;

    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        color: Colors.white,
        elevation: 2,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(child: Icon(Icons.image_outlined, color: Colors.grey.shade400, size: 32)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: badgeColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                          child: Text('$matchPercent% 일치', style: TextStyle(color: badgeColor, fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(desc, style: TextStyle(color: Colors.grey.shade700, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.location_on, size: 14, color: Colors.grey.shade500),
                            const SizedBox(width: 4),
                            Text(location, style: TextStyle(color: Colors.grey.shade600, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                          ],
                        ),
                        Text(time, style: TextStyle(color: Colors.grey.shade400, fontSize: 11)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
