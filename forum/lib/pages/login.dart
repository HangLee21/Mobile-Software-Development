import 'package:flutter/material.dart';
import '../theme/theme_data.dart';
import '../main.dart';
import 'navigation.dart';

class LoginLayout extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            'Login'
          )
        )
      ),
      body: Center(
        child: Login(),
      ),
    );
  }
}

class Login extends StatelessWidget{
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
            const TextField(
              textDirection: TextDirection.ltr,
              obscureText: false,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Username',
              ),
            ),
            const SizedBox(height: 20),
            const TextField(
              textDirection: TextDirection.ltr,
              obscureText: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Password',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
                onPressed: (){
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => NavigationExample()));
                  },
                child: const Text('登录'),
                style: ButtonStyle(
                    minimumSize: MaterialStateProperty.all(Size(250, 50))
                ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: (){
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => NavigationExample()));
              },
              child: const Text('注册'),
              style: ButtonStyle(
                  minimumSize: MaterialStateProperty.all(Size(250, 50))
              ),
            )
          ],
        ),
      ),
    );
  }
}