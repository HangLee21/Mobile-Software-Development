import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:forum/components/card_list.dart';
import 'package:forum/components/content_card.dart';
import 'package:forum/url/user.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'navigation.dart';
import 'dart:developer' as developer;

class Settings extends StatefulWidget {
  @override
  SettingsState createState() => SettingsState();
}


class SettingsState extends State<Settings>{
  String username = '';
  String userid= '';
  String avatar = '';
  String email = '';
  SharedPreferences? sharedPreferences;
  @override
  void initState(){
    super.initState();
    init();
  }
  void init() async{
    sharedPreferences = await SharedPreferences.getInstance();
    username = sharedPreferences?.getString("userName")??"";
    userid = sharedPreferences?.getString("userId")??"";
    avatar = sharedPreferences?.getString("userAvatar")??"";
    email = sharedPreferences?.getString("userEmail")??"";
    setState(() {});
  }
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
          title: const Text(
              '设置'
          )
      ),
      body: Center(
        child: ListView(
          children: [
              const SizedBox(height: 20,),
              TextField(
                controller: TextEditingController(text: username??''),
                obscureText: false,
                decoration: const InputDecoration(
                  labelText: '昵称',
                  hintText: '输入8-16位数字或字母',
                  icon: Icon(Icons.person),
                ),
                onSubmitted: (String value){
                  requestPost('/account/change_username',
                      {
                        'userid': userid,
                        'content': value,
                      },
                      {
                        'Content-Type': 'application/json',
                        'Authorization': 'Bear ${sharedPreferences?.getString('token')??'43432'}'
                      }).then((http.Response res){
                      if(res.statusCode == 200){
                        sharedPreferences?.setString('token', json.decode(res.body)['token']);
                        setState(() {
                          username = value;
                          sharedPreferences?.setString('userName', value);
                        });
                      }
                  });
                },
            ),
            const SizedBox(height: 20,),
            TextField(
              controller: TextEditingController(text: userid),
              obscureText: false,
              decoration: const InputDecoration(
                labelText: '账号',
                hintText: '输入8-16位数字或字母',
                icon: Icon(Icons.key),
              ),
              onSubmitted: (String value){
                requestPost('/account/change_userId',
                    {
                      'userid': userid,
                      'content': value,
                    },
                    {
                      'Content-Type': 'application/json',
                      'Authorization': 'Bear ${sharedPreferences?.getString('token')??'43432'}'
                    }).then((http.Response res){
                  if(res.statusCode == 200){
                    sharedPreferences?.setString('token', json.decode(res.body)['token']);
                    setState(() {
                      userid = value;
                      sharedPreferences?.setString('userId', value);
                    });
                  }
                });
              },
            ),
            const SizedBox(height: 20,),
            TextField(
              controller: TextEditingController(text: email),
              obscureText: false,
              decoration: const InputDecoration(
                labelText: '邮箱',
                hintText: '输入8-16位数字或字母',
                icon: Icon(Icons.email),
              ),
              onSubmitted: (String value){
                requestPost('/account/change_email',
                    {
                      'userid': userid,
                      'content': value,
                    },
                    {
                      'Content-Type': 'application/json',
                      'Authorization': 'Bear ${sharedPreferences?.getString('token')??'43432'}'
                    }).then((http.Response res){
                  if(res.statusCode == 200){
                    sharedPreferences?.setString('token', json.decode(res.body)['token']);
                    setState(() {
                      email = value;
                      sharedPreferences?.setString('userEmail', value);
                    });
                  }
                });
              },
            )

          ],

        ),
      )

    );
  }
}
