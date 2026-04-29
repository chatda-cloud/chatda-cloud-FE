import 'package:flutter/material.dart';
import '../../features/match/match_detail_screen.dart';

class LostItemCard extends StatelessWidget {
  final String title;
  final String desc;
  final String location;
  final String date;
  final String time;
  final List<String> tags;
  final int matchPercent;

  const LostItemCard({
    super.key,
    required this.title,
    required this.desc,
    required this.location,
    required this.date,
    required this.time,
    required this.tags,
    this.matchPercent = 0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MatchDetailScreen(
            myItemTitle: '등록된 내 분실물',
            counterpartTitle: title,
            similarityScore: matchPercent / 100.0,
          ),
        ),
      ),
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 사진이 들어갈 영역 확보 (분실물 - 가로 세로 80 고정)
              Container(
                width: 90,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Icon(Icons.image_outlined, color: Colors.grey.shade400, size: 32),
              ),
              const SizedBox(width: 16),
              // 내용 영역
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis)),
                        Text(time, style: TextStyle(color: Colors.grey.shade400, fontSize: 11)),
                        if (matchPercent > 0) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: Colors.blue.shade100, borderRadius: BorderRadius.circular(12)),
                            child: Text('$matchPercent%', style: TextStyle(color: Colors.blue.shade800, fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                        ]
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(desc, style: TextStyle(color: Colors.grey.shade700, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 8),
                    _IconText(icon: Icons.location_on_outlined, text: location),
                    const SizedBox(height: 4),
                    _IconText(icon: Icons.calendar_today_outlined, text: date),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.local_offer_outlined, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            children: tags.map((t) => _Tag(text: t)).toList(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text('분실물', style: TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold)),
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

class FoundItemCard extends StatelessWidget {
  final String title;
  final String desc;
  final String location;
  final String date;
  final String time;
  final List<String> tags;

  const FoundItemCard({
    super.key,
    required this.title,
    required this.desc,
    required this.location,
    required this.date,
    required this.time,
    required this.tags,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MatchDetailScreen(
            myItemTitle: '등록된 내 분실물',
            counterpartTitle: title,
            similarityScore: 0.85,
          ),
        ),
      ),
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               // 사진 영역 확보
               Container(
                width: 90,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Icon(Icons.image_outlined, color: Colors.grey.shade400, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis)),
                        Text(time, style: TextStyle(color: Colors.grey.shade400, fontSize: 11)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(desc, style: TextStyle(color: Colors.grey.shade700, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 8),
                    _IconText(icon: Icons.location_on_outlined, text: location),
                    const SizedBox(height: 4),
                    _IconText(icon: Icons.calendar_today_outlined, text: date),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.local_offer_outlined, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            children: tags.map((t) => _Tag(text: t)).toList(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text('습득물', style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
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

class ItemGridCard extends StatelessWidget {
  final Map<String, dynamic> item;

  const ItemGridCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final isLost = item['type'] == 'lost';
    final match = item['match'] as int;

    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => MatchDetailScreen(
          myItemTitle: '내 등록 물건',
          counterpartTitle: item['title'],
          similarityScore: (match > 0 ? match : 85) / 100.0,
        )));
      },
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias, // 사진이 카드의 둥근 모서리에 맞춰지도록
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 그리드 뷰 상단의 사진 영역 (사진 위주이므로 비율을 더 높게)
            Expanded(
              flex: 4,
              child: Container(
                color: Colors.grey.shade200,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Icon(Icons.image_outlined, color: Colors.grey.shade400, size: 40),
                    // 사진 공간에 들어갈 내용이 있을 경우 여기에 Image.network 추가
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: isLost ? Colors.red.shade50 : Colors.green.shade50, borderRadius: BorderRadius.circular(4)),
                        child: Text(isLost ? '분실' : '습득', style: TextStyle(color: isLost ? Colors.redAccent : Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    if (match > 0)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                           padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                           decoration: BoxDecoration(color: Colors.blue.withOpacity(0.8), borderRadius: BorderRadius.circular(4)),
                           child: Text('$match% 일치', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // 하단 텍스트 정보 영역
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text(item['desc'], style: TextStyle(color: Colors.grey.shade600, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const Spacer(),
                    if (item['tags'] != null && (item['tags'] as List).isNotEmpty) ...[
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: (item['tags'] as List).take(2).map((t) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(4)),
                          child: Text('#$t', style: TextStyle(color: Colors.grey.shade700, fontSize: 9)),
                        )).toList(),
                      ),
                      const SizedBox(height: 4),
                    ],
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 12, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(child: Text(item['loc'], style: TextStyle(color: Colors.grey.shade600, fontSize: 10), maxLines: 1, overflow: TextOverflow.ellipsis)),
                        Text(item['time'] ?? '', style: TextStyle(color: Colors.grey.shade400, fontSize: 9)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Private Helper Widgets
class _IconText extends StatelessWidget {
  final IconData icon;
  final String text;

  const _IconText({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade600),
        const SizedBox(width: 6),
        Text(text, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
      ],
    );
  }
}

class _Tag extends StatelessWidget {
  final String text;

  const _Tag({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(text, style: TextStyle(color: Colors.grey.shade700, fontSize: 11)),
    );
  }
}
