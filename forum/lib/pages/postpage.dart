import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:forum/components/carousel.dart';
import 'package:forum/components/commentcard.dart';
import 'package:forum/url/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class PostPage extends StatefulWidget{
  final String postId;
  const PostPage(this.postId, {super.key});
  @override
  _PostState createState() => _PostState();
}

class _PostState extends State<PostPage>{
  String username = '';
  String avatar = '';
  String title = '';
  // String content = '我发现很多人的手机换主题壁纸铃声就是不换字体，这是为什么？\n更新问题：本人只换了一ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd个楷体，感觉很好看，字库也很大，默字体不能覆盖的字都能显示，感觉比系统字体好看多了，为什么很多人的手机还在用冷冰冰的无衬线字体？';
  String content = '';
  String createAt = '';
  int likes = 0;
  int stars = 0;
  int views = 0;
  List<String> urls = [];
  bool liked = false;
  bool stared = false;
  late TextEditingController textEditingController;
  FocusNode myFocusNode = FocusNode();
  bool writing = false;
  List comments = [
    // {
    //   'avatar': '',
    //   'username': 'chl',
    //   'time': '2021/3/14',
    //   'content': '煞笔',
    //   'likes': 10,
    //   'commentId': ''
    // },
    // {
    //   'avatar': '',
    //   'username': 'chl',
    //   'time': '2021/3/14',
    //   'content': '若至',
    //   'likes': 10,
    //   'commentId': ''
    // }
  ];

  SharedPreferences? sharedPreferences;
  @override
  void initState(){
    myFocusNode.addListener(() {
      if(myFocusNode.hasFocus){
        setState(() {
          writing = true;
        });
      }else{
        setState(() {
          writing = false;
        });
      }
    });
    super.initState();
    textEditingController = TextEditingController();
    //TODO get post information
    initStorage();
    getInformation();
    getComments();
    getLikedAndStared();
  }

  void initStorage()async{
    sharedPreferences = await SharedPreferences.getInstance();
  }
  void getComments() async{
    requestGet('/api/cos/post/query_comments', {
      'Authorization': 'Bear ${sharedPreferences?.getString('token')}'
    },query: {
      'postId': widget.postId,
    }).then((http.Response res){
      if(res.statusCode == 200){
        Map body = json.decode(res.body);
        List _comments = body['comments'];
        if(_comments != []){
          comments.clear();
          for(Map comment in _comments){
            requestGet('/api/user/get_user', {
              'Authorization': 'Bear ${sharedPreferences?.getString('token')}'
            },query: {
              'userId': comment['commentUserId'],
            }).then((http.Response res2) {
              if(res2.statusCode == 200) {
                print('2002');
                requestGet('/api/info/comment/get_info', {
                  'Authorization': 'Bear ${sharedPreferences?.getString('token')}'
                },query: {
                  'userId': comment['commentUserId'],
                }).then((http.Response res3) {
                  if(res3.statusCode == 200) {
                    setState(() {
                      Map commentItem = {};
                      commentItem['content'] = comment['content'];
                      commentItem['time'] = comment['time'];
                      // commentItem['urls'] = comment['urls'];
                      commentItem['commentId'] = comment['commentId'];
                      commentItem['likes'] = comment['likes'];
                      print(comment['likes']);
                      commentItem['avatar'] = json.decode(res2.body)['content']['userAvatar'];
                      commentItem['username'] = json.decode(res2.body)['content']['userName'];
                      commentItem['liked'] = json.decode(res3.body)['commentInformation']['like'];
                      comments.add(commentItem);
                    });

                  }
                });

              }
            });
          }
        }
      }
    });
  }

  void getInformation()async{
    requestGet('/api/cos/post/query_work', {
      'Authorization': 'Bear ${sharedPreferences?.getString('token')}'
    },query: {
      'postId': widget.postId,
      'userId': sharedPreferences?.getString('userId')
    }).then((http.Response res){
      if(res.statusCode == 200){
        Map body = json.decode(res.body);
        sharedPreferences?.setString('token', body['token']);
        List posts = body['posts'];
        if(posts != []){
          Map post = posts[0];
          print(post);
          requestGet('/api/user/get_user', {
            'Authorization': 'Bear ${sharedPreferences?.getString('token')}'
          },query: {
            'userId': sharedPreferences?.getString('userId')
          }).then((http.Response res2) {
            if(res2.statusCode == 200) {
              setState(() {
                title = post['title'];
                content = post['content'];
                urls = post['urls'].cast<String>();
                // print(urls);
                createAt = post['time'];
                likes = post['likes'];
                stars = post['stars'];
                views = post['views'];
                username = json.decode(res2.body)['content']['userName'];
                avatar = json.decode(res2.body)['content']['userAvatar'];
              });
            }
          });
        }
      }
    });
  }
  
  void getLikedAndStared() async{
    requestGet('/api/info/post/get_info', {
      'Authorization': 'Bear ${sharedPreferences?.getString('token')}'
    },query: {
      'postId': widget.postId,
      'userId': sharedPreferences?.getString('userId')
    }).then((http.Response res) {
      if(res.statusCode == 200) {
        Map info = json.decode(res.body)['postInformation'];
        liked = info['like'];
        stared = info['star'];
      }
    });
  }

  @override
  void dispose() {
    // Clean up the focus node when the Form is disposed.
    textEditingController.dispose();
    myFocusNode.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context){
    return Scaffold(
      // resizeToAvoidBottomInset: true,
      appBar: AppBar(
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          children: [
            Expanded(
                flex: 1,
                child: Padding(
                    padding: const EdgeInsets.fromLTRB(20.0,0.0,20.0,0),
                    child: ListView(
                          shrinkWrap: true,
                          children: [
                            if(urls.isNotEmpty)
                              SizedBox(
                                height: 200,
                                child: CarouselDemo( fileNames: urls,),
                              ),

                            Text(title,style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),),
                            const SizedBox(height: 20,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      // backgroundImage: NetworkImage(avatar),
                                    ),
                                    const SizedBox(width: 20),
                                    Text(username,style: const TextStyle(
                                        fontSize: 20
                                    ),),
                                  ],
                                ),
                                ElevatedButton(
                                    onPressed: (){
                                      //TODO 关注
                                    },
                                    child: const Row(
                                      children: [
                                        Text('关注'),
                                        Icon(Icons.add),
                                      ],
                                    )
                                ),

                              ],
                            ),
                            // const SizedBox(height: 20,),
                            const SizedBox(height: 20,),
                            Text(
                              content,
                              style: const TextStyle(
                                  height: 2
                              ),
                            ),
                            const SizedBox(height: 10,),
                            Row(
                              children: [
                                Text(
                                  createAt,
                                  style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey
                                  ),
                                ),
                                const SizedBox(width: 20,),
                                Text(
                                  '$views人次浏览',
                                  style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey
                                  ),
                                )
                              ],
                            )
                            ,
                            //TODO 评论区
                            const Divider(height: 20,),
                            for(var i in comments)
                              CommentCard(i['avatar'], i['username'], i['content'], i['likes'], i['time'], i['commentId']),
                            const SizedBox(height: 20,),
                            const Text(
                              '已到达底部',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 20,),
                          ],
                        )
                )
            ),
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child:AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.fromLTRB(15, 10, 0, 10),
                      constraints: const BoxConstraints(
                        maxHeight: 100.0,
                        minHeight: 50.0,
                      ),
                      decoration: const BoxDecoration(
                          color:  Color(0xFFF5F6FF),
                          borderRadius: BorderRadius.all(Radius.circular(2))
                      ),
                      child: TextField(
                        focusNode: myFocusNode,
                        onEditingComplete: (){
                        },
                        controller: textEditingController,
                        cursorColor:Color(0xFF464EB5),
                        maxLines: null,
                        // maxLength: 200,
                        decoration: const InputDecoration(
                          counterText: '',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.only(
                              left: 16.0, right: 16.0, top: 10.0, bottom:10.0),
                          hintText: "分享你的观点",
                          hintStyle: TextStyle(
                              color: Color(0xFFADB3BA),
                              fontSize:15
                          ),
                        ),
                        style: const TextStyle(
                            color: Color(0xFF03073C),
                            fontSize:15
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                      alignment: Alignment.center,
                      height: 70,
                      child: const Text(
                        '发送',
                        style: TextStyle(
                          color: Color(0xFF464EB5),
                          fontSize: 14,
                        ),
                      ),
                    ),
                    onTap: () {
                      // sendTxt();
                    },
                  ),

                  AnimatedContainer(
                      width: writing ? 0 : 45,
                      // height: writing ? 0 : 50,
                      duration: Duration(milliseconds: 300),
                      child: Badge(
                        offset: Offset(-10,0),
                        isLabelVisible: !writing,
                        label: Text(likes<=99?likes.toString():'99+'),
                        // backgroundColor: Colors.transparent,
                        child: AnimatedSwitcher(
                          duration: Duration(milliseconds: 200),
                          child: IconButton(
                            onPressed: (){
                              //TODO
                              setState(() {
                                liked = !liked;
                              });
                            },
                            icon: Icon(liked?Icons.favorite:Icons.favorite_border),key: ValueKey<bool>(liked),),
                        )
                      )

                  ),
                  AnimatedContainer(
                      width: writing ? 0 : 45,
                      // height: writing ? 0 : 50,
                      duration: Duration(milliseconds: 150),
                      child: Badge(
                        offset: Offset(-10,0),
                        isLabelVisible: !writing,
                        label: Text(stars<=99?stars.toString():'99+'),
                        // backgroundColor: Colors.red,
                        child: AnimatedSwitcher(
                          duration: Duration(milliseconds: 200),
                          child: IconButton(
                            onPressed: (){
                              //TODO
                              setState(() {
                                stared = !stared;
                              });
                            },
                            icon: Icon(stared?Icons.star:Icons.star_border),key: ValueKey<bool>(stared),),
                        )
                      )
                  )
                ],
              ),
            ),
          ],
        ),
      )


    );
  }
}