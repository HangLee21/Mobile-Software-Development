import 'dart:async';

import 'package:flutter/material.dart';
import 'package:forum/classes/notification_card.dart';
import 'package:forum/storage/notificationInfo_storage.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import '../classes/message.dart';
import '../components/notificationcard.dart';
import '../url/websocket_service.dart';


class NotificationPage extends StatefulWidget{
  @override
  _NotificationState createState() => _NotificationState();
}

class _NotificationState extends State<NotificationPage>{
  final _websocketService = WebSocketService();
  Map<String, NotificationCard> cards = {};
  Map<String, NotificationInfo> _notificationInfos = {};
  List<Message> _messages = <Message>[];
  StreamSubscription<dynamic>? _streamSubscription;
  @override
  void initState(){
    super.initState();
    init();
  }

  List<NotificationInfo> mergeLists(List<NotificationInfo> listA, List<NotificationInfo> listB) {
    Map<String, NotificationInfo> NotificationInfoMap = {};

    // 将 ListA 中的消息添加到 messageMap 中
    for (var info in listA) {
      NotificationInfoMap[info.friendId] = info;
    }

    // 将 ListB 中的消息添加到 messageMap 中，如果 friendId 已存在则覆盖
    for (var info in listB) {
      NotificationInfoMap[info.friendId] = info;
    }

    // 返回合并后的消息列表
    return NotificationInfoMap.values.toList();
  }

  void _initNotifications(){
    NotificationStorage().loadNotifications().then((value) => setState(() {
      _notificationInfos = value;
      for(var info in _notificationInfos.values){
        cards[info.friendId] = NotificationCard(
          friendname: info.friendId,
          content: info.content,
          url: "",
          friendId: info.friendId,
          info_num: info.info_num,
          onPressed: _initNotifications,
        );
      }
    }));
  }

  void init() async{
    _initNotifications();
    _streamSubscription = _websocketService.stream?.listen((message) async {
      setState(() {
        Message message1 = Message.fromString(message);
        _messages.add(message1);
        String key = message1.senderId;
        int info_num = 0;
        // 检查是否存在键
        if (_notificationInfos.containsKey(key)) {
          // 如果存在，则获取现有的 NotificationInfo 对象
          NotificationInfo? existingInfo = _notificationInfos[key];
          info_num = existingInfo!.info_num + 1;
          _notificationInfos[message1.senderId] = NotificationInfo(
            friendId: message1.senderId,
            time: message1.time,
            content: message1.content,
            info_num: info_num,
          );
        } else {
          _notificationInfos[message1.senderId] = NotificationInfo(
            friendId: message1.senderId,
            time: message1.time,
            content: message1.content,
            info_num: 1,
          );
          info_num = 1;
        }
        cards[message1.senderId] = NotificationCard(
          friendname: message1.senderId,
          content: message1.content,
          url: "",
          friendId: message1.senderId,
          info_num: info_num,
          onPressed: _initNotifications,
        );
      });
    });
  }

  void dispose(){
    _streamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    if(cards.values.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(

        ),
        body: ListView.builder(
            itemCount: cards.length,
            itemBuilder: (context, index){
              return cards.values.elementAt(index);
            }
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(

        ),
        body: Center(
          child: Text('No notifications'),
        ),
      );
    }
  }
}