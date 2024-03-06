import 'package:flutter/material.dart';
import 'package:forum/theme/theme_data.dart';


Map iconDict = const {
  '收藏': Icons.star,
  '我的创作': Icons.edit,
  '我的关注': Icons.favorite_rounded,
  '设置': Icons.settings,
};
Map colorDict =  {
  '收藏': Colors.yellow[600],
  '我的创作': Colors.blue,
  '我的关注': Colors.red,
  '设置': Colors.grey,
};

class AccountPageCard extends StatelessWidget{
  final String name;
  const AccountPageCard(this.name,{super.key});
  @override
  Widget build(BuildContext context){

    return Card(
      child: Container(
          height: 50,
          child: InkWell(
            onTap: (){

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