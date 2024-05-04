import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:forum/pages/signup.dart';
import 'package:http/http.dart' as http;
import '../theme/theme_data.dart';
import '../main.dart';
import '../url/user.dart';
import '../url/websocket_service.dart';
import 'navigation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../classes/localStorage.dart';

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

  final FocusNode _accountNode = FocusNode();
  final FocusNode _passwordNode = FocusNode();
  final _websocketService = WebSocketService();
  // SharedPreferences? sharedPreferences;
  @override
  void initState(){
    super.initState();
    // init();
  }

  // void init() async{
  //   sharedPreferences = await SharedPreferences.getInstance();
  // }

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
            Listener(
              onPointerDown: (e)=> FocusScope.of(context).requestFocus(_accountNode),
              child: TextField(
                focusNode: _accountNode,
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
            )
            ,
            const SizedBox(height: 20),
            Listener(
              onPointerDown: (e)=> FocusScope.of(context).requestFocus(_passwordNode),
              child: TextField(
                focusNode: _passwordNode,
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
            ),

            const SizedBox(height: 20),
            ElevatedButton(
                onPressed: (){
                  //TODO 登录
                  requestPost(
                    '/api/user/log_in',
                    {
                      'userId': username,
                      'userPassword': password,
                    },
                    {}
                  ).then((http.Response res){
                    if(res.statusCode == 200){
                      Map body = json.decode(res.body) as Map;
                      LocalStorage.setString('userName', body['content']['userName']);
                      LocalStorage.setString('userId', body['content']['userId']);
                      LocalStorage.setString('userAvatar', body['content']['userAvatar']);
                      LocalStorage.setString('userEmail', body['content']['userEmail']);
                      LocalStorage.setString('token', body['token']);
                      _websocketService.connect(body['content']['userId']);
                      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const NavigationExample()), (route) => route == null);
                    }else{
                      throw Exception("登录失败");
                    }
                  });
                  // LocalStorage.setString('token', 'token');
                  // LocalStorage.setString('userName', 'userName');
                  // LocalStorage.setString('userId', 'userId');
                  // LocalStorage.setString('userAvatar', 'userAvatar');
                  // LocalStorage.setString('userEmail', 'userEmail');
                  // Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const NavigationExample()), (route) => route == null);
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