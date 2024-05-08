import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:forum/components/card_list.dart';
import 'package:forum/components/content_card.dart';
import 'package:forum/components/fancard.dart';
import 'package:forum/url/user.dart';
import 'package:http/http.dart' as http;
import '../classes/localStorage.dart';
import 'navigation.dart';

class FavoriteList extends StatefulWidget{
  @override
  FavoriteListState createState() => FavoriteListState();
}

class FavoriteListState extends State<FavoriteList> {
  //TODO 获取关注列表
  List peoples = [];
  @override
  void initState(){
    super.initState();
    getNames();

  }

  void getNames(){
    requestGet(
      '/api/info/user/get_subscriptions',
      {
        'Authorization': 'Bearer ${LocalStorage.getString('token')}',
      },query: {
        'userId': LocalStorage.getString('userId'),
      }
    ).then((http.Response res){
      if (res.statusCode == 200){
        List userIds = json.decode(res.body)['userIds'];
        for (String fan in userIds){
          requestGet(
            '/api/user/get_user',
            {
              'Authorization': 'Bearer ${LocalStorage.getString('token')}',
            },query: {
              'userId': fan,
            }
          ).then((http.Response response){
            if (response.statusCode == 200){
              Map user = json.decode(response.body)['content'];
              print(user['userName']);
              setState(() {
                peoples = [...peoples,user];
              });
            }
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
          title: const Text(
              '我的关注'
          ),
      ),
      body: ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(), // 禁止内部ListView滚动
        itemCount: peoples.length,
        itemBuilder: (BuildContext context, int index) {
          return FanCard(peoples[index]['userAvatar'], peoples[index]['userName']);
        },
      )
    );
  }
}
