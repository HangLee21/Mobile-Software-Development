import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:forum/components/card_list.dart';
import 'package:forum/components/content_card.dart';
import 'package:forum/url/user.dart';
import 'package:http/http.dart' as http;
import '../classes/localStorage.dart';
import 'navigation.dart';

class StarList extends StatefulWidget{
  @override
  StarListState createState()=>StarListState();
}

class StarListState extends State<StarList>{
  //TODO 获取收藏列表
  List<ContentCard> content_cards = [
    // ContentCard(title: 'Test1', content: 'Content1', postId: '',),
    // ContentCard(title: 'Test2', content: 'Content2', postId: '',),
    // ContentCard(title: 'Test3', content: 'Content3', postId: '',),
    // ContentCard(title: 'Test4', content: 'The following example builds on the previous one. In addition to providing a minimum dimension for the child Column, an IntrinsicHeight widget is used to force the column to be exactly as big as its contents. This constraint combines with the ConstrainedBox constraints discussed previously to ensure that the column becomes either as big as viewport, or as big as the contents, whichever is biggest.Both constraints must be used to get the desired effect. If only the IntrinsicHeight was specified, then the column would not grow to fit the entire viewport when its children were smaller than the whole screen. If only the size of the viewport was used, then the Column would overflow if the children were bigger than the viewport.The widget that is to grow to fit the remaining space so provided is wrapped in an Expanded widget.This technique is quite expensive, as it more or less requires that the contents of the viewport be laid out twice (once to find their intrinsic dimensions, and once to actually lay them out). The number of widgets within the column should therefore be kept small. Alternatively, subsets of the children that have known dimensions can be wrapped in a SizedBox that has tight vertical constraints, so that the intrinsic sizing algorithm can short-circuit the computation when it reaches those parts of the subtree.', media_urls: [
    //   'assets/images/jadeite.png',
    //   'assets/images/1.jpg'
    // ], postId: ''),
  ];

  CardList card_list = CardList(cards: []);

  @override
  void initState(){
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      getStarList();
      print('content:$content_cards');
    });

  }

  Future<void> getStarList()async{
    List<ContentCard> _content_cards = [];
    EasyLoading.show(status: '加载中');
    await requestGet('/api/info/post/star_post', {
      'Authorization': 'Bearer ${LocalStorage.getString('token')}'
    },query: {
      'userId': LocalStorage.getString('userId')
    }).then((http.Response res){
      if(res.statusCode == 200){
        String decodedString1 = utf8.decode(res.bodyBytes);
        Map body = jsonDecode(decodedString1);
        LocalStorage.setString('token', body['token']);
        List posts = body['posts'];
        for(var post in posts){
          requestGet('/api/user/get_user', {
            'Authorization': 'Bearer ${LocalStorage.getString('token')}'
          }, query: {
            'userId': post['userId']
          }).then((http.Response res2){
            if(res2.statusCode == 200){
              print(2000);
              print(post);
              String decodedString2 = utf8.decode(res2.bodyBytes);
              Map user =  jsonDecode(decodedString2)['content'];
              print(user);
              List<String> urls = post['urls'].cast<String>();
              ContentCard card = ContentCard(title: post['title'], content: post['content'], postId: post['postId'], avatar: user['userAvatar'], username: user['userName'],userId: user['userId'],media_urls: post['urls'].cast<String>(),type: 'star',deletePost: (){
                deletePost(post['postId']);
              },);
              _content_cards.add(card);
              print('_content$_content_cards');
              setState(() {
                card_list = CardList(cards: _content_cards,);
              });
            }
          });
        }
      }
      EasyLoading.dismiss();
    });
  }

  void deletePost(String postId)async{
    EasyLoading.show(status: '删除中');
    String? userId = LocalStorage.getString('userId');
    requestDelete('/api/info/post/cancel_star', {
      'userId': userId,
      'postId': postId,
    }, {
      'Authorization': 'Bearer ${LocalStorage.getString('token')}',
      'Content-Type': 'application/json',
    }).then((http.Response res){
      if(res.statusCode == 200){
        print('delete successfully');
        getStarList();
      }
      EasyLoading.dismiss();
    });

  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
          title: const Text(
              '收藏'
          )
      ),
      body: ListView(
        children: [
          card_list
        ],
      )
    );
  }
}