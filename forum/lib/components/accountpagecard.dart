import 'package:flutter/material.dart';
import 'package:forum/pages/favorite.dart';
import 'package:forum/pages/history.dart';
import 'package:forum/pages/settings.dart';
import 'package:forum/pages/starlist.dart';
import 'package:forum/pages/worklist.dart';
import 'package:forum/theme/theme_data.dart';


Map iconDict = const {
  '收藏': Icons.star,
  '我的创作': Icons.edit,
  '我的关注': Icons.favorite_rounded,
  '历史记录': Icons.history,
  '设置': Icons.settings,
};
Map colorDict =  {
  '收藏': Colors.yellow[600],
  '我的创作': Colors.blue,
  '我的关注': Colors.red,
  '历史记录': Colors.black,
  '设置': Colors.grey,
};

Map pageDict = {
  '收藏': StarList(),
  '我的创作': WorkList(),
  '我的关注': FavoriteList(),
  '历史记录': History(),
  '设置': Settings(),
};


class AccountPageCard extends StatelessWidget{
  final String name;
  const AccountPageCard(this.name,{super.key});
  @override
  Widget build(BuildContext context){
    void goto(String page){
        Navigator.push(
            context,
            PageRouteBuilder(
            transitionDuration: Duration(milliseconds: 300),
              pageBuilder: (_, __, ___) => pageDict[name],
              transitionsBuilder: (_, animation, __, child) {
                return SlideTransition(
                  position: Tween<Offset>(
                  begin: Offset(1.0, 0.0),
                  end: Offset.zero,
                  ).animate(animation),
                  child: child,
                );
              }
            )).then((context){
              
        });
    }
    return Card(
      child: Container(
          height: 70,
          child: InkWell(
            onTap: (){
              goto(name);
            },
            child: Row(
              children: [
                const SizedBox(width: 20,),
                Icon(iconDict[name], color: colorDict[name],),
                const SizedBox(width: 20,),
                Text(name),
              ],
            ),
          )

      ),
    );
  }
}