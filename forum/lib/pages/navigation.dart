import 'dart:async';

import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:forum/classes/localStorage.dart';
import 'package:forum/pages/ActivityPage.dart';
import 'package:forum/pages/account.dart';
import 'package:forum/pages/notification.dart';
import 'package:forum/theme/theme_data.dart';
import 'package:forum/pages/home.dart';

import '../classes/message.dart';
import '../components/notificationcard.dart';
import '../url/websocket_service.dart';

class NavigationExample extends StatefulWidget {
  const NavigationExample({super.key});
  @override
  State<NavigationExample> createState() => _NavigationExampleState();
}

class _NavigationExampleState extends State<NavigationExample> {
  int currentPageIndex = 0;
  final _websocketService = WebSocketService();
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
      ActivityPage(),
      AccountPage()
    ];
  }
  int _tabIndex = 0;
  StreamSubscription<dynamic>? _streamSubscription;
  @override
  void initState(){
    super.initState();
    _streamSubscription = _websocketService.stream!.listen((message) async {
      setState(() {
        Message message1 = Message.fromString(message);
        if(LocalStorage.getString('currentUserId') == null){
// 定义正则表达式模式
          RegExp regex = RegExp(r'\((.*?)\)\[(.*?)\]');
          //print('content: '+ item['content']);
          Match? match = regex.firstMatch(message1.content);
          String content = message1.content;
          // 检查是否匹配成功
          if (match != null) {
            content = '暂不支持的消息格式，请跳转页面详细观看内容';
          }
          AnimatedSnackBar(
            duration: Duration(seconds: 4),
            builder: ((context) {
              return NotificationCard(
                friendname: message1.senderId,
                content: content,
                url: '',
                friendId: message1.senderId,
                info_num: 0,
                remove: false,
                onPressed: () {
                },
              );
            }),
          ).show(context);
        }
      });
    });

  }

  @override
  void dispose(){
    super.dispose();
    _streamSubscription?.cancel();
  }

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
            selectedIcon: Icon(Icons.local_activity),
            icon: Icon(Icons.local_activity_outlined),
            label: '动态',
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
