import 'package:flutter/material.dart';
import '../components/search_bar.dart';
import 'package:forum/components/media_card.dart';
import 'package:forum/components/card_list.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final cards = <Widget>[
    const CarouselCard(
      asset: AssetImage(
        'assets/studies/fortnightly_card.png',
        package: 'flutter_gallery_assets',
      ),
      assetColor: Colors.white,
      assetDark: AssetImage(
        'assets/studies/fortnightly_card_dark.png',
        package: 'flutter_gallery_assets',
      ),
      assetDarkColor: Color(0xFF1F1F1F),
      studyRoute: '',
    ),
    const CarouselCard(
      asset: AssetImage(
        'assets/studies/fortnightly_card.png',
        package: 'flutter_gallery_assets',
      ),
      assetColor: Colors.white,
      assetDark: AssetImage(
        'assets/studies/fortnightly_card_dark.png',
        package: 'flutter_gallery_assets',
      ),
      assetDarkColor: Color(0xFF1F1F1F),
      studyRoute: '',
    ),
    const CarouselCard(
      asset: AssetImage(
        'assets/studies/fortnightly_card.png',
        package: 'flutter_gallery_assets',
      ),
      assetColor: Colors.white,
      assetDark: AssetImage(
        'assets/studies/fortnightly_card_dark.png',
        package: 'flutter_gallery_assets',
      ),
      assetDarkColor: Color(0xFF1F1F1F),
      studyRoute: '',
    ),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // 在这里可以添加你的页面内容
        child: Center(
          child:  Column(
            children: [
              const SearchBarApp(),
              SizedBox(
                height: 200.0,
                child: PageView.builder(
                  itemCount: cards.length,
                  itemBuilder: (context, index) {
                    return cards[index];
                  },
                ),
              ),
              const Flexible(
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
