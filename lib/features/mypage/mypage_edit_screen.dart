import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/user_provider.dart';

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
          child: DefaultTabController(
            length: 4,
            child: Column(
              children: [
                Card(
                  elevation: 2,
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
                          decoration: const InputDecoration(hintText: 'demo@example.com'),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 24),
                        
                        _buildLabel('이름'),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(hintText: '데모 사용자'),
                        ),
                        const SizedBox(height: 24),
                        
                        _buildLabel('전화번호'),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _phoneController,
                          decoration: const InputDecoration(hintText: '010-1234-5678'),
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
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                                  showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (ctx) => AlertDialog(
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                      icon: const Icon(Icons.check_circle, color: Color(0xFF059669), size: 48),
                                      title: const Text('완료'),
                                      content: const Text('정보가 수정되었습니다.', textAlign: TextAlign.center),
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
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  backgroundColor: const Color(0xFF2563EB),
                                ),
                                child: const Text('저장', style: TextStyle(fontSize: 16)),
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
