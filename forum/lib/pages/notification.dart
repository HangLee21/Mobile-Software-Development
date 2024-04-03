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
  Map<String, Badge> cards = {};
  Map<String, NotificationInfo> _notificationInfos = {};
  List<Message> _messages = <Message>[];
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

  void init() async{
    NotificationStorage().loadNotifications().then((value) => setState(() {
      _notificationInfos = value;
      for(var info in _notificationInfos.values){
        cards[info.friendId] = Badge(
          label: Text('${info.info_num}'),
          child: NotificationCard(
            friendname: info.friendId,
            content: info.content,
            url: "",
            friendId: info.friendId,
          ),
        );
      }
    }));
    _websocketService.stream?.listen((message) async {
      setState(() {
        Message message1 = Message.fromString(message);
        _messages.add(message1);
        _notificationInfos[message1.senderId] = NotificationInfo(
          friendId: message1.senderId,
          time: message1.time,
          content: message1.content,
          info_num: 1,
        );
        cards[message1.senderId] = Badge(
          label: Text('1'),
          child: NotificationCard(
            friendname: message1.senderId,
            content: message1.content,
            url: "",
            friendId: message1.senderId,
          ),
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if(cards.isNotEmpty)
      return ListView.builder(
          itemCount: cards.length,
          itemBuilder: (context, index){
            return cards.values.elementAt(index);
          }
      );
    else
      return Center(
        child: Text('No notifications'),
      );
  }
}