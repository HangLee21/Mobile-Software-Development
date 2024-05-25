import 'dart:async';

import 'package:flutter/material.dart';
import 'package:forum/pages/login.dart';
import 'package:forum/pages/pinputpage.dart';
import 'package:forum/url/user.dart';
import 'package:http/http.dart' as http;
import 'navigation.dart';

class SignupLayout extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
          title: const Text(
              '注册'
          )
      ),
      body: Center(
        child: Signup(),
      ),
    );
  }
}

class Signup extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SignupState();
}

class _SignupState extends State<Signup>{
  String username = '';
  String userId = '';
  String password1 = '';
  String password2 = '';
  String email = '';

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      child: Center(
        child:Container(
          height: double.infinity,
          width: double.infinity,
          child:SingleChildScrollView(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            TextField(
              textDirection: TextDirection.ltr,
              obscureText: false,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: '用户名',
              ),
              onChanged: (str){
                setState(() {
                  username = str;
                });
              },
            ),
            const SizedBox(height: 20),
            TextField(
              textDirection: TextDirection.ltr,
              obscureText: false,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: '账号',
              ),
              onChanged: (str){
                setState(() {
                  userId = str;
                });
              },
            ),
            const SizedBox(height: 20),
            TextField(
              textDirection: TextDirection.ltr,
              obscureText: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: '密码',
              ),
              onChanged: (str){
                setState(() {
                  password1 = str;
                });
              },
            ),
            const SizedBox(height: 20),
            TextField(
              textDirection: TextDirection.ltr,
              obscureText: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: '再次确认密码',
              ),
              onChanged: (str){
                setState(() {
                  password2 = str;
                });
              },
            ),
            const SizedBox(height: 20),
            TextField(
              textDirection: TextDirection.ltr,
              obscureText: false,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: '邮箱',
              ),
              onChanged: (str){
                setState(() {
                  email = str;
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: (username == '' ||  userId == '' || password1 == '' || password2 == '' || email == '')?null:(){
                //TODO 注册
                // requestPost(
                //     '/api/user/register',
                //     {
                //       'userName': username,
                //       'userId': userId,
                //       'userPassword': password1,
                //       'userEmail': email,
                //       'userAvatar': 'https://android-1324918669.cos.ap-beijing.myqcloud.com/default_avatar_1.png'
                //     }, {}).then((http.Response res){
                //       if(res.statusCode == 200){
                //         Navigator.of(context).push(MaterialPageRoute(builder: (context) => LoginLayout()));
                //       }
                // });
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => PinputPage(username, userId, password1, password2, email: email, type: 'signup')));
              },
              style: ButtonStyle(
                  minimumSize: MaterialStateProperty.all(Size(250, 50))
              ),
              child: const Text('注册'),
            ),
          ],
        ),
          ),
        ),
      ),
    );
  }
}