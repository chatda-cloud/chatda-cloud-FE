import 'package:flutter/material.dart';

class MatchDetailScreen extends StatefulWidget {
  final String myItemTitle;
  final String counterpartTitle;
  final double similarityScore;
  final List<String> myTags;
  final List<String> counterpartTags;

  const MatchDetailScreen({
    super.key,
    required this.myItemTitle,
    required this.counterpartTitle,
    required this.similarityScore,
    this.myTags = const [],
    this.counterpartTags = const [],
  });

  @override
  State<MatchDetailScreen> createState() => _MatchDetailScreenState();
}

class _MatchDetailScreenState extends State<MatchDetailScreen> {
  bool _isMatched = false; // "내 물건이 맞습니다" 확정 여부

  @override
  Widget build(BuildContext context) {
    final int scorePercent = (widget.similarityScore * 100).toInt();
    final bool isHighMatch = widget.similarityScore >= 0.7;

    return Scaffold(
      appBar: AppBar(
        title: const Text('매칭 상세 분석'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 유사도 스코어 박스
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isHighMatch
                        ? [Colors.blue.shade600, Colors.blue.shade800]
                        : [Colors.orange.shade400, Colors.orange.shade600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6)),
                  ],
                ),
                child: Column(
                  children: [
                    const Text('AI가 분석한 일치 확률', style: TextStyle(color: Colors.white70, fontSize: 14)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('$scorePercent', style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold, height: 1)),
                        const Padding(
                          padding: EdgeInsets.only(bottom: 6.0),
                          child: Text('%', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: widget.similarityScore,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      valueColor: const AlwaysStoppedAnimation(Colors.white),
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // 비교 카드
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildComparisonCard('내 분실물', widget.myItemTitle, '강남역 2번 출구', '2026-03-20', Colors.redAccent, widget.myTags),
                  const SizedBox(height: 16),
                  _buildComparisonCard('습득물', widget.counterpartTitle, '강남역 3번 출구', '2026-03-20', Colors.green, widget.counterpartTags),
                ],
              ),
              const SizedBox(height: 32),

              if (!_isMatched) ...[
                const Text('태그 및 특징을 비교해보고 본인의 물건이 맞다면 아래 버튼을 눌러주세요. 상대방의 연락처와 보관장소가 공개됩니다.',
                  style: TextStyle(color: Colors.black54, fontSize: 14, height: 1.4),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() => _isMatched = true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                  ),
                  child: const Text('네, 제 물건이 맞습니다', style: TextStyle(fontSize: 16)),
                ),
              ] else ...[
                // 매칭 완료 및 정보 공개 뷰
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.green.shade200, width: 1.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green.shade600),
                          const SizedBox(width: 8),
                          Text('MATCHED! 정보 공개', style: TextStyle(color: Colors.green.shade800, fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),
                      _buildInfoRow(Icons.inventory_2_outlined, '보관 장소', '강남역 분실물센터 (지하 1층)'),
                      const SizedBox(height: 16),
                      _buildInfoRow(Icons.phone_outlined, '연락처', '010-9876-5432 (습득자)'),
                      const SizedBox(height: 8),
                      const Text('* 습득자에게 연락하여 물건을 수령해 주세요.', style: TextStyle(color: Colors.black54, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildComparisonCard(String type, String title, String loc, String date, Color color, List<String> tags) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(type, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Icon(Icons.image_outlined, color: Colors.grey.shade400, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined, size: 14, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Expanded(child: Text(loc, style: TextStyle(color: Colors.grey.shade600, fontSize: 12))),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Expanded(child: Text(date, style: TextStyle(color: Colors.grey.shade600, fontSize: 12))),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (tags.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: tags.map((t) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(t, style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
              )).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.grey.shade700, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }
}
