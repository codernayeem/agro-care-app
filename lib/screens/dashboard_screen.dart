import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/active_nav_provider.dart';
import 'home_screen.dart';
import 'market_screen.dart';
import 'community_screen.dart';
import 'profile_screen.dart';

class DashBoardScreen extends StatefulWidget {
  const DashBoardScreen({super.key});

  @override
  State<DashBoardScreen> createState() => _DashBoardScreenState();
}

class _DashBoardScreenState extends State<DashBoardScreen>
    with SingleTickerProviderStateMixin {
  int selectedPage = 0;
  late TabController _tabController;
  late ActiveNavProvider activeNavProvider;

  final pages = [
    const HomeScreen(key: ValueKey("HomePage")),
    const MarketScreen(key: ValueKey("MarketPage")),
    const CommunityScreen(key: ValueKey("CommunityPage")),
    const ProfileScreen(key: ValueKey("ProfilePage")),
  ];

  void activeNavListener() {
    if (activeNavProvider.selectedPage != selectedPage) {
      _onItemTapped(activeNavProvider.selectedPage);
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    activeNavProvider = context.read();
    activeNavProvider.addListener(activeNavListener);
  }

  @override
  void dispose() {
    _tabController.dispose();
    activeNavProvider.removeListener(activeNavListener);
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (selectedPage == index) return;

    setState(() {
      selectedPage = index;
    });

    activeNavProvider.setPage(index);
    _tabController.animateTo(index);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: selectedPage == 0,
      onPopInvoked: (didPop) {
        if (selectedPage != 0 && !didPop) {
          _onItemTapped(0);
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: TabBarView(
            controller: _tabController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              pages[0],
              pages[1],
              pages[2],
              pages[3],
            ],
          ),
        ),
        extendBody: true,
        bottomNavigationBar: BottomNavigationBar(
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Image.asset(
                "assets/icons/home.png",
                width: 24,
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                "assets/icons/cart.png",
                width: 24,
              ),
              label: 'Market',
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                "assets/icons/explore.png",
                width: 24,
              ),
              label: 'Community',
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                "assets/icons/profile.png",
                width: 24,
              ),
              label: 'Profile',
            )
          ],
          currentIndex: selectedPage,
          selectedItemColor: Colors.black87,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
