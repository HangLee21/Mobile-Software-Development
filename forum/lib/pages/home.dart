import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:forum/components/content_card.dart';
import 'package:forum/constants.dart';
import 'package:forum/url/user.dart';
import 'package:http/http.dart' as http;
import '../components/search_bar.dart';
import 'package:forum/components/media_card.dart';
import 'package:forum/components/card_list.dart';
import '../components/auto_switch_pageview.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with AutomaticKeepAliveClientMixin {
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
    ContentCard(title: 'Test1', content: 'Content1', postId: '',),
    ContentCard(title: 'Test2', content: 'Content2', postId: '',),
    ContentCard(title: 'Test3', content: 'Content3', postId: '',),
    ContentCard(title: 'Test4', content: 'The following example builds on the previous one. In addition to providing a minimum dimension for the child Column, an IntrinsicHeight widget is used to force the column to be exactly as big as its contents. This constraint combines with the ConstrainedBox constraints discussed previously to ensure that the column becomes either as big as viewport, or as big as the contents, whichever is biggest.Both constraints must be used to get the desired effect. If only the IntrinsicHeight was specified, then the column would not grow to fit the entire viewport when its children were smaller than the whole screen. If only the size of the viewport was used, then the Column would overflow if the children were bigger than the viewport.The widget that is to grow to fit the remaining space so provided is wrapped in an Expanded widget.This technique is quite expensive, as it more or less requires that the contents of the viewport be laid out twice (once to find their intrinsic dimensions, and once to actually lay them out). The number of widgets within the column should therefore be kept small. Alternatively, subsets of the children that have known dimensions can be wrapped in a SizedBox that has tight vertical constraints, so that the intrinsic sizing algorithm can short-circuit the computation when it reaches those parts of the subtree.', media_urls: [
      'assets/images/jadeite.png',
      'assets/images/1.jpg'
    ], postId: '',),
  ];
  SharedPreferences? sharedPreferences;
  @override
  void initState(){
    super.initState();
    initSharedPreference();
    getRecommendWorks();
  }

  void initSharedPreference() async{
    sharedPreferences = await SharedPreferences.getInstance();
  }

  void getRecommendWorks() async{
    // print(Uri.http(BASEURL,'/api/cos/community/recommend_works_with_urls',{'maxNum': '10'}).toString());
    // var r = await http.get(Uri.parse('http://$BASEURL/api/cos/community/recommend_works_with_urls?maxNum=10'), headers: {
    //   'Authorization': 'Bear: fdsfd}',
    // }, );
    // print(r.statusCode.toString());
    requestGet('/api/cos/community/recommend_works_with_urls', {
      'Authorization': 'Bear: ${sharedPreferences?.getString('token')}',
    },query: {
      'maxNum': '10'
    }).then((http.Response res) {
      print('123');
      if(res.statusCode == 200){
        List posts = json.decode(res.body)['posts'];
        content_cards.clear();
        for(var i in posts){
          requestGet('/api/user/get_user',
              {
                'Authorization': 'Bearer ${sharedPreferences?.getString('token')}',
              },query: {
                'userId': i['userId']
              }).then((http.Response res2){
                if(res2.statusCode == 200) {
                  Map body = json.decode(res2.body)['content'];
                  ContentCard card = ContentCard(title: i['title'], content: i['content'], postId: i['postId'],avatar: body['userAvatar'],username: body['userName'],);
                  setState(() {
                    content_cards.add(card);
                  });
                }
          });
        }
      }

    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
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

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
