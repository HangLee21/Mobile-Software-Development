import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
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
              onPressed: (){
                if(username == '' ||  userId == '' || password1 == '' || password2 == '' || email == ''){
                  EasyLoading.showError('请补全信息');
                }else if(password1 != password2){
                  EasyLoading.showError('请输入两次相同的密码');
                }else{
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => PinputPage(username, userId, password1, password2, email: email, type: 'signup')));
                }
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