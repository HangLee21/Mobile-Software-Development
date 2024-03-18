import 'package:flutter/material.dart';
import 'package:forum/pages/account.dart';
import 'package:forum/pages/notification.dart';
import 'package:forum/theme/theme_data.dart';
import 'package:forum/pages/home.dart';

class NavigationExample extends StatefulWidget {
  const NavigationExample({super.key});
  @override
  State<NavigationExample> createState() => _NavigationExampleState();
}

class _NavigationExampleState extends State<NavigationExample> {
  int currentPageIndex = 0;

  var _pageController = PageController();
  var _pages;
  void initData() {
    _pages = [
      Card(
        shadowColor: Colors.transparent,
        margin: EdgeInsets.all(8.0),
        child: SizedBox.expand(
          child: Center(
            child: HomePage(),
          ),
        ),
      ),
      NotificationPage(),
      AccountPage()
    ];
  }
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    initData();
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            _tabIndex = index;
            _pageController.jumpToPage(index);
          });
        },

        selectedIndex: _tabIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: '主页',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.chat_bubble),
            icon: Icon(Icons.chat_bubble_outline),
            label: '消息',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.account_circle),
            icon: Icon(Icons.account_circle_outlined),
            label: '个人中心',
          ),
        ],

      ),
      body: SafeArea(
        child: PageView.builder(
          //要点1
            physics: NeverScrollableScrollPhysics(),
            //禁止页面左右滑动切换
            controller: _pageController,
            onPageChanged: _pageChanged,
            //回调函数
            itemCount: _pages.length,
            itemBuilder: (context, index) => _pages[index]),
      ),
    );
  }
  void _pageChanged(int index) {
    print('_pageChanged');
    setState(() {
      if (_tabIndex != index) _tabIndex = index;
    });
  }
}
