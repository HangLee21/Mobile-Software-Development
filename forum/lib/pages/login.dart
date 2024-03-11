import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:forum/localstorage/localstorage.dart';
import 'package:forum/pages/signup.dart';
import 'package:http/http.dart' as http;
import '../theme/theme_data.dart';
import '../main.dart';
import '../url/user.dart';
import 'navigation.dart';


class LoginLayout extends StatelessWidget{

  @override
  Widget build(BuildContext context){
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 25,
                  child: Image.asset('assets/images/logo_transparent.png'),
                ),

                const SizedBox(width: 10,),
                const Text('万源论坛',style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),)
              ],
            )
        ),
      ),
      body: Center(
        child: Login(),
      ),
    );
  }
}

class Login extends StatefulWidget{
  @override
  State<StatefulWidget> createState() => _LoginState();
}

class _LoginState extends State<Login>{
  String username = '';
  String password = '';
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      child: Center(
        child:Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              foregroundImage: AssetImage('assets/images/1.jpg'),
              radius: 40,
            ),
            const SizedBox(height: 20),
            TextField(
              textDirection: TextDirection.ltr,
              obscureText: false,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: '用户名',
                hintText: '输入8-16位数字或字母'
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
              obscureText: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: '密码',
                hintText: '输入8-16位数字或字母'
              ),
              onChanged: (str){
                setState(() {
                  password = str;
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
                onPressed: (){
                  //TODO 登录
                  requestPost(
                    '/user/log_in',
                    {
                      'username': username,
                      'password': password,
                    },
                    {}
                  ).then((http.Response res){
                    if(res.statusCode == 200){
                      Map body = json.decode(res.body) as Map;
                      LocalStorage.setString('token', body['token']);
                      LocalStorage.setString('userName', body['content']['userName']);
                      LocalStorage.setString('userId', body['content']['userId']);
                      LocalStorage.setString('userAvatar', body['content']['userAvatar']);
                      LocalStorage.setString('userEmail', body['content']['userEmail']);
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => NavigationExample(username:body['content']['userName'], userid: body['content']['userId'],avatar: body['content']['userAvatar'])));
                    }else{
                      throw Exception("登录失败");
                    }
                  });
                },
                style: ButtonStyle(
                    minimumSize: MaterialStateProperty.all(Size(250, 50))
                ),
                child: const Text('登录'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: (){
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => SignupLayout()));
              },
              style: ButtonStyle(
                  minimumSize: MaterialStateProperty.all(Size(250, 50))
              ),
              child: const Text('注册'),
            )
          ],
        ),
      ),
    );
  }
}