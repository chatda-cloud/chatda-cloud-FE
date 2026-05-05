import 'package:flutter/material.dart';
import '../../widgets/chatda_dialog.dart';
import '../main/main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  
  bool _isSignUpMode = false;
  
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
    _phoneController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _handleAction() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_isSignUpMode) {
      ChatdaDialog.showSuccess(
        context: context,
        title: '가입 완료!',
        message: '회원가입이 성공적으로 완료되었습니다.\n자동으로 로그인됩니다.',
        buttonText: '시작하기',
        onConfirm: () {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainScreen()));
        },
      );
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainScreen()));
    }
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
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

                        Text(
                          '비밀번호',
                          style: const TextStyle(
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
                          const SizedBox(height: 24),
                          const Text('전화번호', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              hintText: '전화번호를 입력하세요',
                              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                              filled: true,
                              fillColor: const Color(0xFFF1F5F9),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            validator: (val) => (val == null || val.isEmpty) ? '전화번호를 입력해주세요.' : null,
                          ),
                        ],
                        

                        
                        const SizedBox(height: 32),

                        // 넓고 둥근 로그인/가입 버튼
                        ElevatedButton(
                          onPressed: _handleAction,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF94A3B8), // 회색빛 파스텔톤 버튼 (영상과 유사)
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20), // 둥근 버튼
                            ),
                          ),
                          child: Text(
                            _isSignUpMode ? '회원가입' : '로그인',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                        
                        const SizedBox(height: 40),
                        
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
        ],
      ),
    );
  }
}