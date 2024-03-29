import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:forum/pages/signup.dart';
import 'package:http/http.dart' as http;
import '../theme/theme_data.dart';
import '../main.dart';
import '../url/user.dart';
import 'navigation.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  SharedPreferences? sharedPreferences;
  @override
  void initState(){
    super.initState();
    init();
  }

  void init() async{
    sharedPreferences = await SharedPreferences.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      child: Center(
        child:Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              // foregroundImage: AssetImage('assets/images/1.jpg'),
              backgroundImage: NetworkImage('https://android-1324918669.cos.ap-beijing.myqcloud.com/default_avatar.png'),
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
                  // requestPost(
                  //   '/api/user/log_in',
                  //   {
                  //     'username': username,
                  //     'password': password,
                  //   },
                  //   {}
                  // ).then((http.Response res){
                  //   if(res.statusCode == 200){
                  //     Map body = json.decode(res.body) as Map;
                  //     sharedPreferences?.setString('token', body['token']);
                  //     sharedPreferences?.setString('userName', body['content']['userName']);
                  //     sharedPreferences?.setString('userId', body['content']['userId']);
                  //     sharedPreferences?.setString('userAvatar', body['content']['userAvatar']);
                  //     sharedPreferences?.setString('userEmail', body['content']['userEmail']);
                  //     Navigator.of(context).push(MaterialPageRoute(builder: (context) => const NavigationExample()));
                  //   }else{
                  //
                  //     // throw Exception("登录失败");
                  //   }
                  // });
                  sharedPreferences?.setString('token', 'token');
                  sharedPreferences?.setString('userName', 'userName');
                  sharedPreferences?.setString('userId', 'userId');
                  sharedPreferences?.setString('userAvatar', 'userAvatar');
                  sharedPreferences?.setString('userEmail', 'userEmail');
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => const NavigationExample()));
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