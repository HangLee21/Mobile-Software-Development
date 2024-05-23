import 'package:flutter/material.dart';
import 'package:forum/pages/personspace.dart';
import 'package:forum/pages/postpage.dart';
import 'carousel.dart';
import '../constants.dart';

class ContentCard extends StatelessWidget {
  ContentCard({
    super.key,
    required this.title,
    required this.content,
    this.media_urls,
    required this.postId,
    required this.userId,
    this.avatar,
    this.type,
    this.username,
    this.deletePost,
  });

  final String title;
  final String content;
  final String? avatar;
  final String? username;
  final List<String>? media_urls;
  final String? postId;
  final String? type;
  final String userId;
  final void Function()? deletePost;

  @override
  Widget build(BuildContext context) {
    final card_title = this.title;
    final card_content = this.content;
    final media_urls = this.media_urls;
    final avatar = this.avatar;
    // TODO

    return Center(
      child: Container(
        constraints: BoxConstraints(
          maxHeight: 300.0, // 设置最大高度
        ),
        child: GestureDetector(
          onLongPress: (){
            _showPopupMenu(context);
          },
          child: Card(
            // unless you need it.
            clipBehavior: Clip.hardEdge,
            child: InkWell(
              splashColor: Colors.blue.withAlpha(30),
              onTap: () {
                if(this.postId != null){
                  // Navigator.of(context)
                  //     .popUntil((route) => route.settings.name == '/');
                  // Navigator.of(context).restorablePushNamed(url!);
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => PostPage(postId!)));
                }
              },

              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  ListTile(
                    // leading: Icon(Icons.album),
                    leading: GestureDetector(
                      onTap: (){
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => PersonalSpace(userId)));
                      },
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(avatar??''),
                      ),
                    ),

                    title: GestureDetector(
                      onTap: (){
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => PersonalSpace(userId)));
                      },
                      child: Text(
                        card_title,
                        overflow: TextOverflow.ellipsis, // 设置溢出时显示省略号
                        maxLines: 2,
                      ),
                    ),
                    subtitle: Text(
                      card_content,
                      overflow: TextOverflow.ellipsis, // 设置溢出时显示省略号
                      maxLines: 2, // 设置最大行数
                    ),
                  ),
                  if(media_urls != null && media_urls.isNotEmpty)
                    SizedBox(
                      height: 200.0,
                      child: CarouselDemo(fileNames: media_urls,),
                      // child: SingleChildScrollView(
                      //   scrollDirection: Axis.horizontal,
                      //   child: Row(
                      //     children: List.generate(
                      //       this.media_urls!.length,
                      //           (index) => Container(
                      //         margin: EdgeInsets.all(8.0),
                      //         child: FadeInImage(
                      //           image: AssetImage(
                      //             this.media_urls![index],
                      //           ),
                      //           placeholder: MemoryImage(kTransparentImage),
                      //           fit: BoxFit.cover,
                      //           fadeInDuration: entranceAnimationDuration,
                      //         ),
                      //       ),
                      //     ),
                      //   ),// 设置水平滚动.builder(
                      // ),
                    ),

                ],
              ),
            ),
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
      cardBox.localToGlobal(cardBox.size.topRight(Offset.zero), ancestor: overlay).dy, // 与卡片底部对齐
      MediaQuery.of(context).size.width,
      overlay.size.height,
    );

    showMenu(
      context: context,
      position: position,
      items: [
        if(type != 'home' && type != 'history' && type != 'personal')
          PopupMenuItem(
            child: ListTile(
              leading: Icon(Icons.delete),
              title: Text('删除'),
              onTap: () {
                // 处理删除操作
                if(deletePost != null){
                  deletePost!();
                }else{
                  print('empty delete function!!!');
                }
                Navigator.pop(context);
              },
            ),
          ),

        PopupMenuItem(
          child: ListTile(
            leading: Icon(Icons.favorite),
            title: Text('收藏'),
            onTap: () {
              // 处理收藏操作
              Navigator.pop(context);
            },
          ),
        ),
      ],
    );
  }
}
