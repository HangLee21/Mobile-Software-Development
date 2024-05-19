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
  ];

  List<ContentCard> content_cards = [
  ];
  // SharedPreferences? sharedPreferences;
  @override
  void initState(){
    super.initState();
    getRecommendWorks();
  }

  void getRecommendWorks() async{
    requestGet('/api/cos/community/recommend_works', {
      'Authorization': 'Bearer ${LocalStorage.getString('token') ?? '43432'}',
    },query: {
      'maxNum': '10'
    }).then((http.Response res) {
      print('1234');
      print(LocalStorage.getString('token'));
      print(res.statusCode);
      if(res.statusCode == 200){
        List posts = json.decode(res.body)['posts'];
        content_cards.clear();
        for(var i in posts){
          requestGet('/api/user/get_user',
              {
                'Authorization': 'Bearer ${LocalStorage.getString('token')}',
              },query: {
                'userId': i['userId']
              }).then((http.Response res2){
                print('12312312314');
                print(res2.statusCode);
                if(res2.statusCode == 200) {
                  Map body = json.decode(res2.body)['content'];
                  print(i['title']);
                  print(i['content']);
                  print(i['postId']);
                  print(body['userAvatar']);
                  print(body['userName']);

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
