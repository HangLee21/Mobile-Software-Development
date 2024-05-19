import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:forum/classes/localStorage.dart';
import 'package:http/http.dart';
import '../pages/search_page.dart';
import '../theme/theme_data.dart';
import '../url/user.dart';
/// Flutter code sample for [SearchBar].


class SearchBarApp extends StatefulWidget {
  const SearchBarApp({super.key});

  @override
  State<SearchBarApp> createState() => _SearchBarAppState();
}

class _SearchBarAppState extends State<SearchBarApp> {

  late SearchController _searchController;

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

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme
        .of(context)
        .colorScheme;

    return Stack(
      children: [
        Positioned(
          top: 35,
          child: GestureDetector(
              onTap: () {
                // 处理用户头像点击事件
                // TODO
                print('User avatar clicked!');
              },
              child: CircleAvatar(
                radius: 25.0, // 设置半径为50.0，调整大小
                foregroundImage: NetworkImage(LocalStorage.getString('userAvatar')??'https://android-1324918669.cos.ap-beijing.myqcloud.com/default_avatar_1.png'),
              )
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 30.0, horizontal: 65.0),
          child: SearchBar(
            // TODO
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
          child: FloatingActionButton(
            foregroundColor: colorScheme.secondary,
            backgroundColor: colorScheme.background,
            onPressed: () {
              // Add your onPressed code here!
              // TODO
            },
            child: IconTheme(
              data: IconThemeData(
                size: 30.0, // 设置图标大小为40.0
                color: colorScheme.primary,
              ),
              child: Icon(Icons.mail),
            ),
          ),
        ),
      ],
    );
  }
}
