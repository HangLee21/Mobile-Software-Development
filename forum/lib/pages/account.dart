import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:forum/components/accountpagecard.dart';

class AccountPage extends StatelessWidget{
  final String username;
  final String userid;
  const AccountPage(this.username,this.userid, {super.key});

  @override
  Widget build(BuildContext context){
    final ThemeData theme = Theme.of(context);
    return Center(
        child: ListView(
          children: [
            Container(
              alignment: Alignment.center,
              height: 150,
              child: Card(
                child: Row(
                  children: [
                    const SizedBox(width: 20,),
                    const CircleAvatar(
                      foregroundImage: AssetImage('assets/images/1.jpg'),
                      radius: 50,
                    ),
                    const SizedBox(width: 20,),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                              children: [
                                Text(username,
                                    style: const TextStyle(
                                      fontSize: 30,
                                    )
                                ),
                              ]
                          ),
                          const SizedBox(height: 20),
                          Row(
                              children: [
                                Text('id: $userid',
                                    style: const TextStyle(
                                        fontSize: 15,
                                        color: Colors.grey
                                    )
                                ),
                              ]
                          ),

                        ]

                    ),

                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const AccountPageCard('收藏'),
            const AccountPageCard('我的创作'),
            const AccountPageCard('我的关注'),
            const AccountPageCard('设置')
          ],
        )
    );

  }
}