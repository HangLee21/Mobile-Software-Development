import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:forum/classes/localStorage.dart';
import 'package:forum/components/card_list.dart';
import 'package:forum/components/content_card.dart';
import 'package:forum/constants.dart';
import 'package:forum/pages/login.dart';
import 'package:forum/url/user.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../url/websocket_service.dart';
import 'navigation.dart';
import 'dart:developer' as developer;

class Settings extends StatefulWidget {
  @override
  SettingsState createState() => SettingsState();
}


class SettingsState extends State<Settings>{
  String username = '';
  String userid= '';
  String avatar = 'https://android-1324918669.cos.ap-beijing.myqcloud.com/default_avatar_1.png';
  String email = '';
  int imageNumber = 0;
  SharedPreferences? sharedPreferences;
  final _websocketService = WebSocketService();
  @override
  void initState(){
    super.initState();
    init();
  }
  void init() async{
    sharedPreferences = await SharedPreferences.getInstance();
    username = sharedPreferences?.getString("userName")??"";
    userid = sharedPreferences?.getString("userId")??"";
    avatar = sharedPreferences?.getString("userAvatar")??"https://android-1324918669.cos.ap-beijing.myqcloud.com/default_avatar_1.png";
    email = sharedPreferences?.getString("userEmail")??"";
    setState(() {});
  }

  void _changeAvatar() async{
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      print('yes');
      File file = File(result.files.single.path!);
      var uri = Uri.parse('http://$BASEURL/api/cos/upload_avatar');
      var request = http.MultipartRequest('POST', uri);
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          file.path,
        ),
      );
      request.headers.addAll({
        'Content-Type': 'multipart/form-data',
        'Authorization': 'Bearer ${sharedPreferences?.getString('token') ?? '43432'}',
      });
      request.fields.addAll({
        'userId': sharedPreferences?.getString('userId') ?? '',
      });

      var response = await request.send();
      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        sharedPreferences?.setString('token', json.decode(responseBody)['token']);
        print(json.decode(responseBody)['content'][0]);
        sharedPreferences?.setString('userAvatar', json.decode(responseBody)['content'][0]);
        avatar = json.decode(responseBody)['content'][0];
        imageNumber++;
        EasyLoading.showSuccess('修改成功');
        setState(() {
        });
      } else {
        print('Upload failed with status ${response.statusCode}');
      }
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
                  Text('头像',
                    style: TextStyle(
                      fontSize: 16
                    ),
                  ),
                  Expanded(
                    child: Container(
                      alignment: Alignment.bottomRight,
                      child: GestureDetector(
                        onTap: _changeAvatar,
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                                '$avatar?$imageNumber',
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
                  requestPost('/api/account/change_username',
                      {
                        'userId': userid,
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
                      EasyLoading.showSuccess('修改成功');
                    }else{
                      EasyLoading.showError('修改失败');
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
                    requestPost('/api/account/change_userId',
                        {
                          'userId': userid,
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
                        EasyLoading.showSuccess('修改成功');
                      }else{
                        EasyLoading.showError('修改失败');
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
                    requestPost('/api/account/change_email',
                        {
                          'userId': userid,
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
                        EasyLoading.showSuccess('修改成功');
                      }else{
                        EasyLoading.showError('修改失败');
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
            ),
            const SizedBox(height: 20,),
            ElevatedButton(onPressed: (){
              sharedPreferences?.remove('token');
              sharedPreferences?.remove('userName');
              sharedPreferences?.remove('userId');
              sharedPreferences?.remove('userAvatar');
              sharedPreferences?.remove('userEmail');
              // _websocketService.close();
              Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => LoginLayout()), (route) => false);
            }, child: Text('退出登录'))
          ],
        ),
      )
    );
  }
}
