import 'dart:async';

import 'package:flutter/material.dart';
import 'package:forum/pages/login.dart';
import 'package:forum/pages/pinputpage.dart';
import 'package:forum/url/user.dart';
import 'package:http/http.dart' as http;
import 'navigation.dart';

class EditPasswordLayout extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
          title: const Text(
              '注册'
          )
      ),
      body: Center(
        child: EditPassword(),
      ),
    );
  }
}

class EditPassword extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => EditPasswordState();
}

class EditPasswordState extends State<EditPassword>{
  String oldpassword = '';
  String password1 = '';
  String password2 = '';

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
                    labelText: '原密码',
                  ),
                  onChanged: (str){
                    setState(() {
                      oldpassword = str;
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
                ElevatedButton(
                  onPressed: (password1 == '' || password2 == '' || oldpassword == '')?null:(){

                  },
                  style: ButtonStyle(
                      minimumSize: MaterialStateProperty.all(Size(250, 50))
                  ),
                  child: const Text('确认'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}