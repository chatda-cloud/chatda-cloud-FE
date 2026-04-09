import 'package:flutter/material.dart';
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
                      // 현재 선택된 탭의 네비게이터를 통해 화면 이동, 네비게이션 바 유지됨
                      _navigatorKeys[_currentIndex].currentState?.push(
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
                      _navigatorKeys[_currentIndex].currentState?.push(
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
              onNavigateToRegisterLost: () => _navigatorKeys[0].currentState?.push(MaterialPageRoute(builder: (_) => const RegisterLostItemScreen())),
              onNavigateToRegisterFound: () => _navigatorKeys[0].currentState?.push(MaterialPageRoute(builder: (_) => const RegisterFoundItemScreen())),
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
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5)),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: Theme.of(context).primaryColor,
          unselectedItemColor: Colors.grey.shade400,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.home),
              activeIcon: Icon(CupertinoIcons.house_fill),
              label: '홈',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.search),
              activeIcon: Icon(CupertinoIcons.search),
              label: '탐색',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.add),
              activeIcon: Icon(CupertinoIcons.add_circled_solid),
              label: '등록',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.chat_bubble_2),
              activeIcon: Icon(CupertinoIcons.chat_bubble_2_fill),
              label: '채팅',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.person),
              activeIcon: Icon(CupertinoIcons.person_fill),
              label: '마이',
            ),
          ],
        ),
      ),
    );
  }
}
