import 'package:flutter/material.dart';

class FanCard extends StatelessWidget{
  final String userAvatar;
  final String userName;
  @override
  FanCard(this.userAvatar, this.userName);
  @override
  Widget build(BuildContext context){
    return SizedBox(
      height: 90,
      child: Card(
          child: Row(
            children: [
              const SizedBox(
                width:10
              ),
              CircleAvatar(
                foregroundImage: NetworkImage(userAvatar),
                backgroundImage: NetworkImage('https://android-1324918669.cos.ap-beijing.myqcloud.com/default_avatar_1.png'),
                radius: 30,
              ),
              const SizedBox(
                  width:20
              ),
              Text(
                userName,
                style:const TextStyle(
                  fontSize: 18,
                )
              )
            ],
          )
      ),
    );
  }
}