import 'dart:convert';
import 'dart:developer' as developer;
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
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
    //CarouselCard(postId: 'chl', title: 'title', content: 'content', card_height: 400, asset: NetworkImage('https://img-blog.csdnimg.cn/fcc22710385e4edabccf2451d5f64a99.jpeg'))
  ];

  List<ContentCard> content_cards = [
  ];
  var autoswitchpageview;
  // SharedPreferences? sharedPreferences;
  @override
  void initState(){
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _fetchList();

    });
  }


  void _fetchList()async{
    await Future.delayed(Duration(milliseconds: 50),(){
      getRecommendWorks().then((result){
        setState(() {
          // print('setState');
          content_cards = result;
        });
      });
      getSingleChildScrollView().then((result){
        setState(() {
          // print('setState');
          // print('result:${result}');
          cards = result;
          autoswitchpageview = AutoSwitchPageView(key: UniqueKey(),cards: cards);
        });
      });
    });

  }
  // void initSharedPreference() async{
  //   sharedPreferences = await SharedPreferences.getInstance();
  // }

  Future<List<CarouselCard>> getSingleChildScrollView()async{
    List<CarouselCard> _cards = [];
    EasyLoading.show(status: '加载中');
    await requestGet('/api/cos/community/recommend_works_with_urls',
        {
          'Authorization': 'Bearer ${LocalStorage.getString('token') ?? ''}',
        },query: {
          'maxNum': '10'
        }).then((http.Response res) {
      if(res.statusCode == 200) {
        String decodedString1 = utf8.decode(res.bodyBytes);
        List posts = jsonDecode(decodedString1)['posts'];
        for(var post in posts){
          _cards.add(CarouselCard(postId: post['postId'], title: post['title'], content: post['content'], card_height: 240, asset: NetworkImage(post['urls'][0])));
        }
        EasyLoading.dismiss();
        return _cards;
      }else{
        EasyLoading.showError('获取顶部贴失败');
      }
      EasyLoading.dismiss();
      return _cards;
      }
    );
    EasyLoading.dismiss();
    return _cards;
  }

  Future<List<ContentCard>> getRecommendWorks() async{
    List<ContentCard> _content_cards = content_cards;
    EasyLoading.show(status: '加载中');
    await requestGet('/api/cos/community/recommend_works', {
      'Authorization': 'Bearer ${LocalStorage.getString('token') ?? ''}',
    },query: {
      'maxNum': '10'
    }).then((http.Response res) async {
      if(res.statusCode == 200){
        String decodedString1 = utf8.decode(res.bodyBytes);
        List posts = json.decode(decodedString1)['posts'];
        _content_cards.clear();
        for(var i in posts){
          await requestGet('/api/user/get_user',
              {
                'Authorization': 'Bearer ${LocalStorage.getString('token')}',
              },query: {
                'userId': i['userId']
              }).then((http.Response res2){
            if(res2.statusCode == 200) {
              String decodedString2 = utf8.decode(res2.bodyBytes);
              Map body = jsonDecode(decodedString2) as Map;
              //print(body);
              ContentCard card = ContentCard(title: i['title'], content: i['content'], postId: i['postId'],avatar: body['content']['userAvatar'],username: body['content']['userName'],userId: body['content']['userId'],media_urls: i['urls'].cast<String>(),type: 'home',);
              _content_cards.add(card);
              EasyLoading.dismiss();
              return _content_cards;
            }else{
              EasyLoading.showError('获取推荐贴失败');
            }
            EasyLoading.dismiss();
            return _content_cards;
          });
        }
      }else{
        EasyLoading.showError('获取推荐贴失败');
      }

    });
    EasyLoading.dismiss();
    return _content_cards;
  }

  void _refresh() async {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _fetchList();
      autoswitchpageview = AutoSwitchPageView(cards: cards==[]?[CarouselCard(postId: 'chl', title: 'title', content: 'content', card_height: 100, asset: NetworkImage('https://img-blog.csdnimg.cn/fcc22710385e4edabccf2451d5f64a99.jpeg'))]:cards);
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    // getRecommendWorks();
    // getSingleChildScrollView();
    return Scaffold(
      body: Center(
        child: SizedBox(
            height: double.infinity,
            child: Column(
              children: [
                const SearchBarApp(),
                Expanded(
                  child: EasyRefresh(
                    onRefresh: _refresh,
                    child: SingleChildScrollView(
                      child:
                      Column(
                        children: [
                          SizedBox(
                              height: 300.0,
                              child: autoswitchpageview
                          ),
                          CardList(cards: content_cards,)
                        ],
                      ),
                    ),
                  ),
                )
              ],
            )
        ),

      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        ///点击响应事
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => WorkField('')));
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
