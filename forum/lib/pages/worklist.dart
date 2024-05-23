import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:forum/components/card_list.dart';
import 'package:forum/components/content_card.dart';
import 'package:http/http.dart' as http;
import '../classes/localStorage.dart';
import '../url/user.dart';
import 'navigation.dart';

class WorkList extends StatefulWidget{

  @override
  WorkListState createState()=>WorkListState();
}

class WorkListState extends State<WorkList>  with SingleTickerProviderStateMixin{
  //TODO 获取作品列表
  List<ContentCard> content_cards = [
    // ContentCard(title: 'Test1', content: 'Content1', postId: '',),
    // ContentCard(title: 'Test2', content: 'Content2', postId: '',),
    // ContentCard(title: 'Test3', content: 'Content3', postId: '',),
    // ContentCard(title: 'Test4', content: 'The following example builds on the previous one. In addition to providing a minimum dimension for the child Column, an IntrinsicHeight widget is used to force the column to be exactly as big as its contents. This constraint combines with the ConstrainedBox constraints discussed previously to ensure that the column becomes either as big as viewport, or as big as the contents, whichever is biggest.Both constraints must be used to get the desired effect. If only the IntrinsicHeight was specified, then the column would not grow to fit the entire viewport when its children were smaller than the whole screen. If only the size of the viewport was used, then the Column would overflow if the children were bigger than the viewport.The widget that is to grow to fit the remaining space so provided is wrapped in an Expanded widget.This technique is quite expensive, as it more or less requires that the contents of the viewport be laid out twice (once to find their intrinsic dimensions, and once to actually lay them out). The number of widgets within the column should therefore be kept small. Alternatively, subsets of the children that have known dimensions can be wrapped in a SizedBox that has tight vertical constraints, so that the intrinsic sizing algorithm can short-circuit the computation when it reaches those parts of the subtree.', media_urls: [
    //   'assets/images/jadeite.png',
    //   'assets/images/1.jpg'
    // ], postId: '',),
  ];

  CardList worklist = CardList(cards: []);
  CardList draftlist = CardList(cards: []);

  late TabController tabcontroller;

  String username = LocalStorage.getString('userName')??'chl';
  String userId = LocalStorage.getString('userId')??'111';
  String userAvatar = LocalStorage.getString('userAvatar')??'';

  @override
  void initState(){
    super.initState();
    tabcontroller = TabController(
        vsync: this,    // 动画效果的异步处理
        length: 2       // tab 个数
    );
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      getWorks();
      getDrafts();
    });
  }

  Future<void> getWorks()async {
    EasyLoading.show(status: '加载中');
    requestGet('/api/cos/user/query_work', {
      'Authorization': 'Bearer ${LocalStorage.getString('token')}'
    },query: {
      'userId': LocalStorage.getString('userId')
    }).then((http.Response res){
      if (res.statusCode == 200) {
        String decodedString = utf8.decode(res.bodyBytes);
        Map body = jsonDecode(decodedString);
        LocalStorage.setString('token', body['token']);
        List<ContentCard> _content_cards = [];
        for(Map post in body['posts']){
          print(post);
          print('username: $username');

          ContentCard card = ContentCard(title: post['title'], username: username, avatar: userAvatar, content: post['content'], postId: post['postId'], userId: userId,media_urls: post['urls'].cast<String>(),type: 'personal',);
          _content_cards.add(card);
        }
        setState(() {
          worklist = CardList(cards: _content_cards);
        });

      }
    });
    EasyLoading.dismiss();
  }

  Future<void> getDrafts()async {
    EasyLoading.show(status: '加载中');
    requestGet('/api/cos/user/query_draft', {
      'Authorization': 'Bearer ${LocalStorage.getString('token')}'
    },query: {
      'userId': LocalStorage.getString('userId')
    }).then((http.Response res){
      if (res.statusCode == 200) {
        String decodedString = utf8.decode(res.bodyBytes);
        Map body = jsonDecode(decodedString);
        LocalStorage.setString('token', body['token']);
        List<ContentCard> _content_cards = [];
        for(Map post in body['posts']){
          print(post);
          print('username: $username');

          ContentCard card = ContentCard(title: post['title'], username: username, avatar: userAvatar, content: post['content'], postId: post['postId'], userId: userId,media_urls: post['urls'].cast<String>(), type: 'draft',deletePost: (){
            deleteDraft(post['postId']);
          },);
          _content_cards.add(card);
        }
        setState(() {
          draftlist = CardList(cards: _content_cards);
        });

      }
    });
    EasyLoading.dismiss();
  }

  void deleteDraft(String postId)async{
    requestDelete('/api/cos/delete_draft', {
      'userId': LocalStorage.getString('userId'),
      'postId': postId,
    }, {
      'Authorization': 'Bearer ${LocalStorage.getString('token')}',
      'Content-Type': 'application/json'
    }).then((http.Response res){
      if(res.statusCode == 200){
        String decodedString = utf8.decode(res.bodyBytes);
        Map body = jsonDecode(decodedString);
        LocalStorage.setString('token', body['token']);
        getDrafts();
      }
    });
  }

  @override
  void dispose() {
    tabcontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
          bottom: TabBar(
            controller: tabcontroller,
            tabs: [
              Tab(text: '作品',),
              Tab(text: '草稿'),
            ],
          ),
          title: const Text(
              '我的创作'
          )
      ),
      body: Center(
        child: TabBarView(
          controller: tabcontroller,
          children: [
            ListView(
              children: [
                worklist
              ]
            ),
            ListView(
              children: [
                draftlist
              ]
            ),
          ],
        ),
      ),
    );
  }
}