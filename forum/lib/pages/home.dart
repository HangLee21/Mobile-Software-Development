import 'package:flutter/material.dart';
import '../components/search_bar.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // 在这里可以添加你的页面内容
        child: const Center(
          child: SearchBarApp(),
        ),
      ),
    );
  }
}
