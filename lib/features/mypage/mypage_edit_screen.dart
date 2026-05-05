import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/user_provider.dart';
import '../../widgets/chatda_dialog.dart';

class MyPageEditScreen extends ConsumerStatefulWidget {
  const MyPageEditScreen({super.key});

  @override
  ConsumerState<MyPageEditScreen> createState() => _MyPageEditScreenState();
}

class _MyPageEditScreenState extends ConsumerState<MyPageEditScreen> {
  late TextEditingController _emailController;
  late TextEditingController _nameController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    final userInfo = ref.read(userProvider);
    _emailController = TextEditingController(text: userInfo.email);
    _nameController = TextEditingController(text: userInfo.name);
    _phoneController = TextEditingController(text: userInfo.phone);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
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
                      
                      _buildLabel('이메일'),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          hintText: 'demo@example.com',
                          hintStyle: TextStyle(color: Colors.grey.shade400),
                          filled: true,
                          fillColor: const Color(0xFFF1F5F9),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 24),
                      
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
                      
                      _buildLabel('전화번호'),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _phoneController,
                        decoration: InputDecoration(
                          hintText: '010-1234-5678',
                          hintStyle: TextStyle(color: Colors.grey.shade400),
                          filled: true,
                          fillColor: const Color(0xFFF1F5F9),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        keyboardType: TextInputType.phone,
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
                              onPressed: () {
                                ref.read(userProvider.notifier).updateUser(
                                  email: _emailController.text.trim(),
                                  name: _nameController.text.trim(),
                                  phone: _phoneController.text.trim(),
                                );
                                ChatdaDialog.showSuccess(
                                  context: context,
                                  message: '정보가 수정되었습니다.',
                                  onConfirm: () => Navigator.pop(context),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                backgroundColor: const Color(0xFF2563EB),
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
