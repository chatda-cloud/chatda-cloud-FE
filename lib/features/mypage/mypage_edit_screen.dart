import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/user_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/user_service.dart';
import '../../services/upload_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/chatda_dialog.dart';

class MyPageEditScreen extends ConsumerStatefulWidget {
  const MyPageEditScreen({super.key});

  @override
  ConsumerState<MyPageEditScreen> createState() => _MyPageEditScreenState();
}

class _MyPageEditScreenState extends ConsumerState<MyPageEditScreen> {
  late TextEditingController _emailController;
  late TextEditingController _nameController;
  
  final ImagePicker _imagePicker = ImagePicker();
  final UploadService _uploadService = UploadService();
  final UserService _userService = UserService();
  final AuthService _authService = AuthService();
  
  String? _profileImageUrl;
  bool _isUploadingImage = false;

  @override
  void initState() {
    super.initState();
    final userInfo = ref.read(userProvider);
    _emailController = TextEditingController(text: userInfo.email);
    _nameController = TextEditingController(text: userInfo.name);
    _profileImageUrl = userInfo.profileImageUrl;
  }
  
  Future<void> _pickAndUploadProfileImage() async {
    try {
      final picked = await _imagePicker.pickImage(source: ImageSource.gallery, maxWidth: 512, imageQuality: 80);
      if (picked == null) return;
      
      final bytes = await picked.readAsBytes();
      setState(() => _isUploadingImage = true);
      
      // Step 1: get presigned URL
      // 프로필 사진의 경우 itemId 자리에 현재 유저의 ID를 넣어 시도해봅니다. (0은 서버에서 거부될 수 있음)
      final userId = ref.read(userProvider).id ?? 0;
      
      final presignedData = await _uploadService.getPresignedUrl(
        itemId: userId, 
        filename: 'profile_${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg'
      );
      
      final presignedUrl = presignedData['presignedUrl'] as String;
      final s3Key = presignedData['s3Key'] as String;
      
      // Step 2: Upload to S3
      await _uploadService.uploadToS3(presignedUrl: presignedUrl, imageBytes: bytes);
      
      // We assume the final URL is the presignedUrl without query params.
      final finalUrl = presignedUrl.split('?').first;
      
      // Step 3: Update profile image via API & Provider
      final success = await ref.read(userProvider.notifier).updateProfileImage(finalUrl);
      
      if (success) {
        // API에서 최신 정보 다시 로드
        await ref.read(userProvider.notifier).loadMe();
      }
      
      // 텍스트 필드 변경사항은 저장 버튼을 누를 때 반영되므로 사진만 즉시 반영
      setState(() {
        _profileImageUrl = finalUrl;
      });
      
      if (mounted) {
        ChatdaDialog.showSuccess(context: context, message: '프로필 사진이 변경되었습니다.');
      }
    } catch (e) {
      if (mounted) {
        ChatdaDialog.showSuccess(context: context, title: '오류', message: '이미지 업로드에 실패했습니다.', buttonText: '확인');
      }
    } finally {
      if (mounted) setState(() => _isUploadingImage = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('마이페이지'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // 프로필 사진 변경
              Center(
                child: GestureDetector(
                  onTap: _isUploadingImage ? null : _pickAndUploadProfileImage,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage: _profileImageUrl != null && _profileImageUrl!.isNotEmpty
                            ? NetworkImage(_profileImageUrl!)
                            : null,
                        child: _isUploadingImage
                            ? const CircularProgressIndicator()
                            : (_profileImageUrl == null || _profileImageUrl!.isEmpty)
                                ? const Icon(Icons.person, size: 50, color: Colors.white)
                                : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Color(0xFF2563EB),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Card(
                elevation: 0, // 그림자 제거 → 검은 모서리 방지
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text('정보 수정', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 24),
                      
                      const SizedBox(height: 8),
                      // 이메일 칸 제거 (수정 요청 반영)
                      
                      _buildLabel('닉네임'),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          hintText: '데모 사용자',
                          hintStyle: TextStyle(color: Colors.grey.shade400),
                          filled: true,
                          fillColor: const Color(0xFFF1F5F9),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      _buildLabel('보안'),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            ChatdaDialog.showConfirm(
                              context: context,
                              title: '비밀번호 변경',
                              message: '비밀번호 재설정 메일을 보내시겠습니까?',
                              confirmText: '보내기',
                              onConfirm: () async {
                                final email = _emailController.text.trim();
                                final success = await ref.read(authProvider.notifier).requestPasswordReset(email);
                                if (!context.mounted) return;
                                ChatdaDialog.showSuccess(
                                  context: context,
                                  title: success ? '전송 완료' : '전송 실패',
                                  message: success ? '재설정 메일이 전송되었습니다.' : '메일 전송에 실패했습니다.',
                                );
                              },
                            );
                          },
                          icon: const Icon(Icons.mail_outline, size: 18),
                          label: const Text('비밀번호 재설정 메일 받기'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            side: BorderSide(color: Colors.grey.shade300),
                            foregroundColor: Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                side: BorderSide(color: Colors.grey.shade300),
                              ),
                              child: Text('취소', style: TextStyle(color: Colors.grey.shade700, fontSize: 16)),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                final newName = _nameController.text.trim();
                                if (newName.isEmpty) {
                                  ChatdaDialog.showSuccess(
                                    context: context,
                                    title: '입력 오류',
                                    message: '닉네임을 입력해주세요.',
                                    buttonText: '확인',
                                  );
                                  return;
                                }
                                final success = await ref.read(userProvider.notifier).updateUsername(newName);
                                if (!context.mounted) return;
                                if (success) {
                                  // updateUsername 내부에서 이미 로컬 state.name 을 갱신함
                                  // loadMe() 를 추가로 호출하면 서버 응답 포맷 차이로 name 이 사라질 수 있어 제거
                                  ChatdaDialog.showSuccess(
                                    context: context,
                                    message: '정보가 수정되었습니다.',
                                    onConfirm: () => Navigator.pop(context),
                                  );
                                } else {
                                  ChatdaDialog.showSuccess(
                                    context: context,
                                    title: '오류',
                                    message: '정보 수정에 실패했습니다.',
                                    buttonText: '확인',
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                backgroundColor: const Color(0xFF6B8EFF),
                                elevation: 0,
                              ),
                              child: const Text('저장', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
    );
  }
}
