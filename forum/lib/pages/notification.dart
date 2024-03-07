import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import '../components/notificationcard.dart';

class NotificationPage extends StatefulWidget{
  @override
  _NotificationState createState() => _NotificationState();
}

class _NotificationState extends State<NotificationPage>{
  //TODO 获取消息列表
  List<NotificationCard> cards = [
    NotificationCard(friendname: '1', url: '', content: '111111111111111111111111111111111111111111111111111111111111111111111'),
    NotificationCard(friendname: '2', url: '', content: '2222'),
    NotificationCard(friendname: '3', url: '', content: '3333'),
  ];
  @override
  Widget build(BuildContext context){
    return ListView.builder(
      itemCount: cards.length,
      itemBuilder: (context,index){
        return cards[index];
      }
    );
  }
}