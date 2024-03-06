import 'package:flutter/material.dart';
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
  String password1 = '';
  String password2 = '';
  String email = '';
  String code = '';
  bool gettingcode = false;
  @override
  Widget build(BuildContext context) {

    return SizedBox(
      width: 250,
      child: Center(
        child:Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
              obscureText: true,
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
            !gettingcode?
            ElevatedButton(
              onPressed: (){
                setState(() {
                  //TODO 获取验证码
                  gettingcode = true;
                });
              },
              style: ButtonStyle(
                  minimumSize: MaterialStateProperty.all(Size(250, 50))
              ),
              child: const Text('获取验证码'),
            ):Column(
              children: [
                TextField(
                  textDirection: TextDirection.ltr,
                  obscureText: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: '验证码',
                  ),
                  onChanged: (str){
                    setState(() {
                      code = str;
                    });
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: (){
                    //TODO 注册
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => NavigationExample()));
                  },
                  style: ButtonStyle(
                      minimumSize: MaterialStateProperty.all(Size(250, 50))
                  ),
                  child: const Text('注册'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: (){
                    setState(() {
                      //TODO 获取验证码
                      gettingcode = true;
                    });
                  },
                  style: ButtonStyle(
                      minimumSize: MaterialStateProperty.all(Size(250, 50))
                  ),
                  child: const Text('重新获取验证码'),
                )
              ]
            )

          ],
        ),
      ),
    );
  }
}