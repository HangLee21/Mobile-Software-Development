import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:forum/classes/localStorage.dart';
import 'package:forum/components/card_list.dart';
import 'package:forum/url/user.dart';
import 'package:http/http.dart' as http;

import '../components/content_card.dart';

class PersonalSpace extends StatefulWidget{

  final String userId;
  @override
  PersonalSpace(this.userId, {super.key});

  @override
  PersonalSpaceState createState()=> PersonalSpaceState();
}

class PersonalSpaceState extends State<PersonalSpace>{
  String username = 'chl';
  String avatar = '';
  Text title = Text('主页');
  String email = '';
  List<ContentCard> cardlist = [];
  CardList cards = CardList(cards: []);

  @override
  void initState(){
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      getPersonalInformation();
    });
  }

  Future<void> getPersonalInformation()async {
    if(widget.userId == ''){
      return;
    }
    requestGet('/api/user/get_user', {
      'Authorization': 'Bearer ${LocalStorage.getString('token')}'
    },query: {
      'userId': widget.userId
    }).then((http.Response res){
      if (res.statusCode == 200){
        String decodedString1 = utf8.decode(res.bodyBytes);
        Map body = jsonDecode(decodedString1);
        setState(() {
          username = body['content']['userName'];
          avatar = body['content']['userAvatar'];
          email = body['content']['userEmail'];
        });
        requestGet('/api/cos/user/query_work', {
          'Authorization': 'Bearer ${LocalStorage.getString('token')}'
        },query: {
          'userId': widget.userId
        }).then((http.Response res2) {
          if (res2.statusCode == 200) {
            String decodedString2 = utf8.decode(res2.bodyBytes);
            Map body2 = jsonDecode(decodedString2);
            LocalStorage.setString('token', body2['token']);
            cardlist.clear();
            for(Map post in body2['posts']){
              ContentCard card = ContentCard(title: post['title'], username: body['content']['userName'], avatar: body['content']['userAvatar'], content: post['content'], postId: post['postId'], media_urls: post['urls'].cast<String>(),type: 'home',);
              cardlist.add(card);
            }
            setState(() {
              cards = CardList(cards: cardlist);
            });
          }
        });
      }
    });
    

  }

  @override
  Widget build(context){
    return Scaffold(
      appBar: AppBar(
          title: title
      ),
      body: ListView(
        children: [
          cards
        ],
      )
    );
  }

}