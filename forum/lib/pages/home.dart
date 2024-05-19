import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:forum/components/content_card.dart';
import 'package:forum/constants.dart';
import 'package:forum/pages/workfield.dart';
import 'package:forum/url/user.dart';
import 'package:http/http.dart' as http;
import '../components/search_bar.dart';
import 'package:forum/components/media_card.dart';
import 'package:forum/components/card_list.dart';
import '../components/auto_switch_pageview.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../classes/localStorage.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with AutomaticKeepAliveClientMixin {
  List<CarouselCard> cards = [
    // CarouselCard(postId: 'chl', title: 'title', content: 'content', card_height: 100, asset: NetworkImage('https://img-blog.csdnimg.cn/fcc22710385e4edabccf2451d5f64a99.jpeg'))
  ];

  List<ContentCard> content_cards = [
  ];
  // SharedPreferences? sharedPreferences;
  @override
  void initState(){
    super.initState();
    //getRecommendWorks();
    getSingleChildScrollView();
  }

  // void initSharedPreference() async{
  //   sharedPreferences = await SharedPreferences.getInstance();
  // }

  void getSingleChildScrollView()async{
    requestGet('/api/cos/community/recommend_works_with_urls',
      {
        'Authorization': 'Bearer ${LocalStorage.getString('token') ?? '43432'}',
      },query: {
          'maxNum': '10'
      }).then((http.Response res) {
        if(res.statusCode == 200) {
          String decodedString1 = utf8.decode(res.bodyBytes);
          List posts = jsonDecode(decodedString1)['posts'];
          for( var post in posts){
            if(post['urls'][0] != ''){
              cards.add(CarouselCard(postId: post['postId'], title: post['title'], content: post['content'], card_height: 100, asset: NetworkImage(post['urls'][0])));
            }
          }
          print(cards);
          print('cards end');
          setState(() {

          });
        }
      }
    );
  }

  void getRecommendWorks() async{
    requestGet('/api/cos/community/recommend_works', {
      'Authorization': 'Bearer ${LocalStorage.getString('token') ?? '43432'}',
    },query: {
      'maxNum': '10'
    }).then((http.Response res) {
      if(res.statusCode == 200){
        String decodedString1 = utf8.decode(res.bodyBytes);
        List posts = json.decode(decodedString1)['posts'];
        content_cards.clear();
        for(var i in posts){
          requestGet('/api/user/get_user',
              {
                'Authorization': 'Bearer ${LocalStorage.getString('token')}',
              },query: {
                'userId': i['userId']
              }).then((http.Response res2){
                if(res2.statusCode == 200) {
                  String decodedString2 = utf8.decode(res2.bodyBytes);
                  Map body = jsonDecode(decodedString2) as Map;
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
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        ///点击响应事
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => WorkField('','',const [])));
        },
        ///长按提示
        tooltip: "创作",
        ///设置悬浮按钮的背景
        heroTag: 'other',
        // backgroundColor: Colors.lightBlueAccent,
        // ///获取焦点时显示的颜色
        // focusColor: Colors.green,
        // ///鼠标悬浮在按钮上时显示的颜色
        // hoverColor: Colors.yellow,
        // ///水波纹颜色
        // splashColor: Colors.deepPurple,
        // ///配制阴影高度 未点击时
        // elevation: 5.0,
        // ///配制阴影高度 点击时
        // highlightElevation: 20.0,
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
