import 'package:flutter/material.dart';
import '../match/match_detail_screen.dart';
import '../notification/notification_screen.dart';
import '../main/main_screen.dart';
import '../search/search_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onNavigateToRegisterLost;
  final VoidCallback onNavigateToRegisterFound;

  const HomeScreen({
    super.key,
    required this.onNavigateToRegisterLost,
    required this.onNavigateToRegisterFound,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Chatda', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, size: 28),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationScreen()));
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
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
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildVerticalMatchCard(
                    title: '검정색 가죽 지갑',
                    desc: '습득된 검정색 가죽 지갑과 매우 유사합니다.',
                    location: '강남역 2번 출구',
                    matchPercent: 100,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MatchDetailScreen(
                      myItemTitle: '내 검정색 지갑', counterpartTitle: '습득된 검정색 가죽 지갑', similarityScore: 1.0, myTags: ['지갑', '가죽'], counterpartTags: ['지갑'],
                    ))),
                  ),
                  _buildVerticalMatchCard(
                    title: 'iPhone 15 Pro',
                    desc: '등록하신 폰 정보와 일치하는 습득물이 있습니다.',
                    location: '홍대입구역 9번 출구',
                    matchPercent: 95,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MatchDetailScreen(
                      myItemTitle: 'iPhone 15 Pro', counterpartTitle: '스마트폰', similarityScore: 0.95, myTags: ['폰', '애플'], counterpartTags: ['스마트폰'],
                    ))),
                  ),
                  _buildVerticalMatchCard(
                    title: '에어팟 3세대',
                    desc: '신촌역에서 습득된 무선 이어폰과 유사합니다.',
                    location: '신촌역',
                    matchPercent: 80,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MatchDetailScreen(
                      myItemTitle: '에어팟', counterpartTitle: '무선 이어폰', similarityScore: 0.8,
                    ))),
                  ),
                  _buildVerticalMatchCard(title: '파란색 우산', desc: '비슷한 파란색 우산이 서울역 분실물 센터에 보관 중입니다.', location: '서울역', matchPercent: 75, onTap: (){}),
                  _buildVerticalMatchCard(title: '갈색 크로스백', desc: '색상이 일치하는 가방이 습득되었습니다.', location: '여의도', matchPercent: 60, onTap: (){}),
                  
                  if (_isExpanded) ...[
                    _buildVerticalMatchCard(title: '검정 뿔테 안경', desc: '도서관에서 습득된 안경과 특징이 유사합니다.', location: '시립도서관', matchPercent: 55, onTap: (){}),
                    _buildVerticalMatchCard(title: '샤오미 보조배터리', desc: '버스에서 분실된 물품과 동일한 모델입니다.', location: '버스 분실물센터', matchPercent: 50, onTap: (){}),
                    _buildVerticalMatchCard(title: '회색 니트 목도리', desc: '카페에 보관 중인 목도리와 색상이 같습니다.', location: '스타벅스 강남본점', matchPercent: 40, onTap: (){}),
                  ],
                  
                  // 더보기 / 접기 버튼을 카드 리스트 맨 밑으로 이동
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

  Widget _buildVerticalMatchCard({
    required String title,
    required String desc,
    required String location,
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
                      children: [
                        Icon(Icons.location_on, size: 14, color: Colors.grey.shade500),
                        const SizedBox(width: 4),
                        Expanded(child: Text(location, style: TextStyle(color: Colors.grey.shade600, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis)),
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
