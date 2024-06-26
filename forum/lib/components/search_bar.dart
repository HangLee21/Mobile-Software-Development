import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:forum/classes/localStorage.dart';
import 'package:forum/pages/AIChatPage.dart';
import 'package:http/http.dart';
import '../classes/notification_card.dart';
import '../pages/notification.dart';
import '../pages/personspace.dart';
import '../pages/search_page.dart';
import '../storage/notificationInfo_storage.dart';
import '../theme/theme_data.dart';
import '../url/user.dart';
/// Flutter code sample for [SearchBar].


class SearchBarApp extends StatefulWidget {
  const SearchBarApp({super.key});

  @override
  State<SearchBarApp> createState() => _SearchBarAppState();
}

class _SearchBarAppState extends State<SearchBarApp> {
  Map<String, NotificationInfo> _notificationInfos = {};
  late SearchController _searchController;
  int info_num = 0;
  var Avatar;
  @override
  void initState() {
    super.initState();
    _searchController = SearchController();
    _searchController.addListener(_onQueryChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onQueryChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _initNotifications(){
    NotificationStorage().loadNotifications().then((value) => setState(() {
      _notificationInfos = value;
      for(var info in _notificationInfos.values){
        info_num += info.info_num;
      }
    }));
  }

  void _onQueryChanged() {
    if (_searchController.value.text.isNotEmpty) {
      // Assuming that the user submits with the 'Enter' key
      // This is a simple workaround, better logic might be needed based on your requirements
      if (_searchController.value.text.endsWith('\n')) {
        final query = _searchController.value.text.trim();
        performSearch(query);
      }
    }
  }

  void performSearch(String query) {
    // Do something with the query, e.g., execute the search
    print('Search submitted: $query');
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => SearchPage(query: query)));
  }

  Widget _getAvatar(){
    String url = LocalStorage.getString('userAvatar')??'https://android-1324918669.cos.ap-beijing.myqcloud.com/default_avatar_1.png';

    return CircleAvatar(
      key: UniqueKey(),
      radius: 25.0, // 设置半径为50.0，调整大小
      foregroundImage: NetworkImage(url),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme
        .of(context)
        .colorScheme;
    Avatar = _getAvatar();
    return Stack(
      children: [
        Positioned(
          top: 35,
          child: GestureDetector(
              onTap: () {
                // 处理用户头像点击事件
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => PersonalSpace(LocalStorage.getString('userId') ?? '')));
              },
              child: Avatar,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 30.0, horizontal: 65.0),
          child: SearchBar(
            controller: _searchController,
            padding: const MaterialStatePropertyAll<EdgeInsets>(
                EdgeInsets.symmetric(horizontal: 16.0)),
            onTap: () {

            },
            onSubmitted: (value) {
              performSearch(value);
            },
            leading: const Icon(Icons.search),
            trailing: <Widget>[
              Tooltip(
                message: 'Clear content',
                child: IconButton(
                  onPressed: () {
                    setState(() {
                        _searchController.clear();
                    });
                  },
                  icon: const Icon(Icons.clear),
                ),
              )
            ],
          ),
        ),
        Positioned(
          top: 32,
          right: 1,
          child: Badge(
            label: Text('${info_num}', style: TextStyle(color: colorScheme.primary)),
            isLabelVisible: info_num > 0,
            child: FloatingActionButton(
              foregroundColor: colorScheme.secondary,
              backgroundColor: colorScheme.background,
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => NotificationPage()));
              },
              child: IconTheme(
                data: IconThemeData(
                  size: 30.0, // 设置图标大小为40.0
                  color: colorScheme.primary,
                ),
                child: Icon(Icons.mail),
              ),
            ),
          )
        ),
      ],
    );
  }
}
