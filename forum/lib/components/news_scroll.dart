import 'dart:async';
import 'package:flutter/material.dart';

class NewsScrollWidget extends StatefulWidget {
  @override
  _NewsScrollWidgetState createState() => _NewsScrollWidgetState();
}

class _NewsScrollWidgetState extends State<NewsScrollWidget> {
  List<String> newsList = [
    'News 1',
    'News 2',
    'News 3',
    // Add more news items as needed
  ];

  int currentIndex = 0;

  @override
  void initState() {
    super.initState();

    // Start the timer to scroll news every 3 seconds
    Timer.periodic(Duration(seconds: 3), (timer) {
      setState(() {
        currentIndex = (currentIndex + 1) % newsList.length;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Latest News',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        Text(
          newsList[currentIndex],
          style: TextStyle(fontSize: 18),
        ),
      ],
    );
  }
}
