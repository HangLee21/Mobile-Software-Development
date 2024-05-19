import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:forum/classes/notification_card.dart';
import 'package:forum/pages/chatpage.dart';
import 'package:forum/storage/notificationInfo_storage.dart';


// TODO change content according to the chat page
class NotificationCard extends StatelessWidget{
  final String friendname;
  final String? content;
  final String? avatarurl;
  bool? remove = false;
  final String friendId;
  final String url;
  final int info_num;
  final VoidCallback onPressed;
  NotificationCard({super.key, required this.friendname, this.content, required this.url, this.avatarurl, required this.friendId, required this.info_num, required this.onPressed, this.remove});

  @override
  Widget build(BuildContext context){
    void pushPage(){
      if(remove == true){
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => ChatPage(userId: friendId))).then((value) => onPressed());
      }
      else{
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => ChatPage(userId: friendId))).then((value) => onPressed());
      }
    }

    return Card(
      child: Container(
        height: 80,
        child: InkWell(
          onTap: (){
            NotificationStorage().findNotification(friendId).then((notification) => {
              if(notification != null){
                NotificationStorage().saveNotification(NotificationInfo(
                  friendId: friendId,
                  content: notification.content,
                  info_num: 0,
                  time: notification.time
                )).then((value) => {
                  pushPage()
                })
              }});
          },
          onLongPress: ()=>_showPopupMenu(context),
          child: Row(
            children: [
              const SizedBox(width: 10,),
              CircleAvatar(
                radius: 30,
                // backgroundImage: NetworkImage(url),
              ),
              const SizedBox(width: 20,),
              Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        maxLines: 1,
                        friendname,
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 10,),
                      Text(
                        content != null? content!: '',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      )
                    ],
                  )
              ),
              if(info_num != 0)
                Container(
                  padding: EdgeInsets.all(2),
                  margin: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: BoxConstraints(
                    minWidth: 20,
                    minHeight: 20,
                  ),
                  child: Text(
                    '$info_num',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        )

      )

    );
  }

  void _showPopupMenu(BuildContext context) {
    final RenderBox overlay = Overlay.of(context)!.context.findRenderObject() as RenderBox;

    final RenderBox cardBox = context.findRenderObject() as RenderBox;

    final ThemeData theme = Theme.of(context);

    final RelativeRect position = RelativeRect.fromLTRB(
      MediaQuery.of(context).size.width - 100, // 从屏幕右侧向左偏移100像素
      cardBox.localToGlobal(cardBox.size.bottomRight(Offset.zero), ancestor: overlay).dy, // 与卡片底部对齐
      MediaQuery.of(context).size.width,
      overlay.size.height,
    );

    showMenu(
      context: context,
      position: position,
      items: [
        PopupMenuItem(
          child: ListTile(
            leading: Icon(Icons.delete),
            title: Text('删除'),
            onTap: () {
              // 处理删除操作
              Navigator.pop(context);
            },
          ),
        ),
      ],
    );
  }
}