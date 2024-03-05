import 'package:flutter/material.dart';
import '../components/search_bar.dart';
import 'package:forum/components/media_card.dart';
import 'package:forum/components/card_list.dart';

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
          child:  Column(
            children: [
              SearchBarApp(),
              CarouselCard(
                asset: const AssetImage(
                  'assets/studies/fortnightly_card.png',
                  package: 'flutter_gallery_assets',
                ),
                assetColor: Colors.white,
                assetDark: const AssetImage(
                  'assets/studies/fortnightly_card_dark.png',
                  package: 'flutter_gallery_assets',
                ),
                assetDarkColor: const Color(0xFF1F1F1F),
                studyRoute: '',
              ),
              Flexible(
                flex: 1,
                child: CardList(),
              ),
            ],
          )
        ),
      ),
    );
  }
}
