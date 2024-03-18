import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:forum/components/card_list.dart';
import 'package:forum/components/content_card.dart';
import 'package:forum/constants.dart';
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

  void _changeAvatar() async{
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      File file = File(result.files.single.path!);
      // requestPost(
      //     Uri.parse('$BASEURL/cos/upload_avatar'),
      //     {
      //       'file':
      //     },
      //     {
      //       'Content-Type': 'application/form-data',
      //       'Authorization': 'Bearer ${sharedPreferences?.getString('token')??'43432'}'
      //     }
      // );
    }
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
            FractionallySizedBox(
              widthFactor: 0.9,
              child: Row(
                children: [
                  Text('头像'),
                  Expanded(
                    child: Container(
                      alignment: Alignment.bottomRight,
                      child: GestureDetector(
                        onTap: _changeAvatar,
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                                sharedPreferences?.getString('userAvatar')??'',
                                width: 50,
                                height: 50
                            )
                        ),
                      )
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20,),
            //username
            FractionallySizedBox(
              widthFactor: 0.9,
              child: TextField(
                controller: TextEditingController(text: username??''),
                obscureText: false,
                textAlign: TextAlign.right,
                decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: '输入8-16位数字或字母',
                    prefixText: '昵称'
                ),
                onSubmitted: (String value){
                  requestPost('/account/change_username',
                      {
                        'userid': userid,
                        'content': value,
                      },
                      {
                        'Content-Type': 'application/json',
                        'Authorization': 'Bearer ${sharedPreferences?.getString('token')??'43432'}'
                      }).then((http.Response res){
                    if(res.statusCode == 200){
                      sharedPreferences?.setString('token', json.decode(res.body)['token']);
                      setState(() {
                        username = value;
                        sharedPreferences?.setString('userName', value);
                      });
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('修改成功！'),backgroundColor: Colors.green,));
                    }else{
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('修改失败！'),backgroundColor: Colors.red,));
                    }
                  });
                },
              ),
            ),


            const SizedBox(height: 20,),
            //userid
            FractionallySizedBox(
              widthFactor: 0.9,
                child: TextField(
                  controller: TextEditingController(text: userid),
                  obscureText: false,
                  textAlign: TextAlign.right,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: '输入8-16位数字或字母',
                    prefixText: '账号'
                  ),
                  onSubmitted: (String value){
                    requestPost('/account/change_userId',
                        {
                          'userid': userid,
                          'content': value,
                        },
                        {
                          'Content-Type': 'application/json',
                          'Authorization': 'Bearer ${sharedPreferences?.getString('token')??'43432'}'
                        }).then((http.Response res){
                      if(res.statusCode == 200){
                        sharedPreferences?.setString('token', json.decode(res.body)['token']);
                        setState(() {
                          userid = value;
                          sharedPreferences?.setString('userId', value);
                        });
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('修改成功！'),backgroundColor: Colors.green,));
                      }else{
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('修改失败！'),backgroundColor: Colors.red,));
                      }
                    });
                  },
                ),
            ),
            const SizedBox(height: 20,),

            //email
            FractionallySizedBox(
              widthFactor: 0.9,
                child: TextField(
                  controller: TextEditingController(text: email),
                  obscureText: false,
                  textAlign: TextAlign.right,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: '输入8-16位数字或字母',
                    prefixText: '邮箱'
                  ),
                  onSubmitted: (String value){
                    requestPost('/account/change_email',
                        {
                          'userid': userid,
                          'content': value,
                        },
                        {
                          'Content-Type': 'application/json',
                          'Authorization': 'Bearer ${sharedPreferences?.getString('token')??'43432'}'
                        }).then((http.Response res){
                      if(res.statusCode == 200){
                        sharedPreferences?.setString('token', json.decode(res.body)['token']);
                        setState(() {
                          email = value;
                          sharedPreferences?.setString('userEmail', value);
                        });
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('修改成功！'),backgroundColor: Colors.green,));
                      }else{
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('修改失败！'),backgroundColor: Colors.red,));
                      }
                    });
                  },
                ),
            ),
            const SizedBox(height: 20,),
            FractionallySizedBox(
              widthFactor: 0.9,
              child: TextButton(
                onPressed: (){

                },
                child: Text('修改密码')
              )
            )
          ],

        ),
      )

    );
  }
}
