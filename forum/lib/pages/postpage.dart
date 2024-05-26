import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:forum/classes/localStorage.dart';
import 'package:forum/components/carousel.dart';
import 'package:forum/components/commentcard.dart';
import 'package:forum/url/user.dart';
import 'package:like_button/like_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_easyloading/flutter_easyloading.dart';

import '../constants.dart';

class PostPage extends StatefulWidget{
  final String postId;
  const PostPage(this.postId, {super.key});
  @override
  _PostState createState() => _PostState();
}

class _PostState extends State<PostPage>{
  late String username = '';
  late String avatar = '';
  late String title = '';
  // String content = '我发现很多人的手机换主题壁纸铃声就是不换字体，这是为什么？\n更新问题：本人只换了一ddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd个楷体，感觉很好看，字库也很大，默字体不能覆盖的字都能显示，感觉比系统字体好看多了，为什么很多人的手机还在用冷冰冰的无衬线字体？';
  late String content = '';
  late String createAt = '';
  late int likes = 0;
  late int stars = 0;
  late int views = 0;
  late List<String> urls = [];
  late bool liked = false;
  late bool stared = false;
  late bool subscribed = false;
  late TextEditingController textEditingController;
  FocusNode myFocusNode = FocusNode();
  bool writing = false;
  late String authorId = '';
  List comments = [
  ];

  SharedPreferences? sharedPreferences;
  @override
  void initState(){

    myFocusNode.addListener(() {
      if(myFocusNode.hasFocus){
        setState(() {
          writing = false;
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
    addViews();
  }

  void initStorage()async{
    sharedPreferences = await SharedPreferences.getInstance();
  }
  void getComments() async{
    requestGet('/api/cos/post/query_comments', {
      'Authorization': 'Bearer ${LocalStorage.getString('token')}' ?? ''
    },query: {
      'postId': widget.postId,
    }).then((http.Response res){
      if(res.statusCode == 200){
        String decodedString = utf8.decode(res.bodyBytes);
        Map body = jsonDecode(decodedString) as Map;
        List _comments = body['comments'];
        if(_comments != []){
          comments.clear();
          for(Map comment in _comments){
            requestGet('/api/user/get_user', {
              'Authorization': 'Bearer ${LocalStorage.getString('token')}' ?? ''
            },query: {
              'userId': comment['commentUserId'],
            }).then((http.Response res2) {
              if(res2.statusCode == 200) {
                String decodedString = utf8.decode(res2.bodyBytes);
                Map body2 = jsonDecode(decodedString) as Map;
                requestGet('/api/info/comment/get_info', {
                  'Authorization': 'Bearer ${LocalStorage.getString('token')}' ?? ''
                },query: {
                  'userId': comment['commentUserId'],
                  'commentId': comment['commentId'],
                }).then((http.Response res3) {
                  // TODO
                  //print(res3.body);
                  if(res3.statusCode == 200) {
                    String decodedString = utf8.decode(res3.bodyBytes);
                    Map body3 = jsonDecode(decodedString) as Map;
                    setState(() {
                      Map commentItem = {};
                      commentItem['content'] = comment['content'];
                      commentItem['time'] = comment['time'];
                      commentItem['urls'] = comment['urls'].cast<String>();;
                      commentItem['commentId'] = comment['commentId'];
                      commentItem['likes'] = comment['likes'];
                      // print(comment['likes']);
                      commentItem['avatar'] = body2['content']['userAvatar'];
                      commentItem['username'] = body2['content']['userName'];
                      commentItem['liked'] = body3['commentInformation']['like'];
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
      'Authorization': 'Bearer ${LocalStorage.getString('token')}' ?? ''
    },query: {
      'postId': widget.postId,
      'userId': LocalStorage.getString('userId')
    }).then((http.Response res){
      if(res.statusCode == 200){
        String decodedString = utf8.decode(res.bodyBytes);
        Map body = jsonDecode(decodedString) as Map;
        LocalStorage.setString('token', body['token']);
        List posts = body['posts'];
        if(posts != []){
          Map post = posts[0];
          requestGet('/api/user/get_user', {
            'Authorization': 'Bearer ${LocalStorage.getString('token')}' ?? ''
          },query: {
            'userId': post['userId'],
          }).then((http.Response res2) {
            if(res2.statusCode == 200) {
              String decodedString = utf8.decode(res2.bodyBytes);
              Map body2 = jsonDecode(decodedString) as Map;
              setState(() {
                title = post['title'];
                content = post['content'];
                urls = post['urls'].cast<String>();
                // print(urls);
                createAt = post['time'];
                likes = post['likes'];
                stars = post['stars'];
                views = post['views'];
                username = body2['content']['userName'];
                avatar = body2['content']['userAvatar'];
                authorId = post['userId'];
                //print(authorId);
              });
              checkSubscribed();
            }
          });
        }
      }
    });
  }
  
  void getLikedAndStared() async{
    requestGet('/api/info/post/get_info', {
      'Authorization': 'Bearer ${LocalStorage.getString('token')}' ?? ''
    },query: {
      'postId': widget.postId,
      'userId': LocalStorage.getString('userId')
    }).then((http.Response res) {
      if(res.statusCode == 200) {
        Map info = json.decode(res.body)['postInformation'];
        liked = info['like'];
        stared = info['star'];
      }
    });
  }

  void addViews() {
    requestPost('/api/info/post/update_view', {
      'postId': widget.postId,
      'userId': LocalStorage.getString('userId') ?? ''
    },{
    'Authorization': 'Bearer ${LocalStorage.getString('token')}' ?? ''
    }).then((http.Response res) {
      // print(res.body);
      if(res.statusCode == 200) {
        setState(() {
          views += 1;
        });
      }
    });
  }

  void getSubscribed() {
    requestGet('/api/info/user/get_subscribe_others',{
      'Authorization': 'Bearer ${LocalStorage.getString('token')}' ?? ''
    },query: {
      'another_userId': authorId,
      'your_userId': LocalStorage.getString('userId')
    }).then((http.Response res) {
      //print(authorId);
      //print(res.body);
      if (res.statusCode == 200) {
        setState(() {
          subscribed = true;
        });
      }
    });
  }

  void cancelSubscribed() {
    requestDelete('/api/info/user/cancel_subscribe_others',{

    },{
      'Authorization': 'Bearer ${LocalStorage.getString('token')}' ?? ''
    },query: {
      'another_userId': authorId,
      'your_userId': LocalStorage.getString('userId')
    }).then((http.Response res) {
      //print(res.body);
      if (res.statusCode == 200) {
        setState(() {
          subscribed = false;
        });
      }
    });
  }

  void handelSubscribe() {
    if(subscribed){
      cancelSubscribed();
    }else{
      getSubscribed();
    }
  }

  void checkSubscribed() {
    requestGet('/api/info/user/subscribe', {
      'Authorization': 'Bearer ${LocalStorage.getString('token')}' ?? ''
    }, query: {
      'subscribeId': authorId,
      'userId': LocalStorage.getString('userId')
    }).then((http.Response res) {
      if (res.statusCode == 200) {
        setState(() {
          subscribed = json.decode(res.body)['result'];
        });
      }
    });
  }

  void addLike() {
    if(!liked){
      requestPost('/api/info/post/add_like', {
        'postId': widget.postId,
        'userId': LocalStorage.getString('userId') ?? ''
      }, {
        'Authorization': 'Bearer ${LocalStorage.getString('token')}' ?? ''
      }
      ).then((http.Response res) {
        //print(res.body);
        if (res.statusCode == 200) {
          setState(() {
            liked = true;
            likes += 1;
          });
        }
      });
    }
  }

  void cancelLike() {
    if(liked){
      requestDelete('/api/info/post/cancel_like', {
        'postId': widget.postId,
        'userId': LocalStorage.getString('userId') ?? ''
      }, {
        'Authorization': 'Bearer ${LocalStorage.getString('token')}' ?? ''
      }).then((http.Response res) {
        //print(res.body);
        if (res.statusCode == 200) {
          setState(() {
            liked = false;
            likes -= 1;
          });
        }
      });
    }
  }

  void addStar() {
    if(!stared){
      requestPost('/api/info/post/add_star', {
        'postId': widget.postId,
        'userId': LocalStorage.getString('userId') ?? ''
      }, {
        'Authorization': 'Bearer ${LocalStorage.getString('token')}' ?? '',
      }).then((http.Response res) {
        //print(res.body);
        if (res.statusCode == 200) {
          setState(() {
            stared = true;
            stars += 1;
          });
        }
      });
    }
  }

  void cancelStar() {
    if(stared){
      requestDelete('/api/info/post/cancel_star', {
        'postId': widget.postId,
        'userId': LocalStorage.getString('userId') ?? ''
      }, {
        'Authorization': 'Bearer ${LocalStorage.getString('token')}' ?? '',
      }).then((http.Response res) {
        //print(res.body);
        if (res.statusCode == 200) {
          setState(() {
            stared = false;
            stars -= 1;
          });
        }
      });
    }
  }


  @override
  void dispose() {
    // Clean up the focus node when the Form is disposed.
    textEditingController.dispose();
    myFocusNode.dispose();
    super.dispose();
  }

  _subscribeButton(){
    // if(authorId == LocalStorage.getString('userId')){
    //   return const Text('无法关注自己');
    // }
    if(!subscribed){
      return const Row(
      children: [
        Text('关注'),
        Icon(Icons.add),
        ],
      );
    }
    else{
      return const Row(
      children: [
        Text('已关注'),
        Icon(Icons.check),
        ],
      );
    }
  }

  void addComment() {
    requestGet('/api/cos/get_commentId', {
      'Authorization': 'Bearer ${LocalStorage.getString('token')}' ?? ''
    }).then((http.Response res) async {
      if (res.statusCode == 200) {
        String commentId = json.decode(res.body)['content'];
        requestPost('/api/cos/post_comment_text', {

        }, {
          'Authorization': 'Bearer ${LocalStorage.getString('token')}' ?? ''
        },query: {
          'commentId': commentId,
          'postId': widget.postId,
          'commentUserId': LocalStorage.getString('userId') ?? '',
          'content': textEditingController.text
        }).then((http.Response res) {
          //print(res.body);
          if (res.statusCode == 200) {
            List<String> urls = [];
            setState(() {
              //CommentCard(i['avatar'], i['username'], i['content'], i['likes'], i['time'], i['commentId'],i['liked'],i['urls']),
              comments.add({
                'commentId': commentId,
                'content': textEditingController.text,
                'time': DateTime.now().toString(),
                'username': LocalStorage.getString('userName'),
                'avatar': LocalStorage.getString('userAvatar'),
                'likes': 0,
                'liked': false,
                'urls': urls,
              });
              textEditingController.clear();
            });
          }
        });
    }
    });
  }
  Future<bool> onLikeButtonTapped(bool isLiked) async{
    setState(() {
      if(liked == true){
        cancelLike();
      }else{
        addLike();
      }
    });
    return !isLiked;
  }

  Future<bool> onStarButtonTapped(bool isLiked) async{
    setState(() {
      if(stared == true){
        cancelStar();
      }else{
        addStar();
      }
    });
    return !isLiked;
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
                                      backgroundImage: NetworkImage(avatar),
                                    ),
                                    const SizedBox(width: 20),
                                    Text(username,style: const TextStyle(
                                        fontSize: 20
                                    ),),
                                  ],
                                ),
                                ElevatedButton(
                                    onPressed: (){
                                      handelSubscribe();
                                    },
                                    child: _subscribeButton()
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
                            const Divider(height: 20,),
                            for(var i in comments)
                              CommentCard(i['avatar'], i['username'], i['content'], i['likes'], i['time'], i['commentId'],i['liked'],i['urls']),
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
                      addComment();
                    },
                  ),

                  AnimatedContainer(
                      width: writing ? 0 : 45,
                      // height: writing ? 0 : 50,
                      duration: Duration(milliseconds: 300),
                      child: AnimatedSwitcher(
                          duration: Duration(milliseconds: 200),
                          child: LikeButton(
                              likeCount: likes > 0 ? likes : 0,
                              isLiked: liked,
                              circleColor:
                              CircleColor(start: Color(0xff00ddff), end: Color(0xff0099cc)),
                              bubblesColor: BubblesColor(
                                dotPrimaryColor: Color(0xff33b5e5),
                                dotSecondaryColor: Color(0xff0099cc),
                              ),
                              likeBuilder: (bool isLiked) {
                                return Icon(
                                  Icons.favorite,
                                  color: isLiked ? Colors.redAccent : Colors.grey,
                                );
                              },
                            onTap: onLikeButtonTapped
                          ),
                          // child: IconButton(
                          //   onPressed: (){
                          //     setState(() {
                          //       if(liked == true){
                          //         cancelLike();
                          //       }else{
                          //         addLike();
                          //       }
                          //     });
                          //   },
                          //   icon: Icon(liked?Icons.favorite:Icons.favorite_border),key: ValueKey<bool>(liked),),
                        )
                  ),
                  // AnimatedContainer(
                  //   duration: Duration(milliseconds: 300),
                  //   width: writing ? 0 : 20,
                  //   child: Text(
                  //       likes > 0? likes > 99 ? '99+' : likes.toString(): '',
                  //       style: TextStyle(
                  //         fontSize: writing?0:15,
                  //         color: Colors.grey
                  //       ),
                  //   )
                  // ),
                  AnimatedContainer(
                      margin: const EdgeInsets.fromLTRB(0,0,15,0),
                      width: writing ? 0 : 45,
                      // height: writing ? 0 : 50,
                      duration: Duration(milliseconds: 150),
                      child: AnimatedSwitcher(
                        duration: Duration(milliseconds: 200),
                        child: LikeButton(
                            key: ValueKey<bool>(stared),
                            likeCount: stars > 0 ? stars : 0,
                            isLiked: stared,
                            circleColor:
                            CircleColor(start: Color(0xff00ddff), end: Color(0xff0099cc)),
                            bubblesColor: BubblesColor(
                              dotPrimaryColor: Color(0xff33b5e5),
                              dotSecondaryColor: Color(0xff0099cc),
                            ),
                            likeBuilder: (bool isLiked) {
                              return Icon(
                                Icons.star,
                                color: isLiked ? Colors.amber : Colors.grey,
                              );
                            },
                            onTap: onStarButtonTapped
                        ),
                          // child: IconButton(
                          //   onPressed: (){
                          //     setState(() {
                          //       if(stared == true){
                          //         cancelStar();
                          //       }else{
                          //         addStar();
                          //       }
                          //     });
                          //   },
                          //   icon: Icon(stared?Icons.star:Icons.star_border),key: ValueKey<bool>(stared),),
                        )
                  ),
                  // AnimatedContainer(
                  //     duration: Duration(milliseconds: 300),
                  //     width: writing ? 0 : 20,
                  //     child: Text(
                  //       stars > 0? stars > 99 ? '99+' : stars.toString(): '',
                  //       style: TextStyle(
                  //           fontSize: writing?0:15,
                  //           color: Colors.grey
                  //       ),
                  //     )
                  // ),
                ],
              ),
            ),
          ],
        ),
      )
    );
  }
}