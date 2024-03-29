import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:forum/components/accountpagecard.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountPage extends StatefulWidget {
  @override
  _AccountState createState() => _AccountState();

}
class _AccountState extends State<AccountPage>{
  late  String username;
  late  String userid;
  late  String avatar;

  @override
  void initState(){
    super.initState();
    init();
  }

  void init() async {
    sharedPreferences = await SharedPreferences.getInstance();
    setState(() {});
  }

  SharedPreferences? sharedPreferences;
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
                    CircleAvatar(
                      foregroundImage: NetworkImage(sharedPreferences?.getString('userAvatar')??''),
                      radius: 50,
                    ),
                    const SizedBox(width: 20,),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                              children: [
                                Text(sharedPreferences?.getString('userName')??'',
                                    style: const TextStyle(
                                      fontSize: 30,
                                    )
                                ),
                              ]
                          ),
                          const SizedBox(height: 20),
                          Row(
                              children: [
                                Text('id: ${sharedPreferences?.getString('userId')??''}',
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
            const AccountPageCard('历史记录'),
            const AccountPageCard('设置'),
          ],
        )
    );

  }
}