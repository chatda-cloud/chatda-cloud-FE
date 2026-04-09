import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/items_provider.dart';

class RegisterLostItemScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? editItem;

  const RegisterLostItemScreen({super.key, this.editItem});

  @override
  ConsumerState<RegisterLostItemScreen> createState() => _RegisterLostItemScreenState();
}

class _RegisterLostItemScreenState extends ConsumerState<RegisterLostItemScreen> {
  // 간단한 상태 관리
  final _tags = <String>[];
  final _tagController = TextEditingController();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _locationController = TextEditingController();

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
        _tags.addAll(existingTags);
      }
    }
  }

  void _addTag() {
    if (_tagController.text.trim().isNotEmpty) {
      setState(() {
        _tags.add(_tagController.text.trim());
        _tagController.clear();
      });
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
                  // TODO: image_picker 연동
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('갤러리에서 선택하기'),
                onTap: () {
                  // TODO: image_picker 연동
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(Icons.check_circle, color: Color(0xFF059669), size: 48),
        title: const Text('완료'),
        content: Text(message, textAlign: TextAlign.center),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _onSubmit() {
    if (_titleController.text.trim().isEmpty) return;

    if (_isEditMode) {
      ref.read(itemsProvider.notifier).updateLostItem(
        widget.editItem!['id'] as int,
        {
          'title': _titleController.text.trim(),
          'desc': _descController.text.trim(),
          'location': _locationController.text.trim().isEmpty ? '알 수 없음' : _locationController.text.trim(),
          'tags': _tags.isEmpty ? ['분실물'] : List<String>.from(_tags),
        },
      );
      _showSuccessDialog('분실물 정보가 수정되었습니다.');
    } else {
      ref.read(itemsProvider.notifier).addLostItem({
        'title': _titleController.text.trim(),
        'desc': _descController.text.trim(),
        'location': _locationController.text.trim().isEmpty ? '알 수 없음' : _locationController.text.trim(),
        'date': '2026년 04월 05일',
        'tags': _tags.isEmpty ? ['분실물'] : List<String>.from(_tags),
      });
      _showSuccessDialog('분실물이 등록되었습니다.');
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
              // 점선 테두리를 대신하는 사진 업로드 박스 (일단 둥근 직사각형으로 시각적 통일)
              GestureDetector(
                onTap: _showImagePickerModal,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.grey.shade300,
                      width: 2,
                      strokeAlign: BorderSide.strokeAlignOutside,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt_outlined, size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      Text('사진 업로드', style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
                    ],
                  ),
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

              _buildLabel('상세 설명'),
              const SizedBox(height: 8),
              TextField(
                controller: _descController,
                maxLines: 4,
                decoration: const InputDecoration(hintText: '물건의 상세한 특징을 입력하세요'),
              ),
              const SizedBox(height: 24),

              _buildLabel('특징'),
              const SizedBox(height: 8),
              const TextField(
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: '색상, 크기, 브랜드 등 특징을 입력하세요',
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(bottom: 40), // 멀티라인 텍스트필드 상단 정렬 꼼수
                    child: Icon(Icons.description_outlined),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              _buildLabel('태그'),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _tagController,
                      decoration: const InputDecoration(
                        hintText: '태그 입력 후 추가 버튼 클릭',
                        prefixIcon: Icon(Icons.local_offer_outlined),
                      ),
                      onSubmitted: (_) => _addTag(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    height: 54, // TextField 기본 높이와 유사하게 맞춤
                    child: ElevatedButton(
                      onPressed: _addTag,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange, // 피그마 오렌지 컬러
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                      ),
                      child: const Text('추가'),
                    ),
                  ),
                ],
              ),
              if (_tags.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _tags.map((tag) => Chip(
                      label: Text(tag),
                      onDeleted: () {
                        setState(() => _tags.remove(tag));
                      },
                      backgroundColor: Colors.orange.shade50,
                      side: BorderSide(color: Colors.orange.shade200),
                    )).toList(),
                  ),
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
                decoration: const InputDecoration(
                  hintText: '2026-04-05',
                  prefixIcon: Icon(Icons.calendar_today_outlined),
                  suffixIcon: Icon(Icons.arrow_drop_down),
                ),
                onTap: () {
                  // TODO: 실제 DatePicker 연결
                },
              ),
              const SizedBox(height: 40),

              ElevatedButton(
                onPressed: _onSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange, // 등록완료 버튼 오렌지
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
