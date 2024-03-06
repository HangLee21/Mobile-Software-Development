import 'package:flutter/material.dart';
import 'package:forum/components/content_card.dart';
import '../components/search_bar.dart';
import 'package:forum/components/media_card.dart';
import 'package:forum/components/card_list.dart';
import '../components/auto_switch_pageview.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // TODO get cards from backend
  List<CarouselCard> cards = [
    CarouselCard(studyRoute: '', title: '通缉犯', content: '嫌犯越狱出逃', asset: AssetImage(
      'assets/images/1.jpg',
    ),card_height: 250,),
    CarouselCard(studyRoute: '', title: 'Test2', content: 'Content2', asset: AssetImage(
      'assets/images/jadeite.png',
    ),card_height: 250,),
    CarouselCard(studyRoute: '', title: 'Test3', content: 'Content3', card_height: 250,),
  ];

  List<ContentCard> content_cards = [
    ContentCard(title: 'Test1', content: 'Content1'),
    ContentCard(title: 'Test2', content: 'Content2'),
    ContentCard(title: 'Test3', content: 'Content3'),
    ContentCard(title: 'Test4', content: 'The following example builds on the previous one. In addition to providing a minimum dimension for the child Column, an IntrinsicHeight widget is used to force the column to be exactly as big as its contents. This constraint combines with the ConstrainedBox constraints discussed previously to ensure that the column becomes either as big as viewport, or as big as the contents, whichever is biggest.Both constraints must be used to get the desired effect. If only the IntrinsicHeight was specified, then the column would not grow to fit the entire viewport when its children were smaller than the whole screen. If only the size of the viewport was used, then the Column would overflow if the children were bigger than the viewport.The widget that is to grow to fit the remaining space so provided is wrapped in an Expanded widget.This technique is quite expensive, as it more or less requires that the contents of the viewport be laid out twice (once to find their intrinsic dimensions, and once to actually lay them out). The number of widgets within the column should therefore be kept small. Alternatively, subsets of the children that have known dimensions can be wrapped in a SizedBox that has tight vertical constraints, so that the intrinsic sizing algorithm can short-circuit the computation when it reaches those parts of the subtree.', media_urls: [
        'assets/images/jadeite.png',
        'assets/images/1.jpg'
    ], url: '',),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: SizedBox(
              height: double.infinity,
              child: Column(
                children: [
                  const SearchBarApp(),
                  Expanded(
                    child: SingleChildScrollView(
                    child:
                      Column(
                        children: [
                          SizedBox(
                              height: 300.0,
                              child: AutoSwitchPageView(cards: cards,)
                          ),
                          CardList(cards: content_cards,)
                        ],
                      ),
                    ),
                  ),
                ],
              )
          ),

      ),
    );
  }
}
