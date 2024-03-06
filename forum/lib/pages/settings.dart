import 'package:flutter/material.dart';
import 'package:forum/components/card_list.dart';
import 'package:forum/components/content_card.dart';
import 'navigation.dart';

class Settings extends StatelessWidget {
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
          title: const Text(
              '设置'
          )
      ),
    );
  }
}
