import 'package:flutter/material.dart';
import '../theme/theme_data.dart';
import 'homepage.dart';

class LoginLayout extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Center(
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
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => MyHomePage()));
                  },
                child: const Text('登录'),
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