import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/items_provider.dart';
import '../../services/auth_service.dart';
import '../../services/upload_service.dart';
import '../../widgets/chatda_dialog.dart';
import '../main/main_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  
  bool _isSignUpMode = false;
  bool _isLoading = false;
  XFile? _profileImage;
  final ImagePicker _picker = ImagePicker();
  final UploadService _uploadService = UploadService();
  
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    // 화면 진입 시 슬라이드 애니메이션 실행
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleAction() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      if (_isSignUpMode) {
        // 회원가입
        final success = await ref.read(authProvider.notifier).signup(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          username: _nameController.text.trim(),
        );
        
        if (!mounted) return;
        
        if (success) {
          // 가입 성공 후 사진이 있다면 업로드 시도
          if (_profileImage != null) {
            try {
              final bytes = await _profileImage!.readAsBytes();
              final presignedData = await _uploadService.getPresignedUrl(
                itemId: 0,
                filename: 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
              );
              final presignedUrl = presignedData['presignedUrl'] as String;
              await _uploadService.uploadToS3(presignedUrl: presignedUrl, imageBytes: bytes);
              
              final finalUrl = presignedUrl.split('?').first;
              // 프로필 이미지 업데이트 API 호출
              await ref.read(userProvider.notifier).updateProfileImage(finalUrl);
            } catch (e) {
              debugPrint('Profile image upload failed during signup: $e');
              // 사진 업로드 실패해도 가입은 완료된 것이므로 진행
            }
          }

          // 자동 로그인
          final loginSuccess = await ref.read(authProvider.notifier).signin(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );
          
          if (!mounted) return;
          
          if (loginSuccess) {
            await _onLoginSuccess();
          } else {
            ChatdaDialog.showSuccess(
              context: context,
              title: '가입 완료!',
              message: '회원가입이 완료되었습니다.\n로그인 해주세요.',
              buttonText: '확인',
              onConfirm: () => setState(() => _isSignUpMode = false),
            );
          }
        } else {
          final error = ref.read(authProvider).error;
          ChatdaDialog.showSuccess(
            context: context,
            title: '가입 실패',
            message: error ?? '회원가입에 실패했습니다.',
            buttonText: '확인',
          );
        }
      } else {
        // 로그인
        final success = await ref.read(authProvider.notifier).signin(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        if (!mounted) return;
        if (success) {
          await _onLoginSuccess();
        } else {
          final error = ref.read(authProvider).error;
          ChatdaDialog.showSuccess(
            context: context,
            title: '로그인 실패',
            message: error ?? '이메일 또는 비밀번호를 확인해주세요.',
            buttonText: '확인',
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      ChatdaDialog.showSuccess(
        context: context,
        title: '오류',
        message: '네트워크 오류가 발생했습니다.\n다시 시도해주세요.',
        buttonText: '확인',
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      imageQuality: 80,
    );
    if (picked != null) {
      setState(() => _profileImage = picked);
    }
  }

  Future<void> _onLoginSuccess() async {
    // 사용자 정보 + 아이템 목록 로드
    await ref.read(userProvider.notifier).loadMe();
    await ref.read(itemsProvider.notifier).loadMyItems();
    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainScreen()));
  }

  /// 소셜 로그인 (Google / Kakao)
  Future<void> _handleSocialLogin(String provider) async {
    setState(() => _isLoading = true);
    try {
      // TODO: 실제 OAuth SDK 연동 후 authorization code를 받아서 전달
      // 현재는 placeholder로 알림 표시
      if (!mounted) return;
      ChatdaDialog.showSuccess(
        context: context,
        title: '소셜 로그인',
        message: '$provider 로그인은 곧 지원될 예정입니다.',
        buttonText: '확인',
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// 비밀번호 재설정
  void _showPasswordResetDialog() {
    final resetEmailController = TextEditingController();
    ChatdaDialog.showInfo(
      context: context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            '비밀번호 재설정',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            '가입한 이메일 주소를 입력하시면\n비밀번호 재설정 링크를 보내드립니다.',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          TextField(
            controller: resetEmailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: '이메일 주소',
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              filled: true,
              fillColor: const Color(0xFFF1F5F9),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              final email = resetEmailController.text.trim();
              if (email.isEmpty) return;
              Navigator.pop(context);
              final success = await ref.read(authProvider.notifier).requestPasswordReset(email);
              if (!mounted) return;
              ChatdaDialog.showSuccess(
                context: context,
                title: success ? '전송 완료' : '전송 실패',
                message: success
                    ? '비밀번호 재설정 링크가 이메일로 전송되었습니다.'
                    : '이메일 전송에 실패했습니다. 이메일 주소를 확인해주세요.',
                buttonText: '확인',
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6B8EFF),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: const Text('재설정 링크 보내기', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showPasswordResetConfirmDialog();
            },
            child: Text('이미 인증 코드를 받으셨나요?', style: TextStyle(color: Colors.grey.shade600, decoration: TextDecoration.underline)),
          )
        ],
      ),
    );
  }

  /// 비밀번호 재설정 확정 (인증 코드 입력)
  void _showPasswordResetConfirmDialog() {
    final tokenController = TextEditingController();
    final newPasswordController = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('새 비밀번호 설정', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    Text('이메일로 받은 인증 코드와\n새로운 비밀번호를 입력해주세요.', style: TextStyle(color: Colors.grey.shade600, fontSize: 14), textAlign: TextAlign.center),
                    const SizedBox(height: 20),
                    TextField(
                      controller: tokenController,
                      decoration: InputDecoration(
                        hintText: '인증 코드',
                        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                        filled: true,
                        fillColor: const Color(0xFFF1F5F9),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: newPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: '새 비밀번호',
                        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                        filled: true,
                        fillColor: const Color(0xFFF1F5F9),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: isLoading ? null : () => Navigator.pop(context),
                            child: const Text('취소', style: TextStyle(color: Colors.grey)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isLoading ? null : () async {
                              final token = tokenController.text.trim();
                              final pw = newPasswordController.text.trim();
                              if (token.isEmpty || pw.isEmpty) return;

                              setDialogState(() => isLoading = true);
                              try {
                                await AuthService().confirmPasswordReset(token: token, newPassword: pw);
                                if (!mounted) return;
                                Navigator.pop(context);
                                ChatdaDialog.showSuccess(context: context, message: '비밀번호가 성공적으로 변경되었습니다. 새 비밀번호로 로그인해주세요.');
                              } catch (_) {
                                if (!mounted) return;
                                ChatdaDialog.showSuccess(context: context, title: '오류', message: '인증 코드가 올바르지 않거나 변경에 실패했습니다.');
                                setDialogState(() => isLoading = false);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6B8EFF),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              elevation: 0,
                            ),
                            child: isLoading
                                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Text('확인', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _toggleMode() {
    setState(() {
      _isSignUpMode = !_isSignUpMode;
      _formKey.currentState?.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // 키보드가 올라올 때 화면 전체가 위로 밀리는 현상 방지
      body: Stack(
        children: [
          // 배경 그라데이션 및 상단 로고 (스플래시 화면과 통일성 유지)
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.45,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF6B8EFF), // 상단 파스텔 블루
                  Color(0xFFA5B4FC), // 하단 연보라/파스텔
                ],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                // 로고 이미지 (사용자 커스텀)
                Image.asset(
                  'assets/booting.png',
                  width: 100,
                  height: 100,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Chatda',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
          
          // 하단 하얀색 폼 시트 (슬라이드 애니메이션 적용)
          Align(
            alignment: Alignment.bottomCenter,
            child: SlideTransition(
              position: _slideAnimation,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.65,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 20,
                      offset: Offset(0, -5),
                    )
                  ],
                ),
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(32, 40, 32, 32 + MediaQuery.of(context).viewInsets.bottom), // 키보드 높이만큼 스크롤 여백 추가
                  child: Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.disabled,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (_isSignUpMode) ...[
                          Center(
                            child: GestureDetector(
                              onTap: _pickImage,
                              child: Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 40,
                                    backgroundColor: Colors.grey.shade100,
                                    backgroundImage: _profileImage != null
                                        ? FileImage(File(_profileImage!.path))
                                        : null,
                                    child: _profileImage == null
                                        ? Icon(Icons.person, size: 40, color: Colors.grey.shade300)
                                        : null,
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF94A3B8),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 14),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                        Text(
                          _isSignUpMode ? '이메일 주소' : '이메일',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: '이메일을 입력하세요',
                            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                            filled: true,
                            fillColor: const Color(0xFFF1F5F9), // 연한 회색 배경
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: (val) {
                            if (val == null || val.isEmpty) return '이메일을 입력해주세요.';
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val)) {
                              return '올바른 이메일 형식이 아닙니다.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        const Text(
                          '비밀번호',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            hintText: '비밀번호를 입력하세요',
                            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                            filled: true,
                            fillColor: const Color(0xFFF1F5F9), // 연한 회색 배경
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: (val) {
                            if (val == null || val.isEmpty) return '비밀번호를 입력해주세요.';
                            if (_isSignUpMode && val.length < 8) return '비밀번호는 8자리 이상이어야합니다.';
                            return null;
                          },
                        ),
                        
                        if (_isSignUpMode) ...[
                          const SizedBox(height: 24),
                          const Text('닉네임', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              hintText: '닉네임을 입력하세요',
                              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                              filled: true,
                              fillColor: const Color(0xFFF1F5F9),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            validator: (val) => (val == null || val.isEmpty) ? '닉네임을 입력해주세요.' : null,
                          ),
                        ],
                        
                        // 비밀번호 찾기 링크 (로그인 모드에서만)
                        if (!_isSignUpMode) ...[
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: _showPasswordResetDialog,
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(0, 32),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                '비밀번호를 잊으셨나요?',
                                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                              ),
                            ),
                          ),
                        ],

                        const SizedBox(height: 24),

                        // 넓고 둥근 로그인/가입 버튼
                        ElevatedButton(
                          onPressed: _isLoading ? null : _handleAction,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF94A3B8), // 회색빛 파스텔톤 버튼 (영상과 유사)
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: const Color(0xFF94A3B8).withOpacity(0.5),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20), // 둥근 버튼
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20, height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : Text(
                                  _isSignUpMode ? '회원가입' : '로그인',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                        ),
                        
                        // 소셜 로그인 (로그인 모드에서만)
                        if (!_isSignUpMode) ...[
                          const SizedBox(height: 28),
                          
                          // 구분선
                          Row(
                            children: [
                              Expanded(child: Divider(color: Colors.grey.shade200, thickness: 1)),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  '간편 로그인',
                                  style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                                ),
                              ),
                              Expanded(child: Divider(color: Colors.grey.shade200, thickness: 1)),
                            ],
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // 소셜 로그인 버튼들 (원형 아이콘)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Google
                              _buildSocialButton(
                                onTap: () => _handleSocialLogin('Google'),
                                icon: Icons.g_mobiledata_rounded,
                                color: const Color(0xFFF1F5F9),
                                iconColor: const Color(0xFF4285F4),
                                label: 'Google',
                              ),
                              const SizedBox(width: 24),
                              // Kakao
                              _buildSocialButton(
                                onTap: () => _handleSocialLogin('Kakao'),
                                icon: Icons.chat_bubble_rounded,
                                color: const Color(0xFFFEE500),
                                iconColor: const Color(0xFF3C1E1E),
                                label: 'Kakao',
                              ),
                            ],
                          ),
                        ],
                        
                        const SizedBox(height: 24),
                        
                        // 하단 링크
                        if (!_isSignUpMode) ...[
                          Center(
                            child: TextButton(
                              onPressed: _toggleMode,
                              child: const Text('회원가입', style: TextStyle(color: Color(0xFF6B8EFF), fontSize: 13, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ] else ...[
                          Center(
                            child: TextButton(
                              onPressed: _toggleMode,
                              child: const Text('이미 계정이 있으신가요? 로그인', style: TextStyle(color: Color(0xFF6B8EFF), fontSize: 13, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // 로딩 오버레이
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.1),
            ),
        ],
      ),
    );
  }

  Widget _buildSocialButton({
    required VoidCallback onTap,
    required IconData icon,
    required Color color,
    required Color iconColor,
    required String label,
  }) {
    return GestureDetector(
      onTap: _isLoading ? null : onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: iconColor, size: 30),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}