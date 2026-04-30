import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import '../home/home_screen.dart';
import '../search/search_screen.dart';
import '../register/register_lost_item_screen.dart';
import '../register/register_found_item_screen.dart';
import '../chat/chat_list_screen.dart';
import '../mypage/mypage_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // 네비게이션을 유지한 채로 화면 전환을 위한 글로벌 키 설정 
  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  void _onTabTapped(int index) {
    if (index == 2) {
      // 2번은 '등록' 탭으로 바텀시트 띄움
      _showRegistrationBottomSheet();
    } else {
      if (_currentIndex == index) {
        // 이미 선택된 탭을 다시 누르면 스택의 처음으로 돌아감
        _navigatorKeys[index].currentState?.popUntil((route) => route.isFirst);
      } else {
        setState(() {
          _currentIndex = index;
        });
      }
    }
  }

  void _showRegistrationBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            const Text('어떤 물건을 등록하시겠어요?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildRegisterOption(
                    context,
                    title: '분실물 등록',
                    subtitle: '잃어버린 물건 찾기',
                    icon: Icons.outbox_outlined,
                    color: Colors.orange,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context, rootNavigator: true).push(
                        MaterialPageRoute(builder: (_) => const RegisterLostItemScreen())
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildRegisterOption(
                    context,
                    title: '습득물 등록',
                    subtitle: '주운 물건 찾아주기',
                    icon: Icons.move_to_inbox_outlined,
                    color: Colors.green,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context, rootNavigator: true).push(
                        MaterialPageRoute(builder: (_) => const RegisterFoundItemScreen())
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterOption(BuildContext context, {required String title, required String subtitle, required IconData icon, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: color.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4)),
                ],
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 4),
            Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigator(int index) {
    return Navigator(
      key: _navigatorKeys[index],
      onGenerateRoute: (settings) {
        WidgetBuilder builder;
        switch (index) {
          case 0:
            builder = (context) => HomeScreen(
              onNavigateToRegisterLost: () => Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(builder: (_) => const RegisterLostItemScreen())),
              onNavigateToRegisterFound: () => Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(builder: (_) => const RegisterFoundItemScreen())),
            );
            break;
          case 1:
            builder = (context) => const SearchScreen();
            break;
          case 2:
            builder = (context) => const SizedBox(); // '등록' 탭 빈 화면 (BottomSheet)
            break;
          case 3:
            builder = (context) => const ChatListScreen();
            break;
          case 4:
            builder = (context) => const MyPageScreen();
            break;
          default:
            builder = (context) => const Center(child: Text('Not Found'));
        }
        return MaterialPageRoute(builder: builder, settings: settings);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // 바텀바 뒤로 컨텐츠가 스크롤되도록 설정
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildNavigator(0),
          _buildNavigator(1),
          _buildNavigator(2),
          _buildNavigator(3),
          _buildNavigator(4),
        ],
      ),
      bottomNavigationBar: Container(
        margin: EdgeInsets.only(left: 20, right: 20, bottom: MediaQuery.of(context).padding.bottom + 16),
        height: 72, // 바 높이를 키워서 원형 인디케이터가 들어갈 공간 확보
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(36),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(36),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              color: Colors.white.withOpacity(0.6), // 투명도를 낮춰 블러 효과 극대화
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final totalWidth = constraints.maxWidth;
                  final hPadding = 10.0; // 양쪽 끝 여백 (곡률 안쪽 보호)
                  final usableWidth = totalWidth - hPadding * 2;
                  final itemWidth = usableWidth / 5;
                  final bubbleSize = 56.0;
                  final bubbleLeft = hPadding + (_currentIndex * itemWidth) + (itemWidth - bubbleSize) / 2;
                  return Stack(
                    children: [
                      // 부드럽게 이동하는 물방울(원형) 배경
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutCubic,
                        left: bubbleLeft,
                        top: (72 - bubbleSize) / 2, // 세로 중앙 정렬
                        child: Container(
                          width: bubbleSize,
                          height: bubbleSize,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                spreadRadius: 1,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // 아이콘 및 텍스트 탭 영역
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: hPadding),
                        child: Row(
                          children: [
                            _buildNavItem(0, CupertinoIcons.home, CupertinoIcons.house_fill, '홈'),
                            _buildNavItem(1, CupertinoIcons.search, CupertinoIcons.search, '탐색'),
                            _buildNavItem(2, CupertinoIcons.add, CupertinoIcons.add_circled_solid, '등록'),
                            _buildNavItem(3, CupertinoIcons.chat_bubble_2, CupertinoIcons.chat_bubble_2_fill, '채팅'),
                            _buildNavItem(4, CupertinoIcons.person, CupertinoIcons.person_fill, 'MY'),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, IconData activeIcon, String label) {
    final isSelected = _currentIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => _onTabTapped(index),
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          height: 72,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
                child: Icon(
                  isSelected ? activeIcon : icon,
                  key: ValueKey<bool>(isSelected),
                  color: isSelected ? const Color(0xFF2563EB) : Colors.grey.shade500,
                  size: 24,
                ),
              ),
              const SizedBox(height: 2),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  color: isSelected ? const Color(0xFF2563EB) : Colors.grey.shade500,
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

