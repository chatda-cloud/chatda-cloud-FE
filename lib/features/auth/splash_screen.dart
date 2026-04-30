import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _rippleController;

  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _textSlide;
  late Animation<double> _textOpacity;
  late Animation<double> _subtitleOpacity;

  @override
  void initState() {
    super.initState();

    // 메인 로고/텍스트 등장 애니메이션
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _logoScale = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _mainController, curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack)),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _mainController, curve: const Interval(0.0, 0.3, curve: Curves.easeIn)),
    );
    _textSlide = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(parent: _mainController, curve: const Interval(0.35, 0.65, curve: Curves.easeOutCubic)),
    );
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _mainController, curve: const Interval(0.35, 0.6, curve: Curves.easeIn)),
    );
    _subtitleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _mainController, curve: const Interval(0.55, 0.8, curve: Curves.easeIn)),
    );

    // 물결(파동) 효과 반복 애니메이션
    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();

    _mainController.forward();

    // 3초 후 로그인 화면으로 전환
    Timer(const Duration(milliseconds: 3000), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF6B8EFF),
              Color(0xFF818CF8),
              Color(0xFFA5B4FC),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // 배경 물결 파동 (리퀴드 느낌)
            ...List.generate(3, (index) {
              return AnimatedBuilder(
                animation: _rippleController,
                builder: (context, child) {
                  final progress = (_rippleController.value + index * 0.33) % 1.0;
                  final scale = 1.0 + progress * 2.5;
                  final opacity = (1.0 - progress).clamp(0.0, 0.15);
                  return Center(
                    child: Transform.scale(
                      scale: scale,
                      child: Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(opacity),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            }),

            // 배경 떠다니는 원형 장식
            ..._buildFloatingBubbles(),

            // 메인 콘텐츠
            Center(
              child: AnimatedBuilder(
                animation: _mainController,
                builder: (context, child) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 로고 이미지 + 글로우 효과
                      Opacity(
                        opacity: _logoOpacity.value,
                        child: Transform.scale(
                          scale: _logoScale.value,
                          child: Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.3),
                                  blurRadius: 40,
                                  spreadRadius: 10,
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: Container(
                                color: Colors.white.withOpacity(0.15),
                                padding: const EdgeInsets.all(24),
                                child: Image.asset(
                                  'assets/booting.png',
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // 앱 이름 텍스트
                      Opacity(
                        opacity: _textOpacity.value,
                        child: Transform.translate(
                          offset: Offset(0, _textSlide.value),
                          child: const Text(
                            'Chatda',
                            style: TextStyle(
                              fontSize: 42,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 2.0,
                              shadows: [
                                Shadow(
                                  color: Colors.black12,
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // 서브타이틀
                      Opacity(
                        opacity: _subtitleOpacity.value,
                        child: const Text(
                          '잃어버린 것을 찾아주는 AI',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

          ],
        ),
      ),
    );
  }

  List<Widget> _buildFloatingBubbles() {
    final rng = Random(42); // 시드 고정 (일관된 배치)
    return List.generate(8, (index) {
      final size = 12.0 + rng.nextDouble() * 30;
      final left = rng.nextDouble();
      final top = rng.nextDouble();
      final delay = rng.nextDouble();

      return Positioned(
        left: left * MediaQuery.of(context).size.width,
        top: top * MediaQuery.of(context).size.height,
        child: AnimatedBuilder(
          animation: _rippleController,
          builder: (context, child) {
            final t = (_rippleController.value + delay) % 1.0;
            final dy = sin(t * 2 * pi) * 15;
            return Transform.translate(
              offset: Offset(0, dy),
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.08 + rng.nextDouble() * 0.07),
                ),
              ),
            );
          },
        ),
      );
    });
  }
}
