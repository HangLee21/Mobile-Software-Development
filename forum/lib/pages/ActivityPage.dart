import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:forum/components/content_card.dart';
import 'package:forum/constants.dart';
import 'package:forum/pages/personspace.dart';
import 'package:forum/pages/workfield.dart';
import 'package:forum/url/user.dart';
import 'package:http/http.dart' as http;
import '../components/search_bar.dart';
import 'package:forum/components/media_card.dart';
import 'package:forum/components/card_list.dart';
import '../components/auto_switch_pageview.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../classes/localStorage.dart';
import 'AIChatPage.dart';

class User {
  final String name;
  final String avatarUrl;
  final String userId;
  User(this.name, this.avatarUrl, this.userId);
}

class ActivityPage extends StatefulWidget {
  ActivityPage({super.key});
  @override
  _ActivityPageState createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> with AutomaticKeepAliveClientMixin {
  List<CarouselCard> cards = [
  ];

  List<ContentCard> content_cards = [
  ];

  List<String> userIds = [];

  int pageIndex = 0;
  int pageSize = 10;
  final List<User> users = [
    User('AI助手', 'https://android-1324918669.cos.ap-beijing.myqcloud.com/default_avatar.png', 'ai_assistant'),
  ];
  // SharedPreferences? sharedPreferences;
  @override
  void initState(){
    super.initState();
    getSubscriptions();
    content_cards.clear();
    getActivityWorks();
  }

  void getSubscriptions(){
    requestGet("/api/info/user/get_subscriptions", {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${LocalStorage.getString('token')}' ?? ''
    },query:  {
      'userId': LocalStorage.getString('userId')
    }).then((http.Response res) async {
      print(res.body);
      if(res.statusCode == 200){
        String decodedString = utf8.decode(res.bodyBytes);
        Map body = jsonDecode(decodedString) as Map;
        userIds = body['userIds'].cast<String>();
      }
      for(var i in userIds) {
        requestGet('/api/user/get_user',
            {
              'Authorization': 'Bearer ${LocalStorage.getString('token')}',
            }, query: {
              'userId': i
            }).then((http.Response res2) {
              print(res2.statusCode);
          if (res2.statusCode == 200) {
            String decodedString = utf8.decode(res2.bodyBytes);
            Map body2 = jsonDecode(decodedString) as Map;
            Map body3 = body2['content'];
            setState(() {
              users.add(User(body3['userName'], body3['userAvatar'], i));
            });
          }
        });
      }
    });
  }

  void getActivityWorks() async{
    requestGet("/api/cos/user/query_subscriptions_posts", {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${LocalStorage.getString('token')}' ?? ''
    },query:  {
      'userId': LocalStorage.getString('userId'),
      'pageIndex': pageIndex.toString(),
      'pageSize': pageSize.toString()
    }).then((http.Response res) {
      print(res.body);
      if(res.statusCode == 200){
        String decodedString1 = utf8.decode(res.bodyBytes);
        List posts = json.decode(decodedString1)['posts'];
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
              ContentCard card = ContentCard(title: i['title'], content: i['content'], postId: i['postId'],avatar: body['content']['userAvatar'],username: body['content']['userName'], userId: body['content']['userId'],media_urls: i['urls'].cast<String>(),type: 'home',);
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
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 100,
        title: const Center(
          child: Text(
            '关注列表',
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
            ),
          ),
        )
      ),
      body: Center(
        child: SizedBox(
            height: double.infinity,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child:
                    Column(
                      children: [
                        Container(
                          height: 120,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: users.length,
                            itemBuilder: (context, index) {
                              final user = users[index];
                              return GestureDetector(
                                onTap: () {
                                  if(user.userId == 'ai_assistant'){
                                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => AIChatPage(userId: 'ai_assistant',)));
                                  }
                                  else{
                                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => PersonalSpace(user.userId)));
                                  }
                                },
                                child: Container(
                                  width: 70,
                                  margin: EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Column(
                                    children: [
                                      CircleAvatar(
                                        backgroundImage: NetworkImage(user.avatarUrl),
                                        radius: 30,
                                      ),
                                      SizedBox(height: 8.0),
                                      Text(user.name),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        if (content_cards.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Text(
                              'No posts found for subscriptions',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 20,
                              ),
                            ),
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
