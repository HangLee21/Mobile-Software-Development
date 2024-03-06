import 'package:flutter/material.dart';
import 'package:forum/pages/account.dart';
import 'package:forum/theme/theme_data.dart';
import 'package:forum/pages/home.dart';

class NavigationExample extends StatefulWidget {
  const NavigationExample({super.key});

  @override
  State<NavigationExample> createState() => _NavigationExampleState();
}

class _NavigationExampleState extends State<NavigationExample> {
  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },

        selectedIndex: currentPageIndex,
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
      body: <Widget>[
        /// Home page
        Card(
          shadowColor: Colors.transparent,
          margin: EdgeInsets.all(8.0),
          child: SizedBox.expand(
            child: Center(
              child: HomePage(),
            ),
          ),
        ),

        /// Notifications page
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              Card(
                child: ListTile(
                  leading: Icon(Icons.notifications_sharp),
                  title: Text('Notification 1'),
                  subtitle: Text('This is a notification'),
                ),
              ),
              Card(
                child: ListTile(
                  leading: Icon(Icons.notifications_sharp),
                  title: Text('Notification 2'),
                  subtitle: Text('This is a notification'),
                ),
              ),
            ],
          ),
        ),

        /// Account page
        const AccountPage("chl","2021011840")
        // ListView.builder(
        //   reverse: true,
        //   itemCount: 2,
        //   itemBuilder: (BuildContext context, int index) {
        //     if (index == 0) {
        //       return Align(
        //         alignment: Alignment.centerRight,
        //         child: Container(
        //           margin: const EdgeInsets.all(8.0),
        //           padding: const EdgeInsets.all(8.0),
        //           decoration: BoxDecoration(
        //             color: theme.colorScheme.primary,
        //             borderRadius: BorderRadius.circular(8.0),
        //           ),
        //           child: Text(
        //             'Hello',
        //             style: theme.textTheme.bodyLarge!
        //                 .copyWith(color: theme.colorScheme.onPrimary),
        //           ),
        //         ),
        //       );
        //     }
        //     return Align(
        //       alignment: Alignment.centerLeft,
        //       child: Container(
        //         margin: const EdgeInsets.all(8.0),
        //         padding: const EdgeInsets.all(8.0),
        //         decoration: BoxDecoration(
        //           color: theme.colorScheme.primary,
        //           borderRadius: BorderRadius.circular(8.0),
        //         ),
        //         child: Text(
        //           'Hi!',
        //           style: theme.textTheme.bodyLarge!
        //               .copyWith(color: theme.colorScheme.onPrimary),
        //         ),
        //       ),
        //     );
        //   },
        // ),
      ][currentPageIndex],
    );
  }
}
