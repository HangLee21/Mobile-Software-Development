import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:forum/pages/chatpage.dart';

class NotificationCard extends StatelessWidget{
  final String friendname;
  final String? content;
  final String? avatarurl;
  final String friendId;
  final String url;
  NotificationCard({super.key, required this.friendname, this.content, required this.url, this.avatarurl, required this.friendId});
  @override
  Widget build(BuildContext context){
    return Card(
      child: Container(
        height: 80,
        child: InkWell(
          onTap: (){
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => ChatPage(userId: friendId)));
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
              Expanded(child: Column(
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
                  )
                  ,
                  const SizedBox(height: 10,),
                  Text(
                    content != null? content!: '',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  )
                ],
              )),

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