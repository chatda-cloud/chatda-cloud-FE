import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/items_provider.dart';
import '../../widgets/chatda_dialog.dart';

class RegisterFoundItemScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? editItem;

  const RegisterFoundItemScreen({super.key, this.editItem});

  @override
  ConsumerState<RegisterFoundItemScreen> createState() => _RegisterFoundItemScreenState();
}

class _RegisterFoundItemScreenState extends ConsumerState<RegisterFoundItemScreen> {
  // 태그 관리: AI 추천 태그와 수동 태그를 구분하여 관리
  final _aiTags = <String>[];
  final _manualTags = <String>[];
  final _tagController = TextEditingController();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _locationController = TextEditingController();
  final _dateController = TextEditingController(text: '2026년 04월 05일');
  DateTime? _selectedDate;
  bool _showManualTagInput = false; // 연필 아이콘 토글 상태
  bool _hasUploadedImage = false; // 사진 업로드 여부

  bool get _isEditMode => widget.editItem != null;

  @override
  void initState() {
    super.initState();
    if (_isEditMode) {
      final item = widget.editItem!;
      _titleController.text = item['title'] as String? ?? '';
      _descController.text = item['desc'] as String? ?? '';
      _locationController.text = item['location'] as String? ?? '';
      final existingTags = item['tags'] as List<String>?;
      if (existingTags != null) {
        _manualTags.addAll(existingTags);
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = '${picked.year}년 ${picked.month.toString().padLeft(2, '0')}월 ${picked.day.toString().padLeft(2, '0')}일';
      });
    }
  }

  void _addTag() {
    if (_tagController.text.trim().isNotEmpty) {
      setState(() {
        _manualTags.add(_tagController.text.trim());
        _tagController.clear();
      });
    }
  }

  /// 사진 업로드 후 AI 태그 시뮬레이션
  void _simulateAITags() {
    setState(() {
      _hasUploadedImage = true;
      _aiTags.clear();
      _aiTags.addAll(['지갑', '갈색', '명품']); // AI 분석 결과 시뮬레이션
    });
  }

  void _showImagePickerModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('카메라로 촬영하기'),
                onTap: () {
                  // TODO: image_picker 연동
                  Navigator.pop(context);
                  _simulateAITags();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('갤러리에서 선택하기'),
                onTap: () {
                  // TODO: image_picker 연동
                  Navigator.pop(context);
                  _simulateAITags();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSuccessDialog(String message) {
    ChatdaDialog.showSuccess(
      context: context,
      message: message,
      onConfirm: () => Navigator.pop(context),
    );
  }

  void _onSubmit() {
    if (_titleController.text.trim().isEmpty) return;

    final allTags = [..._aiTags, ..._manualTags];

    if (_isEditMode) {
      ref.read(itemsProvider.notifier).updateFoundItem(
        widget.editItem!['id'] as int,
        {
          'title': _titleController.text.trim(),
          'desc': _descController.text.trim(),
          'location': _locationController.text.trim().isEmpty ? '알 수 없음' : _locationController.text.trim(),
          'tags': allTags.isEmpty ? ['습득물'] : List<String>.from(allTags),
        },
      );
      _showSuccessDialog('습득물 정보가 수정되었습니다.');
    } else {
      ref.read(itemsProvider.notifier).addFoundItem({
        'title': _titleController.text.trim(),
        'desc': _descController.text.trim(),
        'location': _locationController.text.trim().isEmpty ? '알 수 없음' : _locationController.text.trim(),
        'date': _dateController.text,
        'tags': allTags.isEmpty ? ['습득물'] : List<String>.from(allTags),
      });
      _showSuccessDialog('습득물이 등록되었습니다.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? '습득물 수정' : '습득물 등록'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildLabel('사진 업로드 (AI 자동 분석)'),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _showImagePickerModal,
                child: Container(
                  height: 180,
                  decoration: BoxDecoration(
                    color: _hasUploadedImage ? const Color(0xFFE8F5E9) : const Color(0xFFEEEEEE),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: _hasUploadedImage
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_outline, size: 48, color: Colors.green.shade400),
                          const SizedBox(height: 12),
                          Text('사진 업로드 완료', style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 4),
                          Text('탭하여 다시 선택', style: TextStyle(color: Colors.green.shade400, fontSize: 13)),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt_outlined, size: 48, color: Colors.grey.shade500),
                          const SizedBox(height: 12),
                          Text('사진 업로드', style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 4),
                          Text('AI 자동으로 특징을 분석합니다.', style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                        ],
                      ),
                ),
              ),
              const SizedBox(height: 24),

              // 통합 태그 영역
              Row(
                children: [
                  const Text('태그', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  // 연필 아이콘: 수동 태그 입력 토글
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _showManualTagInput = !_showManualTagInput;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: _showManualTagInput ? const Color(0xFF2563EB).withOpacity(0.1) : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.edit_outlined,
                        color: _showManualTagInput ? const Color(0xFF2563EB) : Colors.grey.shade600,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // AI 태그 + 수동 태그를 함께 표시
                    if (_aiTags.isEmpty && _manualTags.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          _hasUploadedImage ? 'AI 분석 중...' : '사진을 업로드하면 AI가 자동으로 태그를 추천합니다.',
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                        ),
                      ),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        // AI 추천 태그 (보라색 계열 + ✨)
                        ..._aiTags.map((tag) => _TagChipWidget(
                          label: tag,
                          isAI: true,
                          onDelete: () {
                            setState(() => _aiTags.remove(tag));
                          },
                        )),
                        // 수동 추가 태그 (파란색 계열 + 🏷️)
                        ..._manualTags.map((tag) => _TagChipWidget(
                          label: tag,
                          isAI: false,
                          onDelete: () {
                            setState(() => _manualTags.remove(tag));
                          },
                        )),
                      ],
                    ),
                    // 수동 태그 입력 필드 (연필 토글 또는 사진 미업로드 시 기본 표시)
                    if (_showManualTagInput || !_hasUploadedImage) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _tagController,
                              decoration: InputDecoration(
                                hintText: '태그 입력 후 추가',
                                prefixIcon: Icon(Icons.local_offer_outlined, color: Colors.grey.shade400),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              ),
                              onSubmitted: (_) => _addTag(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              onPressed: _addTag,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6B8EFF),
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                              ),
                              child: const Text('추가'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),

              _buildLabel('물건 이름', required: true),
              const SizedBox(height: 8),
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(hintText: '예: 검정색 지갑'),
              ),
              const SizedBox(height: 24),

              // 상세 설명 + 특징 통합
              _buildLabel('상세 설명'),
              const SizedBox(height: 8),
              TextField(
                controller: _descController,
                maxLines: 5,
                decoration: const InputDecoration(hintText: '물건의 특징과 상세 설명을 입력하세요\n(색상, 크기, 브랜드 등)'),
              ),
              const SizedBox(height: 24),

              _buildLabel('습득 위치', required: true),
              const SizedBox(height: 8),
              TextField(
                controller: _locationController,
                decoration: const InputDecoration(
                  hintText: '예: 강남역 2번 출구',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
              ),
              const SizedBox(height: 24),

              _buildLabel('습득 날짜', required: true),
              const SizedBox(height: 8),
              TextField(
                readOnly: true,
                controller: _dateController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.calendar_today_outlined),
                  suffixIcon: Icon(Icons.arrow_drop_down),
                ),
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 24),

              _buildLabel('보관 장소', required: true),
              const SizedBox(height: 8),
              const TextField(
                decoration: InputDecoration(
                  hintText: '예: 강남역 분실물센터',
                  prefixIcon: Icon(Icons.inventory_2_outlined),
                ),
              ),
              const SizedBox(height: 24),

              _buildLabel('연락 방법', required: true),
              const SizedBox(height: 8),
              const TextField(
                decoration: InputDecoration(
                  hintText: '예: 전화 또는 문자',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
              ),
              const SizedBox(height: 40),

              ElevatedButton(
                onPressed: _onSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6B8EFF),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                ),
                child: Text(_isEditMode ? '수정하기' : '등록하기', style: const TextStyle(fontSize: 18)),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, {bool required = false}) {
    return RichText(
      text: TextSpan(
        text: text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
        children: [
          if (required)
            const TextSpan(text: ' *', style: TextStyle(color: Colors.redAccent)),
        ],
      ),
    );
  }
}

/// AI 추천 태그와 수동 태그를 시각적으로 구분하는 통합 칩 위젯
class _TagChipWidget extends StatelessWidget {
  final String label;
  final bool isAI;
  final VoidCallback onDelete;

  const _TagChipWidget({
    required this.label,
    required this.isAI,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // AI 태그: 연보라 배경 + ✨ 아이콘 + 보라 텍스트
    // 수동 태그: 연파랑 배경 + 태그 아이콘 + 블루 텍스트
    final bgColor = isAI ? const Color(0xFFF3E8FF) : const Color(0xFFE0F2FE);
    final iconColor = isAI ? const Color(0xFF7C3AED) : const Color(0xFF2563EB);
    final textColor = isAI ? const Color(0xFF7C3AED) : const Color(0xFF2563EB);
    final borderColor = isAI ? const Color(0xFFE9D5FF) : const Color(0xFFBAE6FD);
    final icon = isAI ? Icons.auto_awesome : Icons.local_offer;

    return Container(
      padding: const EdgeInsets.only(left: 10, right: 4, top: 4, bottom: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: iconColor),
          const SizedBox(width: 4),
          Text(
            '#$label',
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 2),
          GestureDetector(
            onTap: onDelete,
            child: Icon(Icons.close, size: 16, color: textColor.withOpacity(0.6)),
          ),
        ],
      ),
    );
  }
}
