import 'package:flutter/material.dart';
import '../../widgets/chatda_dialog.dart';
import '../../services/match_service.dart';

class MatchDetailScreen extends StatefulWidget {
  final int matchId;
  final bool isAlreadyMatched;
  final String myItemTitle;
  final String counterpartTitle;
  final double similarityScore;
  final List<String> myTags;
  final List<String> counterpartTags;

  const MatchDetailScreen({
    super.key,
    this.matchId = 0,
    this.isAlreadyMatched = false,
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
  late bool _isMatched;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isMatched = widget.isAlreadyMatched;
  }

  Future<void> _handleConfirmMatch() async {
    if (widget.matchId == 0) {
      _showMatchedDialog(); // mock fallback
      return;
    }
    setState(() => _isLoading = true);
    try {
      final service = MatchService();
      await service.confirmMatch(widget.matchId, isConfirmed: true);
      _showMatchedDialog();
    } catch (e) {
      if (mounted) {
        ChatdaDialog.showSuccess(context: context, title: '오류', message: '매칭 확인에 실패했습니다.');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showMatchedDialog() {
    setState(() {
      _isMatched = true;
    });

    ChatdaDialog.showInfo(
      context: context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF6B8EFF).withOpacity(0.15),
                      const Color(0xFFA5B4FC).withOpacity(0.15),
                    ],
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.check_circle_rounded, color: Color(0xFF6B8EFF), size: 44),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'MATCHED! 정보 공개',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF2563EB),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Divider(color: Colors.grey.shade200, thickness: 1),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.storefront_outlined, '보관 장소', '강남역 분실물센터 (지하 1층)'),
          const SizedBox(height: 20),
          _buildInfoRow(Icons.phone_in_talk_outlined, '연락처', '010-9876-5432 (습득자)'),
          const SizedBox(height: 20),
          Text(
            '*습득자에게 연락하여 물건을 수령해 주세요.',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () {
              Navigator.pop(context); // 팝업 닫기
              Navigator.pop(context); // 매칭 상세 화면 닫기 → 이전 화면(홈/탐색)으로 복귀
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6B8EFF), Color(0xFF818CF8)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6B8EFF).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  '확인 완료',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.black54, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.black54, fontSize: 13)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final int scorePercent = (widget.similarityScore * 100).toInt();

    return Scaffold(
      appBar: AppBar(
        title: const Text('매칭 상세 분석', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              
              // 유사도 원형 그래프
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 160,
                    height: 160,
                    child: CircularProgressIndicator(
                      value: widget.similarityScore,
                      strokeWidth: 16,
                      backgroundColor: Colors.blue.shade100,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade400),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text('$scorePercent', style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.black87)),
                          const Text('%', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.black54)),
                        ],
                      ),
                      const Text('유사도', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // 상세 비교 영역 (하얀색 박스)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // 좌우 비교 카드
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _buildItemColumn('내 분실물', widget.myItemTitle, '강남역 2번 출구', '2026-03-20')),
                        Container(width: 1, height: 160, color: Colors.grey.shade200),
                        Expanded(child: _buildItemColumn('습득물', widget.counterpartTitle, '강남역 2번 출구', '2026-03-20')),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Divider(thickness: 1, color: Colors.black12),
                    const SizedBox(height: 20),
                    
                    // 태그 목록
                    _buildTagRow('#지갑'),
                    const SizedBox(height: 12),
                    _buildTagRow('#검정색'),
                    const SizedBox(height: 12),
                    _buildTagRow('#강남역'),
                    const SizedBox(height: 12),
                    _buildTagRow('#공나도'),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // 하단 버튼
              ElevatedButton(
                onPressed: (_isMatched || _isLoading) ? null : _handleConfirmMatch,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9CA3AF), // 둥글고 넓은 회색빛 버튼
                  disabledBackgroundColor: Colors.grey.shade300,
                  minimumSize: const Size(double.infinity, 60),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  elevation: 0,
                ),
                child: _isLoading 
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text(
                      _isMatched ? '매칭 완료됨' : '네, 제 물건이 맞습니다',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
              ),
              if (!_isMatched) ...[
                const SizedBox(height: 12),
                const Text(
                  '버튼을 누르시면 상대방의 연락처가 공개 됩니다.',
                  style: TextStyle(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.w500),
                ),
              ],
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemColumn(String type, String title, String loc, String date) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          Text(type, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_on_outlined, size: 14, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Text(loc, style: TextStyle(fontSize: 12, color: Colors.grey.shade800)),
            ],
          ),
          const SizedBox(height: 4),
          Text(date, style: TextStyle(fontSize: 12, color: Colors.grey.shade800)),
        ],
      ),
    );
  }

  Widget _buildTagRow(String tag) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(tag, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
        ),
      ],
    );
  }
}
