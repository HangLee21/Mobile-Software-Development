import 'package:flutter/material.dart';
import 'package:forum/components/card_list.dart';
import 'package:forum/components/content_card.dart';
import 'navigation.dart';

class FavoriteList extends StatelessWidget {
  //TODO 获取关注列表
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
          title: const Text(
              '我的关注'
          )
      ),
    );
  }
}
