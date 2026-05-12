import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/items_provider.dart';
import '../../services/upload_service.dart';
import '../../services/match_service.dart';
import '../../widgets/chatda_dialog.dart';

class RegisterLostItemScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? editItem;

  const RegisterLostItemScreen({super.key, this.editItem});

  @override
  ConsumerState<RegisterLostItemScreen> createState() => _RegisterLostItemScreenState();
}

class _RegisterLostItemScreenState extends ConsumerState<RegisterLostItemScreen> {
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
  bool _isUploading = false; // 업로드 진행 중
  bool _isSubmitting = false; // 등록 진행 중
  Uint8List? _imageBytes; // 선택된 이미지 데이터
  String? _imageFileName; // 선택된 이미지 파일명
  final UploadService _uploadService = UploadService();
  final ImagePicker _imagePicker = ImagePicker();

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

  /// image_picker로 실제 이미지 선택
  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _imagePicker.pickImage(source: source, maxWidth: 1920, imageQuality: 85);
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      setState(() {
        _imageBytes = bytes;
        _imageFileName = picked.name;
        _hasUploadedImage = true;
      });
    } catch (e) {
      if (!mounted) return;
      ChatdaDialog.showSuccess(
        context: context,
        title: '오류',
        message: '이미지를 선택할 수 없습니다.',
        buttonText: '확인',
      );
    }
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
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('갤러리에서 선택하기'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
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

  Future<void> _onSubmit() async {
    if (_titleController.text.trim().isEmpty) return;
    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);

    try {
      final allTags = [..._aiTags, ..._manualTags];
      final dateStr = _selectedDate?.toIso8601String() ?? DateTime.now().toIso8601String();

      if (_isEditMode) {
        final success = await ref.read(itemsProvider.notifier).updateLostItem(
          widget.editItem!['id'] as int,
          {
            'title': _titleController.text.trim(),
            'desc': _descController.text.trim(),
            'location': _locationController.text.trim().isEmpty ? '알 수 없음' : _locationController.text.trim(),
            'tags': allTags.isEmpty ? ['분실물'] : List<String>.from(allTags),
          },
        );
        if (success) {
          _showSuccessDialog('분실물 정보가 수정되었습니다.');
        } else {
          throw Exception('Update failed');
        }
      } else {
        // Step 1: 아이템 등록 (텍스트만)
        final itemId = await ref.read(itemsProvider.notifier).addLostItem({
          'title': _titleController.text.trim(),
          'item_name': _titleController.text.trim(),
          'desc': _descController.text.trim(),
          'raw_text': _descController.text.trim(),
          'location': _locationController.text.trim().isEmpty ? '알 수 없음' : _locationController.text.trim(),
          'date': _dateController.text,
          'dateStart': dateStr,
          'dateEnd': dateStr,
          'tags': allTags.isEmpty ? ['분실물'] : List<String>.from(allTags),
        });

        if (itemId != null) {
          // Step 2: 이미지가 있으면 Presigned URL 플로우 실행
          bool aiSucceeded = false;
          String? aiErrorMessage;
          if (_imageBytes != null && _imageFileName != null) {
            setState(() => _isUploading = true);
            try {
              final tagResult = await _uploadService.uploadImageAndTag(
                itemId: itemId,
                filename: _imageFileName!,
                imageBytes: _imageBytes!,
              );
              final features = tagResult['features'] as List? ?? [];
              final category = tagResult['category'] as String?;
              setState(() {
                _aiTags.clear();
                if (category != null && category.isNotEmpty) _aiTags.add(category);
                _aiTags.addAll(features.map((e) => e.toString()));
                _isUploading = false;
              });
              aiSucceeded = _aiTags.isNotEmpty;
              if (!aiSucceeded) {
                aiErrorMessage = 'AI 분석 결과가 비어있습니다 (시간 초과 가능)';
              }
            } catch (e) {
              setState(() => _isUploading = false);
              aiErrorMessage = e.toString();
            }
          }

          // Step 3: 매칭 트리거 수동 실행 (이미지가 없더라도 텍스트 기반 매칭을 위해 호출)
          try {
            await MatchService().triggerMatching(itemId);
          } catch (_) {}

          final message = (_imageBytes == null)
              ? '분실물이 등록되었습니다.'
              : aiSucceeded
                  ? '분실물이 등록되고 AI 분석이 완료되었습니다.'
                  : '분실물은 등록되었으나 AI 분석에 실패했습니다.\n($aiErrorMessage)';
          _showSuccessDialog(message);
        } else {
          throw Exception('등록 실패');
        }
      }
    } catch (e) {
      if (!mounted) return;
      ChatdaDialog.showSuccess(
        context: context,
        title: '오류',
        message: '등록에 실패했습니다. 다시 시도해주세요.',
        buttonText: '확인',
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? '분실물 수정' : '분실물 등록'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildLabel('사진 (선택사항)'),
              const SizedBox(height: 8),
              // 사진 업로드 박스
              GestureDetector(
                onTap: _showImagePickerModal,
                child: Container(
                  height: 180,
                  decoration: BoxDecoration(
                    color: _hasUploadedImage ? const Color(0xFFE8F5E9) : const Color(0xFFEEEEEE),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: _hasUploadedImage && _imageBytes != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.memory(_imageBytes!, fit: BoxFit.cover),
                            Container(color: Colors.black.withOpacity(0.2)),
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.check_circle, size: 40, color: Colors.white),
                                  const SizedBox(height: 8),
                                  const Text('변경하려면 탭하세요', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                                ],
                              ),
                            ),
                          ],
                        ),
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
                          _isUploading
                              ? 'AI 분석 중...'
                              : _hasUploadedImage
                                  ? '등록 후 AI가 사진을 분석하여 태그를 추천합니다.'
                                  : '사진을 업로드하면 AI가 자동으로 태그를 추천합니다.',
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

              _buildLabel('분실 위치', required: true),
              const SizedBox(height: 8),
              TextField(
                controller: _locationController,
                decoration: const InputDecoration(
                  hintText: '예: 강남역 2번 출구',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
              ),
              const SizedBox(height: 24),

              _buildLabel('분실 날짜', required: true),
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
              const SizedBox(height: 40),

              // 업로드 진행 중 표시
              if (_isUploading) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F4FF),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF6B8EFF).withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF6B8EFF)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('AI가 사진을 분석하고 있습니다...', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF2563EB))),
                            const SizedBox(height: 2),
                            Text('잠시만 기다려주세요', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              ElevatedButton(
                onPressed: (_isSubmitting || _isUploading) ? null : _onSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6B8EFF),
                  disabledBackgroundColor: const Color(0xFF6B8EFF).withOpacity(0.5),
                  padding: const EdgeInsets.symmetric(vertical: 18),
                ),
                child: _isSubmitting
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(_isEditMode ? '수정하기' : '등록하기', style: const TextStyle(fontSize: 18)),
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
