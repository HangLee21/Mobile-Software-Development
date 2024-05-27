import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:forum/classes/localStorage.dart';
import 'package:forum/components/card_list.dart';
import 'package:forum/pages/chatpage.dart';
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
  CardList cards = const CardList(cards: []);
  ElevatedButton button = ElevatedButton(onPressed: (){}, child: Container());
  
  @override
  void initState(){
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      getPersonalInformation();
    });
  }

  Future<void> getPersonalInformation()async {
    EasyLoading.show(status: '加载中');
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
            List<ContentCard> _content_cards = [];
            for(Map post in body2['posts']){
              print(post);
              ContentCard card = ContentCard(title: post['title'], username: body['content']['userName'], avatar: body['content']['userAvatar'], content: post['content'], postId: post['postId'], userId: body['content']['userId'],media_urls: post['urls'].cast<String>(),type: 'personal',);
              _content_cards.add(card);
            }
            setState(() {
              cards = CardList(cards: _content_cards);
            });
          }
        });
        EasyLoading.dismiss();
      }
    });
    requestGet('/api/info/user/subscribe', {
      'Authorization': 'Bearer ${LocalStorage.getString('token')}'
    },query: {
      'userId': LocalStorage.getString('userId'),
      'subscribeId': widget.userId
    }).then((http.Response res){
      if(res.statusCode ==200){
        String decodedString1 = utf8.decode(res.bodyBytes);
        Map body = jsonDecode(decodedString1);
        bool subscribed = body['result'];
        if(subscribed){
            button = ElevatedButton(onPressed: cancel_subscribe, child: const Row(
              children: [
                Text('已关注'),
                Icon(Icons.check),
              ],
            ));

        }else{
            button = ElevatedButton(onPressed: subscribe, child: const Row(
              children: [
                Text('关注'),
                Icon(Icons.add),
              ],
            ));
        }
      }
    });
  }

  void subscribe()async{
    requestGet('/api/info/user/get_subscribe_others',
        {
          'Authorization': 'Bearer ${LocalStorage.getString('token')}',
        },query: {
          'your_userId': LocalStorage.getString('userId'),
          'another_userId': widget.userId
        }).then((http.Response res){
      if(res.statusCode == 200){
        setState(() {
          button = ElevatedButton(onPressed: cancel_subscribe, child: const Row(
            children: [
              Text('已关注'),
              Icon(Icons.check),
            ],
          ));
        });

      }
    });
  }
  
  void cancel_subscribe()async{
    requestDelete('/api/info/user/cancel_subscribe_others',
    {

    },
    {
      'Authorization': 'Bearer ${LocalStorage.getString('token')}',
      'Content-Type': 'application/json',
    },query: {
      'your_userId': LocalStorage.getString('userId'),
      'another_userId': widget.userId
    }).then((http.Response res){
      if(res.statusCode == 200){
        setState(() {
          button = ElevatedButton(onPressed: subscribe, child: const Row(
            children: [
              Text('关注'),
              Icon(Icons.add),
            ],
          ));
        });

      }
    });
  }

  @override
  Widget build(context){
    return Scaffold(
      appBar: AppBar(
          title: title,
          actions: [
            if(widget.userId != LocalStorage.getString('userId'))
              button,
            if(widget.userId != LocalStorage.getString('userId'))
              const SizedBox(width: 20,),
            if(widget.userId != LocalStorage.getString('userId'))
              IconButton(onPressed: (){
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => ChatPage(userId: widget.userId)));
              }, icon: Icon(Icons.message_rounded))
          ]
      ),
      body: ListView(
        children: [
          Container(
            alignment: Alignment.center,
            height: 150,
            child: Row(
              children: [
                const SizedBox(width: 20,),
                CircleAvatar(
                  foregroundImage: NetworkImage(avatar),
                  backgroundImage: const NetworkImage('https://android-1324918669.cos.ap-beijing.myqcloud.com/default_avatar_1.png'),
                  radius: 50,
                ),
                const SizedBox(width: 20,),
                Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                          children: [
                            // Text(sharedPreferences?.getString('userName')??'',
                            //     style: const TextStyle(
                            //       fontSize: 30,
                            //     )
                            // ),
                            Text(username,
                                style: const TextStyle(
                                  fontSize: 30,
                                )
                            ),
                          ]
                      ),
                      const SizedBox(height: 20),
                      Row(
                          children: [
                            Text(email,
                                style: const TextStyle(
                                    fontSize: 15,
                                )
                            ),
                          ]
                      ),

                    ]

                ),

              ],
            ),
          ),
          const Divider(),
          cards
        ],
      )
    );
  }

}