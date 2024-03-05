import 'package:flutter/material.dart';
import 'theme/theme_data.dart';
import 'pages/login.dart';
import 'pages/homepage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Bottom Navigation Bar',
      theme: FlutterThemeData.lightThemeData,
      home: LoginLayout(),
    );
  }
}


