import 'package:flutter/material.dart';

class CommentCard extends StatelessWidget{
  final String avatar;
  final String username;
  final String content;
  final int likes;
  final String time;
  final String commentId;
  const CommentCard(this.avatar, this.username, this.content, this.likes, this.time, this.commentId,{super.key, required});
  @override
  Widget build(BuildContext context){
    return Container(
      // constraints: const BoxConstraints(
      //   minHeight: 50.0,
      // ),
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
                    username,
                    style: TextStyle(
                    fontSize: 20,
                    color: Colors.lightBlueAccent[100]
                    ),
                  ),
                  Text(
                    time,
                    style: const TextStyle(
                    fontSize: 10,
                    color: Colors.grey
                    ),
                  ),
                ],
              ),

            ],
          ),
          Row(
            // crossAxisAlignment: CrossAxisAlignment.start,
            // mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.fromLTRB(50, 10.0, 0.0, 0.0),
                child: Text(
                  content,
                ),
              )

            ],
          )
        ],
      ),
    );
  }
}