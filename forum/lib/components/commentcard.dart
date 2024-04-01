import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:forum/components/carousel.dart';
import 'package:forum/url/user.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CommentCard extends StatefulWidget {
  final String avatar;
  final String username;
  final String content;
  final int likes;
  final String time;
  final String commentId;
  final bool liked;
  final List<String> urls;
  const CommentCard(this.avatar, this.username, this.content, this.likes, this.time, this.commentId,this.liked,this.urls,{super.key, required});

  @override
  _CommentCard createState() => _CommentCard();
}
class _CommentCard extends State<CommentCard>{

  bool liked = false;
  int likes = 0;
  SharedPreferences? sharedPreferences;
  @override
  void initState(){
    super.initState();
    liked = widget.liked;
    likes = widget.likes;
    initLocalStorage();
  }

  void initLocalStorage()async{
    sharedPreferences = await SharedPreferences.getInstance();
  }


  //点赞
  void clickLike(){
    if(!liked){
      addLike();
    }else{
      cancelLike();
    }

  }

  void addLike()async{
    requestPost(
        '/api/info/comment/add_like',
        {
          'userId': sharedPreferences?.getString('userId'),
          'commentId': widget.commentId
        },
        {
          'Content-Type':'application/json',
          'Authorization': 'Bear ${sharedPreferences?.getString('token')}'
        }
    ).then((http.Response res){
      if(res.statusCode == 200){
        sharedPreferences?.setString('token', json.decode(res.body)['token']);
        setState(() {
          liked = !liked;
          likes++;
        });
      }else{
        EasyLoading.showError('点赞失败');
      }
    });
  }

  void cancelLike()async{
    requestDelete(
        '/api/info/comment/cancel_like',
        {
          'userId': sharedPreferences?.getString('userId'),
          'commentId': widget.commentId
        },
        {
          'Content-Type':'application/json',
          'Authorization': 'Bear ${sharedPreferences?.getString('token')}'
        }
    ).then((http.Response res){
      if(res.statusCode == 200){
        sharedPreferences?.setString('token', json.decode(res.body)['token']);
        setState(() {
          liked = !liked;
          likes--;
        });
      }else{
        EasyLoading.showError('取消点赞失败');
      }
    });
  }

  @override
  Widget build(BuildContext context){
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 5, 0, 5),
      child: Column(
        children: [
          Row(
            // crossAxisAlignment: CrossAxisAlignment.start,
            // mainAxisAlignment: MainAxisAlignment.start,
            children: [
              CircleAvatar(
                // backgroundImage: NetworkImage(avatar),
              ),
              const SizedBox(width: 10,),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.username,
                    style: TextStyle(
                    fontSize: 15,
                    color: Colors.lightBlueAccent[100]
                    ),
                  ),
                  Text(
                    widget.time,
                    style: const TextStyle(
                    fontSize: 10,
                    color: Colors.grey
                    ),
                  ),
                ],
              ),
              IconButton(
                  onPressed: (){
                    liked = !liked;
                  },
                  icon: AnimatedSwitcher(
                    duration: Duration(milliseconds: 200),
                    child: IconButton(
                      onPressed: (){
                        clickLike();
                      },
                      iconSize: 20,
                      icon: Icon(liked?Icons.favorite:Icons.favorite_border),key: ValueKey<bool>(liked),),
                  )
              ),
              Text(
                  likes.toString(),
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 15
                ),
              )
            ],
          ),
          if(widget.urls.isNotEmpty)
            Container(
              height: 100,
              child: CarouselDemo(fileNames: widget.urls),
            ),
          Row(
            // crossAxisAlignment: CrossAxisAlignment.start,
            // mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.fromLTRB(50, 10.0, 0.0, 0.0),
                child: Text(
                  widget.content,
                ),
              )

            ],
          )
        ],
      ),
    );
  }
}