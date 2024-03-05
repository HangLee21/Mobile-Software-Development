import 'package:flutter/material.dart';
import '../theme/theme_data.dart';
/// Flutter code sample for [SearchBar].


class SearchBarApp extends StatefulWidget {
  const SearchBarApp({super.key});

  @override
  State<SearchBarApp> createState() => _SearchBarAppState();
}

class _SearchBarAppState extends State<SearchBarApp> {
  bool isDark = false;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return MaterialApp(
      theme: FlutterThemeData.lightThemeData,
      home: Scaffold(
        body: Stack(
          children: [
            Positioned(
              top: 35,
              child: GestureDetector(
                  onTap: () {
                    // 处理用户头像点击事件
                    print('User avatar clicked!');
                  },
                  child: CircleAvatar(
                    radius: 25.0, // 设置半径为50.0，调整大小
                    backgroundColor: FlutterThemeData.lightThemeData.primaryColor,
                    child: const Text('AH'),
                  )
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 30.0, horizontal: 65.0),
              child: SearchAnchor(
                  builder: (BuildContext context, SearchController controller) {
                    return SearchBar(
                      controller: controller,
                      padding: const MaterialStatePropertyAll<EdgeInsets>(
                          EdgeInsets.symmetric(horizontal: 16.0)),
                      onTap: () {
                        controller.openView();
                      },
                      onChanged: (_) {
                        controller.openView();
                      },
                      leading: const Icon(Icons.search),
                    );
                  }, suggestionsBuilder:
                  (BuildContext context, SearchController controller) {
                return List<ListTile>.generate(0, (int index) {
                  final String item = 'item $index';
                  return ListTile(
                    title: Text(item),
                    onTap: () {
                      setState(() {
                        controller.closeView(item);
                      });
                    },
                  );
                });
              }),
            ),
            Positioned(
              top: 35,
              right: 1,
              child:  FloatingActionButton(
                foregroundColor: colorScheme.primary,
                backgroundColor: colorScheme.surface,
                onPressed: () {
                  // Add your onPressed code here!
                },
                child: const IconTheme(
                  data: IconThemeData(
                    size: 30.0, // 设置图标大小为40.0
                  ),
                  child: Icon(Icons.mail),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
