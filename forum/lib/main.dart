import 'package:flutter/material.dart';
import 'package:forum/theme/theme_data.dart';
import 'pages/home.dart';
import 'pages/login.dart';
/// Flutter code sample for [NavigationBar].

void main() => runApp(const ForumApp());

class ForumApp extends StatelessWidget {
  const ForumApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // theme: FlutterThemeData.lightThemeData,
        theme: ThemeData(
          brightness: Brightness.light,
          colorSchemeSeed: Colors.blue,
          //启用
          useMaterial3: true,
        ),
      home: LoginLayout(),
    );
  }
}

