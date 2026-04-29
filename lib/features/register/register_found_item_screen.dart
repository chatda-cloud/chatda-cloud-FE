import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/items_provider.dart';

class RegisterFoundItemScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? editItem;

  const RegisterFoundItemScreen({super.key, this.editItem});

  @override
  ConsumerState<RegisterFoundItemScreen> createState() => _RegisterFoundItemScreenState();
}

class _RegisterFoundItemScreenState extends ConsumerState<RegisterFoundItemScreen> {
  final _tags = <String>[];
  final _tagController = TextEditingController();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _locationController = TextEditingController();
  final _dateController = TextEditingController(text: '2026년 04월 05일');
  DateTime? _selectedDate;

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
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                offset: Offset(0.0, 10.0),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 48,
                ),
              ),
              const SizedBox(height: 24.0),
              const Text(
                '완료',
                style: TextStyle(
                  fontSize: 22.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16.0),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16.0,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 32.0),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 0,
                  ),
                  child: const Text(
                    '확인',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onSubmit() {
    if (_titleController.text.trim().isEmpty) return;

    if (_isEditMode) {
      ref.read(itemsProvider.notifier).updateFoundItem(
        widget.editItem!['id'] as int,
        {
          'title': _titleController.text.trim(),
          'desc': _descController.text.trim(),
          'location': _locationController.text.trim().isEmpty ? '알 수 없음' : _locationController.text.trim(),
          'tags': _tags.isEmpty ? ['습득물'] : List<String>.from(_tags),
        },
      );
      _showSuccessDialog('습득물 정보가 수정되었습니다.');
    } else {
      ref.read(itemsProvider.notifier).addFoundItem({
        'title': _titleController.text.trim(),
        'desc': _descController.text.trim(),
        'location': _locationController.text.trim().isEmpty ? '알 수 없음' : _locationController.text.trim(),
        'date': _dateController.text,
        'tags': _tags.isEmpty ? ['습득물'] : List<String>.from(_tags),
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
                      Text('사진 업로드', style: TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('AI가 자동으로 특징을 분석합니다', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
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
                    padding: EdgeInsets.only(bottom: 40),
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
                        hintText: '수동으로 태그 추가',
                        prefixIcon: Icon(Icons.local_offer_outlined),
                      ),
                      onSubmitted: (_) => _addTag(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _addTag,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF059669), // Emerald 600
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
                      backgroundColor: Colors.green.shade50,
                      side: BorderSide(color: Colors.green.shade200),
                    )).toList(),
                  ),
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
                  backgroundColor: const Color(0xFF059669),
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
